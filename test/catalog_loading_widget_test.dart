import 'package:bazarnicole/Presentation/View/Catalog/web_catalog_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra un estado de carga animado y amigable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CatalogLoadingState())),
    );

    expect(find.text('Cargando catálogo'), findsOneWidget);
    expect(
      find.text('Conectando con Drive y preparando tus productos'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
  });
}
