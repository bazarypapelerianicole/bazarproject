# 📚 Guía de Uso: Context, Hooks y Modelos

## 🎯 Estructura de Archivos

```
lib/Presentation/
├── Model/                 # Clases de datos tipadas
│   ├── product_model.dart
│   ├── customer_model.dart
│   ├── sale_model.dart
│   └── purchase_model.dart
├── Hooks/                 # Funciones reutilizables
│   ├── use_form_validation.dart
│   ├── use_currency_formatter.dart
│   ├── use_date_formatter.dart
│   └── use_search_and_filter.dart
└── Context/              # State Management (Providers)
    ├── product_provider.dart
    ├── customer_provider.dart
    ├── sale_provider.dart
    ├── purchase_provider.dart
    └── providers.dart    # Exportación centralizada
```

---

## 🔧 Configuración en main.dart

```dart
import 'package:bazarnicole/Presentation/Context/providers.dart';
import 'package:provider/provider.dart';

void main() async {
  // ... tu código existente ...

  runApp(
    MultiProvider(
      providers: AppProviders.getProviders(),
      child: const MyApp(),
    ),
  );
}
```

---

## 📦 Cómo Usar los Models

### Ejemplo: Producto

```dart
import 'package:bazarnicole/Presentation/Model/product_model.dart';

// Crear un producto
final product = Product(
  id: 1,
  name: 'Laptop',
  price: 1200.0,
  costPrice: 800.0,
  quantity: 5,
  minStock: 2,
  category: 'Electrónica',
  createdAt: DateTime.now(),
);

// Acceder a propiedades calculadas
print(product.profitMargin);      // 50%
print(product.isLowStock);         // false
print(product.totalInventoryValue); // 4000

// Copiar con cambios
final updatedProduct = product.copyWith(
  price: 1300.0,
  quantity: 3,
);

// Convertir a/desde Map
final map = product.toMap();
final productFromMap = Product.fromMap(map);
```

---

## 🎨 Cómo Usar los Hooks

### 1️⃣ Validación de Formularios

```dart
import 'package:bazarnicole/Presentation/Hooks/use_form_validation.dart';

final formKey = GlobalKey<FormState>();

TextFormField(
  validator: (value) => FormValidator.validateEmail(value),
  decoration: const InputDecoration(labelText: 'Email'),
),

TextFormField(
  validator: (value) => FormValidator.validatePrice(value),
  decoration: const InputDecoration(labelText: 'Precio'),
),
```

### 2️⃣ Formateo de Moneda

```dart
import 'package:bazarnicole/Presentation/Hooks/use_currency_formatter.dart';

final price = 1250.75;
print(CurrencyFormatter.formatCurrency(price));       // \$1,250.75
print(CurrencyFormatter.formatCurrencyNoSymbol(price)); // 1.250,75

final tax = CurrencyFormatter.calculateTax(price);    // 237.64
final total = CurrencyFormatter.calculateTotalWithTax(price); // 1488.39

final discounted = CurrencyFormatter.calculateTotalWithDiscount(price, 10); // 1125.68
```

### 3️⃣ Formateo de Fechas

```dart
import 'package:bazarnicole/Presentation/Hooks/use_date_formatter.dart';

final date = DateTime.now();

print(DateFormatter.formatDate(date));           // 16/04/2026
print(DateFormatter.formatDateTime(date));       // 16/04/2026 14:30
print(DateFormatter.formatFullDate(date));       // miércoles, 16 abril 2026
print(DateFormatter.getTimeAgo(date));           // Hace 5 minutos

print(DateFormatter.isToday(date));              // true
print(DateFormatter.getDayName(date));           // miércoles
```

### 4️⃣ Búsqueda con Debounce

```dart
import 'package:bazarnicole/Presentation/Hooks/use_search_and_filter.dart';

final searchHook = SearchDebounceHook();

// En un TextField
TextField(
  onChanged: (query) {
    searchHook.search(query, (searchQuery) {
      // Llamar API o filtrar datos
      print('Buscando: $searchQuery');
    });
  },
);

// Escuchar cambios
Consumer<SearchDebounceHook>(
  builder: (context, hook, _) {
    if (hook.isSearching) {
      return CircularProgressIndicator();
    }
    return Text('Busca: ${hook.searchQuery}');
  },
)
```

---

## 🌍 Cómo Usar los Providers (Context)

### Product Provider

```dart
import 'package:bazarnicole/Presentation/Context/providers.dart';

class ProductListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.productProvider.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return Consumer<ProductProvider>(
          builder: (context, provider, _) {
            return ListView.builder(
              itemCount: provider.filteredProducts.length,
              itemBuilder: (context, index) {
                final product = provider.filteredProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                  ),
                  trailing: product.isLowStock
                      ? const Chip(label: Text('Stock bajo'))
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }
}
```

### Crear Producto

```dart
Future<void> _createProduct(BuildContext context) async {
  await context.productProvider.createProduct(
    name: 'Nuevo Producto',
    price: 99.99,
    costPrice: 50.0,
    minStock: 5,
    category: 'Electrónica',
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Producto creado')),
  );
}
```

### Sale Provider (POS)

```dart
final saleProvider = context.saleProvider;

// Añadir al carrito
saleProvider.addToCart(
  productId: 1,
  productName: 'Laptop',
  quantity: 2,
  unitPrice: 1200.0,
);

// Ver total
Text('Total: \$${saleProvider.cartTotal.toStringAsFixed(2)}')

// Procesar venta
await saleProvider.processSale(
  customerId: 1,
  storeId: 1,
  paymentMethod: PaymentMethod.card,
  paymentReference: '12345',
  discount: 50.0,
  tax: 237.64,
);
```

---

## 📱 Ejemplo Completo: Pantalla de Productos

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bazarnicole/Presentation/Context/providers.dart';
import 'package:bazarnicole/Presentation/Hooks/use_search_and_filter.dart';
import 'package:bazarnicole/Presentation/Hooks/use_currency_formatter.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late SearchDebounceHook _searchHook;

  @override
  void initState() {
    super.initState();
    _searchHook = SearchDebounceHook();
    // Inicializar productos
    Future.microtask(() {
      context.productProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) {
                _searchHook.search(query, (searchQuery) {
                  context.productProvider.loadProducts(
                    searchValue: searchQuery,
                  );
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Lista de productos
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('No hay productos'),
                  );
                }

                return ListView.builder(
                  itemCount: provider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = provider.filteredProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          'Stock: ${product.quantity} | Costo: ${CurrencyFormatter.formatCurrency(product.costPrice)}',
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatCurrency(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          provider.selectProduct(product);
                          // Navegar a detalle
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mostrar diálogo para crear producto
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## ⚠️ Notas Importantes

1. **DatabaseService**: Los métodos del provider usan `DatabaseService`. Necesitas verificar que existan:
   - `getProducts()`, `createProduct()`, `updateProduct()`, `deleteProduct()`
   - `getCustomers()`, `createCustomer()`, `updateCustomer()`
   - `getSales()`, `createSale()`
   - `getPurchases()`, `createPurchase()`

2. **Error Handling**: Siempre verifica `provider.errorMessage` en tu UI

3. **Refresh**: Usa `await provider.initialize()` al entrar a una pantalla

4. **Performance**: Los Providers usan `ChangeNotifier` para eficiencia

---

## 🔄 Próximos Pasos

1. Ajusta los métodos de `DatabaseService` en los Providers
2. Crea vistas para cada pantalla usando los Providers
3. Integra los Hooks en formularios y listas
4. Añade más modelos según necesites (Inventory, CashRegister, Reports, etc.)

---

## 📖 Referencias

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- Intl Package para localización
