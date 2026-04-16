import 'package:bazarnicole/Presentation/Services/database_service.dart';
import 'package:flutter/foundation.dart';

class ProductManagementController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> stores = [];
  List<Map<String, dynamic>> categories = [];

  Future<void> initialize() async {
    if (isLoading || products.isNotEmpty) return;
    await loadCatalog();
  }

  Future<void> loadCatalog({String search = ''}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      stores = await DatabaseService.getStores();
      categories = await DatabaseService.getCategories();
      products = await DatabaseService.getProducts(search: search);
    } catch (e) {
      errorMessage = 'No se pudo cargar el catálogo: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct({
    required String name,
    required String category,
    required double price,
    String? sku,
    Map<int, int> initialStock = const {},
  }) async {
    await DatabaseService.createProduct(
      name: name,
      price: price,
      categoryName: category,
      sku: sku,
      initialStock: initialStock,
    );
    await loadCatalog();
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    required String category,
    required double price,
    String? sku,
  }) async {
    await DatabaseService.updateProduct(
      productId: productId,
      name: name,
      categoryName: category,
      sku: sku ?? '',
      price: price,
    );
    await loadCatalog();
  }
}