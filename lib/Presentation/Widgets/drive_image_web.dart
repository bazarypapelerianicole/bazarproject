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

  @override
  void initState() {
    super.initState();
    if (widget.url.isEmpty) {
      _imageState = _ImageState.failed;
      return;
    }
    _startProbe();
  }

  @override
  void didUpdateWidget(covariant DriveImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url) return;

    _disposeProbe();
    if (widget.url.isEmpty) {
      setState(() => _imageState = _ImageState.failed);
      return;
    }
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
    probe.dispose();
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
    // ignore: avoid_print
    print('[DriveImage] URL');
    // ignore: avoid_print
    print(widget.url);
    final content = switch (_imageState) {
      _ImageState.loading => widget.placeholder ?? const SizedBox.shrink(),
      _ImageState.failed => widget.errorWidget ?? const SizedBox.shrink(),
      _ImageState.ready => _BrowserImage(
        key: ValueKey(renderKey),
        url: widget.url,
        fit: widget.fit,
        borderRadius: widget.borderRadius,
      ),
    };

    return SizedBox(width: widget.width, height: widget.height, child: content);
  }
}

/// Carga una URL con el cargador nativo del navegador antes de crear la vista
/// visible. Así `placeholder` y `errorWidget` ocupan el mismo espacio sin una
/// pila de widgets ni una Platform View invisible debajo de ellos.
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

  void _removeListeners() {
    _image.removeEventListener('load', _onLoad);
    _image.removeEventListener('error', _onError);
  }
}

class _BrowserImage extends StatelessWidget {
  const _BrowserImage({
    super.key,
    required this.url,
    required this.fit,
    required this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'img',
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
      onElementCreated: (element) {
        final img = element as web.HTMLImageElement;
        img
          ..src = url
          ..alt = '';
        img.style
          ..width = '100%'
          ..height = '100%'
          ..display = 'block'
          ..objectFit = _objectFit(fit)
          ..objectPosition = 'center'
          ..pointerEvents = 'none';
        if (borderRadius != null) {
          img.style.setProperty(
            'border-radius',
            _borderRadiusCss(borderRadius!),
          );
        }
        // ignore: avoid_print
        print('[DriveImage] Render img');
        // ignore: avoid_print
        print(img.src);
      },
    );
  }
}

String _objectFit(BoxFit fit) => switch (fit) {
  BoxFit.fill => 'fill',
  BoxFit.contain => 'contain',
  BoxFit.cover => 'cover',
  BoxFit.none => 'none',
  BoxFit.scaleDown => 'scale-down',
  BoxFit.fitWidth || BoxFit.fitHeight => 'cover',
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
