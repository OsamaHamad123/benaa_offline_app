import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/file_number_entities.dart';

class FirestoreFileNumberService {
  FirestoreFileNumberService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  String get projectId => _firestore.app.options.projectId;

  CollectionReference<Map<String, dynamic>> get _counters => _firestore.collection('file_number_counters');
  CollectionReference<Map<String, dynamic>> get _blocks => _firestore.collection('file_number_blocks');
  CollectionReference<Map<String, dynamic>> get _allocations => _firestore.collection('file_number_allocations');

  Future<void> ensureCounterDocument({
    required int year,
    String prefix = 'GZ',
    int blockSizeDefault = 500,
  }) async {
    final docId = 'global_$year';
    final counterRef = _counters.doc(docId);
    final existing = await counterRef.get();
    if (existing.exists) {
      return;
    }

    await counterRef.set({
      'prefix': prefix.toUpperCase(),
      'year': year,
      'nextNumber': 1,
      'blockSizeDefault': blockSizeDefault,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<FileNumberBlock> reserveBlock({
    required String deviceId,
    required String userId,
    String prefix = 'GZ',
    int? year,
    int blockSize = 500,
    String appVersion = 'unknown',
    Duration expiresIn = const Duration(days: 30),
  }) async {
    final now = DateTime.now().toUtc();
    final effectiveYear = year ?? now.year;
    final counterDocId = 'global_$effectiveYear';

    late FileNumberBlock block;

    await _firestore.runTransaction((transaction) async {
      final counterRef = _counters.doc(counterDocId);
      final counterSnapshot = await transaction.get(counterRef);
      final counterData = counterSnapshot.data();

      final currentPrefix = (counterData?['prefix']?.toString().trim().isNotEmpty ?? false)
          ? counterData!['prefix'].toString().trim().toUpperCase()
          : prefix.toUpperCase();
      final currentYear = (counterData?['year'] as int?) ?? effectiveYear;
      final nextNumber = (counterData?['nextNumber'] as int?) ?? 1;
      final defaultSize = (counterData?['blockSizeDefault'] as int?) ?? blockSize;
      final requestedSize = blockSize <= 0 ? defaultSize : blockSize;

      final start = nextNumber;
      final end = nextNumber + requestedSize - 1;
      final blockId = '${deviceId}_${currentYear}_${DateTime.now().millisecondsSinceEpoch}_$start';
      final expiresAt = Timestamp.fromDate(now.add(expiresIn));

      transaction.set(
        counterRef,
        {
          'prefix': currentPrefix,
          'year': currentYear,
          'nextNumber': end + 1,
          'blockSizeDefault': defaultSize,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final blockRef = _blocks.doc(blockId);
      transaction.set(
        blockRef,
        {
          'blockId': blockId,
          'deviceId': deviceId,
          'userId': userId,
          'prefix': currentPrefix,
          'year': currentYear,
          'start': start,
          'end': end,
          'status': 'reserved',
          'reservedAt': FieldValue.serverTimestamp(),
          'expiresAt': expiresAt,
          'usedCount': 0,
          'releasedCount': 0,
          'appVersion': appVersion,
          'source': 'cedar_file_numbers',
        },
      );

      block = FileNumberBlock(
        blockId: blockId,
        deviceId: deviceId,
        userId: userId,
        prefix: currentPrefix,
        year: currentYear,
        start: start,
        end: end,
        status: 'reserved',
        reservedAt: now,
        expiresAt: expiresAt.toDate(),
        usedCount: 0,
        releasedCount: 0,
        appVersion: appVersion,
      );
    });

    return block;
  }

  Future<void> confirmAssignedNumbers(List<FileNumberAllocation> allocations) async {
    if (allocations.isEmpty) return;

    final batch = _firestore.batch();
    for (final allocation in allocations) {
      final allocationRef = _allocations.doc(allocation.fileNumber);
      batch.set(
        allocationRef,
        {
          'fileNumber': allocation.fileNumber,
          'number': allocation.number,
          'year': allocation.year,
          'prefix': allocation.prefix,
          'status': 'synced',
          'beneficiaryLocalId': allocation.beneficiaryLocalId,
          'beneficiaryRemoteId': allocation.beneficiaryRemoteId,
          'deviceId': allocation.deviceId,
          'userId': allocation.userId,
          'blockId': allocation.blockId,
          'assignedAtLocal': allocation.assignedAtLocal.toIso8601String(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final blockRef = _blocks.doc(allocation.blockId);
      batch.set(
        blockRef,
        {
          'status': 'partially_used',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<List<FileNumberBlock>> fetchDeviceBlocks({
    required String deviceId,
    String? userId,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _blocks.where('deviceId', isEqualTo: deviceId);
    if (userId != null && userId.trim().isNotEmpty) {
      query = query.where('userId', isEqualTo: userId.trim());
    }

    final snapshot = await query.orderBy('reservedAt', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FileNumberBlock(
        blockId: data['blockId']?.toString() ?? doc.id,
        deviceId: data['deviceId']?.toString() ?? '',
        userId: data['userId']?.toString() ?? '',
        prefix: data['prefix']?.toString() ?? 'GZ',
        year: (data['year'] as int?) ?? DateTime.now().year,
        start: (data['start'] as int?) ?? 0,
        end: (data['end'] as int?) ?? 0,
        status: data['status']?.toString() ?? 'reserved',
        reservedAt: (data['reservedAt'] as Timestamp?)?.toDate(),
        expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
        usedCount: (data['usedCount'] as int?) ?? 0,
        releasedCount: (data['releasedCount'] as int?) ?? 0,
        appVersion: data['appVersion']?.toString() ?? 'unknown',
      );
    }).toList(growable: false);
  }

  Future<void> releaseUnusedBlockNumbers(String blockId) async {
    await _blocks.doc(blockId).set(
      {
        'status': 'released',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<List<FileNumberAllocation>> fetchDeviceAllocations({
    required String deviceId,
    String? userId,
    int limit = 3000,
  }) async {
    Query<Map<String, dynamic>> query = _allocations.where('deviceId', isEqualTo: deviceId);
    if (userId != null && userId.trim().isNotEmpty) {
      query = query.where('userId', isEqualTo: userId.trim());
    }

    final snapshot = await query.orderBy('syncedAt', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FileNumberAllocation(
        fileNumber: data['fileNumber']?.toString() ?? doc.id,
        number: (data['number'] as int?) ?? 0,
        year: (data['year'] as int?) ?? DateTime.now().year,
        prefix: data['prefix']?.toString() ?? 'GZ',
        status: data['status']?.toString() ?? 'assigned',
        beneficiaryLocalId: data['beneficiaryLocalId']?.toString() ?? '',
        beneficiaryRemoteId: data['beneficiaryRemoteId']?.toString(),
        deviceId: data['deviceId']?.toString() ?? deviceId,
        userId: data['userId']?.toString() ?? (userId ?? ''),
        blockId: data['blockId']?.toString() ?? '',
        assignedAtLocal: DateTime.tryParse(data['assignedAtLocal']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList(growable: false);
  }

  Future<FileNumberCounterStatus?> getRemoteCounterStatus({
    int? year,
  }) async {
    final effectiveYear = year ?? DateTime.now().year;
    final snapshot = await _counters.doc('global_$effectiveYear').get();
    final data = snapshot.data();
    if (data == null) return null;

    return FileNumberCounterStatus(
      prefix: data['prefix']?.toString() ?? 'GZ',
      year: (data['year'] as int?) ?? effectiveYear,
      nextNumber: (data['nextNumber'] as int?) ?? 1,
      blockSizeDefault: (data['blockSizeDefault'] as int?) ?? 500,
    );
  }

  Future<void> debugFileNumberFirestoreAccess({
    required int year,
    required String uid,
    required String email,
  }) async {
    final counterDocId = 'global_$year';
    final now = DateTime.now().toUtc();

    Future<void> runStep(String name, Future<void> Function() action) async {
      try {
        await action();
      } catch (e) {
        throw StateError('debugFileNumberFirestoreAccess failed at step: $name, error: $e');
      }
    }

    await runStep('read_counter_global_2026', () async {
      await _counters.doc(counterDocId).get();
    });

    await runStep('write_counter_debug_access_test', () async {
      await _counters.doc('debug_access_test').set({
        'uid': uid,
        'email': email,
        'ts': FieldValue.serverTimestamp(),
        'projectId': _firestore.app.options.projectId,
      }, SetOptions(merge: true));
    });

    await runStep('write_block_debug_block_test', () async {
      await _blocks.doc('debug_block_test').set({
        'blockId': 'debug_block_test',
        'deviceId': 'debug-device',
        'userId': uid,
        'prefix': 'GZ',
        'year': year,
        'start': 1,
        'end': 1,
        'status': 'reserved',
        'reservedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 1))),
        'usedCount': 0,
        'releasedCount': 0,
        'source': 'cedar_file_numbers',
      }, SetOptions(merge: true));
    });

    await runStep('write_allocation_debug_allocation_test', () async {
      await _allocations.doc('debug_allocation_test').set({
        'fileNumber': 'debug_allocation_test',
        'status': 'synced',
        'beneficiaryLocalId': 'debug',
        'beneficiaryRemoteId': null,
        'deviceId': 'debug-device',
        'userId': uid,
        'blockId': 'debug_block_test',
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    await runStep('cleanup_debug_counter', () async {
      await _counters.doc('debug_access_test').delete();
    });
    await runStep('cleanup_debug_block', () async {
      await _blocks.doc('debug_block_test').delete();
    });
    await runStep('cleanup_debug_allocation', () async {
      await _allocations.doc('debug_allocation_test').delete();
    });
  }
}
