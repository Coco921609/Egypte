import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- CONFIGURATION WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class Plat {
  final String name, sub_category, photo_url, description, ville, recette;
  final List<String> tags;

  Plat({
    required this.name,
    required this.sub_category,
    required this.photo_url,
    required this.description,
    required this.ville,
    required this.recette,
    required this.tags,
  });
}

class GastronomiePage extends StatefulWidget {
  const GastronomiePage({super.key});

  @override
  State<GastronomiePage> createState() => _GastronomiePageState();
}

class _GastronomiePageState extends State<GastronomiePage> {
  final ScrollController _scrollController = ScrollController();
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  // Palette de couleurs Premium harmonisée avec Home
  final Color _bgDark = const Color(0xFF090A0F);
  final Color _cardDark = const Color(0xFF14151B);
  final Color _accentPink = const Color(0xFFFD79A8); // Rose épice signature pour la gastronomie

  final List<Plat> tous_les_plats = [
    Plat(name: "Koshari", sub_category: "Gastronomie", photo_url: "assets/plat/k.jpg", ville: "Le Caire", description: "Le plat national cairote, mélange de riz, lentilles, macaronis et pois chiches.", recette: "Mélangez riz, lentilles, macaronis et pois chiches, puis nappez de sauce tomate et oignons frits.", tags: ["Végétarien", "Populaire", "Rue"]),
    Plat(name: "Ful medames", sub_category: "Gastronomie", photo_url: "assets/plat/f.jpg", ville: "Le Caire", description: "Purée de fèves mijotées aux épices, petit-déjeuner national traditionnel.", recette: "Mijotez les fèves, puis assaisonnez avec huile d'olive, ail, citron et cumin.", tags: ["Petit-déjeuner", "Traditionnel", "Fèves"]),
    Plat(name: "Taameya", sub_category: "Gastronomie", photo_url: "assets/plat/t.webp", ville: "Le Caire", description: "Falafels aux fèves fraîches et herbes, croustillants à l'extérieur.", recette: "Mixez fèves, coriandre et épices, formez des galettes et faites frire.", tags: ["Falafel", "Rue", "Sandwich"]),
    Plat(name: "Pain baladi", sub_category: "Gastronomie", photo_url: "assets/plat/p.jpg", ville: "Le Caire", description: "Pain traditionnel égyptien cuit à haute température.", recette: "Pétrissez la farine complète, façonnez des disques et cuisez au four très chaud.", tags: ["Pain", "Traditionnel", "Incontournable"]),
    Plat(name: "Pigeon grillé", sub_category: "Gastronomie", photo_url: "assets/plat/g.webp", ville: "Louxor", description: "Pigeon farci au freekeh, un blé vert torréfié.", recette: "Farcissez le pigeon de freekeh et rôtissez jusqu'à obtenir une peau dorée.", tags: ["Viande", "Festif", "Spécialité"]),
    Plat(name: "Kebda", sub_category: "Gastronomie", photo_url: "assets/plat/2.webp", ville: "Alexandrie", description: "Foie de bœuf mariné aux épices intenses, saisi à feu vif.", recette: "Marinez le foie, puis saisissez sur une plancha brûlante avec du piment.", tags: ["Foie", "Épicé", "Rue"]),
    Plat(name: "Om ali", sub_category: "Gastronomie", photo_url: "assets/plat/9.jpg", ville: "Le Caire", description: "Pudding chaud au feuilletage, lait, noix de coco et pistaches.", recette: "Trempez le feuilletage dans du lait sucré et gratinez au four avec des noix.", tags: ["Dessert", "Chaud", "National"]),
    Plat(name: "Basbousa", sub_category: "Gastronomie", photo_url: "assets/plat/4.jpg", ville: "Assouan", description: "Gâteau de semoule moelleux imbibé de sirop parfumé.", recette: "Cuisez la semoule au four et imbibez de sirop à la fleur d'oranger.", tags: ["Dessert", "Semoule", "Sucré"]),
    Plat(name: "Konafa", sub_category: "Gastronomie", photo_url: "assets/plat/2.jpg", ville: "Le Caire", description: "Vermicelles croustillants au beurre, garnis de crème ou fromage.", recette: "Dorez les vermicelles, garnissez de crème et nappez de sirop parfumé.", tags: ["Dessert", "Croustillant", "Fromage"]),
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

  Future<void> _toggleFavori(Plat plat) async {
    final prefs = await SharedPreferences.getInstance();
    bool existe = false;
    int indexTrouve = -1;

    for (int i = 0; i < _favorisLieuxJson.length; i++) {
      try {
        final map = jsonDecode(_favorisLieuxJson[i]);
        if (map['name'] == plat.name) {
          existe = true;
          indexTrouve = i;
          break;
        }
      } catch (e) {
        // Ignorer
      }
    }

    setState(() {
      if (existe) {
        _favorisLieuxJson.removeAt(indexTrouve);
      } else {
        // AJOUT DES CLÉS INCONTOURNABLES pour assurer le classement automatique dans Home
        final Map<String, dynamic> platMap = {
          'name': plat.name,
          'sub_category': "Gastronomie",
          'photo_url': plat.photo_url,
          'description': plat.description,
          'ville': plat.ville,
          'recette': plat.recette,
          'region': "Infos Pratiques", // Pour cibler le dossier principal de votre Home
          'sub_folder': "Gastronomie", // Pour cibler le sous-dossier de votre Home
        };
        _favorisLieuxJson.add(jsonEncode(platMap));
      }
    });

    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  bool _isFavori(String name) {
    for (var jsonStr in _favorisLieuxJson) {
      try {
        if (jsonDecode(jsonStr)['name'] == name) return true;
      } catch (e) {
        // Ignorer
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgDark,
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- BARRE D'APPUI CHIC & ÉPURÉE ---
              SliverAppBar(
                pinned: false, // Comportement défilement site web
                stretch: true,
                backgroundColor: _bgDark.withOpacity(0.9),
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
                title: Text(
                  "Gastronomie égyptienne",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              // --- LISTE DES PLATS ---
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _build_plat_card(tous_les_plats[index]),
                    childCount: tous_les_plats.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CARTE DE PLAT GASTRONOMIQUE PREMIUM AVEC EFFET HALO UNDERGLOW ---
  Widget _build_plat_card(Plat plat) {
    final bool isFav = _isFavori(plat.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentPink.withOpacity(0.18), width: 1.2), // Liseré rose délicat
        boxShadow: [
          // 1. Ombre noire de fond (profondeur)
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          // 2. Reflet lumineux coloré proche
          BoxShadow(
            color: _accentPink.withOpacity(0.22),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
          // 3. Large halo d'ambiance rose
          BoxShadow(
            color: _accentPink.withOpacity(0.1),
            blurRadius: 36,
            spreadRadius: -4,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (sans le badge par-dessus)
            Image.asset(
              plat.photo_url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Corps du texte
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- VILLE DÉPLACÉE ICI (APRÈS L'IMAGE) ---
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _accentPink.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, color: _accentPink, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          plat.ville.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: _accentPink,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plat.name,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavori(plat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFav ? Colors.redAccent.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.white38,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plat.description,
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Zone Recette stylisée
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RECETTE TRADITIONNELLE",
                          style: GoogleFonts.montserrat(
                            color: _accentPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plat.recette,
                          style: GoogleFonts.montserrat(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags du Plat
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: plat.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.montserrat(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}