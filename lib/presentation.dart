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

  // Palette Luxe Pharaonique (Tons profonds, or impérial et cuivre)
  static const Color bgDark = Color(0xFF06070B);
  static const Color bgTop = Color(0xFF10131E);
  static const Color cardBg = Color(0xFF131722);
  static const Color goldPrimary = Color(0xFFE6C567);
  static const Color goldLight = Color(0xFFF9E8B2);
  static const Color goldDark = Color(0xFF997D25);
  static const Color textLight = Color(0xFFF5F7FA);
  static const Color textMuted = Color(0xFF8C9BB2);

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.languageCode;
  }

  @override
  void didUpdateWidget(covariant PresentationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      setState(() {
        _currentLanguage = widget.languageCode;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {'next': 'Continuer', 'start': 'Commencer le voyage'},
    'en': {'next': 'Continue', 'start': 'Start the journey'},
    'ar': {'next': 'متابعة', 'start': 'ابدأ الرحلة'},
  };

  static const Map<String, List<Map<String, dynamic>>> _slidesData = {
    'fr': [
      {
        'type': 'hero_list',
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
          {
            'title': 'Survolez la vallée des Rois',
            'image': 'assets/louxor/rois.jpg',
            'icon': '🎈',
          },
          {
            'title': 'Aventure dans le désert',
            'image': 'assets/desert/blanc.jpg',
            'icon': '🐪',
          },
          {
            'title': 'Croisière sur le Nil',
            'image': 'assets/3.jpg',
            'icon': '⛵',
          },
          {
            'title': 'Saveurs et traditions locales',
            'image': 'assets/plat/k.jpg',
            'icon': '🏮',
          },
        ],
      },
      {
        'type': 'summary',
        'title': 'Prêt pour l’aventure ?',
        'subtitle': 'Votre épopée légendaire commence ici.',
        'badge': 'L’Appel des Pharaons',
        'description': 'Laissez-vous porter par la magie du Nil, la grandeur des pyramides et la chaleur de l’hospitalité égyptienne. Votre carnet de voyage sur-mesure n’attend plus que vous.',
      },
    ],
    'en': [
      {
        'type': 'hero_list',
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
          {
            'title': 'Fly over Valley of the Kings',
            'image': 'assets/louxor/rois.jpg',
            'icon': '🎈',
          },
          {
            'title': 'Desert adventure',
            'image': 'assets/desert/blanc.jpg',
            'icon': '🐪',
          },
          {
            'title': 'Nile cruise',
            'image': 'assets/3.jpg',
            'icon': '⛵',
          },
          {
            'title': 'Local flavors & traditions',
            'image': 'assets/plat/k.jpg',
            'icon': '🏮',
          },
        ],
      },
      {
        'type': 'summary',
        'title': 'Ready for adventure?',
        'subtitle': 'Your legendary epic begins here.',
        'badge': 'The Call of the Pharaohs',
        'description': 'Let yourself be carried away by the magic of the Nile, the grandeur of the pyramids, and the warmth of Egyptian hospitality. Your custom travel log awaits.',
      },
    ],
    'ar': [
      {
        'type': 'hero_list',
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
          {
            'title': 'حلّق فوق وادي الملوك',
            'image': 'assets/louxor/rois.jpg',
            'icon': '🎈',
          },
          {
            'title': 'مغامرة في الصحراء',
            'image': 'assets/desert/blanc.jpg',
            'icon': '🐪',
          },
          {
            'title': 'جولة بحرية في النيل',
            'image': 'assets/3.jpg',
            'icon': '⛵',
          },
          {
            'title': 'نكهات وتقاليد محلية',
            'image': 'assets/plat/k.jpg',
            'icon': '🏮',
          },
        ],
      },
      {
        'type': 'summary',
        'title': 'جاهز للمغامرة؟',
        'subtitle': 'ملحمتك الاسطورية تبدأ هنا.',
        'badge': 'نداء الفراعنة',
        'description': 'دع, نفسك تنجرف سحراً مع النيل العظيم وعظمة الأهرامات ودفء الضيافة المصرية الأصيلة. رحلتك الخاصة بانتظارك الآن.',
      },
    ],
  };

  Future<void> _cycleLanguage() async {
    final nextLang = _currentLanguage == 'fr'
        ? 'en'
        : _currentLanguage == 'en'
        ? 'ar'
        : 'fr';

    setState(() {
      _currentLanguage = nextLang;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', nextLang);
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

  @override
  Widget build(BuildContext context) {
    final bool isRtl = _currentLanguage == 'ar';
    final ui = _uiTranslations[_currentLanguage] ?? _uiTranslations['fr']!;
    final slides = _slidesData[_currentLanguage] ?? _slidesData['fr']!;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgDark,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgTop, bgDark, Color(0xFF030406)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Arrière-plan thématique luxueux avec lueurs mystiques
                Positioned.fill(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -100,
                        right: -50,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: goldPrimary.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -80,
                        left: -50,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: goldPrimary.withOpacity(0.04),
                          ),
                        ),
                      ),
                      Positioned(left: 10, top: 20, bottom: 20, child: _buildHieroglyphColumn()),
                      Positioned(right: 10, top: 20, bottom: 20, child: _buildHieroglyphColumn()),
                    ],
                  ),
                ),

                Column(
                  children: [
                    // Sélecteur de langue haut de gamme
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _cycleLanguage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: goldPrimary.withOpacity(0.6), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _currentLanguage.toUpperCase(),
                                style: const TextStyle(
                                  color: goldLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pages du carrousel
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        physics: const BouncingScrollPhysics(),
                        itemCount: slides.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final slide = slides[index];
                          if (slide['type'] == 'hero_list') {
                            return _buildHeroListSlide(slide);
                          } else if (slide['type'] == 'cards') {
                            return _buildCardsGridSlide(slide);
                          } else {
                            return _buildSummarySlide(slide);
                          }
                        },
                      ),
                    ),

                    // Indicateurs et bouton de navigation inférieur
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              slides.length,
                                  (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentIndex == index ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentIndex == index ? goldPrimary : goldPrimary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: _currentIndex == index
                                      ? [BoxShadow(color: goldPrimary.withOpacity(0.5), blurRadius: 6)]
                                      : [],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: const LinearGradient(
                                  colors: [goldLight, goldPrimary, goldDark],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: goldPrimary.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                onPressed: () {
                                  if (_currentIndex < slides.length - 1) {
                                    _controller.nextPage(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    _finishOnboarding();
                                  }
                                },
                                child: Text(
                                  _currentIndex < slides.length - 1 ? ui['next']! : ui['start']!,
                                  style: const TextStyle(
                                    color: bgDark,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Slide 1 : Style Papyrus moderne et épuré centré
  Widget _buildHeroListSlide(Map<String, dynamic> slide) {
    final features = slide['features'] as List<Map<String, dynamic>>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildHeaderAnkh(slide['title'], slide['subtitle']),
          Expanded(
            child: Center(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final f = features[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: cardBg.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: goldPrimary.withOpacity(0.4), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [bgDark, cardBg],
                            ),
                            border: Border.all(color: goldPrimary.withOpacity(0.7), width: 1.5),
                          ),
                          child: Icon(f['icon'] as IconData, size: 24, color: goldPrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            f['label'] as String,
                            style: const TextStyle(
                              color: textLight,
                              fontSize: 15,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2 : Grille immersive encadrée d'or
  Widget _buildCardsGridSlide(Map<String, dynamic> slide) {
    final items = slide['items'] as List<Map<String, dynamic>>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildHeaderAnkh(slide['title'], null),
          Expanded(
            child: Center(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: goldPrimary.withOpacity(0.45), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                                child: Image.asset(
                                  item['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: cardBg),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bgDark.withOpacity(0.9),
                                    border: Border.all(color: goldPrimary, width: 1.5),
                                  ),
                                  child: Text(
                                    item['icon'] ?? '𓋹',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                          child: Text(
                            item['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: textLight,
                              fontSize: 12,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3 : Sans image, transformée en une magnifique stèle/carte textuelle immersive et élégante
  Widget _buildSummarySlide(Map<String, dynamic> slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildHeaderAnkh(slide['title'], slide['subtitle']),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: goldPrimary.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: bgDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: goldPrimary.withOpacity(0.4)),
                      ),
                      child: Text(
                        slide['badge'] ?? '𓋹 Égypte 𓋹',
                        style: const TextStyle(
                          color: goldLight,
                          fontSize: 12,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '𓆣',
                      style: TextStyle(color: goldPrimary, fontSize: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide['description'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textLight,
                        fontSize: 15,
                        fontFamily: 'serif',
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 1, color: goldPrimary.withOpacity(0.4)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('𓂀', style: TextStyle(color: goldPrimary, fontSize: 18)),
                        ),
                        Container(width: 40, height: 1, color: goldPrimary.withOpacity(0.4)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHeaderAnkh(String title, String? subtitle) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 30, height: 1.5, color: goldPrimary.withOpacity(0.7)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                '𓋹',
                style: TextStyle(color: goldPrimary, fontSize: 26),
              ),
            ),
            Container(width: 30, height: 1.5, color: goldPrimary.withOpacity(0.7)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textLight,
            fontSize: 21,
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textMuted,
              fontSize: 13,
              fontFamily: 'serif',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHieroglyphColumn() {
    const symbols = ['𓋹', '𓏛', '𓁹', '𓀔', '𓃭', '𓄿', '𓆣', '𓎟'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: symbols.map((s) {
        return Text(
          s,
          style: TextStyle(
            color: goldPrimary.withOpacity(0.18),
            fontSize: 15,
          ),
        );
      }).toList(),
    );
  }
}