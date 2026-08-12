import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'arabe/le caire.dart';
import 'arabe/alexandrie.dart';
import 'arabe/louxor.dart';
import 'arabe/assouan.dart';
import 'arabe/siwa.dart';
import 'arabe/fayoum.dart';
import 'arabe/desert.dart';
import 'arabe/sharm.dart';
import 'arabe/Hurghada.dart';
import 'arabe/airlines.dart';
import 'arabe/gastronomie_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> _favorisLieuxJson = [];

  // مفتاح تخزين فريد ومعزول للنسخة العربية
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  int _selectedIndex = 0; // 0 = الدليل (Home), 1 = المفضلة

  // لوحة ألوان فرعونية فاخرة للغاية
  final Color _bgDark = const Color(0xFF07080E); // أسود سبج
  final Color _cardDark = const Color(0xFF11131C); // أونيكس عميق
  final Color _cardDarkSecondary = const Color(0xFF181A26);
  final Color _accentGold = const Color(0xFFD4AF37); // ذهبي فرعوني ملكي
  final Color _accentGoldLight = const Color(0xFFF3E5AB); // انعكاس الذهب
  final Color _lapisBlue = const Color(0xFF1E3A8A); // أزرق لاجورد
  final Color _papyrusBg = const Color(0xFF1A1813); // خلفية البردي الداكنة

  // الفئات الدقيقة المحددة والمتناسقة في كل مكان
  final Map<String, bool> _foldersExpanded = {
    "المدن التاريخية": false,
    "الطبيعة والمغامرة": false,
    "البحر الأحمر": false,
    "معلومات عملية": false,
  };

  final Map<String, bool> _subFoldersExpanded = {
    "القاهرة": false,
    "الإسكندرية": false,
    "الأقصر": false,
    "أسوان": false,
    "شرم الشيخ": false,
    "الغردقة": false,
    "سيوة": false,
    "الفيوم": false,
    "الصحراء": false,
    "فن الطهي": false,
  };

  final List<Map<String, dynamic>> destinations = [
    {
      'nom': "القاهرة",
      'description': "عاصمة نابضة بالحياة، مهد الأهرامات التي تعود لآلاف السنين والقلب النابض لمصر الحديثة.",
      'image': "assets/images/le caire.jpg",
      'couleur': const Color(0xFFD4AF37),
      'region': "المدن التاريخية",
      'page': const LeCairePage(),
    },
    {
      'nom': "الإسكندرية",
      'description': "لؤلؤة البحر الأبيض المتوسط، تمزج هذه المدينة الأسطورية بين العمارة الأوروبية والتراث المصري.",
      'image': "assets/images/alexandrie.jpg",
      'couleur': const Color(0xFF38BDF8),
      'region': "المدن التاريخية",
      'page': const AlexandriePage(),
    },
    {
      'nom': "الأقصر",
      'description': "أكبر متحف مفتوح في العالم، يضم معابد الكرنك المهيبة.",
      'image': "assets/images/louxor.jpg",
      'couleur': const Color(0xFFF59E0B),
      'region': "المدن التاريخية",
      'page': const LouxorPage(),
    },
    {
      'nom': "أسوان",
      'description': "ملاذ للسلام على ضفاف النيل، تشتهر بمناظرها النوبية وهدوئها المطلق.",
      'image': "assets/images/assouan.jpg",
      'couleur': const Color(0xFFEAB308),
      'region': "المدن التاريخية",
      'page': const AssouanPage(),
    },
    {
      'nom': "سيوة",
      'description': "واحة صوفية معزولة في الصحراء، تشتهر بينابيعها الحارة.",
      'image': "assets/images/siwa.jpeg",
      'couleur': const Color(0xFF10B981),
      'region': "الطبيعة والمغامرة",
      'page': const SiwaPage(),
    },
    {
      'nom': "الفيوم",
      'description': "نظام بيئي فريد بين البحيرات المالحة والصحراء، حيث تلتقي الطبيعة البرية بالتاريخ.",
      'image': "assets/images/fayoum.jpeg",
      'couleur': const Color(0xFF34D399),
      'region': "الطبيعة والمغامرة",
      'page': const FayoumPage(),
    },
    {
      'nom': "الصحراء",
      'description': "رحلة استكشافية لا تُنسى في قلب الصحراء البيضاء والسوداء.",
      'image': "assets/images/R.jpg",
      'couleur': const Color(0xFFF97316),
      'region': "الطبيعة والمغامرة",
      'page': const DesertPage(),
    },
    {
      'nom': "شرم الشيخ",
      'description': "وجهة ساحلية عالمية، تشتهر بغنى شعابها المرجانية.",
      'image': "assets/images/sharm.jpg",
      'couleur': const Color(0xFF0EA5E9),
      'region': "البحر الأحمر",
      'page': const SharmElSheikhPage(),
    },
    {
      'nom': "الغردقة",
      'description': "منتجع ساحلي ديناميكي يقدم شواطئ رملية دقيقة ورحلات سحرية.",
      'image': "assets/images/j.jpg",
      'couleur': const Color(0xFF06B6D4),
      'region': "البحر الأحمر",
      'page': const HurghadaPage(),
    },
    {
      'nom': "شركات الطيران",
      'description': "كل المعلومات اللازمة عن الرحلات الدولية والاتصالات المحلية.",
      'image': "assets/images/air.jpg",
      'couleur': const Color(0xFFEF4444),
      'region': "معلومات عملية",
      'page': const AirlinesPage(),
    },
    {
      'nom': "أطباق تقليدية",
      'description': "اكتشف فن الطهي الغني بالنكهات: الكشري والفلافل والمعجنات الشرقية.",
      'image': "assets/images/p.jpg",
      'couleur': const Color(0xFFEC4899),
      'region': "معلومات عملية",
      'page': const GastronomiePage(),
    },
  ];

  final List<Map<String, String>> villesRoulette = [
    {'nom': "القاهرة", 'image': "assets/images/le caire.jpg"},
    {'nom': "الإسكندرية", 'image': "assets/images/alexandrie.jpg"},
    {'nom': "الأقصر", 'image': "assets/images/louxor.jpg"},
    {'nom': "أسوان", 'image': "assets/images/assouan.jpg"},
    {'nom': "سيوة", 'image': "assets/images/siwa.jpeg"},
    {'nom': "الفيوم", 'image': "assets/images/fayoum.jpeg"},
    {'nom': "الصحراء", 'image': "assets/images/R.jpg"},
    {'nom': "شرم الشيخ", 'image': "assets/images/sharm.jpg"},
    {'nom': "الغردقة", 'image': "assets/images/j.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisLieuxJson = prefs.getStringList(_cleStockageLieux) ?? [];
    });
  }

  Future<void> _supprimerFavoriLieu(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String name = item['name'];
    setState(() {
      _favorisLieuxJson.removeWhere((jsonStr) {
        try {
          return jsonDecode(jsonStr)['name'] == name;
        } catch (e) {
          return false;
        }
      });
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  void _gererRetour() {
    if (_selectedIndex == 1) {
      setState(() {
        _selectedIndex = 0;
      });
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _afficherGenerateur(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgDark,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        side: BorderSide(color: _accentGold.withOpacity(0.4), width: 1.5),
      ),
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return _GenerateurWidget(scrollController: scrollController);
            },
          ),
        );
      },
    );
  }

  void _lancerRoulettePrincipale(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: _RouletteDialog(villes: villesRoulette, parentContext: context),
        );
      },
    );
  }

  String _detectRegion(Map<String, dynamic> item) {
    final String rawRegion = item['region'] ?? '';
    final String rawSub = item['sub_folder'] ?? item['ville'] ?? '';

    if (rawRegion == "المدن التاريخية" ||
        rawRegion == "البحر الأحمر" ||
        rawRegion == "الطبيعة والمغامرة" ||
        rawRegion == "معلومات عملية") {
      return rawRegion;
    }

    if (rawSub == "فن الطهي" || rawSub == "Gastronomie") return "معلومات عملية";
    if (rawSub == "القاهرة" || rawSub == "الإسكندرية" || rawSub == "الأقصر" || rawSub == "أسوان" ||
        rawSub == "Le Caire" || rawSub == "Alexandrie" || rawSub == "Louxor" || rawSub == "Assouan") return "المدن التاريخية";
    if (rawSub == "شرم الشيخ" || rawSub == "الغردقة" || rawSub == "Sharm" || rawSub == "Hurghada" || rawSub == "Sharm El-Sheikh") return "البحر الأحمر";
    if (rawSub == "سيوة" || rawSub == "الفيوم" || rawSub == "الصحراء" || rawSub == "Siwa" || rawSub == "Fayoum" || rawSub == "Desert" || rawSub == "Désert") return "الطبيعة والمغامرة";

    return "المدن التاريخية";
  }

  String _detectSubFolder(Map<String, dynamic> item, String region) {
    final String rawSub = item['sub_folder'] ?? item['ville'] ?? '';

    if (rawSub == "Desert" || rawSub == "Désert") return "الصحراء";

    final validSubFolders = [
      "القاهرة", "الإسكندرية", "الأقصر", "أسوان",
      "شرم الشيخ", "الغردقة",
      "سيوة", "الفيوم", "الصحراء",
      "فن الطهي"
    ];

    if (validSubFolders.contains(rawSub)) {
      return rawSub;
    }

    if (rawSub == "Le Caire") return "القاهرة";
    if (rawSub == "Alexandrie") return "الإسكندرية";
    if (rawSub == "Louxor") return "الأقصر";
    if (rawSub == "Assouan") return "أسوان";
    if (rawSub == "Sharm El-Sheikh" || rawSub == "Sharm") return "شرم الشيخ";
    if (rawSub == "Hurghada") return "الغردقة";
    if (rawSub == "Siwa") return "سيوة";
    if (rawSub == "Fayoum") return "الفيوم";
    if (rawSub == "Gastronomie") return "فن الطهي";

    if (region == "معلومات عملية") return "فن الطهي";
    if (region == "المدن التاريخية") return "القاهرة";
    if (region == "البحر الأحمر") return "شرم الشيخ";
    if (region == "الطبيعة والمغامرة") return "الصحراء";

    return "القاهرة";
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "معالم أثرية":
      case "Monuments": return _accentGold;
      case "أسواق تقليدية":
      case "Marchés traditionnels": return const Color(0xFFEF4444);
      case "أماكن تاريخية":
      case "Lieux historiques": return const Color(0xFF38BDF8);
      case "عمارة":
      case "Architecture": return const Color(0xFFA855F7);
      case "أماكن استرخاء":
      case "Lieux de détente": return const Color(0xFF2DD4BF);
      case "فن الطهي":
      case "Gastronomie": return const Color(0xFFEC4899);
      case "معالم وثقافة":
      case "Monuments & Culture": return const Color(0xFFF59E0B);
      case "رحلات لا تفوت":
      case "Excursions incontournables": return const Color(0xFF8B5CF6);
      case "بحر وطبيعة":
      case "Mer & Nature": return const Color(0xFF0EA5E9);
      case "أنشطة":
      case "Activités": return const Color(0xFFF97316);
      case "استرخاء وحياة ليلية":
      case "Détente & Vie nocturne": return const Color(0xFFD946EF);
      default: return _accentGoldLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> doubleGroupedFavorites = {
      "المدن التاريخية": {
        "القاهرة": [],
        "الإسكندرية": [],
        "الأقصر": [],
        "أسوان": [],
      },
      "الطبيعة والمغامرة": {
        "سيوة": [],
        "الفيوم": [],
        "الصحراء": [],
      },
      "البحر الأحمر": {
        "شرم الشيخ": [],
        "الغردقة": [],
      },
      "معلومات عملية": {
        "فن الطهي": [],
      },
    };

    for (var jsonStr in _favorisLieuxJson) {
      try {
        final item = jsonDecode(jsonStr) as Map<String, dynamic>;
        final region = _detectRegion(item);
        final subFolder = _detectSubFolder(item, region);
        if (doubleGroupedFavorites.containsKey(region) && doubleGroupedFavorites[region]!.containsKey(subFolder)) {
          doubleGroupedFavorites[region]![subFolder]!.add(item);
        }
      } catch (e) {}
    }

    final List<Widget> favoritesWidgets = _buildFavoritesFolders(doubleGroupedFavorites);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: _selectedIndex == 0 && !Navigator.canPop(context),
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
                  left: -100,
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
                          padding: const EdgeInsets.only(left: 24, top: 48, bottom: 28, right: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (Navigator.canPop(context) || _selectedIndex == 1) ...[
                                    GestureDetector(
                                      onTap: _gererRetour,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _cardDark,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: _accentGold.withOpacity(0.4), width: 1),
                                          boxShadow: [
                                            BoxShadow(color: _accentGold.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 2)),
                                          ],
                                        ),
                                        // 🔄 Flèche inversée dans l'autre sens pour le bouton de retour RTL
                                        child: Icon(Icons.arrow_back_ios_rounded, color: _accentGold, size: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "𓋹  ",
                                              style: TextStyle(color: _accentGold, fontSize: 10),
                                            ),
                                            Text(
                                              "الدليل الرسمي",
                                              style: GoogleFonts.cairo(
                                                color: _accentGold,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                            children: [
                                              const TextSpan(text: "مصر "),
                                              TextSpan(
                                                text: "الخالدة",
                                                style: GoogleFonts.playfairDisplay(
                                                  fontStyle: FontStyle.italic,
                                                  color: _accentGold,
                                                  fontWeight: FontWeight.w600,
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
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _cardDark,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: _accentGold.withOpacity(0.3), width: 1),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildHeaderNavItem(index: 0, icon: Icons.explore_rounded, activeColor: _accentGold),
                                      const SizedBox(width: 10),
                                      _buildHeaderNavItem(index: 1, icon: Icons.bookmark_rounded, activeColor: _accentGoldLight),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
                      sliver: _selectedIndex == 0
                          ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildGenerateurIntroCard(context),
                              );
                            }
                            if (index == 1) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _buildRouletteMainCard(context),
                              );
                            }
                            final dest = destinations[index - 2];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: _buildDestinationCard(dest, 240),
                            );
                          },
                          childCount: destinations.length + 2,
                        ),
                      )
                          : SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => favoritesWidgets[index],
                          childCount: favoritesWidgets.length,
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

  Widget _buildGenerateurIntroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentGold.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: _accentGold.withOpacity(0.08), blurRadius: 15, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentGold.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentGold.withOpacity(0.3)),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: _accentGold, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'المخطط الفرعوني',
                  style: GoogleFonts.cairo(
                    color: _accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'متى تزور مصر؟ 🗓️',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'احصل على أفضل مواسم الزيارة لكل مدينة لتجنب الحرارة الشديدة والاستمتاع بإقامتك على أكمل وجه.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: const Color(0xFFA1A5B7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [_accentGold, const Color(0xFFB8860B)],
              ),
              boxShadow: [
                BoxShadow(color: _accentGold.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _afficherGenerateur(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 18, color: Colors.black),
              label: Text(
                'إطلاق المخطط',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouletteMainCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.08), blurRadius: 15, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                ),
                child: const Icon(Icons.casino_rounded, color: Color(0xFFA78BFA), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الوجهة الغامضة',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFFA78BFA),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'روليت المدن 🎲',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'دع الصدفة تختار محطتك المصرية القادمة بنقرة واحدة!',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: const Color(0xFFA1A5B7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _lancerRoulettePrincipale(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
              label: Text(
                'تدوير الروليت',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderNavItem({required int index, required IconData icon, required Color activeColor}) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) _chargerFavoris();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: activeColor.withOpacity(0.5), width: 1) : null,
        ),
        child: Icon(icon, color: isSelected ? activeColor : Colors.white38, size: 20),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> destination, double imageHeight) {
    final Color themeColor = destination['couleur'] as Color;
    final String regionText = destination['region'] as String;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination['page'])).then((_) => _chargerFavoris()),
      child: Container(
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeColor.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 20, offset: const Offset(0, 10)),
            BoxShadow(color: themeColor.withOpacity(0.15), blurRadius: 25, spreadRadius: -2, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(destination['image'], height: imageHeight, width: double.infinity, fit: BoxFit.cover),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _cardDark.withOpacity(0.4),
                            _cardDark,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _bgDark.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withOpacity(0.6), width: 1),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8),
                        ],
                      ),
                      child: Text(
                        regionText,
                        style: GoogleFonts.cairo(
                          color: themeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination['nom'],
                      style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      destination['description'],
                      style: GoogleFonts.montserrat(color: const Color(0xFFA1A5B7), fontSize: 13, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: themeColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            'اكتشف',
                            style: GoogleFonts.cairo(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          // 🔄 Flèche orientée vers l'avant (gauche en RTL)
                          child: Icon(Icons.arrow_forward_rounded, color: themeColor, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFavoritesFolders(Map<String, Map<String, List<Map<String, dynamic>>>> grouped) {
    List<Widget> list = [];
    final List<Map<String, dynamic>> folderConfig = [
      {"title": "المدن التاريخية", "color": _accentGold, "icon": Icons.account_balance_rounded},
      {"title": "الطبيعة والمغامرة", "color": const Color(0xFF10B981), "icon": Icons.landscape_rounded},
      {"title": "البحر الأحمر", "color": const Color(0xFF0EA5E9), "icon": Icons.waves_rounded},
      {"title": "معلومات عملية", "color": const Color(0xFFEC4899), "icon": Icons.info_outline_rounded},
    ];

    for (var folder in folderConfig) {
      final String mainTitle = folder["title"] as String;
      final Color color = folder["color"] as Color;
      final IconData icon = folder["icon"] as IconData;
      final Map<String, List<Map<String, dynamic>>> subFolders = grouped[mainTitle] ?? {};
      final bool isExpanded = _foldersExpanded[mainTitle] ?? false;

      int totalItemsInFolder = 0;
      subFolders.forEach((subKey, itemsList) => totalItemsInFolder += itemsList.length);

      String subFolderLabel = mainTitle == "معلومات عملية"
          ? "$totalItemsInFolder معلومة"
          : "$totalItemsInFolder عنصر";

      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            onTap: () => setState(() => _foldersExpanded[mainTitle] = !isExpanded),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isExpanded ? color : color.withOpacity(0.3),
                  width: isExpanded ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                  if (isExpanded) BoxShadow(color: color.withOpacity(0.15), blurRadius: 15),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.3))),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mainTitle, style: GoogleFonts.cairo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subFolderLabel, style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: color, size: 22),
                ],
              ),
            ),
          ),
        ),
      );

      if (isExpanded) {
        subFolders.forEach((subTitle, items) {
          final bool isSubExpanded = _subFoldersExpanded[subTitle] ?? false;
          final int count = items.length;
          final String countLabel = mainTitle == "معلومات عملية" ? "$count معلومة" : "$count مكان";

          list.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, bottom: 10, end: 4),
              child: InkWell(
                onTap: () => setState(() => _subFoldersExpanded[subTitle] = !isSubExpanded),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _cardDarkSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Container(width: 3, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Icon(Icons.folder_special_rounded, color: color.withOpacity(0.8), size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(subTitle, style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
                        child: Text(countLabel, style: GoogleFonts.montserrat(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Icon(isSubExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          );

          if (isSubExpanded) {
            if (items.isNotEmpty) {
              for (var item in items) {
                list.add(Padding(padding: const EdgeInsetsDirectional.only(start: 24, bottom: 16, end: 8), child: _buildFavoriLieuCard(item)));
              }
            } else {
              list.add(Padding(
                padding: const EdgeInsetsDirectional.only(start: 32, bottom: 14, top: 2),
                child: Text("لا توجد عناصر محفوظة", style: GoogleFonts.montserrat(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic)),
              ));
            }
          }
        });
      }
    }
    return list;
  }

  Widget _buildFavoriLieuCard(Map<String, dynamic> item) {
    final String lieuNom = item['name'] ?? '';
    final String subCat = item['sub_category'] ?? '';
    final Color categoryColor = _getCategoryColor(subCat);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _cardDark,
        border: Border.all(color: categoryColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 14, offset: const Offset(0, 6)),
          BoxShadow(color: categoryColor.withOpacity(0.12), blurRadius: 16, spreadRadius: -2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(item['photo_url'] ?? '', width: double.infinity, fit: BoxFit.fitWidth),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(lieuNom, style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: () => _supprimerFavoriLieu(item),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: categoryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: categoryColor.withOpacity(0.4))),
                  child: Text(subCat, style: GoogleFonts.montserrat(color: categoryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(item['description'] ?? '', style: GoogleFonts.montserrat(color: const Color(0xFFA1A5B7), fontSize: 13, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _RouletteDialog extends StatefulWidget {
  final List<Map<String, String>> villes;
  final BuildContext parentContext;

  const _RouletteDialog({required this.villes, required this.parentContext});

  @override
  State<_RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<_RouletteDialog> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isFinished = false;
  String _selectedVille = '';

  @override
  void initState() {
    super.initState();
    _lancerAnimation();
  }

  void _lancerAnimation() {
    final random = Random();
    int steps = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (!mounted) return;
      setState(() {
        _currentIndex = random.nextInt(widget.villes.length);
        steps++;
      });

      if (steps >= 20) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isFinished = true;
            _selectedVille = widget.villes[_currentIndex]['nom']!;
          });
        }
      }
    });
  }

  void _relancerRoulette() {
    _timer?.cancel();
    setState(() {
      _isFinished = false;
      _selectedVille = '';
    });
    _lancerAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _naviguerVersVilleSelectionnee() {
    Navigator.pop(context);
    Widget pageDestination;

    switch (_selectedVille) {
      case 'القاهرة':
        pageDestination = const LeCairePage();
        break;
      case 'الأقصر':
        pageDestination = const LouxorPage();
        break;
      case 'أسوان':
        pageDestination = const AssouanPage();
        break;
      case 'الإسكندرية':
        pageDestination = const AlexandriePage();
        break;
      case 'الغردقة':
        pageDestination = const HurghadaPage();
        break;
      case 'شرم الشيخ':
        pageDestination = const SharmElSheikhPage();
        break;
      case 'الفيوم':
        pageDestination = const FayoumPage();
        break;
      case 'سيوة':
        pageDestination = const SiwaPage();
        break;
      case 'الصحراء':
        pageDestination = const DesertPage();
        break;
      default:
        pageDestination = const LeCairePage();
    }

    Navigator.push(
      widget.parentContext,
      MaterialPageRoute(builder: (context) => pageDestination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentVille = widget.villes[_currentIndex];

    return AlertDialog(
      backgroundColor: const Color(0xFF0D0E15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.5), width: 1.5),
      ),
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                ),
                child: const Icon(Icons.casino_rounded, color: Color(0xFFA78BFA), size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'روليت المدن',
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _isFinished ? '✨ تم الكشف عن الوجهة!' : 'جاري استشارة العراف...',
                style: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141622),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.15), blurRadius: 15),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        currentVille['image']!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 140,
                            height: 140,
                            color: Colors.grey[850],
                            child: const Icon(Icons.location_city, color: Colors.white54, size: 40),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentVille['nom']!,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (_isFinished)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _naviguerVersVilleSelectionnee,
                          child: Text(
                            'اكتشف هذه المدينة',
                            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _relancerRoulette,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(
                          'اختر مدينة أخرى',
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(
                  height: 30,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Color(0xFFA78BFA), strokeWidth: 2.5),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            left: -10,
            top: -10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateurWidget extends StatefulWidget {
  final ScrollController scrollController;

  const _GenerateurWidget({required this.scrollController});

  @override
  State<_GenerateurWidget> createState() => _GenerateurWidgetState();
}

class _GenerateurWidgetState extends State<_GenerateurWidget> {
  final List<String> toutesLesVilles = [
    'القاهرة', 'الأقصر', 'أسوان', 'الإسكندرية',
    'الغردقة', 'شرم الشيخ', 'الفيوم', 'سيوة', 'الصحراء'
  ];

  String? villeSelectionnee;
  bool estEnGenerationVitesse = false;
  bool estGenere = false;

  String affichageVitesseTexte = "جاري الاتصال بقاعدة البيانات...";
  int compteurVitesse = 0;
  Timer? _timerVitesse;
  String villeOngletActif = '';

  final Map<String, Map<String, dynamic>> donneeClimatiquesVilles = {
    'القاهرة': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يقدم يناير درجات حرارة لطيفة ومعتدلة خلال النهار، وهي مثالية لاستكشاف هضبة الجيزة والقاهرة الإسلامية دون المعاناة من الحرارة. الأمسيات باردة، لكن السطوع المستمر يضمن ظروف زيارة استثنائية.',
        2: 'يعتبر فبراير أحد أفضل الأشهر لزيارة العاصمة المصرية، مع مناخ مثالي للمشي واكتشاف المتاحف. يبقى الإقبال السياحي معتدلاً مقارنة بالعطلات، مما يسمح باكتشاف هادئ للغاية.',
        3: 'يبدأ شهر مارس في تدفئة الجو بلطف مع بقائه مناسباً للغاية للرحلات الخارجية. إنه فترة انتقالية مثالية للتجول في أسواق خان الخليلي.',
        4: 'يتمتع أبريل بشمس ربيع جميلة ودرجات حرارة دافئة لكنها محتملة. يجب مراقبة الخماسين، ولكنه بشكل عام وقت ممتاز للاستفادة من الحدائق والمقاهي في القاهرة.',
        5: 'في شهر مايو، تصبح حرارة القاهرة أكثر ثقلاً وخنقاً أثناء المشي على هضبة الجيزة. ترتفع درجات الحرارة بسرعة، مما يجعل الزيارات مرهقة.',
        6: 'يمثل يونيو بداية استقرار الأفران الصيفية الحضرية. الهواء الخانق والشمس الحارقة يحدان بشكل كبير من التنزه في المركز التاريخي.',
        7: 'يسجل يوليو درجات حرارة موجة حارة مرتبطة بالتلوث الحضري، مما يتحول بالاستكشافات الراجلة للقاهرة إلى تجربة مرهقة للمسافرين.',
        8: 'يعاني أغسطس من حرارة شديدة وهواء دافئ جداً يبطئ حركة المدينة بأكملها. فترة غير موصى بها لزيارة المعالم في الهواء الطلق.',
        9: 'يحافظ سبتمبر على حرارة صيفية متأخرة مهمة، مما يترك حجارة القاهرة شديدة السخونة والهواء ثقيلاً قبل وصول الخريف.',
        10: 'أكتوبر هو فترة رائعة للغاية لاستكشاف القاهرة، مع مناخ خريفي دافئ لكنه قابل للتنفس تماماً. تعود الظروف المثالية للاستمتاع الكامل بالمعالم.',
        11: 'يقدم نوفمبر طقساً رائعاً، يجمع بين الاعتدال والسطوع الأمثل دون حرارة الصيف الخانقة. إنه أحد أكثر الأشهر طلباً من قبل المسافرين لتشرب طاقة القاهرة.',
        12: 'ديسمبر لطيف للغاية خلال النهار مع مناخ بارد ومضيء، مثالي لزيارة الأهرامات. يجب الانتباه مع ذلك لعطلات نهاية العام التي تجذب أعداداً كبيرة من السياح.',
      }
    },
    'الأقصر': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يناير هو الفترة الملكية بامتياز في الأقصر، حيث يقدم درجات حرارة معتدلة مثالية لاستكشاف وادي الملوك ومعبد الكرنك. يفسح الجو البارد في الصباح المجال لشمس ساطعة.',
        2: 'يضمن فبراير ظروفاً مناخية استثنائية للإعجاب بالكنوز الفرعونية في صعيد مصر دون المعاناة من الحرارة الشديدة. إنه الشهر المثالي للتحليق بالمنطاد عند شروق الشمس.',
        3: 'يستفيد مارس من نعومة ربيع جميلة، مما يجعل اكتشاف مواقع البر الشرقي والغربي ممتعاً للغاية. تبدأ تدفقات السياح في التنظيم بعد ذروة الشتاء.',
        4: 'يجلب أبريل درجات حرارة أكثر دفئاً ولكنها تظل مناسبة جداً للزيارات الصباحية لمعالم الأقصر. المناظر الطبيعية الخضراء على طول النيل خلابة.',
        5: 'يشهد شهر مايو ارتفاع الحرارة لمستويات قاسية في صعيد مصر، مما يجعل زيارة المقابر الصخرية خانقة من منتصف الصباح.',
        6: 'يحول يونيو الأقصر إلى فرن حقيقي في الهواء الطلق، مع درجات حرارة قصوى تمنع أي زيارة مريحة للمقدسات الفرعونية.',
        7: 'يعاني يوليو من ذروة حرارة قاسية. انعكاس الشمس على أحجار المعابد يجعل الرحلات خطيرة بدون احتیاطات قصوى.',
        8: 'يحافظ أغسطس على حرارة صحراوية خانقة خلال النهار. تبقى المواقع الأثرية مهجورة بسبب درجات الحرارة المرتفعة جداً.',
        9: 'يبدأ سبتمبر انخفاضاً بطيئاً جداً في درجات الحرارة، لكن الحرارة تظل حارقة جداً لتقدير وادي الملوك بحق.',
        10: 'يمثل أكتوبر عودة الموسم السياحي المثالي في الأقصر، مع درجات حرارة تعود لتكون لطيفة وسطوع رائع للرحلات النيلية.',
        11: 'نوفمبر هو شهر رائع لزيارة الأقصر، يجمع بين المناخ المثالي، والضوء الذهبي المثالي للتصوير وراحة مطلقة في مجمع آمون.',
        12: 'يقدم ديسمبر أياماً مشمسة ودافئة بشكل ممتع، تليها ليالٍ باردة. إنه وقت سحرعيش مصر الفرعونية في ظروف مثالية.',
      }
    },
    'أسوان': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'أسوان في يناير هي ملاذ سلام مغمور بالشمس، مع مناخ مثالي للإبحار بالفلوكة وزيارة معبد فيلة. نعومة الهواء تجعل كل رحلة لا تُنسى.',
        2: 'يقدم فبراير طقساً جافاً وممشساً ولطيفاً بشكل رائع، مثالي لاكتشاف جزيرة إلفنتين والقرية النوبية في أجواء دافئة ومريحة.',
        3: 'يحافظ مارس على درجات حرارة مثالية للاستمتاع بجمال أسوان الأسطوري ومحيطها البري. المناخ مثالي للاسترخاء بجانب النهر.',
        4: 'يبدأ أبريل في تسخين الأجواء بشكل أكبر، لكن نسيم النيل البارد يجلب إنعاشاً مرحباً به أثناء الرحلات النهرية.',
        5: 'يمثل مايو بداية الحرارة الصحراوية الشديدة في أسوان، مما يجعل التنقل البري إلى أبو سمبل متعباً بشكل خاص.',
        6: 'يعاني يونيو من درجات حرارة حارقة شديدة. تفرض شمس شمال إفريقيا الحارقة تقييد الزيارات النهارية بشدة.',
        7: 'يسجل يوليو أعلى درجات الحرارة في مصر. الهواء الجاف جداً والحار يجعل التنزه على الكورنيش مستحيلاً في منتصف النهار.',
        8: 'يشهد أغسطس حرارة صحراوية ساحقة تنهك الأجسام. تصبح الرحلات بالفلوكة مرهقة جداً تحت الشمس المباشرة.',
        9: 'يحافظ سبتمبر على حرارة متبقية مهمة رغم تراجع طفيف، محتفظاً بأجواء شديدة السخونة على طول النهر.',
        10: 'يقدم أكتوبر مرة أخرى مناخاً رائعاً، دافئاً ومرحباً، مثالي لاستكشاف المعابد والتمتع بضيافة السكان الأسطورية.',
        11: 'نوفمبر هو شهر جنوني في أسوان، مع طقس ساطع وسماء صافية وجودة حياة لا تضاهى على ضفاف الماء.',
        12: 'ديسمبر مثالي للهرب من كآبة أوروبا ومنح النفس استراحة ساحرة تحت شمس النوبة وجنوب مصر الساطعة.',
      }
    },
    'الإسكندرية': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يناير في الإسكندرية يقدم مناخاً منعشاً وبارداً، مثالي لزيارة المكتبة الكبرى، قلعة قايتباي والتجول بهدوء بدون زحام.',
        2: 'يسمح فبراير باكتشاف التراث اليوناني الروماني والمتاحف الإسكندرية تحت درجة حرارة لطيفة جداً وناعمة على ضفاف المتوسط.',
        3: 'مارس مثالي للاستفادة من شمس الربيع اللطيفة على الكورنيش، استكشاف السرداب وتقدير أجواء المدينة الفكرية.',
        4: 'يقدم أبريل ظروفاً مثالية مع هواء نقي ودرجات حرارة مثالية للتجول في حدائق قصر المنتزة الخلابة.',
        5: 'يشهد مايو ارتفاع رطوبة المتوسط تدريجياً مع درجات الحرارة، مما يجعل الهواء ثقيلاً وأقل راحة للمشي.',
        6: 'يترافق يونيو مع ذروة إقبال محلي مهم وحرارة رطبة قد تجعل الزيارات الثقافية أقل راحة.',
        7: 'يجذب يوليو حشوداً معتبرة على الساحل ويسجل رطوبة ساحلية عالية وخانقة تعكر صفو الهدوء.',
        8: 'يشهد أغسطس تشبعاً سياحياً أقصى على الكورنيش إضافة إلى ثقل مناخ ملحوظ، غير مخصص للسياحة الثقافية.',
        9: 'يحافظ سبتمبر على رطوبة وحرارة ثقيلة قبل التراجع الحقيقي لموسم الصيف على الساحل الشمالي.',
        10: 'يتلطف أكتوبر بشكل ممتع، معلناً عودة مناخ خريفي هادئ، مثالي للنزهات الثقافية أمام الأمواج.',
        11: 'يقدم نوفمبر طقساً لطيفاً وهادئاً جداً لتأمل المناظر البحرية واستكشاف الآثار القديمة بكل هدوء.',
        12: 'يقدم ديسمبر أجواء متوسطية رومانسية وباردة جداً، مثالية لاكتشاف قلب الإسكندرية التاريخي.',
      }
    },
    'الغردقة': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يناير في الغردقة يقدم شلساً ساطعاً ودرجات حرارة لطيفة مثالية لرحلات الصحراء، الدباب والراحة.',
        2: 'يستفيد فبراير من مناخ مشمس لطيف جداً، مثالي للاستفادة من هدوء المنتجعات خارج الموسم والهواء البحري المنعش.',
        3: 'يقدم مارس تدفئة مثالية للهواء والبحر، مما يسمح باستئناف السنوركلينج والغوص في ظروف ممتازة.',
        4: 'أبريل هو شهر استثنائي للأغردقة، يجمع بين حرارة خارجية مثالية ودرجات حرارة رائعة لاستكشاف جزيرة جفتون.',
        5: 'يجلب مايو سطوعاً حارقاً وإشعاع فوق بنفسجي قوي يجعل الاسترخاء الطويل تحت الشمس متعباً.',
        6: 'يعاني يونيو من درجات حرارة صيفية عالية. بدون غطس مستمر في الماء، تصبح الحرارة على الأرض ثقيلة جداً.',
        7: 'يشهد يوليو درجات حرارة ساحلية قصوى تحت شمس قاسية. يجب تجنب الأنشطة خارج الماء.',
        8: 'يتميز أغسطس بذروة حرارة شديدة على شاطئ البحر الأحمر والتي تتطلب البقاء في الظل معظم اليوم.',
        9: 'يحافظ سبتمبر على درجات حرارة أرضية حارقة وخانقة قبل وصول درجات حرارة الخريف الأكثر لطفاً.',
        10: 'أكتوبر هو أحد أفضل أشهر السنة في الغردقة، مقدمًا توازناً مثالياً بين الحرارة اللطيفة والبحر الصافي.',
        11: 'يوفر نوفمبر سطوعاً رائعاً ودرجات حرارة لطيفة جداً، مثالية للهروب إلى الشاطئ قبل الشتاء.',
        12: 'يجذب ديسمبر المسافرين الباحثين عن شمس الشتاء للاحتفال بنهاية العام وأقدامهم في الماء.',
      }
    },
    'شرم الشيخ': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يناير في شرم الشيخ يتمتع بمناخ جاف وممشس، محمي بسلاسل جبال سيناء، مما يضمن هرباً شتوياً لطيفاً تحت النخيل.',
        2: 'فبراير مثالي للجمع بين تسلق جبل سيناء والغوص في الشعاب المحمية لراس محمد بفضل مناخ لطيف جداً.',
        3: 'يقدم مارس ظروفاً جوية مثالية، دافئة بدون إفراط، مثالية لزيارة دير سانت كاترين والصحراء.',
        4: 'أبريل هو شهر مبارك لشرم الشيخ، مع مياه شفافة مسخنة بشكل مثالي ودرجات حرارة خارجية رائعة.',
        5: 'يشهد مايو ارتفاعاً هائلاً في الترمومتر عند سفح مرتفعات سيناء، مما يجعل الرحلات في الصحراء مرهقة جداً.',
        6: 'يعاني يونيو من حرارة صحراوية شديدة تحول الساحل إلى فرن لا يمنح الراحة فيه سوى الغوص البحري.',
        7: 'يسجل يوليو درجات حرارة قاسية يومية تخنق المناطق الحضرية في خليج نعمة وشرم القديمة.',
        8: 'يعرض أغسطس أقسى درجات الحرارة في السنة على خليج العقبة، مما يحد كثيراً من الأنشطة خارج الماء.',
        9: 'يحافظ سبتمبر على أجواء حارقة وثقيلة على سيناء قبل التلطف التدريجي لفترة ما بعد الموسم.',
        10: 'أكتوبر رائع، مقدمًا تكتيكاً مثالياً بين الحرارة اللطيفة، الهدوء وظروف الغوص الاستثنائية.',
        11: 'نوفمبر هو أحد أكثر الأشهر ملاءمة لزيارة جنوب سيناء براحة مناخية تامة وتحت سماء زرقاء واسعة.',
        12: 'ديسمبر مطلوب جداً للهروب من برودة أوروبا تحت شمس دائمة في الطرف الجنوبي لشبه جزيرة سيناء.',
      }
    },
    'الفيوم': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يناير في الفيوم يقدم مناخاً بارداً ومنعشاً، مثالي لمراقبة الطيور المهاجرة حول بحيرة قارون والمشي نحو الشلالات.',
        2: 'يضمن فبراير أياماً مشمسة ولطيفة، مثالية لاستكشاف قرية الحرفيين في تونس وورش الفخار.',
        3: 'يستفيد مارس من طقس ربيع رائع، مثالي للمغامرة في المناظر الطبيعية الفريدة بين الصحراء والمناطق الرطبة.',
        4: 'أبريل مثالي لرحلة ممتعة في الفيوم، مستفيداً من مناخ دافئ ومضيء قبل وصول الحرارة الشديدة.',
        5: 'يشهد مايو تسارعاً في ارتفاع الحرارة بمنخفض الواحة، مما يجعل الرحلات حول البحيرات شاقة جداً.',
        6: 'يعاني يونيو من درجات حرارة صيفية عالية تجفف الهواء وتجعل التنزه في الصحراء خطيراً بدون مرشد.',
        7: 'يحول يوليو منطقة وادي الريان إلى حوض موجة حارة خانقة غير موصى بها للمتنزهين.',
        8: 'يفرض أغسطس ظروف حرارة صحراوية قصوى على جميع المواقع الطبيعية لواحة الفيوم.',
        9: 'يظل سبتمبر موسوماً بحرارة نهارية قوية تؤخر إعادة فتح المخيمات الليلية في الكثبان.',
        10: 'أكتوبر فترة رائعة لإعجاب ألوان الواحة والاستفادة من البحيرة عند غروب الشمس.',
        11: 'يقدم نوفمبر طقساً هادئاً، لطيفاً ومناسباً جداً للاكتشاف الحرفي والطبيعي لمناظر الفيوم.',
        12: 'يقدم ديسمبر مناخاً بارداً ومنعشاً، مثالي للمصورين ومحبي الفضاءات الواسعة المحفوظة.',
      }
    },
    'سيوة': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يناير في سيوة يقدم أياماً مشمسة ولطيفة جداً، مثالية للسباحة في ينابيع كليوباترا الساخنة، رغم الأمسيات الباردة.',
        2: 'فبراير فترة رائعة لاستكشاف جبل الموتى وبحيرات الملح الخلابة دون المعاناة من حرارة الصحراء.',
        3: 'يضمن مارس مناخ ربيع رائع، مثالي للمغامرة في قلب الواحة المعزولة وبساتين النخيل العريقة.',
        4: 'يوفر أبريل طقساً حاراً ومضيئاً، مثالي لعيش تجربة الطفو الفريدة على مياه بحيرات الملح الفيروزية.',
        5: 'يجلب مايو أول موجات حر الصحراء الليبية، مما يجعل استكشاف حصن شلي شاقاً جداً في منتصف النهار.',
        6: 'يخضع يونيو سيوة لحرارة صحراوية حارقة تشلل الواحة خلال الساعات المركزية من اليوم.',
        7: 'يوليو هو شهر حار جداً في قلب الكثبان، حيث تتجاوز درجات الحرارة عتبات الراحة بانتظام.',
        8: 'يعاني أغسطس من درجات حرارة صحراوية سحاقية تجعل عبور بحر الرمال الأعظم صعباً للغاية.',
        9: 'يشهد سبتمبر بقاء الحرارة الصيفية بثقل على بساتين النخيل قبل التراجع الخريفي الكبير.',
        10: 'يقدم أكتوبر مناخاً خريفياً مثالياً، لطيفاً وساحراً لاكتشاف حصن شلي وأسرار الواحة.',
        11: 'يوفر نوفمبر طقساً رائعاً، مناسباً لرحلات الدفع الرباعي في بحر الرمال الأعظم والحمامات الاسترخائية.',
        12: 'ديسمبر مثالي للاستمتاع بالمناظر الفريدة تحت شمس شتاء ساطعة، مع التخطيط لملابس دافئة للمساء.',
      }
    },
    'الصحراء': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'يناير مثالي للتخييم في الصحراء البيضاء والصحراء السوداء، مع أيام لطيفة وليالٍ باردة جداً تحت النجوم.',
        2: 'يقدم فبراير مناخاً جافاً وسماء مرصعة بالنجوم بنقاء استثنائي لعشاق التخييم وعلم الفلك.',
        3: 'يقدم مارس ظروفاً مثالية للرحلات والرحلات الاستكشافية بالدفع الرباعي وسط التشكيلات الحجرية النحتية بالرياح.',
        4: 'يضمن أبريل طقساً حاراً وجافاً، مناسباً جداً لاتساع الفضاءات الكبرى وتصوير المناظر الطبيعية.',
        5: 'يحول مايو الامتدادات الرملية للصحراء السوداء إلى أفران محمومة منذ ساعات الصباح الأولى.',
        6: 'يجعل يونيو التخييم في قلب الصحراء قاسياً بسبب الحرارة الخانقة والرياح الحارة.',
        7: 'يسجل يوليو قيماً قياسية صحراوية تجعل أي رحلة بالدفع الرباعي مرهقة ومخاطرة.',
        8: 'يشهد أغسطس أخطر درجات الحرارة في السنة وسط التشكيلات الصخرية الجيرية للصحراء البيضاء.',
        9: 'يحافظ سبتمبر على انعكاس حراري قوي على الرمال مما يجعل الرحلات النهارية متعبة.',
        10: 'يقدم أكتوبر مناخاً رائعاً، مستاباً ومثالياً للمغامرات الصحراوية والمساء حول نار المخيم.',
        11: 'نوفمبر هو أحد أفضل أشهر السنة لعيش التجربة الساحرة للصحراء البيضاء بهدوء مطلق.',
        12: 'يضمن ديسمبر أياماً لطيفة ومضيئة تليها ليالٍ باردة ولكنها لا تنسى تحت قبة الفضاء السماوي.',
      }
    },
  };

  @override
  void dispose() {
    _timerVitesse?.cancel();
    super.dispose();
  }

  void _lancerGenerationHauteVitesse() {
    if (villeSelectionnee == null) return;

    setState(() {
      estEnGenerationVitesse = true;
      estGenere = false;
      compteurVitesse = 0;
      villeOngletActif = villeSelectionnee!;
    });

    final random = Random();
    final etapesTexte = [
      "جاري الاتصال بقاعدة البيانات...",
      "تحليل المناخ المصري...",
      "حساب درجات الحرارة الموسمية...",
      "تقييم التدفق السياحي...",
      "توليد نصائح الزيارة...",
    ];

    _timerVitesse?.cancel();
    _timerVitesse = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;
      setState(() {
        compteurVitesse++;
        affichageVitesseTexte = etapesTexte[random.nextInt(etapesTexte.length)] +
            " [${random.nextInt(99)}%]";
      });

      if (compteurVitesse >= 20) {
        timer.cancel();
        if (mounted) {
          setState(() {
            estEnGenerationVitesse = false;
            estGenere = true;
          });
        }
      }
    });
  }

  List<Map<String, dynamic>> _getMoisPourVille(String nomVille) {
    final nomsMois = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    final saisons = [
      'الشتاء', 'الشتاء', 'الربيع', 'الربيع', 'الربيع', 'الصيف',
      'الصيف', 'الصيف', 'الخريف', 'الخريف', 'الخريف', 'الشتاء'
    ];

    final dataVille = donneeClimatiquesVilles[nomVille] ?? donneeClimatiquesVilles['القاهرة']!;
    final List<int> moisFavoris = List<int>.from(dataVille['moisFavoris'] ?? []);
    final Map<int, String> descriptions = Map<int, String>.from(dataVille['descriptions'] ?? {});

    List<Map<String, dynamic>> resultat = [];

    for (int i = 1; i <= 12; i++) {
      final bool estBon = moisFavoris.contains(i);
      resultat.add({
        'nom': nomsMois[i - 1],
        'estBon': estBon,
        'saison': saisons[i - 1],
        'raison': descriptions[i] ?? 'تم تحليل الفترة لزيارة $nomVille.',
      });
    }

    return resultat;
  }

  @override
  Widget build(BuildContext context) {
    final listeMois = _getMoisPourVille(villeOngletActif);
    const goldColor = Color(0xFFD4AF37);

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goldColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: goldColor.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: goldColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'مخطط الزيارة 🇪🇬',
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'اختر مدينة للحصول على نصائح مخصصة.',
              style: GoogleFonts.montserrat(color: const Color(0xFFA1A5B7), fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFBBF24), size: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تنبيه مناخي هام ☀️',
                          style: GoogleFonts.cairo(color: Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'حتى لو كانت الفترة موصى بها، احرص دائمًا على جلب الماء ووسائل الحماية من الشمس!',
                          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'اختيار المدينة:',
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var ville in toutesLesVilles)
                  FilterChip(
                    label: Text(
                      ville,
                      style: GoogleFonts.cairo(
                        color: (villeSelectionnee == ville) ? Colors.black : Colors.white,
                        fontWeight: (villeSelectionnee == ville) ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    selected: (villeSelectionnee == ville),
                    selectedColor: goldColor,
                    backgroundColor: const Color(0xFF141622),
                    checkmarkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: (villeSelectionnee == ville) ? goldColor : goldColor.withOpacity(0.3),
                      ),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (villeSelectionnee == ville) {
                          villeSelectionnee = null;
                          villeOngletActif = '';
                          estGenere = false;
                        } else {
                          villeSelectionnee = ville;
                          villeOngletActif = ville;
                          estGenere = false;
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: (villeSelectionnee == null || estEnGenerationVitesse)
                      ? null
                      : LinearGradient(colors: [goldColor, const Color(0xFFB8860B)]),
                  boxShadow: (villeSelectionnee == null || estEnGenerationVitesse)
                      ? []
                      : [BoxShadow(color: goldColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton.icon(
                  onPressed: (estEnGenerationVitesse || villeSelectionnee == null)
                      ? null
                      : _lancerGenerationHauteVitesse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                    foregroundColor: Colors.black,
                    disabledForegroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: estEnGenerationVitesse
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Icon(Icons.flash_on_rounded, size: 20, color: villeSelectionnee == null ? Colors.white24 : Colors.black),
                  label: Text(
                    villeSelectionnee == null
                        ? 'اختر مدينة أولاً'
                        : (estEnGenerationVitesse ? 'جاري التحليل...' : 'بدء التوليد السريع'),
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (estEnGenerationVitesse)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.speed_rounded, size: 50, color: goldColor),
                      const SizedBox(height: 16),
                      Text(
                        affichageVitesseTexte,
                        style: GoogleFonts.shareTechMono(
                          color: goldColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (estGenere && villeSelectionnee != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: goldColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: goldColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_city_rounded, color: goldColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'التحليل السنوي لـ $villeOngletActif',
                            style: GoogleFonts.cairo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (var m in listeMois)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: (m['estBon'] as bool)
                            ? const Color(0xFF10B981).withOpacity(0.08)
                            : const Color(0xFFEF4444).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (m['estBon'] as bool)
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : const Color(0xFFEF4444).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        m['nom'],
                                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${m['saison']})',
                                      style: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (m['estBon'] as bool)
                                      ? const Color(0xFF10B981).withOpacity(0.2)
                                      : const Color(0xFFEF4444).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (m['estBon'] as bool) ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                      size: 13,
                                      color: (m['estBon'] as bool) ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (m['estBon'] as bool) ? 'ممتاز' : 'غير موصى به',
                                      style: GoogleFonts.cairo(
                                        color: (m['estBon'] as bool) ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            m['raison'],
                            style: GoogleFonts.montserrat(color: const Color(0xFFA1A5B7), fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }
}