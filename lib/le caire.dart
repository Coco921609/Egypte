import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import essentiel pour sérialiser le lieu en texte JSON

// --- 1. CLASSE DE DÉFILEMENT WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

// --- 2. PAGE PRINCIPALE (LE CAIRE) ---
class LeCairePage extends StatefulWidget {
  const LeCairePage({super.key});

  @override
  State<LeCairePage> createState() => _LeCairePageState();
}

class _LeCairePageState extends State<LeCairePage> {
  final ScrollController _mainScrollController = ScrollController();

  // Clé globale identique partagée avec home.dart (version française)
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_fr';

  static const List<Map<String, dynamic>> _leCaireData = [
    {
      "name": "La Tour du Caire",
      "sub_category": "Activités au Caire",
      "photo_url": "assets/caire/tour.jpg",
      "description": "Culminant à 187 mètres, la Tour du Caire is une icône moderne de la ville, véritable Tour Eiffel version égyptienne. Construite en béton armé sous la forme d'un moucharabieh, elle offre une plateforme d'observation à 360 degrés. C'est l'endroit idéal pour contempler l'immensité de la capitale, le méandre du Nil et, par temps clair, les pyramides de Gizeh à l'horizon."
    },
    {
      "name": "Pyramides de Gizeh",
      "sub_category": "Monuments",
      "photo_url": "assets/caire/pyramide.jpg",
      "description": "Seules merveilles du monde antique encore debout, les pyramides de Khéops, Khéphren et Mykérinos sont le symbole ultime de l'Égypte. Ce site archéologique monumental, gardé par le majestueux Sphinx, témoigne du génie architectural et de la dévotion religieuse des pharaons de l'Ancien Empire. Explorer ce plateau, c'est marcher sur les traces de l'histoire humaine millénaire au cœur d'un désert qui a préservé ces trésors pour l'éternité."
    },
    {
      "name": "La Citadelle de Saladin",
      "sub_category": "Monuments",
      "photo_url": "assets/caire/saladin.jpg",
      "description": "Dominant la ville depuis les hauteurs des collines de Mokattam, cette forteresse médiévale, construite par Saladin au XIIe siècle, est un joyau de l'architecture islamique. Elle abrite la célèbre Mosquée d'Albâtre (Mosquée de Mohamed Ali) dont les minarets élancés sont visibles de partout au Caire. Ses fortifications offrent non seulement un aperçu historique sur les défenses médiévales, mais aussi l'un des plus beaux panoramas sur la ville."
    },
    {
      "name": "Le Quartier Copte",
      "sub_category": "Lieux historiques",
      "photo_url": "assets/caire/copte.jpg",
      "description": "Le Vieux-Caire cache en son sein le quartier copte, véritable sanctuaire de spiritualité. C'est ici que se trouve l'église suspendue, bâtie au-dessus des portes de la forteresse romaine de Babylone, ainsi que la synagogue Ben Ezra et l'église Saint-Serge, où, selon la tradition, la Sainte Famille aurait trouvé refuge lors de sa fuite en Égypte. Un lieu calme, chargé d'histoire, loin du tumulte urbain."
    },
    {
      "name": "Le Grand Musée Égyptien",
      "sub_category": "Lieux historiques",
      "photo_url": "assets/caire/musee.jpg",
      "description": "L'un des plus grands musées au monde dédiés à une seule civilisation. Un chef-d'œuvre architectural moderne abritant des trésors inestimables de l'histoire égyptienne, situé à proximité des pyramides."
    },
    {
      "name": "Khan el-Khalili",
      "sub_category": "Marchés traditionnels",
      "photo_url": "assets/caire/khan.jpg",
      "description": "Plongez dans l'effervescence du plus célèbre souk du Caire. Vieux de plus de 600 ans, ce dédale de ruelles étroites regorge d'ateliers d'artisans, de boutiques d'épices, de parfums, d'objets en cuivre et de bijoux artisanaux. C'est un voyage sensoriel où les cris des marchands, l'odeur du café à la cardamome et le cliquetis du métal créent une ambiance unique au monde, parfaite pour une immersion totale dans la culture cairote."
    },
    {
      "name": "Souk El-Fustat",
      "sub_category": "Marchés traditionnels",
      "photo_url": "assets/caire/fustat.jpg",
      "description": "Situé près du musée national de la civilisation égyptienne, le Souk El-Fustat est le paradis de l'artisanat contemporain et traditionnel. Moins frénétique que Khan el-Khalili, ce marché met en avant la qualité du travail manuel égyptien, notamment la poterie, le textile et la verrerie soufflée."
    },
    {
      "name": "Palais Baron Empain",
      "sub_category": "Architecture",
      "photo_url": "assets/caire/baron.jpg",
      "description": "Un palais spectaculaire d'inspiration hindoue situé à Héliopolis. Son architecture unique et son histoire mystérieuse en font un lieu incontournable du Caire moderne."
    },
    {
      "name": "Parc Al-Azhar",
      "sub_category": "Lieux de détente",
      "photo_url": "assets/caire/al.jpg",
      "description": "Un havre de paix verdoyant offrant une vue magnifique sur la Citadelle et le vieux Caire. Parfait pour une promenade relaxante loin du tumulte."
    },
    {
      "name": "Le Nil",
      "sub_category": "Lieux historiques",
      "photo_url": "assets/caire/nil.jpg",
      "description": "Artère vitale de l'Égypte depuis l'Antiquité, le Nil est le cœur battant du Caire. Fleuve mythique, il a permis le développement de la civilisation pharaonique et continue aujourd'hui d'offrir des promenades en felouque inoubliables au coucher du soleil."
    },
  ];

  @override
  void initState() {
    super.initState();
    _chargerFavorisLieux();
  }

  Future<void> _chargerFavorisLieux() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisLieuxJson = prefs.getStringList(_cleStockageLieux) ?? [];
    });
  }

  // Alterne l'état favori et l'enregistre en JSON de manière synchrone pour le rafraîchissement visuel
  Future<void> _toggleFavoriLieu(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String name = item['name'];

    setState(() {
      bool existe = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      if (existe) {
        _favorisLieuxJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      } else {
        _favorisLieuxJson.add(jsonEncode(item));
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
    for (var item in _leCaireData) {
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
              title: Text("Le Caire", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDesignCard(Map<String, dynamic> item, Color color) {
    final String lieuNom = item['name'] ?? '';
    // Vérifier si le lieu est présent dans la liste JSON globale
    final bool isFav = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == lieuNom);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E1E1E),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(item['photo_url'] ?? '', height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(lieuNom, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : Colors.white54,
                        size: 26,
                      ),
                      onPressed: () => _toggleFavoriLieu(item), // Passe le Map complet de données au clic
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