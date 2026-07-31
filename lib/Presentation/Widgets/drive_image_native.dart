import 'package:flutter/material.dart';

/// Implementación nativa de [DriveImage].
///
/// La carga remota se implementa exclusivamente en la variante web mediante
/// `HTMLImageElement`. En otras plataformas este widget muestra su fallback.
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
    return SizedBox(
      width: width,
      height: height,
      child: errorWidget ?? placeholder ?? const SizedBox.shrink(),
    );
  }
}
