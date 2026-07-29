import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:ui';

import 'anglais/le caire.dart';
import 'anglais/alexandrie.dart';
import 'anglais/louxor.dart';
import 'anglais/assouan.dart';
import 'anglais/siwa.dart';
import 'anglais/fayoum.dart';
import 'anglais/desert.dart';
import 'anglais/sharm.dart';
import 'anglais/Hurghada.dart';
import 'anglais/airlines.dart';
import 'anglais/gastronomie_page.dart';

class HomeEnglish extends StatefulWidget {
  const HomeEnglish({super.key});

  @override
  State<HomeEnglish> createState() => _HomeEnglishState();
}

class _HomeEnglishState extends State<HomeEnglish> {
  List<String> _favorisLieuxJson = [];

  // CLÉ DE STOCKAGE UNIQUE ET ISOLÉE POUR L'ANGLAIS
  final String _cleStockageLieux = 'favoris_en';

  int _selectedIndex = 0; // 0 = Guide (Home), 1 = Favorites

  // Palette de couleurs Premium
  final Color _bgDark = const Color(0xFF090A0F);
  final Color _cardDark = const Color(0xFF14151B);
  final Color _accentGold = const Color(0xFFDFB15B);

  final Map<String, bool> _foldersExpanded = {
    "Historical Cities": false,
    "Red Sea": false,
    "Nature & Adventure": false,
    "Practical Info": false,
  };

  final Map<String, bool> _subFoldersExpanded = {
    "Cairo": false,
    "Alexandria": false,
    "Luxor": false,
    "Aswan": false,
    "Sharm El-Sheikh": false,
    "Hurghada": false,
    "Siwa": false,
    "Fayoum": false,
    "Desert": false,
    "Gastronomy": false,
  };

  final List<Map<String, dynamic>> destinations = [
    {
      'nom': "Cairo",
      'description': "Vibrant capital, cradle of ancient pyramids and the beating heart of modern Egypt.",
      'image': "assets/images/le caire.jpg",
      'couleur': const Color(0xFFDFB15B),
      'region': "Historical Cities",
      'page': const CairoPage(),
    },
    {
      'nom': "Alexandria",
      'description': "Pearl of the Mediterranean, this legendary city blends European architecture with Egyptian heritage.",
      'image': "assets/images/alexandrie.jpg",
      'couleur': const Color(0xFF4EA8DE),
      'region': "Historical Cities",
      'page': const AlexandriePage(),
    },
    {
      'nom': "Luxor",
      'description': "The world's greatest open-air museum, home to the majestic Karnak temples.",
      'image': "assets/images/louxor.jpg",
      'couleur': const Color(0xFFF39C12),
      'region': "Historical Cities",
      'page': const LouxorPage(),
    },
    {
      'nom': "Aswan",
      'description': "A haven of peace on the banks of the Nile, famous for its Nubian landscapes and absolute serenity.",
      'image': "assets/images/assouan.jpg",
      'couleur': const Color(0xFFD4AC0D),
      'region': "Historical Cities",
      'page': const AssouanPage(),
    },
    {
      'nom': "Siwa",
      'description': "A mystical oasis isolated in the desert, renowned for its hot springs.",
      'image': "assets/images/siwa.jpeg",
      'couleur': const Color(0xFF1ABC9C),
      'region': "Nature & Adventure",
      'page': const SiwaPage(),
    },
    {
      'nom': "Fayoum",
      'description': "A unique ecosystem between salt lakes and desert, where wild nature meets history.",
      'image': "assets/images/fayoum.jpeg",
      'couleur': const Color(0xFF2ECC71),
      'region': "Nature & Adventure",
      'page': const FayoumPage(),
    },
    {
      'nom': "Desert",
      'description': "An unforgettable expedition into the heart of the White and Black Desert.",
      'image': "assets/images/R.jpg",
      'couleur': const Color(0xFFE67E22),
      'region': "Nature & Adventure",
      'page': const DesertPage(),
    },
    {
      'nom': "Sharm El-Sheikh",
      'description': "Global seaside destination, renowned for the richness of its coral reefs.",
      'image': "assets/images/sharm.jpg",
      'couleur': const Color(0xFF3498DB),
      'region': "Red Sea",
      'page': const SharmElSheikhPage(),
    },
    {
      'nom': "Hurghada",
      'description': "Dynamic seaside resort offering fine sandy beaches and magical excursions.",
      'image': "assets/images/j.jpg",
      'couleur': const Color(0xFF00D2FF),
      'region': "Red Sea",
      'page': const HurghadaPage(),
    },
    {
      'nom': "Airlines",
      'description': "All necessary information on international flights and local connections.",
      'image': "assets/images/air.jpg",
      'couleur': const Color(0xFFE74C3C),
      'region': "Practical Info",
      'page': const AirlinesPage(),
    },
    {
      'nom': "Typical Dishes",
      'description': "Discover a gastronomy rich in flavors: koshary, falafels, and oriental pastries.",
      'image': "assets/images/p.jpg",
      'couleur': const Color(0xFFFD79A8),
      'region': "Practical Info",
      'page': const GastronomyPage(),
    },
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

  // --- LOGIQUE DE TRI STRICTE TRADUITE EN ANGLAIS ---
  String _detectRegion(Map<String, dynamic> item) {
    final String rawRegion = item['region'] ?? '';
    final String rawSub = item['sub_folder'] ?? '';

    // 1. Strict confidence in main English keys
    if (rawRegion == "Historical Cities" ||
        rawRegion == "Red Sea" ||
        rawRegion == "Nature & Adventure" ||
        rawRegion == "Practical Info") {
      return rawRegion;
    }

    // 2. Fallback based ONLY on exact English sub_folder names
    if (rawSub == "Gastronomy") return "Practical Info";
    if (rawSub == "Cairo" || rawSub == "Alexandria" || rawSub == "Luxor" || rawSub == "Aswan") return "Historical Cities";
    if (rawSub == "Sharm El-Sheikh" || rawSub == "Hurghada") return "Red Sea";
    if (rawSub == "Siwa" || rawSub == "Fayoum" || rawSub == "Desert") return "Nature & Adventure";

    // Default fallback
    return "Historical Cities";
  }

  String _detectSubFolder(Map<String, dynamic> item, String region) {
    final String rawSub = item['sub_folder'] ?? '';

    // 1. Strict confidence in English subfolders
    final validSubFolders = [
      "Cairo", "Alexandria", "Luxor", "Aswan",
      "Sharm El-Sheikh", "Hurghada",
      "Siwa", "Fayoum", "Desert",
      "Gastronomy"
    ];

    if (validSubFolders.contains(rawSub)) {
      return rawSub;
    }

    // 2. Safety net: Force the correct folder based on the region
    if (region == "Practical Info") return "Gastronomy";
    if (region == "Historical Cities") return "Cairo";
    if (region == "Red Sea") return "Sharm El-Sheikh";
    if (region == "Nature & Adventure") return "Desert";

    return "Cairo";
  }

  Color _getCategoryColor(String category) {
    // Handling both potential FR and EN strings if some old data is present,
    // but primarily expecting English categories now.
    switch (category) {
      case "Monuments": return const Color(0xFFDFB15B);
      case "Traditional Markets":
      case "Marchés traditionnels": return Colors.redAccent;
      case "Historical Sites":
      case "Lieux historiques": return Colors.blueAccent;
      case "Architecture": return Colors.purpleAccent;
      case "Relaxation Spots":
      case "Lieux de détente": return Colors.tealAccent;
      case "Gastronomy":
      case "Gastronomie": return const Color(0xFFFD79A8);
      case "Monuments & Culture": return Colors.amber;
      case "Must-do Excursions":
      case "Excursions incontournables": return Colors.purpleAccent;
      case "Sea & Nature":
      case "Mer & Nature": return Colors.blueAccent;
      case "Activities":
      case "Activités": return Colors.redAccent;
      case "Relaxation & Nightlife":
      case "Détente & Vie nocturne": return Colors.purpleAccent;
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> doubleGroupedFavorites = {
      "Historical Cities": {
        "Cairo": [],
        "Alexandria": [],
        "Luxor": [],
        "Aswan": [],
      },
      "Red Sea": {
        "Sharm El-Sheikh": [],
        "Hurghada": [],
      },
      "Nature & Adventure": {
        "Siwa": [],
        "Fayoum": [],
        "Desert": [],
      },
      "Practical Info": {
        "Gastronomy": [],
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

    return PopScope(
      canPop: _selectedIndex == 0 && !Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _gererRetour();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _bgDark,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, top: 20, bottom: 20, right: 24),
                    child: Row(
                      children: [
                        if (Navigator.canPop(context) || _selectedIndex == 1) ...[
                          GestureDetector(
                            onTap: _gererRetour,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: _cardDark, shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Official Guide", style: GoogleFonts.montserrat(color: _accentGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3)),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  children: const [TextSpan(text: "Eternal "), TextSpan(text: "Egypt", style: TextStyle(fontStyle: FontStyle.italic))],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(color: _cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeaderNavItem(index: 0, icon: Icons.compass_calibration_rounded, activeColor: _accentGold),
                              const SizedBox(width: 4),
                              _buildHeaderNavItem(index: 1, icon: Icons.favorite_rounded, activeColor: Colors.redAccent),
                            ],
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
                      final dest = destinations[index];
                      return Padding(padding: const EdgeInsets.only(bottom: 24), child: _buildDestinationCard(dest, 240));
                    },
                    childCount: destinations.length,
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
        ),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent, shape: BoxShape.circle),
        child: Icon(icon, color: isSelected ? activeColor : Colors.white38, size: 20),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> destination, double imageHeight) {
    final Color themeColor = destination['couleur'] as Color;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination['page'])).then((_) => _chargerFavoris()),
      child: Container(
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeColor.withOpacity(0.2), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.55), blurRadius: 16, offset: const Offset(0, 8)),
            BoxShadow(color: themeColor.withOpacity(0.25), blurRadius: 12, spreadRadius: -2, offset: const Offset(0, 4)),
            BoxShadow(color: themeColor.withOpacity(0.12), blurRadius: 40, spreadRadius: -4, offset: const Offset(0, 16)),
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
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.85)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: themeColor.withOpacity(0.5), width: 1)),
                      child: Text(destination['region'].toUpperCase(), style: GoogleFonts.montserrat(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                    Text(destination['nom'], style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    const SizedBox(height: 8),
                    Text(destination['description'], style: GoogleFonts.montserrat(color: const Color(0xFF9E9FA5), fontSize: 13, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: themeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                          child: Text('Click to discover', style: GoogleFonts.montserrat(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: themeColor, size: 18),
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
      {"title": "Historical Cities", "color": _accentGold, "icon": Icons.location_city_rounded},
      {"title": "Nature & Adventure", "color": Colors.tealAccent, "icon": Icons.landscape_rounded},
      {"title": "Red Sea", "color": Colors.blueAccent, "icon": Icons.waves_rounded},
      {"title": "Practical Info", "color": Colors.redAccent, "icon": Icons.info_outline_rounded},
    ];

    for (var folder in folderConfig) {
      final String mainTitle = folder["title"] as String;
      final Color color = folder["color"] as Color;
      final IconData icon = folder["icon"] as IconData;
      final Map<String, List<Map<String, dynamic>>> subFolders = grouped[mainTitle] ?? {};
      final bool isExpanded = _foldersExpanded[mainTitle] ?? false;

      int totalItemsInFolder = 0;
      subFolders.forEach((subKey, itemsList) => totalItemsInFolder += itemsList.length);

      String subFolderLabel;
      if (mainTitle == "Practical Info") {
        subFolderLabel = "$totalItemsInFolder info";
      } else {
        subFolderLabel = "$totalItemsInFolder ${totalItemsInFolder <= 1 ? 'place' : 'places'}";
      }

      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _foldersExpanded[mainTitle] = !isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isExpanded ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1),
              ),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mainTitle, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subFolderLabel, style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 20),
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
          final String countLabel = mainTitle == "Practical Info"
              ? "$count info"
              : "$count ${count <= 1 ? 'place' : 'places'}";

          list.add(
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, right: 4),
              child: InkWell(
                onTap: () => setState(() => _subFoldersExpanded[subTitle] = !isSubExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1B1C23),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.02), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
                  child: Row(
                    children: [
                      Container(width: 3, height: 16, decoration: BoxDecoration(color: color.withOpacity(0.7), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Icon(Icons.folder_open_rounded, color: color.withOpacity(0.7), size: 16),
                      const SizedBox(width: 10),
                      Expanded(child: Text(subTitle, style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                        child: Text(countLabel, style: GoogleFonts.montserrat(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Icon(isSubExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          );

          if (isSubExpanded) {
            if (items.isNotEmpty) {
              for (var item in items) {
                list.add(Padding(padding: const EdgeInsets.only(left: 24, bottom: 16, right: 8), child: _buildFavoriLieuCard(item)));
              }
            } else {
              list.add(Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 12, top: 2),
                child: Text(mainTitle == "Practical Info" ? "No info saved" : "No place saved", style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic)),
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
        border: Border.all(color: categoryColor.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.55), blurRadius: 12, offset: const Offset(0, 6)),
          BoxShadow(color: categoryColor.withOpacity(0.22), blurRadius: 10, spreadRadius: -2, offset: const Offset(0, 4)),
          BoxShadow(color: categoryColor.withOpacity(0.1), blurRadius: 28, spreadRadius: -4, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(item['photo_url'] ?? '', width: double.infinity, fit: BoxFit.fitWidth)
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(lieuNom, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: () => _supprimerFavoriLieu(item),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(subCat, style: GoogleFonts.montserrat(color: categoryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(item['description'] ?? '', style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 13, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }
}