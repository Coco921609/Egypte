import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:ui';

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
// HELPER POUR LES MOIS FAVORIS
// ==========================================
class MoisFavorisHelper {
  static List<Map<String, dynamic>> filtrerDestinations(List<Map<String, dynamic>> toutesDestinations) {
    final maintenant = DateTime.now();
    final moisActuel = maintenant.month;

    return toutesDestinations.where((dest) {
      if (!dest.containsKey('moisFavoris') || dest['moisFavoris'] == null) {
        return false;
      }
      final rawMois = dest['moisFavoris'] as List<dynamic>? ?? [];
      List<int> moisFavoris = rawMois.map((e) => e as int).toList();
      return moisFavoris.contains(moisActuel);
    }).toList();
  }
}

// ==========================================
// TRADUCTIONS MULTILINGUES COMPLÈTES (FR, EN, AR)
// ==========================================
final Map<String, Map<String, String>> localizedAccueilText = {
  'fr': {
    'greeting': 'Bonjour',
    'welcomeEgypt': 'Bienvenue en Égypte',
    'settings': 'Paramètres',
    'recommendedMonth': 'Recommandé ce mois-ci',
    'exploreByRegion': 'Explorer par Thème & Catégorie',
    'noDestMonth': 'Aucune recommandation pour ce mois.',
    'details': 'Détails',
    'element': 'élément',
    'elements': 'éléments',
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
  },
  'en': {
    'greeting': 'Hello',
    'welcomeEgypt': 'Welcome to Egypt',
    'settings': 'Settings',
    'recommendedMonth': 'Recommended this month',
    'exploreByRegion': 'Explore by Theme & Category',
    'noDestMonth': 'No recommendations for this month.',
    'details': 'Details',
    'element': 'item',
    'elements': 'items',
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
  },
  'ar': {
    'greeting': 'مرحباً',
    'welcomeEgypt': 'مرحباً بك في مصر',
    'settings': 'الإعدادات',
    'recommendedMonth': 'موصى به هذا الشهر',
    'exploreByRegion': 'استكشف حسب الموضوع والفئة',
    'noDestMonth': 'لا توجد توصيات لهذا الشهر.',
    'details': 'التفاصيل',
    'element': 'عنصر',
    'elements': 'عناصر',
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
  },
};

// ==========================================
// ACCESSSCREEN ET ACCESSPAGE COMPATIBLES
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

class _HomeState extends State<AccueilPage> {
  String _lang = 'fr';

  final Color _bgDark = const Color(0xFF07080E);
  final Color _cardDark = const Color(0xFF11131C);
  final Color _cardDarkSecondary = const Color(0xFF181A26);

  late Color _accentGold;
  late String _currentAvatar;

  @override
  void initState() {
    super.initState();
    _lang = widget.languageCode ?? 'fr';
    _accentGold = widget.themeColor ?? const Color(0xFFD4AF37);
    _currentAvatar = widget.selectedAvatar ?? "👨🏽";
    _chargerParametres();
  }

  Future<void> _chargerParametres() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLang = prefs.getString('selected_language');
    if (savedLang != null && localizedAccueilText.containsKey(savedLang)) {
      setState(() {
        _lang = savedLang;
      });
    }

    final int? savedColorValue = prefs.getInt('user_theme_color');
    final String? savedAvatar = prefs.getString('user_avatar');

    setState(() {
      if (widget.themeColor != null) {
        _accentGold = widget.themeColor!;
      } else if (savedColorValue != null) {
        _accentGold = Color(savedColorValue);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLang);
    setState(() {
      _lang = newLang;
    });
  }

  String t(String key) {
    return localizedAccueilText[_lang]?[key] ?? localizedAccueilText['fr']![key] ?? key;
  }

  void _gererRetour() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  List<Map<String, dynamic>> getDestinations() {
    return [
      {
        'nom': t('cairo'),
        'description': t('descCairo'),
        'image': "assets/images/le caire.jpg",
        'couleur': const Color(0xFFD4AF37),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LeCairePage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3, 4],
      },
      {
        'nom': t('alexandria'),
        'description': t('descAlex'),
        'image': "assets/images/alexandrie.jpg",
        'couleur': const Color(0xFF38BDF8),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AlexandriePage(),
        'moisFavoris': [5, 6, 7, 8, 9, 10],
      },
      {
        'nom': t('luxor'),
        'description': t('descLuxor'),
        'image': "assets/images/louxor.jpg",
        'couleur': const Color(0xFFF59E0B),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LouxorPage(),
        'moisFavoris': [11, 12, 1, 2],
      },
      {
        'nom': t('aswan'),
        'description': t('descAswan'),
        'image': "assets/images/assouan.jpg",
        'couleur': const Color(0xFFEAB308),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AssouanPage(),
        'moisFavoris': [11, 12, 1, 2],
      },
      {
        'nom': t('siwa'),
        'description': t('descSiwa'),
        'image': "assets/images/siwa.jpeg",
        'couleur': const Color(0xFF10B981),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const SiwaPage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3],
      },
      {
        'nom': t('fayoum'),
        'description': t('descFayoum'),
        'image': "assets/images/fayoum.jpeg",
        'couleur': const Color(0xFF34D399),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const FayoumPage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3, 4],
      },
      {
        'nom': t('desert'),
        'description': t('descDesert'),
        'image': "assets/images/R.jpg",
        'couleur': const Color(0xFFF97316),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const DesertPage(),
        'moisFavoris': [10, 11, 12, 1, 2, 3, 4],
      },
      {
        'nom': t('sharm'),
        'description': t('descSharm'),
        'image': "assets/images/sharm.jpg",
        'couleur': const Color(0xFF0EA5E9),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const SharmElSheikhPage(),
        'moisFavoris': [3, 4, 5, 9, 10, 11],
      },
      {
        'nom': t('hurghada'),
        'description': t('descHurghada'),
        'image': "assets/images/j.jpg",
        'couleur': const Color(0xFF06B6D4),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const HurghadaPage(),
        'moisFavoris': [3, 4, 5, 9, 10, 11],
      },
      {
        'nom': t('dishesTitle'),
        'description': t('descDishes'),
        'image': "assets/plat/f.jpg",
        'couleur': const Color(0xFFF59E0B),
        'region': t('catDishes'),
        'categoryKey': 'Gastronomie',
        'page': const GastronomiePage(),
      },
      {
        'nom': t('hieroglyphicsTitle'),
        'description': t('descHieroglyphics'),
        'image': "assets/23.jpeg",
        'couleur': const Color(0xFFDFB15B),
        'region': t('catHieroglyphics'),
        'categoryKey': 'Hiéroglyphes Égyptiens',
        'page': const HieroglyphicsPage(),
      },
    ];
  }

  Widget _buildLangButton(String label, String langCode) {
    final bool isSelected = _lang == langCode;
    return GestureDetector(
      onTap: () => _changerLangue(langCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? _accentGold : const Color(0xFF1E2230),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _accentGold : _accentGold.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> toutesLesDestinations = getDestinations();
    final List<Map<String, dynamic>> destinationsMois = MoisFavorisHelper.filtrerDestinations(toutesLesDestinations);
    final bool isRtl = _lang == 'ar';

    final String displayGreeting = (widget.userName != null && widget.userName!.trim().isNotEmpty)
        ? "${t('greeting')}, ${widget.userName}"
        : t('greeting');

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: PopScope(
        canPop: !Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _gererRetour();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: _bgDark,
            body: Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -100,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accentGold.withOpacity(0.05),
                      ),
                    ),
                  ),
                ),
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayGreeting,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white54,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          softWrap: true,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          t('welcomeEgypt'),
                                          style: GoogleFonts.playfairDisplay(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildLangButton('FR', 'fr'),
                                            const SizedBox(width: 6),
                                            _buildLangButton('EN', 'en'),
                                            const SizedBox(width: 6),
                                            _buildLangButton('AR', 'ar'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: _accentGold.withOpacity(0.5), width: 1.5),
                                        ),
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: const Color(0xFF1E2230),
                                          child: Text(_currentAvatar, style: const TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: _accentGold.withOpacity(0.5), width: 1.5),
                                          color: const Color(0xFF1E2230),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.settings_rounded, color: Colors.white70, size: 18),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const ParametresPage()),
                                            ).then((_) => _chargerParametres());
                                          },
                                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                          padding: EdgeInsets.zero,
                                          tooltip: t('settings'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  t('recommendedMonth'),
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            if (index > 0 && index <= destinationsMois.length) {
                              final dest = destinationsMois[index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildDestMoisItem(dest),
                              );
                            }

                            int separatorIndex = destinationsMois.length + 1;
                            if (index == separatorIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 24, bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(color: Colors.white24, height: 20),
                                    const SizedBox(height: 10),
                                    Text(
                                      t('exploreByRegion'),
                                      style: GoogleFonts.playfairDisplay(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            int catStartIndex = separatorIndex + 1;
                            final categoriesConfig = [
                              {"key": "Villes Historiques", "label": t('catHistorical'), "color": _accentGold, "icon": Icons.account_balance_rounded},
                              {"key": "Nature & Aventure", "label": t('catNature'), "color": const Color(0xFF10B981), "icon": Icons.landscape_rounded},
                              {"key": "Mer Rouge", "label": t('catRedSea'), "color": const Color(0xFF0EA5E9), "icon": Icons.waves_rounded},
                              {"key": "Gastronomie", "label": t('catDishes'), "color": const Color(0xFFF59E0B), "icon": Icons.restaurant_rounded},
                              {"key": "Hiéroglyphes Égyptiens", "label": t('catHieroglyphics'), "color": const Color(0xFFDFB15B), "icon": Icons.auto_awesome_rounded},
                            ];

                            int currentIndex = catStartIndex;
                            for (var cat in categoriesConfig) {
                              String catKey = cat['key'] as String;
                              String catLabel = cat['label'] as String;
                              Color catColor = cat['color'] as Color;
                              IconData catIcon = cat['icon'] as IconData;

                              List<Map<String, dynamic>> itemsInCat = toutesLesDestinations
                                  .where((d) => d['categoryKey'] == catKey)
                                  .toList();

                              if (index == currentIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _cardDarkSecondary,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: catColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(catIcon, color: catColor, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          catLabel,
                                          style: GoogleFonts.cinzel(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              currentIndex++;

                              for (var dest in itemsInCat) {
                                if (index == currentIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 12, bottom: 10),
                                    child: _buildDestMoisItem(dest),
                                  );
                                }
                                currentIndex++;
                              }
                            }

                            return const SizedBox.shrink();
                          },
                          childCount: 2 + destinationsMois.length + 5 + toutesLesDestinations.length,
                        ),
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

  Widget _buildDestMoisItem(Map<String, dynamic> destination) {
    final Color themeColor = destination['couleur'] as Color;
    return GestureDetector(
      onTap: () {
        if (destination['page'] != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination['page'])).then((_) => _chargerParametres());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _accentGold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                destination['image'],
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination['nom'],
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination['region'],
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: themeColor,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}