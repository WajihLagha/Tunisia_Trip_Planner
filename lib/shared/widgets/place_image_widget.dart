import 'package:flutter/material.dart';

/// Smart image widget that auto-detects whether to load from network or asset.
/// Shows a styled placeholder on error.
class PlaceImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final Widget? placeholder;

  const PlaceImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  bool get _isNetworkUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return false;
    return imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final fallback = placeholder ??
        Container(
          color: cs.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              size: 32,
            ),
          ),
        );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    if (_isNetworkUrl) {
      return Image.network(
        imageUrl!,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: cs.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    // Local asset
    return Image.asset(
      imageUrl!,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
