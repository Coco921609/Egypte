import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accueil.dart';
import 'presentation.dart';

// L'écran de présentation vit maintenant dans presentation.dart.
// Cet export évite de casser les fichiers qui importaient PresentationScreen via profil.dart.
export 'presentation.dart';

// ==========================================
// 1. THEME & DESIGN SYSTEM
// ==========================================
class BubbleTheme {
  static const Color background = Color(0xFF0E131F);
  static const Color night = Color(0xFF0B0D12);
  static const Color cardDark = Color(0xFF182236);
  static const Color cardBorder = Color(0xFF2D3B56);
  static const Color primaryGradientStart = Color(0xFFE5C158);
  static const Color primaryGradientEnd = Color(0xFFC29B38);
  static const Color accentGold = Color(0xFFE9C46A);
  static const Color textLight = Color(0xFFF6EFE0);
  static const Color textMuted = Color(0xFFB9BFCC);

  static const Color coral = Color(0xFFD9534F);
  static const Color yellow = Color(0xFFF0AD4E);
  static const Color teal = Color(0xFF0288D1);
}

final Map<String, List<Map<String, dynamic>>> localizedLanguagesData = {
  'fr': [
    {'code': 'fr', 'name': 'Français', 'question': 'Quelle langue souhaitez-vous utiliser ?', 'color': BubbleTheme.coral, 'icon': Icons.language_rounded},
    {'code': 'en', 'name': 'Anglais', 'question': 'Quelle langue souhaitez-vous utiliser ?', 'color': BubbleTheme.yellow, 'icon': Icons.public_rounded},
    {'code': 'ar', 'name': 'Arabe', 'question': 'Quelle langue souhaitez-vous utiliser ?', 'color': BubbleTheme.teal, 'icon': Icons.translate_rounded},
  ],
  'en': [
    {'code': 'fr', 'name': 'French', 'question': 'Which language would you like to use ?', 'color': BubbleTheme.coral, 'icon': Icons.language_rounded},
    {'code': 'en', 'name': 'English', 'question': 'Which language would you like to use ?', 'color': BubbleTheme.yellow, 'icon': Icons.public_rounded},
    {'code': 'ar', 'name': 'Arabic', 'question': 'Which language would you like to use ?', 'color': BubbleTheme.teal, 'icon': Icons.translate_rounded},
  ],
  'ar': [
    {'code': 'fr', 'name': 'الفرنسية', 'question': 'ما هي اللغة التي ترغب في استخدامها ؟', 'color': BubbleTheme.coral, 'icon': Icons.language_rounded},
    {'code': 'en', 'name': 'الإنجليزية', 'question': 'ما هي اللغة التي ترغب في استخدامها ؟', 'color': BubbleTheme.yellow, 'icon': Icons.public_rounded},
    {'code': 'ar', 'name': 'العربية', 'question': 'ما هي اللغة التي ترغب في استخدامها ؟', 'color': BubbleTheme.teal, 'icon': Icons.translate_rounded},
  ],
};

final Map<String, Map<String, String>> localizedUi = {
  'fr': {'welcome': 'Bienvenue !', 'validate': 'Valider', 'next': 'Continuer', 'finish': 'Créer mon profil', 'country': 'Égypte'},
  'en': {'welcome': 'Welcome !', 'validate': 'Validate', 'next': 'Continue', 'finish': 'Create my profile', 'country': 'Egypt'},
  'ar': {'welcome': 'مرحبًا !', 'validate': 'تأكيد', 'next': 'متابعة', 'finish': 'إنشاء ملفي الشخصي', 'country': 'مصر'},
};

// ==========================================
// 2. PETITS COMPOSANTS PARTAGÉS
// ==========================================

class PyramidPainter extends CustomPainter {
  final Color color;
  PyramidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Verre dépoli.
class _GlassBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? fill;
  final Color? borderColor;
  final double borderWidth;

  const _GlassBox({
    required this.child,
    this.radius = 20,
    this.padding = const EdgeInsets.all(16),
    this.fill,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: fill ?? Colors.white.withOpacity(0.07),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.14),
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Apparition : fondu + glissement.
class _Reveal extends StatelessWidget {
  final Widget child;
  final int delay;
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
        child: Transform.translate(offset: Offset(0, 22 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

Color _darken(Color c, [double amount = 0.12]) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Color _onColor(Color c) =>
    c.computeLuminance() > 0.45 ? BubbleTheme.night : Colors.white;

/// Bouton principal en pilule avec flèche.
class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isRtl;
  final Color color;

  const _PillButton({
    required this.label,
    required this.onTap,
    required this.isRtl,
    this.color = BubbleTheme.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    final on = _onColor(color);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 58,
        width: double.infinity,
        padding: const EdgeInsetsDirectional.only(start: 26, end: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          gradient: LinearGradient(colors: [color, _darken(color)]),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: on,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: on, shape: BoxShape.circle),
              child: Icon(
                isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                color: color,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contrôle segmenté avec curseur animé.
class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color color;

  const _Segmented({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    final x = n == 1 ? 0.0 : -1 + 2 * selectedIndex / (n - 1);
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: AlignmentDirectional(x, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.35), blurRadius: 10),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(n, (i) {
              final selected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: selected ? _onColor(color) : BubbleTheme.textMuted,
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      child: Text(labels[i]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
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

  static const Map<String, String> _monograms = {'fr': 'FR', 'en': 'EN', 'ar': 'ع'};

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
    final list = localizedLanguagesData[_selectedCode] ?? localizedLanguagesData['fr']!;
    final selectedItem = list.firstWhere(
          (e) => e['code'] == _selectedCode,
      orElse: () => list.first,
    );
    final question = selectedItem['question'] as String? ?? '';
    final ui = localizedUi[_selectedCode] ?? localizedUi['fr']!;
    final isRtl = _selectedCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: BubbleTheme.night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/3.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: BubbleTheme.night),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    BubbleTheme.night.withOpacity(0.55),
                    BubbleTheme.night.withOpacity(0.35),
                    BubbleTheme.night.withOpacity(0.88),
                    BubbleTheme.night.withOpacity(0.98),
                  ],
                  stops: const [0.0, 0.3, 0.65, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 16,
                          child: CustomPaint(
                            painter: PyramidPainter(color: BubbleTheme.accentGold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          (ui['country'] ?? '').toUpperCase(),
                          style: const TextStyle(
                            color: BubbleTheme.textLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) => SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: c.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _Reveal(
                                child: Text(
                                  ui['welcome'] ?? '',
                                  style: const TextStyle(
                                    color: BubbleTheme.accentGold,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _Reveal(
                                delay: 100,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Text(
                                    question,
                                    key: ValueKey(question),
                                    style: const TextStyle(
                                      color: BubbleTheme.textLight,
                                      fontSize: 32,
                                      height: 1.2,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              ...List.generate(list.length, (i) {
                                final item = list[i];
                                final code = item['code'] as String? ?? 'fr';
                                final color = item['color'] as Color? ?? BubbleTheme.coral;
                                final selected = code == _selectedCode;
                                return _Reveal(
                                  delay: 200 + i * 90,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _selectedCode = code);
                                      },
                                      child: _GlassBox(
                                        radius: 22,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        fill: selected
                                            ? BubbleTheme.accentGold.withOpacity(0.14)
                                            : Colors.white.withOpacity(0.07),
                                        borderColor: selected
                                            ? BubbleTheme.accentGold
                                            : Colors.white.withOpacity(0.14),
                                        borderWidth: selected ? 1.6 : 1,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 46,
                                              height: 46,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color.withOpacity(0.22),
                                              ),
                                              child: Text(
                                                _monograms[code] ?? code.toUpperCase(),
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                item['name'] as String? ?? '',
                                                style: TextStyle(
                                                  color: BubbleTheme.textLight,
                                                  fontSize: 18,
                                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 250),
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: selected ? BubbleTheme.accentGold : Colors.transparent,
                                                border: Border.all(
                                                  color: selected ? BubbleTheme.accentGold : Colors.white30,
                                                  width: 2,
                                                ),
                                              ),
                                              child: selected
                                                  ? const Icon(Icons.check_rounded, size: 16, color: BubbleTheme.night)
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: _PillButton(
                      label: ui['validate'] ?? 'Valider',
                      isRtl: isRtl,
                      onTap: _confirmSelection,
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
// 4. PAGE DE PROFIL
// ==========================================
class ProfileScreen extends StatefulWidget {
  final String languageCode;
  const ProfileScreen({super.key, this.languageCode = 'fr'});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool _isMale = true;
  Color _selectedThemeColor = const Color(0xFFE5C158);
  late String _selectedAvatar;
  late String _currentLang;
  bool _hasNameError = false;

  final List<Color> _themeColors = const [
    Color(0xFFE5C158), // Or pharaonique
    Color(0xFFC29B38), // Cuivré
    Color(0xFF0288D1), // Bleu Nil
    Color(0xFFD9534F), // Terre cuite
    Color(0xFF2E7D32), // Vert oasis
    Color(0xFF7B1FA2), // Améthyste
  ];

  final List<String> _avatarsHommes = const [
    '👨🏽', '🧔🏽‍♂️', '👨🏽‍🦱', '👨🏽‍🦰', '👨🏽‍🦳', '👨🏼', '🧔🏼‍♂️', '👨🏼‍🦱', '👨🏼‍🦰', '👨🏼‍🦳', '👨🏽‍🦲', '👨🏼‍🦲',
  ];

  final List<String> _avatarsFemmes = const [
    '👩🏽', '👩🏽‍🦱', '👩🏽‍🦰', '👩🏽‍🦳', '👩🏼', '👩🏼‍🦱', '👩🏼‍🦰', '👩🏼‍🦳', '👩🏽‍🦲', '👩🏼‍🦲', '🧕🏽', '🧕🏼',
  ];

  final Map<String, Map<String, String>> _localizedText = {
    'fr': {
      'title': 'Créez votre profil',
      'subtitle': 'Personnalisez votre expérience au pays des pharaons',
      'nameLabel': 'Nom et prénom',
      'nameHint': 'Entrez votre nom complet',
      'nameError': 'Veuillez entrer votre nom',
      'genreLabel': 'Genre',
      'genreMan': 'Homme',
      'genreWoman': 'Femme',
      'themeLabel': 'Couleur du thème',
      'langLabel': 'Langue de l\'application',
      'avatarLabel': 'Avatar',
      'button': 'Découvrir l\'Égypte',
      'langFr': 'Français',
      'langEn': 'Anglais',
      'langAr': 'Arabe',
    },
    'en': {
      'title': 'Create your profile',
      'subtitle': 'Customize your experience in the land of pharaohs',
      'nameLabel': 'Full name',
      'nameHint': 'Enter your full name',
      'nameError': 'Please enter your name',
      'genreLabel': 'Gender',
      'genreMan': 'Male',
      'genreWoman': 'Female',
      'themeLabel': 'Theme color',
      'langLabel': 'App language',
      'avatarLabel': 'Avatar',
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
      'nameError': 'الرجاء إدخال اسمك',
      'genreLabel': 'الجنس',
      'genreMan': 'رجل',
      'genreWoman': 'امرأة',
      'themeLabel': 'لون المظهر',
      'langLabel': 'لغة التطبيق',
      'avatarLabel': 'الصورة الرمزية',
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _hasNameError = true);
      return;
    }

    final t = _localizedText[_currentLang] ?? _localizedText['fr']!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_gender', _isMale ? t['genreMan']! : t['genreWoman']!);
    await prefs.setInt('user_theme_color', _selectedThemeColor.value);
    await prefs.setString('user_lang', _currentLang);
    await prefs.setString('user_avatar', _selectedAvatar);
    await prefs.setBool('is_profile_created', true);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AccueilScreen(
          userName: name,
          languageCode: _currentLang,
          selectedAvatar: _selectedAvatar,
          themeColor: _selectedThemeColor,
        ),
      ),
          (route) => false,
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: BubbleTheme.textMuted.withOpacity(0.9),
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = _localizedText[_currentLang] ?? _localizedText['fr']!;
    final isRtl = _currentLang == 'ar';
    final avatars = _isMale ? _avatarsHommes : _avatarsFemmes;
    final theme = _selectedThemeColor;
    final name = _nameController.text.trim();

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: BubbleTheme.night,
        body: Stack(
          children: [
            // Lueur colorée selon le thème choisi
            Positioned(
              top: -140,
              left: -100,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [theme.withOpacity(0.32), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -160,
              right: -120,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [theme.withOpacity(0.16), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Reveal(
                            child: Text(
                              t['title']!,
                              style: const TextStyle(
                                color: BubbleTheme.textLight,
                                fontSize: 32,
                                height: 1.15,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Reveal(
                            delay: 80,
                            child: Text(
                              t['subtitle']!,
                              style: const TextStyle(
                                color: BubbleTheme.textMuted,
                                fontSize: 14.5,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Aperçu + choix d'avatar ──
                          _Reveal(
                            delay: 160,
                            child: _GlassBox(
                              radius: 28,
                              padding: const EdgeInsets.fromLTRB(0, 24, 0, 18),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 118,
                                      height: 118,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [theme, _darken(theme, 0.25)],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.withOpacity(0.45),
                                            blurRadius: 28,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: BubbleTheme.cardDark,
                                        ),
                                        alignment: Alignment.center,
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 250),
                                          transitionBuilder: (child, anim) =>
                                              ScaleTransition(scale: anim, child: child),
                                          child: Text(
                                            _selectedAvatar,
                                            key: ValueKey(_selectedAvatar),
                                            style: const TextStyle(fontSize: 58),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      name.isEmpty ? t['nameHint']! : name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: name.isEmpty
                                            ? BubbleTheme.textMuted.withOpacity(0.6)
                                            : BubbleTheme.textLight,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      height: 56,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        itemCount: avatars.length,
                                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                                        itemBuilder: (context, i) {
                                          final a = avatars[i];
                                          final selected = a == _selectedAvatar;
                                          return GestureDetector(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              setState(() => _selectedAvatar = a);
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 220),
                                              curve: Curves.easeOutCubic,
                                              width: 56,
                                              height: 56,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: selected
                                                    ? theme.withOpacity(0.22)
                                                    : Colors.white.withOpacity(0.06),
                                                border: Border.all(
                                                  color: selected ? theme : Colors.white.withOpacity(0.10),
                                                  width: selected ? 2 : 1,
                                                ),
                                              ),
                                              child: Text(a, style: TextStyle(fontSize: selected ? 28 : 24)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // ── Nom ──
                          _label(t['nameLabel']!),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _hasNameError ? BubbleTheme.coral : Colors.white.withOpacity(0.12),
                                width: _hasNameError ? 1.8 : 1,
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              cursorColor: theme,
                              style: const TextStyle(
                                color: BubbleTheme.textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (val) => setState(() {
                                if (_hasNameError && val.trim().isNotEmpty) _hasNameError = false;
                              }),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: _hasNameError ? BubbleTheme.coral : theme,
                                  size: 22,
                                ),
                                hintText: t['nameHint'],
                                hintStyle: TextStyle(
                                  color: BubbleTheme.textMuted.withOpacity(0.55),
                                  fontSize: 15,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: _hasNameError
                                ? Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                              child: Text(
                                t['nameError']!,
                                style: const TextStyle(
                                  color: BubbleTheme.coral,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                                : const SizedBox(width: double.infinity),
                          ),
                          const SizedBox(height: 24),

                          // ── Genre ──
                          _label(t['genreLabel']!),
                          _Segmented(
                            labels: [t['genreMan']!, t['genreWoman']!],
                            selectedIndex: _isMale ? 0 : 1,
                            color: theme,
                            onChanged: (i) => setState(() {
                              _isMale = i == 0;
                              _selectedAvatar = _isMale ? _avatarsHommes[0] : _avatarsFemmes[0];
                            }),
                          ),
                          const SizedBox(height: 24),

                          // ── Couleur ──
                          _label(t['themeLabel']!),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _themeColors.map((color) {
                              final selected = _selectedThemeColor == color;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedThemeColor = color);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected ? Colors.white : Colors.transparent,
                                      width: 2.5,
                                    ),
                                    boxShadow: selected
                                        ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 14, spreadRadius: 1)]
                                        : [],
                                  ),
                                  child: selected
                                      ? Icon(Icons.check_rounded, color: _onColor(color), size: 22)
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // ── Langue ──
                          _label(t['langLabel']!),
                          _Segmented(
                            labels: [t['langFr']!, t['langEn']!, t['langAr']!],
                            selectedIndex: const ['fr', 'en', 'ar'].indexOf(_currentLang),
                            color: theme,
                            onChanged: (i) => setState(() => _currentLang = const ['fr', 'en', 'ar'][i]),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  // Bouton fixe en bas
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [BubbleTheme.night.withOpacity(0), BubbleTheme.night.withOpacity(0.95)],
                      ),
                    ),
                    child: _PillButton(
                      label: t['button']!,
                      color: theme,
                      isRtl: isRtl,
                      onTap: _validateAndSave,
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
// 5. PAGE D'IDÉES
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
    const titles = {
      'fr': 'Idées de voyage',
      'en': 'Travel Ideas',
      'ar': 'أفكار السفر',
    };
    const hints = {
      'fr': 'Touchez pour revenir à l’accueil',
      'en': 'Tap to go back home',
      'ar': 'المس للعودة إلى الرئيسية',
    };
    final title = titles[languageCode] ?? titles['fr']!;
    final hint = hints[languageCode] ?? hints['fr']!;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: BubbleTheme.night,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: BubbleTheme.textLight),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [themeColor.withOpacity(0.30), Colors.transparent],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Reveal(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [themeColor, _darken(themeColor, 0.2)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withOpacity(0.45),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.explore_rounded,
                              size: 56,
                              color: _onColor(themeColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _Reveal(
                          delay: 120,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: BubbleTheme.textLight,
                              fontSize: 30,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Reveal(
                          delay: 220,
                          child: _GlassBox(
                            radius: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app_rounded, size: 16, color: themeColor),
                                const SizedBox(width: 8),
                                Text(
                                  hint,
                                  style: const TextStyle(
                                    color: BubbleTheme.textMuted,
                                    fontSize: 13,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. ÉCRAN ACCUEIL (inchangé)
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