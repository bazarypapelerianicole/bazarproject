import 'package:bazarnicole/Presentation/Controller/purchases_controller.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Widgets/Products/filter_dropdown.dart';

class PurchaseHistoryTab extends StatelessWidget {
  const PurchaseHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchasesController>(
      builder: (context, controller, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 220,
                      child: FilterDropdown<int?>(
                        label: 'Local',
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
                    SizedBox(
                      width: 220,
                      child: FilterDropdown<String?>(
                        label: 'Categoría',
                        value: controller.historyCategory,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Categoría'),
                          ),
                          ...controller.categories.map(
                            (category) => DropdownMenuItem<String?>(
                              value: category['name'].toString(),
                              child: Text(category['name'].toString()),
                            ),
                          ),
                        ],
                        onChanged: controller.selectHistoryCategory,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: FilterDropdown<int?>(
                        label: 'Proveedor',
                        value: controller.historySupplierId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...controller.suppliers.map(
                            (supplier) => DropdownMenuItem<int?>(
                              value: (supplier['id'] as num).toInt(),
                              child: Text(supplier['name'].toString()),
                            ),
                          ),
                        ],
                        onChanged: controller.selectHistorySupplier,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                          initialDate: controller.historyDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          await controller.setHistoryDate(picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        controller.historyDate == null
                            ? 'Filtrar por fecha'
                            : DateFormat(
                                'dd/MM/yyyy',
                              ).format(controller.historyDate!),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.clearHistoryFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Limpiar filtros'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: controller.isHistoryLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.purchaseHistory.isEmpty
                    ? const _PurchaseHistoryEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.purchaseHistory.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final purchase = controller.purchaseHistory[index];
                          final date = DateTime.tryParse(
                            purchase['date']?.toString() ?? '',
                          );
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.receipt_long_outlined),
                            ),
                            title: Text(
                              'Compra #${purchase['id']} · ${purchase['store_name'] ?? ''}',
                            ),
                            subtitle: Text(
                              '${purchase['supplier_name'] ?? 'Sin proveedor'} · ${date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : ''}',
                            ),
                            trailing: Text(
                              '\$${((purchase['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => _showPurchaseDetail(
                              context,
                              controller,
                              (purchase['id'] as num).toInt(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPurchaseDetail(
    BuildContext context,
    PurchasesController controller,
    int purchaseId,
  ) async {
    final items = await controller.getPurchaseItems(purchaseId);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle de compra #$purchaseId'),
        content: SizedBox(
          width: 420,
          child: items.isEmpty
              ? const Text('No hay productos en esta compra.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final subtotal =
                        ((item['quantity'] as num?)?.toInt() ?? 0) *
                        ((item['cost'] as num?)?.toDouble() ?? 0);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item['product_name']?.toString() ?? ''),
                      subtitle: Text(
                        'Cant: ${item['quantity']} · Costo: \$${((item['cost'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                      ),
                      trailing: Text('\$${subtotal.toStringAsFixed(2)}'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _PurchaseHistoryEmptyState extends StatelessWidget {
  const _PurchaseHistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.blackOverlay.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.blackOverlay,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tu historial está vacío',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppColors.blackOverlay,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Registra una compra para ver aquí todos tus movimientos de abastecimiento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: () => DefaultTabController.of(context).animateTo(0),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blackOverlay,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart_outlined, size: 19),
              label: const Text(
                'Nueva compra',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
