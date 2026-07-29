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

class FayoumPage extends StatefulWidget {
  const FayoumPage({super.key});

  @override
  State<FayoumPage> createState() => _FayoumPageState();
}

class _FayoumPageState extends State<FayoumPage> {
  final ScrollController _scrollController = ScrollController();

  // Clé corrigée pour le tiroir de favoris arabe
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  static const List<Map<String, dynamic>> _fayoumData = [
    {
      "name": "شلالات وادي الريان",
      "sub_category": "أنشطة يمكن القيام بها في الفيوم",
      "photo_url": "assets/fayoum/cascade.jpg",
      "description": "تعد شلالات وادي الريان الشلالات الطبيعية الوحيدة في مصر. يمكنك هناك الاستمتاع ببحيرتين متصلتين بشلال، والتنزه في الصحراء والاستمتاع بمناظر خلابة تجمع بين الكثبان الرملية والمياه."
    },
    {
      "name": "قرية تونس",
      "sub_category": "أنشطة يمكن القيام بها في الفيوم",
      "photo_url": "assets/fayoum/tunis.webp",
      "description": "قرية تونس هي قرية صغيرة للفنانين تقع على حافة بحيرة قارون. يمكنك اكتشاف ورش الفخار هناك، والتجول في الأزقة الملونة، والاستمتاع بإطلالة رائعة على البحيرة."
    },
    {
      "name": "بحيرة قارون",
      "sub_category": "أنشطة يمكن القيام بها في الفيوم",
      "photo_url": "assets/fayoum/lac.jpg",
      "description": "بحيرة قارون هي واحدة من أقدم البحيرات الطبيعية في العالم. يمكنك القيام بجولات بالقارب، ومراقبة الطيور المهاجرة، والاستمتاع بالمناظر الطبيعية الصحراوية المحيطة بالبحيرة."
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

  Future<void> _toggleFavoriLieu(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String name = item['name'];

    setState(() {
      bool existe = _favorisLieuxJson.any((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      if (existe) {
        _favorisLieuxJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['name'] == name);
      } else {
        final Map<String, dynamic> itemAAjouter = Map<String, dynamic>.from(item);
        itemAAjouter['ville'] = 'الفيوم';
        itemAAjouter['region'] = 'الواحة';
        itemAAjouter['sub_folder'] = 'الفيوم';

        _favorisLieuxJson.add(jsonEncode(itemAAjouter));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in _fayoumData) {
      groupedData.putIfAbsent(item['sub_category'], () => []).add(item);
    }

    return Directionality(
      textDirection: TextDirection.rtl, // FORCE RTL
      child: Scaffold(
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
                title: Text("الفيوم", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                iconTheme: IconThemeData(color: Colors.white),
                elevation: 0,
              ),
              ...groupedData.entries.map((entry) => SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(color: Colors.tealAccent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                  ...entry.value.map((item) => _buildDesignCard(item, Colors.tealAccent)),
                ]),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
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
                    Expanded(
                      child: Text(lieuNom, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
              ],
            ),
          )
        ],
      ),
    );
  }
}