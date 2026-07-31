// Imagen remota que usa un elemento HTML nativo en Flutter Web.
// La implementación se selecciona en tiempo de compilación: Web usa un
// `HTMLImageElement` mediante `HtmlElementView`, mientras que las plataformas
// nativas conservan `Image.network`.
export 'drive_image_native.dart'
    if (dart.library.js_interop) 'drive_image_web.dart';
