import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import essentiel pour la sérialisation JSON des favoris

// --- CLASSE DE DÉFILEMENT WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class HurghadaPage extends StatefulWidget {
  const HurghadaPage({super.key});

  @override
  State<HurghadaPage> createState() => _HurghadaPageState();
}

class _HurghadaPageState extends State<HurghadaPage> {
  final ScrollController _scrollController = ScrollController();

  // Clé globale identique partagée avec les autres pages (version française)
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  static const List<Map<String, dynamic>> _hurghadaData = [
    {
      "name": "Safari en quad dans le désert",
      "sub_category": "Activités",
      "photo_url": "assets/hurgada/qaud.jpg",
      "description": "Vivez une montée d'adrénaline pure en chevauchant un quad à travers les étendues sauvages du désert oriental. Cette aventure vous emmène au cœur de paysages lunaires et de dunes dorées à perte de vue, avec une halte dans un campement bédouin authentique pour savourer un thé traditionnel et découvrir un mode de vie ancestral, loin de l'effervescence touristique."
    },
    {
      "name": "Plongée à l’île Giftoun",
      "sub_category": "Mer & Nature",
      "photo_url": "assets/hurgada/ile.jpg",
      "description": "Véritable joyau de la mer Rouge, l'île Giftoun est un sanctuaire marin protégé aux eaux turquoise cristallines. En plongeant dans ses sites renommés, vous découvrirez des jardins de coraux multicolores d'une densité incroyable et une vie sous-marine foisonnante, allant des tortues marines aux bancs de poissons tropicaux exotiques dans un écosystème d'une beauté intacte."
    },
    {
      "name": "La Marina d’Hurghada",
      "sub_category": "Détente & Vie nocturne",
      "photo_url": "assets/hurgada/marina.webp",
      "description": "Symbole du renouveau moderne d'Hurghada, la marina est un lieu incontournable pour les amateurs de luxe et de douceur de vivre. Entre les yachts somptueux amarrés au port et les terrasses chics bordant le quai, c'est l'endroit idéal pour flâner en fin de journée, profiter de la brise marine, dîner dans des restaurants gastronomiques ou prolonger la soirée dans une ambiance élégante et animée."
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
        // CORRECTION : On injecte explicitement la destination pour home.dart
        Map<String, dynamic> itemModifie = Map<String, dynamic>.from(item);
        itemModifie['region'] = "Mer Rouge";
        itemModifie['sub_folder'] = "Hurghada";
        itemModifie['ville'] = "Hurghada";

        _favorisLieuxJson.add(jsonEncode(itemModifie));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Activités": return Colors.redAccent;
      case "Mer & Nature": return Colors.blueAccent;
      case "Détente & Vie nocturne": return Colors.purpleAccent;
      default: return Colors.white;
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
    for (var item in _hurghadaData) {
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
              title: Text("Hurghada", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final String lieuNom = item['name'] ?? '';
    final bool isFav = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == lieuNom);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          // 1. Ombre portée principale très visible
          BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 12)),
          // 2. Halo coloré pour l'effet de reflet
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 0)),
          // 3. Liseré lumineux blanc pour le contraste maximal
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