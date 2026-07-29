import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class AssouanPage extends StatefulWidget {
  const AssouanPage({super.key});

  @override
  State<AssouanPage> createState() => _AssouanPageState();
}

class _AssouanPageState extends State<AssouanPage> {
  final ScrollController _mainScrollController = ScrollController();

  // CLÉ ISOLÉE POUR L'ANGLAIS
  List<String> _favoritePlacesJson = [];
  final String _storageKeyPlaces = 'favoris_en';

  static const List<Map<String, dynamic>> _aswanData = [
    {
      "name": "Abu Simbel",
      "sub_category": "Major Monuments",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/s.jpg",
      "description": "Located at the edge of the desert, this complex of two temples carved into the rock by Ramesses II is a masterpiece of world architecture. The titanic relocation of these temples to save them from the waters of the dam is an unprecedented human and technical adventure."
    },
    {
      "name": "Temple of Philae",
      "sub_category": "Major Monuments",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/phi.webp",
      "description": "Dedicated to the goddess Isis, this temple is a jewel of elegance located on the island of Agilkia. Its colonnades, delicate reliefs, and position amidst the waters of the Nile make it one of the most poetic and best-preserved sites in all of Lower Nubia."
    },
    {
      "name": "Temple of Horus",
      "sub_category": "Major Monuments",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/h.jpg",
      "description": "Built in Edfu between Aswan and Luxor, this temple is one of the best-preserved in Egypt. Dedicated to the falcon god Horus, it stands out for its complete structure, imposing pylons, and solemn atmosphere that transports the visitor directly to the heart of the Ptolemaic era."
    },
    {
      "name": "Lake Nasser (Lake Nubia)",
      "sub_category": "Nature and Landscapes",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/nasser.jpg",
      "description": "One of the largest artificial lakes in the world, created by the construction of the High Dam. Its deep blue waters contrast beautifully with the aridity of the surrounding desert."
    },
    {
      "name": "Monastery of Saint Simeon",
      "sub_category": "History and Culture",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/saint.jpeg",
      "description": "Located on the west bank of the Nile, this 7th-century fortified monastery is one of the best-preserved examples of Coptic architecture in Egypt. Isolated in the desert landscape, it bears witness to the ascetic life of the monks with its impressive mud-brick walls, churches with ancient frescoes, and monastic cells overlooking the valley."
    },
    {
      "name": "Elephantine Island",
      "sub_category": "History and Culture",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/ile.jpg",
      "description": "A true historical crossroads, this island houses the Temple of Khnum and an ancient Nilometer. Between its lush gardens and the traditional houses of the Nubian village located there, it offers total immersion in Aswan's daily life."
    },
    {
      "name": "The Nubian Village",
      "sub_category": "History and Culture",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/village.jpeg",
      "description": "Discover the Nubian way of life through their colorful houses, refined craftsmanship, and hospitality. An essential stop to understand the unique identity of this culture."
    },
    {
      "name": "Kitchener's Island Botanical Garden",
      "sub_category": "Nature and Landscapes",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/parc.jpeg",
      "description": "A green paradise in the middle of the river, gathering rare exotic species from every continent. It is the perfect place for a shaded break."
    },
    {
      "name": "Felucca Ride",
      "sub_category": "Activities",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/balade.jpg",
      "description": "Gliding on the Nile in a felucca, without the noise of an engine, is a unique sensory experience. The most authentic way to explore the desert islets and fascinating landscapes of Nubia."
    },
    {
      "name": "Temple of Kom Ombo",
      "sub_category": "Major Monuments",
      "sub_folder": "Aswan",
      "region": "Historical Cities",
      "photo_url": "assets/assouan/ombo.jpeg",
      "description": "Located on a promontory overlooking the Nile, this temple is an architectural rarity. Its perfectly symmetrical design allows it to be dedicated simultaneously to two deities: Sobek, the crocodile god, and Haroeris, the falcon god. It is a fascinating place to understand duality in ancient Egyptian religion."
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
        itemToSave['sub_folder'] = 'Aswan';

        _favoritePlacesJson.add(jsonEncode(itemToSave));
      }
    });
    await prefs.setStringList(_storageKeyPlaces, _favoritePlacesJson);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Major Monuments": return Colors.amber;
      case "Nature and Landscapes": return Colors.greenAccent;
      case "History and Culture": return Colors.blueAccent;
      case "Activities": return Colors.redAccent;
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
    for (var item in _aswanData) {
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
              title: Text("Aswan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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