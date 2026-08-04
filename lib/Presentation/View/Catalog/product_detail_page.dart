import 'package:bazarnicole/Presentation/Template/catalog_template.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:bazarnicole/Presentation/Widgets/drive_image.dart';
import 'package:bazarnicole/Presentation/Widgets/product_gallery_viewer.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product, this.deepLinkSku});

  factory ProductDetailPage.fromSku({Key? key, required String sku}) {
    return ProductDetailPage(
      key: key,
      product: CatalogProductEntry(
        id: -1,
        name: 'Producto',
        sku: sku,
        categoryName: 'Sin categoría',
      ),
      deepLinkSku: sku,
    );
  }

  final CatalogProductEntry product;
  final String? deepLinkSku;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;
    final heroImages = product.imageFiles.isEmpty
        ? const <CatalogImageFile>[]
        : product.imageFiles;
    final heroImage = heroImages.isEmpty ? null : heroImages.first;
    final accentColor = product.categoryName.toLowerCase().contains('bazar')
        ? AppColors.blackOverlay
        : const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isWide ? 360 : 300,
            pinned: true,
            backgroundColor: AppColors.primaryLogo,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroSection(
                heroImage: heroImage,
                heroImages: heroImages,
                accentColor: accentColor,
                product: product,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 36 : 20,
                isWide ? 24 : 18,
                isWide ? 36 : 20,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGray,
                            height: 1.15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.stock > 0 ? 'En stock' : 'Sin stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoPill(
                        icon: Icons.qr_code_2_rounded,
                        label:
                            'SKU ${product.sku.isEmpty ? product.id.toString() : product.sku}',
                        accentColor: accentColor,
                      ),
                      _InfoPill(
                        icon: Icons.category_outlined,
                        label: product.categoryName,
                        accentColor: accentColor,
                      ),
                      _InfoPill(
                        icon: Icons.storefront_outlined,
                        label: product.categoryName.isEmpty
                            ? 'Tienda general'
                            : 'Tienda disponible',
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Precio',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: AppColors.mediumGray,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.stock > 0
                                  ? '${product.stock} unidades disponibles'
                                  : 'Sin unidades disponibles',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Descripción',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.sku.isEmpty && product.name.isEmpty
                              ? 'Detalle del producto disponible próximamente.'
                              : 'Producto disponible en el catálogo de ${product.categoryName.isEmpty ? 'la tienda' : product.categoryName}.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.65,
                            color: AppColors.mediumGray,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Volver al catálogo'),
                            style: FilledButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.heroImage,
    required this.heroImages,
    required this.accentColor,
    required this.product,
  });

  final CatalogImageFile? heroImage;
  final List<CatalogImageFile> heroImages;
  final Color accentColor;
  final CatalogProductEntry product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = heroImage?.thumbnailLink;
    final images = heroImages.map((image) => image.thumbnailLink).toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Semantics(
            button: true,
            label: 'Ampliar imágenes de ${product.name}',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => ProductGalleryViewer.show(
                  context,
                  images: images,
                  initialIndex: 0,
                ),
                child: Hero(
                  tag: ProductGalleryViewer.heroTagFor(imageUrl),
                  child: DriveImage(
                    url: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: _fallbackDecoration(),
                  ),
                ),
              ),
            ),
          )
        else
          _fallbackDecoration(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 140,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteOverlay,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  product.categoryName.isEmpty
                      ? 'Catálogo'
                      : product.categoryName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackOverlay.withValues(alpha: 0.65),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallbackDecoration() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withValues(alpha: 0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white70,
          size: 56,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
