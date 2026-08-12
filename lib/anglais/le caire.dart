import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

// --- WEB SCROLL CLASS ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class CairoPage extends StatefulWidget {
  const CairoPage({super.key});

  @override
  State<CairoPage> createState() => _CairoPageState();
}

class _CairoPageState extends State<CairoPage> {
  final ScrollController _scrollController = ScrollController();

  // CLÉ ISOLÉE POUR L'ANGLAIS
  List<String> _favoritePlacesJson = [];
  final String _storageKeyPlaces = 'favoris_en';

  static const List<Map<String, dynamic>> _cairoData = [
    {
      "name": "Cairo Tower",
      "sub_category": "Activities in Cairo",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/tour.jpg",
      "map_url": "https://maps.google.com/?q=Cairo+Tower",
      "description": "Rising to 187 meters, the Cairo Tower is a modern icon of the city, a true Egyptian version of the Eiffel Tower. Built in reinforced concrete in the shape of a lattice-work (mashrabiya), it offers a 360-degree observation deck. It is the perfect place to contemplate the vastness of the capital, the meanderings of the Nile, and, on a clear day, the Giza Pyramids on the horizon."
    },
    {
      "name": "Giza Pyramids",
      "sub_category": "Monuments",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/pyramide.jpg",
      "map_url": "https://maps.google.com/?q=Giza+Pyramids",
      "description": "The only wonders of the ancient world still standing, the pyramids of Khufu, Khafre, and Menkaure are the ultimate symbol of Egypt. This monumental archaeological site, guarded by the majestic Sphinx, testifies to the architectural genius and religious devotion of the Old Kingdom pharaohs. Exploring this plateau is walking in the footsteps of millenniums of human history in the heart of a desert that has preserved these treasures for eternity."
    },
    {
      "name": "Saladin Citadel",
      "sub_category": "Monuments",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/saladin.jpg",
      "map_url": "https://maps.google.com/?q=Saladin+Citadel+Cairo",
      "description": "Dominating the city from the heights of the Mokattam hills, this medieval fortress, built by Saladin in the 12th century, is a jewel of Islamic architecture. It houses the famous Alabaster Mosque (Mosque of Muhammad Ali), whose slender minarets are visible from everywhere in Cairo. Its fortifications offer not only a historical insight into medieval defenses but also one of the most beautiful panoramas of the city."
    },
    {
      "name": "Coptic Quarter",
      "sub_category": "Historical Sites",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/copte.jpg",
      "map_url": "https://maps.google.com/?q=Coptic+Cairo",
      "description": "Old Cairo hides the Coptic Quarter within its heart, a true sanctuary of spirituality. This is where the Hanging Church is located, built above the gates of the Roman fortress of Babylon, as well as the Ben Ezra Synagogue and the Church of Saints Sergius and Bacchus, where, according to tradition, the Holy Family found refuge during their flight to Egypt. A quiet place, charged with history, far from the urban turmoil."
    },
    {
      "name": "Grand Egyptian Museum",
      "sub_category": "Historical Sites",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/musee.jpg",
      "map_url": "https://maps.google.com/?q=Grand+Egyptian+Museum",
      "description": "One of the largest museums in the world dedicated to a single civilization. A modern architectural masterpiece housing invaluable treasures of Egyptian history, located near the pyramids."
    },
    {
      "name": "Khan el-Khalili",
      "sub_category": "Traditional Markets",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/khan.jpg",
      "map_url": "https://maps.google.com/?q=Khan+el-Khalili",
      "description": "Dive into the effervescence of the most famous souk in Cairo. Over 600 years old, this maze of narrow alleys is packed with artisan workshops, spice shops, perfumes, copper items, and handcrafted jewelry. It is a sensory journey where the cries of merchants, the smell of cardamom coffee, and the clinking of metal create a unique atmosphere in the world, perfect for total immersion in Cairene culture."
    },
    {
      "name": "Souk El-Fustat",
      "sub_category": "Traditional Markets",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/fustat.jpg",
      "map_url": "https://maps.google.com/?q=Souk+El-Fustat+Cairo",
      "description": "Located near the National Museum of Egyptian Civilization, Souk El-Fustat is a paradise for contemporary and traditional crafts. Less frenetic than Khan el-Khalili, this market highlights the quality of Egyptian manual labor, particularly pottery, textiles, and blown glass."
    },
    {
      "name": "Baron Empain Palace",
      "sub_category": "Architecture",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/baron.jpg",
      "map_url": "https://maps.google.com/?q=Baron+Empain+Palace",
      "description": "A spectacular Hindu-inspired palace located in Heliopolis. Its unique architecture and mysterious history make it a must-see in modern Cairo."
    },
    {
      "name": "Al-Azhar Park",
      "sub_category": "Relaxation Areas",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/al.jpg",
      "map_url": "https://maps.google.com/?q=Al-Azhar+Park+Cairo",
      "description": "A verdant haven of peace offering a magnificent view of the Citadel and old Cairo. Perfect for a relaxing walk away from the hustle and bustle."
    },
    {
      "name": "The Nile",
      "sub_category": "Historical Sites",
      "sub_folder": "Cairo",
      "region": "Historical Cities",
      "photo_url": "assets/caire/nil.jpg",
      "map_url": "https://maps.google.com/?q=Nile+River+Cairo",
      "description": "The vital artery of Egypt since antiquity, the Nile is the beating heart of Cairo. A mythical river, it allowed the development of pharaonic civilization and continues today to offer unforgettable felucca rides at sunset."
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
        final Map<String, dynamic> itemToSave = Map<String, dynamic>.from(item);
        itemToSave['region'] = 'Historical Cities';
        itemToSave['sub_folder'] = 'Cairo';

        _favoritePlacesJson.add(jsonEncode(itemToSave));
      }
    });
    await prefs.setStringList(_storageKeyPlaces, _favoritePlacesJson);
  }

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
      case "Historical Sites": return Colors.blueAccent;
      case "Architecture": return Colors.purpleAccent;
      case "Relaxation Areas": return Colors.greenAccent;
      case "Activities in Cairo": return Colors.greenAccent;
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
    for (var item in _cairoData) {
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
              title: Text("Cairo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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