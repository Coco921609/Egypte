import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'le caire.dart';
import 'alexandrie.dart';
import 'louxor.dart';
import 'assouan.dart';
import 'siwa.dart';
import 'fayoum.dart';
import 'desert.dart';
import 'sharm.dart';
import 'hurghada.dart';
import 'airlines.dart';
import 'gastronomie_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> _favorisLieuxJson = [];

  // CLÉ DE STOCKAGE UNIQUE ET ISOLÉE POUR LE FRANÇAIS
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  int _selectedIndex = 0; // 0 = Guide (Home), 1 = Favoris

  // Palette Pharaonique Ultra Haute Gamme
  final Color _bgDark = const Color(0xFF07080E); // Noir Obsidienne
  final Color _cardDark = const Color(0xFF11131C); // Onyx Profond
  final Color _cardDarkSecondary = const Color(0xFF181A26);
  final Color _accentGold = const Color(0xFFD4AF37); // Or Pharaonique Royal
  final Color _accentGoldLight = const Color(0xFFF3E5AB); // Reflet d'Or
  final Color _lapisBlue = const Color(0xFF1E3A8A); // Bleu Lapis-Lazuli
  final Color _papyrusBg = const Color(0xFF1A1813); // Fond Papyrus Sombre

  // CATÉGORIES EXACTES DÉFINIES ET ALIGNÉES PARTOUT
  final Map<String, bool> _foldersExpanded = {
    "Villes Historiques": false,
    "Nature & Aventure": false,
    "Mer Rouge": false,
    "Infos Pratiques": false,
  };

  final Map<String, bool> _subFoldersExpanded = {
    "Le Caire": false,
    "Alexandrie": false,
    "Louxor": false,
    "Assouan": false,
    "Sharm El-Sheikh": false,
    "Hurghada": false,
    "Siwa": false,
    "Fayoum": false,
    "Désert": false,
    "Gastronomie": false,
  };

  final List<Map<String, dynamic>> destinations = [
    {
      'nom': "Le Caire",
      'description': "Capitale vibrante, berceau des pyramides millénaires et cœur battant de l'Égypte moderne.",
      'image': "assets/images/le caire.jpg",
      'couleur': const Color(0xFFD4AF37),
      'region': "Villes Historiques",
      'page': const LeCairePage(),
    },
    {
      'nom': "Alexandrie",
      'description': "Perle de la Méditerranée, cette cité légendaire mêle architecture européenne et héritage égyptien.",
      'image': "assets/images/alexandrie.jpg",
      'couleur': const Color(0xFF38BDF8),
      'region': "Villes Historiques",
      'page': const AlexandriePage(),
    },
    {
      'nom': "Louxor",
      'description': "Le plus grand musée à ciel ouvert du monde, abritant les majestueux temples de Karnak.",
      'image': "assets/images/louxor.jpg",
      'couleur': const Color(0xFFF59E0B),
      'region': "Villes Historiques",
      'page': const LouxorPage(),
    },
    {
      'nom': "Assouan",
      'description': "Havre de paix au bord du Nil, célèbre pour ses paysages nubiens et sa sérénité absolue.",
      'image': "assets/images/assouan.jpg",
      'couleur': const Color(0xFFEAB308),
      'region': "Villes Historiques",
      'page': const AssouanPage(),
    },
    {
      'nom': "Siwa",
      'description': "Oasis mystique isolée dans le désert, réputée pour ses sources d'eau chaude.",
      'image': "assets/images/siwa.jpeg",
      'couleur': const Color(0xFF10B981),
      'region': "Nature & Aventure",
      'page': const SiwaPage(),
    },
    {
      'nom': "Fayoum",
      'description': "Un écosystème unique entre lacs salés et désert, où la nature sauvage rencontre l'histoire.",
      'image': "assets/images/fayoum.jpeg",
      'couleur': const Color(0xFF34D399),
      'region': "Nature & Aventure",
      'page': const FayoumPage(),
    },
    {
      'nom': "Désert",
      'description': "Une expédition inoubliable au cœur du désert blanc et noir.",
      'image': "assets/images/R.jpg",
      'couleur': const Color(0xFFF97316),
      'region': "Nature & Aventure",
      'page': const DesertPage(),
    },
    {
      'nom': "Sharm El-Sheikh",
      'description': "Destination balnéaire mondiale, renommée pour la richesse de ses récifs coralliens.",
      'image': "assets/images/sharm.jpg",
      'couleur': const Color(0xFF0EA5E9),
      'region': "Mer Rouge",
      'page': const SharmElSheikhPage(),
    },
    {
      'nom': "Hurghada",
      'description': "Station balnéaire dynamique offrant des plages de sable fin et excursions magiques.",
      'image': "assets/images/j.jpg",
      'couleur': const Color(0xFF06B6D4),
      'region': "Mer Rouge",
      'page': const HurghadaPage(),
    },
    {
      'nom': "Airlines",
      'description': "Toutes les informations nécessaires sur les vols internationaux et les connexions locales.",
      'image': "assets/images/air.jpg",
      'couleur': const Color(0xFFEF4444),
      'region': "Infos Pratiques",
      'page': const AirlinesPage(),
    },
    {
      'nom': "Plats Typiques",
      'description': "Découvrez une gastronomie riche en saveurs : koshary, falafels et pâtisseries orientales.",
      'image': "assets/images/p.jpg",
      'couleur': const Color(0xFFEC4899),
      'region': "Infos Pratiques",
      'page': const GastronomiePage(),
    },
  ];

  final List<Map<String, String>> villesRoulette = [
    {'nom': "Le Caire", 'image': "assets/images/le caire.jpg"},
    {'nom': "Alexandrie", 'image': "assets/images/alexandrie.jpg"},
    {'nom': "Louxor", 'image': "assets/images/louxor.jpg"},
    {'nom': "Assouan", 'image': "assets/images/assouan.jpg"},
    {'nom': "Siwa", 'image': "assets/images/siwa.jpeg"},
    {'nom': "Fayoum", 'image': "assets/images/fayoum.jpeg"},
    {'nom': "Désert", 'image': "assets/images/R.jpg"},
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

  // --- LOGIQUE DE TRI STRICTE ET CONFORME PARTOUT ---
  String _detectRegion(Map<String, dynamic> item) {
    final String rawRegion = item['region'] ?? '';
    final String rawSub = item['sub_folder'] ?? '';

    if (rawRegion == "Villes Historiques" ||
        rawRegion == "Nature & Aventure" ||
        rawRegion == "Mer Rouge" ||
        rawRegion == "Infos Pratiques") {
      return rawRegion;
    }

    if (rawSub == "Gastronomie") return "Infos Pratiques";
    if (rawSub == "Le Caire" || rawSub == "Alexandrie" || rawSub == "Louxor" || rawSub == "Assouan") return "Villes Historiques";
    if (rawSub == "Sharm El-Sheikh" || rawSub == "Hurghada") return "Mer Rouge";
    if (rawSub == "Siwa" || rawSub == "Fayoum" || rawSub == "Désert" || rawSub == "Desert") return "Nature & Aventure";

    return "Villes Historiques";
  }

  String _detectSubFolder(Map<String, dynamic> item, String region) {
    final String rawSub = item['sub_folder'] ?? '';

    if (rawSub == "Desert") return "Désert";

    final validSubFolders = [
      "Le Caire", "Alexandrie", "Louxor", "Assouan",
      "Sharm El-Sheikh", "Hurghada",
      "Siwa", "Fayoum", "Désert",
      "Gastronomie"
    ];

    if (validSubFolders.contains(rawSub)) {
      return rawSub;
    }

    if (region == "Infos Pratiques") return "Gastronomie";
    if (region == "Villes Historiques") return "Le Caire";
    if (region == "Mer Rouge") return "Sharm El-Sheikh";
    if (region == "Nature & Aventure") return "Désert";

    return "Le Caire";
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Monuments": return _accentGold;
      case "Marchés traditionnels": return const Color(0xFFEF4444);
      case "Lieux historiques": return const Color(0xFF38BDF8);
      case "Architecture": return const Color(0xFFA855F7);
      case "Lieux de détente": return const Color(0xFF2DD4BF);
      case "Gastronomie": return const Color(0xFFEC4899);
      case "Monuments & Culture": return const Color(0xFFF59E0B);
      case "Excursions incontournables": return const Color(0xFF8B5CF6);
      case "Mer & Nature": return const Color(0xFF0EA5E9);
      case "Activités": return const Color(0xFFF97316);
      case "Détente & Vie nocturne": return const Color(0xFFD946EF);
      default: return _accentGoldLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> doubleGroupedFavorites = {
      "Villes Historiques": {
        "Le Caire": [],
        "Alexandrie": [],
        "Louxor": [],
        "Assouan": [],
      },
      "Nature & Aventure": {
        "Siwa": [],
        "Fayoum": [],
        "Désert": [],
      },
      "Mer Rouge": {
        "Sharm El-Sheikh": [],
        "Hurghada": [],
      },
      "Infos Pratiques": {
        "Gastronomie": [],
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
              // Arrière-plan subtil à halo doré
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
                      // EN-TÊTE RÉAJUSTÉ : ESPACEMENT HAUT FORTEMENT AUGMENTÉ + EN HAUT À DROITE PASSÉ À LA LIGNE
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, top: 48, bottom: 28, right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne du titre et bouton retour
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
                                            "GUIDE OFFICIEL",
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
                                            const TextSpan(text: "Égypte "),
                                            TextSpan(
                                              text: "Éternelle",
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

                            // NOUVELLE LIGNE EN HAUT À DROITE : BOUTONS DE NAVIGATION ESPACÉS SUR LEUR PROPRE LIGNE
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
                  'PLANIFICATEUR PHARAONIQUE',
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
            'Quand visiter l\'Égypte ? 🗓️',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Obtenez les meilleures périodes de visite par ville pour éviter les fortes chaleurs et profiter au mieux de votre séjour.',
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
                'Lancer le Générateur',
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
                  'DESTINATION MYSTÈRE',
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
            'La Roulette des Villes 🎲',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Laissez le hasard choisir votre prochaine étape égyptienne en un seul clic !',
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
                'Tourner la Roulette',
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
                        regionText,
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
                            'DÉCOUVRIR',
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

  // CATÉGORIES EXACTES : Villes Historiques, Nature & Aventure, Mer Rouge, Infos Pratiques
  List<Widget> _buildFavoritesFolders(Map<String, Map<String, List<Map<String, dynamic>>>> grouped) {
    List<Widget> list = [];
    final List<Map<String, dynamic>> folderConfig = [
      {"title": "Villes Historiques", "color": _accentGold, "icon": Icons.account_balance_rounded},
      {"title": "Nature & Aventure", "color": const Color(0xFF10B981), "icon": Icons.landscape_rounded},
      {"title": "Mer Rouge", "color": const Color(0xFF0EA5E9), "icon": Icons.waves_rounded},
      {"title": "Infos Pratiques", "color": const Color(0xFFEC4899), "icon": Icons.info_outline_rounded},
    ];

    for (var folder in folderConfig) {
      final String mainTitle = folder["title"] as String;
      final Color color = folder["color"] as Color;
      final IconData icon = folder["icon"] as IconData;
      final Map<String, List<Map<String, dynamic>>> subFolders = grouped[mainTitle] ?? {};
      final bool isExpanded = _foldersExpanded[mainTitle] ?? false;

      int totalItemsInFolder = 0;
      subFolders.forEach((subKey, itemsList) => totalItemsInFolder += itemsList.length);

      String subFolderLabel = "$totalItemsInFolder ${totalItemsInFolder <= 1 ? 'élément' : 'éléments'}";

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
          final String countLabel = "$count ${count <= 1 ? 'lieu' : 'lieux'}";

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
                child: Text("Aucun élément enregistré", style: GoogleFonts.montserrat(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic)),
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
      case 'Le Caire':
        pageDestination = const LeCairePage();
        break;
      case 'Louxor':
        pageDestination = const LouxorPage();
        break;
      case 'Assouan':
        pageDestination = const AssouanPage();
        break;
      case 'Alexandrie':
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
      case 'Désert':
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
                'Roulette des Villes',
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _isFinished ? '✨ Destinée révélée !' : 'Consultation de l\'Oracle...',
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
                            'Découvrir cette ville',
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
                          'Tirer une autre ville',
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
    'Le Caire', 'Louxor', 'Assouan', 'Alexandrie',
    'Hurghada', 'Sharm El-Sheikh', 'Fayoum', 'Siwa', 'Désert'
  ];

  String? villeSelectionnee;
  bool estEnGenerationVitesse = false;
  bool estGenere = false;

  String affichageVitesseTexte = "ANALYSE DE LA BANQUE...";
  int compteurVitesse = 0;
  Timer? _timerVitesse;
  String villeOngletActif = '';

  final Map<String, Map<String, dynamic>> donneeClimatiquesVilles = {
    'Le Caire': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier offre des températures agréables et douces en journée, parfaites pour arpenter le plateau de Gizeh et le Caire islamique sans souffrir de la chaleur. Les soirées sont fraîches, mais l\'ensoleillement constant garantit des conditions de visite exceptionnelles.',
        2: 'Février est l\'un des meilleurs mois pour visiter la capitale égyptienne, avec un climat idéal pour la marche et la découverte des musées. La fréquentation touristique reste modérée par rapport aux fêtes, permettant une exploration très sereine.',
        3: 'Le mois de mars commence à réchauffer doucement l\'atmosphère tout en restant extrêmement agréable pour les excursions en extérieur. C\'est une période de transition idéale pour flâner dans les souks de Khan el-Khalili.',
        4: 'Avril bénéficie d\'un beau soleil printanier et de températures chaudes mais supportables. Il convient de surveiller le Khamsin, mais c\'est globalement un excellent moment pour profiter des parcs et des terrasses du Caire.',
        5: 'En mai, la chaleur cairote devient de plus en plus pesante et suffocante lors des marches sur le plateau de Gizeh. Les températures grimpent rapidement, rendant les visites éprouvantes.',
        6: 'Juin marque la pleine installation de la fournaise estivale urbaine. L\'air étouffant et le soleil de plomb limitent considérablement les promenades dans le centre historique.',
        7: 'Juillet enregistre des températures caniculaires associées à la pollution urbaine, transformant les explorations pédestres du Caire en une expérience éprouvante pour les voyageurs.',
        8: 'Août subit des chaleurs intenses et un air très chaud qui ralentissent l\'ensemble de la ville. Période déconseillée pour visiter les monuments en plein air.',
        9: 'Septembre conserve une chaleur estivale tardive importante, gardant les pierres du Caire très chaude et l\'air lourd avant l\'arrivée de l\'automne.',
        10: 'Octobre est une période absolument magnifique pour explorer Le Caire, avec un climat automnal chaleureux mais parfaitement respirant. Les conditions idéales reviennent pour profiter pleinement des monuments.',
        11: 'Novembre offre un temps somptueux, alliant douceur et ensoleillement optimal sans la chaleur suffocante de l\'été. C\'est l\'un des mois les plus prisés par les voyageurs pour s\'imprégner de l\'énergie cairote.',
        12: 'Décembre est très agréable en journée avec un climat frais et lumineux, idéal pour visiter les pyramides. Attention toutefois aux vacances de fin d\'année qui attirent un nombre important de touristes.',
      }
    },
    'Louxor': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier est la période royale par excellence à Louxor, offrant des températures douces idéales pour explorer la Vallée des Rois et le temple de Karnak. Le climat frais du matin laisse place à un soleil radieux.',
        2: 'Février garantit des conditions climatiques exceptionnelles pour admirer les trésors pharaoniques de Haute-Égypte sans souffrir de la fournaise. C\'est le mois rêvé pour s\'envoler en montgolfière au lever du soleil.',
        3: 'Mars profite d\'une belle douceur printanière, rendant la découverte des sites de la rive est et ouest extrêmement agréable. Les flux touristiques commencent à se réguler après le pic hivernal.',
        4: 'Avril apporte des températures un peu plus chaudes, mais qui restent tout à fait propices aux visites matinales des monuments de Louxor. Les paysages verdoyants le long du Nil sont magnifiques.',
        5: 'Mai voit la chaleur grimper à des niveaux sévères en Haute-Égypte, rendant la visite des tombes rocheuses étouffante dès le milieu de la matinée.',
        6: 'Juin transforme Louxor en un véritable four à ciel ouvert, avec des températures extrêmes qui empêchent toute visite confortable des sanctuaires pharaoniques.',
        7: 'Juillet subit des pics caniculaires écrasants. La réverbération du soleil sur les pierres des temples rend les excursions dangereuses sans précaution extrême.',
        8: 'Août conserve des chaleurs du désert suffocantes en journée. Les sites archéologiques restent déserts en raison des températures très élevées.',
        9: 'Septembre amorce une très lente baisse des températures, mais la chaleur reste encore bien trop cuisante pour apprécier la Vallée des Rois à sa juste valeur.',
        10: 'Octobre marque le grand retour de la saison touristique idéale à Louxor, avec des températures qui redeviennent clémentes et un ensoleillement somptueux pour les croisières sur le Nil.',
        11: 'Novembre est un mois somptueux pour visiter Louxor, combinant un climat idéal, une luminosité dorée parfaite pour la photographie et un confort de visite absolu dans les complexes d\'Amon.',
        12: 'Décembre offre des journées lumineuses et agréablement chaudes, suivies de nuits fraîches. C\'est un moment magique pour vivre l\'Égypte pharaonique dans des conditions optimales.',
      }
    },
    'Assouan': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Assouan en janvier est un havre de paix baigné de soleil, avec un climat idéal pour naviguer en felouque et visiter le temple de Philae. La douceur de l\'air rend chaque excursion mémorable.',
        2: 'Février offre un temps sec, ensoleillé et merveilleusement doux, parfait pour découvrir l\'île Éléphantine et le village nubien dans une ambiance chaleureuse et relaxante.',
        3: 'Mars conserve des températures parfaites pour profiter de la beauté légendaire d\'Assouan et de ses environs sauvages. Le climat est parfait pour se détendre au bord du fleuve.',
        4: 'Avril commence à réchauffer l\'atmosphère de manière plus marquée, mais les brises fraîches du Nil apportent un rafraîchissement bienvenu lors des promenades nautiques.',
        5: 'Mai marque le début des chaleurs intenses sahariennes à Assouan, rendant les déplacements terrestres vers Abou Simbel particulièrement fatigants.',
        6: 'Juin subit des températures caniculaires intenses. Le soleil brûlant d\'Afrique du Nord impose de restreindre fortement les visites en journée.',
        7: 'Juillet enregistre des températures parmi les plus hautes d\'Égypte. L\'air extrêmement sec et chaud rend les promenades sur la corniche impossibles en mi-journée.',
        8: 'Août connaît une chaleur désertique écrasante qui épuise les organismes. La navigation en felouque devient très éprouvante sous le soleil direct.',
        9: 'Septembre garde une chaleur résiduelle importante malgré un léger repli, maintaining une atmosphère surchauffée le long du fleuve.',
        10: 'Octobre offre de nouveau un climat splendide, chaleureux et accueillant, idéal pour explorer les temples et profiter de l\'hospitalité légendaire des habitants.',
        11: 'Novembre est un mois paradisiaque à Assouan, avec un temps radieux, un ciel azuréen et une douceur de vivre incomparable au fil de l\'eau.',
        12: 'Décembre est parfait pour fuir la grisaille européenne et s\'offrir une parenthèse enchantée sous le soleil éclatant de la Nubie et du sud égyptien.',
      }
    },
    'Alexandrie': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier à Alexandrie offre un climat vivifiant et frais, parfait pour visiter la grande Bibliothèque, la Citadelle de Qaitbay et flâner au calme sans la cohue.',
        2: 'Février permet d\'explorer le patrimoine gréco-romain et les musées alexandrins sous une température très agréable et douce au bord de la Méditerranée.',
        3: 'Mars est idéal pour profiter du doux soleil printanier sur la Corniche, explorer les catacombes et apprécier l\'ambiance intellectuelle de la ville.',
        4: 'Avril propose des conditions idéales avec un air pur et des températures parfaites pour flâner dans les jardins somptueux du Palais de Montaza.',
        5: 'Mai voit l\'humidité méditerranéenne s\'élever progressivement avec les températures, rendant l\'air lourd et moins confortable pour la marche.',
        6: 'Juin s\'accompagne d\'un pic d\'affluence locale importante et d\'une chaleur moite qui peut rendre les visites culturelles moins agréables.',
        7: 'Juillet attire une foule considérable sur le littoral et enregistre une forte humidité côtière étouffante qui perturbe la quiétude des visites.',
        8: 'Août connaît une saturation touristique maximale sur la Corniche ainsi qu\'une lourdeur climatique marquée, déconseillée pour le tourisme culturel.',
        9: 'Septembre conserve une humidité et une chaleur lourdes avant le véritable déclin de la saison estivale sur la côte nord.',
        10: 'Octobre s\'adoucit agréablement, marquant le retour d\'un climat automnal apaisé, idéal pour les balades culturelles face aux flots.',
        11: 'Novembre offre un temps très doux et serein pour contempler les paysages marins et explorer les vestiges antiques en toute quiétude.',
        12: 'Décembre propose une atmosphère méditerranéenne très romantique et fraîche, idéale pour découvrir le cœur historique d\'Alexandrie.',
      }
    },
    'Hurghada': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier à Hurghada offre un soleil radieux et des températures douces parfaites pour les excursions dans le désert, le quad et le repos.',
        2: 'Février bénéficie d\'un climat ensoleillé très agréable, idéal pour profiter du calme des resorts hors saison et de l\'air marin rafraîchissant.',
        3: 'Mars offre un réchauffement parfait de l\'air et de la mer, permettant de recommencer le snorkeling et la plongée dans d\'excellentes conditions.',
        4: 'Avril est un mois exceptionnel pour Hurghada, combinant une chaleur extérieure idéale et des températures parfaites pour explorer l\'île Giftoun.',
        5: 'Mai apporte un ensoleillement brûlant et un rayonnement UV très fort qui rendent le farniente prolongé au soleil fatigant.',
        6: 'Juin subit des températures estivales élevées. Sans immersion continue dans l\'eau, la chaleur sur terre devient très lourde.',
        7: 'Juillet connaît des températures balnéaires extrêmes sous un soleil de plomb. Les activités hors de l\'eau doivent être évitées.',
        8: 'Août est marqué par un pic de chaleur intense au bord de la mer Rouge qui nécessite de rester à l\'ombre durant la plus grande partie de la journée.',
        9: 'Septembre garde des températures terrestres très chaudes et étouffantes avant l\'arrivée des températures plus douces de l\'automne.',
        10: 'Octobre est l\'un des meilleurs mois de l\'année à Hurghada, offrant un équilibre parfait entre chaleur douce et mer cristalline.',
        11: 'Novembre procure un ensoleillement magnifique et des températures très douces, parfaites pour s\'évader au bord de l\'eau avant l\'hiver.',
        12: 'Décembre attire les voyageurs en quête de soleil hivernal pour célébrer les fêtes de fin d\'année les pieds dans l\'eau.',
      }
    },
    'Sharm El-Sheikh': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier à Sharm bénéficie d\'un climat sec et ensoleillé, protégé par le massif du Sinaï, garantissant une douce évasion hivernale sous les palmiers.',
        2: 'Février est idéal pour combiner randonnée au mont Sinaï et plongée dans les récifs préservés de Ras Mohammed grâce à un climat très agréable.',
        3: 'Mars offre des conditions météorologiques parfaites, chaudes sans excès, idéales pour visiter le monastère Sainte-Catherine et le désert.',
        4: 'Avril est un mois béni pour Sharm El-Sheikh, avec une eau transparente idéalement chauffée et des températures extérieures merveilleuses.',
        5: 'Mai voit le thermomètre s\'envoler au pied des reliefs du Sinaï, rendant les excursions dans le désert très éprouvantes.',
        6: 'Juin subit une chaleur saharienne intense qui transforme la côte en une étuve où seules les plongées sous-marines apportent du répit.',
        7: 'Juillet enregistre des chaleurs écrasantes quotidiennes qui étouffent les zones urbaines de Naama Bay et du Vieux Sharm.',
        8: 'Août affiche les températures les plus extrêmes de l\'année au bord du golfe d\'Aqaba, limitant considérablement les activités hors de l\'eau.',
        9: 'Septembre conserve une atmosphère très chaude et pesante sur le Sinaï avant l\'adoucissement progressif d\'arrière-saison.',
        10: 'Octobre est sublime, offrant un compromis parfait entre chaleur douce, sérénité et conditions de plongée sous-marine d\'exception.',
        11: 'Novembre est l\'un des mois les plus agréables pour visiter le sud du Sinaï dans un confort climatique total et sous un grand ciel bleu.',
        12: 'Décembre est très prisé pour échapper au froid européen sous le soleil permanent de la pointe sud de la péninsule du Sinaï.',
      }
    },
    'Fayoum': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier au Fayoum offre un climat frais et revigorant, parfait pour observer les oiseaux migrateurs autour du lac Qarun et marcher vers les cascades.',
        2: 'Février garantit des journées ensoleillées et douces, idéales pour explorer le village d\'artisans de Tunis et ses ateliers de poterie.',
        3: 'Mars bénéficie d\'une météo printanière splendide, idéale pour s\'aventurer dans les paysages naturels uniques entre désert et zones humides.',
        4: 'Avril est parfait pour une excursion dépaysante au Fayoum, profitant d\'un climat chaud et lumineux avant l\'arrivée des fortes chaleurs.',
        5: 'Mai voit la chaleur s\'intensifier rapidement dans la cuvette de l\'oasis, rendant les randonnées autour des lacs très physiques.',
        6: 'Juin subit des températures estivales très élevées qui assèchent l\'air et rendent les promenades dans le désert dangereuses sans guide.',
        7: 'Juillet transforme la région de Wadi El-Rayan en une cuvette caniculaire étouffante déconseillée aux randonneurs.',
        8: 'Août impose des conditions extrêmes de chaleur désertique sur l\'ensemble des sites naturels de l\'oasis du Fayoum.',
        9: 'Septembre reste marqué par de fortes chaleurs diurnes retardant la réouverture des bivouacs nocturnes dans les dunes.',
        10: 'Octobre est une période magnifique pour admirer les couleurs de l\'oasis et profiter du lac au soleil couchant.',
        11: 'Novembre offre un temps calme, doux et très propice à la découverte artisanale et naturelle des paysages du Fayoum.',
        12: 'Décembre propose un climat frais et vivifiant, idéal pour les photographes et les amoureux de grands espaces préservés.',
      }
    },
    'Siwa': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier à Siwa offre des journées ensoleillées très douces, idéales pour se baigner dans les sources chaudes de Cléopâtre, malgré des nuits fraîches.',
        2: 'Février est une période fantastique pour explorer Gebel al-Mawta et les magnifiques lacs de sel sans souffrir de la chaleur du désert.',
        3: 'Mars garantit un climat printanier merveilleux, parfait pour s\'aventurer au cœur de l\'oasis isolée et de ses palmeraies séculaires.',
        4: 'Avril procure un temps chaud et lumineux, idéal pour vivre l\'expérience unique de flottaison sur les eaux turquoise des lacs de sel.',
        5: 'Mai amène les premières vagues de chaleur du désert Libyque, rendant l\'exploration de la forteresse de Shali très pénible à mi-journée.',
        6: 'Juin soumet Siwa à une chaleur saharienne cuisante qui paralyse l\'oasis durant les heures centrales de la journée.',
        7: 'Juillet est un mois caniculaire extrême au cœur des dunes, où les températures dépassent régulièrement les seuils de confort.',
        8: 'Août subit des températures désertiques écrasantes qui rendent la traversée de la Grande Mer de Sable extrêmement difficile.',
        9: 'Septembre voit les chaleurs estivales s\'attarder lourdement sur les palmeraies avant le grand déclin automnal.',
        10: 'Octobre offre un climat automnal idéal, doux et enchanteur pour découvrir la Forteresse de Shali et les mystères de l\'oasis.',
        11: 'Novembre procure un temps superbe, propice aux safaris en 4x4 dans le Grand Mer de Sable et aux bains relaxants.',
        12: 'Décembre est parfait pour profiter des paysages uniques sous un soleil d\'hiver éclatant, en prévoyant de bons vêtements pour le soir.',
      }
    },
    'Désert': {
      'moisFavoris': [1, 2, 3, 4, 10, 11, 12],
      'descriptions': {
        1: 'Janvier est parfait pour le camping dans le Désert Blanc et le Désert Noir, avec des journées agréables mais des nuits très froides sous les étoiles.',
        2: 'Février offre un climat sec et des ciels étoilés d\'une pureté exceptionnelle pour les passionnés de bivouac et d\'astronomie.',
        3: 'Mars propose des conditions idéales pour les treks et excursions en 4x4 au milieu des formations calcaires sculptées par le vent.',
        4: 'Avril garantit un temps chaud et sec, extrêmement propice à l\'immensité des grands espaces et à la photographie de paysage.',
        5: 'Mai transforme les étendues sableuses du Désert Noir en fournaises surchauffées dès les premières heures du matin.',
        6: 'Juin rend les bivouacs en plein désert particulièrement rudes en raison de températures étouffantes et de vents chauds.',
        7: 'Juillet enregistre des extrêmes caniculaires sahariens qui rendent tout safari en 4x4 très éprouvant et risqué.',
        8: 'Août connaît les températures les plus dangereuses de l\'année au milieu des formations rocheuses calcaires du Désert Blanc.',
        9: 'Septembre conserve une réverbération thermique intense sur le sable qui rend les randonnées de journée pénibles.',
        10: 'Octobre offre un climat magnifique, stable et idéal pour les aventures sahariennes et les nuits autour du feu de camp.',
        11: 'Novembre est l\'un des meilleurs mois de l\'année pour vivre l\'expérience magique du Désert Blanc dans une quiétude absolue.',
        12: 'Décembre garantit des journées douces et lumineuses suivies de nuits froides mais inoubliables sous la voûte céleste.',
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
      "CONNEXION BANQUE DE DONNÉES...",
      "ANALYSE CLIMATIQUE ÉGYPTIENNE...",
      "CALCUL DES TEMPÉRATURES SAISONNIÈRES...",
      "ÉVALUATION DE L'AFFLUX TOURISTIQUE...",
      "GÉNÉRATION DES CONSEILS DE VISITE...",
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
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

    final saisons = [
      'Hiver', 'Hiver', 'Printemps', 'Printemps', 'Printemps', 'Été',
      'Été', 'Été', 'Automne', 'Automne', 'Automne', 'Hiver'
    ];

    final dataVille = donneeClimatiquesVilles[nomVille] ?? donneeClimatiquesVilles['Le Caire']!;
    final List<int> moisFavoris = List<int>.from(dataVille['moisFavoris'] ?? []);
    final Map<int, String> descriptions = Map<int, String>.from(dataVille['descriptions'] ?? {});

    List<Map<String, dynamic>> resultat = [];

    for (int i = 1; i <= 12; i++) {
      final bool estBon = moisFavoris.contains(i);
      resultat.add({
        'nom': nomsMois[i - 1],
        'estBon': estBon,
        'saison': saisons[i - 1],
        'raison': descriptions[i] ?? 'Période analysée pour la visite de $nomVille.',
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
                    'Générateur de Visite 🇪🇬',
                    style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Sélectionnez une ville pour obtenir des conseils adaptés.',
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
                          'Rappel Climat Important ☀️',
                          style: GoogleFonts.cinzel(color: const Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Même si la période est recommandée, prévoyez toujours de l\'eau et de quoi vous protéger du soleil !',
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
              'Sélection de la ville :',
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
                        ? 'SÉLECTIONNEZ UNE VILLE'
                        : (estEnGenerationVitesse ? 'ANALYSE EN COURS...' : 'LANCER LA GÉNÉRATION RAPIDE'),
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
                            'Analyse annuelle pour $villeOngletActif',
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
                                      (m['estBon'] as bool) ? 'BON' : 'MAUVAIS',
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