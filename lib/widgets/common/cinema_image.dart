import 'package:flutter/material.dart';

/// Unified image widget supporting bundled local cinema assets (`assets/...`)
/// and remote HTTP/HTTPS URLs cleanly with graceful dark fallback.
class CinemaImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const CinemaImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return errorBuilder?.call(context, 'Empty image path', null) ??
          const SizedBox.shrink();
    }

    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        fit: fit,
        alignment: alignment,
        errorBuilder: errorBuilder,
      );
    }

    return Image.network(
      trimmed,
      fit: fit,
      alignment: alignment,
      errorBuilder: errorBuilder,
    );
  }
}
