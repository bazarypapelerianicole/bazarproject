import 'package:flutter/foundation.dart';
import 'package:bazarnicole/Presentation/Model/inventory_model.dart';
import 'package:bazarnicole/Presentation/Services/database_service.dart';

class InventoryProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String search = '';
  int? selectedStoreId;

  List<Map<String, dynamic>> stores = [];
  List<InventoryItem> inventoryItems = [];
  List<InventoryItem> filteredItems = [];
  InventorySummary? summary;

  // Datos de vendibilidad (simulado - conectar con getSalesHistory)
  final Map<int, int> _unitsSoldByProduct = {};

  Future<void> initialize() async {
    if (isLoading || stores.isNotEmpty) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      stores = await DatabaseService.getStores();
      if (stores.isNotEmpty) {
        selectedStoreId ??= (stores.first['id'] as num).toInt();
        await loadInventory();
      }
    } catch (e) {
      errorMessage = 'No se pudo cargar el inventario: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectStore(int? storeId) async {
    if (storeId == null) return;
    selectedStoreId = storeId;
    await loadInventory();
  }

  Future<void> loadInventory() async {
    if (selectedStoreId == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Cargar inventario
      final rawInventory = await DatabaseService.getInventoryByStore(
        selectedStoreId!,
        search: search,
      );

      // Cargar datos de ventas para calcular unidades vendidas
      await _loadSalesData();

      // Convertir a InventoryItem
      inventoryItems = rawInventory.map((item) {
        final productId = (item['product_id'] as num).toInt();
        final unitsSold = _unitsSoldByProduct[productId] ?? 0;
        return InventoryItem.fromMap(item, unitsSold: unitsSold);
      }).toList();

      _filterAndSort();
      _calculateSummary();
    } catch (e) {
      errorMessage = 'No se pudo actualizar el inventario: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Carga datos de ventas para calcular rotación
  Future<void> _loadSalesData() async {
    try {
      // TODO: Conectar con getSalesHistory para obtener ventas del mes
      // Por ahora, usando datos simulados
      _unitsSoldByProduct.clear();
      // _unitsSoldByProduct[productId] = unitsVendidos;
    } catch (e) {
      // Si falla, continuar sin datos de vendibilidad
    }
  }

  void _filterAndSort() {
    // Filtrar por búsqueda
    filteredItems = inventoryItems.where((item) {
      if (search.isEmpty) return true;
      return item.name.toLowerCase().contains(search.toLowerCase()) ||
          item.sku.toLowerCase().contains(search.toLowerCase()) ||
          item.category.toLowerCase().contains(search.toLowerCase());
    }).toList();

    // Ordenar por saleability score (descendente)
    filteredItems.sort((a, b) => b.saleabilityScore.compareTo(a.saleabilityScore));
  }

  void _calculateSummary() {
    if (inventoryItems.isEmpty) {
      summary = null;
      return;
    }

    final totalInvested =
        inventoryItems.fold<double>(0, (sum, item) => sum + item.investmentValue);
    final totalPotentialGain =
        inventoryItems.fold<double>(0, (sum, item) => sum + item.potentialGain);

    final lowStock = inventoryItems.where((i) => i.isLowStock).length;
    final totalUnits = inventoryItems.fold<int>(0, (sum, i) => sum + i.quantity);

    // Top 5 más vendidos
    final topSellers = [...inventoryItems]
      ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));

    // Top 5 mejor margen
    final topMargin = [...inventoryItems]
      ..sort((a, b) => b.marginPercent.compareTo(a.marginPercent));

    final avgMargin = inventoryItems.isNotEmpty
        ? (inventoryItems.fold<double>(0, (sum, i) => sum + i.marginPercent) /
            inventoryItems.length)
            .toDouble()
        : 0.0;

    final avgRotation = inventoryItems.isNotEmpty
        ? (inventoryItems.fold<double>(0, (sum, i) => sum + i.rotationRate) /
            inventoryItems.length)
            .toDouble()
        : 0.0;

    summary = InventorySummary(
      totalInvested: totalInvested,
      totalPotentialGain: totalPotentialGain,
      totalProducts: inventoryItems.length,
      totalUnits: totalUnits,
      lowStockCount: lowStock,
      topSellers: topSellers.take(5).toList(),
      topMargin: topMargin.take(5).toList(),
      averageMarginPercent: avgMargin,
      averageRotation: avgRotation,
    );

    notifyListeners();
  }

  Future<void> updateSearch(String value) async {
    search = value;
    _filterAndSort();
    notifyListeners();
  }

  Future<void> updateStock({
    required int productId,
    required int stock,
  }) async {
    if (selectedStoreId == null) return;
    try {
      await DatabaseService.updateInventoryStock(
        productId: productId,
        storeId: selectedStoreId!,
        stock: stock,
      );
      await loadInventory();
    } catch (e) {
      errorMessage = 'Error al actualizar stock: $e';
      notifyListeners();
    }
  }

  Future<void> transferStock({
    required int productId,
    required int fromStoreId,
    required int toStoreId,
    required int quantity,
  }) async {
    try {
      await DatabaseService.transferInventory(
        productId: productId,
        fromStoreId: fromStoreId,
        toStoreId: toStoreId,
        quantity: quantity,
      );
      await loadInventory();
    } catch (e) {
      errorMessage = 'Error al transferir: $e';
      notifyListeners();
    }
  }

  /// Obtiene productos ordenados por saleability (más vendidos)
  List<InventoryItem> get topSellersItems =>
      [...filteredItems]
        ..sort((a, b) => b.saleabilityScore.compareTo(a.saleabilityScore));

  /// Obtiene productos con inversión crítica (stock bajo pero alto valor)
  List<InventoryItem> get criticalInvestment =>
      filteredItems
          .where((item) => item.isLowStock && item.investmentValue > 500)
          .toList();

  /// Obtiene productos con mejor margen pero bajo stock
  List<InventoryItem> get highMarginLowStock => filteredItems
      .where((item) => item.isLowStock && item.marginPercent > 40)
      .toList();
}
