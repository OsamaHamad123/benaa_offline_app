import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/associations/data/datasources/associations_remote_sync_datasource.dart';

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

  group('AssociationsRemoteSyncDataSource', () {
    test('fetchSponsors sends ids as comma-separated query', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'GET',
          path: '/api/mobile/associations/sponsors',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'records': [],
              'pagination': {'current_page': 1, 'last_page': 1},
            },
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://disabled-api.example.com'));
      dio.httpClientAdapter = adapter;

      final datasource = AssociationsRemoteSyncDataSource(dio);
      await datasource.fetchSponsors(ids: const [1, 2, 3], page: 1, perPage: 100);

      final query = adapter.capturedRequests.single.queryParameters;
      expect(query['ids'], '1,2,3');
    });

    test('fetchEmployees sends ids as comma-separated query', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'GET',
          path: '/api/mobile/associations/employees',
          statusCode: 200,
          body: {
            'success': true,
            'data': {
              'records': [],
              'pagination': {'current_page': 1, 'last_page': 1},
            },
          },
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://disabled-api.example.com'));
      dio.httpClientAdapter = adapter;

      final datasource = AssociationsRemoteSyncDataSource(dio);
      await datasource.fetchEmployees(ids: const [10, 20], page: 1, perPage: 100);

      final query = adapter.capturedRequests.single.queryParameters;
      expect(query['ids'], '10,20');
    });
  });
}
