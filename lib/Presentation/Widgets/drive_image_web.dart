import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:web/web.dart' as web;

/// Imagen remota para Flutter Web cargada por el navegador con un
/// [web.HTMLImageElement].
///
/// `HtmlElementView.fromTagName` es la API de Flutter Web para crear y
/// configurar un elemento HTML sin registrar un `viewType` propio. Por ello no
/// hay fábricas globales ni registros que crezcan por cada imagen.
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
  _ImageState _imageState = _ImageState.loading;
  _ImageProbe? _probe;
  web.HTMLImageElement? _loadedImage;

  @override
  void initState() {
    super.initState();
    _startProbe();
  }

  @override
  void didUpdateWidget(covariant DriveImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url) return;

    _disposeProbe();
    _loadedImage = null;
    setState(() => _imageState = _ImageState.loading);
    _startProbe();
  }

  void _startProbe() {
    late final _ImageProbe probe;
    probe = _ImageProbe(
      url: widget.url,
      onLoad: () => _completeProbe(probe, _ImageState.ready),
      onError: () => _completeProbe(probe, _ImageState.failed),
    );
    _probe = probe;
  }

  void _completeProbe(_ImageProbe probe, _ImageState state) {
    if (!mounted || !identical(_probe, probe)) return;

    _probe = null;
    _loadedImage = switch (state) {
      _ImageState.ready => probe.takeImage(),
      _ImageState.failed => null,
      _ImageState.loading => null,
    };
    if (state != _ImageState.ready) probe.dispose();
    setState(() => _imageState = state);
  }

  void _disposeProbe() {
    _probe?.dispose();
    _probe = null;
  }

  @override
  void dispose() {
    _disposeProbe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final renderKey = (widget.url, widget.fit, widget.borderRadius);
    final content = switch (_imageState) {
      _ImageState.loading => widget.placeholder ?? const SizedBox.shrink(),
      _ImageState.failed => widget.errorWidget ?? const SizedBox.shrink(),
      _ImageState.ready => _BrowserImage(
        key: ValueKey(renderKey),
        image: _loadedImage!,
        fit: widget.fit,
        borderRadius: widget.borderRadius,
      ),
    };

    return SizedBox(width: widget.width, height: widget.height, child: content);
  }
}

/// Carga una URL con el cargador nativo del navegador antes de crear la vista
/// visible. Así `placeholder` y `errorWidget` ocupan el mismo espacio sin una
/// pila de widgets ni una Platform View invisible debajo de ellos. El mismo
/// elemento que completa la carga se inserta después en la Platform View.
class _ImageProbe {
  _ImageProbe({
    required String url,
    required VoidCallback onLoad,
    required VoidCallback onError,
  }) : _image = web.HTMLImageElement()..alt = '' {
    _onLoad = ((web.Event _) => onLoad()).toJS;
    _onError = ((web.Event _) => onError()).toJS;
    _image.addEventListener('load', _onLoad);
    _image.addEventListener('error', _onError);
    _image.src = url;
  }

  final web.HTMLImageElement _image;
  late final JSFunction _onLoad;
  late final JSFunction _onError;

  void dispose() {
    _removeListeners();
    _image.removeAttribute('src');
  }

  web.HTMLImageElement takeImage() {
    _removeListeners();
    return _image;
  }

  void _removeListeners() {
    _image.removeEventListener('load', _onLoad);
    _image.removeEventListener('error', _onError);
  }
}

class _BrowserImage extends StatelessWidget {
  const _BrowserImage({
    super.key,
    required this.image,
    required this.fit,
    required this.borderRadius,
  });

  final web.HTMLImageElement image;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'div',
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
      onElementCreated: (element) {
        final root = element as web.HTMLDivElement;
        _configureRoot(root, borderRadius);
        _configureImage(image, fit);
        root.append(image);
      },
    );
  }
}

void _configureRoot(web.HTMLDivElement root, BorderRadius? borderRadius) {
  root.style
    ..setProperty('display', 'block')
    ..setProperty('width', '100%')
    ..setProperty('height', '100%')
    ..setProperty('overflow', 'hidden')
    ..setProperty('position', 'relative')
    ..setProperty('pointer-events', 'none');

  if (borderRadius != null) {
    root.style.setProperty('border-radius', _borderRadiusCss(borderRadius));
  }
}

void _configureImage(web.HTMLImageElement image, BoxFit fit) {
  image.style
    ..setProperty('display', 'block')
    ..setProperty('position', 'absolute')
    ..setProperty('pointer-events', 'none')
    ..setProperty('left', '0')
    ..setProperty('top', '0')
    ..setProperty('transform', 'none')
    ..removeProperty('object-fit')
    ..removeProperty('object-position');

  switch (fit) {
    case BoxFit.fitWidth:
      image.style
        ..setProperty('width', '100%')
        ..setProperty('height', 'auto')
        ..setProperty('left', '0')
        ..setProperty('top', '50%')
        ..setProperty('transform', 'translateY(-50%)');
    case BoxFit.fitHeight:
      image.style
        ..setProperty('width', 'auto')
        ..setProperty('height', '100%')
        ..setProperty('left', '50%')
        ..setProperty('top', '0')
        ..setProperty('transform', 'translateX(-50%)');
    default:
      image.style
        ..setProperty('width', '100%')
        ..setProperty('height', '100%')
        ..setProperty('object-fit', _objectFit(fit))
        ..setProperty('object-position', 'center');
  }
}

String _objectFit(BoxFit fit) => switch (fit) {
  BoxFit.fill => 'fill',
  BoxFit.contain => 'contain',
  BoxFit.cover => 'cover',
  BoxFit.none => 'none',
  BoxFit.scaleDown => 'scale-down',
  BoxFit.fitWidth || BoxFit.fitHeight => throw StateError('Handled above.'),
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

enum _ImageState { loading, ready, failed }
