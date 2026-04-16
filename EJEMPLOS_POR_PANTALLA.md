# 🎯 Ejemplos de Integración por Pantalla

## 📋 Tabla de Contenidos

- [🎯 Ejemplos de Integración por Pantalla](#-ejemplos-de-integración-por-pantalla)
  - [📋 Tabla de Contenidos](#-tabla-de-contenidos)
  - [Dashboard](#dashboard)
  - [POS / Ventas](#pos--ventas)
  - [Clientes (CRM)](#clientes-crm)
  - [Productos](#productos)
  - [Compras](#compras)
  - [Inventario](#inventario)
  - [Caja](#caja)
  - [Reportes](#reportes)
  - [🔗 Integración en main.dart](#-integración-en-maindart)
  - [⚙️ Uso de FormValidator](#️-uso-de-formvalidator)
  - [📌 Notas Importantes](#-notas-importantes)
  - [🚀 Próximos Pasos](#-próximos-pasos)

---

## Dashboard

**Uso:** Ver resumen de negocio, acceso rápido a pantallas

**Providers necesarios:** ProductProvider, SaleProvider, PurchaseProvider

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bazarnicole/Presentation/Context/providers.dart';
import 'package:bazarnicole/Presentation/Hooks/use_currency_formatter.dart';
import 'package:bazarnicole/Presentation/Hooks/use_date_formatter.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Inicializar todos los providers
    Future.microtask(() {
      context.productProvider.initialize();
      context.saleProvider.initialize();
      context.purchaseProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tarjeta de ventas del día
            Consumer<SaleProvider>(
              builder: (context, saleProvider, _) {
                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ventas del Día',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.formatCurrency(
                            saleProvider.todayTotal,
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${saleProvider.todaySales.length} transacciones',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Tarjeta de inventario
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Productos'),
                                Text(
                                  '${productProvider.products.length}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Stock Bajo'),
                                Text(
                                  '${productProvider.lowStockCount}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Valor Total'),
                                Text(
                                  CurrencyFormatter.formatCurrencyNoSymbol(
                                    productProvider.totalInventoryValue,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## POS / Ventas

**Uso:** Procesar ventas, gestionar carrito

**Providers necesarios:** SaleProvider, ProductProvider, CustomerProvider

```dart
class PosView extends StatefulWidget {
  @override
  _PosViewState createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.saleProvider.initialize();
      context.productProvider.initialize();
      context.customerProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS')),
      body: Row(
        children: [
          // Panel de productos (izquierda)
          Expanded(
            flex: 2,
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: productProvider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.filteredProducts[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          // Añadir al carrito
                          context.saleProvider.addToCart(
                            product.id,
                            product.name,
                            1,
                            product.price,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.formatCurrency(product.price),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Panel del carrito (derecha)
          Expanded(
            flex: 1,
            child: Consumer<SaleProvider>(
              builder: (context, saleProvider, _) {
                return Column(
                  children: [
                    const Text(
                      'Carrito',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: saleProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = saleProvider.cartItems[index];
                          return ListTile(
                            title: Text(item.productName),
                            subtitle: Text(
                              '${item.quantity} x ${CurrencyFormatter.formatCurrency(item.unitPrice)}',
                            ),
                            trailing: Text(
                              CurrencyFormatter.formatCurrency(
                                item.totalPrice,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: ${CurrencyFormatter.formatCurrency(saleProvider.cartTotal)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Procesar venta
                              _showPaymentDialog(context);
                            },
                            child: const Text('Procesar Venta'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Método de Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: PaymentMethod.values
                .map((method) {
                  return ListTile(
                    title: Text(method.display),
                    onTap: () {
                      Navigator.pop(context);
                      // Procesar con el método de pago seleccionado
                      // context.saleProvider.processSale(
                      //   customerId: 1,
                      //   storeId: 1,
                      //   paymentMethod: method,
                      // );
                    },
                  );
                })
                .toList(),
          ),
        );
      },
    );
  }
}
```

---

## Clientes (CRM)

**Uso:** Gestionar clientes, ver historial de compras

**Providers necesarios:** CustomerProvider

```dart
class CustomersView extends StatefulWidget {
  @override
  _CustomersViewState createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.customerProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCustomerDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.customerProvider.loadCustomers(searchValue: value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o teléfono...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Lista de clientes
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, _) {
                if (customerProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (customerProvider.filteredCustomers.isEmpty) {
                  return const Center(child: Text('No hay clientes'));
                }

                return ListView.builder(
                  itemCount: customerProvider.filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = customerProvider.filteredCustomers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(customer.name),
                        subtitle: Text(
                          customer.email ?? customer.phone ?? 'Sin contacto',
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatCurrency(
                            customer.totalSpent,
                          ),
                        ),
                        onTap: () {
                          context.customerProvider.selectCustomer(customer);
                          _showCustomerDetail(context, customer);
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
    );
  }

  void _showAddCustomerDialog() {
    final _formKey = GlobalKey<FormState>();
    String _name = '';
    String? _email;
    String? _phone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Cliente'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onChanged: (value) => _name = value,
                    validator: (value) =>
                        FormValidator.validateName(value),
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => _email = value,
                    validator: (value) =>
                        FormValidator.validateEmail(value),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => _phone = value,
                    validator: (value) =>
                        FormValidator.validatePhone(value),
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.customerProvider.createCustomer(
                    name: _name,
                    email: _email,
                    phone: _phone,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerDetail(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(customer.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Email', customer.email ?? 'N/A'),
                _buildDetailRow('Teléfono', customer.phone ?? 'N/A'),
                _buildDetailRow('Total Gastado',
                    CurrencyFormatter.formatCurrency(customer.totalSpent)),
                _buildDetailRow('Compras', '${customer.totalPurchases}'),
                _buildDetailRow('Ticket Promedio',
                    CurrencyFormatter.formatCurrency(customer.averageTicket)),
                if (customer.hasBalance)
                  _buildDetailRow('Crédito Disponible',
                      CurrencyFormatter.formatCurrency(customer.balance)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

---

## Productos

**Uso:** Gestionar catálogo de productos

**Providers necesarios:** ProductProvider

**Ejemplo simplificado - ver GUIA_CONTEXT_HOOKS_MODELS.md para ejemplo completo**

---

## Compras

**Uso:** Crear órdenes de compra, recibir inventario

**Providers necesarios:** PurchaseProvider, ProductProvider

```dart
class PurchasesView extends StatefulWidget {
  @override
  _PurchasesViewState createState() => _PurchasesViewState();
}

class _PurchasesViewState extends State<PurchasesView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.purchaseProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showNewPurchaseDialog,
          ),
        ],
      ),
      body: Consumer<PurchaseProvider>(
        builder: (context, purchaseProvider, _) {
          if (purchaseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: purchaseProvider.purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchaseProvider.purchases[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(purchase.supplierName),
                  subtitle: Text(
                    DateFormatter.formatDate(purchase.orderDate),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatCurrency(purchase.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text(
                          purchase.status.display,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showNewPurchaseDialog() {
    // Implementar diálogo para nueva compra
    // Usar purchaseProvider.addOrderItem() para gestionar items
  }
}
```

---

## Inventario

**Uso:** Ver stock de productos por tienda, ajustar inventario

**Providers necesarios:** ProductProvider

---

## Caja

**Uso:** Registro de caja, arqueo de caja

**Providers necesarios:** SaleProvider

---

## Reportes

**Uso:** Análisis de ventas, compras, rentabilidad

**Providers necesarios:** ProductProvider, SaleProvider, PurchaseProvider

---

## 🔗 Integración en main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);

  // ... tu código de inicialización ...

  runApp(
    MultiProvider(
      providers: AppProviders.getProviders(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BazarNicole',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardPage(),
      // ... tu configuración de rutas ...
    );
  }
}
```

---

## ⚙️ Uso de FormValidator

```dart
import 'package:bazarnicole/Presentation/Hooks/use_form_validation.dart';

TextFormField(
  validator: (value) => FormValidator.validateEmail(value),
  decoration: const InputDecoration(labelText: 'Email'),
),

TextFormField(
  validator: (value) => FormValidator.validatePrice(value),
  decoration: const InputDecoration(labelText: 'Precio'),
),

TextFormField(
  validator: (value) => FormValidator.validate(
    value,
    fieldName: 'Nombre del Producto',
    required: true,
    minLength: 3,
    maxLength: 100,
  ),
  decoration: const InputDecoration(labelText: 'Nombre'),
),
```

---

## 📌 Notas Importantes

1. **Inicialización**: Siempre llama a `provider.initialize()` en `initState()`
2. **Errores**: Verifica `provider.errorMessage` en tu UI
3. **Loading**: Usa `provider.isLoading` para mostrar spinners
4. **Listener**: Usa `Consumer<ProviderName>` para reconstruir widgets automáticamente
5. **Performance**: Los Providers solo notifican cuando cambian los datos

---

## 🚀 Próximos Pasos

1. Copia estos ejemplos en tus vistas
2. Ajusta según tu diseño actual
3. Extiende los modelos con campos adicionales si es necesario
4. Implementa los métodos TODO en DatabaseService
