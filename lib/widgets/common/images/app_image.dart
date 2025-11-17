import 'dart:io';
import 'package:flutter/material.dart';

/// AppImage
/// Tek bir noktadan:
/// - http URL      -> Image.network
/// - assets/...    -> Image.asset
/// - cihaz path    -> Image.file
///
/// Ayrıca:
/// - [fallbackPath] verilirse, ana path hata verirse fallback path kullanılır.
/// - [placeholder] verilirse, path boşsa veya fallback de yoksa o gösterilir.
class AppImage extends StatelessWidget {
  final String? path;
  final String? fallbackPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.path,
    this.fallbackPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFromPath(path, isFallback: false);
  }

  Widget _buildFromPath(String? p, {required bool isFallback}) {
    // Hangi path'i deniyoruz?
    final String? currentPath = (p == null || p.isEmpty) ? null : p;

    // Path yoksa -> fallback'e geç, o da yoksa placeholder
    if (currentPath == null) {
      if (!isFallback && fallbackPath != null && fallbackPath!.isNotEmpty) {
        return _buildFromPath(fallbackPath, isFallback: true);
      }
      return placeholder ?? const SizedBox.shrink();
    }

    // Network
    if (currentPath.startsWith('http')) {
      return Image.network(
        currentPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          if (!isFallback && fallbackPath != null && fallbackPath!.isNotEmpty) {
            return _buildFromPath(fallbackPath, isFallback: true);
          }
          return placeholder ?? const SizedBox.shrink();
        },
      );
    }

    // Asset
    if (currentPath.startsWith('assets/')) {
      return Image.asset(
        currentPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          if (!isFallback && fallbackPath != null && fallbackPath!.isNotEmpty) {
            return _buildFromPath(fallbackPath, isFallback: true);
          }
          return placeholder ?? const SizedBox.shrink();
        },
      );
    }

    // Cihaz dosya sistemi (galeriden gelen yol)
    try {
      final file = File(currentPath);
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          if (!isFallback && fallbackPath != null && fallbackPath!.isNotEmpty) {
            return _buildFromPath(fallbackPath, isFallback: true);
          }
          return placeholder ?? const SizedBox.shrink();
        },
      );
    } catch (_) {
      if (!isFallback && fallbackPath != null && fallbackPath!.isNotEmpty) {
        return _buildFromPath(fallbackPath, isFallback: true);
      }
      return placeholder ?? const SizedBox.shrink();
    }
  }
}
