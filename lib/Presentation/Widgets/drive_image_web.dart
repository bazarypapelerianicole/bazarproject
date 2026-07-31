import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Imagen remota para Flutter Web que delega la descarga al navegador.
///
/// El `src` se asigna directamente a un `HTMLImageElement`, igual que en un
/// `<img src="...">`; no usa `Image.network`, `NetworkImage` ni CanvasKit.
class DriveImage extends StatefulWidget {
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
  State<DriveImage> createState() => _DriveImageState();
}

class _DriveImageState extends State<DriveImage> {
  static int _nextViewId = 0;

  late String _viewType;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
  }

  @override
  void didUpdateWidget(covariant DriveImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.fit != widget.fit ||
        oldWidget.borderRadius != widget.borderRadius) {
      _isLoaded = false;
      _hasError = false;
      _registerViewFactory();
    }
  }

  void _registerViewFactory() {
    _viewType = 'drive-image-${_nextViewId++}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, _createImage);
  }

  web.HTMLImageElement _createImage(int viewId) {
    final image = web.HTMLImageElement()
      ..alt = ''
      ..src = '';

    image.style
      ..setProperty('display', 'block')
      ..setProperty('width', '100%')
      ..setProperty('height', '100%')
      ..setProperty('object-fit', _objectFit(widget.fit))
      ..setProperty('object-position', 'center')
      ..setProperty('opacity', '0')
      ..setProperty('transition', 'opacity 100ms ease');

    final borderRadius = widget.borderRadius;
    if (borderRadius != null) {
      image.style.setProperty('border-radius', _borderRadiusCss(borderRadius));
      image.style.setProperty('overflow', 'hidden');
    }

    image.addEventListener(
      'load',
      ((web.Event event) {
        image.style.setProperty('opacity', '1');
        if (mounted) {
          setState(() {
            _isLoaded = true;
            _hasError = false;
          });
        }
      }).toJS,
    );
    image.addEventListener(
      'error',
      ((web.Event event) {
        image.style.setProperty('display', 'none');
        if (mounted) {
          setState(() {
            _isLoaded = false;
            _hasError = true;
          });
        }
      }).toJS,
    );

    // Se asigna después de los listeners para no perder una carga desde caché.
    image.src = widget.url;
    return image;
  }

  @override
  Widget build(BuildContext context) {
    final showPlaceholder = !_isLoaded && !_hasError;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showPlaceholder && widget.placeholder != null)
            widget.placeholder!,
          if (_hasError && widget.errorWidget != null) widget.errorWidget!,
          HtmlElementView(key: ValueKey(_viewType), viewType: _viewType),
        ],
      ),
    );
  }
}

String _objectFit(BoxFit fit) => switch (fit) {
  BoxFit.fill => 'fill',
  BoxFit.contain => 'contain',
  BoxFit.cover || BoxFit.fitWidth || BoxFit.fitHeight => 'cover',
  BoxFit.none => 'none',
  BoxFit.scaleDown => 'scale-down',
};

String _borderRadiusCss(BorderRadius radius) {
  String values(bool horizontal) => [
    radius.topLeft,
    radius.topRight,
    radius.bottomRight,
    radius.bottomLeft,
  ].map((corner) => '${horizontal ? corner.x : corner.y}px').join(' ');

  return '${values(true)} / ${values(false)}';
}
