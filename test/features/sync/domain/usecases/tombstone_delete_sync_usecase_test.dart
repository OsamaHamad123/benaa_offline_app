import 'dart:convert';

import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/sync/domain/usecases/tombstone_delete_sync_usecase.dart';

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

  test('dispatches sponsorship tombstone to /api/mobile/sponsorships/{id}', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final adapter = _QueueHttpClientAdapter([
      const _QueuedResponse(
        method: 'DELETE',
        path: '/api/mobile/sponsorships/88',
        statusCode: 200,
        body: {'success': true},
      ),
    ]);

    final dio = Dio(BaseOptions(baseUrl: 'https://disabled-api.example.com'));
    dio.httpClientAdapter = adapter;

    final usecase = TombstoneDeleteSyncUseCase(
      syncDao: database.syncDao,
      dio: dio,
      normalizeApiEndpoint: (endpoint) => endpoint,
    );

    await database.syncDao.addTombstone(
      entityType: 'sponsorships',
      entityId: '88',
      payload: jsonEncode({'server_id': 88}),
    );

    final outcome = await usecase.execute();

    expect(outcome.deletedCount, 1);
    expect(outcome.failedCount, 0);
    expect(adapter.capturedRequests, hasLength(1));

    final pending = await database.syncDao.getPendingTombstones(entityType: 'sponsorships');
    expect(pending, isEmpty);

    await database.close();
  });
}
