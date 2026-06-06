import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'common_widgets.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.landscape_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    final child = imageUrl.isEmpty
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            memCacheWidth: width != null ? (width! * 2).toInt() : 800,
            placeholder: (_, __) => _loading(),
            errorWidget: (_, __, ___) => _fallback(),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _loading() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primaryDark.withValues(alpha: 0.25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Icon(fallbackIcon, size: 40, color: AppColors.primary)),
    );
  }
}
