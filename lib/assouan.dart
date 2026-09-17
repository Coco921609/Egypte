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

// --- 2. PAGE PRINCIPALE (ASSOUAN) ---
class AssouanPage extends StatefulWidget {
  const AssouanPage({super.key});

  @override
  State<AssouanPage> createState() => _AssouanPageState();
}

class _AssouanPageState extends State<AssouanPage> {
  final ScrollController _mainScrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Assouan',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catMonuments': 'Monuments majeurs',
      'catNature': 'Nature et Paysages',
      'catHistory': 'Histoire et Culture',
      'catActivities': 'Activités',
    },
    'en': {
      'pageTitle': 'Aswan',
      'mapsBtn': 'Open in Google Maps',
      'catMonuments': 'Major Monuments',
      'catNature': 'Nature & Landscapes',
      'catHistory': 'History & Culture',
      'catActivities': 'Activities',
    },
    'ar': {
      'pageTitle': 'أسوان',
      'mapsBtn': 'الفتح في خرائط Google',
      'catMonuments': 'المعالم الرئيسية',
      'catNature': 'الطبيعة والمناظر الطبيعية',
      'catHistory': 'التاريخ وثقافة',
      'catActivities': 'الأنشطة',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedAssouanData = {
    'fr': [
      {
        "id": "abou_simbel",
        "name": "Abou Simbel",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/s.jpg",
        "description": "Situé aux confins du désert, cet ensemble de deux temples creusés dans la roche par Ramsès II est un chef-d'œuvre de l'architecture mondiale. Le déplacement titanesque de ces temples pour les sauver des eaux du barrage est une aventure humaine et technique sans précédent.",
        "mapsQuery": "Abou Simbel"
      },
      {
        "id": "temple_philae",
        "name": "Temple de Philae",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/phi.webp",
        "description": "Dédié à la déesse Isis, ce temple est un joyau d'élégance situé sur l'île d'Agilkia. Ses colonnades, ses reliefs délicats et sa position au milieu des eaux du Nil en font l'un des lieux les plus poétiques et les mieux conservés de toute la Basse-Nubie.",
        "mapsQuery": "Temple de Philae Assouan"
      },
      {
        "id": "temple_horus",
        "name": "Temple d'Horus",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/h.jpg",
        "description": "Érigé à Edfou entre Assouan et Louxor, ce temple est l'un des mieux préservés d'Égypte. Dédié au dieu faucon Horus, il se distingue par sa structure complète, ses pylônes imposants et son atmosphère solennelle qui transporte le visiteur directement au cœur de l'époque ptolémaïque.",
        "mapsQuery": "Temple d'Horus Edfou"
      },
      {
        "id": "lac_nasser",
        "name": "Lac Nasser (lac de Nubie)",
        "sub_category_key": "catNature",
        "sub_category": "Nature et Paysages",
        "photo_url": "assets/assouan/nasser.jpg",
        "description": "L'un des plus grands lacs artificiels au monde, créé par la construction du haut barrage. Ses eaux d'un bleu profond contrastent magnifiquement avec l'aridité du désert environnant.",
        "mapsQuery": "Lac Nasser Assouan"
      },
      {
        "id": "monastere_saint_simeon",
        "name": "Le monastère de Saint-Siméon",
        "sub_category_key": "catHistory",
        "sub_category": "Histoire et Culture",
        "photo_url": "assets/assouan/saint.jpeg",
        "description": "Situé sur la rive ouest du Nil, ce monastère fortifié du VIIe siècle est l'un des exemples les mieux conservés de l'architecture copte en Égypte. Isolé dans le paysage désertique, il témoigne de la vie ascétique des moines avec ses impressionnantes murailles en briques crues, ses églises aux fresques anciennes et ses cellules monastiques qui dominent la vallée.",
        "mapsQuery": "Monastère de Saint-Siméon Assouan"
      },
      {
        "id": "ile_elephantine",
        "name": "L’île Éléphantine",
        "sub_category_key": "catHistory",
        "sub_category": "Histoire et Culture",
        "photo_url": "assets/assouan/ile.jpg",
        "description": "Véritable carrefour historique, cette île abrite le temple de Khnoum et un nilomètre antique. Entre ses jardins luxuriants et les maisons traditionnelles du village nubien qui s'y trouve, elle offre une immersion totale dans la vie quotidienne assouanaise.",
        "mapsQuery": "Île Éléphantine Assouan"
      },
      {
        "id": "village_nubien",
        "name": "Le village nubien",
        "sub_category_key": "catHistory",
        "sub_category": "Histoire et Culture",
        "photo_url": "assets/assouan/village.jpeg",
        "description": "Découvrez le mode de vie des Nubiens à travers leurs maisons colorées, leur artisanat raffiné et leur hospitalité. Une escale incontournable pour comprendre l'identité singulière de cette culture.",
        "mapsQuery": "Nubian Village Aswan"
      },
      {
        "id": "jardin_botanique_kitchener",
        "name": "Le jardin botanique de l’île Kitchener",
        "sub_category_key": "catNature",
        "sub_category": "Nature et Paysages",
        "photo_url": "assets/assouan/parc.jpeg",
        "description": "Un paradis verdoyant au milieu du fleuve, rassemblant des espèces exotiques rares issues de tous les continents. C'est l'endroit rêvé pour une pause ombragée.",
        "mapsQuery": "Aswan Botanical Garden Kitchener Island"
      },
      {
        "id": "balade_felouque",
        "name": "Balade en felouque",
        "sub_category_key": "catActivities",
        "sub_category": "Activités",
        "photo_url": "assets/assouan/balade.jpg",
        "description": "Glisser sur le Nil en felouque, sans le bruit d'un moteur, est une expérience sensorielle unique. Le moyen le plus authentique pour explorer les îlots déserts et les paysages fascinants de la Nubie.",
        "mapsQuery": "Felucca ride Aswan"
      },
      {
        "id": "temple_kom_ombo",
        "name": "Temple de Kôm Ombo",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments majeurs",
        "photo_url": "assets/assouan/ombo.jpeg",
        "description": "Situé sur un promontoire surplombant le Nil, ce temple est une rareté architecturale. Sa conception parfaitement symétrique lui permet d'être dédié simultanément à deux divinités : Sobek, le dieu crocodile, et Haroëris, le dieu faucon. C'est un lieu fascinant pour comprendre la dualité dans la religion égyptienne antique.",
        "mapsQuery": "Temple de Kom Ombo"
      },
    ],
    'en': [
      {
        "id": "abou_simbel",
        "name": "Abu Simbel",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/s.jpg",
        "description": "Located at the edge of the desert, this complex of two temples carved into the rock by Ramesses II is a masterpiece of world architecture. The colossal relocation of these temples to save them from dam waters remains an unprecedented human and engineering feat.",
        "mapsQuery": "Abu Simbel"
      },
      {
        "id": "temple_philae",
        "name": "Philae Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/phi.webp",
        "description": "Dedicated to the goddess Isis, this elegant temple is located on Agilkia Island. Its colonnades, delicate reliefs, and setting amidst the waters of the Nile make it one of the most poetic and best-preserved sites in Lower Nubia.",
        "mapsQuery": "Philae Temple Aswan"
      },
      {
        "id": "temple_horus",
        "name": "Temple of Horus",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/h.jpg",
        "description": "Erected in Edfu between Aswan and Luxor, this temple is one of the best-preserved in Egypt. Dedicated to the falcon god Horus, it stands out for its intact structure, imposing pylons, and solemn atmosphere that transports visitors to the Ptolemaic era.",
        "mapsQuery": "Temple of Horus Edfu"
      },
      {
        "id": "lac_nasser",
        "name": "Lake Nasser (Lake Nubia)",
        "sub_category_key": "catNature",
        "sub_category": "Nature & Landscapes",
        "photo_url": "assets/assouan/nasser.jpg",
        "description": "One of the largest man-made lakes in the world, created by the construction of the High Dam. Its deep blue waters contrast strikingly with the surrounding arid desert.",
        "mapsQuery": "Lake Nasser Aswan"
      },
      {
        "id": "monastere_saint_simeon",
        "name": "Monastery of Saint Simeon",
        "sub_category_key": "catHistory",
        "sub_category": "History & Culture",
        "photo_url": "assets/assouan/saint.jpeg",
        "description": "Located on the west bank of the Nile, this 7th-century fortified monastery is one of the best-preserved examples of Coptic architecture in Egypt. Isolated in the desert landscape, it reflects monastic life with mud-brick walls, ancient frescoes, and cells overlooking the valley.",
        "mapsQuery": "Monastery of Saint Simeon Aswan"
      },
      {
        "id": "ile_elephantine",
        "name": "Elephantine Island",
        "sub_category_key": "catHistory",
        "sub_category": "History & Culture",
        "photo_url": "assets/assouan/ile.jpg",
        "description": "A true historical crossroads, this island houses the Temple of Khnum and an ancient nilometer. Between lush gardens and traditional Nubian village houses, it offers total immersion in local life.",
        "mapsQuery": "Elephantine Island Aswan"
      },
      {
        "id": "village_nubien",
        "name": "Nubian Village",
        "sub_category_key": "catHistory",
        "sub_category": "History & Culture",
        "photo_url": "assets/assouan/village.jpeg",
        "description": "Discover the Nubian lifestyle through colorful houses, refined handicrafts, and legendary hospitality. An essential stop to understand the unique identity of this culture.",
        "mapsQuery": "Nubian Village Aswan"
      },
      {
        "id": "jardin_botanique_kitchener",
        "name": "Aswan Botanical Garden (Kitchener's Island)",
        "sub_category_key": "catNature",
        "sub_category": "Nature & Landscapes",
        "photo_url": "assets/assouan/parc.jpeg",
        "description": "A lush green paradise in the middle of the river, housing rare exotic plant species from all continents. The perfect place for a shaded retreat.",
        "mapsQuery": "Aswan Botanical Garden Kitchener Island"
      },
      {
        "id": "balade_felouque",
        "name": "Felucca Ride",
        "sub_category_key": "catActivities",
        "sub_category": "Activities",
        "photo_url": "assets/assouan/balade.jpg",
        "description": "Gliding down the Nile on a traditional felucca without engine noise is a unique sensory experience. The most authentic way to explore deserted islets and Nubia's captivating landscapes.",
        "mapsQuery": "Felucca ride Aswan"
      },
      {
        "id": "temple_kom_ombo",
        "name": "Kom Ombo Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Major Monuments",
        "photo_url": "assets/assouan/ombo.jpeg",
        "description": "Situated on a high promontory overlooking the Nile, this temple is an architectural rarity. Its perfectly symmetrical design is dedicated simultaneously to two deities: Sobek the crocodile god and Haroeris the falcon god.",
        "mapsQuery": "Temple of Kom Ombo"
      },
    ],
    'ar': [
      {
        "id": "abou_simbel",
        "name": "أبو سمبل",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/s.jpg",
        "description": "يقع هذا المجمع المكون من معبدين منحوتين في الصخر بواسطة رمسيس الثاني على أطراف الصحراء، ويُعد تحفة معمارية عالمية. تُعتبر عملية نقل المعبدين المذهلة لإنقاذهما من مياه السد إنجازاً بشرياً وهندسياً فريداً.",
        "mapsQuery": "أبو سمبل"
      },
      {
        "id": "temple_philae",
        "name": "معبد فيلة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/phi.webp",
        "description": "مكرس للإلهة إيزيس، ويُعد هذا المعبد جوهرة أنيقة تقع على جزيرة أجيلكيا. أعمدته ونقوشه الدقيقة وموقعه وسط مياه النيل تجعله واحداً من أكثر الأماكن شاعرية وأفضلها حفظاً في النوبة.",
        "mapsQuery": "معبد فيلة أسوان"
      },
      {
        "id": "temple_horus",
        "name": "معبد حورس (إدفو)",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/h.jpg",
        "description": "يقع في إدفو بين أسوان والأقصر، ويُعتبر من أفضل المعابد حفظاً في مصر. مكرس للإله الصقر حورس، ويتميز ببنائه الكامل وبواباته الضخمة وأجوائه التي تنقل الزائر إلى عصر البطالمة.",
        "mapsQuery": "معبد حورس إدفو"
      },
      {
        "id": "lac_nasser",
        "name": "بحيرة ناصر",
        "sub_category_key": "catNature",
        "sub_category": "الطبيعة والمناظر الطبيعية",
        "photo_url": "assets/assouan/nasser.jpg",
        "description": "واحدة من أكبر البحيرات الصناعية في العالم، أنشئت نتيجة بناء السد العالي. تتناغم مياهها الزرقاء الداكنة بشكل رائع مع جفاف الصحراء المحيطة بها.",
        "mapsQuery": "بحيرة ناصر أسوان"
      },
      {
        "id": "monastere_saint_simeon",
        "name": "دير الأنبا سمعان",
        "sub_category_key": "catHistory",
        "sub_category": "التاريخ وثقافة",
        "photo_url": "assets/assouan/saint.jpeg",
        "description": "يقع على الضفة الغربية للنيل، وهو دير حصين يعود للقرن السابع الميلادي ويعد من أروع أمثلة العمارة القبطية في مصر. يقع وسط الصحراء ويشهد على الحياة الرهبانية بأسواره الضخمة وكنائسه القديمة.",
        "mapsQuery": "دير الأنبا سمعان أسوان"
      },
      {
        "id": "ile_elephantine",
        "name": "جزيرة الفنتين",
        "sub_category_key": "catHistory",
        "sub_category": "التاريخ وثقافة",
        "photo_url": "assets/assouan/ile.jpg",
        "description": "ملتقى تاريخي حقيقي، تضم الجزيرة معبد خنوم ومقياس النيل القديم. وتوفر بين حدائقها الغناء وبيوت القرى النوبية التقليدية تجربة انغماس كاملة في الحياة اليومية.",
        "mapsQuery": "جزيرة الفنتين أسوان"
      },
      {
        "id": "village_nubien",
        "name": "القرية النوبية",
        "sub_category_key": "catHistory",
        "sub_category": "التاريخ وثقافة",
        "photo_url": "assets/assouan/village.jpeg",
        "description": "اكتشف نمط حياة النوبيين من خلال بيوتهم الملونة وحرفهم اليدوية الرفيعة وحسن ضيافتهم. محطة لا غنى عنها لفهم الهوية الفريدة لهذه الثقافة.",
        "mapsQuery": "القرية النوبية أسوان"
      },
      {
        "id": "jardin_botanique_kitchener",
        "name": "الحديقة النباتية (جزيرة النباتات)",
        "sub_category_key": "catNature",
        "sub_category": "الطبيعة والمناظر الطبيعية",
        "photo_url": "assets/assouan/parc.jpeg",
        "description": "واحة خضراء وسط النيل تضم أنواعاً من النباتات والأشجار النادرة من مختلف القارات. مكان مثالي للاسترخاء والتنزه.",
        "mapsQuery": "الحديقة النباتية أسوان"
      },
      {
        "id": "balade_felouque",
        "name": "جولة بالفلوكة",
        "sub_category_key": "catActivities",
        "sub_category": "الأنشطة",
        "photo_url": "assets/assouan/balade.jpg",
        "description": "الإبحار في هدوء عبر نهر النيل على متن فلوكة تقليدية بدون ضوضاء المحركات هي تجربة فريدة. الوسيلة الأكثر أصالة لاستكشاف جزر النوبة ومناظرها الطبيعية.",
        "mapsQuery": "جولة فلوكة أسوان"
      },
      {
        "id": "temple_kom_ombo",
        "name": "معبد كوم أمبو",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الرئيسية",
        "photo_url": "assets/assouan/ombo.jpeg",
        "description": "يقع على ربوة عالية تطل على النيل، ويُعد من أندر المعالم المعمارية. تصميمه المتناظر مخصص لإلهين في وقت واحد: سوبك إله التمساح وحورور إله الصقر.",
        "mapsQuery": "معبد كوم أمبو"
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
      case "catNature": return Colors.greenAccent;
      case "catHistory": return Colors.blueAccent;
      case "catActivities": return Colors.redAccent;
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
    final List<Map<String, dynamic>> currentData = _localizedAssouanData[_lang] ?? _localizedAssouanData['fr']!;
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
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Assouan"),
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