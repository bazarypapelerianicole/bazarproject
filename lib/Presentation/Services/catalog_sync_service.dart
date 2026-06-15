// ignore_for_file: avoid_print

import 'dart:async';

import 'catalog_export_service.dart';
import 'git_sync_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Estado de sincronización
// ─────────────────────────────────────────────────────────────────────────────

enum SyncStatus { idle, exporting, pushing, success, error }

/// Snapshot del estado actual del sistema de sincronización.
class SyncState {
  final SyncStatus status;
  final DateTime? lastSync;
  final String? lastError;
  final int? lastProductsCount;
  final int? lastCategoriesCount;

  const SyncState({
    required this.status,
    this.lastSync,
    this.lastError,
    this.lastProductsCount,
    this.lastCategoriesCount,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSync,
    String? lastError,
    int? lastProductsCount,
    int? lastCategoriesCount,
  }) =>
      SyncState(
        status: status ?? this.status,
        lastSync: lastSync ?? this.lastSync,
        lastError: lastError ?? this.lastError,
        lastProductsCount: lastProductsCount ?? this.lastProductsCount,
        lastCategoriesCount: lastCategoriesCount ?? this.lastCategoriesCount,
      );

  bool get isRunning =>
      status == SyncStatus.exporting || status == SyncStatus.pushing;
}

// ─────────────────────────────────────────────────────────────────────────────
// Entrada del log de sincronización
// ─────────────────────────────────────────────────────────────────────────────

class SyncLogEntry {
  final DateTime timestamp;
  final String message;
  final bool isError;

  const SyncLogEntry({
    required this.timestamp,
    required this.message,
    required this.isError,
  });

  @override
  String toString() {
    final ts = timestamp.toLocal().toIso8601String().substring(0, 19);
    final icon = isError ? '❌' : '✅';
    return '$ts $icon $message';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orquestador principal de sincronización
// ─────────────────────────────────────────────────────────────────────────────

/// Orquesta la exportación SQLite → JSON y la publicación vía Git.
///
/// Funcionalidades:
///   • Cola de sincronización (evita exportaciones simultáneas).
///   • Debounce configurable (por defecto 30 s) para agrupar cambios rápidos.
///   • Sincronización manual mediante [syncNow].
///   • Stream de estado [stateStream] para que el Provider escuche cambios.
///   • Log de las últimas [maxLogEntries] operaciones.
///
/// Uso desde el ProductManagementController (y similares):
/// ```dart
/// // Al crear / editar / eliminar un producto:
/// CatalogSyncService.instance.notifyCatalogChanged();
/// ```
class CatalogSyncService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static CatalogSyncService? _instance;

  static CatalogSyncService get instance {
    assert(
      _instance != null,
      'Llama a CatalogSyncService.initialize() antes de usar la instancia.',
    );
    return _instance!;
  }

  /// Inicializa el singleton. Llamar UNA vez en main.dart / providers.dart.
  static void initialize({
    required String exportDir,
    required String gitRepoPath,
    Duration debounce = const Duration(seconds: 30),
    int maxLogEntries = 100,
  }) {
    _instance ??= CatalogSyncService._(
      exportDir: exportDir,
      gitRepoPath: gitRepoPath,
      debounce: debounce,
      maxLogEntries: maxLogEntries,
    );
  }

  // ── Campos ─────────────────────────────────────────────────────────────────
  final String exportDir;
  final String gitRepoPath;
  final Duration debounce;
  final int maxLogEntries;

  final _stateController = StreamController<SyncState>.broadcast();
  final List<SyncLogEntry> _log = [];

  SyncState _state = const SyncState(status: SyncStatus.idle);
  Timer? _debounceTimer;
  bool _syncRunning = false;

  // Cola: si llega una petición mientras otra está en curso, se encola una sola.
  bool _pendingSync = false;

  CatalogSyncService._({
    required this.exportDir,
    required this.gitRepoPath,
    required this.debounce,
    required this.maxLogEntries,
  });

  // ── API pública ────────────────────────────────────────────────────────────

  /// Stream que emite el estado actualizado. Conéctalo desde el Provider.
  Stream<SyncState> get stateStream => _stateController.stream;

  /// Estado actual (snapshot síncrono).
  SyncState get state => _state;

  /// Log de operaciones (inmutable desde afuera).
  List<SyncLogEntry> get log => List.unmodifiable(_log);

  /// Notifica que hubo un cambio en catálogo (producto o categoría).
  /// Activa el debounce: si no hay cambios nuevos en [debounce], lanza sync.
  void notifyCatalogChanged() {
    _log_(
      'Cambio detectado en catálogo. Debounce reiniciado (${debounce.inSeconds}s).',
    );
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, _enqueueSyncIfIdle);
  }

  /// Sincronización manual inmediata (botón en UI).
  /// Cancela el debounce pendiente y ejecuta ahora.
  Future<void> syncNow() async {
    _debounceTimer?.cancel();
    _log_('Sincronización manual solicitada.');
    await _runSync();
  }

  /// Libera recursos (llamar en dispose del Provider).
  void dispose() {
    _debounceTimer?.cancel();
    _stateController.close();
  }

  // ── Lógica interna ─────────────────────────────────────────────────────────

  void _enqueueSyncIfIdle() {
    if (_syncRunning) {
      _pendingSync = true;
      _log_('Sync en curso — petición encolada.');
      return;
    }
    _runSync();
  }

  Future<void> _runSync() async {
    if (_syncRunning) {
      _pendingSync = true;
      return;
    }

    _syncRunning = true;
    _pendingSync = false;

    try {
      // ── 1. Exportar JSON ──────────────────────────────────────────────────
      _emit(_state.copyWith(status: SyncStatus.exporting));
      _log_('Iniciando exportación SQLite → JSON…');

      final exportResult = await CatalogExportService.exportAll(exportDir);

      if (!exportResult.success) {
        _fail('Error en exportación: ${exportResult.error}');
        return;
      }

      _log_(
        'JSON generados: ${exportResult.productsCount} productos, '
        '${exportResult.categoriesCount} categorías.',
      );

      // ── 2. Publicar vía Git ───────────────────────────────────────────────
      _emit(_state.copyWith(status: SyncStatus.pushing));
      _log_('Publicando en GitHub Pages…');

      final git = GitSyncService(repoPath: gitRepoPath);
      final gitResult = await git.publishCatalog(
        commitMessage:
            'catalog update: ${exportResult.productsCount} prods, '
            '${exportResult.categoriesCount} cats — '
            '${DateTime.now().toUtc().toIso8601String()}',
      );

      if (!gitResult.success) {
        _fail('Error en git push: ${gitResult.stderr}');
        return;
      }

      // ── 3. Éxito ──────────────────────────────────────────────────────────
      final now = DateTime.now();
      _emit(SyncState(
        status: SyncStatus.success,
        lastSync: now,
        lastProductsCount: exportResult.productsCount,
        lastCategoriesCount: exportResult.categoriesCount,
      ));
      _log_(
        '✅ Catálogo publicado: ${exportResult.productsCount} productos.',
        isError: false,
      );
    } catch (e, st) {
      _fail('Excepción inesperada: $e\n$st');
    } finally {
      _syncRunning = false;

      // Procesar petición encolada si existe.
      if (_pendingSync) {
        _pendingSync = false;
        _log_('Procesando sincronización encolada…');
        Future.microtask(_runSync);
      }
    }
  }

  void _fail(String message) {
    print('[CatalogSyncService] ❌ $message');
    _log_(message, isError: true);
    _emit(_state.copyWith(
      status: SyncStatus.error,
      lastError: message,
    ));
  }

  void _emit(SyncState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  void _log_(String message, {bool isError = false}) {
    print('[CatalogSyncService] $message');
    _log.add(SyncLogEntry(
      timestamp: DateTime.now(),
      message: message,
      isError: isError,
    ));
    // Mantener solo las últimas N entradas.
    if (_log.length > maxLogEntries) {
      _log.removeRange(0, _log.length - maxLogEntries);
    }
  }
}
