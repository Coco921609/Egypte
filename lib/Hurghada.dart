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

// --- 2. PAGE PRINCIPALE (HURGHADA) ---
class HurghadaPage extends StatefulWidget {
  const HurghadaPage({super.key});

  @override
  State<HurghadaPage> createState() => _HurghadaPageState();
}

class _HurghadaPageState extends State<HurghadaPage> {
  final ScrollController _scrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Hurghada',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catActivities': 'Activités',
      'catSeaNature': 'Mer & Nature',
      'catRelaxNight': 'Détente & Vie nocturne',
    },
    'en': {
      'pageTitle': 'Hurghada',
      'mapsBtn': 'Open in Google Maps',
      'catActivities': 'Activities',
      'catSeaNature': 'Sea & Nature',
      'catRelaxNight': 'Relaxation & Nightlife',
    },
    'ar': {
      'pageTitle': 'الغردقة',
      'mapsBtn': 'الفتح في خرائط Google',
      'catActivities': 'أنشطة',
      'catSeaNature': 'بحر وطبيعة',
      'catRelaxNight': 'استرخاء وحياة ليلية',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedHurghadaData = {
    'fr': [
      {
        "id": "quad_safari",
        "name": "Safari en Quad dans le désert",
        "sub_category_key": "catActivities",
        "photo_url": "assets/hurgada/qaud.jpg",
        "description": "Vivez une expérience remplie d'adrénaline en pilotant un quad à travers les grands espaces du désert Oriental. Cette aventure vous emmène au cœur de paysages lunaires et de dunes dorées s'étendant à l'infini, avec une halte dans un camp bédouin authentique pour déguster un thé traditionnel et découvrir un mode de vie ancestral, loin de l'agitation touristique.",
        "mapsQuery": "Quad Safari Hurghada"
      },
      {
        "id": "giftun_island",
        "name": "Plongée à l'île de Giftoun",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/hurgada/ile.jpg",
        "description": "Véritable joyau de la mer Rouge, l'île de Giftoun est une réserve marine aux eaux turquoise cristallines. En plongeant dans ses sites célèbres, vous découvrirez des jardins de corail colorés d'une densité impressionnante et une vie marine abondante, des tortues de mer aux bancs de poissons tropicaux exotiques dans un écosystème d'une beauté préservée.",
        "mapsQuery": "Giftun Island Hurghada"
      },
      {
        "id": "hurghada_marina",
        "name": "La Marina de Hurghada",
        "sub_category_key": "catRelaxNight",
        "photo_url": "assets/hurgada/marina.webp",
        "description": "Symbole du renouveau moderne de Hurghada, la Marina est un lieu incontournable pour les amateurs d'élégance et de détente. Entre les yachts somptueux amarrés au port et les terrasses élégantes bordant le quai, c'est l'endroit parfait pour se promener en fin de journée, profiter de la brise marine, dîner dans des restaurants raffinés ou prolonger la soirée dans une ambiance chic et animée.",
        "mapsQuery": "Hurghada Marina"
      },
    ],
    'en': [
      {
        "id": "quad_safari",
        "name": "Desert Quad Bike Safari",
        "sub_category_key": "catActivities",
        "photo_url": "assets/hurgada/qaud.jpg",
        "description": "Experience an adrenaline-fueled adventure riding quad bikes through the vast wilderness of the Eastern Desert. Journey into the heart of moonlike landscapes and endless golden dunes, stopping at an authentic Bedouin camp to enjoy traditional tea and learn about an ancient way of life away from the crowds.",
        "mapsQuery": "Quad Safari Hurghada"
      },
      {
        "id": "giftun_island",
        "name": "Giftun Island Diving",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/hurgada/ile.jpg",
        "description": "A true jewel of the Red Sea, Giftun Island is a marine reserve with crystal-clear turquoise waters. Diving at its famous spots reveals vibrant coral gardens of breathtaking density and abundant marine life, from sea turtles to schools of exotic tropical fish in a pristine ecosystem.",
        "mapsQuery": "Giftun Island Hurghada"
      },
      {
        "id": "hurghada_marina",
        "name": "Hurghada Marina",
        "sub_category_key": "catRelaxNight",
        "photo_url": "assets/hurgada/marina.webp",
        "description": "A symbol of Hurghada's modern elegance, the Marina is a must-visit spot for relaxation and luxury. Lined with lavish yachts and stylish waterfront terraces, it is the perfect place for an evening stroll, enjoying sea breezes, dining at fine restaurants, or relaxing in a vibrant atmosphere.",
        "mapsQuery": "Hurghada Marina"
      },
    ],
    'ar': [
      {
        "id": "quad_safari",
        "name": "سفاري بالدراجات الرباعية في الصحراء",
        "sub_category_key": "catActivities",
        "photo_url": "assets/hurgada/qaud.jpg",
        "description": "عش تجربة مليئة بالأدرينالين أثناء قيادة الدراجات الرباعية عبر البراري في الصحراء الشرقية. تأخذك هذه المغامرة إلى قلب المناظر الطبيعية التي تشبه سطح القمر والكثبان الذهبية الممتدة إلى ما لا نهاية، مع التوقف في مخيم بدوي أصيل للاستمتاع بشاي تقليدي واكتشاف أسلوب حياة عريق، بعيداً عن صخب السياحة.",
        "mapsQuery": "Quad Safari Hurghada"
      },
      {
        "id": "giftun_island",
        "name": "الغوص في جزيرة جفتون",
        "sub_category_key": "catSeaNature",
        "photo_url": "assets/hurgada/ile.jpg",
        "description": "جوهرة حقيقية في البحر الأحمر، جزيرة جفتون هي محمية بحرية ذات مياه فيروزية صافية. عند الغوص في مواقعها الشهيرة، ستكتشف حدائق مرجانية ملونة ذات كثافة مذهلة، وحياة بحرية وفيرة، من السلاحف البحرية إلى أسراب الأسماك الاستوائية الغريبة في نظام بيئي ذي جمال أصيل.",
        "mapsQuery": "Giftun Island Hurghada"
      },
      {
        "id": "hurghada_marina",
        "name": "مارينا الغردقة",
        "sub_category_key": "catRelaxNight",
        "photo_url": "assets/hurgada/marina.webp",
        "description": "رمز التجديد الحديث للغردقة، المارينا مكان لا بد من زيارته لمحبي الفخامة والرفاهية. بين اليخوت الفاخرة الراسية في الميناء والشرفات الأنيقة المطلة على الرصيف، هو المكان المثالي للتنزه في نهاية اليوم، والاستمتاع بنسيم البحر، وتناول العشاء في مطاعم راقية أو تمديد السهرة في أجواء أنيقة وحيوية.",
        "mapsQuery": "Hurghada Marina"
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

  Future<void> _ouvrirGoogleMaps(String query) async {
    final String encodedQuery = Uri.encodeComponent(query);
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Impossible d\'ouvrir la carte pour : $query -> $e');
    }
  }

  Color _getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case "catActivities": return Colors.redAccent;
      case "catSeaNature": return Colors.blueAccent;
      case "catRelaxNight": return Colors.purpleAccent;
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
    final List<Map<String, dynamic>> currentData = _localizedHurghadaData[_lang] ?? _localizedHurghadaData['fr']!;
    final bool isRtl = _lang == 'ar';

    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in currentData) {
      String catKey = item['sub_category_key'] ?? 'catActivities';
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _ouvrirGoogleMaps(item['mapsQuery'] ?? "${item['name']} Hurghada"),
                    icon: const Icon(Icons.map_rounded, color: Colors.black87),
                    label: Text(
                      _getTranslatedText('mapsBtn'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color == Colors.white ? const Color(0xFF57E1AD) : color,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
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