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

// --- 2. PAGE PRINCIPALE (FAYOUM) ---
class FayoumPage extends StatefulWidget {
  const FayoumPage({super.key});

  @override
  State<FayoumPage> createState() => _FayoumPageState();
}

class _FayoumPageState extends State<FayoumPage> {
  final ScrollController _scrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Fayoum',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catActivities': 'Les activités à faire à Fayoum',
    },
    'en': {
      'pageTitle': 'Fayoum',
      'mapsBtn': 'Open in Google Maps',
      'catActivities': 'Activities to do in Fayoum',
    },
    'ar': {
      'pageTitle': 'الفيوم',
      'mapsBtn': 'الفتح في خرائط Google',
      'catActivities': 'أنشطة يمكن القيام بها في الفيوم',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedFayoumData = {
    'fr': [
      {
        "id": "cascades_wadi_el_rayan",
        "name": "Cascades de Wadi El-Rayan",
        "sub_category_key": "catActivities",
        "sub_category": "Les activités à faire à Fayoum",
        "photo_url": "assets/fayoum/cascade.jpg",
        "description": "Les cascades de Wadi El-Rayan sont les seules cascades naturelles d'Égypte. On peut y admirer deux lacs reliés par une cascade, se promener dans le désert et profiter de paysages spectaculaires entre dunes et eau.",
        "mapsQuery": "Wadi El Rayan Cascades Fayoum"
      },
      {
        "id": "oasis_de_tunis",
        "name": "Oasis de Tunis",
        "sub_category_key": "catActivities",
        "sub_category": "Les activités à faire à Fayoum",
        "photo_url": "assets/fayoum/tunis.webp",
        "description": "Le village de Tunis est un petit village d'artistes niché au bord du lac Qarun. On peut y découvrir des ateliers de poterie, se promener dans les ruelles colorées et profiter d'une vue magnifique sur le lac.",
        "mapsQuery": "Tunis Village Fayoum"
      },
      {
        "id": "lac_qarun",
        "name": "Lac Qarun",
        "sub_category_key": "catActivities",
        "sub_category": "Les activités à faire à Fayoum",
        "photo_url": "assets/fayoum/lac.jpg",
        "description": "Le lac Qarun est l'un des plus anciens lacs naturels du monde. On peut y faire des balades en bateau, observer les oiseaux migrateurs et profiter du paysage désertique autour du lac.",
        "mapsQuery": "Lac Qarun Fayoum"
      },
    ],
    'en': [
      {
        "id": "cascades_wadi_el_rayan",
        "name": "Wadi El-Rayan Waterfalls",
        "sub_category_key": "catActivities",
        "sub_category": "Activities to do in Fayoum",
        "photo_url": "assets/fayoum/cascade.jpg",
        "description": "The Wadi El-Rayan waterfalls are the only natural waterfalls in Egypt. You can admire two lakes connected by a waterfall, walk in the desert, and enjoy spectacular landscapes between sand dunes and water.",
        "mapsQuery": "Wadi El Rayan Waterfalls Fayoum"
      },
      {
        "id": "oasis_de_tunis",
        "name": "Tunis Village",
        "sub_category_key": "catActivities",
        "sub_category": "Activities to do in Fayoum",
        "photo_url": "assets/fayoum/tunis.webp",
        "description": "Tunis Village is a small artists' village nestled along Lake Qarun. Visitors can explore pottery workshops, stroll through colorful alleys, and enjoy a magnificent view of the lake.",
        "mapsQuery": "Tunis Village Fayoum"
      },
      {
        "id": "lac_qarun",
        "name": "Lake Qarun",
        "sub_category_key": "catActivities",
        "sub_category": "Activities to do in Fayoum",
        "photo_url": "assets/fayoum/lac.jpg",
        "description": "Lake Qarun is one of the oldest natural lakes in the world. Visitors can enjoy boat rides, observe migratory birds, and take in the surrounding desert landscape.",
        "mapsQuery": "Lake Qarun Fayoum"
      },
    ],
    'ar': [
      {
        "id": "cascades_wadi_el_rayan",
        "name": "شلالات وادي الريان",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة يمكن القيام بها في الفيوم",
        "photo_url": "assets/fayoum/cascade.jpg",
        "description": "تعد شلالات وادي الريان الشلالات الطبيعية الوحيدة في مصر. يمكنك الاستمتاع ببحيرتين تربطهما شلالات، والتنزه في الصحراء والاستمتاع بالمناظر الطبيعية الخلابة بين الكثبان الرملية والمياه.",
        "mapsQuery": "شلالات وادي الريان الفيوم"
      },
      {
        "id": "oasis_de_tunis",
        "name": "قرية تونس",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة يمكن القيام بها في الفيوم",
        "photo_url": "assets/fayoum/tunis.webp",
        "description": "قرية تونس هي قرية صغيرة للفنانين تقع على ضفاف بحيرة قارون. يمكن استكشاف ورش الخزف والفخار، والتجول في الأزقة الملونة، والاستمتاع بإطلالة رائعة على البحيرة.",
        "mapsQuery": "قرية تونس الفيوم"
      },
      {
        "id": "lac_qarun",
        "name": "بحيرة قارون",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة يمكن القيام بها في الفيوم",
        "photo_url": "assets/fayoum/lac.jpg",
        "description": "تعتبر بحيرة قارون واحدة من أقدم البحيرات الطبيعية في العالم. يمكن القيام برحلات بالقوارب، ومراقبة الطيور المهاجرة، والاستمتاع بالمناظر الصحراوية المحيطة بالبحيرة.",
        "mapsQuery": "بحيرة قارون الفيوم"
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
    final List<Map<String, dynamic>> currentData = _localizedFayoumData[_lang] ?? _localizedFayoumData['fr']!;
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

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                      child: Text(
                        translatedCatTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) => _buildDesignCard(item, Colors.tealAccent)),
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
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Fayoum"),
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