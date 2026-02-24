import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/sync/data/datasources/file_id_remote_datasource.dart';

class _QueuedResponse {
  final String method;
  final String path;
  final int statusCode;
  final Map<String, dynamic> body;

  const _QueuedResponse({
    required this.method,
    required this.path,
    required this.statusCode,
    required this.body,
  });
}

class _QueueHttpClientAdapter implements HttpClientAdapter {
  final List<_QueuedResponse> _queue;
  final List<RequestOptions> capturedRequests = <RequestOptions>[];

  _QueueHttpClientAdapter(this._queue);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequests.add(options);

    if (_queue.isEmpty) {
      return ResponseBody.fromString(
        jsonEncode({'error': 'No queued response'}),
        500,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final next = _queue.removeAt(0);
    expect(options.method.toUpperCase(), next.method.toUpperCase());
    expect(options.path, next.path);

    return ResponseBody.fromString(
      jsonEncode(next.body),
      next.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileIdRemoteDataSourceImpl', () {
    test('reserveIds reads explicit ids when provided', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/database/file-ids/reserve',
          statusCode: 200,
          body: {
            'success': true,
            'ids': [1001, 1002, 1003],
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      final ids = await dataSource.reserveIds(3);

      expect(ids, [1001, 1002, 1003]);
      final payload = adapter.capturedRequests.first.data as Map<String, dynamic>;
      expect(payload['batch_size'], 3);
    });

    test('reserveBatchSnapshot reads reservation payload when status is 201', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/database/file-ids/reserve',
          statusCode: 201,
          body: {
            'success': true,
            'data': {
              'reservation': {
                'id': 55,
                'start_id': 9000,
                'end_id': 9004,
                'batch_size': 5,
                'used_count': 1,
                'remaining_count': 4,
                'next_available_id': 9001,
                'status': 'active',
              }
            }
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      final snapshot = await dataSource.reserveBatchSnapshot(5);

      expect(snapshot, isNotNull);
      expect(snapshot!.reservationId, 55);
      expect(snapshot.startId, 9000);
      expect(snapshot.endId, 9004);
      expect(snapshot.nextAvailableId, 9001);
      expect(snapshot.remainingCount, 4);
    });

    test('reserveIds builds ids from active_reservation range when ids list missing', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/database/file-ids/reserve',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'active_reservation': {
                'id': 1,
                'start_id': 2000,
                'end_id': 2002,
              }
            }
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      final ids = await dataSource.reserveIds(3);

      expect(ids, [2000, 2001, 2002]);
    });

    test('syncUsedIds sends reservation_id and used_count when reservation exists', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'GET',
          path: '/api/mobile/database/file-ids/reservations',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'active_reservation': {
                'id': 77,
                'start_id': 3000,
                'end_id': 8000,
              }
            }
          },
        ),
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/database/file-ids/sync-used',
          statusCode: 200,
          body: {
            'success': true,
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      await dataSource.syncUsedIds([3001, 3002, 3003]);

      final syncPayload = adapter.capturedRequests.last.data as Map<String, dynamic>;
      expect(syncPayload['reservation_id'], 77);
      expect(syncPayload['used_count'], 3);
      expect(syncPayload.containsKey('used_ids'), isFalse);
    });
  });
}
