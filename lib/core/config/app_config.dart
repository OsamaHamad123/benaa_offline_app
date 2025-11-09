import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig {
  final String apiBaseUrl;
  final int syncBatchSize;
  final List<int> retryBackoffSeconds;
  final int attachmentChunkSize;
  final int searchTimeout;
  final String civilRegistryManifestPath;

  const AppConfig({
    required this.apiBaseUrl,
    this.syncBatchSize = 200,
    this.retryBackoffSeconds = const [1, 3, 10],
    this.attachmentChunkSize = 512 * 1024, // 512KB
    this.searchTimeout = 800,
    this.civilRegistryManifestPath = 'assets/data/civil_registry/manifest.json',
  });

  static Future<AppConfig> load() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final configFile = File('${docDir.path}/env.json');

      Map<String, dynamic> json;
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        json = jsonDecode(content);
      } else {
        // Load default from assets
        final content = await rootBundle.loadString('assets/env.example.json');
        json = jsonDecode(content);
      }

      return AppConfig(
        apiBaseUrl: json['API_BASE_URL'] ?? 'http://localhost:3000/api',
        syncBatchSize: json['SYNC_BATCH_SIZE'] ?? 200,
        attachmentChunkSize: json['ATTACHMENT_CHUNK_SIZE'] ?? 512 * 1024,
      );
    } catch (e) {
      // Fallback to defaults
      return const AppConfig(apiBaseUrl: 'http://localhost:3000/api');
    }
  }

  Map<String, dynamic> toJson() => {
    'API_BASE_URL': apiBaseUrl,
    'SYNC_BATCH_SIZE': syncBatchSize,
    'ATTACHMENT_CHUNK_SIZE': attachmentChunkSize,
  };
}
