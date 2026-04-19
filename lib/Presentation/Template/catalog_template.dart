/// Modelo que representa un ítem del catálogo público (web)
class CatalogItem {
  final String name;
  final String category;
  final double price;
  final String store; // 'Bazar' | 'Papelería'
  final String description;
  final String imageUrl;
  final List<String> tags;
  final bool available;

  const CatalogItem({
    required this.name,
    required this.category,
    required this.price,
    required this.store,
    this.description = '',
    this.imageUrl = '',
    this.tags = const [],
    this.available = true,
  });
}

/// Tipo de sección del catálogo
enum CatalogStore {
  bazar('Bazar', 'Artículos de bazar, regalos y accesorios'),
  tienda('Tienda', 'Papelería, belleza, alimentos y productos varios');

  final String label;
  final String description;
  const CatalogStore(this.label, this.description);
}

/// Producto real cargado desde Drive (dato mínimo para el catálogo público).
class CatalogProductEntry {
  final int id;
  final String name;
  final String sku;
  final double price;
  final int stock;

  const CatalogProductEntry({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
  });
}

/// Información de categoría: descripción, imagen de portada, etiquetas y
/// (opcionalmente) productos reales cargados desde Drive.
class CategoryInfo {
  final String description;
  final String imageUrl;
  final List<String> tags;

  /// Productos reales de esta categoría (cargados desde Drive).
  /// Lista vacía cuando aún no se ha cargado el Drive.
  final List<CatalogProductEntry> products;

  const CategoryInfo({
    required this.description,
    required this.imageUrl,
    this.tags = const [],
    this.products = const [],
  });

  /// Crea una copia con los productos reales inyectados desde Drive.
  CategoryInfo withProducts(List<CatalogProductEntry> realProducts) {
    return CategoryInfo(
      description: description,
      imageUrl: imageUrl,
      tags: tags,
      products: realProducts,
    );
  }

  /// Crea una copia con una nueva URL de imagen (de Drive).
  CategoryInfo withImageUrl(String url) {
    return CategoryInfo(
      description: description,
      imageUrl: url,
      tags: tags,
      products: products,
    );
  }
}

/// Catálogo estático para la vista web pública.
/// Muestra los artículos disponibles organizados por sección.
class WebCatalog {
  /// Devuelve la info extra de una categoría (descripción, imagen, tags).
  static CategoryInfo infoFor(String category, CatalogStore store) {
    return _categoryInfo[category] ??
        CategoryInfo(
          description: store == CatalogStore.bazar
              ? 'Artículo de bazar disponible en tienda.'
              : 'Artículo disponible en tienda.',
          imageUrl: store == CatalogStore.bazar
              ? 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600'
              : 'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=600',
          tags: const [],
        );
  }

  static const Map<String, CategoryInfo> _categoryInfo = {
    // ── BAZAR › Regalos y decoración ─────────────────────────────────
    'Peluches': CategoryInfo(
      description:
          'Tiernos peluches de todo tipo: osos, unicornios, animales y personajes. Perfectos como regalo para niños y adultos.',
      imageUrl:
          'https://images.unsplash.com/photo-1559181567-c3190ca9d222?w=600',
      tags: ['Regalo', 'Niños', 'Suave'],
    ),
    'Portarretratos': CategoryInfo(
      description:
          'Portarretratos de madera, metal y plástico en distintos formatos para decorar tu hogar con los mejores recuerdos.',
      imageUrl:
          'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600',
      tags: ['Decoración', 'Hogar', 'Regalo'],
    ),
    'Cajas para obsequios': CategoryInfo(
      description:
          'Cajas decorativas para armar el regalo perfecto. Diferentes tamaños, colores y diseños para toda ocasión especial.',
      imageUrl:
          'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600',
      tags: ['Regalo', 'Envoltorio', 'Decoración'],
    ),
    'Fundas de regalo': CategoryInfo(
      description:
          'Fundas y bolsas de regalo en papel y tela, con diseños festivos para cumpleaños, navidad, baby shower y más.',
      imageUrl:
          'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600',
      tags: ['Regalo', 'Fiesta', 'Envoltorio'],
    ),
    'Velas aromáticas': CategoryInfo(
      description:
          'Velas aromáticas artesanales en cera de soya y parafina. Aromas relajantes para el hogar: lavanda, vainilla, canela y más.',
      imageUrl:
          'https://images.unsplash.com/photo-1603905988457-81e9a680f6df?w=600',
      tags: ['Aromas', 'Relajación', 'Hogar'],
    ),
    'Espejos': CategoryInfo(
      description:
          'Espejos de mano, de bolsillo y de pared con marcos decorativos. Imprescindibles para tu tocador y para decorar espacios.',
      imageUrl:
          'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=600',
      tags: ['Belleza', 'Decoración', 'Hogar'],
    ),
    'Lámparas de dormitorio': CategoryInfo(
      description:
          'Lámparas de mesa y veladores para habitación. Diseños modernos y acogedores para crear el ambiente ideal en tu cuarto.',
      imageUrl:
          'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600',
      tags: ['Decoración', 'Luz', 'Hogar'],
    ),

    // ── BAZAR › Fiestas y temporada ──────────────────────────────────
    'Accesorios para cumpleaños': CategoryInfo(
      description:
          'Todo para decorar tu fiesta: globos, serpentinas, cotillones, guirnaldas y más. Celebra cada momento con estilo.',
      imageUrl:
          'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?w=600',
      tags: ['Fiesta', 'Decoración', 'Celebración'],
    ),
    'Lazos y Vinchas': CategoryInfo(
      description:
          'Lazos, vinchas y accesorios para el cabello en una gran variedad de colores, telas y estilos para niñas y mujeres.',
      imageUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
      tags: ['Cabello', 'Niñas', 'Moda'],
    ),
    'Accesorios navideños': CategoryInfo(
      description:
          'Esferas, luces, adornos y todo para decorar tu árbol y hogar en Navidad. Crea la atmósfera más festiva del año.',
      imageUrl:
          'https://images.unsplash.com/photo-1482517967863-00e15c9b44be?w=600',
      tags: ['Navidad', 'Decoración', 'Festivo'],
    ),

    // ── BAZAR › Moda y accesorios personales ─────────────────────────
    'Carteras y Bolsos': CategoryInfo(
      description:
          'Amplia variedad de carteras y bolsos para mujer, en diferentes colores, tamaños y estilos: casual, elegante y deportivo.',
      imageUrl:
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600',
      tags: ['Moda', 'Mujer', 'Accesorio'],
    ),
    'Billeteras': CategoryInfo(
      description:
          'Billeteras para hombre y mujer en cuero sintético y tela. Diseños modernos con múltiples compartimentos.',
      imageUrl:
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=600',
      tags: ['Accesorio', 'Cuero', 'Práctico'],
    ),
    'Mochilas y Loncheras': CategoryInfo(
      description:
          'Mochilas escolares y loncheras con diseños de personajes y colores vibrantes. Resistentes y con amplio espacio.',
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600',
      tags: ['Escolar', 'Niños', 'Organizador'],
    ),
    'Zapatos deportivos y Zapatillas': CategoryInfo(
      description:
          'Zapatos deportivos y zapatillas para niños y adultos. Comodidad, estilo y durabilidad para cada actividad.',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
      tags: ['Calzado', 'Deporte', 'Moda'],
    ),
    'Joyería y Accesorios': CategoryInfo(
      description:
          'Aretes, collares, pulseras y anillos de moda. Bisutería fina y elegante para complementar cualquier look.',
      imageUrl:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600',
      tags: ['Joyería', 'Moda', 'Mujer'],
    ),
    'Perfumes': CategoryInfo(
      description:
          'Fragancias para hombre y mujer: perfumes, colonias y splash corporales de aromas florales, frescos y amaderados.',
      imageUrl:
          'https://images.unsplash.com/photo-1541643600914-78b084683702?w=600',
      tags: ['Belleza', 'Fragancia', 'Regalo'],
    ),
    'Esmaltes y Labiales': CategoryInfo(
      description:
          'Esmaltes de uñas en cientos de colores y labiales de larga duración. Maquillaje accesible y de tendencia.',
      imageUrl:
          'https://images.unsplash.com/photo-1586495777744-4e6232bf3077?w=600',
      tags: ['Maquillaje', 'Belleza', 'Uñas'],
    ),

    // ── BAZAR › Deportes y recreación ────────────────────────────────
    'Pelotas': CategoryInfo(
      description:
          'Pelotas de fútbol, indor, básquet y playa. Para jugar al aire libre y practicar deporte con amigos y familia.',
      imageUrl:
          'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=600',
      tags: ['Deporte', 'Fútbol', 'Juego'],
    ),
    'Juguetes': CategoryInfo(
      description:
          'Juguetes educativos y de entretenimiento para niños de todas las edades. Fomentamos la creatividad y el aprendizaje.',
      imageUrl:
          'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=600',
      tags: ['Niños', 'Educativo', 'Diversión'],
    ),

    // ── BAZAR › Hogar y cocina ────────────────────────────────────────
    'Accesorios de cocina': CategoryInfo(
      description:
          'Accesorios prácticos para tu cocina: recipientes, utensilios, organizadores y más. Calidad y funcionalidad.',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600',
      tags: ['Hogar', 'Cocina', 'Funcional'],
    ),
    'Plateros y accesorios para platos': CategoryInfo(
      description:
          'Plateros, escurridores y accesorios para organizar y exhibir tu vajilla con estilo y orden en la cocina.',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600',
      tags: ['Hogar', 'Cocina', 'Organización'],
    ),

    // ── BAZAR › Tecnología ────────────────────────────────────────────
    'Audífonos y Bluetooth': CategoryInfo(
      description:
          'Audífonos con y sin cable, parlantes bluetooth y accesorios de audio para música, llamadas y entretenimiento.',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600',
      tags: ['Tecnología', 'Audio', 'Música'],
    ),

    // ── BAZAR › Varios bazar ──────────────────────────────────────────
    'Alcancías': CategoryInfo(
      description:
          'Alcancías decorativas para niños y adultos. Formas divertidas de animales, personajes y diseños creativos.',
      imageUrl:
          'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=600',
      tags: ['Ahorro', 'Niños', 'Decoración'],
    ),
    'Casino y entretenimiento': CategoryInfo(
      description:
          'Juegos de mesa, naipes, dados, ruletas y más para noches de entretenimiento en familia o con amigos.',
      imageUrl:
          'https://images.unsplash.com/photo-1626958390928-3a3d26c9de5d?w=600',
      tags: ['Entretenimiento', 'Juego', 'Familia'],
    ),

    // ── TIENDA › Papelería y útiles escolares ─────────────────────────
    'Cuadernos': CategoryInfo(
      description:
          'Cuadernos universitarios, escolares y cuadriculados de 50, 100 y 200 hojas. Tapas duras y blandas en varios diseños.',
      imageUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600',
      tags: ['Escolar', 'Escritura', 'Organización'],
    ),
    'Hojas A4 y Bond': CategoryInfo(
      description:
          'Resmas de papel A4 bond 75 gr para impresora y papel bond para escritura manual. Blancura superior y acabado liso.',
      imageUrl:
          'https://images.unsplash.com/photo-1568667256549-094345857637?w=600',
      tags: ['Papel', 'Oficina', 'Impresión'],
    ),
    'Papel crepé y Fomix': CategoryInfo(
      description:
          'Papel crepé y foamy en todos los colores del arcoíris. Ideal para manualidades, decoraciones y proyectos escolares.',
      imageUrl:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600',
      tags: ['Manualidades', 'Arte', 'Color'],
    ),
    'Cartón prensado': CategoryInfo(
      description:
          'Cartón prensado en láminas de varios grosores para maquetas, encuadernación y proyectos de arte y diseño.',
      imageUrl:
          'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600',
      tags: ['Manualidades', 'Maquetas', 'Arte'],
    ),
    'Agendas y Diccionarios': CategoryInfo(
      description:
          'Agendas con planificador mensual y semanal, y diccionarios ilustrados para todos los niveles escolares.',
      imageUrl:
          'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=600',
      tags: ['Organización', 'Escolar', 'Planificación'],
    ),
    'Lápices de colores': CategoryInfo(
      description:
          'Lápices de colores en cajas de 12 a 48 unidades. Minas suaves de alta pigmentación para colorear y dibujar.',
      imageUrl:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600',
      tags: ['Arte', 'Color', 'Escolar'],
    ),
    'Esferos y Lapiceros': CategoryInfo(
      description:
          'Esferos y bolígrafos de tinta azul, negra y roja. Flujo uniforme para una escritura suave y precisa.',
      imageUrl:
          'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=600',
      tags: ['Escritura', 'Escolar', 'Oficina'],
    ),
    'Marcadores': CategoryInfo(
      description:
          'Marcadores permanentes y borrables, doble punta fina y gruesa. Para pizarras, carteles, manualidades y uso escolar.',
      imageUrl:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600',
      tags: ['Arte', 'Escritura', 'Escolar'],
    ),
    'Resaltadores': CategoryInfo(
      description:
          'Resaltadores de colores fluorescentes de punta biselada. Ideales para estudiar y organizar información.',
      imageUrl:
          'https://images.unsplash.com/photo-1456735190827-d1262f71b8a3?w=600',
      tags: ['Estudio', 'Organización', 'Oficina'],
    ),
    'Borrador y Sacapuntas': CategoryInfo(
      description:
          'Borradores de vinilo, correctores líquidos y sacapuntas metálicos de doble agujero. Precisión para cada trazo.',
      imageUrl:
          'https://images.unsplash.com/photo-1456735190827-d1262f71b8a3?w=600',
      tags: ['Escolar', 'Precisión', 'Herramienta'],
    ),
    'Reglas y Tijeras': CategoryInfo(
      description:
          'Reglas de 15, 20 y 30 cm, transportadores y tijeras escolares con punta redondeada y filo superior.',
      imageUrl:
          'https://images.unsplash.com/photo-1456735190827-d1262f71b8a3?w=600',
      tags: ['Herramienta', 'Escolar', 'Medición'],
    ),
    'Calculadoras': CategoryInfo(
      description:
          'Calculadoras básicas y científicas para uso escolar y universitario. Pantalla grande y funciones avanzadas.',
      imageUrl:
          'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=600',
      tags: ['Escolar', 'Matemáticas', 'Tecnología'],
    ),
    'Carpetas y Fundas': CategoryInfo(
      description:
          'Carpetas de argollas, plásticas y de cartón, y fundas transparentes para organizar y proteger tus documentos.',
      imageUrl:
          'https://images.unsplash.com/photo-1588702547919-26089e690ecc?w=600',
      tags: ['Oficina', 'Organización', 'Escolar'],
    ),
    'Grapadora': CategoryInfo(
      description:
          'Grapadoras de escritorio para 20-50 hojas con repuesto de grapas incluido. Compactas y de uso intensivo.',
      imageUrl:
          'https://images.unsplash.com/photo-1588702547919-26089e690ecc?w=600',
      tags: ['Oficina', 'Archivo', 'Herramienta'],
    ),
    'Perforadora': CategoryInfo(
      description:
          'Perforadoras de 2 y 4 agujeros para archivar documentos con facilidad. Capacidad para hasta 20 hojas.',
      imageUrl:
          'https://images.unsplash.com/photo-1588702547919-26089e690ecc?w=600',
      tags: ['Oficina', 'Organización', 'Archivo'],
    ),
    'Tape dispenser': CategoryInfo(
      description:
          'Dispensadores de cinta adhesiva de escritorio. Corte fácil y preciso con base antideslizante para uso diario.',
      imageUrl:
          'https://images.unsplash.com/photo-1588702547919-26089e690ecc?w=600',
      tags: ['Oficina', 'Adhesivo', 'Escritorio'],
    ),
    'Estilete': CategoryInfo(
      description:
          'Estiletes metálicos y de plástico con hoja retráctil para cortes precisos en papel, cartón y más materiales.',
      imageUrl:
          'https://images.unsplash.com/photo-1581093452543-c2f14a2fb9f9?w=600',
      tags: ['Herramienta', 'Corte', 'Manualidades'],
    ),

    // ── TIENDA › Arte y manualidades ──────────────────────────────────
    'Pinturas y Acuarelas': CategoryInfo(
      description:
          'Sets de acuarelas, temperas y pinturas al agua de 12, 18 y 24 colores. Para uso escolar y artístico.',
      imageUrl:
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600',
      tags: ['Arte', 'Pintura', 'Escolar'],
    ),
    'Pintura acrílica': CategoryInfo(
      description:
          'Pinturas acrílicas Artesco de alta pigmentación. Secado rápido, resistentes al agua, perfectas para lienzo y madera.',
      imageUrl:
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600',
      tags: ['Arte', 'Pintura', 'Profesional'],
    ),
    'Silicona y Pegamento': CategoryInfo(
      description:
          'Pegamento en barra, líquido y pistola de silicona caliente. Adhesivos seguros para papel, foamy, tela y más.',
      imageUrl:
          'https://images.unsplash.com/photo-1581093452543-c2f14a2fb9f9?w=600',
      tags: ['Manualidades', 'Pegamento', 'Arte'],
    ),
    'Lana e Hilos': CategoryInfo(
      description:
          'Lana acrílica, hilo ratón y algodón para tejido, crochet y manualidades. Gran variedad de colores y grosores.',
      imageUrl:
          'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=600',
      tags: ['Tejido', 'Manualidades', 'Arte'],
    ),
    'Cintas': CategoryInfo(
      description:
          'Cintas adhesivas transparentes, de embalaje, decorativas y washi tape. Todo tipo de cintas para sellar y decorar.',
      imageUrl:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600',
      tags: ['Adhesivo', 'Decoración', 'Manualidades'],
    ),
    'Lentejuelas y adornos': CategoryInfo(
      description:
          'Lentejuelas, brillos, piedras y adornos decorativos para manualidades, disfraces y proyectos creativos escolares.',
      imageUrl:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600',
      tags: ['Manualidades', 'Arte', 'Brillo'],
    ),
    'Adornos en fomix': CategoryInfo(
      description:
          'Letras, flores, figuras y plantillas de foamy recortadas para decorar cuadernos, carteles y trabajos escolares.',
      imageUrl:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600',
      tags: ['Manualidades', 'Decoración', 'Arte'],
    ),
    'Slime': CategoryInfo(
      description:
          'Slimes de colores, brillantinas y texturas distintas. La actividad sensorial y creativa favorita de los niños.',
      imageUrl:
          'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=600',
      tags: ['Niños', 'Juego', 'Sensorial'],
    ),
    'Paletas de colores': CategoryInfo(
      description:
          'Paletas de sombras, acuarelas y colores normales para maquillaje y arte. Desde tonos pastel hasta pigmentos vibrantes.',
      imageUrl:
          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600',
      tags: ['Arte', 'Color', 'Maquillaje'],
    ),

    // ── TIENDA › Belleza y cuidado personal ───────────────────────────
    'Peinillas y Moños': CategoryInfo(
      description:
          'Peinillas, peines, moños, cintas invisibles y accesorios para el cabello. Para todo tipo de cabello y estilo.',
      imageUrl:
          'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=600',
      tags: ['Cabello', 'Higiene', 'Cuidado'],
    ),
    'Uñas postizas': CategoryInfo(
      description:
          'Uñas acrílicas y press-on de diferentes formas, tamaños y diseños. Manicura perfecta en minutos desde casa.',
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=600',
      tags: ['Belleza', 'Uñas', 'Moda'],
    ),
    'Pestañas postizas': CategoryInfo(
      description:
          'Pestañas postizas de pelo natural y sintético y pegamento de cejas. Desde looks naturales hasta dramáticos.',
      imageUrl:
          'https://images.unsplash.com/photo-1617897903246-719242758050?w=600',
      tags: ['Maquillaje', 'Belleza', 'Ojos'],
    ),
    'Brochas para maquillaje': CategoryInfo(
      description:
          'Set de brochas profesionales para base, contorno, sombras y más. Cerdas suaves para una aplicación perfecta.',
      imageUrl:
          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600',
      tags: ['Maquillaje', 'Belleza', 'Profesional'],
    ),
    'Tinte de cabello': CategoryInfo(
      description:
          'Tintes semipermanentes y permanentes con crema oxigenada incluida. Paleta amplia de colores naturales y vibrantes.',
      imageUrl:
          'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=600',
      tags: ['Cabello', 'Color', 'Transformación'],
    ),
    'Gel y fijación para pelo': CategoryInfo(
      description:
          'Geles, cremas fijadoras, sprays e hidratantes para todo tipo de peinado. Control fuerte sin maltrato al cabello.',
      imageUrl:
          'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=600',
      tags: ['Cabello', 'Estilo', 'Cuidado'],
    ),
    'Ampollas para el pelo': CategoryInfo(
      description:
          'Ampollas de nutrición y keratina para cabello dañado, seco y sin brillo. Tratamiento intensivo de uso semanal.',
      imageUrl:
          'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=600',
      tags: ['Cabello', 'Tratamiento', 'Nutrición'],
    ),
    'Cremas y limpiador facial': CategoryInfo(
      description:
          'Cremas hidratantes corporales, limpiadoras faciales y protectores solares para el cuidado diario de tu piel.',
      imageUrl:
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=600',
      tags: ['Skincare', 'Belleza', 'Cuidado'],
    ),
    'Desodorantes': CategoryInfo(
      description:
          'Desodorantes en barra, crema y spray aerosol para hombre y mujer. Frescura y protección de larga duración.',
      imageUrl:
          'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=600',
      tags: ['Higiene', 'Frescura', 'Cuidado personal'],
    ),
    'Talco de pies': CategoryInfo(
      description:
          'Talcos para pies con fórmula antifúngica y desodorante. Mantienen tus pies frescos, secos y sin mal olor.',
      imageUrl:
          'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=600',
      tags: ['Higiene', 'Pies', 'Cuidado'],
    ),
    'Cepillo y pasta dental': CategoryInfo(
      description:
          'Cepillos de dientes para niño y adulto, pastas dentales y enjuague bucal para una higiene oral completa.',
      imageUrl:
          'https://images.unsplash.com/photo-1609840114035-3c981b782dfe?w=600',
      tags: ['Higiene', 'Dental', 'Salud'],
    ),
    'Shampoo': CategoryInfo(
      description:
          'Shampoos para todo tipo de cabello: normal, graso, seco, con keratina y fórmulas para niños. Cuida y nutre.',
      imageUrl:
          'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=600',
      tags: ['Cabello', 'Higiene', 'Cuidado'],
    ),
    'Rizador': CategoryInfo(
      description:
          'Rizadores y onduladores para crear peinados perfectos. Con protección de temperatura y distintos tamaños de rizo.',
      imageUrl:
          'https://images.unsplash.com/photo-1522338140262-f46f5913618a?w=600',
      tags: ['Cabello', 'Belleza', 'Estilismo'],
    ),
    'Corta uñas y Limas': CategoryInfo(
      description:
          'Corta uñas de acero inoxidable, limas de diferentes granos y estuches de manicura completos.',
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=600',
      tags: ['Manicura', 'Higiene', 'Cuidado'],
    ),
    'Pinza para cejas': CategoryInfo(
      description:
          'Pinzas de precisión y kits de depilación para cejas perfectas. Diseño ergonómico para mayor control.',
      imageUrl:
          'https://images.unsplash.com/photo-1583241800698-e8ab01830a22?w=600',
      tags: ['Belleza', 'Cejas', 'Precisión'],
    ),
    'Tiras de sostén': CategoryInfo(
      description:
          'Tiras adhesivas y de silicona para sostén. Solución invisible y cómoda para todo tipo de escote y ropa.',
      imageUrl:
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=600',
      tags: ['Lencería', 'Moda', 'Accesorio'],
    ),

    // ── TIENDA › Limpieza y hogar ─────────────────────────────────────
    'Detergente y cloro': CategoryInfo(
      description:
          'Detergentes en polvo y líquido, cloro doméstico y blanqueadores para una limpieza efectiva de ropa y superficies.',
      imageUrl:
          'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=600',
      tags: ['Limpieza', 'Hogar', 'Lavado'],
    ),
    'Lavavajilla': CategoryInfo(
      description:
          'Lavavajillas en crema, líquido y en pastillas. Elimina grasa y residuos de utensilios de cocina eficazmente.',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600',
      tags: ['Limpieza', 'Cocina', 'Hogar'],
    ),
    'Desinfectante ambiental': CategoryInfo(
      description:
          'Desinfectantes para pisos y superficies, ambientadores y tips para mantener el hogar limpio y con buen aroma.',
      imageUrl:
          'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=600',
      tags: ['Limpieza', 'Higiene', 'Hogar'],
    ),
    'Suavizante para ropa': CategoryInfo(
      description:
          'Suavizantes concentrados para ropa en variedad de aromas florales y frescos. Tejidos suaves y perfumados.',
      imageUrl:
          'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=600',
      tags: ['Lavado', 'Ropa', 'Aroma'],
    ),
    'Esponjas': CategoryInfo(
      description:
          'Esponjas de cocina, baño y limpieza general. Alta durabilidad y poder de limpieza sin rayar superficies.',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600',
      tags: ['Limpieza', 'Cocina', 'Hogar'],
    ),
    'Papel higiénico': CategoryInfo(
      description:
          'Papel higiénico triple hoja de alta suavidad y absorción. Paquetes individuales y de gran cantidad.',
      imageUrl:
          'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=600',
      tags: ['Higiene', 'Hogar', 'Esencial'],
    ),
    'Papel aluminio': CategoryInfo(
      description:
          'Papel aluminio doméstico para conservar alimentos, cocinar al horno y sellar recipientes. Resistente al calor.',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600',
      tags: ['Cocina', 'Hogar', 'Conservación'],
    ),
    'Guantes de limpieza': CategoryInfo(
      description:
          'Guantes de látex y nitrilo para limpieza del hogar. Protegen tus manos del cloro, detergentes y suciedad.',
      imageUrl:
          'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=600',
      tags: ['Limpieza', 'Protección', 'Hogar'],
    ),

    // ── TIENDA › Alimentos y abarrotes ────────────────────────────────
    'Granos y básicos': CategoryInfo(
      description:
          'Arroz, azúcar, sal, harina, avena y panela. Los alimentos esenciales para abastecer tu cocina cada semana.',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
      tags: ['Alimentos', 'Básicos', 'Cocina'],
    ),
    'Aceites y grasas': CategoryInfo(
      description:
          'Aceites vegetales, manteca y mantequilla de marcas reconocidas. Esenciales para cocinar con sabor y nutrición.',
      imageUrl:
          'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=600',
      tags: ['Alimentos', 'Cocina', 'Grasa'],
    ),
    'Café y leche': CategoryInfo(
      description:
          'Café molido, en polvo y soluble. Leche entera, semidescremada y condensada para tus preparaciones diarias.',
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
      tags: ['Bebidas', 'Desayuno', 'Alimentos'],
    ),
    'Enlatados': CategoryInfo(
      description:
          'Atún real, sardinas, verduras y frutas en lata. Alimentos de larga duración, prácticos y listos para consumir.',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
      tags: ['Alimentos', 'Conservas', 'Proteína'],
    ),
    'Tallarines y fideos': CategoryInfo(
      description:
          'Tallarines, fideos y pastas de varios cortes para preparar sopas, ensaladas y platos principales rápidamente.',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
      tags: ['Alimentos', 'Pasta', 'Cocina'],
    ),
    'Galletas y dulces': CategoryInfo(
      description:
          'Galletas Amor de todos los sabores, bombones, chocolates y snacks dulces para disfrutar en cualquier momento.',
      imageUrl:
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=600',
      tags: ['Dulces', 'Snacks', 'Antojo'],
    ),
    'Jugos y néctares': CategoryInfo(
      description:
          'Jugos y néctares de durazno, mango, naranja y más variedades. Bebidas naturales y refrescantes para toda la familia.',
      imageUrl:
          'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=600',
      tags: ['Bebidas', 'Frutas', 'Refresco'],
    ),
    'Tés y bebidas': CategoryInfo(
      description:
          'Tés en cartón por sobres, horchata, frescosolo y leches saborizadas. Variedad de bebidas calientes y frías.',
      imageUrl:
          'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600',
      tags: ['Bebidas', 'Té', 'Refresco'],
    ),
    'Gelatina y repostería': CategoryInfo(
      description:
          'Gelatinas en sobre, polvo de hornear, mezcla de chantilly y esencias para repostería. Haz tus postres en casa.',
      imageUrl:
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=600',
      tags: ['Repostería', 'Dulces', 'Cocina'],
    ),
    'Condimentos y aliños': CategoryInfo(
      description:
          'Aliños, condimentos, salsas, cocos, esencias de cocina y todo para dar sabor a tus preparaciones del día a día.',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600',
      tags: ['Cocina', 'Sabor', 'Especias'],
    ),
    'Frutos secos': CategoryInfo(
      description:
          'Maní, nueces, almendras y mezclas de frutos secos. Snack saludable y energético para cualquier hora del día.',
      imageUrl:
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=600',
      tags: ['Snacks', 'Saludable', 'Energía'],
    ),
    'Productos lácteos': CategoryInfo(
      description:
          'Queso, yogur, crema de leche y productos lácteos frescos. Calidad y sabor para tus preparaciones y consumo directo.',
      imageUrl:
          'https://images.unsplash.com/photo-1559598467-f8b76c8155d0?w=600',
      tags: ['Lácteos', 'Alimentos', 'Frescos'],
    ),
    'Platos desechables y servilletas': CategoryInfo(
      description:
          'Platos, vasos y cubiertos desechables, servilletas y fundas para fiestas, eventos y uso cotidiano en el hogar.',
      imageUrl:
          'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?w=600',
      tags: ['Desechables', 'Fiesta', 'Hogar'],
    ),

    // ── TIENDA › Bebés ────────────────────────────────────────────────
    'Pañales': CategoryInfo(
      description:
          'Pañales para recién nacido y todas las tallas. Suaves, absorbentes y con ajuste cómodo para el bebé.',
      imageUrl:
          'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=600',
      tags: ['Bebés', 'Higiene', 'Recién nacido'],
    ),
    'Toallitas húmedas': CategoryInfo(
      description:
          'Toallitas húmedas para bebé y uso familiar. Fórmula sin alcohol, hipoalergénica, suave para la piel más delicada.',
      imageUrl:
          'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=600',
      tags: ['Bebés', 'Higiene', 'Suave'],
    ),
    'Aceite Johnson': CategoryInfo(
      description:
          'Aceite corporal Johnson para bebé. Fórmula suave e hipoalergénica que hidrata y cuida la piel del recién nacido.',
      imageUrl:
          'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=600',
      tags: ['Bebés', 'Hidratación', 'Cuidado'],
    ),
    'Teta para recién nacido': CategoryInfo(
      description:
          'Tetinas y chupetes para recién nacido en silicona y látex. Distintos flujos y formas para cada etapa del bebé.',
      imageUrl:
          'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=600',
      tags: ['Bebés', 'Alimentación', 'Recién nacido'],
    ),

    // ── TIENDA › Ferretería y varios ──────────────────────────────────
    'Pilas': CategoryInfo(
      description:
          'Pilas alcalinas AA, AAA, C, D y de 9V de larga duración para controles remotos, juguetes y dispositivos.',
      imageUrl:
          'https://images.unsplash.com/photo-1610282456014-7b24988c5e43?w=600',
      tags: ['Electricidad', 'Electrónica', 'Hogar'],
    ),
    'Focos': CategoryInfo(
      description:
          'Focos LED y ahorradores de distintas potencias y bases. Mayor ahorro energético y mayor vida útil garantizada.',
      imageUrl:
          'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600',
      tags: ['Electricidad', 'Hogar', 'Iluminación'],
    ),
    'Insecticidas': CategoryInfo(
      description:
          'Insecticidas en spray y espiral para mosquitos, cucarachas y más plagas. Protege tu hogar de manera eficaz.',
      imageUrl:
          'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=600',
      tags: ['Hogar', 'Limpieza', 'Protección'],
    ),
    'Fosforeras y encendedores': CategoryInfo(
      description:
          'Fósforos, fosforeras y encendedores recargables. Seguros y prácticos para la cocina, velas y uso diario.',
      imageUrl:
          'https://images.unsplash.com/photo-1610282456014-7b24988c5e43?w=600',
      tags: ['Hogar', 'Cocina', 'Varios'],
    ),
    'Silicon spray': CategoryInfo(
      description:
          'Silicon spray lubricante para cabello, mecanismos, plásticos y superficies. Brillo y protección duradera.',
      imageUrl:
          'https://images.unsplash.com/photo-1581093452543-c2f14a2fb9f9?w=600',
      tags: ['Varios', 'Cabello', 'Lubricante'],
    ),
    'Prestobarba y navajas': CategoryInfo(
      description:
          'Maquinas de afeitar desechables y navajas para hombres. Afeitado limpio, cómodo y a bajo costo.',
      imageUrl:
          'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=600',
      tags: ['Higiene', 'Hombre', 'Afeitado'],
    ),

    // ── TIENDA › Misceláneos ──────────────────────────────────────────
    'Llaveros': CategoryInfo(
      description:
          'Llaveros personalizados, de personajes, metálicos y de cuero. El detalle perfecto para regalar o para ti mismo.',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
      tags: ['Accesorio', 'Regalo', 'Personalizado'],
    ),
    'Velas y cirios': CategoryInfo(
      description:
          'Velas de cumpleaños, cirios religiosos y velas para el hogar en diferentes tamaños, colores y aromas.',
      imageUrl:
          'https://images.unsplash.com/photo-1603905988457-81e9a680f6df?w=600',
      tags: ['Hogar', 'Religioso', 'Decoración'],
    ),
    'Difusores de esencia': CategoryInfo(
      description:
          'Difusores eléctricos y de varillas con esencias aromáticas para perfumar y ambientar tu hogar naturalmente.',
      imageUrl:
          'https://images.unsplash.com/photo-1603905988457-81e9a680f6df?w=600',
      tags: ['Aromas', 'Hogar', 'Relajación'],
    ),
    'Esencias para carro': CategoryInfo(
      description:
          'Aromatizantes y esencias para el auto en gel, spray y colgantes. Mantén tu vehículo siempre con buen olor.',
      imageUrl:
          'https://images.unsplash.com/photo-1603905988457-81e9a680f6df?w=600',
      tags: ['Auto', 'Aroma', 'Accesorio'],
    ),
    'Productos para calzado': CategoryInfo(
      description:
          'Cremas de brillo, cepillos, banderolas y esponjas para limpiar y dar brillo a todo tipo de zapatos y zapatillas.',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
      tags: ['Calzado', 'Limpieza', 'Cuidado'],
    ),
  };

  // ── BAZAR ────────────────────────────────────────────────────────────
  static const List<String> bazarCategories = [
    // Regalos y decoración
    'Peluches',
    'Portarretratos',
    'Cajas para obsequios',
    'Fundas de regalo',
    'Velas aromáticas',
    'Espejos',
    'Lámparas de dormitorio',
    // Fiestas y temporada
    'Accesorios para cumpleaños',
    'Lazos y Vinchas',
    'Accesorios navideños',
    // Moda y accesorios personales
    'Carteras y Bolsos',
    'Billeteras',
    'Mochilas y Loncheras',
    'Zapatos deportivos y Zapatillas',
    'Joyería y Accesorios',
    'Perfumes',
    'Esmaltes y Labiales',
    // Deportes y recreación
    'Pelotas',
    'Juguetes',
    // Hogar y cocina
    'Accesorios de cocina',
    'Plateros y accesorios para platos',
    // Tecnología
    'Audífonos y Bluetooth',
    // Varios bazar
    'Alcancías',
    'Casino y entretenimiento',
  ];

  // ── TIENDA ───────────────────────────────────────────────────────────
  static const List<String> tiendaCategories = [
    // Papelería y útiles escolares
    'Cuadernos',
    'Hojas A4 y Bond',
    'Papel crepé y Fomix',
    'Cartón prensado',
    'Agendas y Diccionarios',
    'Lápices de colores',
    'Esferos y Lapiceros',
    'Marcadores',
    'Resaltadores',
    'Borrador y Sacapuntas',
    'Reglas y Tijeras',
    'Calculadoras',
    'Carpetas y Fundas',
    'Grapadora',
    'Perforadora',
    'Tape dispenser',
    'Estilete',
    // Arte y manualidades
    'Pinturas y Acuarelas',
    'Pintura acrílica',
    'Silicona y Pegamento',
    'Lana e Hilos',
    'Cintas',
    'Lentejuelas y adornos',
    'Adornos en fomix',
    'Slime',
    'Paletas de colores',
    // Belleza y cuidado personal
    'Peinillas y Moños',
    'Uñas postizas',
    'Pestañas postizas',
    'Brochas para maquillaje',
    'Tinte de cabello',
    'Gel y fijación para pelo',
    'Ampollas para el pelo',
    'Cremas y limpiador facial',
    'Desodorantes',
    'Talco de pies',
    'Cepillo y pasta dental',
    'Shampoo',
    'Rizador',
    'Corta uñas y Limas',
    'Pinza para cejas',
    'Tiras de sostén',
    // Limpieza y hogar
    'Detergente y cloro',
    'Lavavajilla',
    'Desinfectante ambiental',
    'Suavizante para ropa',
    'Esponjas',
    'Papel higiénico',
    'Papel aluminio',
    'Guantes de limpieza',
    // Alimentos y abarrotes
    'Granos y básicos',
    'Aceites y grasas',
    'Café y leche',
    'Enlatados',
    'Tallarines y fideos',
    'Galletas y dulces',
    'Jugos y néctares',
    'Tés y bebidas',
    'Gelatina y repostería',
    'Condimentos y aliños',
    'Frutos secos',
    'Productos lácteos',
    'Platos desechables y servilletas',
    // Bebés
    'Pañales',
    'Toallitas húmedas',
    'Aceite Johnson',
    'Teta para recién nacido',
    // Ferretería y varios
    'Pilas',
    'Focos',
    'Insecticidas',
    'Fosforeras y encendedores',
    'Silicon spray',
    'Prestobarba y navajas',
    // Misceláneos
    'Llaveros',
    'Velas y cirios',
    'Difusores de esencia',
    'Esencias para carro',
    'Productos para calzado',
  ];

  /// Alias de compatibilidad hacia atrás.
  static const List<String> papeleriaCategories = tiendaCategories;
}
