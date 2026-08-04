import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'catalog_controller.dart';
import 'web_catalog_view.dart';
import 'product_detail_page.dart';

class CatalogRouter {
  static GoRouter createRouter({required CatalogController controller}) {
    return GoRouter(
      initialLocation: '/catalog',
      routes: [
        GoRoute(
          path: '/catalog',
          builder: (context, state) => WebCatalogView(controller: controller),
        ),
        GoRoute(
          path: '/catalog/:sku',
          builder: (context, state) => _CatalogDetailRoute(
            controller: controller,
            sku: Uri.decodeComponent(state.pathParameters['sku'] ?? ''),
          ),
        ),
        GoRoute(
          path: '/category/:categoryId',
          builder: (context, state) => WebCatalogView(
            controller: controller,
            initialCategoryId: state.pathParameters['categoryId'],
          ),
        ),
        GoRoute(
          path: '/store/:storeId',
          builder: (context, state) => WebCatalogView(
            controller: controller,
            initialStoreId: state.pathParameters['storeId'],
          ),
        ),
        GoRoute(
          path: '/search/:text',
          builder: (context, state) => WebCatalogView(
            controller: controller,
            initialSearch: Uri.decodeComponent(
              state.pathParameters['text'] ?? '',
            ),
            initialStoreId: null,
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Ruta no encontrada')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('La ruta solicitada no existe.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Volver al catálogo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogDetailRoute extends StatefulWidget {
  final CatalogController controller;
  final String sku;

  const _CatalogDetailRoute({required this.controller, required this.sku});

  @override
  State<_CatalogDetailRoute> createState() => _CatalogDetailRouteState();
}

class _CatalogDetailRouteState extends State<_CatalogDetailRoute> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isLoading && !widget.controller.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.controller.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de catálogo')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.controller.errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  widget.controller.refresh();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final product = widget.controller.productBySku(widget.sku);
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto no encontrado')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se encontró el producto para el SKU solicitado.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Volver al catálogo'),
              ),
            ],
          ),
        ),
      );
    }

    return ProductDetailPage(product: product);
  }
}
