# 📦 Estructura Completa: Context, Hooks y Modelos

## ✅ Resumen de lo que se ha creado

### 1️⃣ **MODELS** (Clases de Datos Tipadas)

Ubicación: `lib/Presentation/Model/`

| Archivo               | Descripción                                                   |
| --------------------- | ------------------------------------------------------------- |
| `product_model.dart`  | Producto con cálculos de margen, stock bajo, valor inventario |
| `customer_model.dart` | Cliente con datos de crédito, compras, ticket promedio        |
| `sale_model.dart`     | Venta completa con items, métodos de pago, enums              |
| `purchase_model.dart` | Compra con estado, items recibidos, saldo pendiente           |

**Características:**

- ✅ Conversión `toMap()` / `fromMap()`
- ✅ `copyWith()` para copias inmutables
- ✅ Propiedades calculadas
- ✅ Enums para estados (PaymentMethod, SaleStatus, PurchaseStatus)

---

### 2️⃣ **HOOKS** (Funciones Reutilizables)

Ubicación: `lib/Presentation/Hooks/`

| Archivo                       | Funciones                                                   |
| ----------------------------- | ----------------------------------------------------------- |
| `use_form_validation.dart`    | Validadores para email, teléfono, precio, cantidad, barcode |
| `use_currency_formatter.dart` | Formateo de moneda, cálculo de impuestos, descuentos        |
| `use_date_formatter.dart`     | Formateo de fechas, diferencias, nombres de días            |
| `use_search_and_filter.dart`  | Debounce, búsqueda, filtrado, ordenamiento                  |

**Ejemplo rápido:**

```dart
// Validación
FormValidator.validateEmail('email@example.com')

// Moneda
CurrencyFormatter.formatCurrency(1250.75) // \$1,250.75
CurrencyFormatter.calculateTax(100) // 19.00

// Fecha
DateFormatter.formatDate(DateTime.now()) // 16/04/2026
DateFormatter.getTimeAgo(DateTime.now()) // Hace 5 minutos

// Búsqueda
searchHook.search(query, (q) { /* buscar */ })
```

---

### 3️⃣ **CONTEXT PROVIDERS** (State Management)

Ubicación: `lib/Presentation/Context/`

| Proveedor          | Responsabilidad                                     |
| ------------------ | --------------------------------------------------- |
| `ProductProvider`  | Gestionar productos, búsqueda, filtrado, stock bajo |
| `CustomerProvider` | CRUD clientes, búsqueda, historial                  |
| `SaleProvider`     | Carrito, procesamiento de ventas, historial         |
| `PurchaseProvider` | Órdenes de compra, recepción de items               |
| `providers.dart`   | Exportación centralizada + extensiones              |

**Características por Provider:**

- ✅ Búsqueda/filtrado integrado
- ✅ Manejo de errores
- ✅ Loading state
- ✅ Métodos auxiliares (totales, resúmenes)

---

## 🚀 Guía de Uso Rápido

### Paso 1: Configurar en main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  runApp(
    MultiProvider(
      providers: AppProviders.getProviders(),
      child: const MyApp(),
    ),
  );
}
```

### Paso 2: Usar en Views

```dart
class MyView extends StatefulWidget {
  @override
  State<MyView> createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  @override
  void initState() {
    super.initState();
    // Inicializar providers
    Future.microtask(() {
      context.productProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          itemCount: provider.filteredProducts.length,
          itemBuilder: (context, index) {
            final product = provider.filteredProducts[index];
            return ListTile(
              title: Text(product.name),
              trailing: Text(
                CurrencyFormatter.formatCurrency(product.price),
              ),
            );
          },
        );
      },
    );
  }
}
```

### Paso 3: Acceso fácil con extensiones

```dart
// Lectura simple (no rebuild)
context.productProvider.loadProducts();

// Watch (rebuild automático)
context.watchProductProvider().filteredProducts;

// Uso de hooks
FormValidator.validatePrice('100.50')
DateFormatter.formatDate(DateTime.now())
CurrencyFormatter.formatCurrency(1000.0)
```

---

## 📊 Estructura de Carpetas

```
lib/Presentation/
├── Model/
│   ├── product_model.dart          ✅
│   ├── customer_model.dart         ✅
│   ├── sale_model.dart             ✅
│   └── purchase_model.dart         ✅
├── Hooks/
│   ├── use_form_validation.dart    ✅
│   ├── use_currency_formatter.dart ✅
│   ├── use_date_formatter.dart     ✅
│   └── use_search_and_filter.dart  ✅
├── Context/
│   ├── product_provider.dart       ✅
│   ├── customer_provider.dart      ✅
│   ├── sale_provider.dart          ✅
│   ├── purchase_provider.dart      ✅
│   └── providers.dart              ✅
├── View/
│   └── ... (tus vistas actuales)
├── Controller/
│   └── ... (puedes eliminar/refactorizar)
└── Services/
    ├── database_service.dart       (existente)
    └── ... (otros servicios)
```

---

## 🔴 TODOs Pendientes

### En DatabaseService

```dart
// Crear métodos para:
static Future<void> createSale({...}) // Crear nueva venta
static Future<void> createPurchase({...}) // Crear compra
static Future<void> updatePurchaseStatus({...}) // Actualizar estado
static Future<void> updateCustomer({...}) // Actualizar cliente
```

### En Views (por hacer)

- Refactorizar Dashboard para usar DashboardProvider
- Refactorizar POS para usar SaleProvider
- Refactorizar CustomersView para usar CustomerProvider
- Refactorizar ProductManagement para usar ProductProvider
- Refactorizar Purchases para usar PurchaseProvider

---

## 📚 Archivos de Documentación

1. **GUIA_CONTEXT_HOOKS_MODELS.md** → Guía completa de uso
2. **EJEMPLOS_POR_PANTALLA.md** → Ejemplos por cada pantalla
3. **README.md** (este archivo) → Visión general

---

## 💡 Mejores Prácticas

### ✅ Hacer

```dart
// Usar extensiones para acceso fácil
context.productProvider.loadProducts();

// Usar Consumer para widgets que necesitan rebuild
Consumer<ProductProvider>(
  builder: (context, provider, _) { ... }
)

// Validar antes de procesar
if (FormValidator.validateEmail(email) == null) { ... }

// Usar los formatters correctamente
CurrencyFormatter.formatCurrency(amount)
DateFormatter.formatDate(date)
```

### ❌ No hacer

```dart
// No mezclar lógica en widgets
// ❌ Hacer cálculos en build()

// No usar read() si necesitas rebuild
// ❌ Provider.of<ProductProvider>(context, listen: false)

// No crear providers manualmente
// ✅ Usar MultiProvider con AppProviders.getProviders()

// No ignorar errorMessage
// ✅ Mostrar siempre provider.errorMessage en UI
```

---

## 🎯 Plan de Refactorización de Views

### Fase 1: Models y Hooks

✅ **COMPLETADO**

- Crear modelos tipados
- Crear hooks reutilizables

### Fase 2: Providers

✅ **COMPLETADO**

- Crear context providers
- Integrar con DatabaseService

### Fase 3: Actualizar Views (PRÓXIMO)

- [ ] Dashboard → Usar DashboardProvider (crear)
- [ ] POS → Usar SaleProvider
- [ ] Customers → Usar CustomerProvider
- [ ] Products → Usar ProductProvider
- [ ] Purchases → Usar PurchaseProvider
- [ ] Inventory → Usar InventoryProvider (crear)
- [ ] Cash → Usar CashProvider (crear)
- [ ] Reports → Usar ReportsProvider (crear)

### Fase 4: Testing

- [ ] Tests unitarios para Providers
- [ ] Tests de integración

---

## 🔗 Referencias

- Documentación de Provider: https://pub.dev/packages/provider
- Flutter State Management: https://flutter.dev/docs/development/data-and-backend/state-mgmt
- Intl para localización: https://pub.dev/packages/intl

---

## 📞 Soporte

Si tienes dudas sobre:

- **Models**: Ver `lib/Presentation/Model/`
- **Hooks**: Ver `lib/Presentation/Hooks/`
- **Providers**: Ver `lib/Presentation/Context/`
- **Ejemplos**: Ver `EJEMPLOS_POR_PANTALLA.md`
- **Guía completa**: Ver `GUIA_CONTEXT_HOOKS_MODELS.md`

---

**Creado**: 16 de abril de 2026
**Versión**: 1.0
**Estado**: ✅ Completo (excepto TODOs en DatabaseService)
