import 'package:bazarnicole/Presentation/Controller/customers_controller.dart';
import 'package:bazarnicole/Presentation/Controller/pos_controller.dart';
import 'package:bazarnicole/Presentation/Controller/product_management_controller.dart';
import 'package:bazarnicole/Presentation/Controller/reports_controller.dart';
import 'package:bazarnicole/Presentation/View/Customers/customers_view.dart';
import 'package:bazarnicole/Presentation/View/POS/pos_view.dart';
import 'package:bazarnicole/Presentation/View/Product/product_management_view.dart';
import 'package:bazarnicole/Presentation/View/Reports/reports_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('muestra la estructura de productos compartidos', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProductManagementController(),
        child: const MaterialApp(home: ProductManagementView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Productos compartidos'), findsOneWidget);
    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.text('Stock inicial por local'), findsOneWidget);
  });

  testWidgets('muestra la pantalla POS principal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PosController(),
        child: const MaterialApp(home: PosView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('POS · Punto de venta'), findsOneWidget);
    expect(find.text('Carrito'), findsOneWidget);
  });

  testWidgets('muestra la pantalla de clientes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CustomersController(),
        child: const MaterialApp(home: CustomersView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Clientes · CRM'), findsOneWidget);
    expect(find.text('Registrar cliente'), findsOneWidget);
  });

  testWidgets('muestra la pantalla de reportes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ReportsController(),
        child: const MaterialApp(home: ReportsView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reportes comerciales'), findsOneWidget);
    expect(find.text('Ventas por local'), findsOneWidget);
  });
}
