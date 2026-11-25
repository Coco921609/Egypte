import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, PointMode;

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
// ACCUEIL — « Le pylône » · édition maison
//
// Barre supérieure toujours visible (translucide au repos, floutée au défilement),
// hero plein écran en fondu enchaîné, sections numérotées,
// apparitions au défilement en cascade, filets d'or.
// Typographie : Marcellus + Jost (Reem Kufi + Cairo en arabe).
// ==========================================

// ==========================================
// HELPER POUR LES MOIS FAVORIS
// ==========================================
class MoisFavorisHelper {
  static List<Map<String, dynamic>> filtrerDestinations(List<Map<String, dynamic>> toutesDestinations) {
    final int moisActuel = DateTime.now().month;
    return toutesDestinations.where((Map<String, dynamic> dest) {
      if (dest['moisFavoris'] == null) return false;
      final List<int> mois = (dest['moisFavoris'] as List<dynamic>).whereType<int>().toList();
      return mois.contains(moisActuel);
    }).toList();
  }
}

// ==========================================
// TRADUCTIONS MULTILINGUES (FR, EN, AR)
// ==========================================
final Map<String, Map<String, String>> localizedAccueilText = <String, Map<String, String>>{
  'fr': <String, String>{
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
    'bestSeason': 'Meilleure saison',
    'backToTop': 'Retour en haut',
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
    'navHome': 'Accueil',
    'navMonth': 'Ce mois-ci',
    'navExplore': 'Explorer',
  },
  'en': <String, String>{
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
    'bestSeason': 'Best season',
    'backToTop': 'Back to top',
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
    'navHome': 'Home',
    'navMonth': 'This month',
    'navExplore': 'Explore',
  },
  'ar': <String, String>{
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
    'bestSeason': 'أفضل موسم',
    'backToTop': 'العودة إلى الأعلى',
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
    'navHome': 'الرئيسية',
    'navMonth': 'هذا الشهر',
    'navExplore': 'استكشف',
  },
};

/// Noms des mois.
const Map<String, List<String>> _accueilMonths = <String, List<String>>{
  'fr': ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
  'en': ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  'ar': ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'],
};

const List<String> _romans = <String>['I', 'II', 'III', 'IV', 'V', 'VI'];

// ==========================================
// FOND : plafond de temple — nuit lapis, étoiles d'or, grain fin.
// Peint une seule fois.
// ==========================================
class _SkyPainter extends CustomPainter {
  final Color accent;
  const _SkyPainter(this.accent);

  static final List<List<double>> _stars = List<List<double>>.generate(46, (int i) {
    final math.Random r = math.Random(i * 31 + 7);
    return <double>[
      r.nextDouble(),
      r.nextDouble(),
      0.5 + r.nextDouble() * 0.9,
      0.16 + r.nextDouble() * 0.40,
    ];
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final List<Offset> centers = <Offset>[
      Offset(w * 0.92, h * 0.06),
      Offset(w * 0.02, h * 0.38),
      Offset(w * 0.98, h * 0.72),
      Offset(w * 0.08, h * 1.0),
    ];
    final List<double> radii = <double>[w * 0.95, w * 1.05, w * 0.85, w * 0.8];
    final List<Color> colors = <Color>[
      accent.withOpacity(0.10),
      const Color(0xFF1E4FA3).withOpacity(0.22),
      const Color(0xFF176B68).withOpacity(0.14),
      const Color(0xFF3B2A6B).withOpacity(0.14),
    ];
    for (int k = 0; k < centers.length; k++) {
      final Paint p = Paint()
        ..shader = RadialGradient(
          colors: <Color>[colors[k], colors[k].withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: centers[k], radius: radii[k]));
      canvas.drawRect(Offset.zero & size, p);
    }

    final Paint star = Paint();
    for (final List<double> s in _stars) {
      star.color = const Color(0xFFF2E9D6).withOpacity(s[3]);
      canvas.drawCircle(Offset(s[0] * w, s[1] * h), s[2], star);
    }

    final math.Random r = math.Random(11);
    final int n = (w * h / 520).clamp(500.0, 3000.0).toInt();
    final List<Offset> pts = List<Offset>.generate(
      n,
          (int _) => Offset(r.nextDouble() * w, r.nextDouble() * h),
    );
    canvas.drawPoints(
      PointMode.points,
      pts,
      Paint()
        ..color = Colors.white.withOpacity(0.04)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.accent != accent;
}

/// Pyramides en filet d'or : signature du pied de page.
class _PyramidsPainter extends CustomPainter {
  final Color color;
  const _PyramidsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double base = h - 2;

    final Paint line = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeJoin = StrokeJoin.round;
    final Paint soft = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeJoin = StrokeJoin.round;

    final Path big = Path()
      ..moveTo(w * 0.25, base)
      ..lineTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.75, base);
    canvas.drawPath(big, line);
    canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, base), soft);

    final Path left = Path()
      ..moveTo(w * 0.03, base)
      ..lineTo(w * 0.16, h * 0.56)
      ..lineTo(w * 0.29, base);
    canvas.drawPath(left, soft);

    final Path right = Path()
      ..moveTo(w * 0.71, base)
      ..lineTo(w * 0.85, h * 0.5)
      ..lineTo(w * 0.97, base);
    canvas.drawPath(right, soft);

    final Paint ground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..shader = LinearGradient(
        colors: <Color>[Colors.transparent, color.withOpacity(0.7), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawLine(Offset(0, base), Offset(w, base), ground);

    canvas.drawCircle(Offset(w * 0.8, h * 0.16), 4.5, soft);
  }

  @override
  bool shouldRepaint(covariant _PyramidsPainter old) => old.color != color;
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

class _HomeState extends State<AccueilPage> with TickerProviderStateMixin {
  // Palette éditoriale premium : encre profonde, ivoire et or champagne.
  static const Color _bg = Color(0xFF080C13);
  static const Color _ivory = Color(0xFFF7F2E8);
  static const Color _muted = Color(0xFFA6ADBA);
  static const Color _surface = Color(0xFF111925);

  String _lang = 'fr';
  late Color _accent;
  late String _currentAvatar;

  final ScrollController _scroll = ScrollController();
  final PageController _featuredCtrl = PageController(viewportFraction: 0.86);
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<int> _heroIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> _featuredIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> _active = ValueNotifier<int>(0); // 0 accueil, 1 mois, 2 explorer
  final ValueNotifier<double> _headerT = ValueNotifier<double>(0); // 0 transparent → 1 verre dépoli
  final GlobalKey _kSearch = GlobalKey();
  final GlobalKey _kMonth = GlobalKey();
  final GlobalKey _kExplore = GlobalKey();
  late final AnimationController _intro;
  late final AnimationController _heroProgress;
  bool _started = false;

  String? _selectedCat;
  String _query = '';

  bool get _ar => _lang == 'ar';

  @override
  void initState() {
    super.initState();
    _lang = widget.languageCode ?? 'fr';
    _accent = widget.themeColor ?? const Color(0xFFC9A449);
    _currentAvatar = widget.selectedAvatar ?? '👨🏽';

    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _heroProgress = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    _heroProgress.addStatusListener((AnimationStatus s) {
      if (s == AnimationStatus.completed && mounted) {
        _heroIndex.value++;
        _heroProgress.forward(from: 0);
      }
    });
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
    _scroll.addListener(_onScroll);
    _chargerParametres();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      if (MediaQuery.of(context).disableAnimations) {
        _intro.value = 1;
      } else {
        _intro.forward();
        _heroProgress.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _heroProgress.dispose();
    _heroIndex.dispose();
    _featuredIndex.dispose();
    _active.dispose();
    _headerT.dispose();
    _scroll.dispose();
    _featuredCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _chargerParametres() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLang);
    if (!mounted) return;
    setState(() => _lang = newLang);
  }

  String t(String key) {
    return localizedAccueilText[_lang]?[key] ?? localizedAccueilText['fr']![key] ?? key;
  }

  void _gererRetour() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _open(Map<String, dynamic> destination) {
    final Object? page = destination['page'];
    if (page is Widget) {
      HapticFeedback.lightImpact();
      Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => page))
          .then((_) => _chargerParametres());
    }
  }

  void _openSettings() {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => const ParametresPage()))
        .then((_) => _chargerParametres());
  }

  void _onQuery(String v) {
    if (v.trim().isNotEmpty && _featuredIndex.value != 0) _featuredIndex.value = 0;
    setState(() => _query = v);
  }

  void _clearSearch() {
    HapticFeedback.selectionClick();
    _searchCtrl.clear();
    setState(() => _query = '');
    FocusScope.of(context).unfocus();
  }

  void _stepHero(int d) {
    HapticFeedback.selectionClick();
    _heroIndex.value += d;
    _heroProgress.forward(from: 0);
  }

  void _goHero(int k) {
    HapticFeedback.selectionClick();
    _heroIndex.value = k;
    _heroProgress.forward(from: 0);
  }

  void _stepFeatured(int d, int count) {
    if (!_featuredCtrl.hasClients) return;
    final int target = (_featuredIndex.value + d).clamp(0, count - 1).toInt();
    HapticFeedback.selectionClick();
    _featuredCtrl.animateToPage(
      target,
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
    );
  }

  /// Hauteur de la barre fixe (zone du statut + deux rangées).
  double _navHeight(MediaQueryData mq) => mq.padding.top + 52 + 40;

  Future<void> _scrollToKey(GlobalKey key, {double gap = 18}) async {
    if (!_scroll.hasClients) return;
    final BuildContext? ctx = key.currentContext;
    if (ctx == null) return;
    final RenderObject? ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached) return;
    final double dy = ro.localToGlobal(Offset.zero).dy;
    final double navH = _navHeight(MediaQuery.of(context));
    final double target = (_scroll.offset + dy - navH - gap)
        .clamp(0.0, _scroll.position.maxScrollExtent)
        .toDouble();
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _goSection(int i) async {
    HapticFeedback.selectionClick();
    if (i == 0) {
      _toTop();
    } else {
      await _scrollToKey(i == 1 ? _kMonth : _kExplore);
    }
  }

  Future<void> _goSearch() async {
    HapticFeedback.selectionClick();
    await _scrollToKey(_kSearch, gap: 28);
    if (mounted) _searchFocus.requestFocus();
  }

  void _toTop() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutCubic);
  }

  /// Met à jour l'effet de verre et le lien actif de la barre fixe.
  /// La barre n'est jamais masquée : seule son apparence change.
  void _onScroll() {
    if (!mounted || !_scroll.hasClients) return;
    final double off = _scroll.offset;
    _headerT.value = ((off - 12) / 140).clamp(0.0, 1.0).toDouble();

    final double limit = _navHeight(MediaQuery.of(context)) + 200;
    int a = 0;
    final List<GlobalKey> keys = <GlobalKey>[_kMonth, _kExplore];
    for (int i = 0; i < keys.length; i++) {
      final BuildContext? ctx = keys[i].currentContext;
      if (ctx == null) continue;
      final RenderObject? ro = ctx.findRenderObject();
      if (ro is! RenderBox || !ro.attached || !ro.hasSize) continue;
      if (ro.localToGlobal(Offset.zero).dy <= limit) a = i + 1;
    }
    if (_active.value != a) _active.value = a;
  }

  List<Map<String, dynamic>> getDestinations() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'nom': t('cairo'),
        'description': t('descCairo'),
        'image': 'assets/images/le caire.jpg',
        'couleur': const Color(0xFFD4AF37),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LeCairePage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3, 4],
      },
      <String, dynamic>{
        'nom': t('alexandria'),
        'description': t('descAlex'),
        'image': 'assets/images/alexandrie.jpg',
        'couleur': const Color(0xFF38BDF8),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AlexandriePage(),
        'moisFavoris': <int>[5, 6, 7, 8, 9, 10],
      },
      <String, dynamic>{
        'nom': t('luxor'),
        'description': t('descLuxor'),
        'image': 'assets/images/louxor.jpg',
        'couleur': const Color(0xFFF59E0B),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LouxorPage(),
        'moisFavoris': <int>[11, 12, 1, 2],
      },
      <String, dynamic>{
        'nom': t('aswan'),
        'description': t('descAswan'),
        'image': 'assets/images/assouan.jpg',
        'couleur': const Color(0xFFEAB308),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AssouanPage(),
        'moisFavoris': <int>[11, 12, 1, 2],
      },
      <String, dynamic>{
        'nom': t('siwa'),
        'description': t('descSiwa'),
        'image': 'assets/images/siwa.jpeg',
        'couleur': const Color(0xFF10B981),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const SiwaPage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3],
      },
      <String, dynamic>{
        'nom': t('fayoum'),
        'description': t('descFayoum'),
        'image': 'assets/images/fayoum.jpeg',
        'couleur': const Color(0xFF34D399),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const FayoumPage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3, 4],
      },
      <String, dynamic>{
        'nom': t('desert'),
        'description': t('descDesert'),
        'image': 'assets/images/R.jpg',
        'couleur': const Color(0xFFF97316),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const DesertPage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3, 4],
      },
      <String, dynamic>{
        'nom': t('sharm'),
        'description': t('descSharm'),
        'image': 'assets/images/sharm.jpg',
        'couleur': const Color(0xFF0EA5E9),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const SharmElSheikhPage(),
        'moisFavoris': <int>[3, 4, 5, 9, 10, 11],
      },
      <String, dynamic>{
        'nom': t('hurghada'),
        'description': t('descHurghada'),
        'image': 'assets/images/j.jpg',
        'couleur': const Color(0xFF06B6D4),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const HurghadaPage(),
        'moisFavoris': <int>[3, 4, 5, 9, 10, 11],
      },
      <String, dynamic>{
        'nom': t('dishesTitle'),
        'description': t('descDishes'),
        'image': 'assets/plat/f.jpg',
        'couleur': const Color(0xFFF59E0B),
        'region': t('catDishes'),
        'categoryKey': 'Gastronomie',
        'page': const GastronomiePage(),
      },
      <String, dynamic>{
        'nom': t('hieroglyphicsTitle'),
        'description': t('descHieroglyphics'),
        'image': 'assets/23.jpeg',
        'couleur': const Color(0xFFDFB15B),
        'region': t('catHieroglyphics'),
        'categoryKey': 'Hiéroglyphes Égyptiens',
        'page': const HieroglyphicsPage(),
      },
    ];
  }

  List<Map<String, dynamic>> _categories() => <Map<String, dynamic>>[
    <String, dynamic>{'key': 'Villes Historiques', 'label': t('catHistorical'), 'icon': Icons.account_balance_rounded},
    <String, dynamic>{'key': 'Nature & Aventure', 'label': t('catNature'), 'icon': Icons.landscape_rounded},
    <String, dynamic>{'key': 'Mer Rouge', 'label': t('catRedSea'), 'icon': Icons.waves_rounded},
    <String, dynamic>{'key': 'Gastronomie', 'label': t('catDishes'), 'icon': Icons.restaurant_rounded},
    <String, dynamic>{'key': 'Hiéroglyphes Égyptiens', 'label': t('catHieroglyphics'), 'icon': Icons.auto_awesome_rounded},
  ];

  List<Map<String, dynamic>> _filtrer(List<Map<String, dynamic>> all) {
    final List<String> mots = _query.toLowerCase().trim().split(RegExp(r'\s+'));
    return all.where((Map<String, dynamic> d) {
      final String hay = '${d['nom']} ${d['description']} ${d['region']}'.toLowerCase();
      return mots.every((String m) => hay.contains(m));
    }).toList();
  }

  List<int> _favMonths(Map<String, dynamic> d) {
    final Object? raw = d['moisFavoris'];
    if (raw is List) return raw.whereType<int>().toList();
    return const <int>[];
  }

  Color _on(Color c) => c.computeLuminance() > 0.45 ? _bg : Colors.white;

  String _num(int i) => (i + 1).toString().padLeft(2, '0');

  double _heroHeight(MediaQueryData mq) => mq.size.height.clamp(660.0, 940.0).toDouble();

  // ───────────────────────── Typographie ─────────────────────────

  TextStyle _display(double size, {Color? color, double height = 1.15, double spacing = 0}) {
    if (_ar) {
      return GoogleFonts.reemKufi(
        color: color ?? _ivory,
        fontSize: size * 0.94,
        fontWeight: FontWeight.w600,
        height: height + 0.25,
      );
    }
    return GoogleFonts.marcellus(
      color: color ?? _ivory,
      fontSize: size,
      height: height,
      letterSpacing: spacing,
    );
  }

  TextStyle _text(
      double size, {
        Color? color,
        FontWeight weight = FontWeight.w400,
        double height = 1.5,
        double spacing = 0,
        FontStyle? style,
      }) {
    if (_ar) {
      return GoogleFonts.cairo(
        color: color ?? _ivory,
        fontSize: size * 1.06,
        fontWeight: weight,
        height: height,
      );
    }
    return GoogleFonts.jost(
      color: color ?? _ivory,
      fontSize: size * 1.04,
      fontWeight: weight,
      fontStyle: style,
      height: height,
      letterSpacing: spacing,
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> all = getDestinations();
    final List<Map<String, dynamic>> month = MoisFavorisHelper.filtrerDestinations(all);
    final List<Map<String, dynamic>> pool = month.isNotEmpty ? month : all;
    final bool isRtl = _lang == 'ar';
    final bool searching = _query.trim().isNotEmpty;
    final List<Map<String, dynamic>> results = searching ? _filtrer(all) : <Map<String, dynamic>>[];

    final String greeting = (widget.userName != null && widget.userName!.trim().isNotEmpty)
        ? '${t('greeting')}, ${widget.userName!.trim()}'
        : t('greeting');

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: PopScope(
        canPop: !Navigator.canPop(context),
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) _gererRetour();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: _bg,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: _bg,
            body: Stack(
              children: <Widget>[
                _buildBackground(),
                CustomScrollView(
                  controller: _scroll,
                  primary: false,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: <Widget>[
                    SliverToBoxAdapter(child: _buildHero(pool, greeting, isRtl)),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildSearchSection(),
                          if (searching)
                            _buildResults(results, isRtl)
                          else ...<Widget>[
                            _buildFeatured(month, isRtl),
                            _buildExplore(all, isRtl),
                          ],
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildHeader(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF101B2B),
                    Color(0xFF0A111D),
                    Color(0xFF080C13),
                  ],
                  stops: <double>[0.0, 0.46, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -180,
              right: -130,
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      _accent.withOpacity(0.13),
                      _accent.withOpacity(0.035),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 180,
              left: -220,
              child: Container(
                width: 480,
                height: 480,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      Color(0x241B6270),
                      Color(0x101B6270),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Séquence d'ouverture ─────────────────────────

  /// Fait apparaître un élément pendant une fenêtre de la séquence d'ouverture.
  Widget _stage(double begin, double end, Widget child, {double dy = 22}) {
    return AnimatedBuilder(
      animation: _intro,
      child: child,
      builder: (BuildContext context, Widget? ch) {
        final double p = ((_intro.value - begin) / (end - begin)).clamp(0.0, 1.0).toDouble();
        final double v = Curves.easeOutCubic.transform(p);
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, dy * (1 - v)), child: ch),
        );
      },
    );
  }

  Widget _swap(String k, Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget w, Animation<double> a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(a),
          child: w,
        ),
      ),
      child: KeyedSubtree(key: ValueKey<String>(k), child: child),
    );
  }

  // ───────────────────────── Barre fixe (toujours visible) ─────────────────────────

  Widget _buildHeader() {
    final MediaQueryData mq = MediaQuery.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ValueListenableBuilder<double>(
        valueListenable: _headerT,
        builder: (BuildContext context, double t, Widget? _) {
          final Widget bar = DecoratedBox(
            decoration: BoxDecoration(
              color: _bg.withOpacity(0.58 + 0.37 * t),
              border: Border(
                bottom: BorderSide(color: _accent.withOpacity(0.16 + 0.28 * t), width: 0.7),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: mq.padding.top),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _headerTop(),
                  _headerNav(),
                ],
              ),
            ),
          );

          // Le flou n'est calculé qu'une fois la barre dépoli (économie de rendu).
          if (t < 0.02) return bar;
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18 * t, sigmaY: 18 * t),
              child: bar,
            ),
          );
        },
      ),
    );
  }

  Widget _headerTop() {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toTop,
              child: Text(
                'ÉGYPTE',
                softWrap: false,
                style: GoogleFonts.marcellus(color: _ivory, fontSize: 16, letterSpacing: 5),
              ),
            ),
            const Spacer(),
            _langPill(),
            const SizedBox(width: 10),
            _roundButton(Icons.search_rounded, _goSearch, size: 36, tooltip: t('searchHint')),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openSettings,
              child: Tooltip(message: t('settings'), child: _avatar(36)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerNav() {
    final List<String> labels = <String>[t('navHome'), t('navMonth'), t('navExplore')];
    return SizedBox(
      height: 40,
      child: ValueListenableBuilder<int>(
        valueListenable: _active,
        builder: (BuildContext context, int a, Widget? _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (int i = 0; i < labels.length; i++) _navLink(labels[i], i, a == i),
            ],
          );
        },
      ),
    );
  }

  Widget _navLink(String label, int i, bool on) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goSection(i),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: _text(
                11.5,
                color: on ? _ivory : _ivory.withOpacity(0.6),
                weight: on ? FontWeight.w600 : FontWeight.w500,
                spacing: _ar ? 0 : 2.0,
                height: 1.2,
              ),
              child: Text(_ar ? label : label.toUpperCase()),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              height: 1.5,
              width: on ? 22 : 0,
              color: _accent,
            ),
          ],
        ),
      ),
    );
  }

  /// Sélecteur de langue compact. L'ordre FR · EN · AR est identique en RTL.
  Widget _langPill() {
    const List<List<String>> langs = <List<String>>[
      <String>['fr', 'FR'],
      <String>['en', 'EN'],
      <String>['ar', 'AR'],
    ];
    int index = langs.indexWhere((List<String> l) => l[0] == _lang);
    if (index < 0) index = 0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 100,
        height: 30,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: _bg.withOpacity(0.45),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
        ),
        child: Stack(
          children: <Widget>[
            AnimatedAlign(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              alignment: Alignment(index - 1.0, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(12.5),
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                for (final List<String> l in langs) Expanded(child: _langItem(l[1], l[0])),
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
          style: GoogleFonts.jost(
            color: selected ? _on(_accent) : _ivory.withOpacity(0.85),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  // ───────────────────────── Présentation éditoriale ─────────────────────────

  Widget _buildHero(List<Map<String, dynamic>> pool, String greeting, bool isRtl) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double h = _heroHeight(mq);
    final List<Map<String, dynamic>> slides = pool.take(5).toList();

    return ValueListenableBuilder<int>(
      valueListenable: _heroIndex,
      builder: (BuildContext context, int idx, Widget? _) {
        final int cur = idx % slides.length;
        final Map<String, dynamic> dest = slides[cur];
        final Color c = dest['couleur'] as Color;
        final bool narrow = mq.size.width < 380;

        return GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
            final double velocity = details.primaryVelocity ?? 0.0;
            if (velocity.abs() < 220) return;
            final bool next = isRtl ? velocity > 0 : velocity < 0;
            _stepHero(next ? 1 : -1);
          },
          child: SizedBox(
            height: h,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                22,
                mq.padding.top + 108,
                22,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _stage(
                    0.02,
                    0.36,
                    Row(
                      children: <Widget>[
                        Container(
                          width: 24,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            greeting.toUpperCase(),
                            style: _text(
                              10.5,
                              color: _accent,
                              weight: FontWeight.w700,
                              spacing: _ar ? 0 : 2.0,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    dy: 14,
                  ),
                  const SizedBox(height: 13),
                  _stage(
                    0.10,
                    0.54,
                    Text(
                      t('welcomeEgypt'),
                      style: _display(narrow ? 34 : 40, height: 1.08),
                    ),
                    dy: 18,
                  ),
                  const SizedBox(height: 5),
                  _stage(
                    0.18,
                    0.68,
                    Text(
                      t('eyebrow'),
                      style: _text(
                        13,
                        color: _muted,
                        style: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                    dy: 12,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _stage(
                      0.26,
                      0.92,
                      _Pressable(
                        semanticLabel: '${dest['nom']}',
                        onTap: () => _open(dest),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                            border: Border.all(
                              color: _accent.withOpacity(0.30),
                              width: 0.9,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.30),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 7,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 900),
                                        switchInCurve: Curves.easeOutCubic,
                                        switchOutCurve: Curves.easeInCubic,
                                        child: _KenBurns(
                                          key: ValueKey<String>(dest['image'] as String),
                                          dir: cur.isEven ? 1 : -1,
                                          child: _photo(
                                            dest['image'] as String,
                                            logicalWidth: mq.size.width - 44,
                                          ),
                                        ),
                                      ),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: <Color>[
                                              Colors.black.withOpacity(0.28),
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.12),
                                            ],
                                            stops: const <double>[0.0, 0.42, 1.0],
                                          ),
                                        ),
                                      ),
                                      PositionedDirectional(
                                        top: 16,
                                        start: 16,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 11,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _bg.withOpacity(0.72),
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.18),
                                              width: 0.7,
                                            ),
                                          ),
                                          child: Text(
                                            '${_num(cur)}  /  ${_num(slides.length)}',
                                            style: _text(
                                              10,
                                              color: _ivory,
                                              weight: FontWeight.w600,
                                              spacing: 1.2,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PositionedDirectional(
                                        top: 16,
                                        end: 16,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: mq.size.width * 0.48,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _bg.withOpacity(0.72),
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.18),
                                              width: 0.7,
                                            ),
                                          ),
                                          child: _regionRow('${dest['region']}', c, size: 9.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  color: _surface,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    20,
                                    16,
                                    17,
                                    17,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              '${dest['nom']}',
                                              style: _display(25, height: 1.12),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${dest['description']}',
                                              style: _text(
                                                12,
                                                color: _muted,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      _arrowDot(isRtl, size: 44),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      dy: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _stage(0.46, 1.0, _heroBars(slides.length, cur), dy: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Photo plein cadre en fondu enchaîné, décodée à la résolution de l'écran.
  Widget _heroBackdrop(Map<String, dynamic> dest, int cur, MediaQueryData mq) {
    return Positioned.fill(
      child: _stage(
        0.0,
        0.5,
        ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              AnimatedBuilder(
                animation: _scroll,
                builder: (BuildContext context, Widget? child) {
                  final double off = _scroll.hasClients ? _scroll.offset.clamp(0.0, 800.0).toDouble() : 0.0;
                  return Transform.translate(offset: Offset(0, off * 0.22), child: child);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _KenBurns(
                    key: ValueKey<String>(dest['image'] as String),
                    dir: cur.isEven ? 1 : -1,
                    child: _photo(dest['image'] as String, logicalWidth: mq.size.width * 1.1),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.05),
                      _bg.withOpacity(0.25),
                      _bg.withOpacity(0.88),
                      _bg,
                    ],
                    stops: const <double>[0.0, 0.25, 0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
        dy: 0,
      ),
    );
  }

  Widget _heroContent(List<Map<String, dynamic>> slides, int cur, String greeting, bool isRtl) {
    final Map<String, dynamic> dest = slides[cur];
    final Color c = dest['couleur'] as Color;
    final bool narrow = MediaQuery.of(context).size.width < 380;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _stage(0.05, 0.40, _label(greeting, color: _accent)),
        const SizedBox(height: 18),
        _stage(
          0.12,
          0.60,
          Text(
            t('welcomeEgypt'),
            style: _display(narrow ? 40 : 54, height: 1.02),
          ),
        ),
        const SizedBox(height: 12),
        _stage(
          0.22,
          0.70,
          Text(
            t('eyebrow'),
            style: _text(15, color: _ivory.withOpacity(0.78), style: FontStyle.italic, spacing: 0.3, height: 1.3),
          ),
        ),
        const SizedBox(height: 30),
        _stage(0.34, 0.80, _goldHairline()),
        const SizedBox(height: 24),
        _stage(0.42, 0.90, _heroCaption(dest, c, cur, slides.length, isRtl), dy: 16),
        const SizedBox(height: 24),
        _stage(0.55, 1.0, _heroBars(slides.length, cur), dy: 10),
      ],
    );
  }

  /// Destination affichée : numéro, nom, description, bouton rond. Toute la zone est cliquable.
  Widget _heroCaption(Map<String, dynamic> dest, Color c, int cur, int total, bool isRtl) {
    return _Pressable(
      semanticLabel: '${dest['nom']}',
      onTap: () => _open(dest),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: _swap(
              '${dest['nom']}',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(_num(cur), style: GoogleFonts.marcellus(color: _accent, fontSize: 34, height: 1.0)),
                      const SizedBox(height: 6),
                      Text(
                        '/ ${total.toString().padLeft(2, '0')}',
                        style: _text(11.5, color: _muted, height: 1.2, spacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Container(width: 0.8, height: 64, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _regionRow('${dest['region']}', c, size: 11.5),
                        const SizedBox(height: 8),
                        Text(
                          '${dest['nom']}',
                          style: _display(26, height: 1.1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${dest['description']}',
                          style: _text(12.5, color: _ivory.withOpacity(0.72), height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          _arrowDot(isRtl, size: 48),
        ],
      ),
    );
  }

  /// Segments fins : destination en cours et temps restant.
  Widget _heroBars(int n, int cur) {
    return Row(
      children: <Widget>[
        for (int k = 0; k < n; k++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (k != cur) _goHero(k);
              },
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: k == n - 1 ? 0 : 8, top: 10, bottom: 10),
                child: SizedBox(
                  height: 2,
                  child: Stack(
                    children: <Widget>[
                      Container(color: Colors.white.withOpacity(0.2)),
                      if (k == cur)
                        AnimatedBuilder(
                          animation: _heroProgress,
                          builder: (BuildContext context, Widget? _) {
                            return FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: _heroProgress.value.clamp(0.0, 1.0).toDouble(),
                              child: Container(color: _accent),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ───────────────────────── Éléments de titrage ─────────────────────────

  Widget _label(String text, {Color? color}) {
    return Text(
      _ar ? text : text.toUpperCase(),
      style: _text(11.5, color: color ?? _accent, weight: FontWeight.w600, spacing: _ar ? 0 : 2.6, height: 1.2),
    );
  }

  /// Filet d'or qui s'estompe vers la droite.
  Widget _goldHairline({double width = double.infinity}) {
    return Container(
      width: width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[_accent.withOpacity(0.9), _accent.withOpacity(0.0)],
        ),
      ),
    );
  }

  /// En-tête de section : numéro romain, titre, filet d'or. Apparaît au défilement.
  Widget _chapterHead(int index, String eyebrow, String title, {Key? key}) {
    final String numeral = _romans[index.clamp(0, _romans.length - 1)];
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: _Reveal(
        controller: _scroll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(numeral, style: GoogleFonts.marcellus(color: _accent, fontSize: 14, letterSpacing: 2)),
                const SizedBox(width: 14),
                Container(width: 28, height: 1, color: _accent.withOpacity(0.6)),
                const SizedBox(width: 14),
                Expanded(child: _label(eyebrow, color: _muted)),
              ],
            ),
            const SizedBox(height: 18),
            Text(title, style: _display(38, height: 1.08)),
            const SizedBox(height: 22),
            _goldHairline(width: 72),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Recherche ─────────────────────────

  Widget _buildSearchSection() {
    final bool focused = _searchFocus.hasFocus;
    return Padding(
      key: _kSearch,
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: focused ? const Color(0xFF182231) : const Color(0x99131D2A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: focused ? _accent.withOpacity(0.8) : Colors.white.withOpacity(0.10),
            width: focused ? 1.2 : 0.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search_rounded, color: _accent, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: _onQuery,
                onSubmitted: (String _) => FocusScope.of(context).unfocus(),
                textInputAction: TextInputAction.search,
                cursorColor: _accent,
                style: _text(17, color: _ivory, height: 1.2),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: t('searchHint'),
                  hintStyle: _text(17, color: _muted, height: 1.2),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clearSearch,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                  child: const Icon(Icons.close_rounded, color: _ivory, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Recommandé ce mois-ci ─────────────────────────

  Widget _buildFeatured(List<Map<String, dynamic>> month, bool isRtl) {
    final DateTime now = DateTime.now();
    final List<String> names = _accueilMonths[_lang] ?? _accueilMonths['fr']!;
    final String monthLabel = '${names[now.month - 1]} ${now.year}';

    return Padding(
      padding: const EdgeInsets.only(top: 88, bottom: 86),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _chapterHead(0, monthLabel, t('recommendedMonth'), key: _kMonth),
          if (month.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(t('noDestMonth'), style: _text(14, color: _muted)),
            )
          else ...<Widget>[
            SizedBox(
              height: 560,
              child: PageView.builder(
                controller: _featuredCtrl,
                physics: const BouncingScrollPhysics(),
                itemCount: month.length,
                onPageChanged: (int idx) {
                  HapticFeedback.selectionClick();
                  _featuredIndex.value = idx;
                },
                itemBuilder: (BuildContext context, int idx) {
                  return AnimatedBuilder(
                    animation: _featuredCtrl,
                    builder: (BuildContext context, Widget? _) {
                      double page = _featuredIndex.value.toDouble();
                      if (_featuredCtrl.hasClients && _featuredCtrl.position.haveDimensions) {
                        page = _featuredCtrl.page ?? page;
                      }
                      final double delta = (idx - page).clamp(-1.5, 1.5).toDouble();
                      final double dist = delta.abs().clamp(0.0, 1.0).toDouble();
                      return Transform.scale(
                        scale: 1 - dist * 0.05,
                        child: Opacity(
                          opacity: 1 - dist * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: _featuredCard(month[idx], delta, isRtl, idx),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (month.length > 1) ...<Widget>[
              const SizedBox(height: 28),
              _featuredControls(month.length, isRtl),
            ],
          ],
        ],
      ),
    );
  }

  Widget _featuredCard(Map<String, dynamic> d, double delta, bool isRtl, int idx) {
    final Color c = d['couleur'] as Color;
    final List<int> fav = _favMonths(d);

    return _Pressable(
      semanticLabel: '${d['nom']}',
      onTap: () => _open(d),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _accent.withOpacity(0.38), width: 0.9),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints cons) {
              final double ext = cons.maxWidth * 0.07;
              final double shift = delta.clamp(-1.0, 1.0).toDouble() * ext * (isRtl ? 1 : -1);
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    left: -ext,
                    right: -ext,
                    top: 0,
                    bottom: 0,
                    child: Transform.translate(
                      offset: Offset(shift, 0),
                      child: _photo(d['image'] as String, logicalWidth: cons.maxWidth + ext * 2),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          _bg.withOpacity(0.55),
                          _bg.withOpacity(0.97),
                        ],
                        stops: const <double>[0.0, 0.26, 0.6, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 22,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: <Widget>[
                        Text(_num(idx), style: GoogleFonts.marcellus(color: _accent, fontSize: 22, height: 1.0)),
                        const Spacer(),
                        Flexible(child: _regionRow('${d['region']}', c, size: 11)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${d['nom']}',
                          style: _display(30, height: 1.1),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${d['description']}',
                          style: _text(13.5, color: _ivory.withOpacity(0.78), height: 1.55),
                        ),
                        const SizedBox(height: 18),
                        _goldHairline(),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: fav.isEmpty
                                  ? const SizedBox.shrink()
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _seasonGlyph(fav),
                                  const SizedBox(height: 8),
                                  Text(
                                    t('bestSeason'),
                                    style: _text(11.5, color: _muted, style: FontStyle.italic, height: 1.2),
                                  ),
                                ],
                              ),
                            ),
                            _arrowDot(isRtl, size: 44),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _featuredControls(int n, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ValueListenableBuilder<int>(
        valueListenable: _featuredIndex,
        builder: (BuildContext context, int v, Widget? _) {
          return Row(
            children: <Widget>[
              Text(_num(v), style: GoogleFonts.marcellus(color: _accent, fontSize: 20, height: 1.0)),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 2,
                  child: Stack(
                    children: <Widget>[
                      Container(color: Colors.white.withOpacity(0.14)),
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: (v + 1) / n,
                        child: Container(color: _accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(_num(n - 1), style: GoogleFonts.marcellus(color: _muted, fontSize: 16, height: 1.0)),
              const SizedBox(width: 20),
              _roundButton(
                isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                    () => _stepFeatured(-1, n),
                size: 40,
              ),
              const SizedBox(width: 8),
              _roundButton(
                isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                    () => _stepFeatured(1, n),
                size: 40,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Frise des douze mois : barres hautes = meilleurs mois, mois courant éclairci.
  Widget _seasonGlyph(List<int> fav) {
    final int now = DateTime.now().month;
    final List<String> names = _accueilMonths[_lang] ?? _accueilMonths['fr']!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (int m = 1; m <= 12; m++)
          Padding(
            padding: EdgeInsetsDirectional.only(start: m == 1 ? 0 : 5),
            child: SizedBox(
              width: 9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 5,
                    height: fav.contains(m) ? 16 : 5,
                    decoration: BoxDecoration(
                      color: fav.contains(m)
                          ? (m == now ? Color.lerp(_accent, Colors.white, 0.5) : _accent)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    names[m - 1].substring(0, 1),
                    textAlign: TextAlign.center,
                    style: _text(
                      8.5,
                      color: m == now ? _ivory : _muted.withOpacity(0.7),
                      weight: m == now ? FontWeight.w700 : FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ───────────────────────── Explorer ─────────────────────────

  Widget _buildExplore(List<Map<String, dynamic>> all, bool isRtl) {
    final List<Map<String, dynamic>> cats = _categories();
    final List<Map<String, dynamic>> shown = _selectedCat == null
        ? cats
        : cats.where((Map<String, dynamic> c) => c['key'] == _selectedCat).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _chapterHead(1, t('eyebrow'), t('exploreByRegion'), key: _kExplore),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: <Widget>[
                _chip(null, t('all'), Icons.apps_rounded),
                ...cats.map(
                      (Map<String, dynamic> c) => _chip(c['key'] as String, c['label'] as String, c['icon'] as IconData),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[...previous, if (current != null) current],
            ),
            transitionBuilder: (Widget child, Animation<double> anim) => FadeTransition(opacity: anim, child: child),
            child: SizedBox(
              key: ValueKey<String>(_selectedCat ?? '__all__'),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  for (final Map<String, dynamic> cat in shown) _categoryBlock(cat, all, isRtl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String? key, String label, IconData icon) {
    final bool selected = _selectedCat == key;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (selected) return;
        HapticFeedback.selectionClick();
        setState(() => _selectedCat = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accent : const Color(0x66192331),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? _accent : Colors.white.withOpacity(0.2),
            width: 0.9,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: selected ? _on(_accent) : _muted),
            const SizedBox(width: 8),
            Text(
              label,
              softWrap: false,
              style: _text(
                13.5,
                color: selected ? _on(_accent) : _ivory.withOpacity(0.85),
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBlock(Map<String, dynamic> cat, List<Map<String, dynamic>> all, bool isRtl) {
    final List<Map<String, dynamic>> items =
    all.where((Map<String, dynamic> d) => d['categoryKey'] == cat['key']).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final int n = items.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Reveal(
            controller: _scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(cat['label'] as String, style: _display(29, height: 1.12)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$n ${n > 1 ? t('elements') : t('element')}',
                      style: _text(12.5, color: _muted, height: 1.3),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[_accent.withOpacity(0.72), _accent.withOpacity(0.05)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 34),
              child: _listingCard(items[i], i, isRtl),
            ),
        ],
      ),
    );
  }

  /// Carte destination — composition éditoriale premium avec photo, panneau matière et détails.
  Widget _listingCard(Map<String, dynamic> d, int i, bool isRtl) {
    final Color c = d['couleur'] as Color;
    final double w = MediaQuery.of(context).size.width - 48;

    return _Reveal(
      controller: _scroll,
      dy: 34,
      child: _Pressable(
        semanticLabel: '${d['nom']}',
        onTap: () => _open(d),
        child: Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _accent.withOpacity(0.22), width: 0.8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.34,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _Parallax(
                        controller: _scroll,
                        extent: 0.16,
                        child: _photo(d['image'] as String, logicalWidth: w),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.black.withOpacity(0.34),
                              Colors.transparent,
                              Colors.black.withOpacity(0.34),
                            ],
                            stops: const <double>[0, 0.52, 1],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: 18,
                        start: 18,
                        end: 18,
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _bg.withOpacity(0.66),
                                shape: BoxShape.circle,
                                border: Border.all(color: _accent.withOpacity(0.72), width: 0.9),
                              ),
                              child: Text(
                                _num(i),
                                style: GoogleFonts.marcellus(color: _ivory, fontSize: 15),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.56,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                              decoration: BoxDecoration(
                                color: _bg.withOpacity(0.72),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
                              ),
                              child: _regionRow('${d['region']}', c, size: 9.5),
                            ),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 18,
                        start: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.location_on_outlined, color: _ivory.withOpacity(0.9), size: 15),
                            const SizedBox(width: 6),
                            Text(
                              _ar ? t('discover') : t('discover').toUpperCase(),
                              style: _text(9.5, color: _ivory.withOpacity(0.92), weight: FontWeight.w600,
                                  spacing: _ar ? 0 : 1.8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 21, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${d['nom']}',
                              style: _display(27, height: 1.12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _accent.withOpacity(0.10),
                              border: Border.all(color: _accent.withOpacity(0.42), width: 0.9),
                            ),
                            child: Icon(
                              isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                              color: _accent,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Text(
                        '${d['description']}',
                        style: _text(13.5, color: _muted, height: 1.62),
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

  // ───────────────────────── Résultats de recherche ─────────────────────────

  Widget _buildResults(List<Map<String, dynamic>> results, bool isRtl) {
    final int n = results.length;
    return Padding(
      padding: const EdgeInsets.only(top: 56, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _chapterHead(
            0,
            n == 0 ? t('searchResults') : '$n ${n > 1 ? t('elements') : t('element')}',
            t('searchResults'),
          ),
          if (n == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(t('noResults'), style: _text(14.5, color: _muted)),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < n; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 52),
                      child: _listingCard(results[i], i, isRtl),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── Pied de page ─────────────────────────

  Widget _buildFooter() {
    final double bottom = MediaQuery.of(context).padding.bottom;
    return _Reveal(
      controller: _scroll,
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: EdgeInsets.fromLTRB(24, 60, 24, 48 + bottom),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 56,
              child: CustomPaint(painter: _PyramidsPainter(_accent)),
            ),
            const SizedBox(height: 26),
            Text(
              'ÉGYPTE',
              textAlign: TextAlign.center,
              style: GoogleFonts.marcellus(color: _ivory, fontSize: 16, letterSpacing: 8),
            ),
            const SizedBox(height: 12),
            Text(
              t('footer'),
              textAlign: TextAlign.center,
              style: _text(13.5, color: _muted, style: FontStyle.italic, height: 1.5),
            ),
            const SizedBox(height: 32),
            _Pressable(
              semanticLabel: t('backToTop'),
              onTap: () {
                HapticFeedback.selectionClick();
                _toTop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _accent.withOpacity(0.6), width: 0.9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.keyboard_arrow_up_rounded, color: _accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _ar ? t('backToTop') : t('backToTop').toUpperCase(),
                      style: _text(12, color: _accent, weight: FontWeight.w600, spacing: _ar ? 0 : 1.8, height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Petits composants ─────────────────────────

  /// Image décodée à la taille réelle d'affichage × densité de l'écran (nette).
  Widget _photo(String path, {double? logicalWidth}) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double w = logicalWidth ?? mq.size.width;
    final int cw = (w * mq.devicePixelRatio).round().clamp(480, 1600).toInt();
    return ColoredBox(
      color: _surface,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: cw,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
        const ColoredBox(color: _surface),
      ),
    );
  }

  Widget _regionRow(String label, Color c, {double size = 12.5}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _ar ? label : label.toUpperCase(),
            style: _text(
              size,
              color: Color.lerp(c, _ivory, 0.45),
              weight: FontWeight.w600,
              height: 1.2,
              spacing: _ar ? 0 : 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar(double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: <Color>[
            Color.lerp(_accent, Colors.white, 0.5)!,
            _accent,
            Color.lerp(_accent, Colors.black, 0.42)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _surface),
        alignment: Alignment.center,
        child: Text(_currentAvatar, style: TextStyle(fontSize: size * 0.46)),
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap, {double size = 46, String? tooltip}) {
    final Widget btn = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _bg.withOpacity(0.45),
          border: Border.all(color: _accent.withOpacity(0.6), width: 0.9),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: _accent, size: size * 0.46),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  Widget _arrowDot(bool isRtl, {double size = 46}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _accent),
      child: Icon(
        isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
        color: _on(_accent),
        size: size * 0.44,
      ),
    );
  }
}

// ==========================================
// COMPOSANTS D'ANIMATION
// ==========================================

/// Légère contraction au toucher.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;
  const _Pressable({required this.child, required this.onTap, this.semanticLabel});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.982 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Apparition en fondu et glissement, une seule fois, quand l'élément entre dans l'écran.
/// Le contrôle est répété à chaque défilement ET après le premier rendu, donc un élément
/// ajouté par la recherche ou un changement de catégorie n'attend pas un nouveau scroll.
class _Reveal extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final double dy;
  final int delayMs;
  const _Reveal({required this.controller, required this.child, this.dy = 36, this.delayMs = 0});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 820),
  );
  late final Animation<double> _v = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutQuart,
  );

  bool _shown = false;
  bool _checkScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleCheck);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleCheck());
  }

  @override
  void didUpdateWidget(covariant _Reveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleCheck);
      widget.controller.addListener(_scheduleCheck);
      _scheduleCheck();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleCheck);
    _c.dispose();
    super.dispose();
  }

  /// Vérifie la position après la mise en page : les coordonnées sont ainsi
  /// recalculées une fois que le scroll a réellement déplacé les éléments.
  void _scheduleCheck() {
    if (!mounted || _shown || _checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (mounted) _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (_shown || !mounted) return;

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return;
    }

    final MediaQueryData media = MediaQuery.of(context);
    final Offset origin = renderObject.localToGlobal(Offset.zero);
    final Rect bounds = origin & renderObject.size;
    final double safeTop = media.padding.top + 92;
    final double safeBottom = media.size.height - media.padding.bottom;

    // L'élément doit réellement croiser la zone visible, et non simplement
    // avoir son bord supérieur au-dessus de l'écran.
    final bool entersViewport =
        bounds.bottom > safeTop && bounds.top < safeBottom - 24;
    if (!entersViewport) return;

    _shown = true;
    if (media.disableAnimations) {
      _c.value = 1;
      return;
    }

    if (widget.delayMs <= 0) {
      _c.forward();
    } else {
      Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted && !_c.isAnimating) _c.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _v,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double progress = _v.value;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, widget.dy * (1 - progress)),
            child: Transform.scale(
              scale: 0.985 + (0.015 * progress),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Parallaxe verticale : la photo glisse lentement dans son cadre pendant le défilement.
class _Parallax extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final double extent;
  const _Parallax({required this.controller, required this.child, this.extent = 0.16});

  @override
  State<_Parallax> createState() => _ParallaxState();
}

class _ParallaxState extends State<_Parallax> {
  final GlobalKey _k = GlobalKey();

  double _fraction() {
    final BuildContext? ctx = _k.currentContext;
    if (ctx == null) return 0;
    final RenderObject? ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return 0;
    final double vh = MediaQuery.of(context).size.height;
    final double mid = ro.localToGlobal(Offset.zero).dy + ro.size.height / 2;
    return ((mid - vh / 2) / (vh / 2)).clamp(-1.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      key: _k,
      child: AnimatedBuilder(
        animation: widget.controller,
        child: widget.child,
        builder: (BuildContext context, Widget? child) {
          final double f = _fraction();
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints cons) {
              final double extra = cons.maxHeight * widget.extent;
              return OverflowBox(
                alignment: Alignment.center,
                minHeight: cons.maxHeight + extra,
                maxHeight: cons.maxHeight + extra,
                child: Transform.translate(offset: Offset(0, -f * extra / 2), child: child),
              );
            },
          );
        },
      ),
    );
  }
}

/// Travelling très lent sur la photo du hero.
class _KenBurns extends StatefulWidget {
  final Widget child;
  final int dir;
  const _KenBurns({super.key, required this.child, this.dir = 1});

  @override
  State<_KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<_KenBurns> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool still = MediaQuery.of(context).disableAnimations;
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (BuildContext context, Widget? child) {
          final double v = still ? 0.0 : Curves.easeOut.transform(_c.value);
          return Transform.translate(
            offset: Offset(widget.dir * -10.0 * v, 0),
            child: Transform.scale(scale: 1.04 + 0.05 * v, child: child),
          );
        },
      ),
    );
  }
}