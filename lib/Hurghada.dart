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

// --- 2. PAGE PRINCIPALE (HURGHADA) ---
class HurghadaPage extends StatefulWidget {
  const HurghadaPage({super.key});

  @override
  State<HurghadaPage> createState() => _HurghadaPageState();
}

class _HurghadaPageState extends State<HurghadaPage>
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
      'pageTitle': "Hurghada",
      'tagline': "La mer Rouge, du désert aux récifs",
      'places': "lieux",
      'all': "Tout",
      'favs': "Favoris",
      'noFav': "Aucun favori pour le moment.\nTouche le ♡ pour en ajouter.",
      'discover': "Découvrir",
      'mapsBtn': "Ouvrir dans Google Maps",
      'about': "À propos",
      'overview': "En bref",
      'duration': "Durée conseillée",
      'bestTime': "Meilleur moment",
      'category': "Catégorie",
      'highlights': "Points forts",
      'didYouKnow': "Le saviez-vous ?",
      'tip': "Conseil du voyageur",
      'seeAlso': "À voir aussi",
      'catActivities': "Activités",
      'catSeaNature': "Mer & Nature",
      'catRelaxNight': "Détente & Vie nocturne",
    },
    'en': {
      'pageTitle': "Hurghada",
      'tagline': "The Red Sea, from desert to reef",
      'places': "places",
      'all': "All",
      'favs': "Favorites",
      'noFav': "No favorites yet.\nTap the ♡ to add some.",
      'discover': "Discover",
      'mapsBtn': "Open in Google Maps",
      'about': "About",
      'overview': "At a glance",
      'duration': "Suggested time",
      'bestTime': "Best time",
      'category': "Category",
      'highlights': "Highlights",
      'didYouKnow': "Did you know?",
      'tip': "Traveller's tip",
      'seeAlso': "Also worth a visit",
      'catActivities': "Activities",
      'catSeaNature': "Sea & Nature",
      'catRelaxNight': "Relaxation & Nightlife",
    },
    'ar': {
      'pageTitle': "الغردقة",
      'tagline': "البحر الأحمر من الصحراء إلى الشعاب",
      'places': "مكان",
      'all': "الكل",
      'favs': "المفضلة",
      'noFav': "لا توجد أماكن مفضلة بعد.\nاضغط على ♡ للإضافة.",
      'discover': "اكتشف",
      'mapsBtn': "الفتح في خرائط Google",
      'about': "نبذة",
      'overview': "لمحة سريعة",
      'duration': "المدة المقترحة",
      'bestTime': "أفضل وقت",
      'category': "الفئة",
      'highlights': "أبرز المعالم",
      'didYouKnow': "هل تعلم؟",
      'tip': "نصيحة للمسافر",
      'seeAlso': "اكتشف أيضًا",
      'catActivities': "أنشطة",
      'catSeaNature': "بحر وطبيعة",
      'catRelaxNight': "استرخاء وحياة ليلية",
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedHurghadaData = {
    'fr': [
      {
        "id": "quad_safari",
        "name": "Safari en Quad dans le désert",
        "sub_category_key": "catActivities",
        "sub_category": "Activités",
        "photo_url": "assets/hurgada/qaud.jpg",
        "description": "Vivez une expérience remplie d'adrénaline en pilotant un quad à travers les grands espaces du désert Oriental. Cette aventure vous emmène au cœur de paysages lunaires et de dunes dorées s'étendant à l'infini, avec une halte dans un camp bédouin authentique pour déguster un thé traditionnel et découvrir un mode de vie ancestral, loin de l'agitation touristique.",
        "mapsQuery": "Quad Safari Hurghada"
      },
      {
        "id": "giftun_island",
        "name": "Plongée à l'île de Giftoun",
        "sub_category_key": "catSeaNature",
        "sub_category": "Mer & Nature",
        "photo_url": "assets/hurgada/ile.jpg",
        "description": "Véritable joyau de la mer Rouge, l'île de Giftoun est une réserve marine aux eaux turquoise cristallines. En plongeant dans ses sites célèbres, vous découvrirez des jardins de corail colorés d'une densité impressionnante et une vie marine abondante, des tortues de mer aux bancs de poissons tropicaux exotiques dans un écosystème d'une beauté préservée.",
        "mapsQuery": "Giftun Island Hurghada"
      },
      {
        "id": "hurghada_marina",
        "name": "La Marina de Hurghada",
        "sub_category_key": "catRelaxNight",
        "sub_category": "Détente & Vie nocturne",
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
        "sub_category": "Activities",
        "photo_url": "assets/hurgada/qaud.jpg",
        "description": "Experience an adrenaline-fueled adventure riding quad bikes through the vast wilderness of the Eastern Desert. Journey into the heart of moonlike landscapes and endless golden dunes, stopping at an authentic Bedouin camp to enjoy traditional tea and learn about an ancient way of life away from the crowds.",
        "mapsQuery": "Quad Safari Hurghada"
      },
      {
        "id": "giftun_island",
        "name": "Giftun Island Diving",
        "sub_category_key": "catSeaNature",
        "sub_category": "Sea & Nature",
        "photo_url": "assets/hurgada/ile.jpg",
        "description": "A true jewel of the Red Sea, Giftun Island is a marine reserve with crystal-clear turquoise waters. Diving at its famous spots reveals vibrant coral gardens of breathtaking density and abundant marine life, from sea turtles to schools of exotic tropical fish in a pristine ecosystem.",
        "mapsQuery": "Giftun Island Hurghada"
      },
      {
        "id": "hurghada_marina",
        "name": "Hurghada Marina",
        "sub_category_key": "catRelaxNight",
        "sub_category": "Relaxation & Nightlife",
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
        "sub_category": "أنشطة",
        "photo_url": "assets/hurgada/qaud.jpg",
        "description": "عش تجربة مليئة بالأدرينالين أثناء قيادة الدراجات الرباعية عبر البراري في الصحراء الشرقية. تأخذك هذه المغامرة إلى قلب المناظر الطبيعية التي تشبه سطح القمر والكثبان الذهبية الممتدة إلى ما لا نهاية، مع التوقف في مخيم بدوي أصيل للاستمتاع بشاي تقليدي واكتشاف أسلوب حياة عريق، بعيداً عن صخب السياحة.",
        "mapsQuery": "Quad Safari Hurghada"
      },
      {
        "id": "giftun_island",
        "name": "الغوص في جزيرة جفتون",
        "sub_category_key": "catSeaNature",
        "sub_category": "بحر وطبيعة",
        "photo_url": "assets/hurgada/ile.jpg",
        "description": "جوهرة حقيقية في البحر الأحمر، جزيرة جفتون هي محمية بحرية ذات مياه فيروزية صافية. عند الغوص في مواقعها الشهيرة، ستكتشف حدائق مرجانية ملونة ذات كثافة مذهلة، وحياة بحرية وفيرة، من السلاحف البحرية إلى أسراب الأسماك الاستوائية الغريبة في نظام بيئي ذي جمال أصيل.",
        "mapsQuery": "Giftun Island Hurghada"
      },
      {
        "id": "hurghada_marina",
        "name": "مارينا الغردقة",
        "sub_category_key": "catRelaxNight",
        "sub_category": "استرخاء وحياة ليلية",
        "photo_url": "assets/hurgada/marina.webp",
        "description": "رمز التجديد الحديث للغردقة، المارينا مكان لا بد من زيارته لمحبي الفخامة والرفاهية. بين اليخوت الفاخرة الراسية في الميناء والشرفات الأنيقة المطلة على الرصيف، هو المكان المثالي للتنزه في نهاية اليوم، والاستمتاع بنسيم البحر، وتناول العشاء في مطاعم راقية أو تمديد السهرة في أجواء أنيقة وحيوية.",
        "mapsQuery": "Hurghada Marina"
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
      case "catActivities":
        return Icons.attractions_outlined;
      case "catSeaNature":
        return Icons.waves_outlined;
      case "catRelaxNight":
        return Icons.nightlife_outlined;
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
    final all = _localizedHurghadaData[_lang] ?? _localizedHurghadaData['fr']!;
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
                _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Hurghada"),
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
        _localizedHurghadaData[_lang] ?? _localizedHurghadaData['fr']!;
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
                  child: const _PlaceImage('assets/hurgada/ile.jpg'),
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
  'quad_safari': {
    'related': ['giftun_island', 'hurghada_marina'],
    'fr': {
      'duration': "3 h à 4 h",
      'best': "En fin d'après-midi, pour le coucher du soleil",
      'tip': "Portez des vêtements couvrants, des lunettes et un foulard contre la poussière, ainsi que des chaussures fermées. Suivez toujours les consignes de votre guide.",
      'fact': "Hurghada n'était qu'un petit village de pêcheurs au début du XXe siècle ; le désert Oriental, qui s'étend derrière la ville, a longtemps été le domaine des Bédouins.",
      'hl': [
        {'t': "Des dunes à perte de vue", 'd': "Le quad permet de traverser pistes et dunes dorées, au rythme de la poussière et du vent."},
        {'t': "Un camp bédouin", 'd': "Une halte autour d'un thé traditionnel permet de découvrir un mode de vie ancestral."},
        {'t': "Un coucher de soleil dans le désert", 'd': "Le ciel s'embrase sur l'horizon, un moment fort de l'excursion."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours",
      'best': "Late afternoon, for sunset",
      'tip': "Wear covering clothes, goggles and a scarf against the dust, and closed shoes. Always follow your guide's instructions.",
      'fact': "Hurghada was just a small fishing village in the early 20th century; the Eastern Desert behind the town was long the domain of the Bedouin.",
      'hl': [
        {'t': "Dunes as far as the eye can see", 'd': "The quad lets you cross tracks and golden dunes, in a rush of dust and wind."},
        {'t': "A Bedouin camp", 'd': "A stop over traditional tea lets you discover an ancestral way of life."},
        {'t': "A desert sunset", 'd': "The sky ignites on the horizon, a highlight of the excursion."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات",
      'best': "في أواخر العصر لمشاهدة الغروب",
      'tip': "ارتدِ ملابس تغطي الجسم ونظارات ووشاحًا للغبار وحذاءً مغلقًا، واتبع دائمًا تعليمات المرشد.",
      'fact': "كانت الغردقة مجرد قرية صيد صغيرة في مطلع القرن العشرين، وظلت الصحراء الشرقية خلفها زمنًا طويلًا موطنًا للبدو.",
      'hl': [
        {'t': "كثبان على مد البصر", 'd': "تتيح الدراجة الرباعية عبور المسارات والكثبان الذهبية وسط الغبار والريح."},
        {'t': "مخيم بدوي", 'd': "تتيح وقفة حول شاي تقليدي اكتشاف أسلوب حياة عريق."},
        {'t': "غروب في الصحراء", 'd': "تشتعل السماء عند الأفق، وهي لحظة بارزة في الرحلة."},
      ],
    },
  },
  'giftun_island': {
    'related': ['hurghada_marina', 'quad_safari'],
    'fr': {
      'duration': "Une journée (6 à 8 h)",
      'best': "Le matin, quand la mer est calme",
      'tip': "L'archipel est une zone protégée : suivez les consignes de la réserve, ne touchez pas le corail et utilisez une crème solaire respectueuse des récifs.",
      'fact': "Giftoun est un petit archipel d'îles désertes face à Hurghada, accessible uniquement en bateau et protégé pour la richesse de ses récifs.",
      'hl': [
        {'t': "Des jardins de corail", 'd': "Coraux colorés et récifs d'une grande densité se découvrent dès les premiers mètres."},
        {'t': "Tortues et poissons tropicaux", 'd': "Tortues de mer et bancs de poissons colorés peuplent les eaux claires."},
        {'t': "Des eaux turquoise", 'd': "Un lagon cristallin idéal pour le snorkeling comme pour la plongée."},
      ],
    },
    'en': {
      'duration': "A day (6 to 8 hours)",
      'best': "In the morning, when the sea is calm",
      'tip': "The archipelago is a protected area: follow the reserve's rules, don't touch the coral and use reef-safe sunscreen.",
      'fact': "Giftun is a small archipelago of uninhabited islands off Hurghada, reachable only by boat and protected for the richness of its reefs.",
      'hl': [
        {'t': "Coral gardens", 'd': "Coloured corals and very dense reefs can be seen from the first few metres."},
        {'t': "Turtles and tropical fish", 'd': "Sea turtles and schools of colourful fish fill the clear waters."},
        {'t': "Turquoise waters", 'd': "A crystalline lagoon, ideal for snorkelling as well as diving."},
      ],
    },
    'ar': {
      'duration': "يوم كامل (من 6 إلى 8 ساعات)",
      'best': "في الصباح حين يكون البحر هادئًا",
      'tip': "الأرخبيل منطقة محمية، فاتبع قواعد المحمية ولا تلمس المرجان واستخدم واقيًا من الشمس صديقًا للشعاب.",
      'fact': "جفتون أرخبيل صغير من الجزر غير المأهولة قبالة الغردقة، لا يُوصل إليه إلا بالقارب، وهو محمي لغنى شعابه.",
      'hl': [
        {'t': "حدائق مرجانية", 'd': "تظهر المرجانيات الملونة والشعاب الكثيفة منذ الأمتار الأولى."},
        {'t': "سلاحف وأسماك استوائية", 'd': "تسكن السلاحف البحرية وأسراب الأسماك الملونة المياه الصافية."},
        {'t': "مياه فيروزية", 'd': "بحيرة صافية مثالية للغطس السطحي وللغوص."},
      ],
    },
  },
  'hurghada_marina': {
    'related': ['giftun_island', 'quad_safari'],
    'fr': {
      'duration': "2 h à 3 h",
      'best': "En soirée, quand la brise se lève",
      'tip': "Réservez votre table à l'avance en haute saison et gardez du temps pour une balade à pied le long du quai.",
      'fact': "Hurghada s'étire sur des dizaines de kilomètres le long de la côte, et la Marina en est l'un des pôles les plus animés.",
      'hl': [
        {'t': "Yachts et voiliers", 'd': "Des bateaux de toutes tailles s'alignent le long des pontons du port."},
        {'t': "Terrasses et restaurants", 'd': "Cuisines du monde et vue sur l'eau pour un dîner en bord de quai."},
        {'t': "Une ambiance animée", 'd': "Cafés et lieux de sortie prolongent la soirée dans une atmosphère chic."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the evening, when the breeze picks up",
      'tip': "Book your table in advance in high season and keep time for a walk along the quay.",
      'fact': "Hurghada stretches for dozens of kilometres along the coast, and the Marina is one of its liveliest hubs.",
      'hl': [
        {'t': "Yachts and sailboats", 'd': "Boats of all sizes line the harbour's pontoons."},
        {'t': "Terraces and restaurants", 'd': "World cuisines and a view over the water for a dinner on the quayside."},
        {'t': "A lively atmosphere", 'd': "Cafés and venues extend the evening in a chic atmosphere."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في المساء حين يهبّ النسيم",
      'tip': "احجز طاولتك مسبقًا في موسم الذروة وخصص وقتًا للتنزه سيرًا على الرصيف.",
      'fact': "تمتد الغردقة عشرات الكيلومترات على طول الساحل، والمارينا من أكثر مراكزها حيوية.",
      'hl': [
        {'t': "يخوت ومراكب شراعية", 'd': "تصطف قوارب بأحجام مختلفة على أرصفة الميناء."},
        {'t': "شرفات ومطاعم", 'd': "مطابخ عالمية وإطلالة على الماء لعشاء على الرصيف."},
        {'t': "أجواء نابضة", 'd': "تمد المقاهي وأماكن السهر الأمسية في أجواء أنيقة."},
      ],
    },
  },
};