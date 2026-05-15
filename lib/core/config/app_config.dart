import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'api_config.dart';

class AppConfig {
  // DISABLED FOR PUBLIC GITHUB VERSION:
  // Real server URL has been removed to protect sensitive infrastructure.
  // TODO: Replace with Firebase or new backend URL.
  static const String _defaultApiBaseUrl = 'https://disabled-api.example.com';

  final String apiBaseUrl;
  final int syncBatchSize;
  final List<int> retryBackoffSeconds;
  final int attachmentChunkSize;
  final int fileIdReserveBatchSize;
  final int fileIdRenewThreshold;
  final int searchTimeout;
  final String civilRegistryManifestPath;

  const AppConfig({
    required this.apiBaseUrl,
    this.syncBatchSize = 200,
    this.retryBackoffSeconds = const [1, 3, 10],
    this.attachmentChunkSize = 512 * 1024, // 512KB
    this.fileIdReserveBatchSize = ApiConfig.fileIdReserveBatchSize,
    this.fileIdRenewThreshold = ApiConfig.fileIdRenewThreshold,
    this.searchTimeout = 800,
    this.civilRegistryManifestPath = 'assets/data/civil_registry/manifest.json',
  });

  static Future<AppConfig> load() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final configFile = File('${docDir.path}/env.json');

      Map<String, dynamic>? persistedJson;
      Map<String, dynamic>? bundledJson;
      Map<String, dynamic>? exampleJson;

      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        persistedJson = jsonDecode(content) as Map<String, dynamic>;
      }

      try {
        final content = await rootBundle.loadString('assets/env.json');
        bundledJson = jsonDecode(content) as Map<String, dynamic>;
      } catch (_) {}

      try {
        final content = await rootBundle.loadString('assets/env.example.json');
        exampleJson = jsonDecode(content) as Map<String, dynamic>;
      } catch (_) {}

      final selected = persistedJson ?? bundledJson ?? exampleJson ?? const <String, dynamic>{};

      String apiBaseUrl = (selected['API_BASE_URL'] as String?)?.trim() ??
          (bundledJson?['API_BASE_URL'] as String?)?.trim() ??
          (exampleJson?['API_BASE_URL'] as String?)?.trim() ??
          _defaultApiBaseUrl;

      if (_isLocalhostUrl(apiBaseUrl)) {
        final bundledApiBaseUrl = (bundledJson?['API_BASE_URL'] as String?)?.trim();
        if (bundledApiBaseUrl != null && bundledApiBaseUrl.isNotEmpty && !_isLocalhostUrl(bundledApiBaseUrl)) {
          apiBaseUrl = bundledApiBaseUrl;
        }
      }

      return AppConfig(
        apiBaseUrl: _normalizeBaseUrl(apiBaseUrl),
        syncBatchSize: _asInt(selected['SYNC_BATCH_SIZE']) ?? 200,
        attachmentChunkSize: _asInt(selected['ATTACHMENT_CHUNK_SIZE']) ?? 512 * 1024,
        fileIdReserveBatchSize: _asInt(selected['FILE_ID_RESERVE_BATCH_SIZE']) ?? ApiConfig.fileIdReserveBatchSize,
        fileIdRenewThreshold: _asInt(selected['FILE_ID_RENEW_THRESHOLD']) ?? ApiConfig.fileIdRenewThreshold,
      );
    } catch (e) {
      // Fallback to defaults
      return const AppConfig(apiBaseUrl: _defaultApiBaseUrl);
    }
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return _defaultApiBaseUrl;
    final withoutTrailingSlashes = trimmed.replaceAll(RegExp(r'/+$'), '');

    try {
      final uri = Uri.parse(withoutTrailingSlashes);
      if (uri.path.toLowerCase() == '/api') {
        return uri.replace(path: '').toString().replaceAll(RegExp(r'/+$'), '');
      }
    } catch (_) {}

    if (withoutTrailingSlashes.toLowerCase().endsWith('/api')) {
      return withoutTrailingSlashes.substring(0, withoutTrailingSlashes.length - 4);
    }

    return withoutTrailingSlashes;
  }

  static bool _isLocalhostUrl(String value) {
    try {
      final uri = Uri.parse(value);
      final host = uri.host.toLowerCase();
      return host == 'localhost' || host == '127.0.0.1' || host == '::1';
    } catch (_) {
      return false;
    }
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Map<String, dynamic> toJson() => {
        'API_BASE_URL': apiBaseUrl,
        'SYNC_BATCH_SIZE': syncBatchSize,
        'ATTACHMENT_CHUNK_SIZE': attachmentChunkSize,
        'FILE_ID_RESERVE_BATCH_SIZE': fileIdReserveBatchSize,
        'FILE_ID_RENEW_THRESHOLD': fileIdRenewThreshold,
      };
}
