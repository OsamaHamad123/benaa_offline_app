import 'dart:convert';

import 'package:benaa_offline_app/features/taxonomies/data/datasources/taxonomy_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('TaxonomyRemoteDataSourceImpl deleteTaxonomy', () {
    test('uses provided group candidates first and avoids cross-group probing', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'DELETE',
          path: '/api/mobile/categories/governorate/1',
          statusCode: 200,
          body: {'success': true},
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final datasource = TaxonomyRemoteDataSourceImpl(dio);

      await datasource.deleteTaxonomy('governorate::1', group: 'governorate');

      expect(adapter.capturedRequests, hasLength(1));
      expect(adapter.capturedRequests.single.path, '/api/mobile/categories/governorate/1');
    });

    test('falls back across category candidates when group is null', () async {
      final adapter = _QueueHttpClientAdapter([
        const _QueuedResponse(
          method: 'DELETE',
          path: '/api/mobile/categories/governorate/1',
          statusCode: 404,
          body: {'success': false},
        ),
        const _QueuedResponse(
          method: 'DELETE',
          path: '/api/mobile/categories/governorates/1',
          statusCode: 200,
          body: {'success': true},
        ),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'https://palestine.benaadev.org'));
      dio.httpClientAdapter = adapter;

      final datasource = TaxonomyRemoteDataSourceImpl(dio);

      await datasource.deleteTaxonomy('1');

      expect(adapter.capturedRequests, hasLength(2));
      expect(adapter.capturedRequests[0].path, '/api/mobile/categories/governorate/1');
      expect(adapter.capturedRequests[1].path, '/api/mobile/categories/governorates/1');
    });
  });
}
