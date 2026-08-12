import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'home.dart' as fr;
import 'home_english.dart' as en;
import 'home_arabic.dart' as ar;

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final Map<String, Map<String, String>> _localizedValues = {
    'Français': {
      'title': 'Égypte',
      'button': 'Découvrir le Pays',
      'desc': 'Explorez l\'Égypte au-delà des monuments : les marchés vibrants du Caire, la magie des villages nubiens, les oasis préservées de Siwa et du Fayoum, et les immensités des déserts blanc et noir.'
    },
    'Anglais': {
      'title': 'Egypt',
      'button': 'Discover the Country',
      'desc': 'Explore Egypt beyond the monuments: the vibrant markets of Cairo, authentic Nubian villages, pristine oases like Siwa and Fayoum, and the vast white and black deserts.'
    },
    'Arabe': {
      'title': 'مصر',
      'button': 'استكشف البلاد',
      'desc': 'استكشف مصر بعيداً عن المعالم التقليدية: أسواق القاهرة النابضة، القرى النوبية الأصيلة، واحات سيوة والفيوم، وسحر الصحراء البيضاء والسوداء.'
    },
  };

  String _currentLang = 'Français';

  // Couleurs Luxe Égyptien
  static const Color obsidianBg = Color(0xFF09090C);
  static const Color darkCardBg = Color(0xFF121218);
  static const Color goldPrimary = Color(0xFFC5A059);
  static const Color goldLight = Color(0xFFF3E5AB);

  static const LinearGradient luxuryGoldGradient = LinearGradient(
    colors: [
      Color(0xFFE6CA65),
      Color(0xFFC5A059),
      Color(0xFF997A15),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Position physique fixe dans le sélecteur (Français = -1, Anglais = 0, Arabe = 1)
  double _getAlignX() {
    if (_currentLang == 'Français') return -1.0;
    if (_currentLang == 'Anglais') return 0.0;
    return 1.0; // Arabe
  }

  @override
  Widget build(BuildContext context) {
    final texts = _localizedValues[_currentLang]!;
    final textDirection = _currentLang == 'Arabe' ? TextDirection.rtl : TextDirection.ltr;
    final List<String> languages = ['Français', 'Anglais', 'Arabe'];

    return Directionality(
      textDirection: textDirection,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: obsidianBg,
          body: Stack(
            children: [
              // 1. Halo lumineux doré en arrière-plan
              Positioned(
                top: -80.0,
                left: MediaQuery.of(context).size.width * 0.25,
                child: Container(
                  width: 220.0,
                  height: 220.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: goldPrimary.withOpacity(0.08),
                        blurRadius: 90.0,
                        spreadRadius: 40.0,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Contenu principal
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // --- EN-TÊTE AVEC TITRE ÉGYPTE ET DRAPEAU ---
                      Column(
                        children: [
                          const Text(
                            "𓋹",
                            style: TextStyle(
                              fontSize: 30.0,
                              color: goldPrimary,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          // Titre Égypte avec accent
                          ShaderMask(
                            shaderCallback: (bounds) => luxuryGoldGradient.createShader(bounds),
                            child: Text(
                              texts['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 3.0,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                          const SizedBox(height: 14.0),
                          // Drapeau d'Égypte
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: darkCardBg.withOpacity(0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: goldPrimary.withOpacity(0.4),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: goldPrimary.withOpacity(0.15),
                                  blurRadius: 12.0,
                                ),
                              ],
                            ),
                            child: const Text(
                              "🇪🇬",
                              style: TextStyle(fontSize: 24.0),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 2),

                      // --- SÉLECTEUR DE LANGUE (ISOLÉ EN LTR POUR GARANTIR L'ANIMATION EN ARABE) ---
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Column(
                          children: [
                            // Scarabée indicateur glissant
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutBack,
                              alignment: Alignment(_getAlignX(), 0.0),
                              child: const SizedBox(
                                width: 100.0,
                                child: Center(
                                  child: Text(
                                    "𓆣",
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      color: goldPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            // Piste du sélecteur
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double itemWidth = constraints.maxWidth / 3;
                                return Container(
                                  height: 52.0,
                                  decoration: BoxDecoration(
                                    color: darkCardBg.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                      color: goldPrimary.withOpacity(0.25),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Lingot d'or animé qui glisse
                                      AnimatedAlign(
                                        duration: const Duration(milliseconds: 350),
                                        curve: Curves.easeInOutCubic,
                                        alignment: Alignment(_getAlignX(), 0.0),
                                        child: Container(
                                          width: itemWidth - 8.0,
                                          height: 44.0,
                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            gradient: luxuryGoldGradient,
                                            borderRadius: BorderRadius.circular(26.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: goldPrimary.withOpacity(0.4),
                                                blurRadius: 14.0,
                                                offset: const Offset(0.0, 2.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Boutons
                                      Row(
                                        children: languages.map((lang) {
                                          bool isSelected = _currentLang == lang;
                                          String displayLabel = lang;
                                          if (lang == 'Anglais') displayLabel = 'English';
                                          if (lang == 'Arabe') displayLabel = 'العربية';

                                          return Expanded(
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () => setState(() => _currentLang = lang),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: AnimatedDefaultTextStyle(
                                                      duration: const Duration(milliseconds: 200),
                                                      style: TextStyle(
                                                        color: isSelected ? obsidianBg : Colors.white.withOpacity(0.7),
                                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                                        fontSize: 13.5,
                                                      ),
                                                      child: Text(displayLabel),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // --- CARTE TEXTE DESCRIPTIF ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding: const EdgeInsets.all(22.0),
                            decoration: BoxDecoration(
                              color: darkCardBg.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: goldPrimary.withOpacity(0.15),
                                width: 1.0,
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.05),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                texts['desc']!,
                                key: ValueKey<String>(_currentLang),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13.5,
                                  height: 1.7,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // --- BOUTON D'ACTION DÉCOUVRIR LE PAYS ---
                      SizedBox(
                        width: double.infinity,
                        height: 56.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: luxuryGoldGradient,
                            borderRadius: BorderRadius.circular(14.0),
                            boxShadow: [
                              BoxShadow(
                                color: goldPrimary.withOpacity(0.2),
                                blurRadius: 20.0,
                                offset: const Offset(0.0, 8.0),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentLang == 'Français') {
                                Get.to(() => const fr.Home());
                              } else if (_currentLang == 'Anglais') {
                                Get.to(() => const en.HomeEnglish());
                              } else {
                                Get.to(() => const ar.Home());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                texts['button']!,
                                key: ValueKey<String>(_currentLang),
                                style: const TextStyle(
                                  color: obsidianBg,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),
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