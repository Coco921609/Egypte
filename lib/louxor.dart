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

// --- 2. PAGE PRINCIPALE (LOUXOR) ---
class LouxorPage extends StatefulWidget {
  const LouxorPage({super.key});

  @override
  State<LouxorPage> createState() => _LouxorPageState();
}

class _LouxorPageState extends State<LouxorPage> {
  final ScrollController _mainScrollController = ScrollController();
  String _lang = 'fr';

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Louxor',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catMonuments': 'Monuments',
      'catValleyKings': 'Vallée des Rois & Reines',
      'catValleyArtisans': 'Vallée des artisans',
      'catActivities': 'Activités',
    },
    'en': {
      'pageTitle': 'Luxor',
      'mapsBtn': 'Open in Google Maps',
      'catMonuments': 'Monuments',
      'catValleyKings': 'Valley of the Kings & Queens',
      'catValleyArtisans': 'Valley of the Artisans',
      'catActivities': 'Activities',
    },
    'ar': {
      'pageTitle': 'الأقصر',
      'mapsBtn': 'الفتح في خرائط Google',
      'catMonuments': 'المعالم الأثرية',
      'catValleyKings': 'وادي الملوك والملكات',
      'catValleyArtisans': 'وادي العمال',
      'catActivities': 'الأنشطة',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedLouxorData = {
    'fr': [
      {
        "id": "karnak_temple",
        "name": "Le temple de Karnak",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/k.jpg",
        "description": "Le plus vaste complexe religieux de l'Antiquité, véritable cité de temples où chaque génération de pharaons a laissé son empreinte. La salle hypostyle, avec ses 134 colonnes monumentales, est une prouesse architecturale qui laisse le visiteur sans voix face à l'immensité de la foi des anciens Égyptiens.",
        "mapsQuery": "Karnak Temple Luxor"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "Le musée en plein air de Karnak",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "Situé dans l'enceinte de Karnak, ce musée rassemble des éléments architecturaux reconstitués avec soin, comme la chapelle blanche de Sésostris Ier. C'est une étape incontournable pour comprendre l'évolution artistique et technique des constructions religieuses égyptiennes.",
        "mapsQuery": "Open Air Museum Karnak Luxor"
      },
      {
        "id": "luxor_temple",
        "name": "Le temple de Louxor",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/l.jpg",
        "description": "Situé au cœur de la ville moderne, ce temple était dédié au renouveau du pouvoir royal. Magnifiquement éclairé à la tombée de la nuit, il se distingue par ses colosses de Ramsès II, son obélisque solitaire et son atmosphère mystique qui semble défier le temps et l'agitation urbaine environnante.",
        "mapsQuery": "Luxor Temple"
      },
      {
        "id": "royal_tomb",
        "name": "Une tombe royale",
        "sub_category_key": "catValleyKings",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "Plongez dans l'intimité des souverains défunts. Les tombes royales offrent une traversée unique vers l'au-delà, où chaque paroi est recouverte de textes sacrés et de fresques aux couleurs éclatantes, protégeant le roi et la reine dans leur voyage éternel.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "valley_kings_queens",
        "name": "La vallée des Rois et des Reines",
        "sub_category_key": "catValleyKings",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "Le site le plus prestigieux de la nécropole thébaine. Entre les montagnes arides de la rive ouest, les pharaons et leurs épouses ont fait creuser leurs demeures secrètes, loin des regards, pour assurer la pérennité de leur règne dans le monde des dieux.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "colossi_memnon",
        "name": "Les colosses de Memnon",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/me.jpg",
        "description": "Deux statues monumentales en grès qui trônent fièrement dans la plaine. Bien que le temple funéraire d'Amenhotep III dont elles faisaient partie ait disparu, ces colosses restent des sentinelles impressionnantes, témoins de la grandeur démesurée des constructions impériales de l'époque.",
        "mapsQuery": "Colossi of Memnon Luxor"
      },
      {
        "id": "medinet_habu",
        "name": "Le temple de Medinet Habu",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "Un temple funéraire d'une richesse exceptionnelle, où les reliefs racontent les batailles victorieuses de Ramsès III contre les peuples de la mer. C'est l'un des rares endroits où la peinture originale des reliefs est encore visible, offrant un contraste saisissant entre la pierre brute et la finesse du détail artistique.",
        "mapsQuery": "Medinet Habu Temple Luxor"
      },
      {
        "id": "deir_el_medina",
        "name": "Deir el Medina",
        "sub_category_key": "catValleyArtisans",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "Le village des artisans qui ont sculpté et peint les chefs-d'œuvre de la Vallée des Rois. Ce lieu offre un regard rare et émouvant sur la vie quotidienne des anciens égyptiens, loin des fastes royaux, avec leurs maisons, leurs ateliers et leurs propres sépultures familiales décorées.",
        "mapsQuery": "Deir el Medina Luxor"
      },
      {
        "id": "hot_air_balloon",
        "name": "Louxor en montgolfière",
        "sub_category_key": "catActivities",
        "photo_url": "assets/louxor/m.jpg",
        "description": "Une expérience aérienne inoubliable au lever du soleil. Survolez le Nil et les sites antiques pour réaliser la grandeur du plan architectural thébain, avec d'un côté la luxuriance des terres fertiles et de l'autre, l'immensité silencieuse des plateaux désertiques.",
        "mapsQuery": "Hot Air Balloon Luxor"
      },
      {
        "id": "nile_boat_ride",
        "name": "Louxor en bateau",
        "sub_category_key": "catActivities",
        "photo_url": "assets/louxor/b.jpg",
        "description": "La navigation sur le Nil, le fleuve nourricier, est l'âme même de Louxor. Que ce soit sur une felouque traditionnelle ou un bateau de croisière, le Nil offre une perspective apaisante et différente sur les rivages, là où la vie agricole continue à suivre le rythme des saisons depuis des millénaires.",
        "mapsQuery": "Felucca ride Luxor Nile"
      },
    ],
    'en': [
      {
        "id": "karnak_temple",
        "name": "Karnak Temple",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/k.jpg",
        "description": "The largest religious complex of antiquity, a true city of temples where every generation of pharaohs left its mark. The hypostyle hall, with its 134 monumental columns, is an architectural feat that leaves visitors awestruck by the scale of ancient Egyptian faith.",
        "mapsQuery": "Karnak Temple Luxor"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "Karnak Open Air Museum",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "Located within the Karnak precinct, this museum features carefully reconstructed architectural elements, such as the White Chapel of Senusret I. It is an essential stop for understanding the artistic and technical evolution of Egyptian religious buildings.",
        "mapsQuery": "Open Air Museum Karnak Luxor"
      },
      {
        "id": "luxor_temple",
        "name": "Luxor Temple",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/l.jpg",
        "description": "Located in the heart of the modern city, this temple was dedicated to the renewal of royal power. Beautifully illuminated at nightfall, it features colossi of Ramesses II, a solitary obelisk, and a mystical atmosphere that defies time and urban bustle.",
        "mapsQuery": "Luxor Temple"
      },
      {
        "id": "royal_tomb",
        "name": "A Royal Tomb",
        "sub_category_key": "catValleyKings",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "Immerse yourself in the sanctuary of deceased rulers. The royal tombs offer a unique journey into the afterlife, where every wall is adorned with sacred texts and brightly colored frescoes protecting the king and queen on their eternal journey.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "valley_kings_queens",
        "name": "Valley of the Kings and Queens",
        "sub_category_key": "catValleyKings",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "The most prestigious site of the Theban necropolis. Among the arid mountains of the West Bank, pharaohs and their wives carved out secret eternal resting places to ensure their reign in the world of the gods.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "colossi_memnon",
        "name": "Colossi of Memnon",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/me.jpg",
        "description": "Two monumental sandstone statues standing proudly in the plain. Although the mortuary temple of Amenhotep III they guarded has vanished, these colossi remain impressive sentinels testifying to the grandeur of imperial building projects.",
        "mapsQuery": "Colossi of Memnon Luxor"
      },
      {
        "id": "medinet_habu",
        "name": "Medinet Habu Temple",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "An exceptionally rich mortuary temple whose reliefs depict the victorious battles of Ramesses III against the Sea Peoples. It is one of the few places where original painted reliefs remain visible, contrasting raw stone with exquisite artistic detail.",
        "mapsQuery": "Medinet Habu Temple Luxor"
      },
      {
        "id": "deir_el_medina",
        "name": "Deir el Medina",
        "sub_category_key": "catValleyArtisans",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "The village of artisans who carved and painted the masterpieces of the Valley of the Kings. This site offers a rare and moving glimpse into daily life in ancient Egypt, complete with houses, workshops, and beautifully decorated family tombs.",
        "mapsQuery": "Deir el Medina Luxor"
      },
      {
        "id": "hot_air_balloon",
        "name": "Luxor Hot Air Balloon",
        "sub_category_key": "catActivities",
        "photo_url": "assets/louxor/m.jpg",
        "description": "An unforgettable sunrise aerial experience. Soar above the Nile and ancient sites to grasp the grandeur of Thebes' architectural layout, with lush fertile green fields on one side and silent desert plateaus on the other.",
        "mapsQuery": "Hot Air Balloon Luxor"
      },
      {
        "id": "nile_boat_ride",
        "name": "Luxor Boat Tour",
        "sub_category_key": "catActivities",
        "photo_url": "assets/louxor/b.jpg",
        "description": "Sailing on the life-giving Nile is the very soul of Luxor. Whether on a traditional felucca or a cruise boat, the Nile offers a soothing perspective on the banks, where agricultural life has followed the rhythm of seasons for millennia.",
        "mapsQuery": "Felucca ride Luxor Nile"
      },
    ],
    'ar': [
      {
        "id": "karnak_temple",
        "name": "معبد الكرنك",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/k.jpg",
        "description": "أكبر مجمع ديني في العصور القديمة، وهو مدينة حقيقية من المعابد حيث تركت كل أجيال الفراعنة بصمتها. قاعة الأعمدة الكبرى، التي تضم 134 عموداً ضخماً، تُعد إنجازاً معمارياً يذهل الزوار أمام عظمة إيمان المصريين القدماء.",
        "mapsQuery": "معبد الكرنك الأقصر"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "متحف الكرنك المفتوح",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "يقع داخل حرم معبد الكرنك، ويضم عناصر معمارية أعيد ترميمها بعناية، مثل المقاصة البيضاء لسنوسرت الأول. يُعد محطة أساسية لفهم التطور الفني والتقني للمباني الدينية المصرية.",
        "mapsQuery": "المتحف المفتوح بالكرنك الأقصر"
      },
      {
        "id": "luxor_temple",
        "name": "معبد الأقصر",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/l.jpg",
        "description": "يقع في قلب المدينة الحديثة، وكان مكرساً لتجديد السلطة الملكية. يتميز بإضاءته الساحرة في الليل، وتماثيل رمسيس الثاني الضخمة، والمسلة المنفردة، وأجوائه الصوفية التي تتحدى الزمن وصخب المدينة.",
        "mapsQuery": "معبد الأقصر"
      },
      {
        "id": "royal_tomb",
        "name": "مقبرة ملكية",
        "sub_category_key": "catValleyKings",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "استكشف الأجواء الخاصة للملوك الراحلين. تقدم المقابر الملكية رحلة فريدة إلى العالم الآخر، حيث تغطي كل جدار نصوص مقدسة وجداريات بألوان زاهية تحمي الملك والملكة في رحلتهما الأبدية.",
        "mapsQuery": "وادي الملوك الأقصر"
      },
      {
        "id": "valley_kings_queens",
        "name": "وادي الملوك والملكات",
        "sub_category_key": "catValleyKings",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "الموقع الأكثر شهرة في جبانة طيبة. بين الجبال الجافة بالبر الغربي، حفر الفراعنة وزوجاتهم مقابرهم السرية بعيداً عن الأعين لضمان خلودهم في عالم الآلهة.",
        "mapsQuery": "وادي الملوك والملكات الأقصر"
      },
      {
        "id": "colossi_memnon",
        "name": "تمثالا ممنون",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/me.jpg",
        "description": "تمثالان ضخمان من الحجر الرملي يقفان بشموخ في السهل. رغم اختفاء معبد أمينحتب الثالث الجنائزي الذي كانا يحرسانه، يظل هذان التمثالان شاهدين على العظمة الفائقة للمباني الإمبراطورية في ذلك العصر.",
        "mapsQuery": "تمثالا ممنون الأقصر"
      },
      {
        "id": "medinet_habu",
        "name": "معبد مدينة هابو",
        "sub_category_key": "catMonuments",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "معبد جنائزي غني للغاية، حيث تحكي نقوشه الملونة المعارك المنتصرة لرمسيس الثالث ضد شعوب البحر. إنه من الأماكن النادرة التي لا تزال فيها الألوان الأصلية للنقوش واضحة ومحتفظة برونقها.",
        "mapsQuery": "معبد مدينة هابو الأقصر"
      },
      {
        "id": "deir_el_medina",
        "name": "دير المدينة",
        "sub_category_key": "catValleyArtisans",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "قرية العمال والحرفيين الذين نحتوا ولونوا تحف وادي الملوك. يقدم هذا الموقع نظرة نادرة ومؤثرة على الحياة اليومية للمصريين القدماء، مع منازلهم وورشهم ومقابرهم العائلية المزخرفة.",
        "mapsQuery": "دير المدينة الأقصر"
      },
      {
        "id": "hot_air_balloon",
        "name": "الأقصر بالمنطاد الطائر",
        "sub_category_key": "catActivities",
        "photo_url": "assets/louxor/m.jpg",
        "description": "تجربة جوية لا تُنسى عند شروق الشمس. تحليق فوق النيل والمواقع الأثرية لاستيعاب روعة التخطيط المعماري لطيبة، حيث الخضرة الخصبة من جهة وامتداد الصحراء الهادئ من جهة أخرى.",
        "mapsQuery": "منطاد الأقصر"
      },
      {
        "id": "nile_boat_ride",
        "name": "الأقصر بالقارب",
        "sub_category_key": "catActivities",
        "photo_url": "assets/louxor/b.jpg",
        "description": "الإبحار في نهر النيل هو شريان الحياة والروح الحقيقية للأقصر. سواء على متن الفلوكة التقليدية أو سفينة سياحية، يوفر النيل إطلالة مريحة على الضفاف حيث تستمر الحياة الزراعية على إيقاع الفصول منذ آلاف السنين.",
        "mapsQuery": "جولة فلوكة النيل الأقصر"
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
      case "catValleyKings": return Colors.redAccent;
      case "catValleyArtisans": return Colors.blueAccent;
      case "catActivities": return Colors.greenAccent;
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
    final List<Map<String, dynamic>> currentData = _localizedLouxorData[_lang] ?? _localizedLouxorData['fr']!;
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
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Louxor"),
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