import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'backup_service.dart';
import 'database_location_service.dart';

/// Servicio principal para manejar la conexión con SQLite.
/// Mantiene un único sistema con múltiples locales compartiendo la misma base.
class DatabaseService {
  static Database? _database;

  static const List<String> _storeNames = ['Bazar', 'Tienda'];

  static const Map<String, List<String>> _catalogByStore = {
    'Bazar': [
      'Peluches',
      'Carteras',
      'Juguetes',
      'Portarretratos',
      'Accesorios de cocina',
      'Lámparas dormitorio',
      'Fundas de regalo',
      'Pelotas de fútbol',
      'Pelotas de indor',
      'Zapatos deportivos',
      'Zapatillas',
      'Mochilas',
      'Loncheras',
      'Plateros y accesorios para platos',
      'Accesorios para fiestas y cumpleaños',
      'Lazos',
      'Vinchas',
      'Joyería',
      'Perfumes',
      'Esmaltes y labiales',
      'Accesorios navideños',
      'Audífonos',
      'Auricular Bluetooth',
      'Billeteras para hombre y mujer',
      'Velas aromáticas',
      'Cajas para obsequios',
      'Espejos',
    ],
    'Tienda': [
      'Cuadernos',
      'Hojas A4',
      'Papel crepé',
      'Fomix',
      'Hojas papel bond',
      'Cartón prensado',
      'Espuma flex',
      'Agendas',
      'Diccionario',
      'Pinturas',
      'Lápices de colores',
      'Resaltadores',
      'Acuarelas',
      'Sacapuntas',
      'Corrector',
      'Goma',
      'Silicona',
      'Lápiz',
      'Esferos',
      'Marcador doble punta',
      'Lapicero borrable',
      'Esferos azul',
      'Borrador',
      'Marcador permanente y borrable',
      'Lana',
      'Hilo ratón',
      'Cintas',
      'Adornos tipo lentejuelas',
      'Reglas',
      'Tijera',
      'Pilas',
      'Adornos en fomix recortados',
      'Pintura acrílica Artesco',
      'Slime',
      'Paletas de colores',
      'Calculadora',
      'Estilete',
      'Prestobarba',
      'Brujita',
      'Peinillas',
      'Descorchador vinos',
      'Cepillo de dientes',
      'Uñas postizas',
      'Rizador',
      'Pestañas postizas',
      'Pegamento de uñas y cejas',
      'Moños',
      'Ampollas para el pelo',
      'Llaveros',
      'Invisibles',
      'Fosforeras',
      'Corta uñas',
      'Limas',
      'Pinza para cejas',
      'Brochas para maquillaje',
      'Tiras de sostén',
      'Cherry para zapatos saca brillo',
      'Desodorantes en aerosol',
      'Fijación e hidratación para pelo',
      'Teta para recién nacido',
      'Banderola para sacar brillo zapatos',
      'Talco de pies',
      'Limpiador facial',
      'Tinte de cabello',
      'Crema oxigenada',
      'Gel',
      'Esponja para sacar brillo zapatos',
      'Desinfectante ambiental',
      'Casino',
      'Alcancías',
      'Aceite limpiador de madera',
      'Desodorante en barra',
      'Desodorante en crema',
      'Aceite Johnson',
      'Repelente',
      'Listerine',
      'Protector solar',
      'Crema hidratante corporal',
      'Cirio vela',
      'Difusor de esencia',
      'Fósforos',
      'Jaboncillo',
      'Jabón',
      'Pasta dental niño y adulto',
      'Suavizante para ropa',
      'Gillette',
      'Pañitos húmedos',
      'Shampoo',
      'Papel aluminio',
      'Toallas higiénicas',
      'Esencias para carro',
      'Silicón en spray para cabello',
      'Leche',
      'Cinta transparente y de todo tipo',
      'Detergente',
      'Guantes',
      'Cloro',
      'Ambiental tips',
      'Enlatados',
      'Sardina',
      'Atún real',
      'Tallarines',
      'Fideos',
      'Panela',
      'Lavavajilla',
      'Focos',
      'Pañales',
      'Café',
      'Harina',
      'Azúcar',
      'Sal',
      'Avena',
      'Aceite',
      'Manteca',
      'Perforadora',
      'Tape dispenser',
      'Grapadora',
      'Insecticidas',
      'Aliños de todo tipo',
      'Condimentos',
      'Esencias',
      'Salsas',
      'Cocos',
      'Mantequilla',
      'Productos lácteos',
      'Jugos o néctares',
      'Café en polvo',
      'Leche condensada',
      'Enlatados tipo verduras',
      'Frutas',
      'Frutos secos',
      'Leches saborizadas',
      'Cremas de peinar',
      'Papel higiénico',
      'Galletas Amor',
      'Bombones',
      'Gelatina',
      'Horchata en sobre',
      'Tés en cartón por sobres',
      'Frescosolo',
      'Polvo de hornear',
      'Mezcla de polvo chantilly',
      'Platos desechables',
      'Servilletas',
      'Velas',
      'Carpetas',
      'Fundas',
      'Esponjas',
    ],
  };

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = await DatabaseLocationService.getDatabasePath();

    try {
      await DatabaseLocationService.ensureDatabaseDirectoryExists(path);
    } catch (_) {
      path = await DatabaseLocationService.getFallbackPath();
      await DatabaseLocationService.ensureDatabaseDirectoryExists(path);
    }

    if (!await DatabaseLocationService.databaseExists(path)) {
      try {
        final data = await rootBundle.load('assets/database/bazarnicole.db');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception('No se pudo copiar la base de datos desde assets: $e');
      }
    }

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async => _ensureBusinessSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async => _ensureBusinessSchema(db),
      onOpen: (db) async => _ensureBusinessSchema(db),
    );

    await _ensureBusinessSchema(db);
    _performAutomaticBackupIfNeeded();
    return db;
  }

  static Future<void> _ensureBusinessSchema(DatabaseExecutor db) async {
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sku TEXT NOT NULL UNIQUE,
        category_id INTEGER,
        price REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        store_id INTEGER NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        UNIQUE(product_id, store_id),
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
        FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store_id INTEGER NOT NULL,
        client_id INTEGER,
        date TEXT NOT NULL,
        total REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (store_id) REFERENCES stores(id),
        FOREIGN KEY (client_id) REFERENCES clients(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        from_store_id INTEGER NOT NULL,
        to_store_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (from_store_id) REFERENCES stores(id),
        FOREIGN KEY (to_store_id) REFERENCES stores(id)
      )
    ''');

    await _ensureColumn(
      db,
      table: 'products',
      column: 'price',
      definition: 'REAL NOT NULL DEFAULT 0',
    );
    await _ensureColumn(
      db,
      table: 'sales',
      column: 'client_id',
      definition: 'INTEGER',
    );

    await _seedStores(db);
    await _seedCatalog(db);
  }

  static Future<void> _seedStores(DatabaseExecutor db) async {
    for (final storeName in _storeNames) {
      await db.rawInsert(
        'INSERT OR IGNORE INTO stores (name) VALUES (?)',
        [storeName],
      );
    }
  }

  static Future<void> _seedCatalog(DatabaseExecutor db) async {
    await _ensureCategory(db, 'Sin categoría');

    final stores = await db.rawQuery('SELECT id, name FROM stores ORDER BY id');
    final storeIds = <String, int>{
      for (final row in stores)
        row['name'] as String: (row['id'] as num).toInt(),
    };

    if (storeIds.isEmpty) return;

    for (final entry in _catalogByStore.entries) {
      final categoryId = await _ensureCategory(db, entry.key);

      for (final rawName in entry.value) {
        final productName = _cleanName(rawName);
        final existing = await db.rawQuery(
          'SELECT id FROM products WHERE lower(name) = ?',
          [productName.toLowerCase()],
        );

        int productId;
        if (existing.isNotEmpty) {
          productId = (existing.first['id'] as num).toInt();
        } else {
          final uniqueSku = await _uniqueSku(db, _buildSku(productName));
          productId = await db.rawInsert(
            'INSERT INTO products (name, sku, category_id, created_at) VALUES (?, ?, ?, ?)',
            [
              productName,
              uniqueSku,
              categoryId,
              DateTime.now().toIso8601String(),
            ],
          );
        }

        for (final storeId in storeIds.values) {
          await db.rawInsert(
            'INSERT OR IGNORE INTO inventory (product_id, store_id, stock) VALUES (?, ?, 0)',
            [productId, storeId],
          );
        }
      }
    }
  }

  static Future<void> _ensureColumn(
    DatabaseExecutor db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final exists = info.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    }
  }

  static Future<int> _ensureCategory(
    DatabaseExecutor db,
    String? categoryName,
  ) async {
    final name = _cleanName(categoryName?.isNotEmpty == true
        ? categoryName!
        : 'Sin categoría');

    await db.rawInsert(
      'INSERT OR IGNORE INTO categories (name) VALUES (?)',
      [name],
    );

    final rows = await db.rawQuery(
      'SELECT id FROM categories WHERE name = ? LIMIT 1',
      [name],
    );

    return (rows.first['id'] as num).toInt();
  }

  static Future<String> _uniqueSku(DatabaseExecutor db, String baseSku) async {
    final cleanBase = _buildSku(baseSku);
    var candidate = cleanBase;
    var suffix = 1;

    while (true) {
      final rows = await db.rawQuery(
        'SELECT id FROM products WHERE upper(sku) = upper(?) LIMIT 1',
        [candidate],
      );

      if (rows.isEmpty) return candidate;

      candidate = '$cleanBase-$suffix';
      suffix++;
    }
  }

  static String _buildSku(String name) {
    final normalized = name
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    if (normalized.isEmpty) return 'ITEM';
    return normalized.substring(0, min(normalized.length, 32));
  }

  static String _cleanName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static void _performAutomaticBackupIfNeeded() {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        await BackupService.performAutomaticBackupIfNeeded();
      } catch (_) {}
    });
  }

  static Future<List<Map<String, dynamic>>> getStores() async {
    final db = await database;
    return db.rawQuery('SELECT id, name FROM stores ORDER BY id');
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.rawQuery('SELECT id, name FROM categories ORDER BY name');
  }

  static Future<List<Map<String, dynamic>>> getProducts({
    String search = '',
  }) async {
    final db = await database;
    final filter = '%${search.trim()}%';

    return db.rawQuery(
      '''
      SELECT
        p.id,
        p.name,
        p.sku,
        p.price,
        COALESCE(c.name, 'Sin categoría') AS category,
        COALESCE(SUM(i.stock), 0) AS total_stock,
        COALESCE(MAX(CASE WHEN s.name = 'Bazar' THEN i.stock END), 0) AS stock_bazar,
        COALESCE(MAX(CASE WHEN s.name = 'Tienda' THEN i.stock END), 0) AS stock_tienda
      FROM products p
      LEFT JOIN categories c ON c.id = p.category_id
      LEFT JOIN inventory i ON i.product_id = p.id
      LEFT JOIN stores s ON s.id = i.store_id
      WHERE p.name LIKE ? OR p.sku LIKE ? OR COALESCE(c.name, '') LIKE ?
      GROUP BY p.id, p.name, p.sku, p.price, c.name
      ORDER BY p.name COLLATE NOCASE
      ''',
      [filter, filter, filter],
    );
  }

  static Future<List<Map<String, dynamic>>> getInventoryByStore(
    int storeId, {
    String search = '',
  }) async {
    final db = await database;
    final filter = '%${search.trim()}%';

    return db.rawQuery(
      '''
      SELECT
        p.id AS product_id,
        p.name,
        p.sku,
        p.price,
        COALESCE(c.name, 'Sin categoría') AS category,
        COALESCE(i.stock, 0) AS stock
      FROM products p
      LEFT JOIN categories c ON c.id = p.category_id
      LEFT JOIN inventory i ON i.product_id = p.id AND i.store_id = ?
      WHERE p.name LIKE ? OR p.sku LIKE ? OR COALESCE(c.name, '') LIKE ?
      ORDER BY p.name COLLATE NOCASE
      ''',
      [storeId, filter, filter, filter],
    );
  }

  static Future<void> createProduct({
    required String name,
    double price = 0,
    String? sku,
    String? categoryName,
    Map<int, int> initialStock = const {},
  }) async {
    final cleanName = _cleanName(name);
    if (cleanName.isEmpty) {
      throw Exception('El nombre del producto es obligatorio');
    }

    await transaction((txn) async {
      final existing = await txn.rawQuery(
        'SELECT id FROM products WHERE lower(name) = ?',
        [cleanName.toLowerCase()],
      );

      if (existing.isNotEmpty) {
        throw Exception(
          'El producto ya existe. Usa el inventario por local para ajustar stock.',
        );
      }

      final categoryId = await _ensureCategory(txn, categoryName);
      final uniqueSku = await _uniqueSku(
        txn,
        (sku?.trim().isNotEmpty ?? false) ? sku!.trim() : _buildSku(cleanName),
      );

      final productId = await txn.rawInsert(
        'INSERT INTO products (name, sku, category_id, price, created_at) VALUES (?, ?, ?, ?, ?)',
        [
          cleanName,
          uniqueSku,
          categoryId,
          price < 0 ? 0 : price,
          DateTime.now().toIso8601String(),
        ],
      );

      final storeRows = await txn.rawQuery('SELECT id FROM stores ORDER BY id');
      for (final store in storeRows) {
        final storeId = (store['id'] as num).toInt();
        await txn.rawInsert(
          'INSERT OR IGNORE INTO inventory (product_id, store_id, stock) VALUES (?, ?, ?)',
          [productId, storeId, max(0, initialStock[storeId] ?? 0)],
        );
      }
    });
  }

  static Future<void> updateInventoryStock({
    required int productId,
    required int storeId,
    required int stock,
  }) async {
    final db = await database;
    final safeStock = max(0, stock);

    await db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT OR IGNORE INTO inventory (product_id, store_id, stock) VALUES (?, ?, 0)',
        [productId, storeId],
      );

      await txn.rawUpdate(
        'UPDATE inventory SET stock = ? WHERE product_id = ? AND store_id = ?',
        [safeStock, productId, storeId],
      );
    });
  }

  static Future<void> transferInventory({
    required int productId,
    required int fromStoreId,
    required int toStoreId,
    required int quantity,
  }) async {
    if (fromStoreId == toStoreId) {
      throw Exception('Selecciona dos locales distintos');
    }

    if (quantity <= 0) {
      throw Exception('La cantidad debe ser mayor que cero');
    }

    await transaction((txn) async {
      await txn.rawInsert(
        'INSERT OR IGNORE INTO inventory (product_id, store_id, stock) VALUES (?, ?, 0)',
        [productId, fromStoreId],
      );
      await txn.rawInsert(
        'INSERT OR IGNORE INTO inventory (product_id, store_id, stock) VALUES (?, ?, 0)',
        [productId, toStoreId],
      );

      final sourceRows = await txn.rawQuery(
        'SELECT stock FROM inventory WHERE product_id = ? AND store_id = ? LIMIT 1',
        [productId, fromStoreId],
      );

      final available = sourceRows.isEmpty
          ? 0
          : (sourceRows.first['stock'] as num).toInt();

      if (available < quantity) {
        throw Exception('No hay stock suficiente en el local origen');
      }

      await txn.rawUpdate(
        'UPDATE inventory SET stock = stock - ? WHERE product_id = ? AND store_id = ?',
        [quantity, productId, fromStoreId],
      );

      await txn.rawUpdate(
        'UPDATE inventory SET stock = stock + ? WHERE product_id = ? AND store_id = ?',
        [quantity, productId, toStoreId],
      );

      await txn.rawInsert(
        'INSERT INTO inventory_movements (product_id, from_store_id, to_store_id, quantity, date) VALUES (?, ?, ?, ?, ?)',
        [
          productId,
          fromStoreId,
          toStoreId,
          quantity,
          DateTime.now().toIso8601String(),
        ],
      );
    });
  }

  static Future<int> registerSale({
    required int storeId,
    required List<Map<String, dynamic>> items,
    int? clientId,
  }) async {
    if (items.isEmpty) {
      throw Exception('La venta debe contener al menos un producto');
    }

    return transaction((txn) async {
      double total = 0;

      for (final item in items) {
        final productId = item['product_id'] as int;
        final quantity = (item['quantity'] as num).toInt();
        final price = (item['price'] as num).toDouble();

        if (quantity <= 0) {
          throw Exception('La cantidad de venta debe ser mayor que cero');
        }

        final stockRows = await txn.rawQuery(
          'SELECT stock FROM inventory WHERE product_id = ? AND store_id = ? LIMIT 1',
          [productId, storeId],
        );

        final available = stockRows.isEmpty
            ? 0
            : (stockRows.first['stock'] as num).toInt();

        if (available < quantity) {
          throw Exception('Stock insuficiente para completar la venta');
        }

        total += quantity * price;
      }

      final saleId = await txn.rawInsert(
        'INSERT INTO sales (store_id, client_id, date, total) VALUES (?, ?, ?, ?)',
        [storeId, clientId, DateTime.now().toIso8601String(), total],
      );

      for (final item in items) {
        final productId = item['product_id'] as int;
        final quantity = (item['quantity'] as num).toInt();
        final price = (item['price'] as num).toDouble();

        await txn.rawInsert(
          'INSERT INTO sale_items (sale_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
          [saleId, productId, quantity, price],
        );

        await txn.rawUpdate(
          'UPDATE inventory SET stock = stock - ? WHERE product_id = ? AND store_id = ?',
          [quantity, productId, storeId],
        );
      }

      return saleId;
    });
  }

  static Future<void> updateProduct({
    required int productId,
    required String name,
    required String categoryName,
    required String sku,
    required double price,
  }) async {
    final cleanName = _cleanName(name);
    if (cleanName.isEmpty) {
      throw Exception('El nombre del producto es obligatorio');
    }

    await transaction((txn) async {
      final repeated = await txn.rawQuery(
        'SELECT id FROM products WHERE lower(name) = ? AND id != ?',
        [cleanName.toLowerCase(), productId],
      );

      if (repeated.isNotEmpty) {
        throw Exception('Ya existe otro producto con ese nombre');
      }

      final categoryId = await _ensureCategory(txn, categoryName);
      await txn.rawUpdate(
        'UPDATE products SET name = ?, sku = ?, category_id = ?, price = ? WHERE id = ?',
        [cleanName, sku.trim().isEmpty ? _buildSku(cleanName) : sku.trim(), categoryId, price < 0 ? 0 : price, productId],
      );
    });
  }

  static Future<List<Map<String, dynamic>>> getCustomers({
    String search = '',
  }) async {
    final db = await database;
    final filter = '%${search.trim()}%';

    return db.rawQuery(
      '''
      SELECT id, name, phone, email, notes, created_at
      FROM clients
      WHERE name LIKE ? OR COALESCE(phone, '') LIKE ? OR COALESCE(email, '') LIKE ?
      ORDER BY name COLLATE NOCASE
      ''',
      [filter, filter, filter],
    );
  }

  static Future<void> createCustomer({
    required String name,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final cleanName = _cleanName(name);
    if (cleanName.isEmpty) {
      throw Exception('El nombre del cliente es obligatorio');
    }

    final db = await database;
    await db.rawInsert(
      'INSERT INTO clients (name, phone, email, notes, created_at) VALUES (?, ?, ?, ?, ?)',
      [
        cleanName,
        phone?.trim(),
        email?.trim(),
        notes?.trim(),
        DateTime.now().toIso8601String(),
      ],
    );
  }

  static Future<List<Map<String, dynamic>>> getCustomerHistory(int customerId) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT sa.id, sa.date, sa.total, st.name AS store_name
      FROM sales sa
      LEFT JOIN stores st ON st.id = sa.store_id
      WHERE sa.client_id = ?
      ORDER BY sa.date DESC
      ''',
      [customerId],
    );
  }

  static Future<Map<String, dynamic>> getReportsSnapshot() async {
    final db = await database;
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    final salesToday = await db.rawQuery(
      'SELECT COUNT(*) AS sales_count, COALESCE(SUM(total), 0) AS total FROM sales WHERE date >= ?',
      [dayStart],
    );

    final salesByStore = await db.rawQuery('''
      SELECT st.name, COUNT(sa.id) AS sales_count, COALESCE(SUM(sa.total), 0) AS total
      FROM stores st
      LEFT JOIN sales sa ON sa.store_id = st.id
      GROUP BY st.id, st.name
      ORDER BY total DESC, st.name ASC
    ''');

    final topProducts = await db.rawQuery('''
      SELECT p.name, COALESCE(SUM(si.quantity), 0) AS units, COALESCE(SUM(si.quantity * si.price), 0) AS revenue
      FROM sale_items si
      INNER JOIN products p ON p.id = si.product_id
      GROUP BY p.id, p.name
      ORDER BY units DESC, revenue DESC
      LIMIT 10
    ''');

    return {
      'salesToday': salesToday.isNotEmpty ? salesToday.first : {'sales_count': 0, 'total': 0},
      'salesByStore': salesByStore,
      'topProducts': topProducts,
    };
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  static Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return db.rawInsert(sql, arguments);
  }

  static Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return db.rawUpdate(sql, arguments);
  }

  static Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return db.rawDelete(sql, arguments);
  }

  static Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await database;
    return db.transaction(action);
  }

  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final path = await DatabaseLocationService.getDatabasePath();
      final exists = await DatabaseLocationService.databaseExists(path);
      final size = exists
          ? await DatabaseLocationService.getDatabaseSize(path)
          : 0.0;

      return {
        'path': path,
        'exists': exists,
        'sizeMB': size,
        'systemInfo': DatabaseLocationService.getSystemInfo(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'path': 'Error obteniendo ruta',
        'exists': false,
        'sizeMB': 0.0,
      };
    }
  }

  static Future<bool> createManualBackup({String? customName}) async {
    try {
      return await BackupService.createBackup(customName: customName);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> restoreFromBackup(String backupName) async {
    try {
      await closeDatabase();
      final result = await BackupService.restoreFromBackup(backupName);
      if (result) {
        _database = await _initDatabase();
      }
      return result;
    } catch (_) {
      return false;
    }
  }
}
