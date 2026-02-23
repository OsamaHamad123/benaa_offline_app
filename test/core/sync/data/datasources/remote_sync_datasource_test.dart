import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/sync/data/datasources/remote_sync_datasource.dart';
import 'package:benaa_offline_app/core/sync/models/sync_models.dart';

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

  group('RemoteSyncDataSource', () {
    test('pullVisitChanges normalizes paginated mobile payload', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'GET',
          path: '/api/mobile/visits',
          statusCode: 200,
          body: {
            'data': {
              'records': [
                {'id': 10, 'notes': 'v1'},
                {'id': 11, 'notes': 'v2'},
              ],
              'pagination': {
                'current_page': 1,
                'last_page': 2,
                'per_page': 2,
                'total': 4,
              },
              'sync_timestamp': '2026-02-22T12:00:00.000Z',
            }
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = RemoteSyncDataSource(dio);
      final result = await dataSource.pullVisitChanges(limit: 2);

      expect(result.data.length, 2);
      expect(result.pagination.total, 4);
      expect(result.pagination.page, 1);
      expect(result.pagination.perPage, 2);
      expect(result.pagination.hasMore, isTrue);
      expect(result.syncTimestamp.toIso8601String(), '2026-02-22T12:00:00.000Z');

      final query = adapter.capturedRequests.first.queryParameters;
      expect(query['per_page'], 2);
      expect(query['page'], 1);
    });

    test('pushVisitChanges normalizes created and updated IDs into success rows', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'POST',
          path: '/api/mobile/visits/batch',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'created': [200],
              'updated': [201],
            }
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final dataSource = RemoteSyncDataSource(dio);
      final changes = <SyncChange>[
        SyncChange(
          clientId: 'c-1',
          action: 'create',
          data: {'id': 200, 'notes': 'new'},
          timestamp: DateTime.parse('2026-02-22T12:00:00.000Z'),
        ),
        SyncChange(
          clientId: 'c-2',
          action: 'update',
          data: {'id': 201, 'notes': 'updated'},
          timestamp: DateTime.parse('2026-02-22T12:00:00.000Z'),
        ),
      ];

      final result = await dataSource.pushVisitChanges(changes);

      expect(result.errors, isEmpty);
      expect(result.conflicts, isEmpty);
      expect(result.success.length, 2);
      expect(result.success.map((s) => s.clientId), containsAll(<String>['c-1', 'c-2']));
      expect(result.success.map((s) => s.serverId), containsAll(<int>[200, 201]));

      final payload = adapter.capturedRequests.first.data as Map<String, dynamic>;
      expect(payload.containsKey('changes'), isTrue);
      expect(payload.containsKey('records'), isTrue);
    });
  });
}
