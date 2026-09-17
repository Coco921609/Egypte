import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accueil.dart';

// ==========================================
// 1. THEME & DESIGN SYSTEM ÉGYPTIEN
// ==========================================
class BubbleTheme {
  static const Color background = Color(0xFF0E131F); // Nuit profonde du désert
  static const Color cardDark = Color(0xFF182236); // Bleu Lapis-Lazuli royal
  static const Color cardBorder = Color(0xFF2D3B56); // Bordure dorée/bleutée subtile
  static const Color primaryGradientStart = Color(0xFFE5C158); // Or Pharaonique
  static const Color primaryGradientEnd = Color(0xFFC29B38); // Or Ancien / Cuivré
  static const Color accentGold = Color(0xFFFFD700); // Or éclatant
  static const Color textLight = Color(0xFFFDF8E2); // Sable clair / Papyrus
  static const Color textMuted = Color(0xFFB5A88F); // Sable grisé

  static const Color coral = Color(0xFFD9534F); // Terre cuite
  static const Color yellow = Color(0xFFF0AD4E); // Sable chaud
  static const Color teal = Color(0xFF0288D1); // Bleu Nil
}

final Map<String, List<Map<String, dynamic>>> localizedLanguagesData = {
  'fr': [
    {
      'code': 'fr',
      'name': 'Français',
      'question': 'Quelle langue souhaitez-vous utiliser ?',
      'color': BubbleTheme.coral,
      'icon': Icons.language_rounded,
    },
    {
      'code': 'en',
      'name': 'Anglais',
      'question': 'Quelle langue souhaitez-vous utiliser ?',
      'color': BubbleTheme.yellow,
      'icon': Icons.public_rounded,
    },
    {
      'code': 'ar',
      'name': 'Arabe',
      'question': 'Quelle langue souhaitez-vous utiliser ?',
      'color': BubbleTheme.teal,
      'icon': Icons.translate_rounded,
    },
  ],
  'en': [
    {
      'code': 'fr',
      'name': 'French',
      'question': 'Which language would you like to use ?',
      'color': BubbleTheme.coral,
      'icon': Icons.language_rounded,
    },
    {
      'code': 'en',
      'name': 'English',
      'question': 'Which language would you like to use ?',
      'color': BubbleTheme.yellow,
      'icon': Icons.public_rounded,
    },
    {
      'code': 'ar',
      'name': 'Arabic',
      'question': 'Which language would you like to use ?',
      'color': BubbleTheme.teal,
      'icon': Icons.translate_rounded,
    },
  ],
  'ar': [
    {
      'code': 'fr',
      'name': 'الفرنسية',
      'question': 'ما هي اللغة التي ترغب في استخدامها ؟',
      'color': BubbleTheme.coral,
      'icon': Icons.language_rounded,
    },
    {
      'code': 'en',
      'name': 'الإنجليزية',
      'question': 'ما هي اللغة التي ترغب في استخدامها ؟',
      'color': BubbleTheme.yellow,
      'icon': Icons.public_rounded,
    },
    {
      'code': 'ar',
      'name': 'العربية',
      'question': 'ما هي اللغة التي ترغب في استخدامها ؟',
      'color': BubbleTheme.teal,
      'icon': Icons.translate_rounded,
    },
  ],
};

final Map<String, List<Map<String, String>>> localizedSlides = {
  'fr': [
    {
      "tag": "01. MYSTÈRES",
      "title": "Saviez-vous ?",
      "highlight": "Terres des Pharaons",
      "description": "L'Égypte ancienne abrite des monuments colossaux et des secrets millénaires encore inexplorés.",
      "icon": "compass"
    },
    {
      "tag": "02. ÉVASION",
      "title": "Le Nil majestueux !",
      "highlight": "Dépaysement total",
      "description": "De Gizeh à Louxor : naviguez sur le fleuve sacré au cœur de paysages intemporels.",
      "icon": "landscape"
    },
    {
      "tag": "03. INSOLITE",
      "title": "Trésors sacrés !",
      "highlight": "Merveilles antiques",
      "description": "Partez à la découverte des vallées secrètes, des temples sublimes et des hiéroglyphes mystiques.",
      "icon": "stars"
    },
    {
      "tag": "04. EXPLORATION",
      "title": "Prêt pour l'aventure ?",
      "highlight": "Terre de légende",
      "description": "Découvrez le Pays des Pyramides sous un tout autre angle dès maintenant.",
      "icon": "explore"
    },
  ],
  'en': [
    {
      "tag": "01. MYSTERIES",
      "title": "Did you know ?",
      "highlight": "Land of the Pharaohs",
      "description": "Ancient Egypt holds colossal monuments and millennia-old secrets yet to be fully explored.",
      "icon": "compass"
    },
    {
      "tag": "02. GETAWAY",
      "title": "The majestic Nile !",
      "highlight": "Total escape",
      "description": "From Giza to Luxor: sail along the sacred river through timeless landscapes.",
      "icon": "landscape"
    },
    {
      "tag": "03. UNUSUAL",
      "title": "Sacred treasures !",
      "highlight": "Ancient wonders",
      "description": "Explore secret valleys, magnificent temples, and mystical hieroglyphs.",
      "icon": "stars"
    },
    {
      "tag": "04. EXPLORATION",
      "title": "Ready for adventure ?",
      "highlight": "Land of legends",
      "description": "Discover the Land of the Pyramids from a whole new angle right now.",
      "icon": "explore"
    },
  ],
  'ar': [
    {
      "tag": "01. أسرار",
      "title": "هل تعلم ؟",
      "highlight": "أرض الفراعنة",
      "description": "تحتضن مصر القديمة معالم ضخمة وأسرارًا تعود لآلاف السنين لم يتم اكتشافها بالكامل بعد.",
      "icon": "compass"
    },
    {
      "tag": "02. هروب",
      "title": "النيل العظيم !",
      "highlight": "تغيير جو كامل",
      "description": "من الجيزة إلى الأقصر: أبحر في النهر المقدس وسط مناظر طبيعية خالدة.",
      "icon": "landscape"
    },
    {
      "tag": "03. غريب",
      "title": "كنوز مقدسة !",
      "highlight": "عجائب أثرية",
      "description": "انطلق لاستكشاف الوديان السرية والمعابد الرائعة والرموز الهيروغليفية الغامضة.",
      "icon": "stars"
    },
    {
      "tag": "04. استكشاف",
      "title": "مستعد للمغامرة ؟",
      "highlight": "أرض الأساطير",
      "description": "اكتشف أرض الأهرامات من منظور آخر تماماً ابتداءً من الآن.",
      "icon": "explore"
    },
  ],
};

final Map<String, Map<String, String>> localizedUi = {
  'fr': {
    'welcome': 'Bienvenue !',
    'validate': 'Valider',
    'next': 'Continuer',
    'finish': 'Créer mon profil',
    'country': 'Égypte',
  },
  'en': {
    'welcome': 'Welcome !',
    'validate': 'Validate',
    'next': 'Continue',
    'finish': 'Create my profile',
    'country': 'Egypt',
  },
  'ar': {
    'welcome': 'مرحبًا !',
    'validate': 'تأكيد',
    'next': 'متابعة',
    'finish': 'إنشاء ملفي الشخصي',
    'country': 'مصر',
  },
};

// ==========================================
// 2. PAINTER PYRAMIDE (STYLE ÉGYPTIEN)
// ==========================================
class PyramidPainter extends CustomPainter {
  final Color color;
  PyramidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 3. PAGE CHOIX DES LANGUES
// ==========================================
class LanguesPage extends StatefulWidget {
  final bool isProfileCreated;

  const LanguesPage({super.key, required this.isProfileCreated});

  @override
  State<LanguesPage> createState() => _LanguesPageState();
}

class _LanguesPageState extends State<LanguesPage> {
  String _selectedCode = 'fr';

  void _confirmSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PresentationScreen(languageCode: _selectedCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguagesList = localizedLanguagesData[_selectedCode] ?? localizedLanguagesData['fr']!;
    final selectedLangItem = currentLanguagesList.firstWhere(
          (element) => element['code'] == _selectedCode,
      orElse: () => currentLanguagesList.first,
    );
    final String currentQuestion = selectedLangItem['question'] ?? '';

    final uiText = localizedUi[_selectedCode] ?? localizedUi['fr'] ?? {};
    final String welcomeMessage = uiText['welcome'] ?? 'Bienvenue !';
    final String validateText = uiText['validate'] ?? 'Valider';

    return Directionality(
      textDirection: _selectedCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: BubbleTheme.background,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -120,
                left: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        BubbleTheme.primaryGradientStart.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: SizedBox(
                      height: 70,
                      child: Text(
                        currentQuestion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: BubbleTheme.textLight,
                          height: 1.3,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: currentLanguagesList.map((item) {
                            final String code = item['code'] ?? 'fr';
                            final String name = item['name'] ?? '';
                            final Color color = item['color'] ?? BubbleTheme.coral;
                            final IconData icon = item['icon'] ?? Icons.language;
                            final bool isSelected = (code == _selectedCode);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () {
                                  setState(() {
                                    _selectedCode = code;
                                  });
                                },
                                child: Container(
                                  height: 78,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  decoration: BoxDecoration(
                                    color: isSelected ? color.withOpacity(0.14) : BubbleTheme.cardDark,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isSelected ? color : BubbleTheme.cardBorder,
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? color.withOpacity(0.25) : Colors.white.withOpacity(0.04),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: isSelected ? color : Colors.white60,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? color : Colors.white24,
                                            width: 2,
                                          ),
                                          color: isSelected ? color : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: BubbleTheme.cardDark,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: BubbleTheme.primaryGradientStart.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              welcomeMessage,
                              style: const TextStyle(
                                color: BubbleTheme.textLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              selectedLangItem['name'] ?? '',
                              style: TextStyle(
                                color: selectedLangItem['color'] ?? BubbleTheme.accentGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [BubbleTheme.primaryGradientStart, BubbleTheme.primaryGradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: BubbleTheme.primaryGradientEnd.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          onPressed: _confirmSelection,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                validateText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _selectedCode == 'ar' ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
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
  }
}

// ==========================================
// 4. PAGE PRESENTATION (ONBOARDING)
// ==========================================
class PresentationScreen extends StatefulWidget {
  final String languageCode;
  const PresentationScreen({super.key, this.languageCode = 'fr'});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getSlideIcon(String? iconType) {
    switch (iconType) {
      case 'compass':
        return Icons.explore_rounded;
      case 'landscape':
        return Icons.landscape_rounded;
      case 'stars':
        return Icons.auto_awesome_rounded;
      case 'explore':
        return Icons.travel_explore_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(languageCode: widget.languageCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slides = localizedSlides[widget.languageCode] ?? localizedSlides['fr'] ?? [];
    final uiText = localizedUi[widget.languageCode] ?? localizedUi['fr'] ?? {};
    final isRtl = widget.languageCode == 'ar';

    final String nextLabel = uiText['next'] ?? 'Continuer';
    final String finishLabel = uiText['finish'] ?? 'Créer mon profil';
    final String countryLabel = uiText['country'] ?? 'Égypte';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: BubbleTheme.background,
        body: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BubbleTheme.primaryGradientStart.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 14,
                              child: CustomPaint(
                                painter: PyramidPainter(color: BubbleTheme.accentGold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              countryLabel,
                              style: const TextStyle(
                                color: BubbleTheme.textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
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

                        final tag = slide["tag"] ?? '';
                        final title = slide["title"] ?? '';
                        final highlight = slide["highlight"] ?? '';
                        final description = slide["description"] ?? '';
                        final iconType = slide["icon"];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          BubbleTheme.primaryGradientEnd.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 92,
                                    height: 92,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          BubbleTheme.primaryGradientStart,
                                          BubbleTheme.primaryGradientEnd,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: BubbleTheme.primaryGradientStart.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getSlideIcon(iconType),
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 36),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                                decoration: BoxDecoration(
                                  color: BubbleTheme.cardDark,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: BubbleTheme.cardBorder,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: BubbleTheme.primaryGradientStart.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: BubbleTheme.primaryGradientStart.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: BubbleTheme.primaryGradientStart,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: BubbleTheme.textLight,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      highlight,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: BubbleTheme.accentGold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      description,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: BubbleTheme.textMuted,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            slides.length,
                                (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentIndex == index ? 28 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? BubbleTheme.primaryGradientEnd
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                BubbleTheme.primaryGradientStart,
                                BubbleTheme.primaryGradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: BubbleTheme.primaryGradientEnd.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () {
                              if (_currentIndex == slides.length - 1) {
                                _finishOnboarding();
                              } else {
                                _controller.jumpToPage(_currentIndex + 1);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentIndex == slides.length - 1 ? finishLabel : nextLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. PAGE DE PROFIL ULTRA DESIGN & PRO
// ==========================================
class ProfileScreen extends StatefulWidget {
  final String languageCode;
  const ProfileScreen({super.key, this.languageCode = 'fr'});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

  String _selectedGenre = 'Homme';
  Color _selectedThemeColor = const Color(0xFFE5C158);
  late String _selectedAvatar;
  late String _currentLang;

  bool _hasNameError = false;
  late AnimationController _orbitController;

  final List<Color> _themeColors = [
    const Color(0xFFE5C158), // Or Pharaonique
    const Color(0xFFC29B38), // Cuivré
    const Color(0xFF0288D1), // Bleu Nil
    const Color(0xFFD9534F), // Terre cuite
    const Color(0xFF2E7D32), // Vert Oasis
    const Color(0xFF7B1FA2), // Améthyste Royale
  ];

  final List<String> _avatarsHommes = [
    '👨🏽', '🧔🏽‍♂️', '👨🏽‍🦱', '👨🏽‍🦰', '👨🏽‍🦳', '👨🏼', '🧔🏼‍♂️', '👨🏼‍🦱', '👨🏼‍🦰', '👨🏼‍🦳', '👨🏽‍🦲', '👨🏼‍🦲',
  ];

  final List<String> _avatarsFemmes = [
    '👩🏽', '👩🏽‍🦱', '👩🏽‍🦰', '👩🏽‍🦳', '👩🏼', '👩🏼‍🦱', '👩🏼‍🦰', '👩🏼‍🦳', '👩🏽‍🦲', '👩🏼‍🦲', '🧕🏽', '🧕🏼',
  ];

  final Map<String, Map<String, String>> _localizedText = {
    'fr': {
      'title': 'Créez votre profil',
      'subtitle': 'Personnalisez votre expérience au pays des pharaons',
      'nameLabel': 'Nom et prénom',
      'nameHint': 'Entrez votre nom complet',
      'genreLabel': 'Sélectionnez votre genre',
      'genreMan': 'Homme',
      'genreWoman': 'Femme',
      'themeLabel': 'Couleur du thème',
      'langLabel': 'Langue de l\'application',
      'avatarLabel': 'Choisissez votre avatar',
      'button': 'Découvrir l\'Égypte',
      'langFr': 'Français',
      'langEn': 'Anglais',
      'langAr': 'Arabe',
    },
    'en': {
      'title': 'Create your profile',
      'subtitle': 'Customize your experience in the land of pharaohs',
      'nameLabel': 'Full Name',
      'nameHint': 'Enter your full name',
      'genreLabel': 'Select your gender',
      'genreMan': 'Male',
      'genreWoman': 'Female',
      'themeLabel': 'Theme color',
      'langLabel': 'App language',
      'avatarLabel': 'Choose your avatar',
      'button': 'Discover Egypt',
      'langFr': 'French',
      'langEn': 'English',
      'langAr': 'Arabic',
    },
    'ar': {
      'title': 'أنشئ ملفك الشخصي',
      'subtitle': 'خصص تجربتك في أرض الفراعنة',
      'nameLabel': 'الاسم واللقب',
      'nameHint': 'أدخل اسمك الكامل',
      'genreLabel': 'حدد جنسك',
      'genreMan': 'رجل',
      'genreWoman': 'امرأة',
      'themeLabel': 'لون المظهر',
      'langLabel': 'لغة التطبيق',
      'avatarLabel': 'اختر صورتك الرمزية',
      'button': 'اكتشف مصر',
      'langFr': 'الفرنسية',
      'langEn': 'الإنجليزية',
      'langAr': 'العربية',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentLang = widget.languageCode;
    _selectedAvatar = _avatarsHommes[0];
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  void _validateAndSave() async {
    final bool nameEmpty = _nameController.text.trim().isEmpty;

    if (nameEmpty) {
      setState(() {
        _hasNameError = true;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_gender', _selectedGenre);
    await prefs.setInt('user_theme_color', _selectedThemeColor.value);
    await prefs.setString('user_lang', _currentLang);
    await prefs.setString('user_avatar', _selectedAvatar);
    await prefs.setBool('is_profile_created', true);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AccueilScreen(
          userName: _nameController.text.trim(),
          languageCode: _currentLang,
          selectedAvatar: _selectedAvatar,
          themeColor: _selectedThemeColor,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _localizedText[_currentLang] ?? _localizedText['fr']!;
    final isRtl = _currentLang == 'ar';
    final currentAvatars = (_selectedGenre == 'Homme' || _selectedGenre == 'Man' || _selectedGenre == 'رجل')
        ? _avatarsHommes
        : _avatarsFemmes;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: BubbleTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        t['title']!,
                        style: const TextStyle(
                          color: BubbleTheme.textLight,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t['subtitle']!,
                        style: const TextStyle(
                          color: BubbleTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  t['nameLabel']!,
                  style: const TextStyle(color: BubbleTheme.textLight, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: BubbleTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasNameError ? BubbleTheme.coral : BubbleTheme.cardBorder,
                      width: _hasNameError ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    onChanged: (val) {
                      if (_hasNameError && val.trim().isNotEmpty) {
                        setState(() {
                          _hasNameError = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: BubbleTheme.textMuted, size: 20),
                      hintText: t['nameHint'],
                      hintStyle: TextStyle(
                        color: _hasNameError ? BubbleTheme.coral.withOpacity(0.8) : BubbleTheme.textMuted.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                Text(
                  t['genreLabel']!,
                  style: const TextStyle(color: BubbleTheme.textLight, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenreButton(
                        label: t['genreMan']!,
                        icon: Icons.male_rounded,
                        isSelected: _selectedGenre == 'Homme' || _selectedGenre == 'Man' || _selectedGenre == 'رجل',
                        onTap: () {
                          setState(() {
                            _selectedGenre = t['genreMan']!;
                            _selectedAvatar = _avatarsHommes[0];
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenreButton(
                        label: t['genreWoman']!,
                        icon: Icons.female_rounded,
                        isSelected: _selectedGenre == 'Femme' || _selectedGenre == 'Woman' || _selectedGenre == 'امرأة',
                        onTap: () {
                          setState(() {
                            _selectedGenre = t['genreWoman']!;
                            _selectedAvatar = _avatarsFemmes[0];
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                Text(
                  t['themeLabel']!,
                  style: const TextStyle(color: BubbleTheme.textLight, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _themeColors.map((color) {
                    final isSelected = _selectedThemeColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedThemeColor = color;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ]
                              : [],
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 22) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                Text(
                  t['avatarLabel']!,
                  style: const TextStyle(color: BubbleTheme.textLight, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: 210,
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                _selectedThemeColor,
                                _selectedThemeColor.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _selectedThemeColor.withOpacity(0.45),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BubbleTheme.cardDark,
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                _selectedAvatar,
                                style: const TextStyle(fontSize: 46),
                              ),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _orbitController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(210, 210),
                              painter: OrbitPainter(
                                progress: _orbitController.value,
                                avatars: currentAvatars,
                                selectedAvatar: _selectedAvatar,
                                themeColor: _selectedThemeColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentAvatars.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final avatar = currentAvatars[index];
                    final isSelected = avatar == _selectedAvatar;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedThemeColor.withOpacity(0.2)
                              : BubbleTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? _selectedThemeColor : BubbleTheme.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: _selectedThemeColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            avatar,
                            style: TextStyle(
                              fontSize: isSelected ? 23 : 19,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  t['langLabel']!,
                  style: const TextStyle(color: BubbleTheme.textLight, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildLangButton('fr', t['langFr']!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLangButton('en', t['langEn']!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLangButton('ar', t['langAr']!),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _selectedThemeColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedThemeColor.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _validateAndSave,
                    child: Text(
                      t['button']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _selectedThemeColor.withOpacity(0.18) : BubbleTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedThemeColor : BubbleTheme.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _selectedThemeColor.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : BubbleTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : BubbleTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String code, String label) {
    final isSelected = _currentLang == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentLang = code;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _selectedThemeColor.withOpacity(0.18) : BubbleTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedThemeColor : BubbleTheme.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : BubbleTheme.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. CUSTOM PAINTER POUR L'ORBITE DES EMOJIS
// ==========================================
class OrbitPainter extends CustomPainter {
  final double progress;
  final List<String> avatars;
  final String selectedAvatar;
  final Color themeColor;

  OrbitPainter({
    required this.progress,
    required this.avatars,
    required this.selectedAvatar,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 85.0;

    final paintRing = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, paintRing);

    final count = avatars.length;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * 3.1415926535 / count) + (progress * 2 * 3.1415926535);
      final x = center.dx + radius * mathCos(angle);
      final y = center.dy + radius * mathSin(angle);

      final avatar = avatars[i];
      final isSelected = (avatar == selectedAvatar);

      final bgPaint = Paint()
        ..color = isSelected ? themeColor.withOpacity(0.3) : BubbleTheme.cardDark
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isSelected ? themeColor : Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.0 : 1.0;

      const itemRadius = 18.0;
      canvas.drawCircle(Offset(x, y), itemRadius, bgPaint);
      canvas.drawCircle(Offset(x, y), itemRadius, borderPaint);

      final textSpan = TextSpan(
        text: avatar,
        style: TextStyle(fontSize: isSelected ? 18 : 15),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  double mathCos(double val) => math.cos(val);
  double mathSin(double val) => math.sin(val);

  @override
  bool shouldRepaint(covariant OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedAvatar != selectedAvatar ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.avatars != avatars;
  }
}

// ==========================================
// 7. PAGE D'IDÉES (IDEESPAGE)
// ==========================================
class IdeesPage extends StatelessWidget {
  final String languageCode;
  final Color themeColor;

  const IdeesPage({
    super.key,
    required this.languageCode,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = languageCode == 'ar';
    final Map<String, String> titles = {
      'fr': 'Idées de voyage',
      'en': 'Travel Ideas',
      'ar': 'أفكار السفر',
    };

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: BubbleTheme.background,
        appBar: AppBar(
          backgroundColor: BubbleTheme.cardDark,
          elevation: 0,
          title: Text(
            titles[languageCode] ?? titles['fr']!,
            style: const TextStyle(
              color: BubbleTheme.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: BubbleTheme.textLight),
        ),
        body: InkWell(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final String userName = prefs.getString('user_name') ?? '';
            final String avatar = prefs.getString('user_avatar') ?? '👨🏽';

            if (!context.mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AccueilScreen(
                  userName: userName,
                  languageCode: languageCode,
                  selectedAvatar: avatar,
                  themeColor: themeColor,
                ),
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_rounded,
                  size: 64,
                  color: themeColor,
                ),
                const SizedBox(height: 16),
                Text(
                  titles[languageCode] ?? titles['fr']!,
                  style: const TextStyle(
                    color: BubbleTheme.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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

// ==========================================
// 8. ÉCRAN ACCUEIL (ACCUEILSCREEN CORRIGÉ & COMPLET)
// ==========================================
class AccueilScreen extends StatelessWidget {
  final String userName;
  final String languageCode;
  final String selectedAvatar;
  final Color themeColor;

  const AccueilScreen({
    super.key,
    required this.userName,
    required this.languageCode,
    required this.selectedAvatar,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccueilPage(
        userName: userName,
        languageCode: languageCode,
        selectedAvatar: selectedAvatar,
        themeColor: themeColor,
      ),
    );
  }
}