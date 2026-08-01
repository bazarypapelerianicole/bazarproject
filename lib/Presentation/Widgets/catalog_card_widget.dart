import 'package:flutter/material.dart';
import 'package:bazarnicole/Presentation/Template/catalog_template.dart';
import 'package:bazarnicole/Presentation/Utils/Colors.dart';
import 'package:bazarnicole/Presentation/Widgets/catalog_detail_widget.dart';
import 'package:bazarnicole/Presentation/Widgets/drive_image.dart';
import 'package:bazarnicole/Presentation/Widgets/product_gallery_viewer.dart';

/// Card del catálogo con imagen de portada, nombre, descripción y chips de tags.
class CatalogCategoryCard extends StatefulWidget {
  final String name;
  final CatalogStore store;
  final CategoryInfo info;

  const CatalogCategoryCard({
    super.key,
    required this.name,
    required this.store,
    required this.info,
  });

  @override
  State<CatalogCategoryCard> createState() => _CatalogCategoryCardState();
}

class _CatalogCategoryCardState extends State<CatalogCategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Color get _accentColor => widget.store == CatalogStore.bazar
      ? AppColors.blackOverlay
      : const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Card(
          color: AppColors.whiteOverlay,
          elevation: 4,
          shadowColor: _accentColor.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openDetail(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Imagen de portada ──────────────────────────────────
                _CardImage(
                  heroImages: widget.info.heroImages,
                  accentColor: _accentColor,
                ),

                // ── Contenido ─────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de categoría
                        Text(
                          widget.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Descripción corta
                        Expanded(
                          child: Text(
                            widget.info.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mediumGray,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tags
                        if (widget.info.tags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: widget.info.tags
                                .take(3)
                                .map(
                                  (t) =>
                                      _TagChip(label: t, color: _accentColor),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 8),
                        // Botón "Ver más"
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: () => _openDetail(context),
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                            ),
                            label: const Text(
                              'Ver detalle',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CatalogDetailWidget(
        name: widget.name,
        store: widget.store,
        info: widget.info,
      ),
    );
  }
}

/// Imagen superior de la card con gradiente overlay y badge de la tienda.
class _CardImage extends StatelessWidget {
  final List<CatalogImageFile> heroImages;
  final Color accentColor;

  const _CardImage({required this.heroImages, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (heroImages.isEmpty) _imageFallback(),
          if (heroImages.isNotEmpty)
            PageView.builder(
              itemCount: heroImages.length,
              itemBuilder: (context, index) {
                final image = heroImages[index];
                final imageUrls =
                    heroImages.map((file) => file.thumbnailLink).toList();
                return Semantics(
                  button: true,
                  label: 'Ampliar imagen ${index + 1} de ${heroImages.length}',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => ProductGalleryViewer.show(
                        context,
                        images: imageUrls,
                        initialIndex: index,
                      ),
                      child: Hero(
                        tag: ProductGalleryViewer.heroTagFor(
                            image.thumbnailLink),
                        child: DriveImage(
                          key: ValueKey(image.id),
                          url: image.thumbnailLink,
                          fit: BoxFit.cover,
                          errorWidget: _imageFallback(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          // Gradiente para mejorar legibilidad del texto sobre imagen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          if (heroImages.length > 1)
            Positioned(
              right: 8,
              bottom: 8,
              child: _ImageCount(count: heroImages.length),
            ),
        ],
      ),
    );
  }

  Widget _imageFallback() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withValues(alpha: 0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white54,
          size: 36,
        ),
      );
}

class _ImageCount extends StatelessWidget {
  final int count;

  const _ImageCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.collections_outlined,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 3),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip pequeño de etiqueta.
class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
