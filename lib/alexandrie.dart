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

// --- 2. PAGE PRINCIPALE (ALEXANDRIE) ---
class AlexandriePage extends StatefulWidget {
  const AlexandriePage({super.key});

  @override
  State<AlexandriePage> createState() => _AlexandriePageState();
}

class _AlexandriePageState extends State<AlexandriePage> {
  final ScrollController _mainScrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DES INTERFACES ET CATEGORIES ---
  final Map<String, Map<String, String>> _uiText = {
    'fr': {
      'pageTitle': 'Alexandrie',
      'openMaps': 'Ouvrir dans Google Maps',
      'subCatMonuments': 'Monuments historiques',
      'subCatActivities': 'Activités incontournables',
      'subCatHistorical': 'Lieux historiques',
      'subCatCulture': 'Culture et Savoir',
    },
    'en': {
      'pageTitle': 'Alexandria',
      'openMaps': 'Open in Google Maps',
      'subCatMonuments': 'Historical Monuments',
      'subCatActivities': 'Must-do Activities',
      'subCatHistorical': 'Historical Places',
      'subCatCulture': 'Culture and Knowledge',
    },
    'ar': {
      'pageTitle': 'الإسكندرية',
      'openMaps': 'افتح في خرائط Google',
      'subCatMonuments': 'معالم تاريخية',
      'subCatActivities': 'أنشطة لا بد منها',
      'subCatHistorical': 'أماكن تاريخية',
      'subCatCulture': 'الثقافة والمعرفة',
    },
  };

  @override
  void initState() {
    super.initState();
    _chargerLangue();
  }

  Future<void> _chargerLangue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLang = prefs.getString('selected_language');
    setState(() {
      if (savedLang != null && _uiText.containsKey(savedLang)) {
        _lang = savedLang;
      }
    });
  }

  Future<void> _changerLangue(String newLang) async {
    if (newLang == _lang) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLang);
    setState(() {
      _lang = newLang;
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
      case 'subCatMonuments':
        return Colors.amber;
      case 'subCatActivities':
        return Colors.greenAccent;
      case 'subCatHistorical':
        return Colors.blueAccent;
      case 'subCatCulture':
        return Colors.blueAccent;
      default:
        return Colors.white;
    }
  }

  // --- DONNÉES LOCALISÉES EN 3 LANGUES SANS MÉLANGE ---
  List<Map<String, dynamic>> _getAlexandrieData() {
    final t = _uiText[_lang] ?? _uiText['fr']!;

    if (_lang == 'en') {
      return [
        {
          "id": "citadelle_qaitbay",
          "name": "Citadel of Qaitbay",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/qai.jpg",
          "description": "Built in the 15th century on the ruins of the legendary Lighthouse of Alexandria—one of the Seven Wonders of the Ancient World—this limestone defensive fortress offers a fascinating dive into Egyptian military history. Its massive ramparts, washed by the Mediterranean waves, reflect Sultan Qaitbay's defensive strategy.",
          "mapsQuery": "Citadel of Qaitbay Alexandria",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "corniche_pont_stanley",
          "name": "The Corniche and Stanley Bridge",
          "categoryKey": "subCatActivities",
          "sub_category": t['subCatActivities'],
          "photo_url": "assets/alexendrie/pont.jpg",
          "description": "A vital and poetic artery of Alexandria, the Corniche stretches along the Mediterranean shoreline for several kilometers, offering a unique panorama blending urban modernity and historical nostalgia. Stanley Bridge, with its distinctive towers, is the jewel of this promenade, especially at sunset.",
          "mapsQuery": "Stanley Bridge Alexandria",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "palais_montaza",
          "name": "Montaza Palace",
          "categoryKey": "subCatHistorical",
          "sub_category": t['subCatHistorical'],
          "photo_url": "assets/alexendrie/palais.jpeg",
          "description": "A true haven of peace, the Montaza Royal Complex spans acres of lush gardens overlooking the sea. The central palace, inspired by a bold blend of Florentine and Ottoman styles, once served as a summer residence for the Egyptian royal family.",
          "mapsQuery": "Montaza Palace Alexandria",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "bibliotheque_alexandrina",
          "name": "Bibliotheca Alexandrina",
          "categoryKey": "subCatCulture",
          "sub_category": t['subCatCulture'],
          "photo_url": "assets/alexendrie/alexandrina.jpg",
          "description": "More than just a building, the new Library of Alexandria is a monument to universal knowledge, designed to revive the spirit of the ancient library. Its bold architecture, shaped like a tilted sun disk plunging into a water basin, symbolizes a rising sun over the sea.",
          "mapsQuery": "Bibliotheca Alexandrina Alexandria",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "amphitheatre_kom_el_dick",
          "name": "Kom El-Dikka Amphitheatre",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/dick.jpg",
          "description": "Discovered by chance in 1960, this remarkably well-preserved small Roman theatre is the only one of its kind in Egypt. With marble seats and granite columns, it bears witness to social and cultural life during the Greco-Roman era.",
          "mapsQuery": "Kom El Dikka Alexandria",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "colonne_pompee",
          "name": "Pompey's Pillar",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/pompe.jpg",
          "description": "Standing proudly on a hill, this monolithic red Aswan granite column is a marvel of ancient engineering. Reaching nearly 27 meters in height, it is the sole surviving ruin of the majestic Serapeum temple.",
          "mapsQuery": "Pompey's Pillar Alexandria",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
      ];
    } else if (_lang == 'ar') {
      return [
        {
          "id": "citadelle_qaitbay",
          "name": "قلعة قايتباي",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/qai.jpg",
          "description": "بُنيت هذه القلعة الدفاعية من الحجر الجيري في القرن الخامس عشر على أنقاض منارة الإسكندرية الأسطورية، إحدى عجائب العالم القديم السبع. تقدم القلعة رحلة ساحرة في التاريخ العسكري المصري، وتعتبر أسوارها الضخمة المطلة على البحر الأبيض المتوسط شاهداً على الاستراتيجية الدفاعية للسلطان قايتباي.",
          "mapsQuery": "قلعة قايتباي الإسكندرية",
          "region": "Villes Historiques",
          "subFolder": "الإسكندرية"
        },
        {
          "id": "corniche_pont_stanley",
          "name": "الكورنيش وكوبري ستانلي",
          "categoryKey": "subCatActivities",
          "sub_category": t['subCatActivities'],
          "photo_url": "assets/alexendrie/pont.jpg",
          "description": "تعد الكورنيش الشريان الحيوي والشاعرية لمدينة الإسكندرية، حيث يمتد لعدة كيلومترات على طول ساحل البحر الأبيض المتوسط، مظهراً مزيجاً فريداً بين الحداثة والعراقة. ويمثل كوبري ستانلي بأبراجه المميزة جوهرة هذه النزهة، خاصة عند غروب الشمس.",
          "mapsQuery": "كوبري ستانلي الإسكندرية",
          "region": "Villes Historiques",
          "subFolder": "الإسكندرية"
        },
        {
          "id": "palais_montaza",
          "name": "قصر المنتزه",
          "categoryKey": "subCatHistorical",
          "sub_category": t['subCatHistorical'],
          "photo_url": "assets/alexendrie/palais.jpeg",
          "description": "واحة حقيقية من الهدوء، يمتد مجمع المنتزه الملكي على مساحات شاسعة من الحدائق الغناء المطلة على البحر. كان القصر المركزي، المستوحى من مزيج فريد من الطرازين الفلورنسي والعثماني، مقراً صيفياً للعائلة الملكية المصرية.",
          "mapsQuery": "قصر المنتزه الإسكندرية",
          "region": "Villes Historiques",
          "subFolder": "الإسكندرية"
        },
        {
          "id": "bibliotheque_alexandrina",
          "name": "مكتبة الإسكندرية",
          "categoryKey": "subCatCulture",
          "sub_category": t['subCatCulture'],
          "photo_url": "assets/alexendrie/alexandrina.jpg",
          "description": "أكثر من مجرد مبنى، تعد مكتبة الإسكندرية الجديدة صرحاً للمعرفة العالمية كُتب لإعادة إحياء روح المكتبة القديمة. يرمز تصميمها المعماري الجريء على شكل قرص شمس مائل ينغمس في بحيرة مائية إلى شروق الشمس من البحر.",
          "mapsQuery": "مكتبة الإسكندرية",
          "region": "Villes Historiques",
          "subFolder": "الإسكندرية"
        },
        {
          "id": "amphitheatre_kom_el_dick",
          "name": "المدرج الروماني بكوم الدكة",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/dick.jpg",
          "description": "اكتُشف بالصدفة عام 1960، ويُعد هذا المدرج الروماني الصغير المحفوظ بشكل رائع الوحيد من نوعه في مصر. بمدرجاته الرخامية وأعمدته الجرانيتية، يشهد على ازدهار الحياة الاجتماعية والثقافية في العصر اليوناني الروماني.",
          "mapsQuery": "كوم الدكة الإسكندرية",
          "region": "Villes Historiques",
          "subFolder": "الإسكندرية"
        },
        {
          "id": "colonne_pompee",
          "name": "عمود السواري",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/pompe.jpg",
          "description": "ينتصب هذا العمود المنفرد المصنوع من الجرانيت الأحمر لأسوان على تلة مرتفعة كإنجاز هندسي قديم. يبلغ ارتفاعه نحو 27 متراً، وهو الأثر الوحيد الباقي من معبد السيرابيوم المجيد.",
          "mapsQuery": "عمود السواري الإسكندرية",
          "region": "Villes Historiques",
          "subFolder": "الإسكندرية"
        },
      ];
    } else {
      // Français
      return [
        {
          "id": "citadelle_qaitbay",
          "name": "Citadelle de Qaitbay",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/qai.jpg",
          "description": "Érigée au XVe siècle sur les vestiges du mythique Phare d'Alexandrie, l'une des sept merveilles du monde antique, cette forteresse défensive en pierre calcaire offre une plongée fascinante dans l'histoire militaire égyptienne. Ses remparts massifs, baignés par les vagues de la Méditerranée, témoignent de la stratégie défensive du sultan Qaitbay face aux menaces ottomanes de l'époque.",
          "mapsQuery": "Citadelle de Qaitbay Alexandrie",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "corniche_pont_stanley",
          "name": "La Corniche et le pont Stanley",
          "categoryKey": "subCatActivities",
          "sub_category": t['subCatActivities'],
          "photo_url": "assets/alexendrie/pont.jpg",
          "description": "Artère vitale et poétique d'Alexandrie, la Corniche s'étire le long du rivage méditerranéen sur plusieurs kilomètres, offrant un panorama unique où se mêlent modernité urbaine et nostalgie historique. Le pont Stanley, avec ses tours caractéristiques, constitue le joyau de cette balade, particulièrement au coucher du soleil lorsque les lumières scintillent sur l'eau, capturant l'essence même de la 'Perle de la Méditerranée'.",
          "mapsQuery": "Pont Stanley Alexandrie",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "palais_montaza",
          "name": "Palais de Montaza",
          "categoryKey": "subCatHistorical",
          "sub_category": t['subCatHistorical'],
          "photo_url": "assets/alexendrie/palais.jpeg",
          "description": "Véritable havre de paix, le complexe royal de Montaza s'étend sur des hectares de jardins luxuriants surplombant la mer. Le palais central, inspiré par un mélange audacieux de styles florentin et turc, servait autrefois de résidence d'été à la famille royale égyptienne. Se promener dans ses allées ombragées, c'est s'immerger dans une époque de faste et de raffinement architectural européen au cœur de l'Égypte.",
          "mapsQuery": "Palais de Montaza Alexandrie",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "bibliotheque_alexandrina",
          "name": "Bibliothèque Alexandrina",
          "categoryKey": "subCatCulture",
          "sub_category": t['subCatCulture'],
          "photo_url": "assets/alexendrie/alexandrina.jpg",
          "description": "Plus qu'un simple bâtiment, la nouvelle Bibliothèque d'Alexandrie est un monument à la connaissance universelle, conçu pour réincarner l'esprit de l'ancienne bibliothèque antique. Son architecture audacieuse, en forme de disque incliné plongeant dans un bassin d'eau, symbolise un soleil levant sortant de la mer. Elle abrite des millions de livres, des musées spécialisés et des salles de lecture impressionnantes, faisant d'elle un phare culturel mondial.",
          "mapsQuery": "Bibliotheca Alexandrina Alexandrie",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "amphitheatre_kom_el_dick",
          "name": "Amphithéâtre Kom-El-Dick",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/dick.jpg",
          "description": "Découvert par hasard en 1960, ce petit amphithéâtre romain, remarquablement bien conservé, est le seul de son genre en Égypte. Avec ses gradins de marbre et ses colonnes de granit, il témoigne de la grandeur de la vie sociale et culturelle à l'époque gréco-romaine. Le site, niché au cœur de la ville moderne, offre une fenêtre imprenable sur les habitudes de divertissement des anciens habitants de la cité.",
          "mapsQuery": "Kom El Dikka Alexandrie",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
        {
          "id": "colonne_pompee",
          "name": "Colonne de Pompée",
          "categoryKey": "subCatMonuments",
          "sub_category": t['subCatMonuments'],
          "photo_url": "assets/alexendrie/pompe.jpg",
          "description": "Se dressant fièrement sur une colline, cette colonne monolithique en granit rouge d'Assouan est un exploit d'ingénierie antique. Haute de près de 27 mètres, elle est le seul vestige encore debout du temple majestueux du Sérapéum. Ce monument imposant, qui domine le quartier populaire de Karmouz, reste un symbole puissant de la longévité historique de la ville et de sa riche mixité culturelle passée.",
          "mapsQuery": "Colonne de Pompée Alexandrie",
          "region": "Villes Historiques",
          "subFolder": "Alexandrie"
        },
      ];
    }
  }

  Widget _buildLangButton(String label, String code) {
    final bool isSelected = _lang == code;
    return GestureDetector(
      onTap: () => _changerLangue(code),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
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
    final data = _getAlexandrieData();
    final isRtl = _lang == 'ar';
    final t = _uiText[_lang] ?? _uiText['fr']!;

    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in data) {
      groupedData.putIfAbsent(item['categoryKey'], () => []).add(item);
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
                  t['pageTitle']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0, left: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLangButton('FR', 'fr'),
                          _buildLangButton('EN', 'en'),
                          _buildLangButton('AR', 'ar'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ...groupedData.entries.map((entry) {
                final categoryKey = entry.key;
                final categoryColor = _getCategoryColor(categoryKey);
                final categoryTitle = t[categoryKey] ?? categoryKey;

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                      child: Text(
                        categoryTitle.toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) => _buildDesignCard(item, categoryColor, t['openMaps']!)),
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

  Widget _buildDesignCard(Map<String, dynamic> item, Color color, String openMapsLabel) {
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
                  item['name'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  item['sub_category'] ?? '',
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  item['description'] ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Alexandrie"),
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
                      openMapsLabel,
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