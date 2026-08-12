import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Clé corrigée pour le tiroir de favoris arabe
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  static const List<Map<String, dynamic>> _hurghadaData = [
    {
      "name": "سفاري بالدراجات الرباعية في الصحراء",
      "sub_category": "أنشطة",
      "photo_url": "assets/hurgada/qaud.jpg",
      "description": "عش تجربة مليئة بالأدرينالين أثناء قيادة الدراجات الرباعية عبر البراري في الصحراء الشرقية. تأخذك هذه المغامرة إلى قلب المناظر الطبيعية التي تشبه سطح القمر والكثبان الذهبية الممتدة إلى ما لا نهاية، مع التوقف في مخيم بدوي أصيل للاستمتاع بشاي تقليدي واكتشاف أسلوب حياة عريق، بعيداً عن صخب السياحة."
    },
    {
      "name": "الغوص في جزيرة جفتون",
      "sub_category": "بحر وطبيعة",
      "photo_url": "assets/hurgada/ile.jpg",
      "description": "جوهرة حقيقية في البحر الأحمر، جزيرة جفتون هي محمية بحرية ذات مياه فيروزية صافية. عند الغوص في مواقعها الشهيرة، ستكتشف حدائق مرجانية ملونة ذات كثافة مذهلة، وحياة بحرية وفيرة، من السلاحف البحرية إلى أسراب الأسماك الاستوائية الغريبة في نظام بيئي ذي جمال أصيل."
    },
    {
      "name": "مارينا الغردقة",
      "sub_category": "استرخاء وحياة ليلية",
      "photo_url": "assets/hurgada/marina.webp",
      "description": "رمز التجديد الحديث للغردقة، المارينا مكان لا بد من زيارته لمحبي الفخامة والرفاهية. بين اليخوت الفاخرة الراسية في الميناء والشرفات الأنيقة المطلة على الرصيف، هو المكان المثالي للتنزه في نهاية اليوم، والاستمتاع بنسيم البحر، وتناول العشاء في مطاعم راقية أو تمديد السهرة في أجواء أنيقة وحيوية."
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
      // البحث عن الفهرس للتأكد من وجود العنصر مسبقاً أو عدم وجوده
      int index = _favorisLieuxJson.indexWhere((jsonStr) {
        try {
          final decoded = jsonDecode(jsonStr);
          return decoded['name'] == name;
        } catch (e) {
          return false;
        }
      });

      if (index != -1) {
        // إذا كان موجوداً، نقوم بحذفه باستخدام الفهرس الذي عثرنا عليه
        _favorisLieuxJson.removeAt(index);
      } else {
        // إذا لم يكن موجوداً، نقوم بإنشاء نسخة وإضافة البيانات الإضافية ثم تشفيرها وحفظها
        Map<String, dynamic> itemModifie = Map<String, dynamic>.from(item);
        itemModifie['region'] = "البحر الأحمر";
        itemModifie['sub_folder'] = "Hurghada";
        itemModifie['ville'] = "الغردقة";

        _favorisLieuxJson.add(jsonEncode(itemModifie));
      }
    });

    // حفظ القائمة المحدثة في SharedPreferences
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Future<void> _ouvrirGoogleMaps(String nomLieu) async {
    final String query = Uri.encodeComponent('$nomLieu، الغردقة، مصر');
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Impossible d\'ouvrir la carte pour : $nomLieu -> $e');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "أنشطة": return Colors.redAccent;
      case "بحر وطبيعة": return Colors.blueAccent;
      case "استرخاء وحياة ليلية": return Colors.purpleAccent;
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
                title: Text("الغردقة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _buildDesignCard(Map<String, dynamic> item, Color color) {
    final String lieuNom = item['name'] ?? '';

    // تحقق آمن من حالة المفضلة لتجنب أي أخطاء أثناء فك التشفير
    final bool isFav = _favorisLieuxJson.any((jsonStr) {
      try {
        return jsonDecode(jsonStr)['name'] == lieuNom;
      } catch (e) {
        return false;
      }
    });

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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _ouvrirGoogleMaps(lieuNom),
                    icon: const Icon(Icons.map_rounded, color: Colors.black87),
                    label: const Text(
                      "فتح في خريطة جوجل",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color == Colors.white ? const Color(0xFF57E1AD) : color,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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