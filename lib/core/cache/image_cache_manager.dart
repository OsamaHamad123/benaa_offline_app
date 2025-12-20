import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'cache_manager.dart';

/// 🖼️ Image Cache Manager
///
/// إدارة ذكية للصور مع thumbnails والضغط

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  // Memory cache للصور الصغيرة
  final CacheManager<String, Uint8List> _memoryCache = CacheManager(
    maxSize: 50,
    ttl: const Duration(minutes: 30),
  );

  // Memory cache للـ thumbnails
  final CacheManager<String, Uint8List> _thumbnailCache = CacheManager(
    maxSize: 100,
    ttl: const Duration(hours: 1),
  );

  Directory? _cacheDir;
  Directory? _thumbnailDir;

  /// تهيئة الـ cache
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory(path.join(appDir.path, 'image_cache'));
    _thumbnailDir = Directory(path.join(appDir.path, 'thumbnails'));

    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    if (!await _thumbnailDir!.exists()) {
      await _thumbnailDir!.create(recursive: true);
    }
  }

  /// توليد مفتاح الـ cache من المسار
  String _getCacheKey(String imagePath) {
    return md5.convert(utf8.encode(imagePath)).toString();
  }

  /// الحصول على صورة مصغرة
  Future<Uint8List?> getThumbnail(
    String imagePath, {
    int width = 150,
    int height = 150,
    int quality = 80,
  }) async {
    final cacheKey = '${_getCacheKey(imagePath)}_${width}x$height';

    // التحقق من الذاكرة أولاً
    var thumbnail = _thumbnailCache.get(cacheKey);
    if (thumbnail != null) return thumbnail;

    // التحقق من القرص
    final thumbnailFile = File(path.join(_thumbnailDir!.path, '$cacheKey.jpg'));
    if (await thumbnailFile.exists()) {
      thumbnail = await thumbnailFile.readAsBytes();
      _thumbnailCache.put(cacheKey, thumbnail);
      return thumbnail;
    }

    // إنشاء صورة مصغرة جديدة
    final file = File(imagePath);
    if (!await file.exists()) return null;

    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imagePath,
        minWidth: width,
        minHeight: height,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes != null) {
        // حفظ في القرص
        await thumbnailFile.writeAsBytes(compressedBytes);

        // حفظ في الذاكرة
        _thumbnailCache.put(cacheKey, compressedBytes);

        return compressedBytes;
      }
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
    }

    return null;
  }

  /// ضغط صورة
  Future<Uint8List?> compressImage(
    String imagePath, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final cacheKey = '${_getCacheKey(imagePath)}_q$quality';

    // التحقق من الذاكرة
    var compressed = _memoryCache.get(cacheKey);
    if (compressed != null) return compressed;

    // التحقق من القرص
    final compressedFile = File(path.join(_cacheDir!.path, '$cacheKey.jpg'));
    if (await compressedFile.exists()) {
      compressed = await compressedFile.readAsBytes();
      _memoryCache.put(cacheKey, compressed);
      return compressed;
    }

    // ضغط الصورة
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imagePath,
        quality: quality,
        minWidth: maxWidth ?? 1920,
        minHeight: maxHeight ?? 1080,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes != null) {
        // حفظ في القرص
        await compressedFile.writeAsBytes(compressedBytes);

        // حفظ في الذاكرة
        _memoryCache.put(cacheKey, compressedBytes);

        return compressedBytes;
      }
    } catch (e) {
      debugPrint('Error compressing image: $e');
    }

    return null;
  }

  /// مسح الـ cache
  Future<void> clearCache() async {
    _memoryCache.clear();
    _thumbnailCache.clear();

    if (_cacheDir != null && await _cacheDir!.exists()) {
      await _cacheDir!.delete(recursive: true);
      await _cacheDir!.create();
    }

    if (_thumbnailDir != null && await _thumbnailDir!.exists()) {
      await _thumbnailDir!.delete(recursive: true);
      await _thumbnailDir!.create();
    }
  }

  /// مسح الملفات القديمة (أكبر من 7 أيام)
  Future<void> clearOldCache({Duration maxAge = const Duration(days: 7)}) async {
    final now = DateTime.now();

    // مسح من مجلد الصور
    if (_cacheDir != null && await _cacheDir!.exists()) {
      await for (final file in _cacheDir!.list()) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          if (age > maxAge) {
            await file.delete();
          }
        }
      }
    }

    // مسح من مجلد الصور المصغرة
    if (_thumbnailDir != null && await _thumbnailDir!.exists()) {
      await for (final file in _thumbnailDir!.list()) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          if (age > maxAge) {
            await file.delete();
          }
        }
      }
    }
  }

  /// حساب حجم الـ cache
  Future<int> getCacheSize() async {
    int totalSize = 0;

    if (_cacheDir != null && await _cacheDir!.exists()) {
      await for (final file in _cacheDir!.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }

    if (_thumbnailDir != null && await _thumbnailDir!.exists()) {
      await for (final file in _thumbnailDir!.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }

    return totalSize;
  }

  /// الحصول على الإحصائيات
  Future<ImageCacheStats> getStats() async {
    final size = await getCacheSize();
    return ImageCacheStats(
      memoryCacheSize: _memoryCache.stats.size,
      thumbnailCacheSize: _thumbnailCache.stats.size,
      diskCacheSizeBytes: size,
      diskCacheSizeMB: (size / (1024 * 1024)).toStringAsFixed(2),
    );
  }

  /// تحرير الموارد
  void dispose() {
    _memoryCache.clear();
    _thumbnailCache.clear();
  }
}

/// إحصائيات Image Cache
class ImageCacheStats {
  final int memoryCacheSize;
  final int thumbnailCacheSize;
  final int diskCacheSizeBytes;
  final String diskCacheSizeMB;

  ImageCacheStats({
    required this.memoryCacheSize,
    required this.thumbnailCacheSize,
    required this.diskCacheSizeBytes,
    required this.diskCacheSizeMB,
  });

  @override
  String toString() {
    return 'ImageCacheStats(memory: $memoryCacheSize, thumbnails: $thumbnailCacheSize, disk: $diskCacheSizeMB MB)';
  }
}
