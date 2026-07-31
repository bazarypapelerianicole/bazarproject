import 'package:flutter/material.dart';

/// Implementación nativa de [DriveImage].
///
/// En plataformas no web se conserva el proveedor de imágenes nativo de
/// Flutter; el elemento HTML solo existe en la implementación web.
class DriveImage extends StatelessWidget {
  const DriveImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null || placeholder == null) return child;
        return placeholder!;
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? const SizedBox.shrink(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
