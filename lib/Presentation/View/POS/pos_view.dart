import 'package:bazarnicole/Presentation/Controller/pos_controller.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosController>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final controller = context.read<PosController>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final saleId = await controller.checkout();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Venta registrada correctamente #$saleId')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): () {
          _searchFocusNode.requestFocus();
        },
        const SingleActivator(LogicalKeyboardKey.f9): _checkout,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          context.read<PosController>().clearCart();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('POS · Punto de venta'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: Text('F2 Buscar · F9 Vender · ESC Limpiar'),
                ),
              ),
            ],
          ),
          body: Consumer<PosController>(
            builder: (context, controller, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 980;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _CatalogPanel(
                                  searchController: _searchController,
                                  searchFocusNode: _searchFocusNode,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const SizedBox(width: 360, child: _CartPanel()),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _CatalogPanel(
                                  searchController: _searchController,
                                  searchFocusNode: _searchFocusNode,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Expanded(flex: 2, child: _CartPanel()),
                            ],
                          ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CatalogPanel extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  const _CatalogPanel({
    required this.searchController,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PosController>(
      builder: (context, controller, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Búsqueda rápida tipo Google',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona el local, busca al instante y agrega al carrito con botones grandes.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: controller.selectedStoreId,
                        decoration: const InputDecoration(
                          labelText: 'Local',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.stores.map((store) {
                          final id = (store['id'] as num).toInt();
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(store['name'].toString()),
                          );
                        }).toList(),
                        onChanged: controller.selectStore,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: controller.selectedCustomerId,
                        decoration: const InputDecoration(
                          labelText: 'Cliente opcional',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Sin cliente'),
                          ),
                          ...controller.customers.map((customer) {
                            final id = (customer['id'] as num).toInt();
                            return DropdownMenuItem<int?>(
                              value: id,
                              child: Text(customer['name'].toString()),
                            );
                          }),
                        ],
                        onChanged: controller.selectCustomer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, SKU o categoría',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              controller.updateSearch('');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: controller.updateSearch,
                ),
                const SizedBox(height: 12),
                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: controller.isLoading && controller.products.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 230,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: controller.products.length,
                          itemBuilder: (context, index) {
                            final product = controller.products[index];
                            final stock = ((product['stock'] as num?)?.toInt()) ?? 0;
                            final price = ((product['price'] as num?)?.toDouble()) ?? 0;

                            return FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                backgroundColor: stock > 0
                                    ? AppColors.threeColor
                                    : Colors.grey.shade200,
                              ),
                              onPressed: stock > 0
                                  ? () => controller.addToCart(product)
                                  : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.point_of_sale, size: 28),
                                  const Spacer(),
                                  Text(
                                    product['name']?.toString() ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Stock: $stock',
                                    style: TextStyle(
                                      color: stock <= 2 ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  Text(
                                    '\$${price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel();

  @override
  Widget build(BuildContext context) {
    return Consumer<PosController>(
      builder: (context, controller, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  'Carrito',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Productos: ${controller.totalItems}'),
                const SizedBox(height: 12),
                Expanded(
                  child: controller.cart.isEmpty
                      ? const Center(child: Text('Aún no agregas productos'))
                      : ListView.separated(
                          itemCount: controller.cart.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = controller.cart[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'].toString(),
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '\$${(item['price'] as double).toStringAsFixed(2)} c/u',
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.decrementQuantity(
                                    item['product_id'] as int,
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('${item['quantity']}'),
                                IconButton(
                                  onPressed: () => controller.incrementQuantity(
                                    item['product_id'] as int,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total'),
                      Text(
                        '\$${controller.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.cart.isEmpty
                        ? null
                        : () => context.findAncestorStateOfType<_PosViewState>()?._checkout(),
                    icon: const Icon(Icons.sell),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Vender · F9'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.cart.isEmpty ? null : controller.clearCart,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Vaciar carrito'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
