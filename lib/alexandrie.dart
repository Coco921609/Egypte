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

class AlexandriePage extends StatefulWidget {
  const AlexandriePage({super.key});

  @override
  State<AlexandriePage> createState() => _AlexandriePageState();
}

class _AlexandriePageState extends State<AlexandriePage>
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
      'pageTitle': 'Alexandrie',
      'tagline': 'La perle de la Méditerranée',
      'places': 'lieux',
      'all': 'Tout',
      'favs': 'Favoris',
      'noFav': 'Aucun favori pour le moment.\nTouche le ♡ pour en ajouter.',
      'discover': 'Découvrir',
      'mapsBtn': 'Ouvrir dans Google Maps',
      'catMonuments': 'Monuments historiques',
      'catActivities': 'Activités incontournables',
      'catHistory': 'Lieux historiques',
      'catCulture': 'Culture et Savoir',
      'about': 'À propos',
      'overview': 'En bref',
      'duration': 'Durée conseillée',
      'bestTime': 'Meilleur moment',
      'category': 'Catégorie',
      'highlights': 'Points forts',
      'didYouKnow': 'Le saviez-vous ?',
      'tip': 'Conseil du voyageur',
      'seeAlso': 'À voir aussi',
    },
    'en': {
      'pageTitle': 'Alexandria',
      'tagline': 'The Pearl of the Mediterranean',
      'places': 'places',
      'all': 'All',
      'favs': 'Favorites',
      'noFav': 'No favorites yet.\nTap the ♡ to add some.',
      'discover': 'Discover',
      'mapsBtn': 'Open in Google Maps',
      'catMonuments': 'Historical Monuments',
      'catActivities': 'Must-do Activities',
      'catHistory': 'Historical Places',
      'catCulture': 'Culture and Knowledge',
      'about': 'About',
      'overview': 'At a glance',
      'duration': 'Suggested time',
      'bestTime': 'Best time',
      'category': 'Category',
      'highlights': 'Highlights',
      'didYouKnow': 'Did you know?',
      'tip': "Traveller's tip",
      'seeAlso': 'Also worth a visit',
    },
    'ar': {
      'pageTitle': 'الإسكندرية',
      'tagline': 'لؤلؤة البحر المتوسط',
      'places': 'مكان',
      'all': 'الكل',
      'favs': 'المفضلة',
      'noFav': 'لا توجد أماكن مفضلة بعد.\nاضغط على ♡ للإضافة.',
      'discover': 'اكتشف',
      'mapsBtn': 'افتح في خرائط Google',
      'catMonuments': 'معالم تاريخية',
      'catActivities': 'أنشطة لا بد منها',
      'catHistory': 'أماكن تاريخية',
      'catCulture': 'الثقافة والمعرفة',
      'about': 'نبذة',
      'overview': 'لمحة سريعة',
      'duration': 'المدة المقترحة',
      'bestTime': 'أفضل وقت',
      'category': 'الفئة',
      'highlights': 'أبرز المعالم',
      'didYouKnow': 'هل تعلم؟',
      'tip': 'نصيحة للمسافر',
      'seeAlso': 'اكتشف أيضًا',
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedData = {
    'fr': [
      {
        "id": "citadelle_qaitbay",
        "name": "Citadelle de Qaitbay",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments historiques",
        "photo_url": "assets/alexendrie/qai.jpg",
        "description": "Érigée au XVe siècle sur les vestiges du mythique Phare d'Alexandrie, l'une des sept merveilles du monde antique, cette forteresse défensive en pierre calcaire offre une plongée fascinante dans l'histoire militaire égyptienne. Ses remparts massifs, baignés par les vagues de la Méditerranée, témoignent de la stratégie défensive du sultan Qaitbay face aux menaces ottomanes de l'époque.",
        "mapsQuery": "Citadelle de Qaitbay Alexandrie"
      },
      {
        "id": "corniche_pont_stanley",
        "name": "La Corniche et le pont Stanley",
        "sub_category_key": "catActivities",
        "sub_category": "Activités incontournables",
        "photo_url": "assets/alexendrie/pont.jpg",
        "description": "Artère vitale et poétique d'Alexandrie, la Corniche s'étire le long du rivage méditerranéen sur plusieurs kilomètres, offrant un panorama unique où se mêlent modernité urbaine et nostalgie historique. Le pont Stanley, avec ses tours caractéristiques, constitue le joyau de cette balade, particulièrement au coucher du soleil lorsque les lumières scintillent sur l'eau, capturant l'essence même de la 'Perle de la Méditerranée'.",
        "mapsQuery": "Pont Stanley Alexandrie"
      },
      {
        "id": "palais_montaza",
        "name": "Palais de Montaza",
        "sub_category_key": "catHistory",
        "sub_category": "Lieux historiques",
        "photo_url": "assets/alexendrie/palais.jpeg",
        "description": "Véritable havre de paix, le complexe royal de Montaza s'étend sur des hectares de jardins luxuriants surplombant la mer. Le palais central, inspiré par un mélange audacieux de styles florentin et turc, servait autrefois de résidence d'été à la famille royale égyptienne. Se promener dans ses allées ombragées, c'est s'immerger dans une époque de faste et de raffinement architectural européen au cœur de l'Égypte.",
        "mapsQuery": "Palais de Montaza Alexandrie"
      },
      {
        "id": "bibliotheque_alexandrina",
        "name": "Bibliothèque Alexandrina",
        "sub_category_key": "catCulture",
        "sub_category": "Culture et Savoir",
        "photo_url": "assets/alexendrie/alexandrina.jpg",
        "description": "Plus qu'un simple bâtiment, la nouvelle Bibliothèque d'Alexandrie est un monument à la connaissance universelle, conçu pour réincarner l'esprit de l'ancienne bibliothèque antique. Son architecture audacieuse, en forme de disque incliné plongeant dans un bassin d'eau, symbolise un soleil levant sortant de la mer. Elle abrite des millions de livres, des musées spécialisés et des salles de lecture impressionnantes, faisant d'elle un phare culturel mondial.",
        "mapsQuery": "Bibliotheca Alexandrina Alexandrie"
      },
      {
        "id": "amphitheatre_kom_el_dick",
        "name": "Amphithéâtre Kom-El-Dick",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments historiques",
        "photo_url": "assets/alexendrie/dick.jpg",
        "description": "Découvert par hasard en 1960, ce petit amphithéâtre romain, remarquablement bien conservé, est le seul de son genre en Égypte. Avec ses gradins de marbre et ses colonnes de granit, il témoigne de la grandeur de la vie sociale et culturelle à l'époque gréco-romaine. Le site, niché au cœur de la ville moderne, offre une fenêtre imprenable sur les habitudes de divertissement des anciens habitants de la cité.",
        "mapsQuery": "Kom El Dikka Alexandrie"
      },
      {
        "id": "colonne_pompee",
        "name": "Colonne de Pompée",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments historiques",
        "photo_url": "assets/alexendrie/pompe.jpg",
        "description": "Se dressant fièrement sur une colline, cette colonne monolithique en granit rouge d'Assouan est un exploit d'ingénierie antique. Haute de près de 27 mètres, elle est le seul vestige encore debout du temple majestueux du Sérapéum. Ce monument imposant, qui domine le quartier populaire de Karmouz, reste un symbole puissant de la longévité historique de la ville et de sa riche mixité culturelle passée.",
        "mapsQuery": "Colonne de Pompée Alexandrie"
      },
    ],
    'en': [
      {
        "id": "citadelle_qaitbay",
        "name": "Citadel of Qaitbay",
        "sub_category_key": "catMonuments",
        "sub_category": "Historical Monuments",
        "photo_url": "assets/alexendrie/qai.jpg",
        "description": "Built in the 15th century on the ruins of the legendary Lighthouse of Alexandria—one of the Seven Wonders of the Ancient World—this limestone defensive fortress offers a fascinating dive into Egyptian military history. Its massive ramparts, washed by the Mediterranean waves, reflect Sultan Qaitbay's defensive strategy.",
        "mapsQuery": "Citadel of Qaitbay Alexandria"
      },
      {
        "id": "corniche_pont_stanley",
        "name": "The Corniche and Stanley Bridge",
        "sub_category_key": "catActivities",
        "sub_category": "Must-do Activities",
        "photo_url": "assets/alexendrie/pont.jpg",
        "description": "A vital and poetic artery of Alexandria, the Corniche stretches along the Mediterranean shoreline for several kilometers, offering a unique panorama blending urban modernity and historical nostalgia. Stanley Bridge, with its distinctive towers, is the jewel of this promenade, especially at sunset.",
        "mapsQuery": "Stanley Bridge Alexandria"
      },
      {
        "id": "palais_montaza",
        "name": "Montaza Palace",
        "sub_category_key": "catHistory",
        "sub_category": "Historical Places",
        "photo_url": "assets/alexendrie/palais.jpeg",
        "description": "A true haven of peace, the Montaza Royal Complex spans acres of lush gardens overlooking the sea. The central palace, inspired by a bold blend of Florentine and Ottoman styles, once served as a summer residence for the Egyptian royal family.",
        "mapsQuery": "Montaza Palace Alexandria"
      },
      {
        "id": "bibliotheque_alexandrina",
        "name": "Bibliotheca Alexandrina",
        "sub_category_key": "catCulture",
        "sub_category": "Culture and Knowledge",
        "photo_url": "assets/alexendrie/alexandrina.jpg",
        "description": "More than just a building, the new Library of Alexandria is a monument to universal knowledge, designed to revive the spirit of the ancient library. Its bold architecture, shaped like a tilted sun disk plunging into a water basin, symbolizes a rising sun over the sea.",
        "mapsQuery": "Bibliotheca Alexandrina Alexandria"
      },
      {
        "id": "amphitheatre_kom_el_dick",
        "name": "Kom El-Dikka Amphitheatre",
        "sub_category_key": "catMonuments",
        "sub_category": "Historical Monuments",
        "photo_url": "assets/alexendrie/dick.jpg",
        "description": "Discovered by chance in 1960, this remarkably well-preserved small Roman theatre is the only one of its kind in Egypt. With marble seats and granite columns, it bears witness to social and cultural life during the Greco-Roman era.",
        "mapsQuery": "Kom El Dikka Alexandria"
      },
      {
        "id": "colonne_pompee",
        "name": "Pompey's Pillar",
        "sub_category_key": "catMonuments",
        "sub_category": "Historical Monuments",
        "photo_url": "assets/alexendrie/pompe.jpg",
        "description": "Standing proudly on a hill, this monolithic red Aswan granite column is a marvel of ancient engineering. Reaching nearly 27 meters in height, it is the sole surviving ruin of the majestic Serapeum temple.",
        "mapsQuery": "Pompey's Pillar Alexandria"
      },
    ],
    'ar': [
      {
        "id": "citadelle_qaitbay",
        "name": "قلعة قايتباي",
        "sub_category_key": "catMonuments",
        "sub_category": "معالم تاريخية",
        "photo_url": "assets/alexendrie/qai.jpg",
        "description": "بُنيت هذه القلعة الدفاعية من الحجر الجيري في القرن الخامس عشر على أنقاض منارة الإسكندرية الأسطورية، إحدى عجائب العالم القديم السبع. تقدم القلعة رحلة ساحرة في التاريخ العسكري المصري، وتعتبر أسوارها الضخمة المطلة على البحر الأبيض المتوسط شاهداً على الاستراتيجية الدفاعية للسلطان قايتباي.",
        "mapsQuery": "قلعة قايتباي الإسكندرية"
      },
      {
        "id": "corniche_pont_stanley",
        "name": "الكورنيش وكوبري ستانلي",
        "sub_category_key": "catActivities",
        "sub_category": "أنشطة لا بد منها",
        "photo_url": "assets/alexendrie/pont.jpg",
        "description": "تعد الكورنيش الشريان الحيوي والشاعرية لمدينة الإسكندرية، حيث يمتد لعدة كيلومترات على طول ساحل البحر الأبيض المتوسط، مظهراً مزيجاً فريداً بين الحداثة والعراقة. ويمثل كوبري ستانلي بأبراجه المميزة جوهرة هذه النزهة، خاصة عند غروب الشمس.",
        "mapsQuery": "كوبري ستانلي الإسكندرية"
      },
      {
        "id": "palais_montaza",
        "name": "قصر المنتزه",
        "sub_category_key": "catHistory",
        "sub_category": "أماكن تاريخية",
        "photo_url": "assets/alexendrie/palais.jpeg",
        "description": "واحة حقيقية من الهدوء، يمتد مجمع المنتزه الملكي على مساحات شاسعة من الحدائق الغناء المطلة على البحر. كان القصر المركزي، المستوحى من مزيج فريد من الطرازين الفلورنسي والعثماني، مقراً صيفياً للعائلة الملكية المصرية.",
        "mapsQuery": "قصر المنتزه الإسكندرية"
      },
      {
        "id": "bibliotheque_alexandrina",
        "name": "مكتبة الإسكندرية",
        "sub_category_key": "catCulture",
        "sub_category": "الثقافة والمعرفة",
        "photo_url": "assets/alexendrie/alexandrina.jpg",
        "description": "أكثر من مجرد مبنى، تعد مكتبة الإسكندرية الجديدة صرحاً للمعرفة العالمية كُتب لإعادة إحياء روح المكتبة القديمة. يرمز تصميمها المعماري الجريء على شكل قرص شمس مائل ينغمس في بحيرة مائية إلى شروق الشمس من البحر.",
        "mapsQuery": "مكتبة الإسكندرية"
      },
      {
        "id": "amphitheatre_kom_el_dick",
        "name": "المدرج الروماني بكوم الدكة",
        "sub_category_key": "catMonuments",
        "sub_category": "معالم تاريخية",
        "photo_url": "assets/alexendrie/dick.jpg",
        "description": "اكتُشف بالصدفة عام 1960، ويُعد هذا المدرج الروماني الصغير المحفوظ بشكل رائع الوحيد من نوعه في مصر. بمدرجاته الرخامية وأعمدته الجرانيتية، يشهد على ازدهار الحياة الاجتماعية والثقافية في العصر اليوناني الروماني.",
        "mapsQuery": "كوم الدكة الإسكندرية"
      },
      {
        "id": "colonne_pompee",
        "name": "عمود السواري",
        "sub_category_key": "catMonuments",
        "sub_category": "معالم تاريخية",
        "photo_url": "assets/alexendrie/pompe.jpg",
        "description": "ينتصب هذا العمود المنفرد المصنوع من الجرانيت الأحمر لأسوان على تلة مرتفعة كإنجاز هندسي قديم. يبلغ ارتفاعه نحو 27 متراً، وهو الأثر الوحيد الباقي من معبد السيرابيوم المجيد.",
        "mapsQuery": "عمود السواري الإسكندرية"
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
    final favs = prefs.getStringList('favorite_places_alexandrie') ?? <String>[];
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
    await prefs.setStringList('favorite_places_alexandrie', _favs.toList());
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
      case "catActivities":
        return Icons.attractions_outlined;
      case "catHistory":
        return Icons.history_edu_outlined;
      case "catCulture":
        return Icons.local_library_outlined;
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
    final all = _localizedData[_lang] ?? _localizedData['fr']!;
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
                _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Alexandrie"),
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
        _localizedData[_lang] ?? _localizedData['fr']!;
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 148,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/alexandrie.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                  child: const _PlaceImage('assets/alexendrie/qai.jpg'),
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
  'citadelle_qaitbay': {
    'related': ['corniche_pont_stanley', 'bibliotheque_alexandrina', 'colonne_pompee'],
    'fr': {
      'duration': "1 h à 1 h 30",
      'best': "Fin d'après-midi ou matin",
      'tip': "Montez sur les remparts pour les vues sur la mer et le port, et emportez de l'eau : la brise est fraîche mais le soleil tape.",
      'fact': "Selon les sources antiques, le Phare d'Alexandrie dépassait les 100 mètres de haut. Détruit par des séismes au XIVe siècle, une partie de ses pierres aurait été réemployée pour bâtir la forteresse.",
      'hl': [
        {'t': "Les remparts face à la mer", 'd': "Bâtis à partir de 1477, ils plongent dans les vagues de la Méditerranée."},
        {'t': "Le donjon central", 'd': "Au cœur de la forteresse, une tour et une petite mosquée révèlent l'art défensif de l'époque mamelouke."},
        {'t': "Vue sur le port", 'd': "Depuis les murs, on aperçoit les barques de pêche et la baie du port oriental."},
      ],
    },
    'en': {
      'duration': "1 to 1.5 hours",
      'best': "Late afternoon or morning",
      'tip': "Climb onto the ramparts for views of the sea and the harbour, and bring water: the breeze is fresh but the sun is strong.",
      'fact': "According to ancient sources, the Lighthouse of Alexandria stood over 100 metres tall. Destroyed by earthquakes in the 14th century, part of its stones is said to have been reused to build the fortress.",
      'hl': [
        {'t': "Ramparts facing the sea", 'd': "Built from 1477, they plunge straight into the waves of the Mediterranean."},
        {'t': "The central keep", 'd': "At the heart of the fortress, a tower and a small mosque reveal the defensive art of the Mamluk era."},
        {'t': "A view over the harbour", 'd': "From the walls you can see fishing boats and the bay of the Eastern Harbour."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعة ونصف",
      'best': "وقت العصر أو الصباح",
      'tip': "اصعد إلى الأسوار للاستمتاع بإطلالات البحر والميناء، وخذ معك الماء فالشمس قوية رغم نسيم البحر.",
      'fact': "كان ارتفاع فنار الإسكندرية يتجاوز 100 متر بحسب المصادر القديمة، وقد دمّرته الزلازل في القرن الرابع عشر، ويُقال إن جزءًا من أحجاره أُعيد استخدامه في بناء القلعة.",
      'hl': [
        {'t': "الأسوار المطلة على البحر", 'd': "شُيّدت منذ عام 1477، وتتحطم أمواج المتوسط عند قدميها."},
        {'t': "البرج المركزي", 'd': "في قلب القلعة برج ومسجد صغير يكشفان فن الدفاع في العصر المملوكي."},
        {'t': "إطلالة على الميناء", 'd': "من الأسوار ترى قوارب الصيد وخليج الميناء الشرقي."},
      ],
    },
  },
  'corniche_pont_stanley': {
    'related': ['citadelle_qaitbay', 'palais_montaza', 'bibliotheque_alexandrina'],
    'fr': {
      'duration': "1 h à 2 h",
      'best': "Au coucher du soleil",
      'tip': "Marchez en fin d'après-midi le long du front de mer et terminez par un thé ou un café en terrasse face à la mer.",
      'fact': "Alexandrie a été fondée en 331 av. J.-C. par Alexandre le Grand ; la Corniche longe aujourd'hui toute sa façade maritime.",
      'hl': [
        {'t': "Le pont Stanley au crépuscule", 'd': "Ses tours se découpent sur un ciel doré, puis s'illuminent à la tombée de la nuit."},
        {'t': "Les cafés face à la mer", 'd': "Terrasses et salons de thé bordent le front de mer, parfaits pour regarder la ville vivre."},
        {'t': "À pied ou en calèche", 'd': "La promenade se fait à pied, et des calèches proposent aussi un tour plus lent."},
      ],
    },
    'en': {
      'duration': "1 to 2 hours",
      'best': "At sunset",
      'tip': "Stroll along the seafront in the late afternoon and finish with tea or coffee on a terrace facing the sea.",
      'fact': "Alexandria was founded in 331 BC by Alexander the Great; today the Corniche follows its entire waterfront.",
      'hl': [
        {'t': "Stanley Bridge at dusk", 'd': "Its towers stand out against a golden sky, then light up as night falls."},
        {'t': "Cafés facing the sea", 'd': "Terraces and tea rooms line the seafront, perfect for watching the city go by."},
        {'t': "On foot or by carriage", 'd': "The promenade is made for walking, and horse-drawn carriages also offer a slower tour."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعتين",
      'best': "عند غروب الشمس",
      'tip': "تمشَّ على الواجهة البحرية في وقت العصر، وأنهِ جولتك بشاي أو قهوة في مقهى مطل على البحر.",
      'fact': "تأسست الإسكندرية عام 331 ق.م على يد الإسكندر الأكبر، ويمتد الكورنيش اليوم على طول واجهتها البحرية.",
      'hl': [
        {'t': "كوبري ستانلي عند الغسق", 'd': "تتحدد أبراجه على سماء ذهبية ثم تُضاء مع حلول الليل."},
        {'t': "مقاهٍ على البحر", 'd': "تصطف المقاهي وصالات الشاي على الواجهة البحرية، مثالية لمشاهدة حياة المدينة."},
        {'t': "سيرًا أو بالحنطور", 'd': "التنزه سيرًا على الأقدام ممتع، كما تتيح عربات الخيل جولة أبطأ."},
      ],
    },
  },
  'palais_montaza': {
    'related': ['corniche_pont_stanley', 'bibliotheque_alexandrina', 'citadelle_qaitbay'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "Le matin ou en fin d'après-midi",
      'tip': "Le palais central n'est pas toujours ouvert à la visite : profitez surtout des jardins et du bord de mer.",
      'fact': "Construit à partir de 1892 pour le khédive Abbas II, puis agrandi par le roi Fouad Ier, le complexe de Montaza s'étend sur environ 150 hectares.",
      'hl': [
        {'t': "Le Salamlek", 'd': "L'ancien pavillon de chasse du khédive, aujourd'hui transformé en hôtel, domine la baie."},
        {'t': "Une tour d'inspiration florentine", 'd': "Le palais central est couronné d'une tour qui rappelle l'Italie, au milieu des palmiers."},
        {'t': "Jardins et plage", 'd': "Allées ombragées, palmiers et accès à la mer en font la grande échappée verte d'Alexandrie."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "Morning or late afternoon",
      'tip': "The central palace isn't always open to visitors: make the most of the gardens and the seafront.",
      'fact': "Built from 1892 for Khedive Abbas II, then expanded by King Fuad I, the Montaza complex covers about 150 hectares.",
      'hl': [
        {'t': "The Salamlek", 'd': "The khedive's former hunting lodge, now a hotel, overlooks the bay."},
        {'t': "A Florentine-style tower", 'd': "The central palace is crowned by a tower reminiscent of Italy, set among palm trees."},
        {'t': "Gardens and beach", 'd': "Shaded paths, palms and access to the sea make it Alexandria's great green escape."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في الصباح أو وقت العصر",
      'tip': "القصر المركزي ليس مفتوحًا للزيارة دائمًا، فاستمتع خصوصًا بالحدائق والواجهة البحرية.",
      'fact': "شُيّد مجمع المنتزه منذ عام 1892 للخديوي عباس الثاني، ثم وسّعه الملك فؤاد الأول، ويمتد على نحو 150 هكتارًا.",
      'hl': [
        {'t': "السلاملك", 'd': "كان استراحة صيد للخديوي، وتحوّل اليوم إلى فندق يطل على الخليج."},
        {'t': "برج بطابع فلورنسي", 'd': "يتوّج القصر المركزي برج يذكّر بإيطاليا وسط أشجار النخيل."},
        {'t': "حدائق وشاطئ", 'd': "ممرات ظليلة ونخيل وإطلالة على البحر تجعله المتنفس الأخضر الأكبر في الإسكندرية."},
      ],
    },
  },
  'bibliotheque_alexandrina': {
    'related': ['citadelle_qaitbay', 'amphitheatre_kom_el_dick', 'corniche_pont_stanley'],
    'fr': {
      'duration': "2 à 3 h",
      'best': "En matinée",
      'tip': "Une visite guidée aide à comprendre l'architecture ; gardez du temps pour les musées et le planétarium.",
      'fact': "Inaugurée en 2002, la bibliothèque est entourée d'un mur de granit gravé de caractères issus de plus de 120 écritures du monde.",
      'hl': [
        {'t': "Un disque incliné face à la mer", 'd': "Conçu par le cabinet norvégien Snøhetta, le bâtiment évoque un soleil levant."},
        {'t': "Une salle de lecture immense", 'd': "L'une des plus grandes salles de lecture au monde se déploie sur onze niveaux sous un toit vitré."},
        {'t': "Musées et planétarium", 'd': "Sous le même toit se trouvent plusieurs musées, ainsi qu'un planétarium."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the morning",
      'tip': "A guided tour helps you understand the architecture; leave time for the museums and the planetarium.",
      'fact': "Opened in 2002, the library is wrapped in a granite wall carved with characters from more than 120 scripts from around the world.",
      'hl': [
        {'t': "A tilted disc facing the sea", 'd': "Designed by the Norwegian firm Snøhetta, the building evokes a rising sun."},
        {'t': "An immense reading room", 'd': "One of the largest reading rooms in the world spreads over eleven levels beneath a glass roof."},
        {'t': "Museums and a planetarium", 'd': "Under the same roof you will find several museums, as well as a planetarium."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في الصباح",
      'tip': "تساعدك الجولة المصحوبة بمرشد على فهم العمارة، فاترك وقتًا للمتاحف والقبة السماوية.",
      'fact': "افتُتحت المكتبة عام 2002، ويحيط بها جدار من الجرانيت منقوش بحروف من أكثر من 120 كتابة من مختلف أنحاء العالم.",
      'hl': [
        {'t': "قرص مائل أمام البحر", 'd': "صمّمته شركة سنوهيتا النرويجية، ويوحي المبنى بشمس تشرق."},
        {'t': "قاعة قراءة ضخمة", 'd': "تمتد إحدى أكبر قاعات القراءة في العالم على أحد عشر مستوى تحت سقف زجاجي."},
        {'t': "متاحف وقبة سماوية", 'd': "تحت السقف نفسه عدة متاحف إضافة إلى قبة سماوية."},
      ],
    },
  },
  'amphitheatre_kom_el_dick': {
    'related': ['colonne_pompee', 'bibliotheque_alexandrina', 'citadelle_qaitbay'],
    'fr': {
      'duration': "1 h à 2 h",
      'best': "En matinée, avant la chaleur",
      'tip': "Le site est à ciel ouvert et peu ombragé : prévoyez un chapeau et de l'eau.",
      'fact': "Découvert en 1960 lors de travaux de construction, ce théâtre romain compte treize rangées de gradins en marbre.",
      'hl': [
        {'t': "Les gradins de marbre", 'd': "Les rangées entourent l'orchestre, avec des colonnes de granit sur le pourtour."},
        {'t': "Les thermes romains", 'd': "Le site conserve aussi les vestiges de bains publics de l'époque romaine."},
        {'t': "La villa des Oiseaux", 'd': "Une demeure antique connue pour ses mosaïques colorées représentant des oiseaux."},
      ],
    },
    'en': {
      'duration': "1 to 2 hours",
      'best': "In the morning, before the heat",
      'tip': "The site is open-air with little shade: bring a hat and water.",
      'fact': "Discovered in 1960 during construction work, this Roman theatre has thirteen rows of marble seats.",
      'hl': [
        {'t': "The marble seating", 'd': "The rows surround the orchestra, with granite columns around the edge."},
        {'t': "The Roman baths", 'd': "The site also preserves the remains of public baths from the Roman period."},
        {'t': "The Villa of the Birds", 'd': "An ancient house known for its colourful mosaics depicting birds."},
      ],
    },
    'ar': {
      'duration': "من ساعة إلى ساعتين",
      'best': "في الصباح قبل اشتداد الحرارة",
      'tip': "الموقع مفتوح وقليل الظل، فاصطحب قبعة وماءً.",
      'fact': "اكتُشف عام 1960 أثناء أعمال البناء، ويضم هذا المسرح الروماني ثلاثة عشر صفًا من المقاعد الرخامية.",
      'hl': [
        {'t': "المدرجات الرخامية", 'd': "تحيط الصفوف بمنطقة العرض، وتحفّ بها أعمدة من الجرانيت."},
        {'t': "الحمامات الرومانية", 'd': "يحتفظ الموقع أيضًا ببقايا حمامات عامة من العصر الروماني."},
        {'t': "فيلا الطيور", 'd': "منزل قديم اشتهر بفسيفسائه الملونة التي تصوّر الطيور."},
      ],
    },
  },
  'colonne_pompee': {
    'related': ['amphitheatre_kom_el_dick', 'citadelle_qaitbay', 'bibliotheque_alexandrina'],
    'fr': {
      'duration': "1 h",
      'best': "En matinée",
      'tip': "Combinez-la avec les catacombes de Kom el-Chokafa, toutes proches, pour une demi-journée consacrée à l'Antiquité.",
      'fact': "Malgré son nom, la colonne n'a rien à voir avec Pompée : elle a été élevée vers 297 en l'honneur de l'empereur Dioclétien.",
      'hl': [
        {'t': "Un monolithe en granit d'Assouan", 'd': "Le fût, taillé dans un seul bloc de granit rouge, a été acheminé depuis le sud de l'Égypte."},
        {'t': "Les sphinx", 'd': "Deux sphinx en granit veillent sur le site, souvenirs du temple de Sérapis."},
        {'t': "Les galeries du Sérapéum", 'd': "Des galeries souterraines taillées dans le roc s'ouvrent au pied de la colline."},
      ],
    },
    'en': {
      'duration': "1 hour",
      'best': "In the morning",
      'tip': "Combine it with the nearby Catacombs of Kom el-Shoqafa for a half-day devoted to Antiquity.",
      'fact': "Despite its name, the column has nothing to do with Pompey: it was raised around 297 in honour of Emperor Diocletian.",
      'hl': [
        {'t': "An Aswan granite monolith", 'd': "The shaft, cut from a single block of red granite, was brought from the south of Egypt."},
        {'t': "The sphinxes", 'd': "Two granite sphinxes watch over the site, reminders of the temple of Serapis."},
        {'t': "The Serapeum galleries", 'd': "Underground galleries carved into the rock open at the foot of the hill."},
      ],
    },
    'ar': {
      'duration': "ساعة",
      'best': "في الصباح",
      'tip': "اجمع بين زيارته وسراديب كوم الشقافة القريبة لقضاء نصف يوم مع العصور القديمة.",
      'fact': "رغم اسمه، لا علاقة للعمود ببومبي، فقد أُقيم نحو عام 297 تكريمًا للإمبراطور دقلديانوس.",
      'hl': [
        {'t': "كتلة واحدة من جرانيت أسوان", 'd': "نُحت الجذع من قطعة واحدة من الجرانيت الأحمر ونُقل من جنوب مصر."},
        {'t': "أبو الهول", 'd': "يحرس الموقع تمثالان من الجرانيت، ذكرى لمعبد سرابيس."},
        {'t': "سراديب السيرابيوم", 'd': "تنفتح عند سفح التل ممرات تحت الأرض منحوتة في الصخر."},
      ],
    },
  },
};