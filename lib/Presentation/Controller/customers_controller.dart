import 'package:bazarnicole/Presentation/Services/database_service.dart';
import 'package:flutter/foundation.dart';

class CustomersController extends ChangeNotifier {
  CustomersController() {
    DatabaseService.addDatabaseListener(_handleDatabaseChanged);
  }

  bool isLoading = false;
  String? errorMessage;
  String search = '';

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> history = [];
  Map<String, dynamic>? selectedCustomer;

  void _handleDatabaseChanged() {
    if (!isLoading) {
      loadCustomers();
    }
  }

  @override
  void dispose() {
    DatabaseService.removeDatabaseListener(_handleDatabaseChanged);
    super.dispose();
  }

  Future<void> initialize() async {
    if (isLoading || customers.isNotEmpty) return;
    await loadCustomers();
  }

  Future<void> loadCustomers({String searchValue = ''}) async {
    isLoading = true;
    search = searchValue;
    errorMessage = null;
    notifyListeners();

    try {
      customers = await DatabaseService.getCustomers(search: searchValue);
      if (selectedCustomer != null) {
        await selectCustomer(selectedCustomer!);
      }
    } catch (e) {
      errorMessage = 'No se pudo cargar el CRM: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> createCustomer({
    required String name,
    String? uid,
    String? phone,
    String? email,
    String? notes,
    String? apellidos,
    String? cedula,
    String? address,
    String? referencias,
  }) async {
    final savedUid = await DatabaseService.createCustomer(
      name: name,
      uid: uid,
      phone: phone,
      email: email,
      notes: notes,
      apellidos: apellidos,
      cedula: cedula,
      address: address,
      referencias: referencias,
    );
    await loadCustomers(searchValue: search);
    return savedUid;
  }

  Future<void> selectCustomer(Map<String, dynamic> customer) async {
    selectedCustomer = customer;
    history = await DatabaseService.getCustomerHistory(
      (customer['id'] as num).toInt(),
    );
    notifyListeners();
  }

  Future<void> updateCustomer({
    required int id,
    required String name,
    String? uid,
    String? phone,
    String? email,
    String? notes,
    String? apellidos,
    String? cedula,
    String? address,
    String? referencias,
  }) async {
    await DatabaseService.updateCustomer(
      id: id,
      name: name,
      uid: uid,
      phone: phone,
      email: email,
      notes: notes,
      apellidos: apellidos,
      cedula: cedula,
      address: address,
      referencias: referencias,
    );
    selectedCustomer = null;
    await loadCustomers(searchValue: search);
  }

  Future<void> deleteCustomer(int id) async {
    await DatabaseService.deleteCustomer(id);
    if (selectedCustomer?['id'] == id) {
      selectedCustomer = null;
      history = [];
    }
    await loadCustomers(searchValue: search);
  }
}
