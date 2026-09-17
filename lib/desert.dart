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

// --- 2. PAGE PRINCIPALE (DÉSERTS) ---
class DesertPage extends StatefulWidget {
  const DesertPage({super.key});

  @override
  State<DesertPage> createState() => _DesertPageState();
}

class _DesertPageState extends State<DesertPage> {
  final ScrollController _scrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Déserts',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catDeserts': 'Les déserts : lieux à découvrir',
    },
    'en': {
      'pageTitle': 'Deserts',
      'mapsBtn': 'Open in Google Maps',
      'catDeserts': 'Deserts: Places to discover',
    },
    'ar': {
      'pageTitle': 'الصحاري',
      'mapsBtn': 'الفتح في خرائط Google',
      'catDeserts': 'الصحاري: أماكن للاكتشاف',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedDesertData = {
    'fr': [
      {
        "id": "desert_blanc",
        "name": "Désert Blanc",
        "sub_category_key": "catDeserts",
        "sub_category": "Les déserts : lieux à découvrir",
        "photo_url": "assets/desert/blanc.jpg",
        "description": "Observer les formations rocheuses blanches uniques, camper dans le désert et faire de la photographie paysagère.",
        "mapsQuery": "Désert Blanc Égypte"
      },
      {
        "id": "desert_noir",
        "name": "Désert Noir",
        "sub_category_key": "catDeserts",
        "sub_category": "Les déserts : lieux à découvrir",
        "photo_url": "assets/desert/noir.webp",
        "description": "Le désert Noir tire son nom des roches volcaniques noires qui couvrent ses collines. On peut y faire des excursions en 4×4, camper sous les étoiles et découvrir des paysages lunaires spectaculaires.",
        "mapsQuery": "Désert Noir Égypte"
      },
    ],
    'en': [
      {
        "id": "desert_blanc",
        "name": "White Desert",
        "sub_category_key": "catDeserts",
        "sub_category": "Deserts: Places to discover",
        "photo_url": "assets/desert/blanc.jpg",
        "description": "Observe unique white rock formations, camp in the desert, and enjoy landscape photography.",
        "mapsQuery": "White Desert Egypt"
      },
      {
        "id": "desert_noir",
        "name": "Black Desert",
        "sub_category_key": "catDeserts",
        "sub_category": "Deserts: Places to discover",
        "photo_url": "assets/desert/noir.webp",
        "description": "The Black Desert gets its name from the black volcanic rocks covering its hills. Visitors can enjoy 4x4 excursions, camp under the stars, and discover spectacular lunar landscapes.",
        "mapsQuery": "Black Desert Egypt"
      },
    ],
    'ar': [
      {
        "id": "desert_blanc",
        "name": "الصحراء البيضاء",
        "sub_category_key": "catDeserts",
        "sub_category": "الصحاري: أماكن للاكتشاف",
        "photo_url": "assets/desert/blanc.jpg",
        "description": "مراقبة التشكيلات الصخرية البيضاء الفريدة، التخييم في الصحراء والتقاط صور للمناظر الطبيعية.",
        "mapsQuery": "الصحراء البيضاء مصر"
      },
      {
        "id": "desert_noir",
        "name": "الصحراء السوداء",
        "sub_category_key": "catDeserts",
        "sub_category": "الصحاري: أماكن للاكتشاف",
        "photo_url": "assets/desert/noir.webp",
        "description": "تستمد الصحراء السوداء اسمها من الصخور البركانية السوداء التي تغطي تلالها. يمكن القيام برحلات الدفع الرباعي والتخييم تحت النجوم واكتشاف مناظر طبيعية تشبه سطح القمر.",
        "mapsQuery": "الصحراء السوداء مصر"
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
    final List<Map<String, dynamic>> currentData = _localizedDesertData[_lang] ?? _localizedDesertData['fr']!;
    final bool isRtl = _lang == 'ar';

    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in currentData) {
      String catKey = item['sub_category_key'] ?? 'catDeserts';
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

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                      child: Text(
                        translatedCatTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) => _buildDesignCard(item, Colors.orangeAccent)),
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

  Widget _buildDesignCard(Map<String, dynamic> item, Color color) {
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
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Égypte"),
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