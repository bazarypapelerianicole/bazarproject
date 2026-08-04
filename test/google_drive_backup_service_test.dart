import 'package:flutter_test/flutter_test.dart';
import 'package:bazarnicole/Presentation/Services/google_drive_backup_service.dart';

void main() {
  group('GoogleDriveBackupService backup filenames', () {
    test('maps inventory table to stock.json', () {
      expect(
        GoogleDriveBackupService.backupFileNameForTable('inventory'),
        'stock.json',
      );
    });

    test('keeps the existing mapping for products', () {
      expect(
        GoogleDriveBackupService.backupFileNameForTable('products'),
        'productos.json',
      );
    });
  });
}
