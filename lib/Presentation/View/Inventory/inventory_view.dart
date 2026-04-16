import 'package:bazarnicole/Presentation/Context/inventory_provider.dart';
import 'package:bazarnicole/Presentation/Model/inventory_model.dart';
import 'package:bazarnicole/Presentation/Renders/responsive_helper.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:bazarnicole/Presentation/Widgets/inventory_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final _searchController = TextEditingController();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<InventoryProvider>().initialize();
      } catch (e) {
        debugPrint('Error al acceder a InventoryProvider en initState: $e');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditStockDialog(InventoryItem item) {
    final controller = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Stock - ${item.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nueva cantidad',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text);
              if (newStock != null && newStock >= 0) {
                context.read<InventoryProvider>().updateStock(productId: item.productId, stock: newStock);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(InventoryItem item) {
    final quantityController = TextEditingController();
    String? selectedStoreId;

    showDialog(
      context: context,
      builder: (ctx) => Consumer<InventoryProvider>(
        builder: (_, provider, __) => AlertDialog(
          title: Text('Transferir - ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tienda Destino'),
                value: selectedStoreId,
                items: provider.stores
                    .where((s) => (s['id'] as num).toInt() != provider.selectedStoreId)
                    .map((store) => DropdownMenuItem(value: store['id'].toString(), child: Text(store['name'] ?? 'Tienda')))
                    .toList(),
                onChanged: (value) {
                  selectedStoreId = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cantidad (máx: ${item.quantity})', border: const OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0 && quantity <= item.quantity && selectedStoreId != null) {
                  context.read<InventoryProvider>().transferStock(
                        productId: item.productId,
                        fromStoreId: provider.selectedStoreId!,
                        toStoreId: int.parse(selectedStoreId!),
                        quantity: quantity,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Transferir'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = ResponsiveHelper.getAppBarHeight(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight + 50),
        child: ClipRRect(
          clipBehavior: Clip.hardEdge,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blackOverlay,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.whiteOverlay, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Column(
                  children: [
                    Text('📦 Inventario por Local', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.whiteOverlay)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _TabButton(label: 'Stock', isSelected: _selectedTab == 0, onPressed: () => setState(() => _selectedTab = 0)),
                          _TabButton(label: 'Vendibilidad', isSelected: _selectedTab == 1, onPressed: () => setState(() => _selectedTab = 1)),
                          _TabButton(label: 'Inversión', isSelected: _selectedTab == 2, onPressed: () => setState(() => _selectedTab = 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.stores.isNotEmpty)
                DropdownButtonFormField<int>(
                  value: provider.selectedStoreId,
                  decoration: const InputDecoration(labelText: '🏪 Local', border: OutlineInputBorder()),
                  items: provider.stores.map((store) => DropdownMenuItem<int>(value: (store['id'] as num).toInt(), child: Text(store['name'] ?? 'Tienda'))).toList(),
                  onChanged: (storeId) {
                    if (storeId != null) provider.selectStore(storeId);
                  },
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar producto',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.updateSearch('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
                onChanged: (value) {
                  provider.updateSearch(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTabContent(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(InventoryProvider provider) {
    if (provider.filteredItems.isEmpty) return const Center(child: Text('No hay productos para este local'));

    switch (_selectedTab) {
      case 0:
        return _buildStockTab(provider);
      case 1:
        return _buildSaleabilityTab(provider);
      case 2:
        return _buildInvestmentTab(provider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStockTab(InventoryProvider provider) {
    return ListView(
      children: [
        if (provider.summary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _StockSummaryCard(summary: provider.summary!),
          ),
        ...provider.filteredItems.map((item) => InventoryProductCard(
              item: item,
              onEditStock: () => _showEditStockDialog(item),
              onTransfer: () => _showTransferDialog(item),
            )),
      ],
    );
  }

  Widget _buildSaleabilityTab(InventoryProvider provider) {
    final topSellers = [...provider.filteredItems]..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));

    return ListView(
      children: [
        if (provider.summary != null && topSellers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TopProductsList(items: topSellers.take(5).toList(), title: '🏆 Productos Más Vendidos', metric: 'sales'),
          ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: const Text('Todos los productos (ordenados por vendibilidad)', style: TextStyle(fontWeight: FontWeight.bold))),
        ...provider.filteredItems.map((item) => InventoryProductCard(
              item: item,
              onEditStock: () => _showEditStockDialog(item),
              onTransfer: () => _showTransferDialog(item),
            )),
      ],
    );
  }

  Widget _buildInvestmentTab(InventoryProvider provider) {
    final topMargin = [...provider.filteredItems]..sort((a, b) => b.marginPercent.compareTo(a.marginPercent));

    return ListView(
      children: [
        if (provider.summary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InventoryInvestmentCard(summary: provider.summary!),
          ),
        if (topMargin.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TopProductsList(items: topMargin.take(5).toList(), title: '💰 Mejores Márgenes de Ganancia', metric: 'margin'),
          ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: const Text('Todos los productos (ordenados por inversión)', style: TextStyle(fontWeight: FontWeight.bold))),
        ...provider.filteredItems.map((item) => InventoryProductCard(
              item: item,
              onEditStock: () => _showEditStockDialog(item),
              onTransfer: () => _showTransferDialog(item),
            )),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TabButton({required this.label, required this.isSelected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onPressed(),
        backgroundColor: Colors.transparent,
        side: BorderSide(color: isSelected ? AppColors.whiteOverlay : Colors.white38),
        labelStyle: TextStyle(color: isSelected ? AppColors.whiteOverlay : Colors.white70),
      ),
    );
  }
}

class _StockSummaryCard extends StatelessWidget {
  final InventorySummary summary;

  const _StockSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Resumen de Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StockMetric(label: 'Productos', value: summary.totalProducts.toString()),
                _StockMetric(label: 'Unidades', value: summary.totalUnits.toString()),
                _StockMetric(label: 'Stock Bajo', value: summary.lowStockCount.toString(), color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StockMetric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
