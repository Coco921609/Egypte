import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
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

  // UNIQUE AND ISOLATED STORAGE KEY FOR ENGLISH
  final String _cleStockageLieux = 'favoris_en';

  int _selectedIndex = 0; // 0 = Guide (Home), 1 = Favorites

  // Ultra High-End Pharaonic Palette
  final Color _bgDark = const Color(0xFF07080E); // Obsidian Black
  final Color _cardDark = const Color(0xFF11131C); // Deep Onyx
  final Color _cardDarkSecondary = const Color(0xFF181A26);
  final Color _accentGold = const Color(0xFFD4AF37); // Royal Pharaonic Gold
  final Color _accentGoldLight = const Color(0xFFF3E5AB); // Gold Highlight
  final Color _lapisBlue = const Color(0xFF1E3A8A); // Lapis-Lazuli Blue
  final Color _papyrusBg = const Color(0xFF1A1813); // Dark Papyrus Background

  // EXACT CATEGORIES DEFINED AND ALIGNED EVERYWHERE
  final Map<String, bool> _foldersExpanded = {
    "Historical Cities": false,
    "Nature & Adventure": false,
    "Red Sea": false,
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
      'couleur': const Color(0xFFD4AF37),
      'region': "Historical Cities",
      'page': const CairoPage(),
    },
    {
      'nom': "Alexandria",
      'description': "Pearl of the Mediterranean, this legendary city blends European architecture with Egyptian heritage.",
      'image': "assets/images/alexandrie.jpg",
      'couleur': const Color(0xFF38BDF8),
      'region': "Historical Cities",
      'page': const AlexandriePage(),
    },
    {
      'nom': "Luxor",
      'description': "The world's greatest open-air museum, home to the majestic Karnak temples.",
      'image': "assets/images/louxor.jpg",
      'couleur': const Color(0xFFF59E0B),
      'region': "Historical Cities",
      'page': const LouxorPage(),
    },
    {
      'nom': "Aswan",
      'description': "A haven of peace on the banks of the Nile, famous for its Nubian landscapes and absolute serenity.",
      'image': "assets/images/assouan.jpg",
      'couleur': const Color(0xFFEAB308),
      'region': "Historical Cities",
      'page': const AssouanPage(),
    },
    {
      'nom': "Siwa",
      'description': "A mystical oasis isolated in the desert, renowned for its hot springs.",
      'image': "assets/images/siwa.jpeg",
      'couleur': const Color(0xFF10B981),
      'region': "Nature & Adventure",
      'page': const SiwaPage(),
    },
    {
      'nom': "Fayoum",
      'description': "A unique ecosystem between salt lakes and desert, where wild nature meets history.",
      'image': "assets/images/fayoum.jpeg",
      'couleur': const Color(0xFF34D399),
      'region': "Nature & Adventure",
      'page': const FayoumPage(),
    },
    {
      'nom': "Desert",
      'description': "An unforgettable expedition into the heart of the White and Black Desert.",
      'image': "assets/images/R.jpg",
      'couleur': const Color(0xFFF97316),
      'region': "Nature & Adventure",
      'page': const DesertPage(),
    },
    {
      'nom': "Sharm El-Sheikh",
      'description': "Global seaside destination, renowned for the richness of its coral reefs.",
      'image': "assets/images/sharm.jpg",
      'couleur': const Color(0xFF0EA5E9),
      'region': "Red Sea",
      'page': const SharmElSheikhPage(),
    },
    {
      'nom': "Hurghada",
      'description': "Dynamic seaside resort offering fine sandy beaches and magical excursions.",
      'image': "assets/images/j.jpg",
      'couleur': const Color(0xFF06B6D4),
      'region': "Red Sea",
      'page': const HurghadaPage(),
    },
    {
      'nom': "Airlines",
      'description': "All necessary information on international flights and local connections.",
      'image': "assets/images/air.jpg",
      'couleur': const Color(0xFFEF4444),
      'region': "Practical Info",
      'page': const AirlinesPage(),
    },
    {
      'nom': "Typical Dishes",
      'description': "Discover a gastronomy rich in flavors: koshary, falafels, and oriental pastries.",
      'image': "assets/images/p.jpg",
      'couleur': const Color(0xFFEC4899),
      'region': "Practical Info",
      'page': const GastronomyPage(),
    },
  ];

  final List<Map<String, String>> villesRoulette = [
    {'nom': "Cairo", 'image': "assets/images/le caire.jpg"},
    {'nom': "Alexandria", 'image': "assets/images/alexandrie.jpg"},
    {'nom': "Luxor", 'image': "assets/images/louxor.jpg"},
    {'nom': "Aswan", 'image': "assets/images/assouan.jpg"},
    {'nom': "Siwa", 'image': "assets/images/siwa.jpeg"},
    {'nom': "Fayoum", 'image': "assets/images/fayoum.jpeg"},
    {'nom': "Desert", 'image': "assets/images/R.jpg"},
    {'nom': "Sharm El-Sheikh", 'image': "assets/images/sharm.jpg"},
    {'nom': "Hurghada", 'image': "assets/images/j.jpg"},
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
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _GenerateurWidget(scrollController: scrollController);
          },
        );
      },
    );
  }

  void _lancerRoulettePrincipale(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _RouletteDialog(villes: villesRoulette, parentContext: context);
      },
    );
  }

  // --- STRICT AND CONSISTENT SORTING LOGIC ---
  String _detectRegion(Map<String, dynamic> item) {
    final String rawRegion = item['region'] ?? '';
    final String rawSub = item['sub_folder'] ?? '';

    if (rawRegion == "Historical Cities" ||
        rawRegion == "Nature & Adventure" ||
        rawRegion == "Red Sea" ||
        rawRegion == "Practical Info") {
      return rawRegion;
    }

    if (rawSub == "Gastronomy") return "Practical Info";
    if (rawSub == "Cairo" || rawSub == "Alexandria" || rawSub == "Luxor" || rawSub == "Aswan") return "Historical Cities";
    if (rawSub == "Sharm El-Sheikh" || rawSub == "Hurghada") return "Red Sea";
    if (rawSub == "Siwa" || rawSub == "Fayoum" || rawSub == "Desert" || rawSub == "Désert") return "Nature & Adventure";

    return "Historical Cities";
  }

  String _detectSubFolder(Map<String, dynamic> item, String region) {
    final String rawSub = item['sub_folder'] ?? '';

    if (rawSub == "Désert") return "Desert";

    final validSubFolders = [
      "Cairo", "Alexandria", "Luxor", "Aswan",
      "Sharm El-Sheikh", "Hurghada",
      "Siwa", "Fayoum", "Desert",
      "Gastronomy"
    ];

    if (validSubFolders.contains(rawSub)) {
      return rawSub;
    }

    if (region == "Practical Info") return "Gastronomy";
    if (region == "Historical Cities") return "Cairo";
    if (region == "Red Sea") return "Sharm El-Sheikh";
    if (region == "Nature & Adventure") return "Desert";

    return "Cairo";
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Monuments": return _accentGold;
      case "Traditional Markets": return const Color(0xFFEF4444);
      case "Historical Sites": return const Color(0xFF38BDF8);
      case "Architecture": return const Color(0xFFA855F7);
      case "Relaxation Spots": return const Color(0xFF2DD4BF);
      case "Gastronomy": return const Color(0xFFEC4899);
      case "Monuments & Culture": return const Color(0xFFF59E0B);
      case "Must-do Excursions": return const Color(0xFF8B5CF6);
      case "Sea & Nature": return const Color(0xFF0EA5E9);
      case "Activities": return const Color(0xFFF97316);
      case "Relaxation & Nightlife": return const Color(0xFFD946EF);
      default: return _accentGoldLight;
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
      "Nature & Adventure": {
        "Siwa": [],
        "Fayoum": [],
        "Desert": [],
      },
      "Red Sea": {
        "Sharm El-Sheikh": [],
        "Hurghada": [],
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
                                      child: Icon(Icons.arrow_back_ios_new_rounded, color: _accentGold, size: 14),
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
                                            "OFFICIAL GUIDE",
                                            style: GoogleFonts.cinzel(
                                              color: _accentGold,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                          children: [
                                            const TextSpan(text: "Eternal "),
                                            TextSpan(
                                              text: "Egypt",
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
                              alignment: Alignment.centerRight,
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
                  'PHARAONIC PLANNER',
                  style: GoogleFonts.cinzel(
                    color: _accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'When to visit Egypt ? 🗓️',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get the best visiting periods by city to avoid extreme heat and make the most of your stay.',
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
                'Launch Generator',
                style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                  'MYSTERY DESTINATION',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFA78BFA),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Cities Roulette 🎲',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let chance choose your next Egyptian stop in a single click !',
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
                'Spin the Roulette',
                style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                    left: 16,
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
                        regionText.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          color: themeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
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
                      style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.5),
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
                            'DISCOVER',
                            style: GoogleFonts.cinzel(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
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
      {"title": "Historical Cities", "color": _accentGold, "icon": Icons.account_balance_rounded},
      {"title": "Nature & Adventure", "color": const Color(0xFF10B981), "icon": Icons.landscape_rounded},
      {"title": "Red Sea", "color": const Color(0xFF0EA5E9), "icon": Icons.waves_rounded},
      {"title": "Practical Info", "color": const Color(0xFFEC4899), "icon": Icons.info_outline_rounded},
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
        subFolderLabel = "$totalItemsInFolder ${totalItemsInFolder <= 1 ? 'info' : 'infos'}";
      } else {
        subFolderLabel = "$totalItemsInFolder ${totalItemsInFolder <= 1 ? 'item' : 'items'}";
      }

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
                        Text(mainTitle, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
          final String countLabel = mainTitle == "Practical Info"
              ? "$count info"
              : "$count ${count <= 1 ? 'place' : 'places'}";

          list.add(
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 10, right: 4),
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
                      Expanded(child: Text(subTitle, style: GoogleFonts.cinzel(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600))),
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
                list.add(Padding(padding: const EdgeInsets.only(left: 24, bottom: 16, right: 8), child: _buildFavoriLieuCard(item)));
              }
            } else {
              list.add(Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 14, top: 2),
                child: Text(mainTitle == "Practical Info" ? "No info saved" : "No place saved", style: GoogleFonts.montserrat(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic)),
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
                      child: Text(lieuNom, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
      case 'Cairo':
        pageDestination = const CairoPage();
        break;
      case 'Luxor':
        pageDestination = const LouxorPage();
        break;
      case 'Aswan':
        pageDestination = const AssouanPage();
        break;
      case 'Alexandria':
        pageDestination = const AlexandriePage();
        break;
      case 'Hurghada':
        pageDestination = const HurghadaPage();
        break;
      case 'Sharm El-Sheikh':
        pageDestination = const SharmElSheikhPage();
        break;
      case 'Fayoum':
        pageDestination = const FayoumPage();
        break;
      case 'Siwa':
        pageDestination = const SiwaPage();
        break;
      case 'Desert':
        pageDestination = const DesertPage();
        break;
      default:
        pageDestination = const CairoPage();
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
                'Cities Roulette',
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _isFinished ? '✨ Destiny revealed!' : 'Consulting the Oracle...',
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
                      style: GoogleFonts.cinzel(
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
                            'Discover this city',
                            style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold),
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
                          'Draw another city',
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
            right: -10,
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
    'Cairo', 'Luxor', 'Aswan', 'Alexandria',
    'Hurghada', 'Sharm El-Sheikh', 'Fayoum', 'Siwa', 'Desert'
  ];

  String? villeSelectionnee;
  bool estEnGenerationVitesse = false;
  bool estGenere = false;

  String affichageVitesseTexte = "ANALYZING DATABASE...";
  int compteurVitesse = 0;
  Timer? _timerVitesse;
  String villeOngletActif = '';

  final Map<String, Map<String, dynamic>> donneeClimatiquesVilles = {
    'Cairo': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January offers pleasant and mild daytime temperatures, perfect for exploring the Giza plateau and Islamic Cairo without suffering from the heat. Evenings are cool, but constant sunshine guarantees exceptional visiting conditions.',
        2: 'February is one of the best months to visit the Egyptian capital, with ideal weather for walking and discovering museums. Tourist crowds remain moderate compared to the holidays, allowing for a very serene exploration.',
        3: 'March begins to gently warm the atmosphere while remaining extremely pleasant for outdoor excursions. It is an ideal transition period to stroll through the souks of Khan el-Khalili.',
        4: 'April benefits from beautiful spring sunshine and warm but bearable temperatures. The Khamsin should be monitored, but overall it is an excellent time to enjoy Cairo\'s parks and terraces.',
        5: 'In May, Cairo\'s heat becomes increasingly heavy and suffocating during walks on the Giza plateau. Temperatures rise rapidly, making visits grueling.',
        6: 'June marks the full onset of the summer urban furnace. The stifling air and blazing sun considerably limit walks in the historic center.',
        7: 'July records scorching temperatures combined with urban pollution, turning pedestrian explorations of Cairo into a grueling experience for travelers.',
        8: 'August suffers from intense heat and very hot air that slow down the entire city. Not recommended for visiting outdoor monuments.',
        9: 'September retains significant late summer heat, keeping Cairo\'s stones very hot and the air heavy before autumn arrives.',
        10: 'October is an absolutely magnificent period to explore Cairo, with warm but perfectly breathable autumn conditions. Ideal conditions return to fully enjoy the monuments.',
        11: 'November offers sumptuous weather, combining mildness and optimal sunshine without the suffocating heat of summer. It is one of the most popular months for travelers to soak up Cairo\'s energy.',
        12: 'December is very pleasant during the day with cool and bright weather, ideal for visiting the pyramids. However, watch out for the year-end holidays which attract a significant number of tourists.',
      }
    },
    'Luxor': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January is the royal period par excellence in Luxor, offering mild temperatures ideal for exploring the Valley of the Kings and the Karnak Temple. The cool morning climate gives way to radiant sunshine.',
        2: 'February guarantees exceptional climatic conditions to admire the pharaonic treasures of Upper Egypt without suffering from the furnace. It is the dream month to take a hot air balloon ride at sunrise.',
        3: 'March benefits from beautiful spring mildness, making the discovery of East and West Bank sites extremely pleasant. Tourist flows begin to regulate after the winter peak.',
        4: 'April brings slightly warmer temperatures, but remains entirely conducive to morning visits to Luxor\'s monuments. The lush green landscapes along the Nile are magnificent.',
        5: 'May sees heat climb to severe levels in Upper Egypt, making visits to rock-cut tombs suffocating by mid-morning.',
        6: 'June turns Luxor into a true open-air furnace, with extreme temperatures preventing any comfortable visit to pharaonic sanctuaries.',
        7: 'July suffers from crushing heatwave peaks. The reflection of the sun on the temple stones makes excursions dangerous without extreme precaution.',
        8: 'August retains suffocating desert heat during the day. Archaeological sites remain deserted due to very high temperatures.',
        9: 'September initiates a very slow drop in temperatures, but the heat is still far too biting to appreciate the Valley of the Kings at its true value.',
        10: 'October marks the grand return of the ideal tourist season in Luxor, with temperatures becoming clement again and sumptuous sunshine for Nile cruises.',
        11: 'November is a sumptuous month to visit Luxor, combining ideal climate, perfect golden lighting for photography, and absolute visiting comfort in Amun\'s complexes.',
        12: 'December offers bright and pleasantly warm days, followed by cool nights. It is a magical time to experience pharaonic Egypt under optimal conditions.',
      }
    },
    'Aswan': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Aswan in January is a sun-drenched haven of peace, with ideal weather for sailing in a felucca and visiting the Philae Temple. The mild air makes every excursion memorable.',
        2: 'February offers dry, sunny, and wonderfully mild weather, perfect for discovering Elephantine Island and the Nubian village in a warm and relaxing atmosphere.',
        3: 'March retains perfect temperatures to enjoy the legendary beauty of Aswan and its wild surroundings. The climate is perfect for relaxing by the river.',
        4: 'April begins to warm the atmosphere more markedly, but cool breezes from the Nile bring welcome refreshment during nautical walks.',
        5: 'May marks the beginning of intense Saharan heat in Aswan, making land travel to Abu Simbel particularly tiring.',
        6: 'June suffers from intense heatwave temperatures. The scorching North African sun requires severely restricting daytime visits.',
        7: 'July records some of the highest temperatures in Egypt. The extremely dry and hot air makes walks on the corniche impossible at midday.',
        8: 'August experiences crushing desert heat that exhausts organisms. Felucca sailing becomes very grueling under direct sun.',
        9: 'September keeps significant residual heat despite a slight dip, maintaining a superheated atmosphere along the river.',
        10: 'October once again offers splendid, warm, and welcoming weather, ideal for exploring temples and enjoying the legendary hospitality of the locals.',
        11: 'November is a paradisiacal month in Aswan, with radiant weather, azure skies, and incomparable dolce vita along the water.',
        12: 'December is perfect to escape European gloom and treat yourself to an enchanted parenthesis under the dazzling sun of Nubia and southern Egypt.',
      }
    },
    'Alexandria': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January in Alexandria offers a bracing and cool climate, perfect for visiting the great Library, the Citadel of Qaitbay, and strolling quietly without the hustle and bustle.',
        2: 'February allows you to explore Greco-Roman heritage and Alexandrian museums under very pleasant and mild temperatures by the Mediterranean.',
        3: 'March is ideal to enjoy the sweet spring sun on the Corniche, explore the catacombs, and appreciate the intellectual atmosphere of the city.',
        4: 'April proposes ideal conditions with clean air and perfect temperatures to stroll through the sumptuous gardens of Montaza Palace.',
        5: 'May sees Mediterranean humidity rise progressively with temperatures, making the air heavy and less comfortable for walking.',
        6: 'June is accompanied by a significant local influx and humid heat that can make cultural visits less pleasant.',
        7: 'July attracts considerable crowds to the coast and records high suffocating coastal humidity that disrupts the tranquility of visits.',
        8: 'August experiences maximum tourist saturation on the Corniche as well as marked climatic heaviness, not recommended for cultural tourism.',
        9: 'September retains heavy humidity and heat before the true decline of the summer season on the north coast.',
        10: 'October softens pleasantly, marking the return of a pacified autumn climate, ideal for cultural strolls facing the waves.',
        11: 'November offers very mild and serene weather to contemplate marine landscapes and explore ancient vestiges in complete tranquility.',
        12: 'December proposes a very romantic and fresh Mediterranean atmosphere, ideal for discovering the historic heart of Alexandria.',
      }
    },
    'Hurghada': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January in Hurghada offers radiant sunshine and mild temperatures perfect for desert excursions, quad biking, and relaxation.',
        2: 'February benefits from very pleasant sunny weather, ideal for enjoying the calm of off-season resorts and refreshing sea air.',
        3: 'March offers a perfect warming of the air and sea, allowing snorkeling and diving to resume in excellent conditions.',
        4: 'April is an exceptional month for Hurghada, combining ideal outdoor warmth and perfect temperatures to explore Giftun Island.',
        5: 'May brings scorching sunshine and very strong UV radiation that make prolonged lounging in the sun tiring.',
        6: 'June suffers from high summer temperatures. Without continuous immersion in water, the heat on land becomes very heavy.',
        7: 'July experiences extreme seaside temperatures under a blazing sun. Activities out of the water should be avoided.',
        8: 'August is marked by a peak of intense heat by the Red Sea that requires staying in the shade for most of the day.',
        9: 'September keeps very hot and stifling land temperatures before the arrival of milder autumn temperatures.',
        10: 'October is one of the best months of the year in Hurghada, offering a perfect balance between gentle warmth and crystal-clear sea.',
        11: 'November provides magnificent sunshine and very mild temperatures, perfect for escaping to the water\'s edge before winter.',
        12: 'December attracts travelers seeking winter sun to celebrate year-end holidays right by the water.',
      }
    },
    'Sharm El-Sheikh': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January in Sharm benefits from dry and sunny weather, protected by the Sinai massif, guaranteeing a sweet winter escape under palm trees.',
        2: 'February is ideal for combining hiking on Mount Sinai and diving in the preserved reefs of Ras Mohammed thanks to very pleasant weather.',
        3: 'March offers perfect meteorological conditions, warm without excess, ideal for visiting Saint Catherine\'s Monastery and the desert.',
        4: 'April is a blessed month for Sharm El-Sheikh, with transparent water ideally warmed and wonderful outdoor temperatures.',
        5: 'May sees the thermometer soar at the foot of the Sinai reliefs, making desert excursions very grueling.',
        6: 'June suffers from intense Saharan heat that turns the coast into a steam room where only underwater dives bring respite.',
        7: 'July records daily crushing heats that suffocate the urban areas of Naama Bay and Old Sharm.',
        8: 'August displays the most extreme temperatures of the year by the Gulf of Aqaba, considerably limiting activities out of the water.',
        9: 'September keeps a very hot and heavy atmosphere on Sinai before the progressive post-season softening.',
        10: 'October is sublime, offering a perfect compromise between gentle warmth, serenity, and exceptional scuba diving conditions.',
        11: 'November is one of the most pleasant months to visit southern Sinai in total climatic comfort and under a great blue sky.',
        12: 'December is very popular to escape European cold under the permanent sun of the southern tip of the Sinai peninsula.',
      }
    },
    'Fayoum': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January in Fayoum offers a fresh and invigorating climate, perfect for observing migratory birds around Lake Qarun and walking towards waterfalls.',
        2: 'February guarantees sunny and mild days, ideal for exploring the artisan village of Tunis and its pottery workshops.',
        3: 'March benefits from splendid spring weather, ideal for venturing into unique natural landscapes between desert and wetlands.',
        4: 'April is perfect for an exotic excursion to Fayoum, enjoying warm and luminous weather before the arrival of extreme heat.',
        5: 'May sees heat intensify rapidly in the oasis basin, making hikes around the lakes very physical.',
        6: 'June suffers from very high summer temperatures that dry out the air and make desert walks dangerous without a guide.',
        7: 'July turns the Wadi El-Rayan region into a stifling heatwave basin not recommended for hikers.',
        8: 'August imposes extreme desert heat conditions across all natural sites of the Fayoum oasis.',
        9: 'September remains marked by strong daytime heat delaying the reopening of nighttime bivouacs in the dunes.',
        10: 'October is a magnificent period to admire the colors of the oasis and enjoy the lake at sunset.',
        11: 'November offers calm, mild, and very favorable weather for artisan and natural discovery of Fayoum\'s landscapes.',
        12: 'December proposes a fresh and invigorating climate, ideal for photographers and lovers of preserved wide-open spaces.',
      }
    },
    'Siwa': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January in Siwa offers very mild sunny days, ideal for bathing in Cleopatra\'s hot springs, despite cool nights.',
        2: 'February is a fantastic period to explore Gebel al-Mawta and the magnificent salt lakes without suffering from desert heat.',
        3: 'March guarantees wonderful spring weather, perfect for venturing into the heart of the isolated oasis and its secular palm groves.',
        4: 'April procures warm and luminous weather, ideal for living the unique floating experience on the turquoise waters of the salt lakes.',
        5: 'May brings the first waves of Libyan Desert heat, making the exploration of Shali Fortress very painful at midday.',
        6: 'June subjects Siwa to biting Saharan heat that paralyzes the oasis during central hours of the day.',
        7: 'July is an extreme heatwave month in the heart of dunes, where temperatures regularly exceed comfort thresholds.',
        8: 'August suffers from crushing desert temperatures that make crossing the Great Sand Sea extremely difficult.',
        9: 'September sees summer heats linger heavily on palm groves before the great autumn decline.',
        10: 'October offers ideal autumn climate, mild and enchanting to discover Shali Fortress and the mysteries of the oasis.',
        11: 'November procures superb weather, favorable to 4x4 safaris in the Great Sand Sea and relaxing baths.',
        12: 'December is perfect to enjoy unique landscapes under a dazzling winter sun, while providing good clothing for the evening.',
      }
    },
    'Desert': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'January is perfect for camping in the White and Black Deserts, with pleasant days but very cold nights under the stars.',
        2: 'February offers dry weather and starry skies of exceptional purity for bivouac and astronomy enthusiasts.',
        3: 'March proposes ideal conditions for treks and 4x4 excursions amidst wind-sculpted limestone formations.',
        4: 'April guarantees warm and dry weather, extremely conducive to the immensity of wide-open spaces and landscape photography.',
        5: 'May turns the sandy expanses of the Black Desert into superheated furnaces from early morning hours.',
        6: 'June makes open desert bivouacs particularly harsh due to stifling temperatures and hot winds.',
        7: 'July records Saharan heatwave extremes that make any 4x4 safari very grueling and risky.',
        8: 'August experiences the most dangerous temperatures of the year amidst the limestone rock formations of the White Desert.',
        9: 'September keeps intense thermal reflection on sand that makes daytime hikes painful.',
        10: 'October offers magnificent climate, stable and ideal for Saharan adventures and nights around the campfire.',
        11: 'November is one of the best months of the year to experience the magical White Desert in absolute tranquility.',
        12: 'December guarantees mild and luminous days followed by cold but unforgettable nights under the celestial vault.',
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
      "CONNECTING TO DATABASE...",
      "ANALYZING EGYPTIAN CLIMATE...",
      "CALCULATING SEASONAL TEMPERATURES...",
      "EVALUATING TOURIST INFLUX...",
      "GENERATING VISIT RECOMMENDATIONS...",
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final saisons = [
      'Winter', 'Winter', 'Spring', 'Spring', 'Spring', 'Summer',
      'Summer', 'Summer', 'Autumn', 'Autumn', 'Autumn', 'Winter'
    ];

    final dataVille = donneeClimatiquesVilles[nomVille] ?? donneeClimatiquesVilles['Cairo']!;
    final List<int> moisFavoris = List<int>.from(dataVille['moisFavoris'] ?? []);
    final Map<int, String> descriptions = Map<int, String>.from(dataVille['descriptions'] ?? {});

    List<Map<String, dynamic>> resultat = [];

    for (int i = 1; i <= 12; i++) {
      final bool estBon = moisFavoris.contains(i);
      resultat.add({
        'nom': nomsMois[i - 1],
        'estBon': estBon,
        'saison': saisons[i - 1],
        'raison': descriptions[i] ?? 'Period analyzed for visiting $nomVille.',
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
                    'Visit Generator 🇪🇬',
                    style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Select a city to get tailored advice.',
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
                          'Important Climate Reminder ☀️',
                          style: GoogleFonts.cinzel(color: const Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Even if the period is recommended, always bring water and sun protection!',
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
              'City selection:',
              style: GoogleFonts.cinzel(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                      style: GoogleFonts.montserrat(
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
                        ? 'SELECT A CITY'
                        : (estEnGenerationVitesse ? 'ANALYSIS IN PROGRESS...' : 'LAUNCH FAST GENERATION'),
                    style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                            'Annual analysis for $villeOngletActif',
                            style: GoogleFonts.cinzel(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
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
                                        style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                                      (m['estBon'] as bool) ? 'GOOD' : 'BAD',
                                      style: GoogleFonts.montserrat(
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