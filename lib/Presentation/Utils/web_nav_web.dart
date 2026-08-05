// Web implementation using dart:html
// ignore: avoid_web_libraries_in_flutter

import 'package:web/web.dart' as html;

void navigateToExternalCatalog(String url) {
  html.window.location.href = url;
}
