import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class LouxorPage extends StatefulWidget {
  const LouxorPage({super.key});

  @override
  State<LouxorPage> createState() => _LouxorPageState();
}

class _LouxorPageState extends State<LouxorPage> {
  final ScrollController _mainScrollController = ScrollController();

  // CLÉ ISOLÉE POUR L'ANGLAIS
  List<String> _favoritePlacesJson = [];
  final String _storageKeyPlaces = 'favoris_en';

  static const List<Map<String, dynamic>> _luxorData = [
    {
      "name": "Karnak Temple",
      "sub_category": "Monuments",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/k.jpg",
      "description": "The largest religious complex of Antiquity, a true city of temples where every generation of pharaohs left its mark. The hypostyle hall, with its 134 monumental columns, is an architectural feat that leaves the visitor speechless in the face of the vastness of the ancient Egyptians' faith."
    },
    {
      "name": "Karnak Open Air Museum",
      "sub_category": "Monuments",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/temple.jpg",
      "description": "Located within the Karnak enclosure, this museum gathers architectural elements carefully reconstructed, such as the White Chapel of Senusret I. It is an essential stop to understand the artistic and technical evolution of Egyptian religious constructions."
    },
    {
      "name": "Luxor Temple",
      "sub_category": "Monuments",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/l.jpg",
      "description": "Located in the heart of the modern city, this temple was dedicated to the renewal of royal power. Beautifully illuminated at nightfall, it is distinguished by its colossi of Ramesses II, its solitary obelisk, and its mystical atmosphere that seems to defy time and the surrounding urban bustle."
    },
    {
      "name": "A Royal Tomb",
      "sub_category": "Valley of the Kings & Queens",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/tombe.jpg",
      "description": "Immerse yourself in the intimacy of the deceased sovereigns. The royal tombs offer a unique crossing to the afterlife, where every wall is covered with sacred texts and vibrantly colored frescoes, protecting the king and queen on their eternal journey."
    },
    {
      "name": "Valley of the Kings and Queens",
      "sub_category": "Valley of the Kings & Queens",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/rois.jpg",
      "description": "The most prestigious site of the Theban necropolis. Between the arid mountains of the west bank, the pharaohs and their wives had their secret dwellings dug, far from prying eyes, to ensure the longevity of their reign in the world of the gods."
    },
    {
      "name": "Colossi of Memnon",
      "sub_category": "Monuments",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/me.jpg",
      "description": "Two monumental sandstone statues that sit proudly in the plain. Although the mortuary temple of Amenhotep III to which they belonged has disappeared, these colossi remain impressive sentinels, witnesses to the excessive grandeur of the imperial constructions of the era."
    },
    {
      "name": "Medinet Habu Temple",
      "sub_category": "Monuments",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/habu.jpg",
      "description": "A mortuary temple of exceptional richness, where the reliefs recount the victorious battles of Ramesses III against the sea peoples. It is one of the few places where the original painting of the reliefs is still visible, offering a striking contrast between the raw stone and the finesse of the artistic detail."
    },
    {
      "name": "Deir el Medina",
      "sub_category": "Valley of the Artisans",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/deir.jpg",
      "description": "The village of the artisans who sculpted and painted the masterpieces of the Valley of the Kings. This place offers a rare and moving look at the daily life of ancient Egyptians, far from royal splendor, with their houses, workshops, and their own decorated family tombs."
    },
    {
      "name": "Luxor Hot Air Balloon",
      "sub_category": "Activities",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/m.jpg",
      "description": "An unforgettable aerial experience at sunrise. Fly over the Nile and the ancient sites to realize the grandeur of the Theban architectural plan, with the lushness of fertile lands on one side and the silent vastness of the desert plateaus on the other."
    },
    {
      "name": "Luxor by Boat",
      "sub_category": "Activities",
      "sub_folder": "Luxor",
      "region": "Historical Cities",
      "photo_url": "assets/louxor/b.jpg",
      "description": "Navigating the Nile, the life-giving river, is the very soul of Luxor. Whether on a traditional felucca or a cruise ship, the Nile offers a soothing and different perspective on the shores, where agricultural life has continued to follow the rhythm of the seasons for millennia."
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
        itemToSave['region'] = 'Historical Cities';
        itemToSave['sub_folder'] = 'Luxor';

        _favoritePlacesJson.add(jsonEncode(itemToSave));
      }
    });
    await prefs.setStringList(_storageKeyPlaces, _favoritePlacesJson);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Monuments": return Colors.amber;
      case "Valley of the Kings & Queens": return Colors.redAccent;
      case "Valley of the Artisans": return Colors.blueAccent;
      case "Activities": return Colors.greenAccent;
      default: return Colors.white;
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
    for (var item in _luxorData) {
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
              title: Text("Luxor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              ],
            ),
          )
        ],
      ),
    );
  }
}