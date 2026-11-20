import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Cached plant image with a placeholder for missing or broken images.
class PlantThumbnail extends StatelessWidget {
  const PlantThumbnail({
    required this.imageUrl,
    super.key,
    this.size,
    this.aspectRatio = 1,
    this.borderRadius = AppSpacing.cardRadius,
    this.semanticLabel,
  });

  final String? imageUrl;

  /// Fixed square size; when null the image fills its width at [aspectRatio].
  final double? size;
  final double aspectRatio;
  final double borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final image = url == null || url.isEmpty
        ? const _Placeholder()
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ColoredBox(color: AppColors.accent),
            errorWidget: (_, _, _) => const _Placeholder(),
          );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Semantics(image: true, label: semanticLabel, child: image),
    );

    final dimension = size;
    return dimension != null
        ? SizedBox.square(dimension: dimension, child: clipped)
        : AspectRatio(aspectRatio: aspectRatio, child: clipped);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.accent,
    child: Center(child: Icon(Icons.local_florist_outlined, color: AppColors.secondary)),
  );
}
