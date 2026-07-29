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

class SharmElSheikhPage extends StatefulWidget {
  const SharmElSheikhPage({super.key});

  @override
  State<SharmElSheikhPage> createState() => _SharmElSheikhPageState();
}

class _SharmElSheikhPageState extends State<SharmElSheikhPage> {
  final ScrollController _scrollController = ScrollController();

  // Clé corrigée pour le tiroir de favoris arabe
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  static const List<Map<String, dynamic>> _sharmData = [
    {
      "name": "مسجد الصحابة",
      "sub_category": "معالم وثقافة",
      "photo_url": "assets/sharm/mosque.jpeg",
      "description": "يقع في قلب المدينة القديمة، ويعد هذا المسجد تحفة معمارية حقيقية. يجمع بأناقة بين الطراز العثماني والفاطمي والمملوكي، ويبهر بتفاصيله المعقدة وصورته الظلية المهيبة."
    },
    {
      "name": "الكنيسة القبطية الأرثوذكسية",
      "sub_category": "معالم وثقافة",
      "photo_url": "assets/sharm/eglise.jpg",
      "description": "هذه الكنيسة هي جوهرة من السكينة والجمال الروحي. تلقي نوافذها الزجاجية الملونة النابضة بالحياة مسرحيات رائعة من الضوء في الداخل، بينما تروي جدارياتها المفصلة بدقة التقاليد القبطية المصرية الغنية."
    },
    {
      "name": "هوليوود شرم الشيخ",
      "sub_category": "معالم وثقافة",
      "photo_url": "assets/sharm/h.jpg",
      "description": "مدينة ملاهٍ مذهلة حقًا، ينقل هذا المكان الفريد الزوار إلى عالم خيالي. بين النسخ المتماثلة العملاقة للتماثيل الشهيرة، والنوافير الراقصة المصممة بحركات متناغمة."
    },
    {
      "name": "السوق القديم",
      "sub_category": "معالم وثقافة",
      "photo_url": "assets/sharm/la.jpg",
      "description": "يمثل السوق القديم القلب التاريخي النابض لشرم الشيخ. إنه متاهة حية من الأزقة حيث يكتشف المرء جوهر الثقافة المحلية، بين أكشاك الحرف اليدوية التقليدية والتوابل ذات الروائح الساحرة."
    },
    {
      "name": "دير سانت كاترين",
      "sub_category": "رحلات لا بد من زيارتها",
      "photo_url": "assets/sharm/saint.webp",
      "description": "يقع عند سفح جبال سيناء الرائعة، ويعد هذا الدير أحد أقدم أماكن العبادة المسيحية التي لا تزال تعمل في العالم. يضم مجموعة لا تقدر بثمن من الأيقونات والمخطوطات القديمة."
    },
    {
      "name": "جبل سيناء",
      "sub_category": "رحلات لا بد من زيارتها",
      "photo_url": "assets/sharm/mont.jpeg",
      "description": "مكان مشحون بقوة رمزية هائلة، جبل سيناء هو الوجهة النهائية للحجاج والمتنزهين. الصعود، الذي يتم تقليديًا في الليل للوصول إلى القمة قبل الفجر، هو تجربة بصرية لا تُنسى."
    },
    {
      "name": "دهب",
      "sub_category": "رحلات لا بد من زيارتها",
      "photo_url": "assets/sharm/Dahab.webp",
      "description": "قرية صيد سابقة أصبحت مخبأً أسطوريًا للمسافرين الباحثين عن الحرية، تمتلك دهب أجواءً بوهيمية فريدة وتعد محطة لا بد من زيارتها بمواقع الغوص الاستثنائية."
    },
    {
      "name": "جزيرة تيران",
      "sub_category": "البحر والطبيعة",
      "photo_url": "assets/sharm/tirana.jpg",
      "description": "جزيرة تيران هي محمية حقيقية لمحبي البحر، وتحيط بها شعاب مرجانية تعد من بين الأكثر حماية والأغنى في البحر الأحمر. تسمح مياهها الصافية بمراقبة الحياة البحرية الكثيفة."
    },
    {
      "name": "البحر الأحمر",
      "sub_category": "البحر والطبيعة",
      "photo_url": "assets/sharm/mer.jpg",
      "description": "البحر الأحمر، جوهرة مصر الحقيقية، يوفر ظروف سباحة وغوص لا مثيل لها. بمياهه الفيروزية والتنوع البيولوجي البحري الغني، فهو الملعب المفضل للغواصين."
    },
    {
      "name": "الثقب الأزرق (Blue Hole) في دهب",
      "sub_category": "البحر والطبيعة",
      "photo_url": "assets/sharm/ll.jpg",
      "description": "الثقب الأزرق في دهب هو موقع أسطوري يمارس سحرًا مغناطيسيًا على الغواصين. إنه فجوة طبيعية تحت الماء ذات عمق مذهل، وتحيط بها شعاب مرجانية ذات كثافة لا تصدق."
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
        itemAAjouter['ville'] = 'شرم الشيخ';
        itemAAjouter['region'] = 'البحر الأحمر';
        itemAAjouter['sub_folder'] = 'Sharm';

        _favorisLieuxJson.add(jsonEncode(itemAAjouter));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "معالم وثقافة": return Colors.amber;
      case "رحلات لا بد من زيارتها": return Colors.purpleAccent;
      case "البحر والطبيعة": return Colors.blueAccent;
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            thickness: 8.0,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                const SliverAppBar(
                  pinned: false,
                  backgroundColor: Color(0xFF101010),
                  title: Text("شرم الشيخ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      child: Text(item['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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