import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'presentation.dart';

class LanguesPage extends StatefulWidget {
  final bool isProfileCreated;

  const LanguesPage({super.key, required this.isProfileCreated});

  @override
  State<LanguesPage> createState() => _LanguesPageState();
}

class _LanguesPageState extends State<LanguesPage> {
  String _selectedLanguage = 'fr';

  // Palette de couleurs pharaoniques & dorées
  static const Color goldLight = Color(0xFFFFF1B0);
  static const Color goldMain = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFF9E7B21);
  static const Color darkPillBg = Color(0xDD0D1B2A);
  static const Color darkGlassBg = Color(0x88000000);

  // Dictionnaire des traductions
  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      'title': 'Égypte',
      'subtitle': 'L’Égypte, une destination de rêve à visiter',
      'tagline': '— Explorez la terre des Pharaons —',
      'choose_language': 'Choisissez votre langue',
      'fr_label': 'Français',
      'en_label': 'Anglais',
      'ar_label': 'Arabe',
      'validate': 'Valider',
    },
    'en': {
      'title': 'Egypt',
      'subtitle': 'Egypt, a dream destination to visit',
      'tagline': '— Explore the land of the Pharaohs —',
      'choose_language': 'Choose your language',
      'fr_label': 'French',
      'en_label': 'English',
      'ar_label': 'Arabic',
      'validate': 'Validate',
    },
    'ar': {
      'title': 'مِصْر',
      'subtitle': 'مصر، وجهة الأحلام للزيارة',
      'tagline': '— استكشف أرض الفراعنة —',
      'choose_language': 'اخْتَر لُغَتَك',
      'fr_label': 'الفرنسية',
      'en_label': 'الإنجليزية',
      'ar_label': 'العربية',
      'validate': 'تأكيد',
    },
  };

  String _txt(String key) {
    return _translations[_selectedLanguage]?[key] ?? '';
  }

  void _navigateToPresentation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PresentationScreen(
          languageCode: _selectedLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF090806),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Image de fond centrée et alignée au milieu
            Image.asset(
              'assets/2.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF8A622A),
                        Color(0xFF381F0D),
                        Color(0xFF090806),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 2. Dégradé d'ambiance
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.30),
                    Colors.black.withOpacity(0.92),
                  ],
                  stops: const [0.0, 0.45, 0.95],
                ),
              ),
            ),

            // 3. Contenu Principal
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Emblème Pharaonique supérieur
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: HeaderEmblemPainter(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Carte Glassmorphism Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: darkGlassBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: goldMain.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: goldMain.withOpacity(0.12),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Titre principal traduit
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [goldLight, goldMain, goldDark],
                            ).createShader(bounds),
                            child: Text(
                              _txt('title'),
                              style: TextStyle(
                                fontSize: isRtl ? 42 : 46,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w900,
                                letterSpacing: isRtl ? 1.0 : 3.0,
                                height: 1.1,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Séparateur royal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 25,
                                height: 1,
                                color: goldMain.withOpacity(0.7),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '𓋹 𓏛 𓁹',
                                  style: TextStyle(
                                    color: goldMain,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                width: 25,
                                height: 1,
                                color: goldMain.withOpacity(0.7),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Sous-titre traduit
                          Text(
                            _txt('subtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFF0E6D2),
                              fontSize: 15,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Accroche
                          Text(
                            _txt('tagline'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: goldLight.withOpacity(0.85),
                              fontSize: 12,
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Icône centrale Boussole + Avion
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: CustomPaint(
                        painter: CompassPlanePainter(),
                      ),
                    ),

                    const Spacer(),

                    // Section choix de langue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('✧ ', style: TextStyle(color: goldMain, fontSize: 14)),
                        Text(
                          _txt('choose_language'),
                          style: TextStyle(
                            color: goldLight.withOpacity(0.95),
                            fontSize: 14,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            letterSpacing: isRtl ? 0.5 : 1.0,
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 8),
                            ],
                          ),
                        ),
                        const Text(' ✧', style: TextStyle(color: goldMain, fontSize: 14)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 1. Bouton FRANÇAIS
                    _buildLanguageButton(
                      code: 'fr',
                      label: _txt('fr_label'),
                    ),

                    const SizedBox(height: 10),

                    // 2. Bouton ANGLAIS
                    _buildLanguageButton(
                      code: 'en',
                      label: _txt('en_label'),
                    ),

                    const SizedBox(height: 10),

                    // 3. Bouton ARABE
                    _buildLanguageButton(
                      code: 'ar',
                      label: _txt('ar_label'),
                    ),

                    const SizedBox(height: 16),

                    // Bouton VALIDER
                    _buildValidateButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget du bouton de sélection de langue (sans drapeau)
  Widget _buildLanguageButton({
    required String code,
    required String label,
  }) {
    final bool isSelected = _selectedLanguage == code;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedLanguage = code;
          });
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? darkPillBg : darkGlassBg,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? goldLight : goldMain.withOpacity(0.4),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? goldMain.withOpacity(0.40)
                    : Colors.black45,
                blurRadius: isSelected ? 12 : 6,
                spreadRadius: isSelected ? 1 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Libellé de langue
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? goldLight : Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontFamily: 'serif',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    letterSpacing: _selectedLanguage == 'ar' ? 0.5 : 1.0,
                  ),
                ),
              ),

              // Coche de sélection
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? goldMain : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? goldLight : goldMain.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.black,
                  size: 14,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget du bouton Valider
  Widget _buildValidateButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [goldLight, goldMain, goldDark],
        ),
        boxShadow: [
          BoxShadow(
            color: goldMain.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _navigateToPresentation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          _txt('validate'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// Emblème Pharaonique supérieur
class HeaderEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.20)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, goldPaint);

    final pyramidPath = Path()
      ..moveTo(center.dx - 20, center.dy + 16)
      ..lineTo(center.dx, center.dy - 6)
      ..lineTo(center.dx + 20, center.dy + 16)
      ..close();
    canvas.drawPath(pyramidPath, goldPaint);
    canvas.drawPath(pyramidPath, fillPaint);

    canvas.drawLine(
      Offset(center.dx, center.dy - 6),
      Offset(center.dx, center.dy + 16),
      goldPaint,
    );

    final double ankhY = center.dy - 14;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, ankhY - 7), width: 9, height: 11),
      goldPaint,
    );
    canvas.drawLine(
      Offset(center.dx, ankhY - 1),
      Offset(center.dx, ankhY + 9),
      goldPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 6, ankhY + 3),
      Offset(center.dx + 6, ankhY + 3),
      goldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Boussole + Avion
class CompassPlanePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawCircle(center, radius, goldPaint);

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final len = (i % 2 == 0) ? radius : radius * 0.55;
      final x = center.dx + math.cos(angle) * len;
      final y = center.dy + math.sin(angle) * len;
      canvas.drawLine(center, Offset(x, y), goldPaint);
    }

    final planePaint = Paint()
      ..color = const Color(0xFFFFF1B0)
      ..style = PaintingStyle.fill;

    final planePath = Path()
      ..moveTo(center.dx + 16, center.dy - 16)
      ..lineTo(center.dx + 7, center.dy - 3)
      ..lineTo(center.dx - 2, center.dy - 2)
      ..lineTo(center.dx - 9, center.dy + 5)
      ..lineTo(center.dx - 5, center.dy + 7)
      ..lineTo(center.dx, center.dy + 3)
      ..lineTo(center.dx + 9, center.dy + 9)
      ..close();

    canvas.drawPath(planePath, planePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}