import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/media_url_resolver.dart';

/// Unified image widget that safely handles assets, local device files,
/// and remote/MinIO network images with automated host remapping and headers.
class VitheyMediaImage extends StatelessWidget {
  const VitheyMediaImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.fallbackColor,
    this.iconColor,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? fallbackColor;
  final Color? iconColor;

  Widget _buildError(BuildContext context) {
    if (errorWidget != null) return errorWidget!;
    final bgColor = fallbackColor ?? context.appColors.inputFill;
    return Container(
      width: width,
      height: height,
      color: bgColor,
      alignment: Alignment.center,
      child: VitheyIcon(
        LucideIcons.imageOff,
        color: iconColor ?? context.appColors.muted,
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    final bgColor = fallbackColor ?? context.appColors.inputFill;
    return ColoredBox(
      color: bgColor,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = MediaUrlResolver.resolve(url);

    if (resolved.isEmpty) {
      return _buildError(context);
    }

    if (resolved.isAsset) {
      return Image.asset(
        resolved.url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _buildError(context),
      );
    }

    if (resolved.isLocalFile) {
      try {
        final file = File(resolved.url);
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          errorBuilder: (_, __, ___) => _buildError(context),
        );
      } catch (_) {
        return _buildError(context);
      }
    }

    return CachedNetworkImage(
      imageUrl: resolved.url,
      httpHeaders: resolved.headers,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: (_, __) => _buildPlaceholder(context),
      errorWidget: (_, __, ___) => _buildError(context),
    );
  }
}
