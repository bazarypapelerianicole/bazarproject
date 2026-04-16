import 'package:bazarnicole/Presentation/Services/database_service.dart';
import 'package:flutter/foundation.dart';

class PosController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  int? selectedStoreId;
  int? selectedCustomerId;
  String search = '';

  List<Map<String, dynamic>> stores = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cart = [];

  double get total => cart.fold<double>(
    0,
    (sum, item) =>
        sum + ((item['quantity'] as int) * (item['price'] as double)),
  );

  int get totalItems => cart.fold<int>(
    0,
    (sum, item) => sum + (item['quantity'] as int),
  );

  Future<void> initialize() async {
    if (isLoading || stores.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      stores = await DatabaseService.getStores();
      customers = await DatabaseService.getCustomers();
      if (stores.isNotEmpty) {
        selectedStoreId ??= (stores.first['id'] as num).toInt();
      }
      await _loadProducts();
    } catch (e) {
      errorMessage = 'No se pudo cargar el POS: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectStore(int? storeId) async {
    if (storeId == null) return;
    selectedStoreId = storeId;
    cart.clear();
    await _loadProducts();
  }

  Future<void> updateSearch(String value) async {
    search = value;
    await _loadProducts();
  }

  Future<void> reloadCustomers() async {
    customers = await DatabaseService.getCustomers();
    notifyListeners();
  }

  void selectCustomer(int? customerId) {
    selectedCustomerId = customerId;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    if (selectedStoreId == null) {
      products = [];
      notifyListeners();
      return;
    }

    try {
      products = await DatabaseService.getInventoryByStore(
        selectedStoreId!,
        search: search,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = 'No se pudo actualizar el catálogo de venta: $e';
    }

    notifyListeners();
  }

  void addToCart(Map<String, dynamic> product) {
    final productId = (product['product_id'] as num).toInt();
    final stock = ((product['stock'] as num?)?.toInt()) ?? 0;
    final index = cart.indexWhere(
      (item) => (item['product_id'] as int) == productId,
    );

    if (stock <= 0) {
      errorMessage = 'Este producto no tiene stock disponible en el local';
      notifyListeners();
      return;
    }

    if (index >= 0) {
      final currentQty = cart[index]['quantity'] as int;
      if (currentQty >= stock) {
        errorMessage = 'No puedes vender más del stock disponible';
        notifyListeners();
        return;
      }
      cart[index]['quantity'] = currentQty + 1;
    } else {
      cart.add({
        'product_id': productId,
        'name': product['name'],
        'price': ((product['price'] as num?)?.toDouble()) ?? 0,
        'quantity': 1,
        'stock': stock,
      });
    }

    errorMessage = null;
    notifyListeners();
  }

  void incrementQuantity(int productId) {
    final index = cart.indexWhere((item) => item['product_id'] == productId);
    if (index < 0) return;

    final stock = cart[index]['stock'] as int;
    final currentQty = cart[index]['quantity'] as int;
    if (currentQty < stock) {
      cart[index]['quantity'] = currentQty + 1;
      errorMessage = null;
    } else {
      errorMessage = 'Stock máximo alcanzado';
    }
    notifyListeners();
  }

  void decrementQuantity(int productId) {
    final index = cart.indexWhere((item) => item['product_id'] == productId);
    if (index < 0) return;

    final currentQty = cart[index]['quantity'] as int;
    if (currentQty <= 1) {
      cart.removeAt(index);
    } else {
      cart[index]['quantity'] = currentQty - 1;
    }
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  Future<int> checkout() async {
    if (selectedStoreId == null) {
      throw Exception('Selecciona un local antes de vender');
    }
    if (cart.isEmpty) {
      throw Exception('Agrega productos al carrito');
    }

    final saleId = await DatabaseService.registerSale(
      storeId: selectedStoreId!,
      clientId: selectedCustomerId,
      items: cart
          .map(
            (item) => {
              'product_id': item['product_id'],
              'quantity': item['quantity'],
              'price': item['price'],
            },
          )
          .toList(),
    );

    cart.clear();
    await _loadProducts();
    return saleId;
  }
}
