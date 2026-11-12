import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profil.dart';

class PresentationScreen extends StatefulWidget {
  final String languageCode;
  const PresentationScreen({super.key, this.languageCode = 'fr'});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  late String _currentLanguage;

  // Palette : nuit du désert + or
  static const Color night = Color(0xFF0B0D12);
  static const Color gold = Color(0xFFE9C46A);
  static const Color goldDeep = Color(0xFFC9973A);
  static const Color sand = Color(0xFFF6EFE0);
  static const Color muted = Color(0xFFB9BFCC);

  // Une photo de fond par slide
  static const List<String> _backgrounds = [
    'assets/3.jpg',
    'assets/desert/blanc.jpg',
    'assets/louxor/rois.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.languageCode;
  }

  @override
  void didUpdateWidget(covariant PresentationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      setState(() => _currentLanguage = widget.languageCode);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {'next': 'Continuer', 'start': 'Commencer', 'skip': 'Passer'},
    'en': {'next': 'Continue', 'start': 'Get started', 'skip': 'Skip'},
    'ar': {'next': 'متابعة', 'start': 'ابدأ الرحلة', 'skip': 'تخطي'},
  };

  static const Map<String, List<Map<String, dynamic>>> _slidesData = {
    'fr': [
      {
        'type': 'hero_list',
        'eyebrow': 'ÉGYPTE',
        'title': 'Découvrez l’Égypte',
        'subtitle': 'Des merveilles antiques aux paysages à couper le souffle',
        'features': [
          {'icon': Icons.account_balance_outlined, 'label': 'Histoire millénaire'},
          {'icon': Icons.camera_alt_outlined, 'label': 'Sites incroyables'},
          {'icon': Icons.wb_sunny_outlined, 'label': 'Culture authentique'},
          {'icon': Icons.card_travel_outlined, 'label': 'Expériences uniques'},
        ],
      },
      {
        'type': 'cards',
        'title': 'Vivez des expériences uniques',
        'items': [
          {'title': 'Survolez la vallée des Rois', 'image': 'assets/louxor/rois.jpg', 'icon': '🎈'},
          {'title': 'Aventure dans le désert', 'image': 'assets/desert/blanc.jpg', 'icon': '🐪'},
          {'title': 'Croisière sur le Nil', 'image': 'assets/3.jpg', 'icon': '⛵'},
          {'title': 'Saveurs et traditions locales', 'image': 'assets/plat/k.jpg', 'icon': '🏮'},
        ],
      },
      {
        'type': 'summary',
        'title': 'Prêt pour l’aventure ?',
        'subtitle': 'Votre épopée légendaire commence ici.',
        'badge': 'L’Appel des Pharaons',
        'description':
        'Laissez-vous porter par la magie du Nil, la grandeur des pyramides et la chaleur de l’hospitalité égyptienne. Votre carnet de voyage sur-mesure n’attend plus que vous.',
      },
    ],
    'en': [
      {
        'type': 'hero_list',
        'eyebrow': 'EGYPT',
        'title': 'Discover Egypt',
        'subtitle': 'From ancient wonders to breathtaking landscapes',
        'features': [
          {'icon': Icons.account_balance_outlined, 'label': 'Ancient history'},
          {'icon': Icons.camera_alt_outlined, 'label': 'Amazing sites'},
          {'icon': Icons.wb_sunny_outlined, 'label': 'Authentic culture'},
          {'icon': Icons.card_travel_outlined, 'label': 'Unique experiences'},
        ],
      },
      {
        'type': 'cards',
        'title': 'Live unique experiences',
        'items': [
          {'title': 'Fly over Valley of the Kings', 'image': 'assets/louxor/rois.jpg', 'icon': '🎈'},
          {'title': 'Desert adventure', 'image': 'assets/desert/blanc.jpg', 'icon': '🐪'},
          {'title': 'Nile cruise', 'image': 'assets/3.jpg', 'icon': '⛵'},
          {'title': 'Local flavors & traditions', 'image': 'assets/plat/k.jpg', 'icon': '🏮'},
        ],
      },
      {
        'type': 'summary',
        'title': 'Ready for adventure?',
        'subtitle': 'Your legendary epic begins here.',
        'badge': 'The Call of the Pharaohs',
        'description':
        'Let yourself be carried away by the magic of the Nile, the grandeur of the pyramids, and the warmth of Egyptian hospitality. Your custom travel log awaits.',
      },
    ],
    'ar': [
      {
        'type': 'hero_list',
        'eyebrow': 'مصر',
        'title': 'اكتشف مصر',
        'subtitle': 'من العجائب القديمة إلى المناظر الطبيعية الخلابة',
        'features': [
          {'icon': Icons.account_balance_outlined, 'label': 'تاريخ عريق'},
          {'icon': Icons.camera_alt_outlined, 'label': 'معالم مذهلة'},
          {'icon': Icons.wb_sunny_outlined, 'label': 'ثقافة أصيلة'},
          {'icon': Icons.card_travel_outlined, 'label': 'تجارب فريدة'},
        ],
      },
      {
        'type': 'cards',
        'title': 'عِش تجارب فريدة',
        'items': [
          {'title': 'حلّق فوق وادي الملوك', 'image': 'assets/louxor/rois.jpg', 'icon': '🎈'},
          {'title': 'مغامرة في الصحراء', 'image': 'assets/desert/blanc.jpg', 'icon': '🐪'},
          {'title': 'جولة بحرية في النيل', 'image': 'assets/3.jpg', 'icon': '⛵'},
          {'title': 'نكهات وتقاليد محلية', 'image': 'assets/plat/k.jpg', 'icon': '🏮'},
        ],
      },
      {
        'type': 'summary',
        'title': 'جاهز للمغامرة؟',
        'subtitle': 'ملحمتك الأسطورية تبدأ هنا.',
        'badge': 'نداء الفراعنة',
        'description':
        'دع نفسك تنجرف مع سحر النيل العظيم وعظمة الأهرامات ودفء الضيافة المصرية الأصيلة. رحلتك الخاصة بانتظارك الآن.',
      },
    ],
  };

  Future<void> _setLanguage(String lang) async {
    if (lang == _currentLanguage) return;
    setState(() => _currentLanguage = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    await prefs.setString('selected_language', _currentLanguage);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(languageCode: _currentLanguage),
      ),
    );
  }

  void _next(int total) {
    if (_currentIndex < total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = _currentLanguage == 'ar';
    final ui = _uiTranslations[_currentLanguage] ?? _uiTranslations['fr']!;
    final slides = _slidesData[_currentLanguage] ?? _slidesData['fr']!;
    final bool isLast = _currentIndex == slides.length - 1;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(ui, isLast),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: slides.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, index) {
                        final slide = slides[index];
                        switch (slide['type']) {
                          case 'hero_list':
                            return _buildHeroSlide(slide);
                          case 'cards':
                            return _buildCardsSlide(slide);
                          default:
                            return _buildSummarySlide(slide);
                        }
                      },
                    ),
                  ),
                  _buildBottomBar(ui, slides.length, isLast, isRtl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Fond ─────────────────────────

  Widget _buildBackground() {
    final path = _backgrounds[_currentIndex.clamp(0, _backgrounds.length - 1)];
    final double blur = _currentIndex == 1 ? 22 : 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: SizedBox.expand(
            key: ValueKey(path),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: night),
              ),
            ),
          ),
        ),
        // Voile sombre pour la lisibilité
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                night.withOpacity(0.55),
                night.withOpacity(0.25),
                night.withOpacity(0.80),
                night.withOpacity(0.97),
              ],
              stops: const [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Barre du haut ─────────────────────────

  Widget _buildTopBar(Map<String, String> ui, bool isLast) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassBox(
            radius: 22,
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['fr', 'en', 'ar'].map((code) {
                final selected = code == _currentLanguage;
                return GestureDetector(
                  onTap: () => _setLanguage(code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? gold : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      code.toUpperCase(),
                      style: TextStyle(
                        color: selected ? night : sand.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isLast ? 0 : 1,
            child: TextButton(
              onPressed: isLast ? null : _finishOnboarding,
              style: TextButton.styleFrom(foregroundColor: sand),
              child: Text(
                ui['skip']!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Barre du bas ─────────────────────────

  Widget _buildBottomBar(Map<String, String> ui, int total, bool isLast, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Row(
        children: [
          // Indicateurs
          Row(
            children: List.generate(total, (i) {
              final active = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsetsDirectional.only(end: 6),
                width: active ? 26 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? gold : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const Spacer(),
          // Bouton
          GestureDetector(
            onTap: () => _next(total),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 56,
              padding: const EdgeInsetsDirectional.only(start: 24, end: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(colors: [gold, goldDeep]),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isLast ? ui['start']! : ui['next']!,
                      key: ValueKey(isLast),
                      style: const TextStyle(
                        color: night,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: night, shape: BoxShape.circle),
                    child: Icon(
                      isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                      color: gold,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Slide 1 : Hero ─────────────────────────

  Widget _buildHeroSlide(Map<String, dynamic> slide) {
    final features = slide['features'] as List<Map<String, dynamic>>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          _Reveal(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 28, height: 2, color: gold),
                const SizedBox(width: 10),
                Text(
                  slide['eyebrow'] as String,
                  style: const TextStyle(
                    color: gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Reveal(
            delay: 100,
            child: Text(
              slide['title'] as String,
              style: const TextStyle(
                color: sand,
                fontSize: 42,
                height: 1.1,
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Reveal(
            delay: 200,
            child: Text(
              slide['subtitle'] as String,
              style: const TextStyle(color: muted, fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 88,
            ),
            itemBuilder: (context, i) {
              final f = features[i];
              return _Reveal(
                delay: 300 + i * 90,
                child: _GlassBox(
                  radius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(f['icon'] as IconData, color: gold, size: 22),
                      Text(
                        f['label'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: sand,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ───────────────────────── Slide 2 : Expériences ─────────────────────────

  Widget _buildCardsSlide(Map<String, dynamic> slide) {
    final items = slide['items'] as List<Map<String, dynamic>>;

    Widget card(int i) {
      final item = items[i];
      return Expanded(
        child: _Reveal(
          delay: 150 + i * 110,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1E29)),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, night.withOpacity(0.9)],
                        stops: const [0.45, 1.0],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 10,
                    start: 10,
                    child: _GlassBox(
                      radius: 14,
                      padding: const EdgeInsets.all(7),
                      child: Text(item['icon'] as String, style: const TextStyle(fontSize: 15)),
                    ),
                  ),
                  PositionedDirectional(
                    start: 12,
                    end: 12,
                    bottom: 12,
                    child: Text(
                      item['title'] as String,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: sand,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _Reveal(
            child: Text(
              slide['title'] as String,
              style: const TextStyle(
                color: sand,
                fontSize: 30,
                height: 1.15,
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 44, height: 3, decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: 22),
          // Grille décalée : colonne droite plus basse
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: Column(
                      children: [card(0), const SizedBox(height: 14), card(2)],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 26),
                    child: Column(
                      children: [card(1), const SizedBox(height: 14), card(3)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ───────────────────────── Slide 3 : Final ─────────────────────────

  Widget _buildSummarySlide(Map<String, dynamic> slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          _Reveal(
            child: _GlassBox(
              radius: 32,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: gold.withOpacity(0.5)),
                    ),
                    child: Text(
                      slide['badge'] as String,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    slide['title'] as String,
                    style: const TextStyle(
                      color: sand,
                      fontSize: 32,
                      height: 1.15,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide['subtitle'] as String,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    slide['description'] as String,
                    style: const TextStyle(color: muted, fontSize: 14.5, height: 1.65),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ───────────────────────── Widgets utilitaires ─────────────────────────

/// Carte en verre dépoli (glassmorphism).
class _GlassBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  const _GlassBox({
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withOpacity(0.09),
            border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Apparition douce : fondu + léger glissement vers le haut.
class _Reveal extends StatelessWidget {
  final Widget child;
  final int delay; // ms

  const _Reveal({required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    final total = 600 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}