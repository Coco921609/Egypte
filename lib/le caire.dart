import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// --- 1. CLASSE DE DÉFILEMENT WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

// --- 2. PAGE PRINCIPALE (LE CAIRE) ---
class LeCairePage extends StatefulWidget {
  const LeCairePage({super.key});

  @override
  State<LeCairePage> createState() => _LeCairePageState();
}

class _LeCairePageState extends State<LeCairePage> {
  final ScrollController _mainScrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Le Caire',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catMonuments': 'Monuments',
      'catMarkets': 'Marchés traditionnels',
      'catHistory': 'Lieux historiques',
      'catArch': 'Architecture',
      'catRelaxation': 'Lieux de détente',
      'catActivities': 'Activités au Caire',
    },
    'en': {
      'pageTitle': 'Cairo',
      'mapsBtn': 'Open in Google Maps',
      'catMonuments': 'Monuments',
      'catMarkets': 'Traditional Markets',
      'catHistory': 'Historical Sites',
      'catArch': 'Architecture',
      'catRelaxation': 'Relaxation Spots',
      'catActivities': 'Activities in Cairo',
    },
    'ar': {
      'pageTitle': 'القاهرة',
      'mapsBtn': 'الفتح في خرائط Google',
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
        "description": "Le Vieux-Caire cache en son sein le quartier copte, véritable sanctuaire de spiritualité. C'est ici que se trouve l'église suspendue, bâtie au-dessus des portes de la forteresse romaine de Babylone, ainsi que la synagogue Ben Ezra et l'église Saint-Serge, où, selon la tradition, la Sainte Famille aurait trouvé refuge lors de sa fuite en Égypte. Un lieu calme, charged d'histoire, loin du tumulte urbain.",
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
    _chargerLangue();
  }

  Future<void> _chargerLangue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langSauvegardee = prefs.getString('selected_language');
    setState(() {
      if (langSauvegardee != null && _uiTranslations.containsKey(langSauvegardee)) {
        _lang = langSauvegardee;
      }
    });
  }

  Future<void> _changerLangue(String nouvelleLangue) async {
    if (_lang == nouvelleLangue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', nouvelleLangue);
    setState(() {
      _lang = nouvelleLangue;
    });
  }

  Future<void> _ouvrirMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

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

  Color _getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case "catMonuments": return Colors.amber;
      case "catMarkets": return Colors.redAccent;
      case "catHistory": return Colors.blueAccent;
      case "catArch": return Colors.purpleAccent;
      case "catRelaxation": return Colors.greenAccent;
      case "catActivities": return const Color(0xFFD4AF37);
      default: return Colors.white;
    }
  }

  String _getTranslatedText(String key) {
    return _uiTranslations[_lang]?[key] ?? _uiTranslations['fr']![key] ?? key;
  }

  Widget _buildLangButton(String label, String langCode) {
    final bool isSelected = _lang == langCode;
    return GestureDetector(
      onTap: () => _changerLangue(langCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF222222),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> currentData = _localizedCaireData[_lang] ?? _localizedCaireData['fr']!;
    final bool isRtl = _lang == 'ar';

    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in currentData) {
      String catKey = item['sub_category_key'] ?? 'catHistory';
      groupedData.putIfAbsent(catKey, () => []).add(item);
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: CustomScrollView(
            controller: _mainScrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: false,
                backgroundColor: const Color(0xFF101010),
                title: Text(
                  _getTranslatedText('pageTitle'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        _buildLangButton('FR', 'fr'),
                        _buildLangButton('EN', 'en'),
                        _buildLangButton('AR', 'ar'),
                      ],
                    ),
                  ),
                ],
              ),
              ...groupedData.entries.map((entry) {
                String catKey = entry.key;
                String translatedCatTitle = _getTranslatedText(catKey);
                Color catColor = _getCategoryColor(catKey);

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                      child: Text(
                        translatedCatTitle.toUpperCase(),
                        style: TextStyle(
                          color: catColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) => _buildDesignCard(item, catColor)),
                  ]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignCard(Map<String, dynamic> item, Color color) {
    final String lieuNom = item['name'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              item['photo_url'] ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lieuNom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item['sub_category'] ?? '',
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  item['description'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Le Caire"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.navigation_outlined, size: 18),
                    label: Text(
                      _getTranslatedText('mapsBtn'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}