import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firestore_taxonomy_service.dart';
import 'firestore_taxonomy_seed_data.dart';

class FirestoreTaxonomySeedFailure {
  final String documentId;
  final String? group;
  final String errorCode;
  final String message;

  const FirestoreTaxonomySeedFailure({
    required this.documentId,
    required this.errorCode,
    required this.message,
    this.group,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'documentId': documentId,
      'group': group,
      'errorCode': errorCode,
      'message': message,
    };
  }

  factory FirestoreTaxonomySeedFailure.fromJson(Map<String, dynamic> json) {
    return FirestoreTaxonomySeedFailure(
      documentId: json['documentId']?.toString() ?? '',
      group: json['group']?.toString(),
      errorCode: json['errorCode']?.toString() ?? 'unknown',
      message: json['message']?.toString() ?? '',
    );
  }

  @override
  String toString() => '$documentId ($errorCode): $message';
}

class FirestoreTaxonomySeedProgress {
  final String operation;
  final String phase;
  final int catalogTotal;
  final int total;
  final int processed;
  final int created;
  final int skipped;
  final int updated;
  final int failed;
  final int pending;
  final String? currentItemId;
  final String? currentGroup;
  final String? message;
  final String? errorCode;
  final String? errorMessage;
  final List<FirestoreTaxonomySeedFailure> failures;

  const FirestoreTaxonomySeedProgress({
    required this.operation,
    required this.phase,
    required this.catalogTotal,
    required this.total,
    required this.processed,
    required this.created,
    required this.skipped,
    required this.updated,
    required this.failed,
    required this.pending,
    this.currentItemId,
    this.currentGroup,
    this.message,
    this.errorCode,
    this.errorMessage,
    this.failures = const <FirestoreTaxonomySeedFailure>[],
  });

  double get percent => total <= 0 ? 0 : (processed / total).clamp(0, 1).toDouble();
}

typedef FirestoreTaxonomySeedProgressCallback = void Function(FirestoreTaxonomySeedProgress progress);

class FirestoreTaxonomySeedReport {
  final int prepared;
  final int catalogTotal;
  final int created;
  final int skipped;
  final int updated;
  final int failed;
  final int pending;
  final bool pausedDueToNetwork;
  final bool resumedFromCheckpoint;
  final List<FirestoreTaxonomySeedFailure> failures;
  final String? message;

  const FirestoreTaxonomySeedReport({
    required this.prepared,
    required this.catalogTotal,
    required this.created,
    required this.skipped,
    required this.updated,
    this.failed = 0,
    this.pending = 0,
    this.pausedDueToNetwork = false,
    this.resumedFromCheckpoint = false,
    this.failures = const <FirestoreTaxonomySeedFailure>[],
    this.message,
  });
}

class _TaxonomySeedCheckpoint {
  final String version;
  final int catalogTotal;
  final List<String> allIds;
  final List<String> successfulIds;
  final List<String> skippedIds;
  final List<String> failedIds;
  final String? lastAttemptedId;
  final DateTime updatedAt;

  const _TaxonomySeedCheckpoint({
    required this.version,
    required this.catalogTotal,
    required this.allIds,
    required this.successfulIds,
    required this.skippedIds,
    required this.failedIds,
    required this.updatedAt,
    this.lastAttemptedId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'catalogTotal': catalogTotal,
      'allIds': allIds,
      'successfulIds': successfulIds,
      'skippedIds': skippedIds,
      'failedIds': failedIds,
      'lastAttemptedId': lastAttemptedId,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory _TaxonomySeedCheckpoint.fromJson(Map<String, dynamic> json) {
    return _TaxonomySeedCheckpoint(
      version: json['version']?.toString() ?? '',
      catalogTotal: _asInt(json['catalogTotal']),
      allIds: _toStringList(json['allIds']),
      successfulIds: _toStringList(json['successfulIds']),
      skippedIds: _toStringList(json['skippedIds']),
      failedIds: _toStringList(json['failedIds']),
      lastAttemptedId: json['lastAttemptedId']?.toString(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList(growable: false);
    }
    return const <String>[];
  }
}

class FirestoreTaxonomySeeder {
  FirestoreTaxonomySeeder({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static bool _isTaxonomyMasterSyncRunning = false;

  static const String taxonomySeedVersion = 'gaza_v1';
  static const String _seedMetaGroup = 'taxonomy_seed_meta';
  static const int _batchSize = 100;
  static const List<int> _progressMilestones = <int>[10, 25, 50, 75, 100];

  static const String _permissionDeniedMessage =
      'Firestore taxonomy permission denied. Check Firestore rules for taxonomy_categories and confirm the app is connected to the correct Firebase project.';

  String get _seedMetaDocumentId => 'taxonomy_seed_version_$taxonomySeedVersion';
  String get _checkpointStorageKey => 'taxonomy_seed_checkpoint_v2_$taxonomySeedVersion';

  DocumentReference<Map<String, dynamic>> _seedMetaDocRef(
    CollectionReference<Map<String, dynamic>> collection,
  ) {
    return collection.doc(_seedMetaDocumentId);
  }

  Future<_TaxonomySeedCheckpoint?> _loadCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_checkpointStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _TaxonomySeedCheckpoint.fromJson(decoded);
    } catch (e) {
      developer.log('Failed to parse taxonomy seed checkpoint: $e', name: 'TaxonomySeeder');
      return null;
    }
  }

  Future<void> _saveCheckpoint(_TaxonomySeedCheckpoint checkpoint) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkpointStorageKey, jsonEncode(checkpoint.toJson()));
  }

  Future<void> _clearCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkpointStorageKey);
  }

  Future<bool> _isSeedVersionApplied(CollectionReference<Map<String, dynamic>> collection) async {
    final snapshot = await _seedMetaDocRef(collection).get();
    if (!snapshot.exists) return false;

    final data = snapshot.data();
    if (data == null) return false;

    return data['version']?.toString() == taxonomySeedVersion && data['isApplied'] == true;
  }

  Future<void> _markSeedVersionApplied(
    CollectionReference<Map<String, dynamic>> collection, {
    required int prepared,
    required int created,
    required int skipped,
    required int updated,
    required String trigger,
    bool force = false,
  }) async {
    await _seedMetaDocRef(collection).set(
      <String, dynamic>{
        'id': _seedMetaDocumentId,
        'group': _seedMetaGroup,
        'name': 'Taxonomy Seed ${taxonomySeedVersion.toUpperCase()}',
        'nameAr': 'إصدار بذور التصنيفات ${taxonomySeedVersion.toUpperCase()}',
        'nameEn': 'Taxonomy Seed ${taxonomySeedVersion.toUpperCase()}',
        'slug': _seedMetaDocumentId,
        'version': taxonomySeedVersion,
        'isApplied': true,
        'isActive': true,
        'journeyType': 'general',
        'sortOrder': -1,
        'metadata': <String, dynamic>{
          'source': 'taxonomy_master_sync',
          'trigger': trigger,
          'force': force,
          'prepared': prepared,
          'created': created,
          'skipped': skipped,
          'updated': updated,
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _logFirebaseProjectContext() async {
    final projectId = Firebase.app().options.projectId;
    final packageInfo = await PackageInfo.fromPlatform();
    developer.log('Firebase project_id: $projectId', name: 'TaxonomySeeder');
    developer.log('App package_name: ${packageInfo.packageName}', name: 'TaxonomySeeder');
  }

  Future<bool> _logAuthContextAndEnsureUser() async {
    final user = _auth.currentUser;
    final hasToken = await user?.getIdToken(false) != null;

    developer.log('FirebaseAuth uid: ${user?.uid}', name: 'TaxonomySeeder');
    developer.log('FirebaseAuth email: ${user?.email}', name: 'TaxonomySeeder');
    developer.log('FirebaseAuth hasIdToken: $hasToken', name: 'TaxonomySeeder');

    if (user == null) {
      developer.log(
        'Cannot seed Firestore taxonomies: no Firebase authenticated user.',
        name: 'TaxonomySeeder',
      );
      return false;
    }

    return true;
  }

  void _logPermissionDeniedHint() {
    developer.log(_permissionDeniedMessage, name: 'TaxonomySeeder');
    developer.log(
      'Check Firebase Console -> App Check -> Firestore enforcement. Disable enforcement for development or configure DebugAppCheckProvider.',
      name: 'TaxonomySeeder',
    );
  }

  bool _isNetworkError(Object error) {
    if (error is SocketException) return true;

    if (error is FirebaseException) {
      return error.code == 'unavailable' || error.code == 'network-request-failed';
    }

    final text = error.toString().toLowerCase();
    return text.contains('unknownhostexception') || text.contains('unable to resolve host') || text.contains('socket');
  }

  Future<bool> _hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<FirestoreTaxonomySeedReport> seedFirestoreTaxonomies({
    bool force = false,
    String trigger = 'manual',
    FirestoreTaxonomySeedProgressCallback? onProgress,
  }) async {
    final collection = _firestore.collection(FirestoreTaxonomyService.taxonomyCategoriesCollection);

    await _logFirebaseProjectContext();
    final canSeed = await _logAuthContextAndEnsureUser();

    final allItems = <String, FirestoreTaxonomySeedItem>{
      for (final item in firestoreTaxonomySeedData) item.documentId: item,
    };
    final catalogTotal = allItems.length;

    developer.log(
      'Taxonomy master sync started version=$taxonomySeedVersion trigger=$trigger total=$catalogTotal force=$force',
      name: 'TaxonomySeeder',
    );

    if (_isTaxonomyMasterSyncRunning) {
      developer.log(
        'Taxonomy master sync skipped version=$taxonomySeedVersion reason=already_running trigger=$trigger',
        name: 'TaxonomySeeder',
      );
      return FirestoreTaxonomySeedReport(
        prepared: catalogTotal,
        catalogTotal: catalogTotal,
        created: 0,
        skipped: catalogTotal,
        updated: 0,
        pending: 0,
        message: 'Taxonomy master sync is already running.',
      );
    }

    if (!canSeed) {
      return FirestoreTaxonomySeedReport(
        prepared: catalogTotal,
        catalogTotal: catalogTotal,
        created: 0,
        skipped: 0,
        updated: 0,
        message: 'Cannot seed Firestore taxonomies: no Firebase authenticated user.',
      );
    }

    if (!await _hasInternetConnection()) {
      final offlineMessage = 'No stable internet connection. Taxonomy upload paused before start.';
      onProgress?.call(
        FirestoreTaxonomySeedProgress(
          operation: 'taxonomy_upload',
          phase: 'paused_due_to_network',
          catalogTotal: catalogTotal,
          total: catalogTotal,
          processed: 0,
          created: 0,
          skipped: 0,
          updated: 0,
          failed: 0,
          pending: catalogTotal,
          message: offlineMessage,
          errorCode: 'unavailable',
          errorMessage: offlineMessage,
        ),
      );
      return FirestoreTaxonomySeedReport(
        prepared: catalogTotal,
        catalogTotal: catalogTotal,
        created: 0,
        skipped: 0,
        updated: 0,
        failed: 0,
        pending: catalogTotal,
        pausedDueToNetwork: true,
        message: offlineMessage,
      );
    }

    _isTaxonomyMasterSyncRunning = true;
    try {
      final checkpoint = force ? null : await _loadCheckpoint();
      final resumedFromCheckpoint = checkpoint != null && checkpoint.version == taxonomySeedVersion;

      final successfulIds = <String>{...?checkpoint?.successfulIds};
      final skippedIds = <String>{...?checkpoint?.skippedIds};
      final failedIds = <String>{...?checkpoint?.failedIds};

      final pendingFromCheckpoint = <String>{
        ...allItems.keys,
      }
        ..removeAll(successfulIds)
        ..removeAll(skippedIds);

      final resumeIds = pendingFromCheckpoint.toList(growable: false);
      final candidateIds =
          (resumedFromCheckpoint && resumeIds.isNotEmpty && !force) ? resumeIds : allItems.keys.toList(growable: false);

      final prepared = candidateIds.length;

      if (resumedFromCheckpoint && prepared > 0) {
        developer.log('Taxonomy master sync resumed pending=$prepared', name: 'TaxonomySeeder');
      }

      final alreadyApplied = await _isSeedVersionApplied(collection);
      if (alreadyApplied && !force && prepared == catalogTotal) {
        developer.log(
          'Taxonomy master sync skipped version=$taxonomySeedVersion reason=already_applied trigger=$trigger',
          name: 'TaxonomySeeder',
        );
        onProgress?.call(
          FirestoreTaxonomySeedProgress(
            operation: 'taxonomy_upload',
            phase: 'completed',
            catalogTotal: catalogTotal,
            total: catalogTotal,
            processed: catalogTotal,
            created: 0,
            skipped: catalogTotal,
            updated: 0,
            failed: 0,
            pending: 0,
            message: 'Taxonomy seed version already applied.',
          ),
        );
        return FirestoreTaxonomySeedReport(
          prepared: catalogTotal,
          catalogTotal: catalogTotal,
          created: 0,
          skipped: catalogTotal,
          updated: 0,
          failed: 0,
          pending: 0,
          resumedFromCheckpoint: resumedFromCheckpoint,
          message: 'Taxonomy seed version already applied: $taxonomySeedVersion',
        );
      }

      int created = 0;
      int skipped = 0;
      int updated = 0;
      int failed = 0;
      int processed = 0;
      final failures = <FirestoreTaxonomySeedFailure>[];
      int milestoneIndex = 0;

      void emitProgress({
        required String phase,
        String? currentItemId,
        String? currentGroup,
        String? message,
        String? errorCode,
        String? errorMessage,
      }) {
        final pending = prepared - (created + skipped + updated);
        final currentProgress = FirestoreTaxonomySeedProgress(
          operation: 'taxonomy_upload',
          phase: phase,
          catalogTotal: catalogTotal,
          total: prepared,
          processed: processed,
          created: created,
          skipped: skipped,
          updated: updated,
          failed: failed,
          pending: pending < 0 ? 0 : pending,
          currentItemId: currentItemId,
          currentGroup: currentGroup,
          message: message,
          errorCode: errorCode,
          errorMessage: errorMessage,
          failures: List<FirestoreTaxonomySeedFailure>.unmodifiable(failures),
        );

        final percent = (currentProgress.percent * 100).round();
        while (milestoneIndex < _progressMilestones.length && percent >= _progressMilestones[milestoneIndex]) {
          developer.log('taxonomy_upload progress ${_progressMilestones[milestoneIndex]}%', name: 'TaxonomySeeder');
          milestoneIndex += 1;
        }

        onProgress?.call(currentProgress);
      }

      Future<void> persistCheckpoint({String? lastAttemptedId}) async {
        final cp = _TaxonomySeedCheckpoint(
          version: taxonomySeedVersion,
          catalogTotal: catalogTotal,
          allIds: allItems.keys.toList(growable: false),
          successfulIds: successfulIds.toList(growable: false),
          skippedIds: skippedIds.toList(growable: false),
          failedIds: failedIds.toList(growable: false),
          lastAttemptedId: lastAttemptedId,
          updatedAt: DateTime.now(),
        );
        await _saveCheckpoint(cp);
      }

      emitProgress(
        phase: resumedFromCheckpoint ? 'retrying' : 'preparing',
        message: resumedFromCheckpoint
            ? 'Resuming taxonomy upload from saved checkpoint.'
            : 'Preparing taxonomy upload to Firestore.',
      );

      for (var start = 0; start < candidateIds.length; start += _batchSize) {
        final end = (start + _batchSize) > candidateIds.length ? candidateIds.length : (start + _batchSize);
        final chunkIds = candidateIds.sublist(start, end);

        if (!await _hasInternetConnection()) {
          final message = 'Network unavailable, checkpoint saved. Resume when internet returns.';
          failedIds.addAll(chunkIds);
          failed += chunkIds.length;
          await persistCheckpoint(lastAttemptedId: chunkIds.first);
          emitProgress(
            phase: 'paused_due_to_network',
            currentItemId: chunkIds.first,
            message: message,
            errorCode: 'unavailable',
            errorMessage: message,
          );
          return FirestoreTaxonomySeedReport(
            prepared: prepared,
            catalogTotal: catalogTotal,
            created: created,
            skipped: skipped,
            updated: updated,
            failed: failed,
            pending: prepared - (created + skipped + updated),
            pausedDueToNetwork: true,
            resumedFromCheckpoint: resumedFromCheckpoint,
            failures: failures,
            message: message,
          );
        }

        final batch = _firestore.batch();
        final writes = <({FirestoreTaxonomySeedItem item, bool existed})>[];

        for (final id in chunkIds) {
          final item = allItems[id];
          if (item == null) {
            continue;
          }

          emitProgress(
            phase: 'uploading',
            currentItemId: item.documentId,
            currentGroup: item.group,
            message: 'Uploading ${item.group}/${item.documentId}',
          );

          final docRef = collection.doc(item.documentId);
          try {
            final existing = await docRef.get();
            if (existing.exists && !force) {
              skipped += 1;
              processed += 1;
              skippedIds.add(item.documentId);
              successfulIds.remove(item.documentId);
              failedIds.remove(item.documentId);
              await persistCheckpoint(lastAttemptedId: item.documentId);
              continue;
            }

            final payload = <String, dynamic>{
              'id': item.id,
              'group': item.group,
              'name': item.nameAr,
              'nameAr': item.nameAr,
              'nameEn': item.nameEn,
              'slug': item.slug,
              'parentId': item.parentId,
              'journeyType': item.journeyType,
              'iconUrl': null,
              'imageUrl': null,
              'sortOrder': item.sortOrder,
              'isActive': item.isActive,
              'metadata': <String, dynamic>{
                ...item.metadata,
                'seedVersion': taxonomySeedVersion,
              },
              'createdAt': existing.exists
                  ? (existing.data()?['createdAt'] ?? FieldValue.serverTimestamp())
                  : FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            };

            batch.set(docRef, payload, SetOptions(merge: true));
            writes.add((item: item, existed: existing.exists));
          } on FirebaseException catch (e) {
            if (e.code == 'permission-denied') {
              _logPermissionDeniedHint();
            }

            final isNetwork = _isNetworkError(e);
            final failure = FirestoreTaxonomySeedFailure(
              documentId: item.documentId,
              group: item.group,
              errorCode: e.code,
              message: e.message ?? e.toString(),
            );
            failures.add(failure);
            failedIds.add(item.documentId);
            failed += 1;

            if (isNetwork) {
              await persistCheckpoint(lastAttemptedId: item.documentId);
              final message = 'network unavailable, checkpoint saved';
              developer.log(message, name: 'TaxonomySeeder');
              emitProgress(
                phase: 'paused_due_to_network',
                currentItemId: item.documentId,
                currentGroup: item.group,
                message: message,
                errorCode: e.code,
                errorMessage: failure.message,
              );
              return FirestoreTaxonomySeedReport(
                prepared: prepared,
                catalogTotal: catalogTotal,
                created: created,
                skipped: skipped,
                updated: updated,
                failed: failed,
                pending: prepared - (created + skipped + updated),
                pausedDueToNetwork: true,
                resumedFromCheckpoint: resumedFromCheckpoint,
                failures: failures,
                message: message,
              );
            }
          } on SocketException catch (e) {
            final failure = FirestoreTaxonomySeedFailure(
              documentId: item.documentId,
              group: item.group,
              errorCode: 'unavailable',
              message: e.toString(),
            );
            failures.add(failure);
            failedIds.add(item.documentId);
            failed += 1;
            await persistCheckpoint(lastAttemptedId: item.documentId);

            final message = 'network unavailable, checkpoint saved';
            developer.log(message, name: 'TaxonomySeeder');
            emitProgress(
              phase: 'paused_due_to_network',
              currentItemId: item.documentId,
              currentGroup: item.group,
              message: message,
              errorCode: 'unavailable',
              errorMessage: failure.message,
            );
            return FirestoreTaxonomySeedReport(
              prepared: prepared,
              catalogTotal: catalogTotal,
              created: created,
              skipped: skipped,
              updated: updated,
              failed: failed,
              pending: prepared - (created + skipped + updated),
              pausedDueToNetwork: true,
              resumedFromCheckpoint: resumedFromCheckpoint,
              failures: failures,
              message: message,
            );
          } catch (e) {
            final failure = FirestoreTaxonomySeedFailure(
              documentId: item.documentId,
              group: item.group,
              errorCode: 'unknown',
              message: e.toString(),
            );
            failures.add(failure);
            failedIds.add(item.documentId);
            failed += 1;
          }
        }

        if (writes.isNotEmpty) {
          try {
            await batch.commit();
            for (final write in writes) {
              if (write.existed) {
                updated += 1;
              } else {
                created += 1;
              }
              processed += 1;
              successfulIds.add(write.item.documentId);
              skippedIds.remove(write.item.documentId);
              failedIds.remove(write.item.documentId);
            }
          } on FirebaseException catch (e) {
            final isNetwork = _isNetworkError(e);
            for (final write in writes) {
              final failure = FirestoreTaxonomySeedFailure(
                documentId: write.item.documentId,
                group: write.item.group,
                errorCode: e.code,
                message: e.message ?? e.toString(),
              );
              failures.add(failure);
              failedIds.add(write.item.documentId);
              failed += 1;
            }

            await persistCheckpoint(lastAttemptedId: writes.last.item.documentId);

            final message = isNetwork ? 'network unavailable, checkpoint saved' : 'taxonomy batch commit failed';
            if (isNetwork) {
              developer.log(message, name: 'TaxonomySeeder');
              emitProgress(
                phase: 'paused_due_to_network',
                currentItemId: writes.last.item.documentId,
                currentGroup: writes.last.item.group,
                message: message,
                errorCode: e.code,
                errorMessage: e.message,
              );
              return FirestoreTaxonomySeedReport(
                prepared: prepared,
                catalogTotal: catalogTotal,
                created: created,
                skipped: skipped,
                updated: updated,
                failed: failed,
                pending: prepared - (created + skipped + updated),
                pausedDueToNetwork: true,
                resumedFromCheckpoint: resumedFromCheckpoint,
                failures: failures,
                message: message,
              );
            }
          }
        }

        await persistCheckpoint(lastAttemptedId: chunkIds.isEmpty ? null : chunkIds.last);
        emitProgress(
          phase: 'uploading',
          currentItemId: chunkIds.isEmpty ? null : chunkIds.last,
          message: 'Uploaded $processed/$prepared',
        );
      }

      final pending = prepared - (created + skipped + updated);
      final globalCompleted = successfulIds.length + skippedIds.length;

      if (pending <= 0) {
        await _markSeedVersionApplied(
          collection,
          prepared: catalogTotal,
          created: created,
          skipped: skipped,
          updated: updated,
          trigger: trigger,
          force: force,
        );
        await _clearCheckpoint();
      } else {
        await persistCheckpoint();
      }

      developer.log(
        'Taxonomy master sync result: prepared=$prepared created=$created skipped=$skipped updated=$updated failed=$failed pending=$pending',
        name: 'TaxonomySeeder',
      );
      if (pending <= 0) {
        developer.log(
          'Taxonomy master sync completed version=$taxonomySeedVersion prepared=$catalogTotal completed=$globalCompleted failed=$failed',
          name: 'TaxonomySeeder',
        );
      }

      emitProgress(
        phase: pending <= 0 ? 'completed' : 'failed',
        message:
            pending <= 0 ? 'Taxonomy upload completed successfully.' : 'Taxonomy upload completed with pending items.',
      );

      return FirestoreTaxonomySeedReport(
        prepared: prepared,
        catalogTotal: catalogTotal,
        created: created,
        skipped: skipped,
        updated: updated,
        failed: failed,
        pending: pending < 0 ? 0 : pending,
        pausedDueToNetwork: false,
        resumedFromCheckpoint: resumedFromCheckpoint,
        failures: failures,
      );
    } finally {
      _isTaxonomyMasterSyncRunning = false;
    }
  }

  Future<void> debugFirestoreTaxonomyAccess() async {
    await _logFirebaseProjectContext();

    final user = _auth.currentUser;
    final hasToken = await user?.getIdToken(false) != null;
    developer.log('debugFirestoreTaxonomyAccess user.uid=${user?.uid}', name: 'TaxonomySeeder');
    developer.log('debugFirestoreTaxonomyAccess user.email=${user?.email}', name: 'TaxonomySeeder');
    developer.log('debugFirestoreTaxonomyAccess hasIdToken=$hasToken', name: 'TaxonomySeeder');

    if (user == null) {
      developer.log('Cannot seed Firestore taxonomies: no Firebase authenticated user.', name: 'TaxonomySeeder');
      return;
    }

    final collection = _firestore.collection(FirestoreTaxonomyService.taxonomyCategoriesCollection);
    final testDocRef = collection.doc('debug_access_test');

    try {
      developer.log('Diagnostic step 1/4: read taxonomy_categories limit(1)', name: 'TaxonomySeeder');
      await collection.limit(1).get();
      developer.log('Diagnostic step 1/4 succeeded', name: 'TaxonomySeeder');

      developer.log('Diagnostic step 2/4: write taxonomy_categories/debug_access_test', name: 'TaxonomySeeder');
      await testDocRef.set(<String, dynamic>{
        'id': 'debug_access_test',
        'group': 'debug',
        'name': 'Debug Access Test',
        'nameAr': 'اختبار الوصول',
        'nameEn': 'Debug Access Test',
        'slug': 'debug_access_test',
        'parentId': null,
        'journeyType': 'general',
        'sortOrder': -1,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      developer.log('Diagnostic step 2/4 succeeded', name: 'TaxonomySeeder');

      developer.log('Diagnostic step 3/4: read back taxonomy_categories/debug_access_test', name: 'TaxonomySeeder');
      await testDocRef.get();
      developer.log('Diagnostic step 3/4 succeeded', name: 'TaxonomySeeder');

      developer.log('Diagnostic step 4/4: delete taxonomy_categories/debug_access_test', name: 'TaxonomySeeder');
      await testDocRef.delete();
      developer.log('Diagnostic step 4/4 succeeded', name: 'TaxonomySeeder');
    } on FirebaseException catch (e) {
      developer.log(
        'Firestore taxonomy diagnostic failed at step due to FirebaseException: code=${e.code}, message=${e.message}',
        name: 'TaxonomySeeder',
      );
      if (e.code == 'permission-denied') {
        _logPermissionDeniedHint();
      }
    } catch (e) {
      developer.log('Firestore taxonomy diagnostic failed: $e', name: 'TaxonomySeeder');
    }
  }
}
