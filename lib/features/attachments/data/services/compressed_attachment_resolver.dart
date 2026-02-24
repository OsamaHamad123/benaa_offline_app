import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/attachment.dart';

class CompressedAttachmentReference {
  final String archiveUrl;
  final String entryPath;

  const CompressedAttachmentReference({
    required this.archiveUrl,
    required this.entryPath,
  });
}

class CompressedAttachmentResolver {
  static const int _maxEntryUncompressedBytes = 25 * 1024 * 1024;
  static const int _maxArchiveEntries = 5000;
  static const int _maxArchiveBytes = 120 * 1024 * 1024;
  static const int _maxExtractedFiles = 200;
  static const Duration _maxExtractedAge = Duration(days: 7);

  Future<File?> resolve(Attachment attachment) async {
    final localFile = File(attachment.filePath);
    if (localFile.existsSync()) {
      return localFile;
    }

    final remoteDirectUrl = _resolveDirectRemoteUrl(attachment);
    if (remoteDirectUrl != null) {
      final remoteFile = await DefaultCacheManager().getSingleFile(
        remoteDirectUrl,
        key: 'attachment-file:${attachment.id}:$remoteDirectUrl',
      );
      if (remoteFile.existsSync()) {
        return remoteFile;
      }
    }

    final reference = parseReference(attachment);
    if (reference == null) {
      final zipArchiveUrl = _extractStandaloneZipUrl(attachment);
      if (zipArchiveUrl == null) {
        return null;
      }
      return _resolveFromStandaloneArchive(attachment, zipArchiveUrl);
    }

    final extractionRoot = await _ensureExtractionRoot();
    await _cleanupOldExtractedFiles(extractionRoot);

    final cacheKey = _hash('${reference.archiveUrl}::${reference.entryPath}');
    final outputFileName = _buildOutputFileName(
      attachment.fileName,
      reference.entryPath,
    );
    final extractedFile = File(
      p.join(extractionRoot.path, '${cacheKey}_$outputFileName'),
    );

    if (extractedFile.existsSync()) {
      return extractedFile;
    }

    final archiveFile = await DefaultCacheManager().getSingleFile(
      reference.archiveUrl,
      key: 'compressed-attachment:${attachment.id}:${reference.archiveUrl}',
    );

    final archiveLength = archiveFile.lengthSync();
    if (archiveLength > _maxArchiveBytes) {
      throw Exception('حجم ملف الأرشيف يتجاوز الحد المسموح');
    }

    final archiveBytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(archiveBytes);

    if (archive.files.length > _maxArchiveEntries) {
      throw Exception('عدد ملفات الأرشيف كبير جداً');
    }

    final normalizedEntry = _normalizeEntryPath(reference.entryPath);
    if (normalizedEntry == null) {
      throw Exception('مسار الملف داخل الأرشيف غير صالح');
    }

    ArchiveFile? target;
    for (final file in archive.files) {
      if (!file.isFile) {
        continue;
      }
      final currentName = _normalizeEntryPath(file.name);
      if (currentName == normalizedEntry) {
        target = file;
        break;
      }
    }

    if (target == null) {
      throw Exception('لم يتم العثور على الملف داخل الأرشيف');
    }

    if (target.size > _maxEntryUncompressedBytes) {
      throw Exception('حجم الملف داخل الأرشيف يتجاوز الحد المسموح');
    }

    final content = target.content;
    if (content is! List<int>) {
      throw Exception('تعذر استخراج الملف المضغوط');
    }

    await extractedFile.parent.create(recursive: true);
    await extractedFile.writeAsBytes(content, flush: true);

    return extractedFile;
  }

  Future<File?> _resolveFromStandaloneArchive(
    Attachment attachment,
    String archiveUrl,
  ) async {
    final extractionRoot = await _ensureExtractionRoot();
    await _cleanupOldExtractedFiles(extractionRoot);

    final cacheKey = _hash('${archiveUrl}::${attachment.fileName}');
    final outputFileName = _buildOutputFileName(attachment.fileName, attachment.fileName);
    final extractedFile = File(
      p.join(extractionRoot.path, '${cacheKey}_$outputFileName'),
    );

    if (extractedFile.existsSync()) {
      return extractedFile;
    }

    final archiveFile = await DefaultCacheManager().getSingleFile(
      archiveUrl,
      key: 'compressed-attachment:${attachment.id}:$archiveUrl',
    );

    final archiveLength = archiveFile.lengthSync();
    if (archiveLength > _maxArchiveBytes) {
      throw Exception('حجم ملف الأرشيف يتجاوز الحد المسموح');
    }

    final archiveBytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(archiveBytes);

    if (archive.files.length > _maxArchiveEntries) {
      throw Exception('عدد ملفات الأرشيف كبير جداً');
    }

    final target = _findBestArchiveEntry(archive, attachment);
    if (target == null) {
      throw Exception('لم يتم العثور على ملف مطابق داخل الأرشيف');
    }

    if (target.size > _maxEntryUncompressedBytes) {
      throw Exception('حجم الملف داخل الأرشيف يتجاوز الحد المسموح');
    }

    final content = target.content;
    if (content is! List<int>) {
      throw Exception('تعذر استخراج الملف المضغوط');
    }

    await extractedFile.parent.create(recursive: true);
    await extractedFile.writeAsBytes(content, flush: true);
    return extractedFile;
  }

  ArchiveFile? _findBestArchiveEntry(Archive archive, Attachment attachment) {
    final fileEntries = archive.files.where((file) => file.isFile).toList(growable: false);
    if (fileEntries.isEmpty) {
      return null;
    }

    final expectedName = attachment.fileName.trim().toLowerCase();
    if (expectedName.isNotEmpty) {
      for (final file in fileEntries) {
        final base = p.basename(file.name).trim().toLowerCase();
        if (base == expectedName) {
          return file;
        }
      }

      for (final file in fileEntries) {
        final base = p.basename(file.name).trim().toLowerCase();
        if (base.contains(expectedName) || expectedName.contains(base)) {
          return file;
        }
      }
    }

    return null;
  }

  static bool isCompressedAttachment(Attachment attachment) {
    return parseReference(attachment) != null;
  }

  static CompressedAttachmentReference? parseReference(Attachment attachment) {
    final serverUrlRef = _parseReferenceString(attachment.serverUrl);
    if (serverUrlRef != null) {
      return serverUrlRef;
    }

    final pathRef = _parseReferenceString(attachment.filePath);
    if (pathRef != null) {
      return pathRef;
    }

    return null;
  }

  static CompressedAttachmentReference? _parseReferenceString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final value = raw.trim();

    final jsonRef = _parseReferenceJson(value);
    if (jsonRef != null) {
      return jsonRef;
    }

    final zipBangIndex = value.toLowerCase().indexOf('.zip!');
    if (zipBangIndex != -1) {
      final archiveUrl = _normalizeArchiveUrl(value.substring(0, zipBangIndex + 4));
      final entryPath = value.substring(zipBangIndex + 5);
      if (archiveUrl != null && entryPath.isNotEmpty) {
        return CompressedAttachmentReference(
          archiveUrl: archiveUrl,
          entryPath: entryPath,
        );
      }
    }

    final uri = Uri.tryParse(value);
    if (uri == null) {
      return null;
    }

    if (uri.hasScheme && uri.scheme != 'http' && uri.scheme != 'https' && uri.scheme != 'file') {
      return null;
    }

    final entryPath = uri.queryParameters['entry'] ??
        uri.queryParameters['path'] ??
        uri.queryParameters['file'] ??
        _fragmentEntry(uri.fragment);

    final archiveFromQuery = uri.queryParameters['archive'] ??
        uri.queryParameters['archive_url'] ??
        uri.queryParameters['zip'] ??
        uri.queryParameters['zip_url'];

    final rawPath = uri.path.toLowerCase();
    final hasZipInPath = rawPath.endsWith('.zip');
    final hasArchiveInQuery = archiveFromQuery != null && archiveFromQuery.trim().toLowerCase().contains('.zip');

    if (!hasZipInPath && !hasArchiveInQuery) {
      return null;
    }

    if (entryPath == null || entryPath.trim().isEmpty) {
      return null;
    }

    final archiveUri =
        hasArchiveInQuery ? _normalizeArchiveUrl(archiveFromQuery) : _normalizeArchiveUrl(uri.replace().toString());
    if (archiveUri == null) {
      return null;
    }

    return CompressedAttachmentReference(
      archiveUrl: archiveUri,
      entryPath: entryPath,
    );
  }

  static CompressedAttachmentReference? _parseReferenceJson(String raw) {
    if (!raw.startsWith('{') || !raw.endsWith('}')) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final archive = decoded['archive_url'] ?? decoded['archive'] ?? decoded['zip_url'] ?? decoded['zip'];
      final entry = decoded['entry_path'] ?? decoded['entry'] ?? decoded['path'] ?? decoded['file'];
      final archiveUrl = _normalizeArchiveUrl(archive?.toString());
      final entryPath = entry?.toString().trim();

      if (archiveUrl == null || entryPath == null || entryPath.isEmpty) {
        return null;
      }

      return CompressedAttachmentReference(
        archiveUrl: archiveUrl,
        entryPath: entryPath,
      );
    } catch (_) {
      return null;
    }
  }

  static String? _fragmentEntry(String fragment) {
    if (fragment.isEmpty) {
      return null;
    }

    if (!fragment.contains('=')) {
      return fragment;
    }

    final pairs = fragment.split('&');
    for (final pair in pairs) {
      final parts = pair.split('=');
      if (parts.length != 2) {
        continue;
      }
      if (parts[0] == 'entry' || parts[0] == 'path' || parts[0] == 'file') {
        return Uri.decodeComponent(parts[1]);
      }
    }

    return null;
  }

  String _buildOutputFileName(String attachmentName, String entryPath) {
    final safeOriginal = _sanitizeFileName(attachmentName);
    if (safeOriginal.isNotEmpty) {
      return safeOriginal;
    }

    final fromEntry = p.basename(entryPath);
    return _sanitizeFileName(fromEntry);
  }

  Future<Directory> _ensureExtractionRoot() async {
    final tempDir = await getTemporaryDirectory();
    final dir = Directory(p.join(tempDir.path, 'attachment_archive_cache'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> _cleanupOldExtractedFiles(Directory rootDir) async {
    if (!rootDir.existsSync()) {
      return;
    }

    final entities = await rootDir.list().where((e) => e is File).cast<File>().toList();
    entities.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );

    final now = DateTime.now();

    for (var i = 0; i < entities.length; i++) {
      final file = entities[i];
      final age = now.difference(file.lastModifiedSync());
      final shouldDeleteByAge = age > _maxExtractedAge;
      final shouldDeleteByCount = i >= _maxExtractedFiles;
      if (shouldDeleteByAge || shouldDeleteByCount) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    }
  }

  static String? _normalizeEntryPath(String rawPath) {
    final normalized = rawPath.replaceAll('\\', '/').trim();
    if (normalized.isEmpty || normalized.startsWith('/')) {
      return null;
    }

    final segments = normalized.split('/').where((segment) => segment.isNotEmpty).toList();

    if (segments.any((segment) => segment == '..')) {
      return null;
    }

    return segments.join('/');
  }

  String _sanitizeFileName(String value) {
    final sanitized = value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (sanitized.isEmpty) {
      return 'attachment.bin';
    }
    return sanitized;
  }

  String _hash(String value) {
    return sha1.convert(utf8.encode(value)).toString();
  }

  static String? _normalizeArchiveUrl(String? raw) {
    if (raw == null) {
      return null;
    }
    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiConfig.defaultBaseUrl}$value';
    }

    if (value.startsWith('api/') || value.startsWith('storage/') || value.startsWith('uploads/')) {
      return '${ApiConfig.defaultBaseUrl}/$value';
    }

    return value;
  }

  String? _resolveDirectRemoteUrl(Attachment attachment) {
    for (final raw in [attachment.serverUrl, attachment.filePath]) {
      final normalized = _normalizeRemoteUrl(raw);
      if (normalized != null && !_looksLikeZipReference(normalized)) {
        return normalized;
      }
    }
    return null;
  }

  String? _normalizeRemoteUrl(String? raw) {
    if (raw == null) {
      return null;
    }

    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiConfig.defaultBaseUrl}$value';
    }

    if (value.startsWith('api/') || value.startsWith('storage/') || value.startsWith('uploads/')) {
      return '${ApiConfig.defaultBaseUrl}/$value';
    }

    return null;
  }

  bool _looksLikeZipReference(String value) {
    final lower = value.toLowerCase();
    return lower.contains('.zip!') || lower.contains('.zip?') || lower.endsWith('.zip');
  }

  String? _extractStandaloneZipUrl(Attachment attachment) {
    for (final raw in [attachment.serverUrl, attachment.filePath]) {
      final jsonArchive = _extractArchiveUrlFromJsonReference(raw);
      if (jsonArchive != null) {
        final lowerJson = jsonArchive.toLowerCase();
        if ((lowerJson.endsWith('.zip') || lowerJson.contains('.zip?')) && !lowerJson.contains('.zip!')) {
          return jsonArchive;
        }
      }

      final normalized = _normalizeRemoteUrl(raw) ?? _normalizeArchiveUrl(raw);
      if (normalized == null) {
        continue;
      }

      final lower = normalized.toLowerCase();
      if ((lower.endsWith('.zip') || lower.contains('.zip?')) && !lower.contains('.zip!')) {
        return normalized;
      }
    }
    return null;
  }

  String? _extractArchiveUrlFromJsonReference(String? raw) {
    if (raw == null) {
      return null;
    }

    final value = raw.trim();
    if (!value.startsWith('{') || !value.endsWith('}')) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final archive = decoded['archive_url'] ?? decoded['archive'] ?? decoded['zip_url'] ?? decoded['zip'];
      return _normalizeArchiveUrl(archive?.toString());
    } catch (_) {
      return null;
    }
  }
}
