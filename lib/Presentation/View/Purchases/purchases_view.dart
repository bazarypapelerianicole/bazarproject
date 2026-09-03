import 'package:bazarnicole/Presentation/Controller/purchases_controller.dart';
import 'package:bazarnicole/Presentation/Renders/responsive_helper.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'new_purchase_tab.dart';
import 'purchase_history_tab.dart';

class PurchasesView extends StatefulWidget {
  const PurchasesView({super.key});

  @override
  State<PurchasesView> createState() => _PurchasesViewState();
}

class _PurchasesViewState extends State<PurchasesView> {
  final _searchController = TextEditingController();
  final _supplierController = TextEditingController();
  final _supplierPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchasesController>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _supplierController.dispose();
    _supplierPhoneController.dispose();
    super.dispose();
  }

  Future<void> _savePurchase() async {
    final controller = context.read<PurchasesController>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final purchaseId = await controller.savePurchase(
        supplierName: _supplierController.text.trim(),
        supplierPhone: _supplierPhoneController.text.trim(),
      );

      _supplierController.clear();
      _supplierPhoneController.clear();

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Compra registrada correctamente #$purchaseId')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = ResponsiveHelper.getAppBarHeight(context) + 48;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.blackOverlay,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 4,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.whiteOverlay,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Compras · Abastecimiento',
                  style: TextStyle(fontSize: 16, color: AppColors.whiteOverlay),
                ),
                bottom: TabBar(
                  labelColor: _searchController.text.isEmpty
                      ? AppColors.whiteOverlay
                      : AppColors.mediumGray,
                  unselectedLabelColor: _searchController.text.isEmpty
                      ? AppColors.mediumGray
                      : AppColors.whiteOverlay,
                  unselectedLabelStyle: TextStyle(
                    color: _searchController.text.isEmpty
                        ? AppColors.mediumGray
                        : AppColors.whiteOverlay,
                  ),
                  indicatorColor: AppColors.whiteOverlay,
                  tabs: const [
                    Tab(
                      text: 'Nueva compra',
                      icon: Icon(Icons.add),
                    ),
                    Tab(
                      text: 'Historial de compras',
                      icon: Icon(Icons.history_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            NewPurchaseTab(
              searchController: _searchController,
              supplierController: _supplierController,
              supplierPhoneController: _supplierPhoneController,
              onSave: _savePurchase,
            ),
            const PurchaseHistoryTab(),
          ],
        ),
      ),
    );
  }
}
