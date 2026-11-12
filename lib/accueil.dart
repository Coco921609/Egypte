import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'le caire.dart';
import 'alexandrie.dart';
import 'louxor.dart';
import 'assouan.dart';
import 'siwa.dart';
import 'fayoum.dart';
import 'desert.dart';
import 'sharm.dart';
import 'parametres.dart';
import 'gastronomie_page.dart';
import 'hieroglyphics_page.dart';
import 'package:egypte/Hurghada.dart';

// ==========================================
// HELPER POUR LES MOIS FAVORIS
// ==========================================
class MoisFavorisHelper {
  static List<Map<String, dynamic>> filtrerDestinations(List<Map<String, dynamic>> toutesDestinations) {
    final moisActuel = DateTime.now().month;

    return toutesDestinations.where((dest) {
      if (!dest.containsKey('moisFavoris') || dest['moisFavoris'] == null) {
        return false;
      }
      final rawMois = dest['moisFavoris'] as List<dynamic>? ?? [];
      final List<int> moisFavoris = rawMois.map((e) => e as int).toList();
      return moisFavoris.contains(moisActuel);
    }).toList();
  }
}

// ==========================================
// TRADUCTIONS MULTILINGUES (FR, EN, AR)
// ==========================================
final Map<String, Map<String, String>> localizedAccueilText = {
  'fr': {
    'greeting': 'Bonjour',
    'welcomeEgypt': 'Bienvenue en Égypte',
    'eyebrow': 'Terre des pharaons',
    'settings': 'Paramètres',
    'recommendedMonth': 'Recommandé ce mois-ci',
    'exploreByRegion': 'Explorer par thème',
    'noDestMonth': 'Aucune recommandation pour ce mois.',
    'element': 'élément',
    'elements': 'éléments',
    'all': 'Tout',
    'discover': 'Découvrir',
    'searchHint': 'Rechercher une destination',
    'searchResults': 'Résultats',
    'noResults': 'Aucun résultat pour votre recherche.',
    'footer': 'Conçu avec passion pour les voyageurs.',
    'catHistorical': 'Villes Historiques',
    'catNature': 'Nature & Aventure',
    'catRedSea': 'Mer Rouge',
    'catDishes': 'Gastronomie',
    'catHieroglyphics': 'Hiéroglyphes Égyptiens',
    'cairo': 'Le Caire',
    'alexandria': 'Alexandrie',
    'luxor': 'Louxor',
    'aswan': 'Assouan',
    'siwa': 'Siwa',
    'fayoum': 'Fayoum',
    'desert': 'Désert',
    'sharm': 'Sharm El-Sheikh',
    'hurghada': 'Hurghada',
    'descCairo': 'Capitale vibrante, berceau des pyramides millénaires.',
    'descAlex': 'Perle de la Méditerranée.',
    'descLuxor': 'Le plus grand musée à ciel ouvert.',
    'descAswan': 'Havre de paix au bord du Nil.',
    'descSiwa': 'Oasis mystique isolée.',
    'descFayoum': 'Écosystème unique entre lacs et désert.',
    'descDesert': 'Expédition au cœur du désert blanc et noir.',
    'descSharm': 'Destination balnéaire et récifs coralliens.',
    'descHurghada': 'Station balnéaire dynamique.',
    'dishesTitle': 'Spécialités Culinaires',
    'descDishes': 'Découvrez la richesse et les saveurs de la cuisine égyptienne.',
    'hieroglyphicsTitle': 'Symboles & Écriture',
    'descHieroglyphics': 'Découvrez la langue sacrée et les symboles pharaoniques.',
    'general': 'Général',
  },
  'en': {
    'greeting': 'Hello',
    'welcomeEgypt': 'Welcome to Egypt',
    'eyebrow': 'Land of the pharaohs',
    'settings': 'Settings',
    'recommendedMonth': 'Recommended this month',
    'exploreByRegion': 'Explore by theme',
    'noDestMonth': 'No recommendations for this month.',
    'element': 'item',
    'elements': 'items',
    'all': 'All',
    'discover': 'Discover',
    'searchHint': 'Search for a destination',
    'searchResults': 'Results',
    'noResults': 'No results for your search.',
    'footer': 'Crafted with passion for travellers.',
    'catHistorical': 'Historical Cities',
    'catNature': 'Nature & Adventure',
    'catRedSea': 'Red Sea',
    'catDishes': 'Gastronomy',
    'catHieroglyphics': 'Egyptian Hieroglyphics',
    'cairo': 'Cairo',
    'alexandria': 'Alexandria',
    'luxor': 'Luxor',
    'aswan': 'Aswan',
    'siwa': 'Siwa',
    'fayoum': 'Fayoum',
    'desert': 'Desert',
    'sharm': 'Sharm El-Sheikh',
    'hurghada': 'Hurghada',
    'descCairo': 'Vibrant capital, cradle of millenary pyramids.',
    'descAlex': 'Pearl of the Mediterranean.',
    'descLuxor': 'Largest open-air museum.',
    'descAswan': 'Peaceful haven on the Nile.',
    'descSiwa': 'Isolated mystic oasis.',
    'descFayoum': 'Unique ecosystem between salt lakes and desert.',
    'descDesert': 'White and black desert expedition.',
    'descSharm': 'Coral reefs seaside destination.',
    'descHurghada': 'Dynamic seaside resort.',
    'dishesTitle': 'Culinary Specialties',
    'descDishes': 'Discover the rich flavors of Egyptian cuisine.',
    'hieroglyphicsTitle': 'Symbols & Writing',
    'descHieroglyphics': 'Discover the sacred language and pharaonic symbols.',
    'general': 'General',
  },
  'ar': {
    'greeting': 'مرحباً',
    'welcomeEgypt': 'مرحباً بك في مصر',
    'eyebrow': 'أرض الفراعنة',
    'settings': 'الإعدادات',
    'recommendedMonth': 'موصى به هذا الشهر',
    'exploreByRegion': 'استكشف حسب الموضوع',
    'noDestMonth': 'لا توجد توصيات لهذا الشهر.',
    'element': 'عنصر',
    'elements': 'عناصر',
    'all': 'الكل',
    'discover': 'اكتشف',
    'searchHint': 'ابحث عن وجهة',
    'searchResults': 'النتائج',
    'noResults': 'لا توجد نتائج لبحثك.',
    'footer': 'صُنع بشغف للمسافرين.',
    'catHistorical': 'مدن تاريخية',
    'catNature': 'الطبيعة والمغامرة',
    'catRedSea': 'البحر الأحمر',
    'catDishes': 'المأكولات والتذوق',
    'catHieroglyphics': 'الهيروغليفية المصرية',
    'cairo': 'القاهرة',
    'alexandria': 'الإسكندرية',
    'luxor': 'الأقصر',
    'aswan': 'أسوان',
    'siwa': 'سيوة',
    'fayoum': 'الفيوم',
    'desert': 'الصحراء',
    'sharm': 'شرم الشيخ',
    'hurghada': 'الغردقة',
    'descCairo': 'عاصمة نابضة بالحياة، مهد الأهرامات.',
    'descAlex': 'لؤلؤة البحر الأبيض المتوسط.',
    'descLuxor': 'أكبر متحف مفتوح.',
    'descAswan': 'ملاذ هادئ على النيل.',
    'descSiwa': 'واحة صوفية منعزلة.',
    'descFayoum': 'نظام بيئي فريد.',
    'descDesert': 'رحلة الصحراء البيضاء والسوداء.',
    'descSharm': 'وجهة شعاب مرجانية.',
    'descHurghada': 'منتجع ساحلي حيوي.',
    'dishesTitle': 'الأطباق التقليدية',
    'descDishes': 'اكتشف غنى ونكهات المطبخ المصري.',
    'hieroglyphicsTitle': 'الرموز والكتابة',
    'descHieroglyphics': 'اكتشف اللغة المقدسة والرموز الفرعونية.',
    'general': 'عام',
  },
};

// ==========================================
// FOND AURORA : halos colorés qui dérivent lentement
// ==========================================
class _AuroraPainter extends CustomPainter {
  final double t; // 0 → 1, en boucle
  final List<Color> colors;
  const _AuroraPainter(this.t, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double a = t * 2 * math.pi;

    final centers = <Offset>[
      Offset(w * (0.18 + 0.14 * math.sin(a)), h * (0.12 + 0.07 * math.cos(a))),
      Offset(w * (0.88 + 0.10 * math.cos(a * 0.7)), h * (0.32 + 0.09 * math.sin(a * 0.8))),
      Offset(w * (0.30 + 0.16 * math.sin(a * 0.5 + 1.1)), h * (0.62 + 0.08 * math.cos(a * 1.1))),
      Offset(w * (0.85 + 0.09 * math.sin(a * 1.3)), h * (0.92 + 0.05 * math.cos(a * 0.6))),
    ];
    final radii = <double>[w * 0.85, w * 0.75, w * 0.8, w * 0.7];

    for (var k = 0; k < centers.length; k++) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[k].withOpacity(0.42), colors[k].withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: centers[k], radius: radii[k]));
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.t != t;
}

// ==========================================
// ACCUEILSCREEN ET ACCUEILPAGE (API inchangée)
// ==========================================
class AccueilScreen extends StatelessWidget {
  final String? userName;
  final String? languageCode;
  final String? selectedAvatar;
  final Color? themeColor;

  const AccueilScreen({
    super.key,
    this.userName,
    this.languageCode,
    this.selectedAvatar,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AccueilPage(
      userName: userName,
      languageCode: languageCode,
      selectedAvatar: selectedAvatar,
      themeColor: themeColor,
    );
  }
}

class AccueilPage extends StatefulWidget {
  final String? userName;
  final String? languageCode;
  final String? selectedAvatar;
  final Color? themeColor;

  const AccueilPage({
    super.key,
    this.userName,
    this.languageCode,
    this.selectedAvatar,
    this.themeColor,
  });

  @override
  State<AccueilPage> createState() => _HomeState();
}

class _HomeState extends State<AccueilPage> with SingleTickerProviderStateMixin {
  // Palette
  static const Color _bg = Color(0xFF07080E);
  static const Color _sand = Color(0xFFF6EFE0);
  static const Color _muted = Color(0xFFB9BFCC);

  String _lang = 'fr';
  late Color _accent;
  late String _currentAvatar;

  final ScrollController _scroll = ScrollController();
  final PageController _featuredCtrl = PageController(viewportFraction: 0.86);
  final TextEditingController _searchCtrl = TextEditingController();
  final ValueNotifier<int> _heroIndex = ValueNotifier<int>(0);
  Timer? _heroTimer;
  late final AnimationController _aurora;

  String? _selectedCat; // null = tout
  String _query = '';
  int _featuredIndex = 0;

  @override
  void initState() {
    super.initState();
    _lang = widget.languageCode ?? 'fr';
    _accent = widget.themeColor ?? const Color(0xFFD4AF37);
    _currentAvatar = widget.selectedAvatar ?? '👨🏽';
    _aurora = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _chargerParametres();
    _heroTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) _heroIndex.value++;
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _aurora.dispose();
    _heroIndex.dispose();
    _scroll.dispose();
    _featuredCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _chargerParametres() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLang = prefs.getString('selected_language');
    final int? savedColorValue = prefs.getInt('user_theme_color');
    final String? savedAvatar = prefs.getString('user_avatar');

    if (!mounted) return;
    setState(() {
      if (savedLang != null && localizedAccueilText.containsKey(savedLang)) {
        _lang = savedLang;
      }
      if (widget.themeColor != null) {
        _accent = widget.themeColor!;
      } else if (savedColorValue != null) {
        _accent = Color(savedColorValue);
      }
      if (widget.selectedAvatar != null && widget.selectedAvatar!.trim().isNotEmpty) {
        _currentAvatar = widget.selectedAvatar!;
      } else if (savedAvatar != null && savedAvatar.trim().isNotEmpty) {
        _currentAvatar = savedAvatar;
      }
    });
  }

  Future<void> _changerLangue(String newLang) async {
    if (newLang == _lang) return;
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLang);
    if (!mounted) return;
    setState(() => _lang = newLang);
  }

  String t(String key) {
    return localizedAccueilText[_lang]?[key] ?? localizedAccueilText['fr']![key] ?? key;
  }

  void _gererRetour() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _open(Map<String, dynamic> destination) {
    final page = destination['page'];
    if (page is Widget) {
      HapticFeedback.lightImpact();
      Navigator.push(context, MaterialPageRoute(builder: (context) => page))
          .then((_) => _chargerParametres());
    }
  }

  void _openSettings() {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ParametresPage()))
        .then((_) => _chargerParametres());
  }

  void _clearSearch() {
    HapticFeedback.selectionClick();
    _searchCtrl.clear();
    setState(() => _query = '');
    FocusScope.of(context).unfocus();
  }

  List<Map<String, dynamic>> getDestinations() {
    return [
      {
        'nom': t('cairo'),
        'description': t('descCairo'),
        'image': "assets/images/le caire.jpg",
        'couleur': const Color(0xFFD4AF37),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LeCairePage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3, 4],
      },
      {
        'nom': t('alexandria'),
        'description': t('descAlex'),
        'image': "assets/images/alexandrie.jpg",
        'couleur': const Color(0xFF38BDF8),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AlexandriePage(),
        'moisFavoris': [5, 6, 7, 8, 9, 10],
      },
      {
        'nom': t('luxor'),
        'description': t('descLuxor'),
        'image': "assets/images/louxor.jpg",
        'couleur': const Color(0xFFF59E0B),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LouxorPage(),
        'moisFavoris': [11, 12, 1, 2],
      },
      {
        'nom': t('aswan'),
        'description': t('descAswan'),
        'image': "assets/images/assouan.jpg",
        'couleur': const Color(0xFFEAB308),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AssouanPage(),
        'moisFavoris': [11, 12, 1, 2],
      },
      {
        'nom': t('siwa'),
        'description': t('descSiwa'),
        'image': "assets/images/siwa.jpeg",
        'couleur': const Color(0xFF10B981),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const SiwaPage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3],
      },
      {
        'nom': t('fayoum'),
        'description': t('descFayoum'),
        'image': "assets/images/fayoum.jpeg",
        'couleur': const Color(0xFF34D399),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const FayoumPage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3, 4],
      },
      {
        'nom': t('desert'),
        'description': t('descDesert'),
        'image': "assets/images/R.jpg",
        'couleur': const Color(0xFFF97316),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const DesertPage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3, 4],
      },
      {
        'nom': t('sharm'),
        'description': t('descSharm'),
        'image': "assets/images/sharm.jpg",
        'couleur': const Color(0xFF0EA5E9),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const SharmElSheikhPage(),
        'moisFavoris': [3, 4, 5, 9, 10, 11],
      },
      {
        'nom': t('hurghada'),
        'description': t('descHurghada'),
        'image': "assets/images/j.jpg",
        'couleur': const Color(0xFF06B6D4),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const HurghadaPage(),
        'moisFavoris': [3, 4, 5, 9, 10, 11],
      },
      {
        'nom': t('dishesTitle'),
        'description': t('descDishes'),
        'image': "assets/plat/f.jpg",
        'couleur': const Color(0xFFF59E0B),
        'region': t('catDishes'),
        'categoryKey': 'Gastronomie',
        'page': const GastronomiePage(),
      },
      {
        'nom': t('hieroglyphicsTitle'),
        'description': t('descHieroglyphics'),
        'image': "assets/23.jpeg",
        'couleur': const Color(0xFFDFB15B),
        'region': t('catHieroglyphics'),
        'categoryKey': 'Hiéroglyphes Égyptiens',
        'page': const HieroglyphicsPage(),
      },
    ];
  }

  List<Map<String, dynamic>> _categories() => [
    {'key': 'Villes Historiques', 'label': t('catHistorical'), 'icon': Icons.account_balance_rounded},
    {'key': 'Nature & Aventure', 'label': t('catNature'), 'icon': Icons.landscape_rounded},
    {'key': 'Mer Rouge', 'label': t('catRedSea'), 'icon': Icons.waves_rounded},
    {'key': 'Gastronomie', 'label': t('catDishes'), 'icon': Icons.restaurant_rounded},
    {'key': 'Hiéroglyphes Égyptiens', 'label': t('catHieroglyphics'), 'icon': Icons.auto_awesome_rounded},
  ];

  List<Map<String, dynamic>> _filtrer(List<Map<String, dynamic>> all) {
    final mots = _query.toLowerCase().trim().split(RegExp(r'\s+'));
    return all.where((d) {
      final hay = '${d['nom']} ${d['description']} ${d['region']}'.toLowerCase();
      return mots.every((m) => hay.contains(m));
    }).toList();
  }

  Color _on(Color c) => c.computeLuminance() > 0.45 ? _bg : Colors.white;

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final all = getDestinations();
    final month = MoisFavorisHelper.filtrerDestinations(all);
    final pool = month.isNotEmpty ? month : all;
    final bool isRtl = _lang == 'ar';
    final bool searching = _query.trim().isNotEmpty;
    final results = searching ? _filtrer(all) : <Map<String, dynamic>>[];

    final String greeting = (widget.userName != null && widget.userName!.trim().isNotEmpty)
        ? "${t('greeting')}, ${widget.userName!.trim()}"
        : t('greeting');

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: PopScope(
        canPop: !Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _gererRetour();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: _bg,
            body: Stack(
              children: [
                // Nouveau fond éditorial : nuit du désert, lumière sable et profondeur.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF101B1B),
                            Color(0xFF10151D),
                            Color(0xFF171321),
                            Color(0xFF090D13),
                          ],
                          stops: [0.0, 0.38, 0.72, 1.0],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: const Alignment(-1.15, -0.72),
                            child: Container(
                              width: 330,
                              height: 430,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFFB78A3B).withOpacity(0.24),
                                    Color(0xFFB78A3B).withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(1.1, 0.12),
                            child: Container(
                              width: 360,
                              height: 500,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFF176B68).withOpacity(0.20),
                                    Color(0xFF176B68).withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(-0.9, 1.0),
                            child: Container(
                              width: 330,
                              height: 430,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFF69427B).withOpacity(0.15),
                                    Color(0xFF69427B).withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Contenu : tout défile ensemble, en-tête compris
                CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHero(pool, greeting, isRtl)),
                    if (searching)
                      SliverToBoxAdapter(child: _buildResults(results, isRtl))
                    else ...[
                      SliverToBoxAdapter(child: _buildFeatured(month, isRtl)),
                      SliverToBoxAdapter(child: _buildExplore(all, isRtl)),
                    ],
                    SliverToBoxAdapter(child: _buildFooter()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Hero ─────────────────────────

  Widget _buildHero(List<Map<String, dynamic>> pool, String greeting, bool isRtl) {
    final double topPad = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(22, topPad + 12, 22, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNav(),
          const SizedBox(height: 44),
          _Reveal(
            child: Text(
              t('eyebrow').toUpperCase(),
              style: GoogleFonts.montserrat(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Reveal(
            delay: 90,
            child: Text(
              t('welcomeEgypt'),
              textWidthBasis: TextWidthBasis.parent,
              softWrap: true,
              style: GoogleFonts.playfairDisplay(
                color: _sand,
                fontSize: MediaQuery.of(context).size.width < 380 ? 40 : 46,
                height: 1.08,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Reveal(
            delay: 180,
            child: Text(
              greeting,
              style: GoogleFonts.montserrat(color: _muted, fontSize: 15, height: 1.5),
            ),
          ),
          const SizedBox(height: 34),
          _Reveal(delay: 240, child: _buildPortal(pool, isRtl)),
          const SizedBox(height: 26),
          _Reveal(delay: 320, child: _buildSearchBar()),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_accent, _accent.withOpacity(0.15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF151824)),
                alignment: Alignment.center,
                child: Text(_currentAvatar, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ÉGYPTE',
                softWrap: false,
                style: GoogleFonts.cinzel(color: _sand, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 4),
              ),
            ),
            const SizedBox(width: 12),
            _settingsButton(),
          ],
        ),
        const SizedBox(height: 18),
        _langSwitch(),
      ],
    );
  }

  /// Bouton paramètres : pastille ronde à anneau dégradé, comme l'avatar.
  Widget _settingsButton() {
    return GestureDetector(
      onTap: _openSettings,
      child: Tooltip(
        message: t('settings'),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_accent, _accent.withOpacity(0.12)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF151824),
              boxShadow: [BoxShadow(color: _accent.withOpacity(0.25), blurRadius: 16)],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.tune_rounded, color: _accent, size: 22),
          ),
        ),
      ),
    );
  }

  /// Sélecteur de langue pleine largeur : noms complets, indicateur qui glisse.
  Widget _langSwitch() {
    // Les noms des langues suivent la langue actuellement sélectionnée.
    final List<List<String>> langs = _lang == 'en'
        ? [
      ['fr', 'French'],
      ['en', 'English'],
      ['ar', 'Arabic'],
    ]
        : _lang == 'ar'
        ? [
      ['fr', 'الفرنسية'],
      ['en', 'الإنجليزية'],
      ['ar', 'العربية'],
    ]
        : [
      ['fr', 'Français'],
      ['en', 'Anglais'],
      ['ar', 'Arabe'],
    ];
    int index = langs.indexWhere((l) => l[0] == _lang);
    if (index < 0) index = 0;

    return _glass(
      radius: 30,
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 44,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional(index - 1.0, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: _accent.withOpacity(0.35), blurRadius: 14)],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final l in langs) Expanded(child: _langItem(l[1], l[0])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _langItem(String label, String code) {
    final bool selected = _lang == code;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _changerLangue(code),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: GoogleFonts.montserrat(
            color: selected ? _on(_accent) : _sand.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          child: Text(label, softWrap: false),
        ),
      ),
    );
  }

  /// Portail photo : s'incline en 3D au défilement, légende en verre flottant.
  Widget _buildPortal(List<Map<String, dynamic>> pool, bool isRtl) {
    return ValueListenableBuilder<int>(
      valueListenable: _heroIndex,
      builder: (context, idx, _) {
        final dest = pool[idx % pool.length];
        final Color c = dest['couleur'] as Color;

        return AnimatedBuilder(
          animation: _scroll,
          builder: (context, child) {
            final double off = _scroll.hasClients ? _scroll.offset : 0.0;
            final double tilt = (off * 0.0005).clamp(-0.10, 0.10);
            final Matrix4 m = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(tilt);
            return Transform(alignment: Alignment.topCenter, transform: m, child: child);
          },
          child: SizedBox(
            height: 440,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1400),
                    child: SizedBox.expand(
                      key: ValueKey(dest['image']),
                      child: _photo(dest['image'] as String),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, _bg.withOpacity(0.5), _bg.withOpacity(0.92)],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    left: isRtl ? null : 18,
                    right: isRtl ? 18 : null,
                    child: _glass(
                      radius: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 14, color: _accent),
                          const SizedBox(width: 8),
                          Text(
                            t('recommendedMonth'),
                            style: GoogleFonts.montserrat(color: _sand, fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _glass(
                      radius: 30,
                      padding: const EdgeInsets.fromLTRB(22, 18, 16, 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (dest['region'] as String).toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    color: c,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    dest['nom'] as String,
                                    key: ValueKey(dest['nom']),
                                    style: GoogleFonts.playfairDisplay(
                                      color: _sand,
                                      fontSize: 26,
                                      height: 1.1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _open(dest),
                            child: _arrowButton(c, isRtl, size: 52),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 62,
      child: _glass(
        radius: 31,
        padding: const EdgeInsetsDirectional.fromSTEB(22, 0, 8, 0),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: _accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                cursorColor: _accent,
                style: GoogleFonts.montserrat(color: _sand, fontSize: 15),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: t('searchHint'),
                  hintStyle: GoogleFonts.montserrat(color: _muted, fontSize: 15),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: _clearSearch,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                  child: const Icon(Icons.close_rounded, color: _sand, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Titres de section ─────────────────────────

  Widget _sectionTitle(String index, String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                index,
                style: GoogleFonts.montserrat(color: _accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accent.withOpacity(0.6), Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    trailing,
                    style: GoogleFonts.montserrat(color: _muted, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              color: _sand,
              fontSize: 32,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Carrousel recommandés ─────────────────────────

  Widget _buildFeatured(List<Map<String, dynamic>> month, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            '01',
            t('recommendedMonth'),
            trailing: month.isEmpty ? null : '${month.length}',
          ),
          if (month.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _glass(
                radius: 26,
                padding: const EdgeInsets.all(22),
                child: Text(
                  t('noDestMonth'),
                  style: GoogleFonts.montserrat(color: _muted, fontSize: 14, height: 1.5),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 500,
              child: PageView.builder(
                controller: _featuredCtrl,
                physics: const BouncingScrollPhysics(),
                itemCount: month.length,
                onPageChanged: (idx) => setState(() => _featuredIndex = idx),
                itemBuilder: (context, idx) {
                  return AnimatedBuilder(
                    animation: _featuredCtrl,
                    builder: (context, child) {
                      double page = _featuredIndex.toDouble();
                      if (_featuredCtrl.hasClients && _featuredCtrl.position.haveDimensions) {
                        page = _featuredCtrl.page ?? page;
                      }
                      final double dist = (page - idx).abs().clamp(0.0, 1.0);
                      return Transform.scale(scale: 1 - dist * 0.06, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: _featuredCard(month[idx], isRtl),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Center(child: _dots(month.length, _featuredIndex)),
          ],
        ],
      ),
    );
  }

  Widget _featuredCard(Map<String, dynamic> d, bool isRtl) {
    final Color c = d['couleur'] as Color;
    return _Pressable(
      onTap: () => _open(d),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _photo(d['image'] as String),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _bg.withOpacity(0.5), _bg.withOpacity(0.95)],
                  stops: const [0.2, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _glass(
                radius: 30,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (d['region'] as String).toUpperCase(),
                      style: GoogleFonts.montserrat(
                        color: c,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d['nom'] as String,
                      style: GoogleFonts.playfairDisplay(
                        color: _sand,
                        fontSize: 30,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      d['description'] as String,
                      style: GoogleFonts.montserrat(color: _muted, fontSize: 13, height: 1.55),
                    ),
                    const SizedBox(height: 18),
                    Row(children: [Flexible(child: _pill(t('discover'), isRtl))]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Explorer ─────────────────────────

  Widget _buildExplore(List<Map<String, dynamic>> all, bool isRtl) {
    final cats = _categories();
    final shown = _selectedCat == null ? cats : cats.where((c) => c['key'] == _selectedCat).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('02', t('exploreByRegion')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(null, t('all'), Icons.apps_rounded),
              ...cats.map((c) => _chip(c['key'] as String, c['label'] as String, c['icon'] as IconData)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: Column(
            key: ValueKey(_selectedCat ?? '__all__'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cat in shown) _categoryBlock(cat, all, isRtl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String? key, String label, IconData icon) {
    final bool selected = _selectedCat == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCat = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? _accent : Colors.white.withOpacity(0.12)),
          boxShadow: selected
              ? [BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? _on(_accent) : _muted),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230),
              child: Text(
                label,
                softWrap: true,
                style: GoogleFonts.montserrat(
                  color: selected ? _on(_accent) : _sand.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBlock(Map<String, dynamic> cat, List<Map<String, dynamic>> all, bool isRtl) {
    final items = all.where((d) => d['categoryKey'] == cat['key']).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final int n = items.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_accent.withOpacity(0.28), _accent.withOpacity(0.07)],
                    ),
                    border: Border.all(color: _accent.withOpacity(0.45)),
                  ),
                  child: Icon(cat['icon'] as IconData, color: _accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat['label'] as String,
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.parent,
                        style: GoogleFonts.playfairDisplay(
                          color: _sand,
                          fontSize: 23,
                          height: 1.18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$n ${n > 1 ? t('elements') : t('element')}',
                        style: GoogleFonts.montserrat(
                          color: _muted.withOpacity(0.88),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _tileList(items, isRtl),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Liste en tuiles fluides ─────────────────────────

  /// Alterne une grande tuile verticale et une tuile horizontale : aucune
  /// largeur trop étroite, donc aucun mot coupé.
  Widget _tileList(List<Map<String, dynamic>> items, bool isRtl) {
    return Column(
      children: [
        for (int k = 0; k < items.length; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _tile(items[k], k.isEven, isRtl),
          ),
      ],
    );
  }

  Widget _tile(Map<String, dynamic> d, bool wide, bool isRtl) {
    final Color c = d['couleur'] as Color;
    final double cardHeight = MediaQuery.of(context).size.width < 380 ? 270 : 310;

    return _Pressable(
      onTap: () => _open(d),
      child: SizedBox(
        height: cardHeight,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _photo(d['image'] as String),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.02),
                      Colors.black.withOpacity(0.12),
                      const Color(0xFF080D12).withOpacity(0.94),
                    ],
                    stops: const [0.0, 0.40, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080D12).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.20)),
                        ),
                        child: Text(
                          (d['region'] as String).toUpperCase(),
                          softWrap: true,
                          style: GoogleFonts.montserrat(
                            color: c,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    _glass(
                      radius: 22,
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        isRtl ? Icons.north_west_rounded : Icons.north_east_rounded,
                        color: _sand,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: _tileText(d, c),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileText(Map<String, dynamic> d, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          (d['region'] as String).toUpperCase(),
          style: GoogleFonts.montserrat(
            color: c,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          d['nom'] as String,
          softWrap: true,
          textWidthBasis: TextWidthBasis.parent,
          style: GoogleFonts.playfairDisplay(
            color: _sand,
            fontSize: 29,
            height: 1.12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          d['description'] as String,
          softWrap: true,
          textWidthBasis: TextWidthBasis.parent,
          style: GoogleFonts.montserrat(color: _muted, fontSize: 13, height: 1.55),
        ),
      ],
    );
  }

  // ───────────────────────── Résultats de recherche ─────────────────────────

  Widget _buildResults(List<Map<String, dynamic>> results, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('01', t('searchResults'), trailing: '${results.length}'),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _glass(
                radius: 26,
                padding: const EdgeInsets.all(22),
                child: Text(
                  t('noResults'),
                  style: GoogleFonts.montserrat(color: _muted, fontSize: 14, height: 1.5),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _tileList(results, isRtl),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── Pied de page ─────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, _accent, Colors.transparent]),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ÉGYPTE',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(color: _sand, fontSize: 14, letterSpacing: 5),
          ),
          const SizedBox(height: 10),
          Text(
            t('footer'),
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: _muted,
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Petits composants ─────────────────────────

  Widget _photo(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF151824)),
    );
  }

  Widget _pill(String label, bool isRtl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accent, _accent.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(color: _on(_accent), fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Icon(
            isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            color: _on(_accent),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _dots(int count, int active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (k) {
        final bool on = k == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: on ? _accent : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _arrowButton(Color c, bool isRtl, {double size = 44}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c, c.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(color: c.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(
        isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
        color: _on(c),
        size: size * 0.46,
      ),
    );
  }

  Widget _glass({
    required Widget child,
    double radius = 20,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Effet de pression : l'élément se contracte légèrement au toucher.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Apparition fluide : fondu + glissement vertical.
class _Reveal extends StatelessWidget {
  final Widget child;
  final int delay;
  const _Reveal({required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    final int total = 900 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 26 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}