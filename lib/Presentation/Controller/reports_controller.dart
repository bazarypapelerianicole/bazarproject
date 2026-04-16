import 'package:bazarnicole/Presentation/Services/database_service.dart';
import 'package:flutter/foundation.dart';

class ReportsController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic> salesToday = const {};
  List<Map<String, dynamic>> salesByStore = [];
  List<Map<String, dynamic>> topProducts = [];

  int get salesCountToday => ((salesToday['sales_count'] as num?)?.toInt()) ?? 0;
  double get totalToday => ((salesToday['total'] as num?)?.toDouble()) ?? 0;

  Future<void> initialize() async {
    if (isLoading || salesByStore.isNotEmpty || topProducts.isNotEmpty) return;
    await loadReports();
  }

  Future<void> loadReports() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await DatabaseService.getReportsSnapshot();
      salesToday = Map<String, dynamic>.from(
        snapshot['salesToday'] as Map<String, dynamic>,
      );
      salesByStore = List<Map<String, dynamic>>.from(
        snapshot['salesByStore'] as List,
      );
      topProducts = List<Map<String, dynamic>>.from(
        snapshot['topProducts'] as List,
      );
    } catch (e) {
      errorMessage = 'No se pudieron cargar los reportes: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
