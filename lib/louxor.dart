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

// --- 2. PAGE PRINCIPALE (LOUXOR) ---
class LouxorPage extends StatefulWidget {
  const LouxorPage({super.key});

  @override
  State<LouxorPage> createState() => _LouxorPageState();
}

class _LouxorPageState extends State<LouxorPage>
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
      'pageTitle': 'Louxor',
      'tagline': 'Le plus grand musée à ciel ouvert du monde',
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
      'catValleyKings': 'Vallée des Rois & Reines',
      'catValleyArtisans': 'Vallée des artisans',
      'catActivities': 'Activités à Louxor',
    },
    'en': {
      'pageTitle': 'Luxor',
      'tagline': "The world's greatest open-air museum",
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
      'catValleyKings': 'Valley of the Kings & Queens',
      'catValleyArtisans': 'Valley of the Artisans',
      'catActivities': 'Activities in Luxor',
    },
    'ar': {
      'pageTitle': 'الأقصر',
      'tagline': 'أكبر متحف مفتوح في العالم',
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
      'catValleyKings': 'وادي الملوك والملكات',
      'catValleyArtisans': 'وادي العمال',
      'catActivities': 'أنشطة في الأقصر',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedLouxorData = {
    'fr': [
      {
        "id": "karnak_temple",
        "name": "Le temple de Karnak",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/k.jpg",
        "description": "Le plus vaste complexe religieux de l'Antiquité, véritable cité de temples où chaque génération de pharaons a laissé son empreinte. La salle hypostyle, avec ses 134 colonnes monumentales, est une prouesse architecturale qui laisse le visiteur sans voix face à l'immensité de la foi des anciens Égyptiens.",
        "mapsQuery": "Karnak Temple Luxor"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "Le musée en plein air de Karnak",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "Situé dans l'enceinte de Karnak, ce musée rassemble des éléments architecturaux reconstitués avec soin, comme la chapelle blanche de Sésostris Ier. C'est une étape incontournable pour comprendre l'évolution artistique et technique des constructions religieuses égyptiennes.",
        "mapsQuery": "Open Air Museum Karnak Luxor"
      },
      {
        "id": "luxor_temple",
        "name": "Le temple de Louxor",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/l.jpg",
        "description": "Situé au cœur de la ville moderne, ce temple était dédié au renouveau du pouvoir royal. Magnifiquement éclairé à la tombée de la nuit, il se distingue par ses colosses de Ramsès II, son obélisque solitaire et son atmosphère mystique qui semble défier le temps et l'agitation urbaine environnante.",
        "mapsQuery": "Luxor Temple"
      },
      {
        "id": "royal_tomb",
        "name": "Une tombe royale",
        "sub_category_key": "catValleyKings",
        "sub_category": "Vallée des Rois & Reines",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "Plongez dans l'intimité des souverains défunts. Les tombes royales offrent une traversée unique vers l'au-delà, où chaque paroi est recouverte de textes sacrés et de fresques aux couleurs éclatantes, protégeant le roi et la reine dans leur voyage éternel.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "valley_kings_queens",
        "name": "La vallée des Rois et des Reines",
        "sub_category_key": "catValleyKings",
        "sub_category": "Vallée des Rois & Reines",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "Le site le plus prestigieux de la nécropole thébaine. Entre les montagnes arides de la rive ouest, les pharaons et leurs épouses ont fait creuser leurs demeures secrètes, loin des regards, pour assurer la pérennité de leur règne dans le monde des dieux.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "colossi_memnon",
        "name": "Les colosses de Memnon",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/me.jpg",
        "description": "Deux statues monumentales en grès qui trônent fièrement dans la plaine. Bien que le temple funéraire d'Amenhotep III dont elles faisaient partie ait disparu, ces colosses restent des sentinelles impressionnantes, témoins de la grandeur démesurée des constructions impériales de l'époque.",
        "mapsQuery": "Colossi of Memnon Luxor"
      },
      {
        "id": "medinet_habu",
        "name": "Le temple de Medinet Habu",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "Un temple funéraire d'une richesse exceptionnelle, où les reliefs racontent les batailles victorieuses de Ramsès III contre les peuples de la mer. C'est l'un des rares endroits où la peinture originale des reliefs est encore visible, offrant un contraste saisissant entre la pierre brute et la finesse du détail artistique.",
        "mapsQuery": "Medinet Habu Temple Luxor"
      },
      {
        "id": "deir_el_medina",
        "name": "Deir el Medina",
        "sub_category_key": "catValleyArtisans",
        "sub_category": "Vallée des artisans",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "Le village des artisans qui ont sculpté et peint les chefs-d'œuvre de la Vallée des Rois. Ce lieu offre un regard rare et émouvant sur la vie quotidienne des anciens égyptiens, loin des fastes royaux, avec leurs maisons, leurs ateliers et leurs propres sépultures familiales décorées.",
        "mapsQuery": "Deir el Medina Luxor"
      },
      {
        "id": "hot_air_balloon",
        "name": "Louxor en montgolfière",
        "sub_category_key": "catActivities",
        "sub_category": "Activités à Louxor",
        "photo_url": "assets/louxor/m.jpg",
        "description": "Une expérience aérienne inoubliable au lever du soleil. Survolez le Nil et les sites antiques pour réaliser la grandeur du plan architectural thébain, avec d'un côté la luxuriance des terres fertiles et de l'autre, l'immensité silencieuse des plateaux désertiques.",
        "mapsQuery": "Hot Air Balloon Luxor"
      },
      {
        "id": "nile_boat_ride",
        "name": "Louxor en bateau",
        "sub_category_key": "catActivities",
        "sub_category": "Activités à Louxor",
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
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/k.jpg",
        "description": "The largest religious complex of antiquity, a true city of temples where every generation of pharaohs left its mark. The hypostyle hall, with its 134 monumental columns, is an architectural feat that leaves visitors awestruck by the scale of ancient Egyptian faith.",
        "mapsQuery": "Karnak Temple Luxor"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "Karnak Open Air Museum",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "Located within the Karnak precinct, this museum features carefully reconstructed architectural elements, such as the White Chapel of Senusret I. It is an essential stop for understanding the artistic and technical evolution of Egyptian religious buildings.",
        "mapsQuery": "Open Air Museum Karnak Luxor"
      },
      {
        "id": "luxor_temple",
        "name": "Luxor Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/l.jpg",
        "description": "Located in the heart of the modern city, this temple was dedicated to the renewal of royal power. Beautifully illuminated at nightfall, it features colossi of Ramesses II, a solitary obelisk, and a mystical atmosphere that defies time and urban bustle.",
        "mapsQuery": "Luxor Temple"
      },
      {
        "id": "royal_tomb",
        "name": "A Royal Tomb",
        "sub_category_key": "catValleyKings",
        "sub_category": "Valley of the Kings & Queens",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "Immerse yourself in the sanctuary of deceased rulers. The royal tombs offer a unique journey into the afterlife, where every wall is adorned with sacred texts and brightly colored frescoes protecting the king and queen on their eternal journey.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "valley_kings_queens",
        "name": "Valley of the Kings and Queens",
        "sub_category_key": "catValleyKings",
        "sub_category": "Valley of the Kings & Queens",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "The most prestigious site of the Theban necropolis. Among the arid mountains of the West Bank, pharaohs and their wives carved out secret eternal resting places to ensure their reign in the world of the gods.",
        "mapsQuery": "Valley of the Kings Luxor"
      },
      {
        "id": "colossi_memnon",
        "name": "Colossi of Memnon",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/me.jpg",
        "description": "Two monumental sandstone statues standing proudly in the plain. Although the mortuary temple of Amenhotep III they guarded has vanished, these colossi remain impressive sentinels testifying to the grandeur of imperial building projects.",
        "mapsQuery": "Colossi of Memnon Luxor"
      },
      {
        "id": "medinet_habu",
        "name": "Medinet Habu Temple",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "An exceptionally rich mortuary temple whose reliefs depict the victorious battles of Ramesses III against the Sea Peoples. It is one of the few places where original painted reliefs remain visible, contrasting raw stone with exquisite artistic detail.",
        "mapsQuery": "Medinet Habu Temple Luxor"
      },
      {
        "id": "deir_el_medina",
        "name": "Deir el Medina",
        "sub_category_key": "catValleyArtisans",
        "sub_category": "Valley of the Artisans",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "The village of artisans who carved and painted the masterpieces of the Valley of the Kings. This site offers a rare and moving glimpse into daily life in ancient Egypt, complete with houses, workshops, and beautifully decorated family tombs.",
        "mapsQuery": "Deir el Medina Luxor"
      },
      {
        "id": "hot_air_balloon",
        "name": "Luxor Hot Air Balloon",
        "sub_category_key": "catActivities",
        "sub_category": "Activities in Luxor",
        "photo_url": "assets/louxor/m.jpg",
        "description": "An unforgettable sunrise aerial experience. Soar above the Nile and ancient sites to grasp the grandeur of Thebes' architectural layout, with lush fertile green fields on one side and silent desert plateaus on the other.",
        "mapsQuery": "Hot Air Balloon Luxor"
      },
      {
        "id": "nile_boat_ride",
        "name": "Luxor Boat Tour",
        "sub_category_key": "catActivities",
        "sub_category": "Activities in Luxor",
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
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/k.jpg",
        "description": "أكبر مجمع ديني في العصور القديمة، وهو مدينة حقيقية من المعابد حيث تركت كل أجيال الفراعنة بصمتها. قاعة الأعمدة الكبرى، التي تضم 134 عموداً ضخماً، تُعد إنجازاً معمارياً يذهل الزوار أمام عظمة إيمان المصريين القدماء.",
        "mapsQuery": "معبد الكرنك الأقصر"
      },
      {
        "id": "karnak_open_air_museum",
        "name": "متحف الكرنك المفتوح",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/temple.jpg",
        "description": "يقع داخل حرم معبد الكرنك، ويضم عناصر معمارية أعيد ترميمها بعناية، مثل المقاصة البيضاء لسنوسرت الأول. يُعد محطة أساسية لفهم التطور الفني والتقني للمباني الدينية المصرية.",
        "mapsQuery": "المتحف المفتوح بالكرنك الأقصر"
      },
      {
        "id": "luxor_temple",
        "name": "معبد الأقصر",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/l.jpg",
        "description": "يقع في قلب المدينة الحديثة، وكان مكرساً لتجديد السلطة الملكية. يتميز بإضاءته الساحرة في الليل، وتماثيل رمسيس الثاني الضخمة، والمسلة المنفردة، وأجوائه الصوفية التي تتحدى الزمن وصخب المدينة.",
        "mapsQuery": "معبد الأقصر"
      },
      {
        "id": "royal_tomb",
        "name": "مقبرة ملكية",
        "sub_category_key": "catValleyKings",
        "sub_category": "وادي الملوك والملكات",
        "photo_url": "assets/louxor/tombe.jpg",
        "description": "استكشف الأجواء الخاصة للملوك الراحلين. تقدم المقابر الملكية رحلة فريدة إلى العالم الآخر، حيث تغطي كل جدار نصوص مقدسة وجداريات بألوان زاهية تحمي الملك والملكة في رحلتهما الأبدية.",
        "mapsQuery": "وادي الملوك الأقصر"
      },
      {
        "id": "valley_kings_queens",
        "name": "وادي الملوك والملكات",
        "sub_category_key": "catValleyKings",
        "sub_category": "وادي الملوك والملكات",
        "photo_url": "assets/louxor/rois.jpg",
        "description": "الموقع الأكثر شهرة في جبانة طيبة. بين الجبال الجافة بالبر الغربي، حفر الفراعنة وزوجاتهم مقابرهم السرية بعيداً عن الأعين لضمان خلودهم في عالم الآلهة.",
        "mapsQuery": "وادي الملوك والملكات الأقصر"
      },
      {
        "id": "colossi_memnon",
        "name": "تمثالا ممنون",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/me.jpg",
        "description": "تمثالان ضخمان من الحجر الرملي يقفان بشموخ في السهل. رغم اختفاء معبد أمينحتب الثالث الجنائزي الذي كانا يحرسانه، يظل هذان التمثالان شاهدين على العظمة الفائقة للمباني الإمبراطورية في ذلك العصر.",
        "mapsQuery": "تمثالا ممنون الأقصر"
      },
      {
        "id": "medinet_habu",
        "name": "معبد مدينة هابو",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم الأثرية",
        "photo_url": "assets/louxor/habu.jpg",
        "description": "معبد جنائزي غني للغاية، حيث تحكي نقوشه الملونة المعارك المنتصرة لرمسيس الثالث ضد شعوب البحر. إنه من الأماكن النادرة التي لا تزال فيها الألوان الأصلية للنقوش واضحة ومحتفظة برونقها.",
        "mapsQuery": "معبد مدينة هابو الأقصر"
      },
      {
        "id": "deir_el_medina",
        "name": "دير المدينة",
        "sub_category_key": "catValleyArtisans",
        "sub_category": "وادي العمال",
        "photo_url": "assets/louxor/deir.jpg",
        "description": "قرية العمال والحرفيين الذين نحتوا ولونوا تحف وادي الملوك. يقدم هذا الموقع نظرة نادرة ومؤثرة على الحياة اليومية للمصريين القدماء، مع منازلهم وورشهم ومقابرهم العائلية المزخرفة.",
        "mapsQuery": "دير المدينة الأقصر"
      },
      {
        "id": "hot_air_balloon",
        "name": "الأقصر بالمنطاد الطائر",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة في الأقصر",
        "photo_url": "assets/louxor/m.jpg",
        "description": "تجربة جوية لا تُنسى عند شروق الشمس. تحليق فوق النيل والمواقع الأثرية لاستيعاب روعة التخطيط المعماري لطيبة، حيث الخضرة الخصبة من جهة وامتداد الصحراء الهادئ من جهة أخرى.",
        "mapsQuery": "منطاد الأقصر"
      },
      {
        "id": "nile_boat_ride",
        "name": "الأقصر بالقارب",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة في الأقصر",
        "photo_url": "assets/louxor/b.jpg",
        "description": "الإبحار في نهر النيل هو شريان الحياة والروح الحقيقية للأقصر. سواء على متن الفلوكة التقليدية أو سفينة سياحية، يوفر النيل إطلالة مريحة على الضفاف حيث تستمر الحياة الزراعية على إيقاع الفصول منذ آلاف السنين.",
        "mapsQuery": "جولة فلوكة النيل الأقصر"
      },
    ],
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
      case "catValleyKings":
        return Icons.terrain_outlined;
      case "catValleyArtisans":
        return Icons.handyman_outlined;
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
    final all = _localizedLouxorData[_lang] ?? _localizedLouxorData['fr']!;
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
                _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Louxor"),
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
        _localizedLouxorData[_lang] ?? _localizedLouxorData['fr']!;
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
                  child: const _PlaceImage('assets/louxor/k.jpg'),
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
  'karnak_temple': {
    'related': ['karnak_open_air_museum', 'luxor_temple', 'valley_kings_queens'],
    'fr': {
      'duration': "3 à 4 h",
      'best': "Dès l'ouverture, tôt le matin",
      'tip': "Arrivez à l'ouverture pour profiter de la fraîcheur et d'un site encore calme ; prévoyez de l'eau, un chapeau et de bonnes chaussures.",
      'fact': "Le complexe a été agrandi et remanié pendant environ deux mille ans ; la salle hypostyle à elle seule couvre près de 5 000 m², et ses douze colonnes centrales dépassent 20 mètres de haut.",
      'hl': [
        {'t': "La salle hypostyle", 'd': "Une forêt de 134 colonnes couvertes de hiéroglyphes, où la lumière tombe en rais depuis les fenêtres hautes de la nef centrale."},
        {'t': "L'obélisque d'Hatchepsout", 'd': "Taillé dans un seul bloc de granit, il s'élève à près de 30 mètres : l'un des plus hauts obélisques antiques encore debout."},
        {'t': "Le lac sacré", 'd': "Réservé aux purifications des prêtres, il est dominé par un grand scarabée de pierre autour duquel la tradition veut qu'on tourne pour porter chance."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours",
      'best': "First thing in the morning",
      'tip': "Arrive at opening time to enjoy the cool air and a still-quiet site; bring water, a hat and sturdy shoes.",
      'fact': "The complex was enlarged and reworked over some two thousand years; the hypostyle hall alone covers nearly 5,000 m², and its twelve central columns stand over 20 metres tall.",
      'hl': [
        {'t': "The Hypostyle Hall", 'd': "A forest of 134 columns covered in hieroglyphs, where light falls in shafts from the high windows of the central nave."},
        {'t': "Hatshepsut's obelisk", 'd': "Carved from a single block of granite, it rises nearly 30 metres: one of the tallest ancient obelisks still standing."},
        {'t': "The Sacred Lake", 'd': "Used for the priests' purification rituals, it is overlooked by a great stone scarab that, by tradition, visitors walk around for good luck."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات",
      'best': "في الصباح الباكر عند الافتتاح",
      'tip': "احرص على الوصول عند الافتتاح لتستمتع بالأجواء المنعشة والموقع الهادئ، وخذ معك الماء وقبعة وحذاءً مريحًا.",
      'fact': "توسّع المجمع وأُعيد تشكيله على مدى نحو ألفي عام؛ وتغطي قاعة الأعمدة الكبرى وحدها قرابة 5000 متر مربع، وتتجاوز أعمدتها الاثنا عشر الوسطى 20 مترًا ارتفاعًا.",
      'hl': [
        {'t': "قاعة الأعمدة الكبرى", 'd': "غابة من 134 عمودًا مغطاة بالنقوش الهيروغليفية، يتسلل الضوء بينها من النوافذ العالية للصحن الأوسط."},
        {'t': "مسلة حتشبسوت", 'd': "نُحتت من كتلة واحدة من الجرانيت ويقارب ارتفاعها 30 مترًا، وهي من أعلى المسلات القديمة التي لا تزال قائمة."},
        {'t': "البحيرة المقدسة", 'd': "كانت مخصصة لطقوس تطهّر الكهنة، ويشرف عليها جعران حجري ضخم يدور حوله الزوار طلبًا للحظ، وفق التقليد."},
      ],
    },
  },
  'karnak_open_air_museum': {
    'related': ['karnak_temple', 'luxor_temple', 'medinet_habu'],
    'fr': {
      'duration': "1 h",
      'best': "En fin de visite de Karnak, quand les groupes sont partis",
      'tip': "Vérifiez à la billetterie si un billet distinct de celui de Karnak est nécessaire, et gardez-lui un peu de temps : les détails se lisent mieux sans se presser.",
      'fact': "Les blocs de la chapelle blanche de Sésostris Ier avaient été réemployés comme remplissage dans un pylône voisin ; ils ont été retrouvés puis remontés au XXe siècle, comme un immense puzzle.",
      'hl': [
        {'t': "La chapelle blanche de Sésostris Ier", 'd': "Un petit sanctuaire en calcaire blanc, aux reliefs d'une finesse remarquable, considéré comme l'un des joyaux de l'art du Moyen Empire."},
        {'t': "La chapelle d'albâtre d'Amenhotep Ier", 'd': "Un édifice de calcite luisante, reconstitué avec soin, qui servait de reposoir à la barque sacrée."},
        {'t': "Les blocs d'Akhenaton", 'd': "Des milliers de petits blocs décorés, issus des monuments de l'époque amarnienne, permettent de lire un style artistique à part."},
      ],
    },
    'en': {
      'duration': "1 hour",
      'best': "At the end of your Karnak visit, once the tour groups have left",
      'tip': "Check at the ticket office whether a ticket separate from Karnak's is required, and give it some time: the details reward a slower pace.",
      'fact': "The blocks of Senusret I's White Chapel had been reused as filling in a neighbouring pylon; they were found and reassembled in the 20th century, like an immense puzzle.",
      'hl': [
        {'t': "Senusret I's White Chapel", 'd': "A small white limestone shrine with remarkably fine reliefs, regarded as one of the jewels of Middle Kingdom art."},
        {'t': "Amenhotep I's Alabaster Chapel", 'd': "A gleaming calcite building, carefully reconstructed, which served as a resting place for the sacred barque."},
        {'t': "The Akhenaten blocks", 'd': "Thousands of small decorated blocks from Amarna-period monuments reveal a strikingly different artistic style."},
      ],
    },
    'ar': {
      'duration': "ساعة",
      'best': "في نهاية زيارة الكرنك بعد انصراف المجموعات السياحية",
      'tip': "اسأل في شباك التذاكر إن كانت هناك تذكرة منفصلة عن الكرنك، وخصّص له بعض الوقت فتفاصيله تستحق التمهّل.",
      'fact': "أُعيد استخدام كتل المقصورة البيضاء لسنوسرت الأول كحشو داخل صرح مجاور، ثم عُثر عليها وأُعيد تركيبها في القرن العشرين كأنها أحجية ضخمة.",
      'hl': [
        {'t': "المقصورة البيضاء لسنوسرت الأول", 'd': "مزار صغير من الحجر الجيري الأبيض ذو نقوش بالغة الدقة، ويُعد من درر فن الدولة الوسطى."},
        {'t': "مقصورة الألباستر لأمنحتب الأول", 'd': "بناء من الكالسيت اللامع أُعيد تركيبه بعناية، وكان مخصصًا لاستراحة المركب المقدس."},
        {'t': "كتل إخناتون", 'd': "آلاف الكتل الصغيرة المزخرفة من آثار عصر العمارنة تكشف عن أسلوب فني مختلف تمامًا."},
      ],
    },
  },
  'luxor_temple': {
    'related': ['karnak_temple', 'nile_boat_ride', 'colossi_memnon'],
    'fr': {
      'duration': "1 h à 1 h 30",
      'best': "À la tombée de la nuit, lorsque le temple s'illumine",
      'tip': "Venez en fin d'après-midi : vous verrez la pierre dorée au soleil couchant, puis les projecteurs prendre le relais, sans avoir à revenir.",
      'fact': "L'obélisque jumeau de celui qui se dresse ici se trouve place de la Concorde, à Paris, où il a été érigé en 1836.",
      'hl': [
        {'t': "Les colosses de Ramsès II", 'd': "Assis ou debout devant le pylône, ils veillent sur l'entrée depuis plus de 3 000 ans."},
        {'t': "Une mosquée dans le temple", 'd': "La mosquée d'Abou el-Haggag, construite au sein même du temple, témoigne de siècles de continuité religieuse."},
        {'t': "L'allée des sphinx", 'd': "Longue d'environ 2,7 km, elle reliait autrefois le temple de Louxor à celui de Karnak lors des grandes processions."},
      ],
    },
    'en': {
      'duration': "1 to 1.5 hours",
      'best': "At nightfall, when the temple is lit up",
      'tip': "Come in the late afternoon: you'll see the stone glow gold at sunset, then the floodlights take over, without having to return.",
      'fact': "The twin of the obelisk standing here is in the Place de la Concorde in Paris, where it was erected in 1836.",
      'hl': [
        {'t': "The colossi of Ramesses II", 'd': "Seated and standing before the pylon, they have guarded the entrance for more than 3,000 years."},
        {'t': "A mosque inside the temple", 'd': "The Abu el-Haggag Mosque, built within the temple itself, bears witness to centuries of religious continuity."},
        {'t': "The Avenue of Sphinxes", 'd': "About 2.7 km long, it once linked Luxor Temple to Karnak for the great processions."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعة ونصف",
      'best': "عند حلول الليل حين يُضاء المعبد",
      'tip': "تعال في أواخر العصر لترى الحجر ذهبيًا عند الغروب ثم تتولى الأضواء الكاشفة المشهد، دون الحاجة للعودة.",
      'fact': "توأم المسلة القائمة هنا يقف في ساحة الكونكورد بباريس حيث نُصب عام 1836.",
      'hl': [
        {'t': "تماثيل رمسيس الثاني", 'd': "جالسة وواقفة أمام الصرح، تحرس المدخل منذ أكثر من 3000 عام."},
        {'t': "مسجد داخل المعبد", 'd': "يشهد مسجد أبي الحجاج المبني داخل المعبد نفسه على قرون من الاستمرارية الدينية."},
        {'t': "طريق الكباش", 'd': "يبلغ طوله نحو 2.7 كم، وكان يربط معبد الأقصر بمعبد الكرنك في الاحتفالات الكبرى."},
      ],
    },
  },
  'royal_tomb': {
    'related': ['valley_kings_queens', 'deir_el_medina', 'hot_air_balloon'],
    'fr': {
      'duration': "30 à 45 min par tombe",
      'best': "Tôt le matin, avant la chaleur",
      'tip': "Le billet d'entrée donne généralement accès à trois tombes au choix ; quelques-unes, comme celle de Toutânkhamon, demandent un billet supplémentaire. Les règles sur les photos varient selon les tombes.",
      'fact': "Les parois reproduisent des textes funéraires, tels que le Livre des Portes ou l'Amdouat, véritables guides du voyage nocturne du roi dans l'au-delà.",
      'hl': [
        {'t': "Des textes sacrés", 'd': "Hiéroglyphes et scènes mythologiques recouvrent les couloirs, comme un mode d'emploi pour l'éternité."},
        {'t': "Des plafonds étoilés", 'd': "Dans plusieurs tombes, la voûte céleste est peinte au plafond de la chambre funéraire."},
        {'t': "Des couleurs préservées", 'd': "À l'abri de la lumière et de l'air pendant des millénaires, les pigments ont gardé un éclat saisissant."},
      ],
    },
    'en': {
      'duration': "30 to 45 minutes per tomb",
      'best': "Early morning, before the heat",
      'tip': "The entry ticket usually covers three tombs of your choice; a few, such as Tutankhamun's, require an extra ticket. Photo rules vary from tomb to tomb.",
      'fact': "The walls reproduce funerary texts, such as the Book of Gates or the Amduat, true guides to the king's nocturnal journey through the afterlife.",
      'hl': [
        {'t': "Sacred texts", 'd': "Hieroglyphs and mythological scenes cover the corridors, like an instruction manual for eternity."},
        {'t': "Starry ceilings", 'd': "In several tombs, the vault of the heavens is painted across the ceiling of the burial chamber."},
        {'t': "Preserved colours", 'd': "Sheltered from light and air for millennia, the pigments have kept a striking brilliance."},
      ],
    },
    'ar': {
      'duration': "من 30 إلى 45 دقيقة لكل مقبرة",
      'best': "في الصباح الباكر قبل اشتداد الحرارة",
      'tip': "تتيح تذكرة الدخول عادةً زيارة ثلاث مقابر من اختيارك، وبعضها مثل مقبرة توت عنخ آمون يتطلب تذكرة إضافية. وتختلف قواعد التصوير من مقبرة إلى أخرى.",
      'fact': "تحمل الجدران نصوصًا جنائزية مثل كتاب البوابات وكتاب إمي دوات، وهي أدلة حقيقية لرحلة الملك الليلية في العالم الآخر.",
      'hl': [
        {'t': "نصوص مقدسة", 'd': "تغطي الهيروغليفية والمشاهد الأسطورية الممرات كأنها دليل للخلود."},
        {'t': "أسقف مرصعة بالنجوم", 'd': "في عدة مقابر تُرسم قبة السماء على سقف حجرة الدفن."},
        {'t': "ألوان محفوظة", 'd': "بقيت الأصباغ زاهية بشكل لافت لأنها كانت بمنأى عن الضوء والهواء آلاف السنين."},
      ],
    },
  },
  'valley_kings_queens': {
    'related': ['royal_tomb', 'deir_el_medina', 'medinet_habu'],
    'fr': {
      'duration': "3 à 4 h",
      'best': "Dès l'ouverture, avant la chaleur",
      'tip': "Emportez de l'eau et un chapeau : il y a peu d'ombre. Une petite navette relie l'entrée aux tombes, et la vallée des Reines se visite à part.",
      'fact': "Howard Carter y a découvert en 1922 la tombe de Toutânkhamon, l'une des rares à avoir été retrouvée presque intacte. Le site fait partie de « Thèbes antique et sa nécropole », inscrite à l'UNESCO en 1979.",
      'hl': [
        {'t': "La tombe de Toutânkhamon", 'd': "Modeste par la taille, elle est célèbre pour avoir livré un trésor funéraire quasi intact."},
        {'t': "La vallée des Reines", 'd': "Épouses et enfants de pharaons y reposent, dont Néfertari, dont la tombe est réputée pour la beauté de ses peintures."},
        {'t': "Un paysage de désert et de falaises", 'd': "La pointe pyramidale de la montagne qui domine la vallée aurait inspiré le choix du lieu."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours",
      'best': "First thing in the morning, before the heat",
      'tip': "Bring water and a hat: there is little shade. A small shuttle runs from the entrance to the tombs, and the Valley of the Queens is visited separately.",
      'fact': "Howard Carter discovered Tutankhamun's tomb here in 1922, one of the few found almost intact. The site is part of “Ancient Thebes with its Necropolis”, inscribed by UNESCO in 1979.",
      'hl': [
        {'t': "Tutankhamun's tomb", 'd': "Modest in size, it is famous for yielding an almost intact funerary treasure."},
        {'t': "The Valley of the Queens", 'd': "Pharaohs' wives and children rest here, including Nefertari, whose tomb is renowned for the beauty of its paintings."},
        {'t': "A landscape of desert and cliffs", 'd': "The pyramid-shaped peak overlooking the valley is said to have inspired the choice of this place."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات",
      'best': "في الصباح الباكر قبل اشتداد الحرارة",
      'tip': "خذ معك الماء وقبعة فالظل قليل. تنقلك حافلة صغيرة من المدخل إلى المقابر، وتُزار وادي الملكات بشكل منفصل.",
      'fact': "اكتشف هوارد كارتر هنا عام 1922 مقبرة توت عنخ آمون، إحدى المقابر القليلة التي عُثر عليها شبه سليمة. ويُعد الموقع جزءًا من «طيبة القديمة وجبانتها» المدرجة لدى اليونسكو عام 1979.",
      'hl': [
        {'t': "مقبرة توت عنخ آمون", 'd': "صغيرة الحجم لكنها شهيرة لأنها قدمت كنزًا جنائزيًا شبه كامل."},
        {'t': "وادي الملكات", 'd': "تضم زوجات الفراعنة وأبناءهم، ومنهم نفرتاري التي اشتهرت مقبرتها بجمال لوحاتها."},
        {'t': "مشهد من الصحراء والجروف", 'd': "يُقال إن القمة الهرمية التي تعلو الوادي كانت وراء اختيار هذا المكان."},
      ],
    },
  },
  'colossi_memnon': {
    'related': ['medinet_habu', 'valley_kings_queens', 'hot_air_balloon'],
    'fr': {
      'duration': "20 à 30 min",
      'best': "Au lever du soleil",
      'tip': "L'arrêt est bref et se fait souvent en route vers la vallée des Rois ; à l'aube, la lumière rasante sur le grès est superbe pour les photos.",
      'fact': "Chaque statue mesure environ 18 mètres. Après un séisme en 27 av. J.-C., la statue nord se serait mise à « chanter » à l'aube, jusqu'à sa restauration sous l'empereur romain Septime Sévère.",
      'hl': [
        {'t': "Deux géants de 18 mètres", 'd': "Taillés dans des blocs de grès, ils représentent Amenhotep III assis, le regard tourné vers le Nil."},
        {'t': "Le colosse qui chantait", 'd': "Dans l'Antiquité, voyageurs grecs et romains venaient l'entendre, et ont gravé leurs impressions sur ses jambes."},
        {'t': "Un temple disparu", 'd': "Le temple funéraire qu'ils gardaient était l'un des plus vastes d'Égypte ; il n'en reste que des vestiges, que des fouilles continuent de révéler."},
      ],
    },
    'en': {
      'duration': "20 to 30 minutes",
      'best': "At sunrise",
      'tip': "The stop is short and often made on the way to the Valley of the Kings; at dawn, the low light on the sandstone is superb for photos.",
      'fact': "Each statue stands about 18 metres tall. After an earthquake in 27 BC, the northern statue was said to “sing” at dawn, until it was restored under the Roman emperor Septimius Severus.",
      'hl': [
        {'t': "Two 18-metre giants", 'd': "Carved from blocks of sandstone, they depict the seated Amenhotep III, gazing toward the Nile."},
        {'t': "The singing colossus", 'd': "In antiquity, Greek and Roman travellers came to hear it, and carved their impressions on its legs."},
        {'t': "A vanished temple", 'd': "The mortuary temple they guarded was among the largest in Egypt; only remains survive, which excavations continue to reveal."},
      ],
    },
    'ar': {
      'duration': "من 20 إلى 30 دقيقة",
      'best': "عند شروق الشمس",
      'tip': "الوقفة قصيرة وغالبًا ما تكون في الطريق إلى وادي الملوك؛ وعند الفجر يكون الضوء المنخفض على الحجر الرملي رائعًا للتصوير.",
      'fact': "يبلغ ارتفاع كل تمثال نحو 18 مترًا. وبعد زلزال عام 27 ق.م قيل إن التمثال الشمالي كان «يغني» عند الفجر، حتى رمّمه الإمبراطور الروماني سبتيموس سيفيروس.",
      'hl': [
        {'t': "عملاقان بارتفاع 18 مترًا", 'd': "نُحتا من كتل الحجر الرملي ويصوّران أمنحتب الثالث جالسًا ناظرًا نحو النيل."},
        {'t': "التمثال الذي كان يغني", 'd': "في العصور القديمة كان المسافرون اليونانيون والرومان يأتون للاستماع إليه، ونقشوا انطباعاتهم على ساقيه."},
        {'t': "معبد اختفى", 'd': "كان المعبد الجنائزي الذي يحرسانه من أكبر معابد مصر، ولم يتبق منه سوى آثار لا تزال الحفائر تكشف عنها."},
      ],
    },
  },
  'medinet_habu': {
    'related': ['colossi_memnon', 'deir_el_medina', 'valley_kings_queens'],
    'fr': {
      'duration': "1 h 30 à 2 h",
      'best': "Fin d'après-midi, lorsque la lumière dore la pierre",
      'tip': "Bien moins fréquenté que Karnak : prenez le temps de lever les yeux vers les plafonds et les chapiteaux, où les couleurs d'origine subsistent.",
      'fact': "Construit pour Ramsès III il y a environ 3 200 ans, ce temple est l'un des mieux conservés de la rive ouest ; ses murs racontent la victoire sur les peuples de la mer.",
      'hl': [
        {'t': "La bataille contre les peuples de la mer", 'd': "Des reliefs d'un réalisme saisissant montrent navires, guerriers et prisonniers sur les murs extérieurs."},
        {'t': "Des couleurs encore vives", 'd': "Dans les cours et sous les portiques, la polychromie d'origine est restée remarquablement visible."},
        {'t': "La porte fortifiée", 'd': "L'entrée monumentale, inspirée des forteresses syro-palestiniennes, impressionne dès les premiers pas."},
      ],
    },
    'en': {
      'duration': "1.5 to 2 hours",
      'best': "Late afternoon, when the light gilds the stone",
      'tip': "Far less crowded than Karnak: take time to look up at the ceilings and capitals, where the original colours survive.",
      'fact': "Built for Ramesses III some 3,200 years ago, this temple is among the best preserved on the West Bank; its walls recount the victory over the Sea Peoples.",
      'hl': [
        {'t': "The battle against the Sea Peoples", 'd': "Strikingly realistic reliefs show ships, warriors and prisoners on the outer walls."},
        {'t': "Colours still vivid", 'd': "In the courtyards and beneath the porticoes, the original polychromy remains remarkably visible."},
        {'t': "The fortified gateway", 'd': "The monumental entrance, inspired by Syro-Palestinian fortresses, impresses from the very first steps."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين",
      'best': "وقت العصر حين يضفي الضوء لونًا ذهبيًا على الحجر",
      'tip': "إنه أقل ازدحامًا بكثير من الكرنك، فخذ وقتك لتتأمل الأسقف والتيجان حيث لا تزال الألوان الأصلية باقية.",
      'fact': "شُيّد لرمسيس الثالث قبل نحو 3200 عام، وهو من أفضل معابد البر الغربي حفظًا، وتروي جدرانه الانتصار على شعوب البحر.",
      'hl': [
        {'t': "معركة شعوب البحر", 'd': "نقوش بالغة الواقعية تُظهر السفن والمحاربين والأسرى على الجدران الخارجية."},
        {'t': "ألوان لا تزال زاهية", 'd': "في الأفنية وتحت الأروقة بقيت الألوان الأصلية ظاهرة بشكل لافت."},
        {'t': "البوابة المحصنة", 'd': "يبهر المدخل الضخم المستوحى من الحصون السورية الفلسطينية منذ الخطوات الأولى."},
      ],
    },
  },
  'deir_el_medina': {
    'related': ['valley_kings_queens', 'royal_tomb', 'medinet_habu'],
    'fr': {
      'duration': "1 h 30",
      'best': "Le matin, quand le village est calme",
      'tip': "Prévoyez des chaussures fermées pour les ruelles de pierre ; l'accès à certaines tombes décorées se fait par un billet distinct.",
      'fact': "Vers 1155 av. J.-C., sous Ramsès III, les artisans du village ont cessé le travail faute de ration : c'est l'une des plus anciennes grèves connues de l'histoire.",
      'hl': [
        {'t': "Le village des artisans", 'd': "Plans de maisons, ruelles et ateliers permettent d'imaginer le quotidien de ceux qui décoraient les tombes royales."},
        {'t': "La tombe de Sennedjem", 'd': "Petite mais éblouissante, elle déploie des peintures aux couleurs éclatantes dans une chambre voûtée."},
        {'t': "Le temple d'Hathor", 'd': "Un sanctuaire d'époque ptolémaïque, dédié à Hathor et à Maât, veille sur le village."},
      ],
    },
    'en': {
      'duration': "1.5 hours",
      'best': "Morning, when the village is quiet",
      'tip': "Wear closed shoes for the stone lanes; access to some decorated tombs requires a separate ticket.",
      'fact': "Around 1155 BC, under Ramesses III, the village's craftsmen downed tools over unpaid rations: one of the earliest known strikes in history.",
      'hl': [
        {'t': "The artisans' village", 'd': "House plans, lanes and workshops let you imagine the daily life of those who decorated the royal tombs."},
        {'t': "The tomb of Sennedjem", 'd': "Small but dazzling, it displays brilliantly coloured paintings in a vaulted chamber."},
        {'t': "The Temple of Hathor", 'd': "A Ptolemaic-era sanctuary dedicated to Hathor and Maat watches over the village."},
      ],
    },
    'ar': {
      'duration': "ساعة ونصف",
      'best': "في الصباح حين تكون القرية هادئة",
      'tip': "ارتدِ حذاءً مغلقًا للأزقة الحجرية؛ ويتطلب دخول بعض المقابر المزخرفة تذكرة منفصلة.",
      'fact': "نحو عام 1155 ق.م، في عهد رمسيس الثالث، توقف حرفيو القرية عن العمل بسبب تأخر الحصص الغذائية، وهو من أقدم الإضرابات المعروفة في التاريخ.",
      'hl': [
        {'t': "قرية الحرفيين", 'd': "تتيح مخططات البيوت والأزقة والورش تخيّل الحياة اليومية لمن زيّنوا المقابر الملكية."},
        {'t': "مقبرة سنجم", 'd': "صغيرة لكنها مبهرة، تعرض لوحات بألوان زاهية داخل حجرة مقببة."},
        {'t': "معبد حتحور", 'd': "مزار من العصر البطلمي مكرّس لحتحور وماعت يطل على القرية."},
      ],
    },
  },
  'hot_air_balloon': {
    'related': ['nile_boat_ride', 'valley_kings_queens', 'colossi_memnon'],
    'fr': {
      'duration': "Environ 45 min de vol",
      'best': "Au lever du soleil",
      'tip': "Réservez à l'avance : les vols dépendent de la météo, surtout du vent. Prévoyez une petite veste, car il fait frais avant l'aube.",
      'fact': "Les ballons décollent de la rive ouest peu avant le lever du soleil, quand l'air est calme et stable : c'est ce qui permet de glisser doucement au-dessus des temples.",
      'hl': [
        {'t': "Le soleil sur la vallée du Nil", 'd': "La lumière naissante dore tour à tour le fleuve, les champs et les falaises thébaines."},
        {'t': "Les temples vus d'en haut", 'd': "Colosses, temples funéraires et nécropole se révèlent dans leur plan d'ensemble."},
        {'t': "Le contraste vert et désert", 'd': "Une frontière nette sépare les terres cultivées de l'immensité du désert."},
      ],
    },
    'en': {
      'duration': "About 45 minutes of flight",
      'best': "At sunrise",
      'tip': "Book in advance: flights depend on the weather, especially the wind. Bring a light jacket, as it is cool before dawn.",
      'fact': "The balloons lift off from the West Bank shortly before sunrise, when the air is calm and stable, which lets them drift gently over the temples.",
      'hl': [
        {'t': "Sunrise over the Nile valley", 'd': "The first light gilds the river, the fields and the Theban cliffs in turn."},
        {'t': "Temples from above", 'd': "Colossi, mortuary temples and the necropolis reveal themselves in their overall layout."},
        {'t': "The contrast of green and desert", 'd': "A sharp line separates the cultivated land from the immensity of the desert."},
      ],
    },
    'ar': {
      'duration': "نحو 45 دقيقة من التحليق",
      'best': "عند شروق الشمس",
      'tip': "احجز مسبقًا فالرحلات تعتمد على الطقس وخاصة الرياح. وخذ معك سترة خفيفة فالجو بارد قبل الفجر.",
      'fact': "تقلع المناطيد من البر الغربي قبيل شروق الشمس حين يكون الهواء هادئًا ومستقرًا، مما يتيح الانسياب بلطف فوق المعابد.",
      'hl': [
        {'t': "الشروق فوق وادي النيل", 'd': "يكسو الضوء الأول النهر والحقول وجروف طيبة بلون ذهبي تباعًا."},
        {'t': "المعابد من الأعلى", 'd': "تنكشف التماثيل والمعابد الجنائزية والجبانة في تخطيطها العام."},
        {'t': "تباين الأخضر والصحراء", 'd': "يفصل خط حاد بين الأراضي المزروعة واتساع الصحراء."},
      ],
    },
  },
  'nile_boat_ride': {
    'related': ['hot_air_balloon', 'luxor_temple', 'karnak_temple'],
    'fr': {
      'duration': "1 h (promenade en felouque)",
      'best': "Au coucher du soleil",
      'tip': "Convenez du prix et de la durée avant d'embarquer, et choisissez la fin de journée, quand la brise se lève et que la lumière s'adoucit.",
      'fact': "Les anciens Égyptiens plaçaient les nécropoles sur la rive ouest, là où le soleil se couche, et les villes des vivants sur la rive est, là où il se lève.",
      'hl': [
        {'t': "La felouque au crépuscule", 'd': "Ces voiliers traditionnels glissent presque en silence, au rythme du vent."},
        {'t': "Deux rives, deux mondes", 'd': "La ville animée sur la rive est, les champs et les falaises thébaines sur la rive ouest."},
        {'t': "L'île aux bananes", 'd': "Une escale prisée sur le fleuve, au milieu des cultures, pour une pause fraîcheur."},
      ],
    },
    'en': {
      'duration': "1 hour (felucca ride)",
      'best': "At sunset",
      'tip': "Agree on the price and duration before boarding, and go late in the day when the breeze rises and the light softens.",
      'fact': "The ancient Egyptians placed the necropolises on the west bank, where the sun sets, and the cities of the living on the east bank, where it rises.",
      'hl': [
        {'t': "A felucca at dusk", 'd': "These traditional sailboats glide almost silently, at the pace of the wind."},
        {'t': "Two banks, two worlds", 'd': "The lively city on the east bank, the fields and Theban cliffs on the west bank."},
        {'t': "Banana Island", 'd': "A popular stop on the river, among the crops, for a cool break."},
      ],
    },
    'ar': {
      'duration': "ساعة (جولة بالفلوكة)",
      'best': "عند غروب الشمس",
      'tip': "اتفق على السعر والمدة قبل الركوب، واختر آخر النهار حين يهبّ النسيم ويلين الضوء.",
      'fact': "وضع المصريون القدماء الجبانات على الضفة الغربية حيث تغرب الشمس، ومدن الأحياء على الضفة الشرقية حيث تشرق.",
      'hl': [
        {'t': "فلوكة عند الغسق", 'd': "تنساب هذه المراكب الشراعية التقليدية بصمت تقريبًا على إيقاع الريح."},
        {'t': "ضفتان وعالمان", 'd': "المدينة النابضة على الضفة الشرقية، والحقول وجروف طيبة على الضفة الغربية."},
        {'t': "جزيرة الموز", 'd': "محطة محببة على النهر وسط المزروعات لاستراحة منعشة."},
      ],
    },
  },
};