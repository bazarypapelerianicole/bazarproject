// ===========================================================================
// catalog_template.dart
// Catálogo 100% dinámico construido desde Google Drive (products.json /
// categories.json).  No contiene ninguna lista ni mapa estático de categorías.
// ===========================================================================

// ── Modelos ─────────────────────────────────────────────────────────────────

/// Producto mínimo expuesto en el catálogo público.
class CatalogProductEntry {
  final int id;
  final String name;
  final String sku;
  final double price;
  final int stock;

  const CatalogProductEntry({
    required this.id,
    required this.name,
    required this.sku,
    this.price = 0,
    this.stock = 0,
  });
}

/// Categoría con sus productos y metadatos de visualización.
class CatalogCategory {
  final int id;
  final String name;
  final int storeId;
  final String storeName;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final List<CatalogProductEntry> products;

  const CatalogCategory({
    required this.id,
    required this.name,
    required this.storeId,
    this.storeName = '',
    this.imageUrl = '',
    this.description = '',
    this.tags = const [],
    this.products = const [],
  });

  CatalogCategory copyWith({
    List<CatalogProductEntry>? products,
    String? imageUrl,
    String? description,
    List<String>? tags,
  }) => CatalogCategory(
    id: id,
    name: name,
    storeId: storeId,
    storeName: storeName,
    imageUrl: imageUrl ?? this.imageUrl,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    products: products ?? this.products,
  );
}

/// Sección del catálogo agrupada por tienda.
class CatalogSection {
  final int storeId;
  final String storeName;
  final List<CatalogCategory> categories;

  const CatalogSection({
    required this.storeId,
    required this.storeName,
    required this.categories,
  });
}

// ── Compatibilidad hacia atrás ───────────────────────────────────────────────

/// Alias de [CatalogCategory]. Mantiene compatibilidad con widgets existentes.
typedef CategoryInfo = CatalogCategory;

// ── Enum de tienda ───────────────────────────────────────────────────────────

enum CatalogStore {
  bazar(1, 'Bazar', 'Artículos de bazar, regalos y accesorios'),
  tienda(2, 'Tienda', 'Papelería, belleza, alimentos y productos varios');

  final int id;
  final String label;
  final String description;
  const CatalogStore(this.id, this.label, this.description);

  static CatalogStore? fromId(int id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return null;
  }
}

// ── Utilidades ───────────────────────────────────────────────────────────────

/// Retorna el nombre de la tienda a partir de su ID.
/// 1 → Bazar | 2 → Tienda | otro → General
String getStoreName(int storeId) {
  switch (storeId) {
    case 1:
      return 'Bazar';
    case 2:
      return 'Tienda';
    default:
      return 'General';
  }
}

/// Retorna el [CatalogStore] correspondiente a un [storeId], o null.
CatalogStore? storeFromId(int storeId) => CatalogStore.fromId(storeId);

// ── Servicio de construcción del catálogo ────────────────────────────────────

/// Construye las secciones del catálogo a partir de los datos crudos de Drive.
class CatalogBuilder {
  CatalogBuilder._();

  // ── Construcción desde JSON crudo ─────────────────────────────────────────

  /// Construye [CatalogSection]s a partir de los JSON sin procesar de Drive.
  ///
  /// - [productsJson]    → contenido de products.json
  /// - [categoriesJson]  → contenido de categories.json
  /// - [storesJson]      → contenido de stores.json (opcional)
  /// - [imageThumbnails] → mapa normalizedName→url de imágenes de Drive
  static List<CatalogSection> buildFromJson({
    required List<Map<String, dynamic>> productsJson,
    required List<Map<String, dynamic>> categoriesJson,
    List<Map<String, dynamic>> storesJson = const [],
    Map<String, String> imageThumbnails = const {},
  }) {
    // 1. Índice de categorías: id → datos raw
    final categoryIndex = <int, Map<String, dynamic>>{};
    for (final c in categoriesJson) {
      final id = (c['id'] as num?)?.toInt();
      if (id != null) categoryIndex[id] = c;
    }

    // 2. Índice de stores: id → name
    final storeNames = <int, String>{};
    for (final s in storesJson) {
      final id = (s['id'] as num?)?.toInt();
      final name = s['name'] as String?;
      if (id != null && name != null) storeNames[id] = name;
    }

    // 3. Agrupar productos por category_id
    final productsByCatId = <int, List<CatalogProductEntry>>{};
    for (final p in productsJson) {
      final id = (p['id'] as num?)?.toInt();
      final name = p['name'] as String?;
      final sku = p['sku'] as String? ?? '';
      final price = (p['price'] as num?)?.toDouble() ?? 0;
      final stock = (p['stock'] as num?)?.toInt() ?? 0;
      final categoryId = (p['category_id'] as num?)?.toInt();
      if (id == null || name == null || categoryId == null) continue;
      productsByCatId
          .putIfAbsent(categoryId, () => [])
          .add(
            CatalogProductEntry(
              id: id,
              name: name,
              sku: sku,
              price: price,
              stock: stock,
            ),
          );
    }

    // 4. Construir secciones agrupando por storeId
    final sectionMap = <int, List<CatalogCategory>>{};
    for (final entry in categoryIndex.entries) {
      final catId = entry.key;
      final catData = entry.value;
      final catName = catData['name'] as String? ?? 'Categoría $catId';
      final storeId = (catData['store_id'] as num?)?.toInt() ?? 0;
      final storeName = storeNames[storeId] ?? getStoreName(storeId);
      final prods = productsByCatId[catId] ?? const [];
      final imageUrl = _findImage(imageThumbnails, catName);
      sectionMap
          .putIfAbsent(storeId, () => [])
          .add(
            CatalogCategory(
              id: catId,
              name: catName,
              storeId: storeId,
              storeName: storeName,
              imageUrl: imageUrl,
              products: prods,
            ),
          );
    }

    // Ordenar categorías alfabéticamente dentro de cada sección
    for (final list in sectionMap.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    return _toSections(sectionMap);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<CatalogSection> _toSections(
    Map<int, List<CatalogCategory>> sectionMap,
  ) {
    // storeId 0 (General) al final; el resto en orden ascendente
    final storeIds = sectionMap.keys.toList()
      ..sort((a, b) {
        if (a == 0) return 1;
        if (b == 0) return -1;
        return a.compareTo(b);
      });
    return [
      for (final id in storeIds)
        CatalogSection(
          storeId: id,
          storeName: getStoreName(id),
          categories: sectionMap[id]!,
        ),
    ];
  }

  static String _findImage(Map<String, String> thumbnails, String catName) {
    if (thumbnails.isEmpty) return '';
    final key = _normalize(catName);
    if (thumbnails.containsKey(key)) return thumbnails[key]!;
    for (final e in thumbnails.entries) {
      if (e.key.contains(key) || key.contains(e.key)) return e.value;
    }
    return '';
  }

  static String _normalize(String s) {
    const a = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const b = 'aaaaaeeeeiiiioooooouuuunc';
    var r = s.toLowerCase().trim();
    for (int i = 0; i < a.length; i++) {
      r = r.replaceAll(a[i], b[i]);
    }
    return r;
  }

  /// Devuelve la sección correspondiente a un [storeId], o null si no existe.
  static CatalogSection? sectionFor(
    List<CatalogSection> sections,
    int storeId,
  ) {
    for (final s in sections) {
      if (s.storeId == storeId) return s;
    }
    return null;
  }

  /// Devuelve todos los productos de una sección en una lista plana.
  static List<CatalogProductEntry> flatProducts(CatalogSection section) => [
    for (final c in section.categories) ...c.products,
  ];
}

// ── Modelo legado — mantiene compatibilidad de compilación ───────────────────
@Deprecated('Usar CatalogProductEntry + CatalogCategory en su lugar.')
class CatalogItem {
  final String name;
  final String category;
  final double price;
  final String store;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final bool available;

  const CatalogItem({
    required this.name,
    required this.category,
    required this.price,
    required this.store,
    this.description = '',
    this.imageUrl = '',
    this.tags = const [],
    this.available = true,
  });
}
