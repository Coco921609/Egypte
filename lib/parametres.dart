import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'accueil.dart';

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
// 3. PAGE DES PARAMÈTRES PHARAONIQUES
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: EgyptTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: _selectedThemeColor),
        ),
      );
    }

    final t = _localizedText[_currentLang] ?? _localizedText['fr']!;
    final isRtl = _currentLang == 'ar';
    final bool isMan = _selectedGenre == 'Homme' || _selectedGenre == 'Man' || _selectedGenre == 'رجل';
    final currentAvatars = isMan ? _avatarsHommes : _avatarsFemmes;

    if (!currentAvatars.contains(_selectedAvatar)) {
      _selectedAvatar = currentAvatars.first;
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: EgyptTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: EgyptTheme.cardDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: _selectedThemeColor.withOpacity(0.5), width: 1.5),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: _selectedThemeColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        t['title']!,
                        style: GoogleFonts.cinzel(
                          color: _selectedThemeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 46.0),
                  child: Text(
                    t['subtitle']!,
                    style: GoogleFonts.montserrat(
                      color: EgyptTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 40, height: 1, color: _selectedThemeColor.withOpacity(0.3)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("🏛️", style: TextStyle(fontSize: 14)),
                      ),
                      Container(width: 40, height: 1, color: _selectedThemeColor.withOpacity(0.3)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 1. NOM ET PRÉNOM
                Text(
                  t['nameLabel']!,
                  style: GoogleFonts.montserrat(color: EgyptTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: EgyptTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasNameError ? EgyptTheme.coral : _selectedThemeColor.withOpacity(0.4),
                      width: _hasNameError ? 2 : 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    onChanged: (val) {
                      if (_hasNameError && val.trim().isNotEmpty) {
                        setState(() {
                          _hasNameError = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_rounded, color: _selectedThemeColor, size: 20),
                      hintText: t['nameHint'],
                      hintStyle: GoogleFonts.montserrat(
                        color: _hasNameError ? EgyptTheme.coral.withOpacity(0.8) : EgyptTheme.textMuted.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. GENRE
                Text(
                  t['genreLabel']!,
                  style: GoogleFonts.montserrat(color: EgyptTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenreButton(
                        label: t['genreMan']!,
                        icon: Icons.male_rounded,
                        isSelected: isMan,
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
                        isSelected: !isMan,
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
                const SizedBox(height: 24),

                // 3. COULEUR DU THÈME
                Text(
                  t['themeLabel']!,
                  style: GoogleFonts.montserrat(color: EgyptTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _themeColors.map((color) {
                    final isSelected = _selectedThemeColor.value == color.value;
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
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                              : [],
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, color: Colors.black87, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 26),

                // 4. AVATAR PHARAONIQUE
                Text(
                  t['avatarLabel']!,
                  style: GoogleFonts.montserrat(color: EgyptTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Center(
                  child: AnimatedContainer(
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
                    ),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: EgyptTheme.cardDark,
                        border: Border.all(color: _selectedThemeColor.withOpacity(0.6), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _selectedAvatar,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
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
                    mainAxisSpacing: 8,
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
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedThemeColor.withOpacity(0.25)
                              : EgyptTheme.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? _selectedThemeColor : EgyptTheme.cardDarkSecondary,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            avatar,
                            style: TextStyle(
                              fontSize: isSelected ? 24 : 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 26),

                // 5. LANGUE DE L'APPLICATION
                Text(
                  t['langLabel']!,
                  style: GoogleFonts.montserrat(color: EgyptTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 36),

                // BOUTON VALIDER
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_selectedThemeColor, _selectedThemeColor.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedThemeColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
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
                      style: GoogleFonts.cinzel(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
          color: isSelected ? _selectedThemeColor.withOpacity(0.18) : EgyptTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedThemeColor : EgyptTheme.cardDarkSecondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? _selectedThemeColor : EgyptTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : EgyptTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
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
          color: isSelected ? _selectedThemeColor.withOpacity(0.18) : EgyptTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedThemeColor : EgyptTheme.cardDarkSecondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              color: isSelected ? Colors.white : EgyptTheme.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}