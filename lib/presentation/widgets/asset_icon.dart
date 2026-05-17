import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG/PNG from assets; uses [fallback] icon if load fails.
class AssetIcon extends StatelessWidget {
  const AssetIcon({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.fallback,
  });

  final String asset;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final IconData? fallback;

  @override
  Widget build(BuildContext context) {
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => _fallbackWidget(),
      );
    }
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      errorBuilder: (context, error, stackTrace) => _fallbackWidget(),
    );
  }

  Widget _fallbackWidget() {
    if (fallback == null) {
      return SizedBox(width: width, height: height);
    }
    return Icon(
      fallback,
      size: height ?? width ?? 24,
      color: color ?? Colors.white,
    );
  }
}
