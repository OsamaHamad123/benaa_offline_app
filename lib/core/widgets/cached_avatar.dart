import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// 🖼️ Cached Avatar - صورة محسّنة مع lazy loading & caching
class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? localPath;
  final String initials;
  final Color color;
  final double size;
  final BoxShape shape;

  const CachedAvatar({
    required this.initials, required this.color, super.key,
    this.imageUrl,
    this.localPath,
    this.size = 56,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    // Local file image
    if (localPath != null && localPath!.isNotEmpty) {
      final file = File(localPath!);
      if (file.existsSync()) {
        return _buildImageContainer(
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialsAvatar(),
          ),
        );
      }
    }

    // Network image with caching
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => _buildImageContainer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: shape,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
        placeholder: (context, url) => _buildShimmerAvatar(context),
        errorWidget: (context, url, error) => _buildInitialsAvatar(),
        memCacheHeight: (size * 2).toInt(), // ✅ 2x الحجم الفعلي
        memCacheWidth: (size * 2).toInt(),
        maxHeightDiskCache: (size * 4).toInt(), // ✅ 4x للدقة العالية
        maxWidthDiskCache: (size * 4).toInt(),
        fadeInDuration: const Duration(milliseconds: 300),
      );
    }

    // Fallback to initials
    return _buildInitialsAvatar();
  }

  Widget _buildImageContainer({required Widget child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.circle
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(8),
        child: child,
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAvatar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.white, shape: shape),
      ),
    );
  }
}
