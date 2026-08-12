import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import essentiel pour la sérialisation JSON des favoris
import 'package:url_launcher/url_launcher.dart'; // Import pour l'ouverture de Google Maps

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

class LouxorPage extends StatefulWidget {
  const LouxorPage({super.key});

  @override
  State<LouxorPage> createState() => _LouxorPageState();
}

class _LouxorPageState extends State<LouxorPage> {
  // Le ScrollController reste pour la gestion du défilement
  final ScrollController _mainScrollController = ScrollController();

  // Clé globale identique partagée avec home.dart, le_caire.dart et alexandrie.dart (version française)
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  static const List<Map<String, dynamic>> _louxorData = [
    {
      "name": "Le temple de Karnak",
      "sub_category": "Monuments",
      "photo_url": "assets/louxor/k.jpg",
      "description": "Le plus vaste complexe religieux de l'Antiquité, véritable cité de temples où chaque génération de pharaons a laissé son empreinte. La salle hypostyle, avec ses 134 colonnes monumentales, est une prouesse architecturale qui laisse le visiteur sans voix face à l'immensité de la foi des anciens Égyptiens.",
      "mapsQuery": "Karnak Temple Luxor"
    },
    {
      "name": "Le musée en plein air de Karnak",
      "sub_category": "Monuments",
      "photo_url": "assets/louxor/temple.jpg",
      "description": "Situé dans l'enceinte de Karnak, ce musée rassemble des éléments architecturaux reconstitués avec soin, comme la chapelle blanche de Sésostris Ier. C'est une étape incontournable pour comprendre l'évolution artistique et technique des constructions religieuses égyptiennes.",
      "mapsQuery": "Open Air Museum Karnak Luxor"
    },
    {
      "name": "Le temple de Louxor",
      "sub_category": "Monuments",
      "photo_url": "assets/louxor/l.jpg",
      "description": "Situé au cœur de la ville moderne, ce temple était dédié au renouveau du pouvoir royal. Magnifiquement éclairé à la tombée de la nuit, il se distingue par ses colosses de Ramsès II, son obélisque solitaire et son atmosphère mystique qui semble défier le temps et l'agitation urbaine environnante.",
      "mapsQuery": "Luxor Temple"
    },
    {
      "name": "Une tombe royale",
      "sub_category": "Vallée des Rois & Reines",
      "photo_url": "assets/louxor/tombe.jpg",
      "description": "Plongez dans l'intimité des souverains défunts. Les tombes royales offrent une traversée unique vers l'au-delà, où chaque paroi est recouverte de textes sacrés et de fresques aux couleurs éclatantes, protégeant le roi et la reine dans leur voyage éternel.",
      "mapsQuery": "Valley of the Kings Luxor"
    },
    {
      "name": "La vallée des Rois et des Reines",
      "sub_category": "Vallée des Rois & Reines",
      "photo_url": "assets/louxor/rois.jpg",
      "description": "Le site le plus prestigieux de la nécropole thébaine. Entre les montagnes arides de la rive ouest, les pharaons et leurs épouses ont fait creuser leurs demeures secrètes, loin des regards, pour assurer la pérennité de leur règne dans le monde des dieux.",
      "mapsQuery": "Valley of the Kings Luxor"
    },
    {
      "name": "Les colosses de Memnon",
      "sub_category": "Monuments",
      "photo_url": "assets/louxor/me.jpg",
      "description": "Deux statues monumentales en grès qui trônent fièrement dans la plaine. Bien que le temple funéraire d'Amenhotep III dont elles faisaient partie ait disparu, ces colosses restent des sentinelles impressionnantes, témoins de la grandeur démesurée des constructions impériales de l'époque.",
      "mapsQuery": "Colossi of Memnon Luxor"
    },
    {
      "name": "Le temple de Medinet Habu",
      "sub_category": "Monuments",
      "photo_url": "assets/louxor/habu.jpg",
      "description": "Un temple funéraire d'une richesse exceptionnelle, où les reliefs racontent les batailles victorieuses de Ramsès III contre les peuples de la mer. C'est l'un des rares endroits où la peinture originale des reliefs est encore visible, offrant un contraste saisissant entre la pierre brute et la finesse du détail artistique.",
      "mapsQuery": "Medinet Habu Temple Luxor"
    },
    {
      "name": "Deir el Medina",
      "sub_category": "Vallée des artisans",
      "photo_url": "assets/louxor/deir.jpg",
      "description": "Le village des artisans qui ont sculpté et peint les chefs-d'œuvre de la Vallée des Rois. Ce lieu offre un regard rare et émouvant sur la vie quotidienne des anciens égyptiens, loin des fastes royaux, avec leurs maisons, leurs ateliers et leurs propres sépultures familiales décorées.",
      "mapsQuery": "Deir el Medina Luxor"
    },
    {
      "name": "Louxor en montgolfière",
      "sub_category": "Activités",
      "photo_url": "assets/louxor/m.jpg",
      "description": "Une expérience aérienne inoubliable au lever du soleil. Survolez le Nil et les sites antiques pour réaliser la grandeur du plan architectural thébain, avec d'un côté la luxuriance des terres fertiles et de l'autre, l'immensité silencieuse des plateaux désertiques.",
      "mapsQuery": "Hot Air Balloon Luxor"
    },
    {
      "name": "Louxor en bateau",
      "sub_category": "Activités",
      "photo_url": "assets/louxor/b.jpg",
      "description": "La navigation sur le Nil, le fleuve nourricier, est l'âme même de Louxor. Que ce soit sur une felouque traditionnelle ou un bateau de croisière, le Nil offre une perspective apaisante et différente sur les rivages, là où la vie agricole continue à suivre le rythme des saisons depuis des millénaires.",
      "mapsQuery": "Felucca ride Luxor Nile"
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
        // de cette manière home.dart sait immédiatement qu'il s'agit de Louxor !
        final Map<String, dynamic> itemAAjouter = Map<String, dynamic>.from(item);
        itemAAjouter['ville'] = 'Louxor';
        itemAAjouter['region'] = 'Villes Historiques'; // Ajustez si vous utilisez une catégorie différente dans home.dart
        itemAAjouter['sub_folder'] = 'Louxor';

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Monuments": return Colors.amber;
      case "Vallée des Rois & Reines": return Colors.redAccent;
      case "Vallée des artisans": return Colors.blueAccent;
      case "Activités": return Colors.greenAccent;
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
    for (var item in _louxorData) {
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
              title: Text("Louxor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Louxor"),
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