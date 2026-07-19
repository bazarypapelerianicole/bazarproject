import 'package:flutter_test/flutter_test.dart';
import 'package:bazarnicole/Presentation/Services/database_config.dart';

void main() {
  test('DatabaseConfig usa el nombre unificado de base de datos', () {
    expect(DatabaseConfig.dbName, 'bazarnicole.db');
  });
}
