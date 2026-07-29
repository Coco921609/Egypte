import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import essentiel pour la sérialisation JSON des favoris

// --- CLASSE DE DÉFILEMENT WEB ---
// Permet d'activer le clic-et-glisser avec la souris comme sur un navigateur web
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
  // Le ScrollController reste pour la gestion du défilement
  final ScrollController _mainScrollController = ScrollController();

  // Clé globale identique partagée avec home.dart et le_caire.dart (version française)
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  static const List<Map<String, dynamic>> _alexandrieData = [
    {
      "name": "Citadelle de Qaitbay",
      "sub_category": "Monuments historiques",
      "photo_url": "assets/alexendrie/qai.jpg",
      "description": "Érigée au XVe siècle sur les vestiges du mythique Phare d'Alexandrie, l'une des sept merveilles du monde antique, cette forteresse défensive en pierre calcaire offre une plongée fascinante dans l'histoire militaire égyptienne. Ses remparts massifs, baignés par les vagues de la Méditerranée, témoignent de la stratégie défensive du sultan Qaitbay face aux menaces ottomanes de l'époque."
    },
    {
      "name": "La Corniche et le pont Stanley",
      "sub_category": "Activités incontournables",
      "photo_url": "assets/alexendrie/pont.jpg",
      "description": "Artère vitale et poétique d'Alexandrie, la Corniche s'étire le long du rivage méditerranéen sur plusieurs kilomètres, offrant un panorama unique où se mêlent modernité urbaine et nostalgie historique. Le pont Stanley, avec ses tours caractéristiques, constitue le joyau de cette balade, particulièrement au coucher du soleil lorsque les lumières scintillent sur l'eau, capturant l'essence même de la 'Perle de la Méditerranée'."
    },
    {
      "name": "Palais de Montaza",
      "sub_category": "Lieux historiques",
      "photo_url": "assets/alexendrie/palais.jpeg",
      "description": "Véritable havre de paix, le complexe royal de Montaza s'étend sur des hectares de jardins luxuriants surplombant la mer. Le palais central, inspiré par un mélange audacieux de styles florentin et turc, servait autrefois de résidence d'été à la famille royale égyptienne. Se promener dans ses allées ombragées, c'est s'immerger dans une époque de faste et de raffinement architectural européen au cœur de l'Égypte."
    },
    {
      "name": "Bibliothèque Alexandrina",
      "sub_category": "Culture et Savoir",
      "photo_url": "assets/alexendrie/alexandrina.jpg",
      "description": "Plus qu'un simple bâtiment, la nouvelle Bibliothèque d'Alexandrie est un monument à la connaissance universelle, conçu pour réincarner l'esprit de l'ancienne bibliothèque antique. Son architecture audacieuse, en forme de disque incliné plongeant dans un bassin d'eau, symbolise un soleil levant sortant de la mer. Elle abrite des millions de livres, des musées spécialisés et des salles de lecture impressionnantes, faisant d'elle un phare culturel mondial."
    },
    {
      "name": "Amphithéâtre Kom-El-Dick",
      "sub_category": "Monuments historiques",
      "photo_url": "assets/alexendrie/dick.jpg",
      "description": "Découvert par hasard en 1960, ce petit amphithéâtre romain, remarquablement bien conservé, est le seul de son genre en Égypte. Avec ses gradins de marbre et ses colonnes de granit, il témoigne de la grandeur de la vie sociale et culturelle à l'époque gréco-romaine. Le site, niché au cœur de la ville moderne, offre une fenêtre imprenable sur les habitudes de divertissement des anciens habitants de la cité."
    },
    {
      "name": "Colonne de Pompée",
      "sub_category": "Monuments historiques",
      "photo_url": "assets/alexendrie/pompe.jpg",
      "description": "Se dressant fièrement sur une colline, cette colonne monolithique en granit rouge d'Assouan est un exploit d'ingénierie antique. Haute de près de 27 mètres, elle est le seul vestige encore debout du temple majestueux du Sérapéum. Ce monument imposant, qui domine le quartier populaire de Karmouz, reste un symbole puissant de la longévité historique de la ville et de sa riche mixité culturelle passée."
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
        // de cette manière home.dart sait immédiatement qu'il s'agit d'Alexandrie !
        final Map<String, dynamic> itemAAjouter = Map<String, dynamic>.from(item);
        itemAAjouter['ville'] = 'Alexandrie';
        itemAAjouter['region'] = 'Villes Historiques';
        itemAAjouter['sub_folder'] = 'Alexandrie';

        _favorisLieuxJson.add(jsonEncode(itemAAjouter));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Monuments": return Colors.amber;
      case "Marchés traditionnels": return Colors.redAccent;
      case "Lieux historiques": return Colors.blueAccent;
      case "Architecture": return Colors.purpleAccent;
      case "Lieux de détente": return Colors.greenAccent;
      case "Monuments historiques": return Colors.amber;
      case "Activités incontournables": return Colors.greenAccent;
      case "Culture et Savoir": return Colors.blueAccent;
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
    for (var item in _alexandrieData) {
      groupedData.putIfAbsent(item['sub_category'], () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      // ScrollConfiguration englobe toute la page pour forcer la logique web
      body: ScrollConfiguration(
        behavior: WebScrollBehavior(),
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const ClampingScrollPhysics(), // Retire l'effet de rebond
          slivers: [
            const SliverAppBar(
              pinned: false, // Le titre défile vers le haut
              backgroundColor: Color(0xFF101010),
              title: Text("Alexandrie", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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