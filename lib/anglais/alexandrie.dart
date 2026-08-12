import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Import pour ouvrir Google Maps
import 'dart:convert'; // Essential import for JSON serialization of favorites

// --- 1. WEB SCROLL BEHAVIOR CLASS ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class AlexandriePage extends StatefulWidget {
  const AlexandriePage({super.key});

  @override
  State<AlexandriePage> createState() => _AlexandriePageState();
}

class _AlexandriePageState extends State<AlexandriePage> {
  final ScrollController _mainScrollController = ScrollController();

  // CLÉ ISOLÉE POUR L'ANGLAIS
  List<String> _favoritePlacesJson = [];
  final String _storageKeyPlaces = 'favoris_en';

  static const List<Map<String, dynamic>> _alexandriaData = [
    {
      "name": "Citadel of Qaitbay",
      "sub_category": "Historical Monuments",
      "photo_url": "assets/alexendrie/qai.jpg",
      "map_url": "https://maps.google.com/?q=Citadel+of+Qaitbay+Alexandria",
      "description": "Built in the 15th century on the ruins of the mythical Lighthouse of Alexandria, one of the seven wonders of the ancient world, this defensive limestone fortress offers a fascinating dive into Egyptian military history. Its massive ramparts, bathed by the waves of the Mediterranean, bear witness to the defensive strategy of Sultan Qaitbay against the Ottoman threats of the time."
    },
    {
      "name": "The Corniche and Stanley Bridge",
      "sub_category": "Must-do Activities",
      "photo_url": "assets/alexendrie/pont.jpg",
      "map_url": "https://maps.google.com/?q=Stanley+Bridge+Alexandria",
      "description": "A vital and poetic artery of Alexandria, the Corniche stretches along the Mediterranean shore for several kilometers, offering a unique panorama where urban modernity and historical nostalgia intertwine. The Stanley Bridge, with its characteristic towers, is the jewel of this walk, especially at sunset when the lights sparkle on the water, capturing the very essence of the 'Pearl of the Mediterranean'."
    },
    {
      "name": "Montaza Palace",
      "sub_category": "Historical Places",
      "photo_url": "assets/alexendrie/palais.jpeg",
      "map_url": "https://maps.google.com/?q=Montaza+Palace+Alexandria",
      "description": "A true haven of peace, the royal complex of Montaza spans hectares of lush gardens overlooking the sea. The central palace, inspired by a bold mix of Florentine and Turkish styles, once served as the summer residence for the Egyptian royal family. Strolling through its shaded paths is to immerse oneself in an era of splendor and European architectural refinement in the heart of Egypt."
    },
    {
      "name": "Bibliotheca Alexandrina",
      "sub_category": "Culture and Knowledge",
      "photo_url": "assets/alexendrie/alexandrina.jpg",
      "map_url": "https://maps.google.com/?q=Bibliotheca+Alexandrina",
      "description": "More than just a building, the new Library of Alexandria is a monument to universal knowledge, designed to reincarnate the spirit of the ancient library. Its bold architecture, in the shape of a tilted disc plunging into a pool of water, symbolizes a rising sun emerging from the sea. It houses millions of books, specialized museums, and impressive reading rooms, making it a global cultural beacon."
    },
    {
      "name": "Kom El Dikka Amphitheatre",
      "sub_category": "Historical Monuments",
      "photo_url": "assets/alexendrie/dick.jpg",
      "map_url": "https://maps.google.com/?q=Kom+El+Dikka+Alexandria",
      "description": "Discovered by chance in 1960, this small, remarkably well-preserved Roman amphitheater is the only one of its kind in Egypt. With its marble tiers and granite columns, it testifies to the grandeur of social and cultural life in the Greco-Roman era. The site, nestled in the heart of the modern city, offers an unobstructed window into the entertainment habits of the ancient inhabitants of the city."
    },
    {
      "name": "Pompey's Pillar",
      "sub_category": "Historical Monuments",
      "photo_url": "assets/alexendrie/pompe.jpg",
      "map_url": "https://maps.google.com/?q=Pompey's+Pillar+Alexandria",
      "description": "Standing proudly on a hill, this monolithic red granite column from Aswan is a feat of ancient engineering. Nearly 27 meters high, it is the only standing remnant of the majestic Serapeum temple. This imposing monument, which dominates the popular district of Karmouz, remains a powerful symbol of the city's historical longevity and its rich mixed cultural past."
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

  // --- Injection des métadonnées pour la Home Page ---
  Future<void> _toggleFavoritePlace(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String name = item['name'];

    setState(() {
      bool exists = _favoritePlacesJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      if (exists) {
        _favoritePlacesJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      } else {
        // Copie de l'item et ajout des champs requis par HomeEnglish
        final Map<String, dynamic> itemToSave = Map<String, dynamic>.from(item);
        itemToSave['region'] = 'Historical Cities';
        itemToSave['sub_folder'] = 'Alexandria';

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
      case "Monuments": return Colors.amber;
      case "Traditional Markets": return Colors.redAccent;
      case "Historical Places": return Colors.blueAccent;
      case "Architecture": return Colors.purpleAccent;
      case "Relaxing Places": return Colors.greenAccent;
      case "Historical Monuments": return Colors.amber;
      case "Must-do Activities": return Colors.greenAccent;
      case "Culture and Knowledge": return Colors.blueAccent;
      default: return Colors.tealAccent;
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in _alexandriaData) {
      groupedData.putIfAbsent(item['sub_category'], () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: ScrollConfiguration(
        behavior: WebScrollBehavior(),
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              pinned: false,
              backgroundColor: Color(0xFF101010),
              title: Text("Alexandria", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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