class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double costPrice;
  final int quantity;
  final int minStock;
  final String? category;
  final String? barcode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.costPrice,
    required this.quantity,
    required this.minStock,
    this.category,
    this.barcode,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Calcula el margen de ganancia
  double get profitMargin {
    if (costPrice == 0) return 0;
    return ((price - costPrice) / costPrice) * 100;
  }

  /// Verifica si está bajo stock
  bool get isLowStock => quantity <= minStock;

  /// Valor total del inventario
  double get totalInventoryValue => quantity * costPrice;

  /// Crea una copia con cambios
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? costPrice,
    int? quantity,
    int? minStock,
    String? category,
    String? barcode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte de Map a Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      costPrice: (map['costPrice'] ?? map['cost_price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      minStock: (map['minStock'] ?? map['min_stock'] as num?)?.toInt() ?? 0,
      category: map['category'] as String?,
      barcode: map['barcode'] as String?,
      isActive: (map['isActive'] ?? map['is_active'] as bool?) ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convierte Product a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'quantity': quantity,
      'min_stock': minStock,
      'category': category,
      'barcode': barcode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}
