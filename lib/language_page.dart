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
      'button': 'Découvrir l\'Égypte',
      'desc': 'Découvrez l\'âme de l\'Égypte. Au-delà des monuments, Egypt go vous emmène explorer les marchés vibrants du Caire, les villages nubiens authentiques, hors des sentiers battus comme Siwa, le Fayoum, ainsi que les déserts blanc et noir, tout en savourant les plats égyptiens typiques.'
    },
    'Anglais': {
      'title': 'Egypt',
      'button': 'Discover Egypt',
      'desc': 'Discover the soul of Egypt. Beyond the monuments, Egypt go takes you to explore the vibrant markets of Cairo, authentic Nubian villages, and off-the-beaten-path destinations like Siwa, Fayoum, and the White and Black Deserts, while savoring typical Egyptian dishes.'
    },
    'Arabe': {
      'title': 'مصر ',
      'button': 'اكتشف مصر',
      'desc': 'اكتشف روح مصر. بعيداً عن المعالم الأثرية, تأخذك "مصر جو" لاستكشاف أسواق القاهرة النابضة بالحياة، والقرى النوبية الأصيلة، ووجهات بعيدة عن المسارات التقليدية مثل سيوة والفيوم والصحراء البيضاء والسوداء، مع الاستمتاع بتذوق الأطباق المصرية الأصيلة.'
    },
  };

  String _currentLang = 'Français';

  @override
  Widget build(BuildContext context) {
    final texts = _localizedValues[_currentLang]!;
    final textDirection = _currentLang == 'Arabe' ? TextDirection.rtl : TextDirection.ltr;
    final List<String> languages = _localizedValues.keys.toList();

    return Directionality(
      textDirection: textDirection,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Column(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/egpyte.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            texts['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              children: [
                                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("🇪🇬", style: TextStyle(fontSize: 18)),
                                ),
                                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                              ],
                            ),
                          ),
                          Text(
                            texts['desc']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13.5,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Column(
                        children: [
                          Row(
                            // Correction apportée ici :
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: languages.map((lang) {
                              bool isSelected = _currentLang == lang;
                              String displayLabel = lang;
                              if (lang == 'Anglais') displayLabel = 'English';
                              if (lang == 'Arabe') displayLabel = 'العربية';

                              return GestureDetector(
                                onTap: () => setState(() => _currentLang = lang),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.lightGreen : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isSelected ? Colors.lightGreen : Colors.white.withOpacity(0.15),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    displayLabel,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentLang == 'Français') Get.to(() => const fr.Home());
                                else if (_currentLang == 'Anglais') Get.to(() => const en.HomeEnglish());
                                else Get.to(() => const ar.Home());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                texts['button']!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.55, size.height - 35);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.80, size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 25);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}