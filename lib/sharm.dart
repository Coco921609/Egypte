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

// --- 2. PAGE PRINCIPALE (SHARM EL-SHEIKH) ---
class SharmElSheikhPage extends StatefulWidget {
  const SharmElSheikhPage({super.key});

  @override
  State<SharmElSheikhPage> createState() => _SharmElSheikhPageState();
}

class _SharmElSheikhPageState extends State<SharmElSheikhPage> {
  final ScrollController _scrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Sharm El-Sheikh',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catMonuments': 'Monuments & Culture',
      'catExcursions': 'Excursions incontournables',
      'catSeaNature': 'Mer & Nature',
    },
    'en': {
      'pageTitle': 'Sharm El-Sheikh',
      'mapsBtn': 'Open in Google Maps',
      'catMonuments': 'Monuments & Culture',
      'catExcursions': 'Must-See Excursions',
      'catSeaNature': 'Sea & Nature',
    },
    'ar': {
      'pageTitle': 'شرم الشيخ',
      'mapsBtn': 'الفتح في خرائط Google',
      'catMonuments': 'المعالم والثقافة',
      'catExcursions': 'رحلات لا بد منها',
      'catSeaNature': 'البحر والطبيعة',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedSharmData = {
    'fr': [
      {
        "id": "mosque",
        "name": "La mosquée Al Sahaba",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "Située au cœur de la vieille ville, cette mosquée est un véritable chef-d'œuvre architectural. Alliant avec élégance les styles ottoman, fatimide et mamelouk, elle impressionne par ses détails complexes et sa silhouette imposante. Lorsque la nuit tombe, son éclairage savamment étudié sublime ses façades et ses minarets, créant une atmosphère mystique et majestueuse qui attire les visiteurs du monde entier.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "L'Église Copte Orthodoxe",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "Cette église est un joyau de sérénité et de beauté spirituelle. Ses vitraux aux couleurs vibrantes projettent des jeux de lumière fascinants à l'intérieur, tandis que ses fresques murales détaillées racontent avec précision la riche tradition copte égyptienne. C'est un havre de paix essentiel pour ceux qui souhaitent découvrir la profondeur culturelle et chrétienne de la région, loin du tumulte balnéaire.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "Hollywood Sharm El-Sheikh",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/h.jpg",
        "description": "Véritable parc à thème spectaculaire, ce lieu unique transporte les visiteurs dans un univers fantastique. Entre les répliques géantes de statues célèbres, les fontaines dansantes chorégraphiées et les installations lumineuses féeriques, c'est une destination incontournable pour les familles et les amateurs de photographie. L'ambiance y est constamment animée, offrant une expérience ludique et totalement dépaysante.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "La Vieille Ville",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/la.jpg",
        "description": "Le Vieux Marché représente le cœur battant et historique de Sharm El-Sheikh. C’est un labyrinthe vivant de ruelles où l'on découvre l'essence même de la culture locale. Entre les étals d'artisanat traditionnel, les épices aux parfums envoûtants et les boutiques de souvenirs, le visiteur s'immerge dans une ambiance authentique. C'est l'endroit rêvé pour goûter à la gastronomie égyptienne et échanger avec les commerçants dans une atmosphère chaleureuse.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "Le monastère Sainte-Catherine",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/saint.webp",
        "description": "Niché au pied des montagnes grandioses du Sinaï, ce monastère est l'un des plus anciens lieux de culte chrétien encore en activité dans le monde. Classé au patrimoine mondial, il abrite une collection inestimable d'icônes byzantines, de manuscrits anciens et le célèbre 'Buisson Ardent'. Une visite ici est un voyage dans le temps, imprégné de spiritualité et d'une histoire séculaire qui semble figée dans le désert.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "Le mont Sinaï",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "Lieu chargé d'une puissance symbolique immense, le mont Sinaï est la destination par excellence des pèlerins et randonneurs. L'ascension, traditionnellement effectuée de nuit pour atteindre le sommet avant l'aube, est une épreuve physique récompensée par un lever de soleil spectaculaire. Voir la lumière embraser les cimes désertiques depuis ce sommet historique offre un moment de contemplation rare et une expérience visuelle absolument inoubliable.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "Dahab",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "Ancien village de pêcheurs devenu un repaire mythique pour les voyageurs en quête de liberté, Dahab possède une atmosphère bohème unique. Réputée mondialement pour son rythme de vie détendu et ses sites de plongée d'exception, la ville est une étape incontournable. Son mélange de culture bédouine et de mode de vie décontracté en bord de mer, couplé à la proximité de sites naturels grandioses, en fait une destination fascinante.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "L’île de Tiran",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "L'île de Tiran est un véritable sanctuaire pour les amoureux de la mer. Située à l'embouchure du golfe d'Aqaba, elle est entourée de récifs coralliens parmi les plus préservés et les plus riches de la mer Rouge. Ses eaux d'une clarté incroyable permettent d'observer une faune marine dense, incluant des tortues marines, des raies et une multitude de poissons tropicaux, faisant de chaque excursion une aventure immersive dans un aquarium naturel à ciel ouvert.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "La mer",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "La mer Rouge, véritable joyau de l'Égypte, offre des conditions de baignade et de plongée inégalées. Avec ses eaux turquoise dont la température est idéale toute l'année et une biodiversité marine d'une richesse rare au monde, elle constitue le terrain de jeu favori des plongeurs. Explorer ses fonds marins, c'est plonger dans un univers de coraux colorés et de vie sauvage où le spectacle sous-marin est un émerveillement constant.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "Dahab Blue Hole",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "Le Blue Hole de Dahab est un site légendaire qui exerce une fascination magnétique sur tous les plongeurs du globe. Il s'agit d'un gouffre sous-marin naturel d'une profondeur vertigineuse, entouré de récifs coralliens d'une densité incroyable. La transition brutale entre le bleu lagon peu profond et le bleu profond et mystérieux de l'abîme offre un spectacle visuel saisissant, faisant de cet endroit un défi et un rêve pour les passionnés d'exploration sous-marine.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
    'en': [
      {
        "id": "mosque",
        "name": "Al Sahaba Mosque",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "Located in the heart of the Old Town, this mosque is a true architectural masterpiece. Elegantly blending Ottoman, Fatimid, and Mamluk styles, it impresses with intricate details and a grand silhouette. At night, thoughtfully designed lighting highlights its facades and minarets, creating a mystical and majestic atmosphere.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "Coptic Orthodox Church",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "This church is a sanctuary of serenity and spiritual beauty. Vibrant stained-glass windows cast fascinating light patterns inside, while detailed wall frescoes meticulously tell the rich story of Egyptian Coptic tradition. It offers a peaceful retreat for those wishing to discover the region's deep spiritual heritage.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "Hollywood Sharm El-Sheikh",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/h.jpg",
        "description": "A spectacular theme park, this unique attraction transports visitors into a world of fantasy. Featuring giant replicas of iconic statues, choreographed dancing fountains, and magical light displays, it is a must-visit for families and photography enthusiasts seeking lively entertainment.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "Old Town Market",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/la.jpg",
        "description": "The Old Market is the vibrant, historic heart of Sharm El-Sheikh. A lively maze of alleys where you can experience the true essence of local culture. Surrounded by traditional crafts, fragrant spice stalls, and souvenir shops, visitors immerse themselves in an authentic atmosphere and local cuisine.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "Saint Catherine's Monastery",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/saint.webp",
        "description": "Nestled at the foot of Mount Sinai, this UNESCO World Heritage site is one of the oldest continuously operating Christian monasteries in the world. It houses an invaluable collection of Byzantine icons, ancient manuscripts, and the famous 'Burning Bush', offering a profound journey through spiritual history.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "Mount Sinai",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "A site of immense symbolic importance, Mount Sinai is a revered destination for pilgrims and hikers. Typically climbed overnight to reach the summit before dawn, hikers are rewarded with a breathtaking sunrise igniting the desert peaks in a truly unforgettable spectacle.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "Dahab",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "Once a quiet fishing village, Dahab has evolved into a famous coastal haven with a unique bohemian vibe. Renowned for its laid-back lifestyle and world-class diving sites, it seamlessly blends Bedouin tradition with relaxed seaside charm.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "Tiran Island",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "Tiran Island is a marine sanctuary situated at the mouth of the Gulf of Aqaba. Surrounded by pristine coral reefs teeming with marine life—including sea turtles, rays, and vibrant tropical fish—it offers unparalleled snorkeling and diving in a natural open-air aquarium.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "The Red Sea",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "The Red Sea is Egypt's coastal crown jewel, offering world-class swimming, snorkeling, and diving conditions. With warm turquoise waters year-round and rich marine biodiversity, exploring its coral gardens is a constantly breathtaking underwater adventure.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "Dahab Blue Hole",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "The Dahab Blue Hole is a world-renowned submarine sinkhole that fascinates divers globally. Dropping into dizzying depths and framed by dense coral walls, the dramatic shift from shallow turquoise lagoon to abyssal deep blue creates a thrilling underwater landmark.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
    'ar': [
      {
        "id": "mosque",
        "name": "مسجد الصحابة",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "يقع هذا المسجد في قلب المدينة القديمة، ويُعد شاهكاراً معمارياً حقيقياً. يجمع بأناقة بين الأنماط العثمانية والفاطمية والمملوكية، ويثير الإعجاب بتفاصيله المعقدة ومأذنتيه الشامختين. عند حلول الليل، تبرز إضاءته المدروسة بعناية واجهاته ومآذنه، مما يخلق أجواءً ساحرة ومجيدة تجذب الزوار من جميع أنحاء العالم.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "الكنيسة القبطية الأرثوذكسية",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "تعتبر هذه الكنيسة جوهرة من الهدوء والجمال الروحي. تعكس زجاجياتها الملونة الزاهية ألعاباً ضوئية ساحرة بالداخل، بينما تحكي جدارياتها المفصلة بدقة التقاليد القبطية المصرية الغنية. إنها واحة من السلام لمن يرغب في اكتشاف العمق الثقافي والروحي للمنطقة.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "هوليوود شرم الشيخ",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/h.jpg",
        "description": "متنزّه ترفيهي مذهل ينقل الزوار إلى عالم خيالي حافل بالإثارة. يضم مجسمات عملاقة لتماثيل شهيرة، ونوافير راقصة ومجسمات مضيئة ساحرة، مما يجعله وجهة مثالية للعائلات ومحبي التصوير الفوتوغرافي للاستمتاع بأجواء مليئة بالبهجة والمرح.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "المدينة القديمة",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/sharm/la.jpg",
        "description": "يمثل السوق القديم النابض بالحياة القلب التاريخي لشرم الشيخ. إنه متاهة حية من الأزقة المليئة بالمصنوعات اليدوية التقليدية والتوابل العطرة ومتاجر الهدايا التذكارية، حيث ينغمس الزائر في أجواء أصلية ويتذوق أفضل المأكولات المصرية.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "دير سانت كاترين",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/saint.webp",
        "description": "يقع هذا الدير عند قدم جبال سيناء الشامخة، وهو أحد أقدم الأديرة المسيحية المأهولة في العالم. مدرج ضمن التراث العالمي لليونسكو، ويضم مجموعة لا تُقدر بثمن من الأيقونات البيزنطية والمخطوطات القديمة بالإضافة إلى الشجيرة المشتعلة الشهيرة.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "جبل سيناء",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "مكان ذو أهمية رمزية وروحية عظيمة، ويُعد وجهة ممتازة للحجاج ومحبي تسلق الجبال. تتم الصعود عادةً ليلاً للوصول إلى القمة قبل الفجر، حيث يُكافأ الصاعدون بمشهد شروق شمس مذهل يضيء قمم الصحراء في لحظة تأمل لا تُنسى.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "دهب",
        "sub_category_key": "catExcursions",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "قرية صيادين سابقة تحولت إلى ملاذ شهير للمسافرين الباحثين عن الهدوء والحرية. تتميز دهب بأجوائها البوهيمية الفريدة وشواطئها الخلابة ومواقع الغوص العالمية، حيث تمزج بين الثقافة البدوية وأسلوب الحياة الاسترخائي على البحر.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "جزيرة تيران",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "تعتبر جزيرة تيران محمية طبيعية لعشاق البحر. تقع عند مدخل خليج العقبة وتحيط بها شعاب مرجانية من الأجمل والأكثر تنوعاً في البحر الأحمر، حيث تتيح مياهها الكريستالية رؤية السلاحف البحرية والكائنات البحرية الملونة.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "البحر الأحمر",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "البحر الأحمر هو الجوهرة الساحلية لمصر، ويوفر أروع ظروف السباحة والغوص على مدار العام. بفضل مياهه الفيروزية الدافئة وتنوعه البيولوجي الغني، يُعد الاستكشاف تحت الماء رحلة مذهلة بين الشعاب المرجانية والأحياء البحرية.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "الثقب الأزرق بدهب",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "يُعد الثقب الأزرق في دهب موقعاً أسطورياً يجذب الغواصين من جميع أنحاء العالم. وهو حفرة عميقة تحت الماء محاطة بالشعاب المرجانية، ويتيح التباين المذهل بين الأزرق الفاتح والأزرق الداكن للعمق تجربة غوص فريدة وساحرة.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
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
      case "catExcursions": return Colors.purpleAccent;
      case "catSeaNature": return Colors.blueAccent;
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> currentData = _localizedSharmData[_lang] ?? _localizedSharmData['fr']!;
    final bool isRtl = _lang == 'ar';

    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in currentData) {
      String catKey = item['sub_category_key'] ?? 'catMonuments';
      groupedData.putIfAbsent(catKey, () => []).add(item);
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: CustomScrollView(
            controller: _scrollController,
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
                    ...entry.value.map((item) => _buildDesignCard(item, catColor, catKey)),
                  ]),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignCard(Map<String, dynamic> item, Color color, String catKey) {
    final String lieuNom = item['name'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            blurRadius: 0,
            spreadRadius: 1.5,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.black,
              child: Image.asset(
                item['photo_url'] ?? '',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
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
                  _getTranslatedText(catKey),
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Sharm El-Sheikh"),
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