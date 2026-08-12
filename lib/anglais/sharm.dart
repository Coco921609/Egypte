import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Import pour ouvrir Google Maps
import 'dart:convert'; // Essential import for JSON serialization of favorites

// --- WEB SCROLL CLASS ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class SharmElSheikhPage extends StatefulWidget {
  const SharmElSheikhPage({super.key});

  @override
  State<SharmElSheikhPage> createState() => _SharmElSheikhPageState();
}

class _SharmElSheikhPageState extends State<SharmElSheikhPage> {
  final ScrollController _scrollController = ScrollController();

  // CLÉ ISOLÉE POUR L'ANGLAIS
  List<String> _favoritePlacesJson = [];
  final String _storageKeyPlaces = 'favoris_en';

  static const List<Map<String, dynamic>> _sharmData = [
    {
      "name": "Al Sahaba Mosque",
      "sub_category": "Monuments & Culture",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/mosque.jpeg",
      "map_url": "https://maps.google.com/?q=Al+Sahaba+Mosque+Sharm+El-Sheikh",
      "description": "Located in the heart of the old town, this mosque is a true architectural masterpiece. Elegantly blending Ottoman, Fatimid, and Mamluk styles, it impresses with its intricate details and imposing silhouette. As night falls, its expertly designed lighting enhances its facades and minarets, creating a mystical and majestic atmosphere that attracts visitors from all over the world."
    },
    {
      "name": "Coptic Orthodox Church",
      "sub_category": "Monuments & Culture",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/eglise.jpg",
      "map_url": "https://maps.google.com/?q=Coptic+Orthodox+Church+Sharm+El-Sheikh",
      "description": "This church is a jewel of serenity and spiritual beauty. Its vibrantly colored stained glass windows cast fascinating light effects inside, while its detailed wall frescoes accurately tell the rich Egyptian Coptic tradition. It is an essential haven of peace for those wishing to discover the cultural and Christian depth of the region, far from the seaside bustle."
    },
    {
      "name": "Hollywood Sharm El-Sheikh",
      "sub_category": "Monuments & Culture",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/h.jpg",
      "map_url": "https://maps.google.com/?q=Hollywood+Sharm+El-Sheikh",
      "description": "A truly spectacular theme park, this unique place transports visitors into a fantastic universe. Between giant replicas of famous statues, choreographed dancing fountains, and enchanting light installations, it is a must-visit destination for families and photography enthusiasts. The atmosphere is constantly lively, offering a fun and totally exotic experience."
    },
    {
      "name": "The Old Town",
      "sub_category": "Monuments & Culture",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/la.jpg",
      "map_url": "https://maps.google.com/?q=Old+Market+Sharm+El-Sheikh",
      "description": "The Old Market represents the beating and historical heart of Sharm El-Sheikh. It is a living labyrinth of alleys where one discovers the very essence of local culture. Between traditional craft stalls, enchanting spices, and souvenir shops, visitors immerse themselves in an authentic ambiance. It is the perfect place to taste Egyptian gastronomy and interact with merchants in a warm atmosphere."
    },
    {
      "name": "Saint Catherine's Monastery",
      "sub_category": "Essential Excursions",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/saint.webp",
      "map_url": "https://maps.google.com/?q=Saint+Catherine's+Monastery+Sinai",
      "description": "Nestled at the foot of the magnificent Sinai mountains, this monastery is one of the oldest Christian places of worship still in operation in the world. A World Heritage site, it houses an invaluable collection of Byzantine icons, ancient manuscripts, and the famous 'Burning Bush'. A visit here is a journey through time, imbued with spirituality and a centuries-old history that seems frozen in the desert."
    },
    {
      "name": "Mount Sinai",
      "sub_category": "Essential Excursions",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/mont.jpeg",
      "map_url": "https://maps.google.com/?q=Mount+Sinai+Egypt",
      "description": "A place of immense symbolic power, Mount Sinai is the ultimate destination for pilgrims and hikers. The climb, traditionally done at night to reach the summit before dawn, is a physical challenge rewarded by a spectacular sunrise. Seeing the light ignite the desert peaks from this historic summit offers a moment of rare contemplation and an absolutely unforgettable visual experience."
    },
    {
      "name": "Dahab",
      "sub_category": "Essential Excursions",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/Dahab.webp",
      "map_url": "https://maps.google.com/?q=Dahab+Egypt",
      "description": "A former fishing village that has become a mythical haven for travelers in search of freedom, Dahab possesses a unique bohemian atmosphere. World-renowned for its relaxed pace of life and exceptional diving sites, the city is an essential stop. Its mix of Bedouin culture and laid-back seaside lifestyle, coupled with the proximity of grandiose natural sites, makes it a fascinating destination."
    },
    {
      "name": "Tiran Island",
      "sub_category": "Sea & Nature",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/tirana.jpg",
      "map_url": "https://maps.google.com/?q=Tiran+Island+Red+Sea",
      "description": "Tiran Island is a true sanctuary for sea lovers. Located at the mouth of the Gulf of Aqaba, it is surrounded by coral reefs among the most preserved and richest in the Red Sea. Its incredibly clear waters allow for the observation of dense marine life, including sea turtles, rays, and a multitude of tropical fish, making each excursion an immersive adventure in an open-air natural aquarium."
    },
    {
      "name": "The Sea",
      "sub_category": "Sea & Nature",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/mer.jpg",
      "map_url": "https://maps.google.com/?q=Sharm+El-Sheikh+Red+Sea",
      "description": "The Red Sea, a true jewel of Egypt, offers unparalleled swimming and diving conditions. With its turquoise waters whose temperature is ideal all year round and marine biodiversity of rare richness in the world, it is the favorite playground for divers. Exploring its seabed means diving into a universe of colorful corals and wild life where the underwater show is a constant wonder."
    },
    {
      "name": "Dahab Blue Hole",
      "sub_category": "Sea & Nature",
      "sub_folder": "Sharm El-Sheikh",
      "region": "Coastal Cities",
      "photo_url": "assets/sharm/ll.jpg",
      "map_url": "https://maps.google.com/?q=Blue+Hole+Dahab",
      "description": "The Dahab Blue Hole is a legendary site that exerts a magnetic fascination on all divers around the globe. It is a natural underwater sinkhole of dizzying depth, surrounded by incredibly dense coral reefs. The brutal transition between the shallow lagoon blue and the deep, mysterious blue of the abyss offers a striking visual spectacle, making this place a challenge and a dream for underwater exploration enthusiasts."
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavoritePlaces();
  }

  Future<void> _loadFavoritePlaces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePlacesJson = prefs.getStringList(_storageKeyPlaces) ?? [];
    });
  }

  Future<void> _toggleFavoritePlace(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String name = item['name'];

    setState(() {
      bool exists = _favoritePlacesJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      if (exists) {
        _favoritePlacesJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      } else {
        // Injection des métadonnées pour la compatibilité avec HomeEnglish
        final Map<String, dynamic> itemToSave = Map<String, dynamic>.from(item);
        itemToSave['region'] = 'Coastal Cities';
        itemToSave['sub_folder'] = 'Sharm El-Sheikh';

        _favoritePlacesJson.add(jsonEncode(itemToSave));
      }
    });
    await prefs.setStringList(_storageKeyPlaces, _favoritePlacesJson);
  }

  // Fonction pour ouvrir Google Maps
  Future<void> _openMap(String mapUrl) async {
    final Uri uri = Uri.parse(mapUrl);
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching map: $e');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Monuments & Culture": return Colors.amber;
      case "Essential Excursions": return Colors.purpleAccent;
      case "Sea & Nature": return Colors.blueAccent;
      default: return Colors.tealAccent;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in _sharmData) {
      groupedData.putIfAbsent(item['sub_category'], () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: ScrollConfiguration(
        behavior: WebScrollBehavior(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              pinned: false,
              backgroundColor: Color(0xFF101010),
              title: Text("Sharm El-Sheikh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            ...groupedData.entries.map((entry) => SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(color: _getCategoryColor(entry.key), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                ),
                ...entry.value.map((item) => _buildDesignCard(item, _getCategoryColor(entry.key))),
              ]),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignCard(Map<String, dynamic> item, Color color) {
    final String placeName = item['name'] ?? '';
    final bool isFav = _favoritePlacesJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == placeName);

    // Contraste automatique pour le texte et l'icône du bouton selon la couleur de la catégorie
    final bool isLightColor = color == Colors.amber || color == Colors.greenAccent || color == Colors.tealAccent || color == Colors.white;
    final Color textColor = isLightColor ? Colors.black : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 12)),
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 0)),
          BoxShadow(color: Colors.white.withOpacity(0.12), blurRadius: 0, spreadRadius: 1.5, offset: const Offset(0, 1.5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.black,
              child: Image.asset(item['photo_url'] ?? '', fit: BoxFit.cover, alignment: Alignment.topCenter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(placeName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                    IconButton(
                      icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFav ? Colors.redAccent : Colors.white54, size: 26),
                      onPressed: () => _toggleFavoritePlace(item),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(item['sub_category'] ?? '', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(item['description'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openMap(item['map_url'] ?? ''),
                    icon: Icon(Icons.map_outlined, size: 18, color: textColor),
                    label: Text(
                      "Open in Google Maps",
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}