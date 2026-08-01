import 'package:flutter_test/flutter_test.dart';
import 'package:bazarnicole/Presentation/Services/database_service.dart';

void main() {
  test('builds product filters for search, store, and category', () {
    final result = DatabaseService.buildProductQueryFilters(
      search: 'pan',
      storeId: 3,
      category: 'Bebidas',
    );

    expect(result.whereClause, contains('p.store_id = ?'));
    expect(result.whereClause, contains("COALESCE(c.name, '') LIKE ?"));
    expect(result.params, containsAll(<Object?>['%pan%', 3, '%Bebidas%']));
  });

  test('skips empty filters', () {
    final result = DatabaseService.buildProductQueryFilters();

    expect(result.whereClause, isEmpty);
    expect(result.params, isEmpty);
  });
}
