import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import essentiel pour la sérialisation JSON des favoris
import 'package:url_launcher/url_launcher.dart'; // Import pour l'ouverture de Google Maps

// --- CLASSE DE DÉFILEMENT WEB ---
// Permet le clic-et-glisser avec la souris comme sur un navigateur web
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class DesertPage extends StatefulWidget {
  const DesertPage({super.key});

  @override
  State<DesertPage> createState() => _DesertPageState();
}

class _DesertPageState extends State<DesertPage> {
  // Contrôleur de défilement
  final ScrollController _scrollController = ScrollController();

  // Clé globale identique partagée avec home.dart et les autres pages (version française)
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  static const List<Map<String, dynamic>> _desertData = [
    {
      "name": "Désert Blanc",
      "sub_category": "Les déserts : lieux à découvrir",
      "photo_url": "assets/desert/blanc.jpg",
      "description": "Observer les formations rocheuses blanches uniques, camper dans le désert et faire de la photographie paysagère.",
      "mapsQuery": "Désert Blanc Égypte"
    },
    {
      "name": "Désert Noir",
      "sub_category": "Les déserts : lieux à découvrir",
      "photo_url": "assets/desert/noir.webp",
      "description": "Le désert Noir tire son nom des roches volcaniques noires qui couvrent ses collines. On peut y faire des excursions en 4×4, camper sous les étoiles et découvrir des paysages lunaires spectaculaires.",
      "mapsQuery": "Désert Noir Égypte"
    },
  ];

  @override
  void initState() {
    super.initState();
    _chargerFavorisLieux();
  }

  // Charge les favoris depuis le stockage local
  Future<void> _chargerFavorisLieux() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisLieuxJson = prefs.getStringList(_cleStockageLieux) ?? [];
    });
  }

  // Ajoute ou retire un lieu de la liste globale au format JSON
  Future<void> _toggleFavoriLieu(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String name = item['name'];

    setState(() {
      bool existe = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      if (existe) {
        _favorisLieuxJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      } else {
        // On crée une copie pour y injecter explicitement la localisation
        // de cette manière home.dart sait immédiatement qu'il s'agit des Déserts !
        final Map<String, dynamic> itemAAjouter = Map<String, dynamic>.from(item);
        itemAAjouter['ville'] = 'Déserts';
        itemAAjouter['region'] = 'Déserts';
        itemAAjouter['sub_folder'] = 'Desert';

        _favorisLieuxJson.add(jsonEncode(itemAAjouter));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  // Méthode sécurisée pour ouvrir l'application Google Maps
  Future<void> _ouvrirMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('Impossible d\'ouvrir Google Maps');
      }
    } catch (e) {
      debugPrint('Erreur ouverture Maps : $e');
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
    for (var item in _desertData) {
      groupedData.putIfAbsent(item['sub_category'], () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: ScrollConfiguration(
        behavior: WebScrollBehavior(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(), // Défilement rigide type web
          slivers: [
            const SliverAppBar(
              pinned: false, // Le titre défile avec le reste
              backgroundColor: Color(0xFF101010),
              title: Text("Déserts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            ...groupedData.entries.map((entry) => SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                ),
                ...entry.value.map((item) => _buildDesignCard(item, Colors.orangeAccent)),
              ]),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignCard(Map<String, dynamic> item, Color color) {
    final String lieuNom = item['name'] ?? '';
    // Vérification de la présence du lieu dans l'état local global
    final bool isFav = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == lieuNom);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          // 1. Ombre portée principale très visible
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          ),
          // 2. Halo coloré pour l'effet de reflet
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 0),
          ),
          // 3. Liseré lumineux blanc pour le contraste maximal
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            blurRadius: 0,
            spreadRadius: 1.5,
            offset: const Offset(0, 1.5),
          ),
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
              child: Image.asset(
                item['photo_url'] ?? '',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
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
                    Expanded(
                      child: Text(
                        lieuNom,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : Colors.white54,
                        size: 26,
                      ),
                      onPressed: () => _toggleFavoriLieu(item),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item['description'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Égypte"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.navigation_outlined, size: 18),
                    label: const Text(
                      'Ouvrir dans Google Maps',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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