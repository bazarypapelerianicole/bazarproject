import 'package:bazarnicole/Presentation/Services/drive_data_service.dart';
import 'package:bazarnicole/Presentation/Template/catalog_template.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:bazarnicole/Presentation/Widgets/catalog_card_widget.dart';
import 'package:bazarnicole/Presentation/Widgets/legal_page_widget.dart';
import 'package:flutter/material.dart';

class CatalogSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isCompact;

  const CatalogSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar producto',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 20,
            vertical: isCompact ? 14 : 16,
          ),
        ),
      ),
    );
  }
}

class CategoryFilter extends StatelessWidget {
  final List<CatalogCategory> categories;
  final CatalogCategory? selectedCategory;
  final ValueChanged<CatalogCategory?> onChanged;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownMenu<CatalogCategory?>(
        initialSelection: selectedCategory,
        onSelected: onChanged,
        width: double.infinity,
        textStyle: theme.textTheme.bodyMedium,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        menuStyle: MenuStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        dropdownMenuEntries: [
          const DropdownMenuEntry<CatalogCategory?>(
            value: null,
            label: 'Todas las categorías',
          ),
          ...categories.map(
            (category) => DropdownMenuEntry<CatalogCategory?>(
              value: category,
              label: category.name,
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogFilters extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<CatalogCategory> categories;
  final CatalogCategory? selectedCategory;
  final ValueChanged<CatalogCategory?> onCategoryChanged;
  final int resultCount;

  const CatalogFilters({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CatalogSearchBar(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    isCompact: isCompact,
                  ),
                ),
                if (!isCompact) const SizedBox(width: 12),
                if (!isCompact)
                  Expanded(
                    child: CategoryFilter(
                      categories: categories,
                      selectedCategory: selectedCategory,
                      onChanged: onCategoryChanged,
                    ),
                  ),
              ],
            ),
            if (isCompact) ...[
              const SizedBox(height: 12),
              CategoryFilter(
                categories: categories,
                selectedCategory: selectedCategory,
                onChanged: onCategoryChanged,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '$resultCount productos encontrados',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Vista pública del catálogo — solo para web.
/// Muestra los artículos disponibles con selector de sección (Bazar / Papelería).
/// Los datos reales (productos e imágenes) se cargan desde el backup en Google Drive.
class WebCatalogView extends StatefulWidget {
  const WebCatalogView({super.key});

  @override
  State<WebCatalogView> createState() => _WebCatalogViewState();
}

class _WebCatalogViewState extends State<WebCatalogView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  CatalogCategory? _selectedCategory;
  String _search = '';

  /// Datos reales de Drive (null = aún cargando).
  CatalogDriveData? _driveData;
  bool _driveLoading = false;
  String? _driveError;

  List<CatalogSection> get _sections => _driveData?.sections ?? [];

  @override
  void initState() {
    super.initState();
    _loadDriveData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  // ── Carga de datos desde Drive ─────────────────────────────────────────────

  // ── Carga de datos desde Drive (pública, sin login) ─────────────────────────

  Future<void> _loadDriveData() async {
    setState(() {
      _driveLoading = true;
      _driveError = null;
    });
    try {
      final data = await DriveDataService.fetchPublic();

      if (!mounted) return;

      _tabController?.dispose();

      _tabController = TabController(
        length: data.sections.isEmpty ? 1 : data.sections.length,
        vsync: this,
      );

      setState(() {
        _driveData = data;
      });
    } catch (e, stack) {
      debugPrint("=================================");
      debugPrint("ERROR EN fetchPublic()");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      debugPrint("=================================");

      if (mounted) {
        setState(() {
          _driveError = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _driveLoading = false);
    }
  }

  List<CatalogCategory> _filteredCategories(List<CatalogCategory> items) {
    final q = _search.trim().toLowerCase();

    return items.where((category) {
      final matchesCategory =
          _selectedCategory == null || category.id == _selectedCategory!.id;
      if (!matchesCategory) {
        return false;
      }

      final matchesProducts = q.isEmpty
          ? category.products.isNotEmpty
          : category.products.any(
              (product) => product.name.toLowerCase().contains(q),
            );

      return matchesProducts;
    }).toList();
  }

  int _countVisibleProducts(List<CatalogCategory> categories) {
    final q = _search.trim().toLowerCase();
    return categories.fold<int>(0, (total, category) {
      final visibleProducts = q.isEmpty
          ? category.products.length
          : category.products.where(
              (product) => product.name.toLowerCase().contains(q),
            ).length;
      return total + visibleProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final isTablet = width > 700;

    final currentSectionCategories = _sections.isEmpty
        ? <CatalogCategory>[]
        : (_tabController != null && _tabController!.index < _sections.length
            ? _sections[_tabController!.index].categories
            : _sections.first.categories);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryLogo,
        foregroundColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.storefront_outlined, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bazar & Tienda Nicole',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Catálogo de productos',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_driveLoading)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              ),
            )
          else if (_driveData != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Tooltip(
                message: 'Datos en tiempo real desde Google Drive',
                child: const Icon(
                  Icons.cloud_done_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TextButton.icon(
                onPressed: _loadDriveData,
                icon: const Icon(
                  Icons.refresh_outlined,
                  color: Colors.white60,
                  size: 18,
                ),
                label: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ),
            ),
        ],
        bottom: _sections.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: _sections
                      .map(
                        (s) => Tab(
                          icon: Icon(
                            s.storeId == 1
                                ? Icons.shopping_bag_outlined
                                : Icons.menu_book_outlined,
                          ),
                          text: s.storeName,
                        ),
                      )
                      .toList(),
                ),
              ),
      ),
      body: Column(
        children: [
          if (_driveError != null)
            _DriveBanner(message: _driveError!, onRetry: _loadDriveData),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 28 : 16,
                      20,
                      isTablet ? 28 : 16,
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explora el catálogo',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLogo,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Encuentra tus productos favoritos de forma rápida y cómoda.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mediumGray),
                        ),
                        const SizedBox(height: 16),
                        if (_sections.isNotEmpty)
                          CatalogFilters(
                            searchController: _searchController,
                            onSearchChanged: (value) => setState(() {
                              _search = value;
                            }),
                            categories: currentSectionCategories,
                            selectedCategory: _selectedCategory,
                            onCategoryChanged: (category) => setState(() {
                              _selectedCategory = category;
                            }),
                            resultCount: _sections.fold<int>(0, (
                              count,
                              section,
                            ) {
                              return count +
                                  _countVisibleProducts(
                                    _filteredCategories(section.categories),
                                  );
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_driveLoading && _sections.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_sections.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 48,
                            color: AppColors.greyOverlay,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No se pudo cargar el catálogo',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _loadDriveData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 28 : 16,
                        8,
                        isTablet ? 28 : 16,
                        24,
                      ),
                      child: _CatalogGrid(
                        sections: _sections,
                        search: _search,
                        selectedCategory: _selectedCategory,
                        isWide: isWide,
                        isTablet: isTablet,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            color: AppColors.primaryLogo,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  '© 2026 Bazar & Tienda Nicole — Todos los derechos reservados',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          LegalPageWidget.show(context, LegalDocType.terms),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Términos y Condiciones',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54,
                        ),
                      ),
                    ),
                    const Text(
                      '·',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    TextButton(
                      onPressed: () =>
                          LegalPageWidget.show(context, LegalDocType.privacy),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Política de Privacidad',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner de estado de Drive ────────────────────────────────────────────────

class _DriveBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DriveBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF3CD),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            color: Color(0xFF856404),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No se pudieron cargar datos desde Drive. Mostrando catálogo base.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF856404)),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(fontSize: 11, color: Color(0xFF856404)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid de categorías ───────────────────────────────────────────────────────

class _CatalogGrid extends StatelessWidget {
  final List<CatalogSection> sections;
  final String search;
  final CatalogCategory? selectedCategory;
  final bool isWide;
  final bool isTablet;

  const _CatalogGrid({
    required this.sections,
    required this.search,
    required this.selectedCategory,
    required this.isWide,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final filteredSections = sections
        .map((section) {
          final categories = section.categories.where((category) {
            final q = search.trim().toLowerCase();
            final matchesCategory =
                selectedCategory == null || category.id == selectedCategory!.id;
            final matchesProducts = q.isEmpty
                ? category.products.isNotEmpty
                : category.products.any(
                    (product) => product.name.toLowerCase().contains(q),
                  );
            return matchesCategory && matchesProducts;
          }).toList();

          return CatalogSection(
            storeId: section.storeId,
            storeName: section.storeName,
            categories: categories,
          );
        })
        .where((section) => section.categories.isNotEmpty)
        .toList();

    if (filteredSections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.greyOverlay),
            const SizedBox(height: 8),
            const Text('No se encontraron artículos'),
          ],
        ),
      );
    }

    final crossCount = isWide
        ? 4
        : isTablet
        ? 3
        : 1;
    final childAspectRatio = isWide
        ? 0.78
        : isTablet
        ? 0.84
        : 0.86;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in filteredSections) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 14, top: 4),
            child: Text(
              section.storeName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLogo,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: section.categories.length,
            itemBuilder: (context, index) {
              final category = section.categories[index];
              return CatalogCategoryCard(
                name: category.name,
                storeName: category.storeName,
                info: category,
              );
            },
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}
