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

class AssouanPage extends StatefulWidget {
  const AssouanPage({super.key});

  @override
  State<AssouanPage> createState() => _AssouanPageState();
}

class _AssouanPageState extends State<AssouanPage> {
  final ScrollController _mainScrollController = ScrollController();

  // Clé globale identique partagée avec home.dart, le_caire.dart, louxor.dart (version française)
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  static const List<Map<String, dynamic>> _assouanData = [
    {
      "name": "Abou Simbel",
      "sub_category": "Monuments majeurs",
      "photo_url": "assets/assouan/s.jpg",
      "description": "Situé aux confins du désert, cet ensemble de deux temples creusés dans la roche par Ramsès II est un chef-d'œuvre de l'architecture mondiale. Le déplacement titanesque de ces temples pour les sauver des eaux du barrage est une aventure humaine et technique sans précédent.",
      "mapsQuery": "Abou Simbel"
    },
    {
      "name": "Temple de Philae",
      "sub_category": "Monuments majeurs",
      "photo_url": "assets/assouan/phi.webp",
      "description": "Dédié à la déesse Isis, ce temple est un joyau d'élégance situé sur l'île d'Agilkia. Ses colonnades, ses reliefs délicats et sa position au milieu des eaux du Nil en font l'un des lieux les plus poétiques et les mieux conservés de toute la Basse-Nubie.",
      "mapsQuery": "Temple de Philae Assouan"
    },
    {
      "name": "Temple d'Horus",
      "sub_category": "Monuments majeurs",
      "photo_url": "assets/assouan/h.jpg",
      "description": "Érigé à Edfou entre Assouan et Louxor, ce temple est l'un des mieux préservés d'Égypte. Dédié au dieu faucon Horus, il se distingue par sa structure complète, ses pylônes imposants et son atmosphère solennelle qui transporte le visiteur directement au cœur de l'époque ptolémaïque.",
      "mapsQuery": "Temple d'Horus Edfou"
    },
    {
      "name": "Lac Nasser (lac de Nubie)",
      "sub_category": "Nature et Paysages",
      "photo_url": "assets/assouan/nasser.jpg",
      "description": "L'un des plus grands lacs artificiels au monde, créé par la construction du haut barrage. Ses eaux d'un bleu profond contrastent magnifiquement avec l'aridité du désert environnant.",
      "mapsQuery": "Lac Nasser Assouan"
    },
    {
      "name": "Le monastère de Saint-Siméon",
      "sub_category": "Histoire et Culture",
      "photo_url": "assets/assouan/saint.jpeg",
      "description": "Situé sur la rive ouest du Nil, ce monastère fortifié du VIIe siècle est l'un des exemples les mieux conservés de l'architecture copte en Égypte. Isolé dans le paysage désertique, il témoigne de la vie ascétique des moines avec ses impressionnantes murailles en briques crues, ses églises aux fresques anciennes et ses cellules monastiques qui dominent la vallée.",
      "mapsQuery": "Monastère de Saint-Siméon Assouan"
    },
    {
      "name": "L’île Éléphantine",
      "sub_category": "Histoire et Culture",
      "photo_url": "assets/assouan/ile.jpg",
      "description": "Véritable carrefour historique, cette île abrite le temple de Khnoum et un nilomètre antique. Entre ses jardins luxuriants et les maisons traditionnelles du village nubien qui s'y trouve, elle offre une immersion totale dans la vie quotidienne assouanaise.",
      "mapsQuery": "Île Éléphantine Assouan"
    },
    {
      "name": "Le village nubien",
      "sub_category": "Histoire et Culture",
      "photo_url": "assets/assouan/village.jpeg",
      "description": "Découvrez le mode de vie des Nubiens à travers leurs maisons colorées, leur artisanat raffiné et leur hospitalité. Une escale incontournable pour comprendre l'identité singulière de cette culture.",
      "mapsQuery": "Nubian Village Aswan"
    },
    {
      "name": "Le jardin botanique de l’île Kitchener",
      "sub_category": "Nature et Paysages",
      "photo_url": "assets/assouan/parc.jpeg",
      "description": "Un paradis verdoyant au milieu du fleuve, rassemblant des espèces exotiques rares issues de tous les continents. C'est l'endroit rêvé pour une pause ombragée.",
      "mapsQuery": "Aswan Botanical Garden Kitchener Island"
    },
    {
      "name": "Balade en felouque",
      "sub_category": "Activités",
      "photo_url": "assets/assouan/balade.jpg",
      "description": "Glisser sur le Nil en felouque, sans le bruit d'un moteur, est une expérience sensorielle unique. Le moyen le plus authentique pour explorer les îlots déserts et les paysages fascinants de la Nubie.",
      "mapsQuery": "Felucca ride Aswan"
    },
    {
      "name": "Temple de Kôm Ombo",
      "sub_category": "Monuments majeurs",
      "photo_url": "assets/assouan/ombo.jpeg",
      "description": "Situé sur un promontoire surplombant le Nil, ce temple est une rareté architecturale. Sa conception parfaitement symétrique lui permet d'être dédié simultanément à deux divinités : Sobek, le dieu crocodile, et Haroëris, le dieu faucon. C'est un lieu fascinant pour comprendre la dualité dans la religion égyptienne antique.",
      "mapsQuery": "Temple de Kom Ombo"
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
        // de cette manière home.dart sait immédiatement qu'il s'agit d'Assouan !
        final Map<String, dynamic> itemAAjouter = Map<String, dynamic>.from(item);
        itemAAjouter['ville'] = 'Assouan';
        itemAAjouter['region'] = 'Villes Historiques';
        itemAAjouter['sub_folder'] = 'Assouan';

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
      case "Monuments majeurs": return Colors.amber;
      case "Nature et Paysages": return Colors.greenAccent;
      case "Histoire et Culture": return Colors.blueAccent;
      case "Activités": return Colors.redAccent;
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
    for (var item in _assouanData) {
      groupedData.putIfAbsent(item['sub_category'], () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: ScrollConfiguration(
        behavior: WebScrollBehavior(),
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const ClampingScrollPhysics(), // Retire l'effet élastique
          slivers: [
            const SliverAppBar(
              pinned: false, // Le titre défile vers le haut
              backgroundColor: Color(0xFF101010),
              title: Text("Assouan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Assouan"),
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