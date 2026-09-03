import 'package:bazarnicole/Presentation/Controller/purchases_controller.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../Widgets/Products/filter_dropdown.dart';
import '../../Widgets/Products/shared_inputs.dart';

class NewPurchaseTab extends StatelessWidget {
  const NewPurchaseTab({
    required this.searchController,
    required this.supplierController,
    required this.supplierPhoneController,
    required this.onSave,
    super.key,
  });

  final TextEditingController searchController;
  final TextEditingController supplierController;
  final TextEditingController supplierPhoneController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchasesController>(
      builder: (context, controller, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 980;
            final catalogPanel = _CatalogPanel(
              controller: controller,
              searchController: searchController,
              supplierController: supplierController,
              supplierPhoneController: supplierPhoneController,
            );
            final summaryPanel = _SummaryPanel(
              controller: controller,
              onSave: onSave,
            );

            return Padding(
              padding: const EdgeInsets.all(16),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: catalogPanel),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: summaryPanel),
                      ],
                    )
                  : ListView(
                      children: [
                        SizedBox(height: 520, child: catalogPanel),
                        const SizedBox(height: 16),
                        SizedBox(height: 360, child: summaryPanel),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

class _CatalogPanel extends StatelessWidget {
  const _CatalogPanel({
    required this.controller,
    required this.searchController,
    required this.supplierController,
    required this.supplierPhoneController,
  });

  final PurchasesController controller;
  final TextEditingController searchController;
  final TextEditingController supplierController;
  final TextEditingController supplierPhoneController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingreso de mercadería',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona el local, agrega proveedor y suma productos para aumentar stock.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilterDropdown<int?>(
                  label: 'Local destino',
                  value: controller.selectedStoreId,
                  items: controller.stores
                      .map(
                        (store) => DropdownMenuItem<int?>(
                          value: (store['id'] as num).toInt(),
                          child: Text(store['name'].toString()),
                        ),
                      )
                      .toList(),
                  onChanged: controller.selectStore,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: supplierController,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: filterFieldDecoration(hint: 'Proveedor opcional'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: supplierPhoneController,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: filterFieldDecoration(hint: 'Teléfono proveedor'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: filterFieldDecoration(
                    hint: 'Buscar producto',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: controller.updateSearch,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'PRODUCTO Y SKU',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'PRECIO REF.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 52),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: controller.isLoading && controller.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.products.isEmpty
                ? const Center(child: Text('No hay productos para comprar.'))
                : ListView.separated(
                    itemCount: controller.products.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: Divider(height: 0.1, color: AppColors.lightGray),
                    ),
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      final price = (product['price'] as num?)?.toDouble() ?? 0;
                      return Material(
                            color: AppColors.whiteOverlay,
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => controller.addToCart(product),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.threeColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name']?.toString() ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'SKU: ${product['sku'] ?? 'Sin código'}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '\$${price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      tooltip: 'Agregar producto',
                                      onPressed: () =>
                                          controller.addToCart(product),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 30 * (index % 20)),
                            duration: 280.ms,
                          )
                          .slideX(
                            begin: 0.04,
                            end: 0,
                            delay: Duration(milliseconds: 30 * (index % 20)),
                            duration: 280.ms,
                            curve: Curves.easeOut,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.controller, required this.onSave});

  final PurchasesController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.whiteOverlay,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de compra',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${controller.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: controller.cart.isEmpty
                  ? const Center(child: Text('Todavía no agregas productos.'))
                  : ListView.separated(
                      itemCount: controller.cart.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = controller.cart[index];
                        final subtotal =
                            (item['quantity'] as int) *
                            (item['cost'] as double);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item['name']?.toString() ?? ''),
                          subtitle: Text(
                            'Costo: \$${(item['cost'] as double).toStringAsFixed(2)} · Subtotal: \$${subtotal.toStringAsFixed(2)}',
                          ),
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
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
                              IconButton(
                                tooltip: 'Editar costo',
                                onPressed: () => _showCostDialog(
                                  context,
                                  controller,
                                  item['product_id'] as int,
                                  item['cost'] as double,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.cart.isEmpty ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Guardar compra'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCostDialog(
    BuildContext context,
    PurchasesController controller,
    int productId,
    double currentCost,
  ) async {
    final costController = TextEditingController(
      text: currentCost.toStringAsFixed(2),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar costo'),
        content: TextField(
          controller: costController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Costo unitario',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final newCost =
                  double.tryParse(costController.text.trim()) ?? currentCost;
              controller.updateCost(productId, newCost);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    costController.dispose();
  }
}
