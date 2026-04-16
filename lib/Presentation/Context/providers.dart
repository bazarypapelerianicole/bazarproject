import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_provider.dart';
import 'customer_provider.dart';
import 'sale_provider.dart';
import 'purchase_provider.dart';

/// Centro de control de todos los Providers
/// Usar en main.dart con MultiProvider
class AppProviders {
  static List<ChangeNotifierProvider<ChangeNotifier>> getProviders() => [
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => CustomerProvider()),
    ChangeNotifierProvider(create: (_) => SaleProvider()),
    ChangeNotifierProvider(create: (_) => PurchaseProvider()),
  ];
}

/// Para acceder fácilmente desde las vistas
extension ProviderAccess on BuildContext {
  ProductProvider get productProvider =>
      read<ProductProvider>();

  CustomerProvider get customerProvider =>
      read<CustomerProvider>();

  SaleProvider get saleProvider =>
      read<SaleProvider>();

  PurchaseProvider get purchaseProvider =>
      read<PurchaseProvider>();

  // Watchers (para rebuild automático)
  ProductProvider watchProductProvider() =>
      watch<ProductProvider>();

  CustomerProvider watchCustomerProvider() =>
      watch<CustomerProvider>();

  SaleProvider watchSaleProvider() =>
      watch<SaleProvider>();

  PurchaseProvider watchPurchaseProvider() =>
      watch<PurchaseProvider>();
}
