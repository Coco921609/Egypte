import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'accueil.dart';
import 'egypt_design.dart';

// ==========================================
// 1. THÈMES & DESIGN SYSTÈME PHARAONIQUE
// ==========================================
class EgyptTheme {
  static const Color background = Color(0xFF07080E);
  static const Color cardDark = Color(0xFF11131C);
  static const Color cardDarkSecondary = Color(0xFF181A26);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFF3E5AB);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFFA1A5B7);
  static const Color coral = Color(0xFFFF5252);
}

// ==========================================
// 2. REDIRECTION COMPATIBLE ACCUEIL
// ==========================================
class ParametresPage extends StatelessWidget {
  final String languageCode;
  final Color? themeColor;

  const ParametresPage({
    super.key,
    this.languageCode = 'fr',
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ParametresScreen(languageCode: languageCode);
  }
}

// ==========================================
// 3. PAGE DES PARAMÈTRES
// ==========================================
class ParametresScreen extends StatefulWidget {
  final String languageCode;
  const ParametresScreen({super.key, this.languageCode = 'fr'});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final TextEditingController _nameController = TextEditingController();

  String _selectedGenre = 'Homme';
  Color _selectedThemeColor = const Color(0xFFD4AF37);
  String _selectedAvatar = '👨🏽';
  late String _currentLang;
  bool _hasNameError = false;
  bool _isLoading = true;

  final List<Color> _themeColors = [
    const Color(0xFFD4AF37), // Or Pharaonique
    const Color(0xFF38BDF8), // Bleu Nil
    const Color(0xFF10B981), // Vert Oasis
    const Color(0xFFF59E0B), // Ambre Désert
    const Color(0xFFEF4444), // Corail Mer Rouge
    const Color(0xFF8B5CF6), // Violet Mystique
  ];

  final List<String> _avatarsHommes = [
    '👨🏽', '🧔🏽‍♂️', '👨🏽‍🦱', '👨🏽‍🦰', '👨🏽‍🦳', '👨🏼', '🧔🏼‍♂️', '👨🏼‍🦱', '👨🏼‍🦰', '👨🏼‍🦳', '👨🏽‍🦲', '👨🏼‍🦲',
  ];

  final List<String> _avatarsFemmes = [
    '👩🏽', '👩🏽‍🦱', '👩🏽‍🦰', '👩🏽‍🦳', '👩🏼', '👩🏼‍🦱', '👩🏼‍🦰', '👩🏼‍🦳', '👩🏽‍🦲', '👩🏼‍🦲', '🧕🏽', '🧕🏼',
  ];

  final Map<String, Map<String, String>> _localizedText = {
    'fr': {
      'title': 'Paramètres Pharaoniques',
      'subtitle': 'Personnalisez votre voyage en Égypte ancienne',
      'nameLabel': 'Nom et prénom',
      'nameHint': 'Entrez votre nom complet',
      'genreLabel': 'Sélectionnez votre genre',
      'genreMan': 'Homme',
      'genreWoman': 'Femme',
      'themeLabel': 'Couleur du thème royal',
      'langLabel': 'Langue de l\'application',
      'avatarLabel': 'Choisissez votre avatar',
      'button': 'Valider les modifications',
      'langFr': 'Français',
      'langEn': 'Anglais',
      'langAr': 'العربية',
    },
    'en': {
      'title': 'Pharaonic Settings',
      'subtitle': 'Customize your journey in ancient Egypt',
      'nameLabel': 'Full Name',
      'nameHint': 'Enter your full name',
      'genreLabel': 'Select your gender',
      'genreMan': 'Male',
      'genreWoman': 'Female',
      'themeLabel': 'Royal theme color',
      'langLabel': 'App language',
      'avatarLabel': 'Choose your avatar',
      'button': 'Save Changes',
      'langFr': 'French',
      'langEn': 'English',
      'langAr': 'Arabic',
    },
    'ar': {
      'title': 'الإعدادات الفرعونية',
      'subtitle': 'تخصيص رحلتك في مصر التاريخية',
      'nameLabel': 'الاسم واللقب',
      'nameHint': 'أدخل اسمك الكامل',
      'genreLabel': 'حدد جنسك',
      'genreMan': 'رجل',
      'genreWoman': 'امرأة',
      'themeLabel': 'لون المظهر الملكي',
      'langLabel': 'لغة التطبيق',
      'avatarLabel': 'اختر صورتك الرمزية',
      'button': 'حفظ التغييرات',
      'langFr': 'الفرنسية',
      'langEn': 'الإنجليزية',
      'langAr': 'العربية',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentLang = widget.languageCode;
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _selectedGenre = prefs.getString('user_gender') ?? 'Homme';
      _currentLang = prefs.getString('selected_language') ?? prefs.getString('user_lang') ?? widget.languageCode;
      _selectedAvatar = prefs.getString('user_avatar') ?? '👨🏽';
      final int? savedColorValue = prefs.getInt('user_theme_color');
      if (savedColorValue != null) {
        _selectedThemeColor = Color(savedColorValue);
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    await prefs.setString('selected_language', _currentLang);
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

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: EgyptTheme.background,
        body: Stack(
          children: [
            const Positioned.fill(
              child: EgyptAurora(colors: [EgyptTheme.accentGold, EgyptPalette.violet]),
            ),
            Center(child: CircularProgressIndicator(color: _selectedThemeColor)),
          ],
        ),
      );
    }

    final t = _localizedText[_currentLang] ?? _localizedText['fr']!;
    final bool isRtl = _currentLang == 'ar';
    final bool isMan = _selectedGenre == 'Homme' || _selectedGenre == 'Man' || _selectedGenre == 'رجل';
    final List<String> currentAvatars = isMan ? _avatarsHommes : _avatarsFemmes;

    if (!currentAvatars.contains(_selectedAvatar)) {
      _selectedAvatar = currentAvatars.first;
    }

    final double topPad = MediaQuery.of(context).padding.top;
    final double bottomPad = MediaQuery.of(context).padding.bottom;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: EgyptTheme.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: EgyptAurora(
                colors: [_selectedThemeColor, EgyptPalette.teal, EgyptPalette.violet, EgyptPalette.rose],
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(22, topPad + 12, 22, bottomPad + 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(t, isRtl),
                  const SizedBox(height: 34),
                  _buildProfileHero(t),
                  const SizedBox(height: 30),
                  _block(t['nameLabel']!, _buildNameField(t)),
                  _block(t['genreLabel']!, _buildGenreRow(t, isMan)),
                  _block(t['themeLabel']!, _buildThemeRow()),
                  _block(t['avatarLabel']!, _buildAvatarGrid(currentAvatars)),
                  _block(t['langLabel']!, _buildLangRow(t)),
                ],
              ),
            ),
            // Dégradé de lecture sous le bouton flottant
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomPad + 130,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, EgyptTheme.background],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: bottomPad + 18,
              child: _buildSaveButton(t),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── En-tête ─────────────────────────

  Widget _buildHeader(Map<String, String> t, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: EgyptBackButton(isRtl: isRtl, onTap: () => Navigator.pop(context)),
        ),
        const SizedBox(height: 36),
        EgyptReveal(
          child: Text(
            t['title']!,
            style: GoogleFonts.playfairDisplay(
              color: EgyptPalette.sand,
              fontSize: 44,
              height: 1.04,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        EgyptReveal(
          delay: 120,
          child: Text(
            t['subtitle']!,
            style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 14, height: 1.6),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Profil lumineux ─────────────────────────

  Widget _buildProfileHero(Map<String, String> t) {
    final String name = _nameController.text.trim();
    return Center(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  _selectedThemeColor,
                  _selectedThemeColor.withOpacity(0.15),
                  _selectedThemeColor,
                  _selectedThemeColor.withOpacity(0.15),
                  _selectedThemeColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _selectedThemeColor.withOpacity(0.35),
                  blurRadius: 50,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: EgyptTheme.cardDark,
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _selectedAvatar,
                  key: ValueKey(_selectedAvatar),
                  style: const TextStyle(fontSize: 68),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name.isEmpty ? t['nameHint']! : name,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: name.isEmpty ? EgyptPalette.muted : EgyptPalette.sand,
              fontSize: 26,
              height: 1.2,
              fontStyle: name.isEmpty ? FontStyle.italic : FontStyle.normal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Bloc en verre ─────────────────────────

  Widget _block(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: EgyptGlass(
        radius: 32,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: EgyptPalette.sand,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Nom ─────────────────────────

  Widget _buildNameField(Map<String, String> t) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _hasNameError ? EgyptTheme.coral : Colors.white.withOpacity(0.12),
          width: _hasNameError ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.person_outline_rounded, color: _selectedThemeColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _nameController,
              onChanged: (val) {
                setState(() {
                  if (_hasNameError && val.trim().isNotEmpty) {
                    _hasNameError = false;
                  }
                });
              },
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: t['nameHint'],
                hintStyle: GoogleFonts.montserrat(
                  color: _hasNameError ? EgyptTheme.coral : EgyptTheme.textMuted,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // ───────────────────────── Genre ─────────────────────────

  Widget _buildGenreRow(Map<String, String> t, bool isMan) {
    return Row(
      children: [
        Expanded(
          child: _genreTile(
            label: t['genreMan']!,
            icon: Icons.male_rounded,
            selected: isMan,
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
          child: _genreTile(
            label: t['genreWoman']!,
            icon: Icons.female_rounded,
            selected: !isMan,
            onTap: () {
              setState(() {
                _selectedGenre = t['genreWoman']!;
                _selectedAvatar = _avatarsFemmes[0];
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _genreTile({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _selectedThemeColor.withOpacity(0.18) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? _selectedThemeColor : Colors.white.withOpacity(0.1),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? _selectedThemeColor : EgyptTheme.textMuted),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: selected ? EgyptTheme.textLight : EgyptTheme.textMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Couleur du thème ─────────────────────────

  Widget _buildThemeRow() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _themeColors.map((color) {
          final bool selected = _selectedThemeColor.value == color.value;

          return GestureDetector(
            onTap: () => setState(() => _selectedThemeColor = color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
                    : [],
              ),
              child: selected
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.black87,
                size: 20,
              )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ───────────────────────── Avatar ─────────────────────────

  Widget _buildAvatarGrid(List<String> avatars) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: avatars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final String avatar = avatars[index];
        final bool selected = avatar == _selectedAvatar;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = avatar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _selectedThemeColor.withOpacity(0.22) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? _selectedThemeColor : Colors.white.withOpacity(0.08),
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Text(
              avatar,
              style: TextStyle(fontSize: selected ? 26 : 22),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── Langue ─────────────────────────

  Widget _buildLangRow(Map<String, String> t) {
    return Row(
      children: [
        Expanded(child: _langTile('fr', t['langFr']!)),
        const SizedBox(width: 10),
        Expanded(child: _langTile('en', t['langEn']!)),
        const SizedBox(width: 10),
        Expanded(child: _langTile('ar', t['langAr']!)),
      ],
    );
  }

  Widget _langTile(String code, String label) {
    final bool selected = _currentLang == code;
    return GestureDetector(
      onTap: () => setState(() => _currentLang = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? _selectedThemeColor.withOpacity(0.18) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _selectedThemeColor : Colors.white.withOpacity(0.1),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: selected ? EgyptTheme.textLight : EgyptTheme.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Bouton flottant ─────────────────────────

  Widget _buildSaveButton(Map<String, String> t) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_selectedThemeColor, _selectedThemeColor.withOpacity(0.78)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(31),
        boxShadow: [
          BoxShadow(
            color: _selectedThemeColor.withOpacity(0.4),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(31)),
        ),
        onPressed: _validateAndSave,
        child: Text(
          t['button']!,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}