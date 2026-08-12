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

class FayoumPage extends StatefulWidget {
  const FayoumPage({super.key});

  @override
  State<FayoumPage> createState() => _FayoumPageState();
}

class _FayoumPageState extends State<FayoumPage> {
  final ScrollController _scrollController = ScrollController();

  // CLÉ ISOLÉE POUR L'ANGLAIS
  List<String> _favoritePlacesJson = [];
  final String _storageKeyPlaces = 'favoris_en';

  static const List<Map<String, dynamic>> _fayoumData = [
    {
      "name": "Wadi El-Rayan Waterfalls",
      "sub_category": "Activities to do in Fayoum",
      "sub_folder": "Fayoum",
      "region": "Nature & Adventure",
      "photo_url": "assets/fayoum/cascade.jpg",
      "map_url": "https://maps.google.com/?q=Wadi+El-Rayan+Waterfalls+Fayoum",
      "description": "The Wadi El-Rayan waterfalls are the only natural waterfalls in Egypt. You can admire two lakes connected by a waterfall, walk in the desert, and enjoy spectacular landscapes between dunes and water."
    },
    {
      "name": "Tunis Oasis",
      "sub_category": "Activities to do in Fayoum",
      "sub_folder": "Fayoum",
      "region": "Nature & Adventure",
      "photo_url": "assets/fayoum/tunis.webp",
      "map_url": "https://maps.google.com/?q=Tunis+Village+Fayoum",
      "description": "Tunis village is a small artist village nestled on the edge of Lake Qarun. You can discover pottery workshops, walk through the colorful alleys, and enjoy a magnificent view of the lake."
    },
    {
      "name": "Lake Qarun",
      "sub_category": "Activities to do in Fayoum",
      "sub_folder": "Fayoum",
      "region": "Nature & Adventure",
      "photo_url": "assets/fayoum/lac.jpg",
      "map_url": "https://maps.google.com/?q=Lake+Qarun+Fayoum",
      "description": "Lake Qarun is one of the oldest natural lakes in the world. You can go on boat trips, observe migratory birds, and enjoy the desert landscape around the lake."
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
        itemToSave['region'] = 'Nature & Adventure';
        itemToSave['sub_folder'] = 'Fayoum';

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
      case "Activities to do in Fayoum": return Colors.tealAccent;
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
    for (var item in _fayoumData) {
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
              title: Text("Fayoum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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