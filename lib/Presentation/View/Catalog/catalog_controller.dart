import 'package:flutter/foundation.dart';
import 'package:bazarnicole/Presentation/Template/catalog_template.dart';
import 'catalog_repository.dart';

/// Controlador del catálogo web. Mantiene el estado en memoria y evita
/// descargas repetidas de JSON cuando el usuario navega entre rutas.
class CatalogController extends ChangeNotifier {
  final CatalogRepository repository;

  CatalogController({required this.repository});

  bool isLoading = false;
  bool isReady = false;
  String? errorMessage;
  CatalogRepositoryData? _catalogData;

  String currentSearch = '';
  String? selectedCategoryId;
  String? selectedStoreId;

  List<CatalogSection> get sections => _catalogData?.driveData.sections ?? [];

  bool get hasSections => sections.isNotEmpty;

  Future<void> initialize({bool forceRefresh = false}) async {
    if (isReady && !forceRefresh) return;
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _catalogData = await repository.loadCatalog();
      isReady = true;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void refresh() => initialize(forceRefresh: true);

  CatalogProductEntry? productBySku(String sku) {
    final searchKey = sku.trim().toLowerCase();
    return _catalogData?.skuIndex[searchKey];
  }

  CatalogCategory? categoryById(String categoryId) {
    return _catalogData?.categoryIndex[categoryId];
  }

  CatalogSection? storeById(String storeId) {
    return _catalogData?.storeIndex[storeId];
  }

  List<CatalogProductEntry> searchProducts(String query) {
    final trimmed = query.trim().toLowerCase();
    if (_catalogData == null) return const [];

    final productLists = _catalogData!.driveData.sections
        .expand((section) => section.categories)
        .expand((category) => category.products);

    if (trimmed.isEmpty) {
      return productLists.toList();
    }

    return productLists
        .where((product) =>
            product.name.toLowerCase().contains(trimmed) ||
            product.sku.toLowerCase().contains(trimmed))
        .toList();
  }
}
