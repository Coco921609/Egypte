import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────
//  PALETTE « OR & NUIT »
// ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0C0A09);
  static const surface = Color(0xFF14100C);
  static const gold = Color(0xFFD9B77A);
  static const goldLight = Color(0xFFF1DFB4);
  static const goldDeep = Color(0xFFA8823F);
  static const cream = Color(0xFFF4ECDF);
  static const ink = Color(0xFF16110A);
}

// --- 1. CLASSE DE DÉFILEMENT WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

/// Petite icône qui s'inverse automatiquement en contexte RTL
/// (remplace le paramètre `matchTextDirection`, qui n'existe pas sur [Icon]).
class _DirectionalIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  const _DirectionalIcon(
      this.icon, {
        required this.size,
        required this.color,
      });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Transform(
      alignment: Alignment.center,
      transform: isRtl ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
      child: Icon(icon, size: size, color: color),
    );
  }
}

// --- 2. PAGE PRINCIPALE (LE CAIRE) ---
class LeCairePage extends StatefulWidget {
  const LeCairePage({super.key});

  @override
  State<LeCairePage> createState() => _LeCairePageState();
}

class _LeCairePageState extends State<LeCairePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _mainScrollController = ScrollController();
  late final AnimationController _shimmer;
  String _lang = 'fr';
  String _filter = 'all'; // 'all' | 'fav' | clé de catégorie
  Set<String> _favs = {};
  bool _showTop = false;

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Le Caire',
      'tagline': 'La ville aux mille minarets',
      'places': 'lieux',
      'all': 'Tout',
      'favs': 'Favoris',
      'noFav': 'Aucun favori pour le moment.\nTouche le ♡ pour en ajouter.',
      'discover': 'Découvrir',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'about': 'À propos',
      'overview': 'En bref',
      'duration': 'Durée conseillée',
      'bestTime': 'Meilleur moment',
      'category': 'Catégorie',
      'highlights': 'Points forts',
      'didYouKnow': 'Le saviez-vous ?',
      'tip': 'Conseil du voyageur',
      'seeAlso': 'À voir aussi',
      'catMonuments': 'Monuments',
      'catMarkets': 'Marchés traditionnels',
      'catHistory': 'Lieux historiques',
      'catArch': 'Architecture',
      'catRelaxation': 'Lieux de détente',
      'catActivities': 'Activités au Caire',
    },
    'en': {
      'pageTitle': 'Cairo',
      'tagline': 'The city of a thousand minarets',
      'places': 'places',
      'all': 'All',
      'favs': 'Favorites',
      'noFav': 'No favorites yet.\nTap the ♡ to add some.',
      'discover': 'Discover',
      'mapsBtn': 'Open in Google Maps',
      'about': 'About',
      'overview': 'At a glance',
      'duration': 'Suggested time',
      'bestTime': 'Best time',
      'category': 'Category',
      'highlights': 'Highlights',
      'didYouKnow': 'Did you know?',
      'tip': "Traveller's tip",
      'seeAlso': 'Also worth a visit',
      'catMonuments': 'Monuments',
      'catMarkets': 'Traditional Markets',
      'catHistory': 'Historical Sites',
      'catArch': 'Architecture',
      'catRelaxation': 'Relaxation Spots',
      'catActivities': 'Activities in Cairo',
    },
    'ar': {
      'pageTitle': 'القاهرة',
      'tagline': 'مدينة الألف مئذنة',
      'places': 'مكان',
      'all': 'الكل',
      'favs': 'المفضلة',
      'noFav': 'لا توجد أماكن مفضلة بعد.\nاضغط على ♡ للإضافة.',
      'discover': 'اكتشف',
      'mapsBtn': 'الفتح في خرائط Google',
      'about': 'نبذة',
      'overview': 'لمحة سريعة',
      'duration': 'المدة المقترحة',
      'bestTime': 'أفضل وقت',
      'category': 'الفئة',
      'highlights': 'أبرز المعالم',
      'didYouKnow': 'هل تعلم؟',
      'tip': 'نصيحة للمسافر',
      'seeAlso': 'اكتشف أيضًا',
      'catMonuments': 'المعالم الأثرية',
      'catMarkets': 'الأسواق التقليدية',
      'catHistory': 'الأماكن التاريخية',
      'catArch': 'العمارة',
      'catRelaxation': 'أماكن الاسترخاء',
      'catActivities': 'أنشطة في القاهرة',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedCaireData = {
    'fr': [
      {
        "id": "tour_caire",
        "name": "La Tour du Caire",
        "sub_category_key": "catActivities",
        "sub_category": "Activités au Caire",
        "photo_url": "assets/caire/tour.jpg",
        "description": "Culminant à 187 mètres, la Tour du Caire est une icône moderne de la ville, véritable Tour Eiffel version égyptienne. Construite en béton armé sous la forme d'un moucharabieh, elle offre une plateforme d'observation à 360 degrés. C'est l'endroit idéal pour contempler l'immensité de la capitale, le méandre du Nil et, par temps clair, les pyramides de Gizeh à l'horizon.",
        "mapsQuery": "Tour du Caire"
      },
      {
        "id": "pyramides_gizeh",
        "name": "Pyramides de Gizeh",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/pyramide.jpg",
        "description": "Seules merveilles du monde antique encore debout, les pyramides de Khéops, Khéphren et Mykérinos sont le symbole ultime de l'Égypte. Ce site archéologique monumental, gardé par le majestueux Sphinx, témoigne du génie architectural et de la dévotion religieuse des pharaons de l'Ancien Empire. Explorer ce plateau, c'est marcher sur les traces de l'histoire humaine millénaire au cœur d'un désert qui a préservé ces trésors pour l'éternité.",
        "mapsQuery": "Pyramides de Gizeh Le Caire"
      },
      {
        "id": "citadelle_saladin",
        "name": "La Citadelle de Saladin",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/saladin.jpg",
        "description": "Dominant la ville depuis les hauteurs des collines de Mokattam, cette forteresse médiévale, construite par Saladin au XIIe siècle, est un joyau de l'architecture islamique. Elle abrite la célèbre Mosquée d'Albâtre (Mosquée de Mohamed Ali) dont les minarets élancés sont visibles de partout au Caire. Ses fortifications offrent non seulement un aperçu historique sur les défenses médiévales, mais aussi l'un des plus beaux panoramas sur la ville.",
        "mapsQuery": "Citadelle de Saladin Le Caire"
      },
      {
        "id": "quartier_copte",
        "name": "Le Quartier Copte",
        "sub_category_key": "catHistory",
        "sub_category": "Lieux historiques",
        "photo_url": "assets/caire/copte.jpg",
        "description": "Le Vieux-Caire cache en son sein le quartier copte, véritable sanctuaire de spiritualité. C'est ici que se trouve l'église suspendue, bâtie au-dessus des portes de la forteresse romaine de Babylone, ainsi que la synagogue Ben Ezra et l'église Saint-Serge, où, selon la tradition, la Sainte Famille aurait trouvé refuge lors de sa fuite en Égypte. Un lieu calme, chargé d'histoire, loin du tumulte urbain.",
        "mapsQuery": "Quartier Copte Le Caire"
      },
      {
        "id": "grand_musee_egyptien",
        "name": "Le Grand Musée Égyptien",
        "sub_category_key": "catHistory",
        "sub_category": "Lieux historiques",
        "photo_url": "assets/caire/musee.jpg",
        "description": "L'un des plus grands musées au monde dédiés à une seule civilisation. Un chef-d'œuvre architectural moderne abritant des trésors inestimables de l'histoire égyptienne, situé à proximité des pyramides.",
        "mapsQuery": "Grand Musée Égyptien Gizeh"
      },
      {
        "id": "khan_el_khalili",
        "name": "Khan el-Khalili",
        "sub_category_key": "catMarkets",
        "sub_category": "Marchés traditionnels",
        "photo_url": "assets/caire/khan.jpg",
        "description": "Plongez dans l'effervescence du plus célèbre souk du Caire. Vieux de plus de 600 ans, ce dédale de ruelles étroites regorge d'ateliers d'artisans, de boutiques d'épices, de parfums, d'objets en cuivre et de bijoux artisanaux. C'est un voyage sensoriel où les cris des marchands, l'odeur du café à la cardamome et le cliquetis du métal créent une ambiance unique au monde, parfaite pour une immersion totale dans la culture cairote.",
        "mapsQuery": "Khan el-Khalili Le Caire"
      },
      {
        "id": "souk_el_fustat",
        "name": "Souk El-Fustat",
        "sub_category_key": "catMarkets",
        "sub_category": "Marchés traditionnels",
        "photo_url": "assets/caire/fustat.jpg",
        "description": "Situé près du musée national de la civilisation égyptienne, le Souk El-Fustat est le paradis de l'artisanat contemporain et traditionnel. Moins frénétique que Khan el-Khalili, ce marché met en avant la qualité du travail manuel égyptien, notamment la poterie, le textile et la verrerie soufflée.",
        "mapsQuery": "Souk El-Fustat Le Caire"
      },
      {
        "id": "palais_baron",
        "name": "Palais Baron Empain",
        "sub_category_key": "catArch",
        "sub_category": "Architecture",
        "photo_url": "assets/caire/baron.jpg",
        "description": "Un palais spectaculaire d'inspiration hindoue situé à Héliopolis. Son architecture unique et son histoire mystérieuse en font un lieu incontournable du Caire moderne.",
        "mapsQuery": "Palais Baron Empain Héliopolis"
      },
      {
        "id": "parc_al_azhar",
        "name": "Parc Al-Azhar",
        "sub_category_key": "catRelaxation",
        "sub_category": "Lieux de détente",
        "photo_url": "assets/caire/al.jpg",
        "description": "Un havre de paix verdoyant offrant une vue magnifique sur la Citadelle et le vieux Caire. Parfait pour une promenade relaxante loin du tumulte.",
        "mapsQuery": "Parc Al-Azhar Le Caire"
      },
      {
        "id": "le_nil",
        "name": "Le Nil",
        "sub_category_key": "catHistory",
        "sub_category": "Lieux historiques",
        "photo_url": "assets/caire/nil.jpg",
        "description": "Artère vitale de l'Égypte depuis l'Antiquité, le Nil est le cœur battant du Caire. Fleuve mythique, il a permis le développement de la civilisation pharaonique et continue aujourd'hui d'offrir des promenades en felouque inoubliables au coucher du soleil.",
        "mapsQuery": "Le Nil Le Caire"
      },
    ],
    'en': [
      {
        "id": "tour_caire",
        "name": "Cairo Tower",
        "sub_category_key": "catActivities",
        "sub_category": "Activities in Cairo",
        "photo_url": "assets/caire/tour.jpg",
        "description": "Standing 187 meters tall, the Cairo Tower is a modern icon of the city, often considered Egypt's equivalent of the Eiffel Tower. Built in reinforced concrete shaped like a lattice mashrabiya, it offers a 360-degree observation deck. It is the perfect location to admire the vastness of the capital, the winding Nile, and on a clear day, the Giza Pyramids on the horizon.",
        "mapsQuery": "Cairo Tower"
      },
      {
        "id": "pyramides_gizeh",
        "name": "Pyramids of Giza",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/pyramide.jpg",
        "description": "The only surviving Wonder of the Ancient World, the Pyramids of Khufu, Khafre, and Menkaure are the ultimate symbol of Egypt. Guarded by the majestic Great Sphinx, this monumental archaeological site stands as a testament to the architectural brilliance and religious devotion of Old Kingdom Pharaohs.",
        "mapsQuery": "Pyramids of Giza Cairo"
      },
      {
        "id": "citadelle_saladin",
        "name": "Citadel of Saladin",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/caire/saladin.jpg",
        "description": "Dominating the skyline from the heights of the Mokattam Hills, this medieval fortress built by Saladin in the 12th century is a masterpiece of Islamic architecture. It houses the famous Alabaster Mosque (Mosque of Muhammad Ali) and offers one of the best panoramic views over the entire city.",
        "mapsQuery": "Citadel of Saladin Cairo"
      },
      {
        "id": "quartier_copte",
        "name": "Coptic Quarter",
        "sub_category_key": "catHistory",
        "sub_category": "Historical Sites",
        "photo_url": "assets/caire/copte.jpg",
        "description": "Old Cairo houses the Coptic Quarter, a peaceful sanctuary rich in spiritual heritage. Here you will find the Hanging Church built over the Roman Fortress of Babylon, Ben Ezra Synagogue, and St. Sergius Church, where tradition holds the Holy Family sheltered during their flight to Egypt.",
        "mapsQuery": "Coptic Cairo"
      },
      {
        "id": "grand_musee_egyptien",
        "name": "Grand Egyptian Museum",
        "sub_category_key": "catHistory",
        "sub_category": "Historical Sites",
        "photo_url": "assets/caire/musee.jpg",
        "description": "One of the largest museum complexes in the world dedicated to a single civilization. A modern architectural masterpiece housing priceless treasures of Egyptian history, located near the Pyramids.",
        "mapsQuery": "Grand Egyptian Museum Giza"
      },
      {
        "id": "khan_el_khalili",
        "name": "Khan el-Khalili",
        "sub_category_key": "catMarkets",
        "sub_category": "Traditional Markets",
        "photo_url": "assets/caire/khan.jpg",
        "description": "Immerse yourself in the bustling atmosphere of Cairo's most famous bazaar. Over 600 years old, this labyrinth of narrow alleyways is filled with artisan workshops, spice shops, perfumes, copperware, and handcrafted jewelry, offering an authentic cultural immersion.",
        "mapsQuery": "Khan el-Khalili Cairo"
      },
      {
        "id": "souk_el_fustat",
        "name": "Souk El-Fustat",
        "sub_category_key": "catMarkets",
        "sub_category": "Traditional Markets",
        "photo_url": "assets/caire/fustat.jpg",
        "description": "Located near the National Museum of Egyptian Civilization, Souk El-Fustat is a center for traditional and modern Egyptian handicrafts. Quieter than Khan el-Khalili, it highlights fine handiwork such as pottery, textiles, and blown glass.",
        "mapsQuery": "Souk El-Fustat Cairo"
      },
      {
        "id": "palais_baron",
        "name": "Baron Empain Palace",
        "sub_category_key": "catArch",
        "sub_category": "Architecture",
        "photo_url": "assets/caire/baron.jpg",
        "description": "A striking Hindu-inspired mansion located in Heliopolis. Its unique architecture and intriguing history make it a fascinating landmark in modern Cairo.",
        "mapsQuery": "Baron Empain Palace Heliopolis"
      },
      {
        "id": "parc_al_azhar",
        "name": "Al-Azhar Park",
        "sub_category_key": "catRelaxation",
        "sub_category": "Relaxation Spots",
        "photo_url": "assets/caire/al.jpg",
        "description": "A lush, green haven of tranquility offering magnificent views of the Citadel and Historic Cairo. Perfect for a relaxing stroll away from the urban bustle.",
        "mapsQuery": "Al-Azhar Park Cairo"
      },
      {
        "id": "le_nil",
        "name": "The Nile",
        "sub_category_key": "catHistory",
        "sub_category": "Historical Sites",
        "photo_url": "assets/caire/nil.jpg",
        "description": "The vital lifeline of Egypt since ancient times, the Nile River is the beating heart of Cairo. This legendary river nurtured Pharaonic civilization and continues to offer unforgettable sunset felucca rides today.",
        "mapsQuery": "Nile River Cairo"
      },
    ],
    'ar': [
      {
        "id": "tour_caire",
        "name": "برج القاهرة",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة في القاهرة",
        "photo_url": "assets/caire/tour.jpg",
        "description": "يبلغ ارتفاع برج القاهرة 187 متراً، وهو رمز حديث للمدينة وشبيه ببرج إيفل بنكهة مصرية. تم بناؤه من الخرسانة المسلحة على شكل مشربية مصممة بعناية، ويضم منصة مراقبة بـ 360 درجة، مما يجعله المكان المثالي لمشاهدة النيل العظيم والأهرامات في الأفق.",
        "mapsQuery": "برج القاهرة"
      },
      {
        "id": "pyramides_gizeh",
        "name": "أهرامات الجيزة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/caire/pyramide.jpg",
        "description": "العجيبة الوحيدة المتبقية من عجائب العالم القديم، أهرامات خوفو وخفرع ومنقرع هي الرمز الأسمى لمصر. يحرس هذا الموقع الأثري المهيب تمثال أبو الهول، ليشهد على عبقرية العمارة والروحانية لدى الفراعنة.",
        "mapsQuery": "أهرامات الجيزة القاهرة"
      },
      {
        "id": "citadelle_saladin",
        "name": "قلعة صلاح الدين",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/caire/saladin.jpg",
        "description": "تطل هذه القلعة التي بناها صلاح الدين الأيوبي في القرن الثاني عشر على المدينة من أعالي تلال المقطم. وهي تحفة من تحف العمارة الإسلامية، وتضم مسجد محمد علي الشهير وتوفر إحدى أروع الإطلالات البانورامية على القاهرة.",
        "mapsQuery": "قلعة صلاح الدين القاهرة"
      },
      {
        "id": "quartier_copte",
        "name": "مجمع الأديان (الحي القبطي)",
        "sub_category_key": "catHistory",
        "sub_category": "الأماكن التاريخية",
        "photo_url": "assets/caire/copte.jpg",
        "description": "تخفي مصر القديمة في قلبها الحي القبطي التاريخي. يحتوي على الكنيسة المعلقة المبنية فوق حصن بابليون الروماني، وكنيسة أبي سرجة حيث أوت العائلة المقدسة، ومعبد بن عزرا اليهودي.",
        "mapsQuery": "الحي القبطي القاهرة"
      },
      {
        "id": "grand_musee_egyptien",
        "name": "المتحف المصري الكبير",
        "sub_category_key": "catHistory",
        "sub_category": "الأماكن التاريخية",
        "photo_url": "assets/caire/musee.jpg",
        "description": "أحد أكبر المتاحف في العالم المخصصة لحضارة واحدة. تحفة معمارية حديثة تضم كنوزاً لا تُقدر بثمن من التاريخ المصري بالقرب من أهرامات الجيزة.",
        "mapsQuery": "المتحف المصري الكبير الجيزة"
      },
      {
        "id": "khan_el_khalili",
        "name": "خان الخليلي",
        "sub_category_key": "catMarkets",
        "sub_category": "الأسواق التقليدية",
        "photo_url": "assets/caire/khan.jpg",
        "description": "انغمس في صخب أشهر سوق في القاهرة يعود تاريخه لأكثر من 600 عام. زقاق حافل بالورش الحرفية والمقاهي التاريخية والمجوهرات والمصنوعات النحاسية والتوابل والعطور.",
        "mapsQuery": "خان الخليلي القاهرة"
      },
      {
        "id": "souk_el_fustat",
        "name": "سوق الفسطاط",
        "sub_category_key": "catMarkets",
        "sub_category": "الأسواق التقليدية",
        "photo_url": "assets/caire/fustat.jpg",
        "description": "يقع بالقرب من المتحف القومي للحضارة المصرية، ويدعم الحرف اليدوية التقليدية والمعاصرة مثل الفخار والسيراميك والمنسوجات والزجاج المنفوخ.",
        "mapsQuery": "سوق الفسطاط القاهرة"
      },
      {
        "id": "palais_baron",
        "name": "قصر البارون إمبان",
        "sub_category_key": "catArch",
        "sub_category": "العمارة",
        "photo_url": "assets/caire/baron.jpg",
        "description": "قصر فريد مستوحى من المعابد الهندوسية يقع في حي مصر الجديدة. معمار أنيق وتاريخ ساحر يجعله معلماً استثنائياً في القاهرة.",
        "mapsQuery": "قصر البارون مصر الجديدة"
      },
      {
        "id": "parc_al_azhar",
        "name": "حديقة الأزهر",
        "sub_category_key": "catRelaxation",
        "sub_category": "أماكن الاسترخاء",
        "photo_url": "assets/caire/al.jpg",
        "description": "واحة خضراء هادئة توفر إطلالة ساحرة على قلعة صلاح الدين والقاهرة التاريخية، وتعتبر مكاناً مثالياً للتنزه والاسترخاء بعيداً عن صخب المدينة.",
        "mapsQuery": "حديقة الأزهر القاهرة"
      },
      {
        "id": "le_nil",
        "name": "نهر النيل",
        "sub_category_key": "catHistory",
        "sub_category": "الأماكن التاريخية",
        "photo_url": "assets/caire/nil.jpg",
        "description": "شريان الحياة في مصر منذ أقدم العصور والقلب النابض للقاهرة. جولات الفلوكة النيلية وقت غروب الشمس توفر تجربة لا تُنسى.",
        "mapsQuery": "نهر النيل القاهرة"
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _mainScrollController.addListener(() {
      final show = _mainScrollController.offset > 600;
      if (show != _showTop) setState(() => _showTop = show);
    });
    _chargerPrefs();
  }

  Future<void> _chargerPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langSauvegardee = prefs.getString('selected_language');
    final favs = prefs.getStringList('favorite_places') ?? <String>[];
    if (!mounted) return;
    setState(() {
      if (langSauvegardee != null &&
          _uiTranslations.containsKey(langSauvegardee)) {
        _lang = langSauvegardee;
      }
      _favs = favs.toSet();
    });
  }

  Future<void> _changerLangue(String nouvelleLangue) async {
    if (_lang == nouvelleLangue) return;
    HapticFeedback.selectionClick();
    setState(() => _lang = nouvelleLangue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', nouvelleLangue);
  }

  Future<void> _toggleFav(String id) async {
    HapticFeedback.lightImpact();
    setState(() {
      if (!_favs.remove(id)) _favs.add(id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_places', _favs.toList());
  }

  Future<void> _ouvrirMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('Impossible d\'ouvrir Google Maps');
      }
    } catch (e) {
      debugPrint('Erreur ouverture Maps : $e');
    }
  }

  // Palette monochrome : tout en or champagne
  Color _getCategoryColor(String categoryKey) => _C.gold;

  IconData _getCategoryIcon(String categoryKey) {
    switch (categoryKey) {
      case "catMonuments":
        return Icons.account_balance_outlined;
      case "catMarkets":
        return Icons.storefront_outlined;
      case "catHistory":
        return Icons.history_edu_outlined;
      case "catArch":
        return Icons.apartment_outlined;
      case "catRelaxation":
        return Icons.spa_outlined;
      case "catActivities":
        return Icons.attractions_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  String _getTranslatedText(String key) {
    return _uiTranslations[_lang]?[key] ?? _uiTranslations['fr']![key] ?? key;
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  // ───────────── Sélecteur de langue ─────────────
  Widget _buildLangSwitcher() {
    const codes = ['fr', 'en', 'ar'];
    const labels = ['FR', 'EN', 'AR'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _C.gold.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final active = _lang == codes[i];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _changerLangue(codes[i]),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color:
                            active ? _C.gold : _C.cream.withOpacity(0.6),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                          child: Text(labels[i]),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          height: 1,
                          width: active ? 16 : 0,
                          color: _C.gold,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ───────────── Onglets de filtre (texte + filet doré) ─────────────
  Widget _buildTab({
    required String id,
    required String label,
    IconData? icon,
  }) {
    final selected = _filter == id;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_filter == id) return;
          HapticFeedback.selectionClick();
          setState(() => _filter = id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 13,
                        color: selected
                            ? _C.gold
                            : _C.cream.withOpacity(0.5)),
                    const SizedBox(width: 7),
                  ],
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      color: selected ? _C.gold : _C.cream.withOpacity(0.55),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: _ls(context, 2.2),
                    ),
                    child: Text(label.toUpperCase()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                height: 1.5,
                width: selected ? 30 : 0,
                color: _C.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(Map<String, dynamic> item, Color color, IconData icon) {
    HapticFeedback.selectionClick();
    final isRtl = _lang == 'ar';
    final id = item['id'] as String;
    final extraAll = _placeExtras[id];
    final extra =
    (extraAll?[_lang] ?? extraAll?['fr']) as Map<String, dynamic>?;
    final relIds = ((extraAll?['related'] as List?) ?? const []).cast<String>();
    final all = _localizedCaireData[_lang] ?? _localizedCaireData['fr']!;
    final related = <Map<String, dynamic>>[
      for (final r in relIds) ...all.where((e) => e['id'] == r),
    ];
    final labels = <String, String>{
      for (final k in const [
        'about', 'overview', 'duration', 'bestTime', 'category',
        'highlights', 'didYouKnow', 'tip', 'seeAlso',
      ])
        k: _getTranslatedText(k),
    };
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: _PlaceDetailPage(
            item: item,
            color: color,
            icon: icon,
            mapsLabel: _getTranslatedText('mapsBtn'),
            isFav: _favs.contains(item['id']),
            onFav: () => _toggleFav(item['id'] as String),
            onMaps: () =>
                _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Le Caire"),
            labels: labels,
            extra: extra,
            related: related,
            onOpenRelated: (r) {
              final k = r['sub_category_key'] as String? ?? 'catHistory';
              _openDetail(r, _getCategoryColor(k), _getCategoryIcon(k));
            },
          ),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: child,
        ),
      ),
    );
  }

  Widget _wrap(Key key, Widget child) {
    return Center(
      key: key,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> currentData =
        _localizedCaireData[_lang] ?? _localizedCaireData['fr']!;
    final bool isRtl = _lang == 'ar';
    final double topPad = MediaQuery.of(context).padding.top;
    final double screenH = MediaQuery.of(context).size.height;
    final double heroH = (screenH * 0.82).clamp(500.0, 800.0).toDouble();

    // Catégories dans l'ordre d'apparition
    final List<String> catKeys = [];
    for (final item in currentData) {
      final k = item['sub_category_key'] as String? ?? 'catHistory';
      if (!catKeys.contains(k)) catKeys.add(k);
    }

    // Filtrage
    final List<Map<String, dynamic>> visible = currentData.where((item) {
      if (_filter == 'all') return true;
      if (_filter == 'fav') return _favs.contains(item['id']);
      return item['sub_category_key'] == _filter;
    }).toList();

    // Lignes (en-têtes + cartes)
    final List<_Entry> entries = [];
    if (_filter == 'all') {
      for (final k in catKeys) {
        final items =
        visible.where((e) => e['sub_category_key'] == k).toList();
        entries.add(_Entry(header: k, count: items.length));
        for (final it in items) {
          entries.add(_Entry(item: it));
        }
      }
    } else {
      for (final it in visible) {
        entries.add(_Entry(item: it));
      }
    }

    // Numérotation éditoriale des cartes (01, 02, 03…)
    final List<int> nums = [];
    int n = 0;
    for (final e in entries) {
      if (e.item != null) {
        n++;
        nums.add(n);
      } else {
        nums.add(0);
      }
    }

    final String ctxKey = '${_lang}_$_filter';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _C.bg,
        floatingActionButton: AnimatedScale(
          scale: _showTop ? 1 : 0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          child: FloatingActionButton.small(
            backgroundColor: _C.bg.withOpacity(0.92),
            foregroundColor: _C.gold,
            elevation: 0,
            hoverElevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            shape: CircleBorder(
              side: BorderSide(color: _C.gold.withOpacity(0.6)),
            ),
            onPressed: () => _mainScrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOutCubic,
            ),
            child: const Icon(Icons.keyboard_arrow_up_rounded, size: 26),
          ),
        ),
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: CustomScrollView(
            controller: _mainScrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Hero(
                  topPad: topPad,
                  height: heroH,
                  title: _getTranslatedText('pageTitle'),
                  tagline: _getTranslatedText('tagline'),
                  countText:
                  '${currentData.length} ${_getTranslatedText('places')}',
                  langSwitcher: _buildLangSwitcher(),
                  shimmer: _shimmer,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterBarDelegate(
                  topPad: topPad,
                  child: LayoutBuilder(
                    builder: (context, cons) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: cons.maxWidth),
                        child: SizedBox(
                          height: 64,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              _buildTab(
                                id: 'all',
                                label: _getTranslatedText('all'),
                              ),
                              _buildTab(
                                id: 'fav',
                                label: _getTranslatedText('favs'),
                                icon: Icons.favorite_border_rounded,
                              ),
                              ...catKeys.map(
                                    (k) => _buildTab(
                                  id: k,
                                  label: _getTranslatedText(k),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                sliver: entries.isEmpty
                    ? SliverToBoxAdapter(
                  child: _Reveal(
                    key: ValueKey('empty_$ctxKey'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 110, horizontal: 30),
                      child: Column(
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 46,
                              color: _C.gold.withOpacity(0.6)),
                          const SizedBox(height: 22),
                          const _Ornament(width: 110),
                          const SizedBox(height: 22),
                          Text(
                            _getTranslatedText('noFav'),
                            textAlign: TextAlign.center,
                            style: _serif(
                              context,
                              size: 20,
                              weight: FontWeight.w400,
                              color: _C.cream.withOpacity(0.75),
                              height: 1.7,
                              style: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final e = entries[i];
                      if (e.header != null) {
                        final k = e.header!;
                        return _wrap(
                          ValueKey('h_${ctxKey}_$k'),
                          _Reveal(
                            child: _SectionHeader(
                              title: _getTranslatedText(k),
                              countLabel:
                              '${e.count} ${_getTranslatedText('places')}',
                            ),
                          ),
                        );
                      }
                      final item = e.item!;
                      final k = item['sub_category_key'] as String? ??
                          'catHistory';
                      final id = item['id'] as String;
                      return _wrap(
                        ValueKey('c_${ctxKey}_$id'),
                        _Reveal(
                          delay:
                          Duration(milliseconds: math.min(i, 2) * 80),
                          dy: 44,
                          child: _PlaceCard(
                            item: item,
                            number: nums[i],
                            icon: _getCategoryIcon(k),
                            isFav: _favs.contains(id),
                            discoverLabel: _getTranslatedText('discover'),
                            onFav: () => _toggleFav(id),
                            onTap: () => _openDetail(
                                item, _getCategoryColor(k), _getCategoryIcon(k)),
                          ),
                        ),
                      );
                    },
                    childCount: entries.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _Footer(title: _getTranslatedText('pageTitle')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
//  OUTILS
// ─────────────────────────────────────────────────────────────

/// Le letterSpacing casse la liaison des lettres arabes : on l'annule en RTL.
double _ls(BuildContext c, double v) =>
    Directionality.of(c) == TextDirection.rtl ? 0 : v;

class _Entry {
  final String? header;
  final int count;
  final Map<String, dynamic>? item;
  _Entry({this.header, this.count = 0, this.item});
}

/// Apparition douce : fondu + glissement vers le haut, avec délai.
class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double dy;
  const _Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.dy = 36,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: _a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, widget.dy * (1 - _a.value)),
          child: child,
        ),
      ),
    );
  }
}

class _PlaceImage extends StatelessWidget {
  final String path;
  const _PlaceImage(this.path);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2017), Color(0xFF5A4122)],
          ),
        ),
        child: Center(
          child: Icon(Icons.landscape_outlined, color: _C.gold, size: 48),
        ),
      ),
    );
  }
}

/// Motif de losanges façon moucharabieh.
class _LatticePainter extends CustomPainter {
  final double opacity;
  _LatticePainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final p = Paint()
      ..color = _C.gold.withOpacity(opacity)
      ..strokeWidth = 0.8;
    const s = 46.0;
    for (double x = -size.height; x < size.width + size.height; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant _LatticePainter old) => old.opacity != opacity;
}


// ─────────────────────────────────────────────────────────────
//  TYPOGRAPHIE & ORNEMENTS
// ─────────────────────────────────────────────────────────────
const List<String> _serifFallback = [
  'Cormorant Garamond',
  'Playfair Display',
  'Georgia',
  'Times New Roman',
  'Noto Serif',
  'serif',
];

TextStyle _serif(
    BuildContext c, {
      required double size,
      FontWeight weight = FontWeight.w500,
      Color color = _C.cream,
      double height = 1.2,
      double ls = 0,
      FontStyle? style,
    }) =>
    TextStyle(
      fontFamily: 'Cormorant Garamond',
      fontFamilyFallback: _serifFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: _ls(c, ls),
      fontStyle: style,
    );

/// Filet doré – losange – filet doré.
class _Ornament extends StatelessWidget {
  final double width;
  const _Ornament({this.width = 140});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _C.gold.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(width: 6, height: 6, color: _C.gold),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_C.gold.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HERO PLEIN ÉCRAN (un bloc de la page : il défile comme sur un site)
// ─────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  final double topPad;
  final double height;
  final String title;
  final String tagline;
  final String countText;
  final Widget langSwitcher;
  final AnimationController shimmer;

  const _Hero({
    required this.topPad,
    required this.height,
    required this.title,
    required this.tagline,
    required this.countText,
    required this.langSwitcher,
    required this.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final titleSize = (w * 0.15).clamp(56.0, 118.0).toDouble();

    return SizedBox(
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo avec très lente respiration
            AnimatedBuilder(
              animation: shimmer,
              builder: (_, __) {
                final z = 1.08 + 0.04 * math.sin(shimmer.value * 2 * math.pi);
                return Transform.scale(
                  scale: z,
                  child: const _PlaceImage('assets/caire/pyramide.jpg'),
                );
              },
            ),
            // Voile cinéma, qui se fond dans le fond de la page
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x1A000000),
                    Color(0x66000000),
                    Color(0xFF0C0A09),
                  ],
                  stops: [0, 0.28, 0.62, 1],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _LatticePainter(0.035)),
              ),
            ),
            // Cadre doré fin
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, topPad + 74, 18, 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _C.gold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Contenu central
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 24,
              end: 24,
              bottom: 70,
              child: _HeroTitle(
                title: title,
                tagline: tagline,
                countText: countText,
                titleSize: titleSize,
                shimmer: shimmer,
              ),
            ),
            // Langues, en haut de la page
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: topPad + 14,
              end: 18,
              child: langSwitcher,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTitle extends StatelessWidget {
  final String title;
  final String tagline;
  final String countText;
  final double titleSize;
  final AnimationController shimmer;

  const _HeroTitle({
    required this.title,
    required this.tagline,
    required this.countText,
    required this.titleSize,
    required this.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 34 * (1 - v)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Ornament(width: 150),
              const SizedBox(height: 22),
              Text(
                countText.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _ls(context, 5),
                ),
              ),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: shimmer,
                builder: (_, child) => ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [_C.cream, _C.gold, _C.cream],
                    stops: [
                      (shimmer.value - 0.25).clamp(0.0, 1.0).toDouble(),
                      shimmer.value,
                      (shimmer.value + 0.25).clamp(0.0, 1.0).toDouble(),
                    ],
                  ).createShader(r),
                  child: child,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: _serif(
                    context,
                    size: titleSize,
                    weight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.0,
                    ls: 3,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tagline,
                textAlign: TextAlign.center,
                style: _serif(
                  context,
                  size: 22,
                  weight: FontWeight.w400,
                  color: _C.cream.withOpacity(0.92),
                  style: FontStyle.italic,
                  ls: 0.4,
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: 1,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_C.gold, _C.gold.withOpacity(0)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BARRE DE FILTRES ÉPINGLÉE
// ─────────────────────────────────────────────────────────────
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double topPad;
  _FilterBarDelegate({required this.child, this.topPad = 0});

  @override
  double get minExtent => 64 + topPad;
  @override
  double get maxExtent => 64 + topPad;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _C.bg.withOpacity(overlapsContent ? 0.9 : 0.97),
            border: Border(
              bottom: BorderSide(color: _C.gold.withOpacity(0.18)),
            ),
          ),
          padding: EdgeInsets.only(top: topPad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterBarDelegate old) => true;
}

// ─────────────────────────────────────────────────────────────
//  EN-TÊTE DE SECTION & PIED DE PAGE
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String countLabel;
  const _SectionHeader({required this.title, required this.countLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90, bottom: 28),
      child: Column(
        children: [
          const _Ornament(width: 120),
          const SizedBox(height: 26),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _serif(
              context,
              size: 40,
              weight: FontWeight.w500,
              height: 1.1,
              ls: 1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            countLabel.toUpperCase(),
            style: TextStyle(
              color: _C.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: _ls(context, 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String title;
  const _Footer({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, bottom: 130),
      child: Column(
        children: [
          const _Ornament(width: 160),
          const SizedBox(height: 24),
          Text(
            title.toUpperCase(),
            style: _serif(
              context,
              size: 18,
              weight: FontWeight.w600,
              color: _C.gold,
              ls: 7,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CARTE ÉDITORIALE
// ─────────────────────────────────────────────────────────────
class _PlaceCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int number;
  final IconData icon;
  final bool isFav;
  final String discoverLabel;
  final VoidCallback onFav;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.item,
    required this.number,
    required this.icon,
    required this.isFav,
    required this.discoverLabel,
    required this.onFav,
    required this.onTap,
  });

  @override
  State<_PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<_PlaceCard> {
  bool _hover = false;

  Widget _image(BuildContext context, double aspect) {
    final it = widget.item;
    final id = it['id'] as String;
    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScale(
              scale: _hover ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              child: Hero(
                tag: 'img_$id',
                child: _PlaceImage(it['photo_url'] ?? ''),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x59000000),
                  ],
                  stops: [0, 0.25, 0.7, 1],
                ),
              ),
            ),
            // Cadre doré intérieur
            Padding(
              padding: const EdgeInsets.all(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _C.gold.withOpacity(_hover ? 0.85 : 0.32),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 26,
              start: 28,
              child: Text(
                widget.number.toString().padLeft(2, '0'),
                style: _serif(
                  context,
                  size: 26,
                  weight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.92),
                  height: 1.0,
                  ls: 1,
                ),
              ),
            ),
            PositionedDirectional(
              top: 18,
              end: 20,
              child: _HeartButton(isFav: widget.isFav, onTap: widget.onFav),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(BuildContext context, {required bool wide}) {
    final it = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 28, height: 1, color: _C.gold),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                (it['sub_category'] ?? '').toString().toUpperCase(),
                style: TextStyle(
                  color: _C.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _ls(context, 2.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          it['name'] ?? '',
          style: _serif(
            context,
            size: wide ? 44 : 36,
            weight: FontWeight.w500,
            height: 1.08,
            ls: 0.2,
          ),
        ),
        const SizedBox(height: 22),
        Container(width: 48, height: 1, color: _C.gold.withOpacity(0.5)),
        const SizedBox(height: 22),
        Text(
          it['description'] ?? '',
          style: TextStyle(
            color: _C.cream.withOpacity(0.74),
            fontSize: 14.5,
            height: 1.9,
            letterSpacing: _ls(context, 0.15),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.discoverLabel.toUpperCase(),
              style: TextStyle(
                color: _C.gold,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: _ls(context, 2.8),
              ),
            ),
            const SizedBox(width: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              width: _hover ? 64 : 34,
              height: 1,
              color: _C.gold,
            ),
            const SizedBox(width: 6),
            const _DirectionalIcon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: _C.gold,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 820;
            if (wide) {
              final imageFirst = widget.number.isOdd;
              final img = Expanded(flex: 6, child: _image(context, 1.12));
              final txt = Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: _text(context, wide: true),
                ),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 38),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: imageFirst ? [img, txt] : [txt, img],
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _image(context, 0.86),
                      const SizedBox(height: 28),
                      _text(context, wide: false),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BOUTONS
// ─────────────────────────────────────────────────────────────
class _HeartButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onTap;
  const _HeartButton({required this.isFav, required this.onTap});

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  double _scale = 1;

  void _pop() {
    widget.onTap();
    setState(() => _scale = 1.35);
    Future.delayed(const Duration(milliseconds: 170), () {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pop,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.38),
                border: Border.all(color: _C.gold.withOpacity(0.55)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: Icon(
                  widget.isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(widget.isFav),
                  size: 18,
                  color: widget.isFav ? _C.gold : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.35),
                border: Border.all(color: _C.gold.withOpacity(0.5)),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _ShineButton({required this.label, required this.onTap});

  @override
  State<_ShineButton> createState() => _ShineButtonState();
}

class _ShineButtonState extends State<_ShineButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.98 : 1,
          duration: const Duration(milliseconds: 160),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [_C.goldDeep, _C.gold, _C.goldLight, _C.gold],
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.gold.withOpacity(0.28),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: LayoutBuilder(
                        builder: (_, cons) => AnimatedBuilder(
                          animation: _c,
                          builder: (_, __) => Stack(
                            children: [
                              Positioned(
                                left: -120 + (cons.maxWidth + 240) * _c.value,
                                top: 0,
                                bottom: 0,
                                width: 90,
                                child: Transform(
                                  transform: Matrix4.skewX(-0.4),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0),
                                          Colors.white.withOpacity(0.42),
                                          Colors.white.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Double filet intérieur
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: _C.ink.withOpacity(0.28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 58),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me_outlined,
                            color: _C.ink, size: 18),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _C.ink,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: _ls(context, 2.4),
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PAGE DÉTAIL
// ─────────────────────────────────────────────────────────────
class _PlaceDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color color;
  final IconData icon;
  final String mapsLabel;
  final bool isFav;
  final VoidCallback onFav;
  final VoidCallback onMaps;
  final Map<String, String> labels;
  final Map<String, dynamic>? extra;
  final List<Map<String, dynamic>> related;
  final ValueChanged<Map<String, dynamic>> onOpenRelated;

  const _PlaceDetailPage({
    required this.item,
    required this.color,
    required this.icon,
    required this.mapsLabel,
    required this.isFav,
    required this.onFav,
    required this.onMaps,
    required this.labels,
    required this.extra,
    required this.related,
    required this.onOpenRelated,
  });

  @override
  State<_PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<_PlaceDetailPage> {
  late bool _fav = widget.isFav;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final id = it['id'] as String;
    final size = MediaQuery.of(context).size;
    final heroH = (size.height * 0.68).clamp(440.0, 700.0).toDouble();
    final titleSize = (size.width * 0.11).clamp(38.0, 68.0).toDouble();

    return Scaffold(
      backgroundColor: _C.bg,
      extendBody: true,
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: WebScrollBehavior(),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: heroH,
                  backgroundColor: _C.bg,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leadingWidth: 70,
                  leading: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 18),
                    child: Center(
                      child: _GlassButton(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const _DirectionalIcon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 14),
                      child: Center(
                        child: _HeartButton(
                          isFav: _fav,
                          onTap: () {
                            widget.onFav();
                            setState(() => _fav = !_fav);
                          },
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'img_$id',
                          child: _PlaceImage(it['photo_url'] ?? ''),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x80000000),
                                Color(0x00000000),
                                Color(0x73000000),
                                Color(0xFF0C0A09),
                              ],
                              stops: [0, 0.25, 0.65, 1],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(28, 0, 28, 44),
                            child: _Reveal(
                              delay: const Duration(milliseconds: 250),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (it['sub_category'] ?? '')
                                        .toString()
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _C.gold,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: _ls(context, 4),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    it['name'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: _serif(
                                      context,
                                      size: titleSize,
                                      weight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1.05,
                                      ls: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _DetailBody(
                    item: it,
                    labels: widget.labels,
                    extra: widget.extra,
                    related: widget.related,
                    onOpenRelated: widget.onOpenRelated,
                  ),
                ),
              ],
            ),
          ),
          // Bouton Google Maps flottant
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    24, 40, 24, 22 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x000C0A09), Color(0xF20C0A09)],
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _ShineButton(
                      label: widget.mapsLabel,
                      onTap: widget.onMaps,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CORPS DE LA PAGE DÉTAIL (sections enrichies)
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 28, height: 1, color: _C.gold),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: _C.gold,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: _ls(context, 2.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _C.gold.withOpacity(0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: _C.cream.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _ls(context, 2.2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: _serif(
                context,
                size: 19,
                weight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  final int index;
  final String title;
  final String text;
  const _Highlight(
      {required this.index, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    const numerals = ['I', 'II', 'III', 'IV', 'V', 'VI'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              numerals[index % numerals.length],
              style: _serif(
                context,
                size: 30,
                weight: FontWeight.w400,
                color: _C.gold,
                height: 1.1,
                style: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _serif(
                    context,
                    size: 25,
                    weight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: _C.cream.withOpacity(0.72),
                    fontSize: 14.5,
                    height: 1.85,
                    letterSpacing: _ls(context, 0.15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DidYouKnow extends StatelessWidget {
  final String label;
  final String text;
  const _DidYouKnow({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 38),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: _C.gold.withOpacity(0.35)),
        ),
      ),
      child: Column(
        children: [
          Text(
            '“',
            style: _serif(
              context,
              size: 84,
              weight: FontWeight.w500,
              color: _C.gold,
              height: 1.0,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: _C.gold,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: _ls(context, 3.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: _serif(
              context,
              size: 22,
              weight: FontWeight.w400,
              color: _C.cream.withOpacity(0.92),
              height: 1.7,
              style: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String label;
  final String text;
  const _TipBox({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _C.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: _C.gold.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.lightbulb_outline_rounded,
                color: _C.gold, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: _C.gold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: _ls(context, 2.6),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: _C.cream.withOpacity(0.84),
                    fontSize: 14.5,
                    height: 1.8,
                    letterSpacing: _ls(context, 0.15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _RelatedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PlaceImage(item['photo_url'] ?? ''),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x33000000),
                        Color(0xE6000000),
                      ],
                      stops: [0.3, 0.55, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: _C.gold.withOpacity(0.35)),
                    ),
                  ),
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 22,
                  end: 22,
                  bottom: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (item['sub_category'] ?? '').toString().toUpperCase(),
                        style: TextStyle(
                          color: _C.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: _ls(context, 2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['name'] ?? '',
                        style: _serif(
                          context,
                          size: 23,
                          weight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, String> labels;
  final Map<String, dynamic>? extra;
  final List<Map<String, dynamic>> related;
  final ValueChanged<Map<String, dynamic>> onOpenRelated;

  const _DetailBody({
    required this.item,
    required this.labels,
    required this.extra,
    required this.related,
    required this.onOpenRelated,
  });

  String _l(String k) => labels[k] ?? k;

  @override
  Widget build(BuildContext context) {
    final List hl = (extra?['hl'] as List?) ?? const [];
    final String? fact = extra?['fact'] as String?;
    final String? tip = extra?['tip'] as String?;
    final String? duration = extra?['duration'] as String?;
    final String? best = extra?['best'] as String?;
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: _Reveal(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: _Ornament(width: 150)),
                    const SizedBox(height: 44),
                    _SectionLabel(_l('about')),
                    const SizedBox(height: 22),
                    Text(
                      item['description'] ?? '',
                      style: _serif(
                        context,
                        size: 19,
                        weight: FontWeight.w400,
                        color: _C.cream.withOpacity(0.86),
                        height: 1.95,
                        ls: 0.2,
                      ),
                    ),
                    if (duration != null || best != null) ...[
                      const SizedBox(height: 64),
                      _SectionLabel(_l('overview')),
                      const SizedBox(height: 14),
                      if (duration != null)
                        _InfoRow(label: _l('duration'), value: duration),
                      if (best != null)
                        _InfoRow(label: _l('bestTime'), value: best),
                      _InfoRow(
                        label: _l('category'),
                        value: (item['sub_category'] ?? '').toString(),
                      ),
                    ],
                    if (hl.isNotEmpty) ...[
                      const SizedBox(height: 70),
                      _SectionLabel(_l('highlights')),
                      const SizedBox(height: 34),
                      for (int i = 0; i < hl.length; i++)
                        _Highlight(
                          index: i,
                          title: (hl[i] as Map)['t'] as String,
                          text: (hl[i] as Map)['d'] as String,
                        ),
                    ],
                    if (fact != null) ...[
                      const SizedBox(height: 40),
                      _DidYouKnow(label: _l('didYouKnow'), text: fact),
                    ],
                    if (tip != null) ...[
                      const SizedBox(height: 40),
                      _TipBox(label: _l('tip'), text: tip),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (related.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                const _Ornament(width: 130),
                const SizedBox(height: 26),
                Text(
                  _l('seeAlso'),
                  textAlign: TextAlign.center,
                  style: _serif(context,
                      size: 38, weight: FontWeight.w500, ls: 1),
                ),
                const SizedBox(height: 34),
                SizedBox(
                  height: 300,
                  child: Builder(builder: (context) {
                    final total = related.length * 220.0 +
                        (related.length - 1) * 16.0;
                    final side = ((width - total) / 2)
                        .clamp(24.0, double.infinity)
                        .toDouble();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: side),
                      itemCount: related.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) => _RelatedCard(
                        item: related[i],
                        onTap: () => onOpenRelated(related[i]),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        const SizedBox(height: 200),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CONTENU ENRICHI DE LA PAGE DÉTAIL (par lieu et par langue)
// ─────────────────────────────────────────────────────────────
const Map<String, Map<String, dynamic>> _placeExtras = {
  'tour_caire': {
    'related': ['le_nil', 'pyramides_gizeh', 'parc_al_azhar'],
    'fr': {
      'duration': "1 h à 1 h 30",
      'best': "Au coucher du soleil",
      'tip': "Arrivez une heure avant le crépuscule : vous verrez la ville en pleine lumière, puis illuminée, sans avoir à monter deux fois.",
      'fact': "Inaugurée en 1961 et conçue par l'architecte Naoum Shebib, la tour a un treillis qui évoque la tige d'un lotus, symbole de l'Égypte antique.",
      'hl': [
        {'t': "Panorama à 360°", 'd': "La plateforme dévoile Le Caire d'un seul regard : îles du Nil, minarets, ponts et, par temps clair, les pyramides."},
        {'t': "Une icône de l'île de Gezira", 'd': "Elle s'élève au cœur de l'île, entourée de jardins et à quelques pas de l'Opéra du Caire."},
        {'t': "Un dîner avec vue", 'd': "Un restaurant panoramique au sommet permet de dîner tandis que toute la ville scintille en contrebas."},
      ],
    },
    'en': {
      'duration': "1 to 1.5 hours",
      'best': "At sunset",
      'tip': "Arrive an hour before dusk: you'll see the city in daylight, then lit up, without having to go up twice.",
      'fact': "Opened in 1961 and designed by architect Naoum Shebib, the tower's lattice evokes the stem of a lotus, a symbol of ancient Egypt.",
      'hl': [
        {'t': "360° panorama", 'd': "The viewing platform takes in all of Cairo at once: Nile islands, minarets, bridges and, on a clear day, the pyramids."},
        {'t': "An icon of Gezira Island", 'd': "It rises in the heart of the island, surrounded by gardens and a short walk from the Cairo Opera House."},
        {'t': "Dining with a view", 'd': "A panoramic restaurant at the top lets you enjoy a meal while the whole city glitters below."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعة ونصف",
      'best': "عند غروب الشمس",
      'tip': "احرص على الوصول قبل الغروب بساعة لتشاهد المدينة في ضوء النهار ثم وهي مضاءة، دون الحاجة إلى الصعود مرتين.",
      'fact': "افتُتح البرج عام 1961 وصممه المهندس نعوم شبيب، وتذكّر شبكته الهيكلية بساق زهرة اللوتس، رمز مصر القديمة.",
      'hl': [
        {'t': "إطلالة بانورامية 360°", 'd': "تكشف المنصة القاهرة بأكملها: جزر النيل والمآذن والجسور، وفي الأيام الصافية الأهرامات."},
        {'t': "رمز جزيرة الزمالك", 'd': "يقع في قلب الجزيرة وسط الحدائق، على بُعد خطوات من دار الأوبرا المصرية."},
        {'t': "عشاء مع إطلالة", 'd': "في الأعلى مطعم بانورامي يتيح لك تناول الطعام بينما تتلألأ المدينة تحت قدميك."},
      ],
    },
  },
  'pyramides_gizeh': {
    'related': ['grand_musee_egyptien', 'tour_caire', 'le_nil'],
    'fr': {
      'duration': "3 à 4 h",
      'best': "Dès l'ouverture, tôt le matin",
      'tip': "Emportez de l'eau, un chapeau et de la crème solaire, et convenez toujours du prix avant une balade à dos de chameau ou de cheval.",
      'fact': "La Grande Pyramide de Khéops, érigée vers 2560 av. J.-C., est restée la plus haute construction du monde pendant environ 3 800 ans.",
      'hl': [
        {'t': "La Grande Pyramide", 'd': "Haute d'environ 139 mètres aujourd'hui (146 à l'origine), elle est composée de plus de deux millions de blocs de pierre."},
        {'t': "Le Grand Sphinx", 'd': "Sculpté dans le roc, il mesure environ 73 mètres de long pour 20 mètres de haut et veille sur le plateau depuis plus de 4 500 ans."},
        {'t': "Un site classé à l'UNESCO", 'd': "Le plateau de Gizeh fait partie du site « Memphis et sa nécropole », inscrit au patrimoine mondial depuis 1979."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours",
      'best': "First thing in the morning",
      'tip': "Bring water, a hat and sunscreen, and always agree on a price before a camel or horse ride.",
      'fact': "The Great Pyramid of Khufu, built around 2560 BC, remained the tallest structure in the world for about 3,800 years.",
      'hl': [
        {'t': "The Great Pyramid", 'd': "About 139 metres tall today (146 originally), it is made of more than two million blocks of stone."},
        {'t': "The Great Sphinx", 'd': "Carved from bedrock, it is about 73 metres long and 20 metres high, and has watched over the plateau for more than 4,500 years."},
        {'t': "A UNESCO World Heritage Site", 'd': "The Giza plateau belongs to the “Memphis and its Necropolis” site, inscribed on the World Heritage List in 1979."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات",
      'best': "في الصباح الباكر عند الافتتاح",
      'tip': "خذ معك الماء وقبعة وواقيًا من الشمس، واتفق دائمًا على السعر قبل ركوب الجمل أو الحصان.",
      'fact': "ظل هرم خوفو الأكبر، الذي شُيّد نحو عام 2560 ق.م، أعلى بناء في العالم لنحو 3800 عام.",
      'hl': [
        {'t': "الهرم الأكبر", 'd': "يبلغ ارتفاعه اليوم نحو 139 مترًا (146 مترًا في الأصل)، ويتألف من أكثر من مليوني كتلة حجرية."},
        {'t': "أبو الهول", 'd': "منحوت في الصخر، يبلغ طوله نحو 73 مترًا وارتفاعه 20 مترًا، ويحرس الهضبة منذ أكثر من 4500 عام."},
        {'t': "موقع في قائمة اليونسكو", 'd': "تنتمي هضبة الجيزة إلى موقع «منف ومقبرتها» المدرج في قائمة التراث العالمي منذ عام 1979."},
      ],
    },
  },
  'citadelle_saladin': {
    'related': ['parc_al_azhar', 'khan_el_khalili', 'quartier_copte'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "Fin d'après-midi, pour la lumière dorée",
      'tip': "Pour entrer dans la mosquée de Mohamed Ali, portez une tenue couvrante (épaules et genoux) ; on se déchausse à l'entrée.",
      'fact': "Mohamed Ali a fait bâtir sa mosquée entre 1830 et 1848, en s'inspirant des grandes mosquées d'Istanbul. Son surnom d'« Albâtre » vient de la pierre qui revêt ses murs et sa cour.",
      'hl': [
        {'t': "La mosquée de Mohamed Ali", 'd': "Son dôme central et ses deux minarets effilés dominent la silhouette du Caire."},
        {'t': "Un panorama exceptionnel", 'd': "Depuis les terrasses, le regard embrasse la ville et, par temps clair, jusqu'aux pyramides."},
        {'t': "Plus de huit siècles d'histoire", 'd': "Fondée au XIIe siècle, la citadelle fut le siège du pouvoir pendant des siècles et abrite aujourd'hui plusieurs musées."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "Late afternoon, for the golden light",
      'tip': "To enter the Mohamed Ali Mosque, wear modest clothing (shoulders and knees covered); shoes are removed at the entrance.",
      'fact': "Mohamed Ali had his mosque built between 1830 and 1848, inspired by the great mosques of Istanbul. Its “Alabaster” nickname comes from the stone that clads its walls and courtyard.",
      'hl': [
        {'t': "The Mohamed Ali Mosque", 'd': "Its central dome and two slender minarets dominate Cairo's skyline."},
        {'t': "An exceptional panorama", 'd': "From the terraces, the view stretches across the city and, on clear days, to the pyramids."},
        {'t': "Over eight centuries of history", 'd': "Founded in the 12th century, the citadel was the seat of power for centuries and now houses several museums."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "وقت العصر حين يكون الضوء ذهبيًا",
      'tip': "لدخول مسجد محمد علي ارتدِ ملابس محتشمة تغطي الكتفين والركبتين، وتُخلع الأحذية عند المدخل.",
      'fact': "بنى محمد علي مسجده بين عامي 1830 و1848 متأثرًا بمساجد إسطنبول الكبرى، ويعود لقب «الألباستر» إلى الحجر الذي يكسو جدرانه وصحنه.",
      'hl': [
        {'t': "مسجد محمد علي", 'd': "تهيمن قبّته المركزية ومئذنتاه الرشيقتان على أفق القاهرة."},
        {'t': "إطلالة استثنائية", 'd': "من الشرفات تمتد الرؤية فوق المدينة، وحتى الأهرامات في الأيام الصافية."},
        {'t': "أكثر من ثمانية قرون من التاريخ", 'd': "أُسست القلعة في القرن الثاني عشر وكانت مقرّ الحكم لقرون، وتضم اليوم عدة متاحف."},
      ],
    },
  },
  'quartier_copte': {
    'related': ['souk_el_fustat', 'citadelle_saladin', 'le_nil'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "Le matin, quand le quartier est calme",
      'tip': "Les ruelles sont pavées et les églises demandent une tenue respectueuse : prévoyez des chaussures confortables.",
      'fact': "Les premières communautés chrétiennes d'Égypte remontent aux premiers siècles de notre ère ; le mot « copte » dérive du grec ancien désignant les Égyptiens.",
      'hl': [
        {'t': "L'église suspendue", 'd': "Bâtie sur les bastions d'une forteresse romaine, sa nef semble flotter au-dessus du sol."},
        {'t': "L'église Saint-Serge", 'd': "Selon la tradition, la Sainte Famille se serait abritée dans sa crypte lors de sa fuite en Égypte."},
        {'t': "La synagogue Ben Ezra", 'd': "L'un des plus anciens lieux de culte juifs d'Égypte, célèbre pour la découverte de la Geniza du Caire."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the morning, when the district is quiet",
      'tip': "The lanes are cobbled and the churches call for respectful dress, so bring comfortable shoes.",
      'fact': "Egypt's first Christian communities date back to the first centuries AD; the word “Copt” derives from the ancient Greek word for “Egyptian”.",
      'hl': [
        {'t': "The Hanging Church", 'd': "Built over the bastions of a Roman fortress, its nave seems to float above the ground."},
        {'t': "Saint Sergius Church", 'd': "According to tradition, the Holy Family sheltered in its crypt during the flight into Egypt."},
        {'t': "The Ben Ezra Synagogue", 'd': "One of the oldest Jewish places of worship in Egypt, famous for the discovery of the Cairo Geniza."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في الصباح حين يكون الحي هادئًا",
      'tip': "الأزقة مرصوفة بالحجارة والكنائس تتطلب لباسًا محتشمًا، لذا ارتدِ حذاءً مريحًا.",
      'fact': "تعود أولى الجماعات المسيحية في مصر إلى القرون الأولى للميلاد، وكلمة «قبطي» مشتقة من الكلمة اليونانية القديمة التي تعني «مصري».",
      'hl': [
        {'t': "الكنيسة المعلقة", 'd': "شُيّدت فوق أبراج حصن روماني، فيبدو صحنها كأنه معلّق في الهواء."},
        {'t': "كنيسة أبي سرجة", 'd': "وفق التقليد، لجأت العائلة المقدسة إلى سردابها أثناء رحلتها إلى مصر."},
        {'t': "معبد بن عزرا", 'd': "من أقدم المعابد اليهودية في مصر، اشتهر باكتشاف جنيزة القاهرة."},
      ],
    },
  },
  'grand_musee_egyptien': {
    'related': ['pyramides_gizeh', 'tour_caire', 'khan_el_khalili'],
    'fr': {
      'duration': "3 à 5 h",
      'best': "À l'ouverture, en semaine",
      'tip': "Réservez votre billet en ligne à l'avance et associez la visite aux pyramides, qui ne sont qu'à quelques minutes.",
      'fact': "Le musée réunit pour la première fois l'ensemble de la collection de Toutânkhamon, soit plus de 5 000 objets.",
      'hl': [
        {'t': "Le Grand Escalier", 'd': "Des dizaines de statues de pharaons et de divinités jalonnent la montée, comme une galerie sous verrière."},
        {'t': "Ramsès II en majesté", 'd': "Un colosse de plusieurs tonnes accueille les visiteurs dans le grand hall."},
        {'t': "Vue sur les pyramides", 'd': "De larges baies vitrées cadrent les pyramides de Gizeh à l'horizon."},
      ],
    },
    'en': {
      'duration': "3 to 5 hours",
      'best': "At opening time, on a weekday",
      'tip': "Book your ticket online in advance and pair the visit with the pyramids, only a few minutes away.",
      'fact': "The museum brings together, for the first time, the entire Tutankhamun collection: more than 5,000 objects.",
      'hl': [
        {'t': "The Grand Staircase", 'd': "Dozens of statues of pharaohs and gods line the climb, like a gallery under glass."},
        {'t': "Ramesses II in majesty", 'd': "A colossal statue weighing several tonnes greets visitors in the grand hall."},
        {'t': "Views of the pyramids", 'd': "Wide glass walls frame the Giza pyramids on the horizon."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 5 ساعات",
      'best': "عند الافتتاح في أيام الأسبوع",
      'tip': "احجز تذكرتك عبر الإنترنت مسبقًا، واجمع بين زيارة المتحف والأهرامات القريبة منه بدقائق.",
      'fact': "يجمع المتحف لأول مرة مجموعة توت عنخ آمون كاملة، وتضم أكثر من 5000 قطعة.",
      'hl': [
        {'t': "الدرج العظيم", 'd': "تصطف عشرات التماثيل للفراعنة والآلهة على امتداد الصعود، كأنه معرض تحت سقف زجاجي."},
        {'t': "رمسيس الثاني بكل مهابته", 'd': "يستقبل الزوار تمثال ضخم يزن عدة أطنان في القاعة الكبرى."},
        {'t': "إطلالة على الأهرامات", 'd': "تؤطر الواجهات الزجاجية الواسعة أهرامات الجيزة في الأفق."},
      ],
    },
  },
  'khan_el_khalili': {
    'related': ['citadelle_saladin', 'parc_al_azhar', 'souk_el_fustat'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "En fin de journée, quand la lumière s'adoucit",
      'tip': "Marchandez avec le sourire : le premier prix annoncé est rarement le prix final. Faites une pause thé au café El Fishawy.",
      'fact': "Le bazar a été fondé en 1382 ; le café El Fishawy, installé en son cœur, serait ouvert depuis le XVIIIe siècle.",
      'hl': [
        {'t': "Lanternes et cuivres", 'd': "Des centaines d'ateliers façonnent lanternes, plateaux ciselés et objets en laiton."},
        {'t': "Épices et parfums", 'd': "Hibiscus, safran, cumin, huiles parfumées : les étals embaument les ruelles."},
        {'t': "Le café El Fishawy", 'd': "Une halte mythique, thé à la menthe en main, souvent associée au prix Nobel Naguib Mahfouz."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "Late in the day, as the light softens",
      'tip': "Haggle with a smile: the first price is rarely the final one. Stop for tea at El Fishawy café.",
      'fact': "The bazaar was founded in 1382; El Fishawy café, in its heart, is said to have been open since the 18th century.",
      'hl': [
        {'t': "Lanterns and copperware", 'd': "Hundreds of workshops craft lanterns, engraved trays and brass objects."},
        {'t': "Spices and perfumes", 'd': "Hibiscus, saffron, cumin, scented oils: the stalls perfume the alleys."},
        {'t': "El Fishawy café", 'd': "A legendary stop, mint tea in hand, often associated with Nobel laureate Naguib Mahfouz."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في نهاية اليوم حين يلين الضوء",
      'tip': "فاصِل بابتسامة، فالسعر الأول نادرًا ما يكون النهائي، وخذ استراحة شاي في مقهى الفيشاوي.",
      'fact': "تأسس الخان عام 1382، ويُقال إن مقهى الفيشاوي في قلبه مفتوح منذ القرن الثامن عشر.",
      'hl': [
        {'t': "الفوانيس والنحاس", 'd': "مئات الورش تصنع الفوانيس والصواني المنقوشة والتحف النحاسية."},
        {'t': "التوابل والعطور", 'd': "الكركديه والزعفران والكمون والزيوت العطرية تملأ الأزقة برائحتها."},
        {'t': "مقهى الفيشاوي", 'd': "محطة أسطورية لشرب الشاي بالنعناع، ارتبط اسمها بالأديب الحائز على نوبل نجيب محفوظ."},
      ],
    },
  },
  'souk_el_fustat': {
    'related': ['quartier_copte', 'khan_el_khalili', 'le_nil'],
    'fr': {
      'duration': "1 h 30 à 2 h 30",
      'best': "Le matin ou en fin d'après-midi",
      'tip': "Combinez-le avec le musée national de la civilisation égyptienne, tout proche, pour une journée mêlant culture et artisanat.",
      'fact': "Fustat, fondée en 641, fut la première capitale de l'Égypte islamique et le berceau de ce qui deviendrait Le Caire.",
      'hl': [
        {'t': "Poterie et céramique", 'd': "Des ateliers présentent des pièces tournées à la main, aux motifs traditionnels et contemporains."},
        {'t': "Verre soufflé", 'd': "Vases et lampes en verre soufflé, façonnés par des artisans égyptiens."},
        {'t': "Textiles tissés", 'd': "Tapis, tissus et broderies mettent en avant un savoir-faire transmis de génération en génération."},
      ],
    },
    'en': {
      'duration': "1.5 to 2.5 hours",
      'best': "Morning or late afternoon",
      'tip': "Combine it with the nearby National Museum of Egyptian Civilization for a day of culture and craftsmanship.",
      'fact': "Fustat, founded in 641, was the first capital of Islamic Egypt and the cradle of what would become Cairo.",
      'hl': [
        {'t': "Pottery and ceramics", 'd': "Workshops present hand-thrown pieces with traditional and contemporary patterns."},
        {'t': "Blown glass", 'd': "Vases and lamps in blown glass, shaped by Egyptian craftspeople."},
        {'t': "Woven textiles", 'd': "Rugs, fabrics and embroidery showcase skills handed down through generations."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين ونصف",
      'best': "في الصباح أو وقت العصر",
      'tip': "اجمع بين زيارته والمتحف القومي للحضارة المصرية القريب منه لقضاء يوم يجمع الثقافة والحرف.",
      'fact': "كانت الفسطاط، التي تأسست عام 641، أول عاصمة لمصر الإسلامية ومهد ما ستصبح عليه القاهرة.",
      'hl': [
        {'t': "الفخار والخزف", 'd': "تعرض الورش قطعًا مصنوعة يدويًا بزخارف تقليدية ومعاصرة."},
        {'t': "الزجاج المنفوخ", 'd': "مزهريات ومصابيح من الزجاج المنفوخ يصنعها حرفيون مصريون."},
        {'t': "المنسوجات", 'd': "تبرز السجاجيد والأقمشة والتطريز مهارات تنتقل من جيل إلى جيل."},
      ],
    },
  },
  'palais_baron': {
    'related': ['tour_caire', 'khan_el_khalili', 'citadelle_saladin'],
    'fr': {
      'duration': "1 h à 2 h",
      'best': "En fin de journée, à l'heure dorée",
      'tip': "Associez la visite à une balade dans Héliopolis, quartier fondé par le baron Empain et riche en façades néo-mauresques.",
      'fact': "Construit entre 1907 et 1911 pour le baron belge Édouard Empain, le palais s'inspire des temples hindous et d'Angkor, au Cambodge. Le baron est aussi le fondateur d'Héliopolis.",
      'hl': [
        {'t': "Une architecture unique", 'd': "Éléphants sculptés, statues d'inspiration hindoue et colonnades : un décor qui détonne au cœur de l'Égypte."},
        {'t': "Un palais entouré de légendes", 'd': "Abandonné pendant des décennies, il a nourri rumeurs et récits de fantômes avant d'être restauré."},
        {'t': "Héliopolis", 'd': "Autour du palais, ce quartier élégant mêle avenues arborées et architecture néo-mauresque."},
      ],
    },
    'en': {
      'duration': "1 to 2 hours",
      'best': "Late in the day, at golden hour",
      'tip': "Pair the visit with a stroll through Heliopolis, the district founded by Baron Empain, rich in neo-Moorish façades.",
      'fact': "Built between 1907 and 1911 for Belgian Baron Édouard Empain, the palace draws on Hindu temples and Cambodia's Angkor. The baron also founded Heliopolis.",
      'hl': [
        {'t': "A unique architecture", 'd': "Carved elephants, Hindu-inspired statues and colonnades: a décor that stands out in the heart of Egypt."},
        {'t': "A palace wrapped in legends", 'd': "Abandoned for decades, it fed rumours and ghost stories before being restored."},
        {'t': "Heliopolis", 'd': "Around the palace, this elegant district blends tree-lined avenues with neo-Moorish architecture."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعتين",
      'best': "قبيل الغروب في الساعة الذهبية",
      'tip': "أضف إلى زيارتك جولة في مصر الجديدة (هليوبوليس) التي أسسها البارون، وتزخر بواجهات على الطراز المغربي الجديد.",
      'fact': "شُيّد القصر بين عامي 1907 و1911 للبارون البلجيكي إدوارد إمبان، مستلهمًا المعابد الهندوسية وأنغكور في كمبوديا، والبارون هو أيضًا مؤسس هليوبوليس.",
      'hl': [
        {'t': "عمارة فريدة", 'd': "فيلة منحوتة وتماثيل ذات طابع هندوسي وأعمدة: ديكور يبرز وسط مصر."},
        {'t': "قصر تحيط به الأساطير", 'd': "هُجر لعقود فأثار الشائعات وحكايات الأشباح قبل أن يُرمَّم."},
        {'t': "مصر الجديدة", 'd': "حول القصر، حي أنيق يجمع بين الشوارع المشجّرة والعمارة على الطراز المغربي الجديد."},
      ],
    },
  },
  'parc_al_azhar': {
    'related': ['citadelle_saladin', 'khan_el_khalili', 'quartier_copte'],
    'fr': {
      'duration': "1 h à 3 h",
      'best': "Fin d'après-midi, pour la vue sur la ville",
      'tip': "Apportez de quoi pique-niquer ou installez-vous dans un café avec vue sur la Citadelle.",
      'fact': "Aménagé sur d'anciennes collines de gravats et inauguré en 2005 grâce à l'Aga Khan Trust for Culture, le parc s'étend sur une trentaine d'hectares.",
      'hl': [
        {'t': "Des jardins d'inspiration islamique", 'd': "Bassins, fontaines et allées bordées d'arbres rappellent les jardins traditionnels."},
        {'t': "Les remparts ayyoubides", 'd': "Les travaux ont mis au jour un tronçon de l'ancienne muraille médiévale de la ville."},
        {'t': "Vue sur Le Caire historique", 'd': "Minarets, Citadelle et toits du vieux Caire se découvrent depuis les belvédères."},
      ],
    },
    'en': {
      'duration': "1 to 3 hours",
      'best': "Late afternoon, for the view of the city",
      'tip': "Bring a picnic or settle in at a café with a view over the Citadel.",
      'fact': "Created on former mounds of rubble and opened in 2005 thanks to the Aga Khan Trust for Culture, the park covers about thirty hectares.",
      'hl': [
        {'t': "Islamic-inspired gardens", 'd': "Pools, fountains and tree-lined paths recall traditional gardens."},
        {'t': "The Ayyubid walls", 'd': "The works uncovered a stretch of the city's old medieval wall."},
        {'t': "A view of historic Cairo", 'd': "Minarets, the Citadel and the old rooftops unfold from the viewpoints."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى 3 ساعات",
      'best': "وقت العصر للاستمتاع بإطلالة المدينة",
      'tip': "أحضر نزهة خفيفة أو اجلس في مقهى مطل على القلعة.",
      'fact': "أُقيمت الحديقة فوق تلال من الأنقاض القديمة وافتُتحت عام 2005 بفضل مؤسسة الآغا خان للثقافة، وتمتد على نحو ثلاثين هكتارًا.",
      'hl': [
        {'t': "حدائق مستوحاة من الطراز الإسلامي", 'd': "أحواض ونوافير وممرات تحفّها الأشجار تذكّر بالحدائق التقليدية."},
        {'t': "السور الأيوبي", 'd': "كشفت الأعمال عن جزء من سور المدينة الأيوبي القديم."},
        {'t': "إطلالة على القاهرة التاريخية", 'd': "تتكشف المآذن والقلعة وأسطح القاهرة القديمة من نقاط المشاهدة."},
      ],
    },
  },
  'le_nil': {
    'related': ['tour_caire', 'pyramides_gizeh', 'quartier_copte'],
    'fr': {
      'duration': "1 h (promenade en felouque)",
      'best': "Au coucher du soleil",
      'tip': "Convenez du prix et de la durée avant d'embarquer sur une felouque, et choisissez la fin de journée, quand la brise se lève.",
      'fact': "Avec environ 6 650 km, le Nil est l'un des plus longs fleuves du monde ; la grande majorité des Égyptiens vit encore sur ses rives.",
      'hl': [
        {'t': "La felouque au crépuscule", 'd': "Ces voiliers à voile triangulaire glissent en silence, au rythme du vent, face aux lumières de la ville."},
        {'t': "Berceau de la civilisation", 'd': "Chaque année, la crue du Nil fertilisait ses rives et a permis l'essor de l'Égypte pharaonique."},
        {'t': "La corniche", 'd': "Les quais du Caire, bordés de cafés et de promeneurs, s'animent le soir."},
      ],
    },
    'en': {
      'duration': "1 hour (felucca ride)",
      'best': "At sunset",
      'tip': "Agree on the price and duration before boarding a felucca, and go late in the day when the breeze rises.",
      'fact': "At about 6,650 km, the Nile is one of the longest rivers in the world; the vast majority of Egyptians still live along its banks.",
      'hl': [
        {'t': "A felucca at dusk", 'd': "These triangular-sailed boats glide silently with the wind, facing the city lights."},
        {'t': "Cradle of civilisation", 'd': "Each year the Nile's flood fertilised its banks and allowed pharaonic Egypt to flourish."},
        {'t': "The Corniche", 'd': "Cairo's embankments, lined with cafés and strollers, come alive in the evening."},
      ],
    },
    'ar': {
      'duration': "ساعة (جولة بالفلوكة)",
      'best': "عند غروب الشمس",
      'tip': "اتفق على السعر والمدة قبل ركوب الفلوكة، واختر آخر النهار حين يهبّ النسيم.",
      'fact': "يبلغ طول النيل نحو 6650 كم وهو من أطول أنهار العالم، ولا يزال معظم المصريين يعيشون على ضفافه.",
      'hl': [
        {'t': "فلوكة عند الغسق", 'd': "تنساب هذه المراكب ذات الشراع المثلث بصمت مع الريح أمام أضواء المدينة."},
        {'t': "مهد الحضارة", 'd': "كان فيضان النيل كل عام يخصب ضفافه ومكّن مصر الفرعونية من الازدهار."},
        {'t': "الكورنيش", 'd': "تنبض أرصفة القاهرة، التي تصطف عليها المقاهي والمتنزهون، بالحياة في المساء."},
      ],
    },
  },
};