import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cache/data_cache_provider.dart';

/// 🖼️ Cached Image Widget with Lazy Loading
///
/// عرض الصور مع التخزين المؤقت والتحميل الكسول

class CachedImageWidget extends ConsumerWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool useThumbnail;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImageWidget({
    required this.imagePath, super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.useThumbnail = false,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageCache = ref.watch(imageCacheProvider);

    return FutureBuilder<dynamic>(
      future: useThumbnail
          ? imageCache.getThumbnail(imagePath)
          : imageCache.compressImage(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ??
              SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return errorWidget ??
              SizedBox(
                width: width,
                height: height,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
        }

        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ??
                SizedBox(
                  width: width,
                  height: height,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
          },
        );
      },
    );
  }
}

/// 📁 Cached File Image with fallback to disk
class CachedFileImage extends StatelessWidget {
  final String filePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedFileImage({
    required this.filePath, super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);

    if (!file.existsSync()) {
      return errorWidget ??
          SizedBox(
            width: width,
            height: height,
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
    }

    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            SizedBox(
              width: width,
              height: height,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
      },
    );
  }
}
