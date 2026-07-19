import 'dart:io';
import 'package:bazarnicole/Presentation/Services/database_service.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import '../Services/database_config.dart';
import '../Services/database_location_service.dart';

/// Inicialización de base de datos para entornos nativos (desktop, mobile).
Future<void> initializeDatabasePlatform() async {
  // Desktop: habilitar sqflite FFI
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } catch (_) {
      // No bloquear si falla, dejaremos que la inicialización posterior intente abrir/crear DB
    }
  }

  // Intentar inicializar la base de datos de forma segura (móvil y desktop)
  try {
    if (Platform.isIOS || Platform.isAndroid) {
      await _initMobileDatabase();
    } else {
      // En desktop simplemente forzar acceso a DatabaseService.database
      await DatabaseService.database;
    }
  } catch (_) {
    await _safeFallbackDatabaseInit();
  }
}

Future<void> _initMobileDatabase() async {
  final dbPath = await DatabaseLocationService.getDatabasePath();
  final File dbFile = File(dbPath);

  if (!await dbFile.exists()) {
    final ByteData data = await rootBundle.load(DatabaseConfig.assetDbPath);
    final List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await dbFile.writeAsBytes(bytes, flush: true);
  }

  debugPrint('Opening database:');
  debugPrint(dbPath);

  final db = await openDatabase(dbPath, version: 1, readOnly: false);
  await db.close();
}

Future<void> _safeFallbackDatabaseInit() async {
  try {
    if (Platform.isIOS || Platform.isAndroid) {
      final dbPath = await DatabaseLocationService.getDatabasePath();
      final File dbFile = File(dbPath);
      if (await dbFile.exists()) {
        try {
          debugPrint('Opening database:');
          debugPrint(dbPath);

          final db = await openDatabase(dbPath, readOnly: true);
          await db.close();
          return;
        } catch (e) {
          await dbFile.delete();
        }
      }

      final ByteData data = await rootBundle.load(DatabaseConfig.assetDbPath);
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await dbFile.writeAsBytes(bytes, flush: true);
      debugPrint('Opening database:');
      debugPrint(dbPath);

      final db = await openDatabase(dbPath);
      await db.close();
    }
  } catch (_) {
    // No propagamos: la app seguirá funcionando pero sin DB precargada
  }
}

// Usamos el `DatabaseService` existente para forzar acceso/validación cuando sea necesario.
