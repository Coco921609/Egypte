import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- WEB CONFIGURATION ---
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

class Dish {
  final String name, sub_category, photo_url, description, city, recipe;
  final List<String> tags;

  Dish({
    required this.name,
    required this.sub_category,
    required this.photo_url,
    required this.description,
    required this.city,
    required this.recipe,
    required this.tags,
  });
}

class GastronomyPage extends StatefulWidget {
  const GastronomyPage({super.key});

  @override
  State<GastronomyPage> createState() => _GastronomyPageState();
}

class _GastronomyPageState extends State<GastronomyPage> {
  final ScrollController _scrollController = ScrollController();
  List<String> _favoritePlacesJson = [];

  // CLÉ ISOLÉE POUR L'ANGLAIS
  final String _storageKeyPlaces = 'favoris_en';

  final Color _bgDark = const Color(0xFF090A0F);
  final Color _cardDark = const Color(0xFF14151B);
  final Color _accentPink = const Color(0xFFFD79A8);

  final List<Dish> all_dishes = [
    Dish(name: "Koshari", sub_category: "Gastronomy", photo_url: "assets/plat/k.jpg", city: "Cairo", description: "The national Cairene dish, a mix of rice, lentils, macaroni, and chickpeas.", recipe: "Mix rice, lentils, macaroni, and chickpeas, then top with tomato sauce and fried onions.", tags: ["Vegetarian", "Popular", "Street food"]),
    Dish(name: "Ful medames", sub_category: "Gastronomy", photo_url: "assets/plat/f.jpg", city: "Cairo", description: "Stewed fava bean puree with spices, the traditional national breakfast.", recipe: "Stew the fava beans, then season with olive oil, garlic, lemon, and cumin.", tags: ["Breakfast", "Traditional", "Beans"]),
    Dish(name: "Taameya", sub_category: "Gastronomy", photo_url: "assets/plat/t.webp", city: "Cairo", description: "Fresh fava bean and herb falafels, crispy on the outside.", recipe: "Blend fava beans, cilantro, and spices, form patties, and deep fry.", tags: ["Falafel", "Street food", "Sandwich"]),
    Dish(name: "Baladi bread", sub_category: "Gastronomy", photo_url: "assets/plat/p.jpg", city: "Cairo", description: "Traditional Egyptian bread baked at high temperature.", recipe: "Knead whole wheat flour, shape into discs, and bake in a very hot oven.", tags: ["Bread", "Traditional", "Essential"]),
    Dish(name: "Grilled pigeon", sub_category: "Gastronomy", photo_url: "assets/plat/g.webp", city: "Luxor", description: "Pigeon stuffed with freekeh, a roasted green wheat.", recipe: "Stuff the pigeon with freekeh and roast until the skin is golden.", tags: ["Meat", "Festive", "Specialty"]),
    Dish(name: "Kebda", sub_category: "Gastronomy", photo_url: "assets/plat/2.webp", city: "Alexandria", description: "Beef liver marinated in intense spices, seared over high heat.", recipe: "Marinate the liver, then sear on a hot griddle with chili peppers.", tags: ["Liver", "Spicy", "Street food"]),
    Dish(name: "Om ali", sub_category: "Gastronomy", photo_url: "assets/plat/9.jpg", city: "Cairo", description: "Hot puff pastry pudding with milk, coconut, and pistachios.", recipe: "Soak puff pastry in sweetened milk and bake until golden with nuts.", tags: ["Dessert", "Hot", "National"]),
    Dish(name: "Basbousa", sub_category: "Gastronomy", photo_url: "assets/plat/4.jpg", city: "Aswan", description: "Moist semolina cake soaked in scented syrup.", recipe: "Bake the semolina cake and soak in orange blossom syrup.", tags: ["Dessert", "Semolina", "Sweet"]),
    Dish(name: "Konafa", sub_category: "Gastronomy", photo_url: "assets/plat/2.jpg", city: "Cairo", description: "Crispy buttered vermicelli, garnished with cream or cheese.", recipe: "Brown the vermicelli, garnish with cream, and drizzle with scented syrup.", tags: ["Dessert", "Crispy", "Cheese"]),
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePlacesJson = prefs.getStringList(_storageKeyPlaces) ?? [];
    });
  }

  Future<void> _toggleFavorite(Dish dish) async {
    final prefs = await SharedPreferences.getInstance();
    bool exists = false;
    int indexFound = -1;

    for (int i = 0; i < _favoritePlacesJson.length; i++) {
      try {
        final map = jsonDecode(_favoritePlacesJson[i]);
        if (map['name'] == dish.name) {
          exists = true;
          indexFound = i;
          break;
        }
      } catch (e) {
        // Ignore
      }
    }

    setState(() {
      if (exists) {
        _favoritePlacesJson.removeAt(indexFound);
      } else {
        // INJECTION MÉTADONNÉES POUR COMPATIBILITÉ
        final Map<String, dynamic> dishMap = {
          'name': dish.name,
          'sub_category': "Gastronomy",
          'photo_url': dish.photo_url,
          'description': dish.description,
          'city': dish.city,
          'recipe': dish.recipe,
          'region': "Practical Info",
          'sub_folder': "Gastronomy",
        };
        _favoritePlacesJson.add(jsonEncode(dishMap));
      }
    });

    await prefs.setStringList(_storageKeyPlaces, _favoritePlacesJson);
  }

  bool _isFavorite(String name) {
    for (var jsonStr in _favoritePlacesJson) {
      try {
        if (jsonDecode(jsonStr)['name'] == name) return true;
      } catch (e) {
        // Ignore
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
              SliverAppBar(
                pinned: false,
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
                  "Egyptian Gastronomy",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _build_dish_card(all_dishes[index]),
                    childCount: all_dishes.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build_dish_card(Dish dish) {
    final bool isFav = _isFavorite(dish.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentPink.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 16, offset: const Offset(0, 8)),
          BoxShadow(color: _accentPink.withOpacity(0.22), blurRadius: 12, spreadRadius: -2, offset: const Offset(0, 4)),
          BoxShadow(color: _accentPink.withOpacity(0.1), blurRadius: 36, spreadRadius: -4, offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(dish.photo_url, height: 200, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          dish.city.toUpperCase(),
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
                          dish.name,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorite(dish),
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
                    dish.description,
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          "TRADITIONAL RECIPE",
                          style: GoogleFonts.montserrat(
                            color: _accentPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dish.recipe,
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dish.tags.map((tag) => Container(
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