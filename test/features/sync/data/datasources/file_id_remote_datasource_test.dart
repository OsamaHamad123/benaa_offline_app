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
    test('reserveIds uses /codes/request-codes when available', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/codes/request-codes',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'codes': ['001001', '001002', '001003'],
            },
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      final ids = await dataSource.reserveIds(3);

      expect(ids, [1001, 1002, 1003]);
      final payload = adapter.capturedRequests.first.data as Map<String, dynamic>;
      expect(payload['count'], 3);
    });

    test('reserveIds falls back to /file-ids/reserve when codes endpoint fails', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/codes/request-codes',
          statusCode: 404,
          body: {'success': false},
        ),
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/database/file-ids/reserve',
          statusCode: 200,
          body: {
            'success': true,
            'ids': [9000, 9001, 9002],
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      final ids = await dataSource.reserveIds(3);

      expect(ids, [9000, 9001, 9002]);
    });

    test('reserveBatchSnapshot builds synthetic snapshot from codes list', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/codes/request-codes',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'codes': ['002000', '002001', '002002'],
            }
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      final snapshot = await dataSource.reserveBatchSnapshot(3);

      expect(snapshot, isNotNull);
      expect(snapshot!.startId, 2000);
      expect(snapshot.endId, 2002);
      expect(snapshot.batchSize, 3);
      expect(snapshot.remainingCount, 3);
    });

    test('syncUsedIds uses /codes/confirm-usage with explicit codes', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/codes/confirm-usage',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'confirmed': ['003001', '003002', '003003']
            },
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);
      await dataSource.syncUsedIds([3001, 3002, 3003]);

      final syncPayload = adapter.capturedRequests.last.data as Map<String, dynamic>;
      expect(syncPayload['codes'], isA<List>());
      final codes = (syncPayload['codes'] as List).cast<Map<String, dynamic>>();
      expect(codes.map((e) => e['code']).toList(), ['003001', '003002', '003003']);
    });

    test('syncUsedIds falls back to /file-ids/sync-used when confirm-usage fails', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/codes/confirm-usage',
          statusCode: 404,
          body: {'success': false},
        ),
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
    });

    test('requestCodes rejects invalid count locally before network call', () async {
      final adapter = _QueueHttpClientAdapter([]);
      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = FileIdRemoteDataSourceImpl(dio);

      await expectLater(
        () => dataSource.requestCodes(0),
        throwsA(
          isA<CodesApiException>().having((e) => e.errorCode, 'errorCode', 'invalid_request_count'),
        ),
      );

      expect(adapter.capturedRequests, isEmpty);
    });
  });
}
