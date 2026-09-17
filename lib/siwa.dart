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

// --- 2. PAGE PRINCIPALE (SIWA) ---
class SiwaPage extends StatefulWidget {
  const SiwaPage({super.key});

  @override
  State<SiwaPage> createState() => _SiwaPageState();
}

class _SiwaPageState extends State<SiwaPage> {
  final ScrollController _mainScrollController = ScrollController();

  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Siwa',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catOasis': 'Oasis : lieux et activités à découvrir',
    },
    'en': {
      'pageTitle': 'Siwa',
      'mapsBtn': 'Open in Google Maps',
      'catOasis': 'Oasis: places and activities to discover',
    },
    'ar': {
      'pageTitle': 'سيوة',
      'mapsBtn': 'الفتح في خرائط Google',
      'catOasis': 'الواحة: أماكن وأنشطة للاكتشاف',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedSiwaData = {
    'fr': [
      {
        "id": "cleopatra_bath",
        "name": "Le bain de Cléopâtre",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/bain.jpg",
        "map_url": "https://maps.google.com/?q=Cleopatra+Bath+Siwa",
        "description": "Le bain de Cléopâtre est une source naturelle d'eau douce à Siwa. On peut s'y baigner dans un cadre désertique unique et découvrir l'une des piscines naturelles les plus célèbres d'Égypte."
      },
      {
        "id": "gebel_al_mawta",
        "name": "Gebel al-Mawta",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/siw.jpg",
        "map_url": "https://maps.google.com/?q=Gebel+al-Mawta+Siwa",
        "description": "Gebel al-Mawta, la montagne des morts, est un site archéologique unique à Siwa. On peut y explorer des tombeaux rupestres datant de l'époque ptolémaïque et admirer les peintures et hiéroglyphes anciens."
      },
      {
        "id": "salt_lakes",
        "name": "Les lacs de sel",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/sel.jpg",
        "map_url": "https://maps.google.com/?q=Salt+Lakes+Siwa",
        "description": "Les lacs de sel de Siwa, dont le célèbre lac Zeitoun, permettent de flotter naturellement comme dans la mer Morte. Une expérience unique dans un cadre désertique spectaculaire."
      },
    ],
    'en': [
      {
        "id": "cleopatra_bath",
        "name": "Cleopatra's Bath",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/bain.jpg",
        "map_url": "https://maps.google.com/?q=Cleopatra+Bath+Siwa",
        "description": "Cleopatra's Bath is a natural freshwater spring in Siwa. Visitors can swim in a unique desert setting and discover one of Egypt's most famous natural pools."
      },
      {
        "id": "gebel_al_mawta",
        "name": "Gebel al-Mawta",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/siw.jpg",
        "map_url": "https://maps.google.com/?q=Gebel+al-Mawta+Siwa",
        "description": "Gebel al-Mawta, the Mountain of the Dead, is a unique archaeological site in Siwa. Visitors can explore rock-cut tombs dating back to the Ptolemaic period and admire ancient paintings and hieroglyphs."
      },
      {
        "id": "salt_lakes",
        "name": "Salt Lakes",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/sel.jpg",
        "map_url": "https://maps.google.com/?q=Salt+Lakes+Siwa",
        "description": "The salt lakes of Siwa, including the famous Lake Zeitoun, allow you to float naturally just like in the Dead Sea. A unique experience in a spectacular desert landscape."
      },
    ],
    'ar': [
      {
        "id": "cleopatra_bath",
        "name": "حمام كليوباترا",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/bain.jpg",
        "map_url": "https://maps.google.com/?q=Cleopatra+Bath+Siwa",
        "description": "حمام كليوباترا هو ينبوع طبيعي للمياه العذبة في سيوة. يمكن للزوار السباحة فيه وسط أكتناف الصحراء الفريدة واكتشاف واحدة من أشهر حمامات السباحة الطبيعية في مصر."
      },
      {
        "id": "gebel_al_mawta",
        "name": "جبل الموتى",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/siw.jpg",
        "map_url": "https://maps.google.com/?q=Gebel+al-Mawta+Siwa",
        "description": "جبل الموتى هو موقع أثري فريد في سيوة. يمكن للزوار استكشاف المقابر الصخرية التي تعود إلى العصر البطلمي وملاحظة اللوحات والهيروغليفية القديمة."
      },
      {
        "id": "salt_lakes",
        "name": "بحيرات الملح",
        "sub_category_key": "catOasis",
        "photo_url": "assets/siwa/sel.jpg",
        "map_url": "https://maps.google.com/?q=Salt+Lakes+Siwa",
        "description": "تتيح بحيرات الملح في سيوة، بما في ذلك بحيرة زيتون الشهيرة، الطفو بشكل طبيعي كما هو الحال في البحر الميت. تجربة فريدة في وسط مناظر صحراوية خلابة."
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

  Future<void> _openMap(String mapUrl) async {
    final Uri uri = Uri.parse(mapUrl);
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Erreur d\'ouverture de la carte : $e');
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
    final List<Map<String, dynamic>> currentData = _localizedSiwaData[_lang] ?? _localizedSiwaData['fr']!;
    final bool isRtl = _lang == 'ar';

    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in currentData) {
      String catKey = item['sub_category_key'] ?? 'catOasis';
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

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                      child: Text(
                        translatedCatTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) => _buildDesignCard(item, Colors.amber)),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openMap(item['map_url'] ?? ''),
                    icon: const Icon(Icons.map_outlined, size: 18, color: Colors.black),
                    label: Text(
                      _getTranslatedText('mapsBtn'),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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