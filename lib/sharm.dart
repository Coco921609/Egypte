import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import essentiel pour la sérialisation JSON des favoris
import 'package:url_launcher/url_launcher.dart'; // Import pour l'ouverture de Google Maps[cite: 12]

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

class SharmElSheikhPage extends StatefulWidget {
  const SharmElSheikhPage({super.key});

  @override
  State<SharmElSheikhPage> createState() => _SharmElSheikhPageState();
}

class _SharmElSheikhPageState extends State<SharmElSheikhPage> {
  final ScrollController _scrollController = ScrollController();

  // Clé globale identique partagée avec les autres pages (version française)[cite: 12]
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  static const List<Map<String, dynamic>> _sharmData = [
    {
      "name": "La mosquée Al Sahaba",
      "sub_category": "Monuments & Culture",
      "photo_url": "assets/sharm/mosque.jpeg",
      "description": "Située au cœur de la vieille ville, cette mosquée est un véritable chef-d'œuvre architectural. Alliant avec élégance les styles ottoman, fatimide et mamelouk, elle impressionne par ses détails complexes et sa silhouette imposante. Lorsque la nuit tombe, son éclairage savamment étudié sublime ses façades et ses minarets, créant une atmosphère mystique et majestueuse qui attire les visiteurs du monde entier.",
      "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
    },
    {
      "name": "L'Église Copte Orthodoxe",
      "sub_category": "Monuments & Culture",
      "photo_url": "assets/sharm/eglise.jpg",
      "description": "Cette église est un joyau de sérénité et de beauté spirituelle. Ses vitraux aux couleurs vibrantes projettent des jeux de lumière fascinants à l'intérieur, tandis que ses fresques murales détaillées racontent avec précision la riche tradition copte égyptienne. C'est un havre de paix essentiel pour ceux qui souhaitent découvrir la profondeur culturelle et chrétienne de la région, loin du tumulte balnéaire.",
      "mapsQuery": "Coptic Church Sharm El-Sheikh"
    },
    {
      "name": "Hollywood Sharm El-Sheikh",
      "sub_category": "Monuments & Culture",
      "photo_url": "assets/sharm/h.jpg",
      "description": "Véritable parc à thème spectaculaire, ce lieu unique transporte les visiteurs dans un univers fantastique. Entre les répliques géantes de statues célèbres, les fontaines dansantes chorégraphiées et les installations lumineuses féeriques, c'est une destination incontournable pour les familles et les amateurs de photographie. L'ambiance y est constamment animée, offrant une expérience ludique et totalement dépaysante.",
      "mapsQuery": "Hollywood Sharm El-Sheikh"
    },
    {
      "name": "La Vieille Ville",
      "sub_category": "Monuments & Culture",
      "photo_url": "assets/sharm/la.jpg",
      "description": "Le Vieux Marché représente le cœur battant et historique de Sharm El-Sheikh. C’est un labyrinthe vivant de ruelles où l'on découvre l'essence même de la culture locale. Entre les étals d'artisanat traditionnel, les épices aux parfums envoûtants et les boutiques de souvenirs, le visiteur s'immerge dans une ambiance authentique. C'est l'endroit rêvé pour goûter à la gastronomie égyptienne et échanger avec les commerçants dans une atmosphère chaleureuse.",
      "mapsQuery": "Old Market Sharm El-Sheikh"
    },
    {
      "name": "Le monastère Sainte-Catherine",
      "sub_category": "Excursions incontournables",
      "photo_url": "assets/sharm/saint.webp",
      "description": "Niché au pied des montagnes grandioses du Sinaï, ce monastère est l'un des plus anciens lieux de culte chrétien encore en activité dans le monde. Classé au patrimoine mondial, il abrite une collection inestimable d'icônes byzantines, de manuscrits anciens et le célèbre 'Buisson Ardent'. Une visite ici est un voyage dans le temps, imprégné de spiritualité et d'une histoire séculaire qui semble figée dans le désert.",
      "mapsQuery": "Saint Catherine's Monastery Sinai"
    },
    {
      "name": "Le mont Sinaï",
      "sub_category": "Excursions incontournables",
      "photo_url": "assets/sharm/mont.jpeg",
      "description": "Lieu chargé d'une puissance symbolique immense, le mont Sinaï est la destination par excellence des pèlerins et randonneurs. L'ascension, traditionnellement effectuée de nuit pour atteindre le sommet avant l'aube, est une épreuve physique récompensée par un lever de soleil spectaculaire. Voir la lumière embraser les cimes désertiques depuis ce sommet historique offre un moment de contemplation rare et une expérience visuelle absolument inoubliable.",
      "mapsQuery": "Mount Sinai Egypt"
    },
    {
      "name": "Dahab",
      "sub_category": "Excursions incontournables",
      "photo_url": "assets/sharm/Dahab.webp",
      "description": "Ancien village de pêcheurs devenu un repaire mythique pour les voyageurs en quête de liberté, Dahab possède une atmosphère bohème unique. Réputée mondialement pour son rythme de vie détendu et ses sites de plongée d'exception, la ville est une étape incontournable. Son mélange de culture bédouine et de mode de vie décontracté en bord de mer, couplé à la proximité de sites naturels grandioses, en fait une destination fascinante.",
      "mapsQuery": "Dahab South Sinai"
    },
    {
      "name": "L’île de Tiran",
      "sub_category": "Mer & Nature",
      "photo_url": "assets/sharm/tirana.jpg",
      "description": "L'île de Tiran est un véritable sanctuaire pour les amoureux de la mer. Située à l'embouchure du golfe d'Aqaba, elle est entourée de récifs coralliens parmi les plus préservés et les plus riches de la mer Rouge. Ses eaux d'une clarté incroyable permettent d'observer une faune marine dense, incluant des tortues marines, des raies et une multitude de poissons tropicaux, faisant de chaque excursion une aventure immersive dans un aquarium naturel à ciel ouvert.",
      "mapsQuery": "Tiran Island Red Sea"
    },
    {
      "name": "La mer",
      "sub_category": "Mer & Nature",
      "photo_url": "assets/sharm/mer.jpg",
      "description": "La mer Rouge, véritable joyau de l'Égypte, offre des conditions de baignade et de plongée inégalées. Avec ses eaux turquoise dont la température est idéale toute l'année et une biodiversité marine d'une richesse rare au monde, elle constitue le terrain de jeu favori des plongeurs. Explorer ses fonds marins, c'est plonger dans un univers de coraux colorés et de vie sauvage où le spectacle sous-marin est un émerveillement constant.",
      "mapsQuery": "Red Sea Sharm El-Sheikh"
    },
    {
      "name": "Dahab Blue Hole",
      "sub_category": "Mer & Nature",
      "photo_url": "assets/sharm/ll.jpg",
      "description": "Le Blue Hole de Dahab est un site légendaire qui exerce une fascination magnétique sur tous les plongeurs du globe. Il s'agit d'un gouffre sous-marin naturel d'une profondeur vertigineuse, entouré de récifs coralliens d'une densité incroyable. La transition brutale entre le bleu lagon peu profond et le bleu profond et mystérieux de l'abîme offre un spectacle visuel saisissant, faisant de cet endroit un défi et un rêve pour les passionnés d'exploration sous-marine.",
      "mapsQuery": "Blue Hole Dahab"
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

  // Ajoute ou retire un lieu de la liste globale au format JSON[cite: 12]
  Future<void> _toggleFavoriLieu(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String name = item['name'];

    setState(() {
      bool existe = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      if (existe) {
        _favorisLieuxJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      } else {
        // On crée une copie pour y injecter explicitement la localisation
        // de cette manière home.dart sait immédiatement qu'il s'agit de Sharm El-Sheikh ![cite: 12]
        final Map<String, dynamic> itemAAjouter = Map<String, dynamic>.from(item);
        itemAAjouter['ville'] = 'Sharm El-Sheikh';
        itemAAjouter['region'] = 'Mer Rouge';
        itemAAjouter['sub_folder'] = 'Sharm El-Sheikh';

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
      case "Monuments & Culture": return Colors.amber;
      case "Excursions incontournables": return Colors.purpleAccent;
      case "Mer & Nature": return Colors.blueAccent;
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
    for (var item in _sharmData) {
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
              pinned: false, // Titre défilant avec le contenu[cite: 12]
              backgroundColor: Color(0xFF101010),
              title: Text("Sharm El-Sheikh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    // Vérification de la présence du lieu dans l'état local global[cite: 12]
    final bool isFav = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == lieuNom);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          // 1. Ombre portée principale très visible[cite: 12]
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          ),
          // 2. Halo coloré pour l'effet de reflet[cite: 12]
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 0),
          ),
          // 3. Liseré lumineux blanc pour le contraste maximal[cite: 12]
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
                    onPressed: () => _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Sharm El-Sheikh"),
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