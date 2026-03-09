import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/kafalat/data/datasources/sponsorships_remote_sync_datasource.dart';

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

  test('fetchSponsorships sends optional todo filters in query params', () async {
    final adapter = _QueueHttpClientAdapter([
      const _QueuedResponse(
        method: 'GET',
        path: '/api/mobile/sponsorships',
        statusCode: 200,
        body: {
          'success': true,
          'data': {
            'records': [],
            'pagination': {'current_page': 1, 'last_page': 1},
            'sync_timestamp': '2026-03-02T12:00:00Z',
          },
        },
      ),
    ]);

    final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
    dio.httpClientAdapter = adapter;

    final datasource = SponsorshipsRemoteSyncDataSource(dio);
    final result = await datasource.fetchSponsorships(
      updatedAfter: DateTime.parse('2026-03-01T00:00:00Z'),
      sponsorId: 7,
      statusId: 2,
      typeId: 1,
      identityNumber: '123456789',
      internalFileNumber: 'GZ-2026-001',
      page: 3,
      perPage: 50,
    );

    expect(result.records, isEmpty);

    final query = adapter.capturedRequests.single.queryParameters;
    expect(query['page'], 3);
    expect(query['per_page'], 50);
    expect(query['sponsor_id'], 7);
    expect(query['status_id'], 2);
    expect(query['type_id'], 1);
    expect(query['identity_number'], '123456789');
    expect(query['internal_file_number'], 'GZ-2026-001');
    expect(query['updated_after'], isNotEmpty);
  });
}
