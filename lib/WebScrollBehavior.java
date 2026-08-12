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

class AlexandriePage extends StatefulWidget {
  const AlexandriePage({super.key});

  @override
  State<AlexandriePage> createState() => _AlexandriePageState();
}

class _AlexandriePageState extends State<AlexandriePage> {
  final ScrollController _mainScrollController = ScrollController();

  // Clé corrigée pour correspondre au "tiroir" arabe
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  static const List<Map<String, dynamic>> _alexandrieData = [
    {
      "name": "قلعة قايتباي",
      "sub_category": "معالم تاريخية",
      "photo_url": "assets/alexendrie/qai.jpg",
      "description": "شُيدت في القرن الخامس عشر على أنقاض منارة الإسكندرية الأسطورية، إحدى عجائب الدنيا السبع القديمة. هذه القلعة الدفاعية المبنية من الحجر الجيري تقدم لمحة رائعة عن التاريخ العسكري المصري. أسوارها الضخمة، التي تداعبها أمواج البحر الأبيض المتوسط، تشهد على الاستراتيجية الدفاعية للسلطان قايتباي ضد التهديدات العثمانية في ذلك العصر."
    },
    {
      "name": "الكورنيش وكوبري ستانلي",
      "sub_category": "أنشطة لا غنى عنها",
      "photo_url": "assets/alexendrie/pont.jpg",
      "description": "شريان حيوي وشاعري للإسكندرية، يمتد الكورنيش على طول الساحل المتوسطي لمسافة كيلومترات، مقدماً بانوراما فريدة تمزج بين الحداثة الحضرية والحنين التاريخي. يمثل كوبري ستانلي، بأبراجه المميزة، جوهرة هذه الجولة، خاصة عند غروب الشمس عندما تتلألأ الأضواء على الماء، مما يجسد جوهر 'عروس البحر الأبيض المتوسط'."
    },
    {
      "name": "قصر المنتزه",
      "sub_category": "أماكن تاريخية",
      "photo_url": "assets/alexendrie/palais.jpeg",
      "description": "ملاذ حقيقي للسلام، يمتد المجمع الملكي للمنتزه على مساحات شاسعة من الحدائق الغناء المطلة على البحر. القصر الرئيسي، المستوحى من مزيج جريء من الطرازين الفلورنسي والتركي، كان يستخدم قديماً كإقامة صيفية للعائلة الملكية المصرية. التنزه في ممراته الظليلة هو انغماس في حقبة من البذخ والرقي المعماري الأوروبي في قلب مصر."
    },
    {
      "name": "مكتبة الإسكندرية",
      "sub_category": "ثقافة ومعرفة",
      "photo_url": "assets/alexendrie/alexandrina.jpg",
      "description": "أكثر من مجرد مبنى، مكتبة الإسكندرية الجديدة هي صرح للمعرفة العالمية، صُممت لتجسد روح المكتبة القديمة. هندستها المعمارية الجريئة، على شكل قرص مائل يغوص في حوض مياه، ترمز إلى شمس مشرقة تخرج من البحر. تضم ملايين الكتب والمتاحف المتخصصة وقاعات القراءة المذهلة، مما يجعلها منارة ثقافية عالمية."
    },
    {
      "name": "مسرح كوم الدكة",
      "sub_category": "معالم تاريخية",
      "photo_url": "assets/alexendrie/dick.jpg",
      "description": "اكتُشف بالصدفة عام 1960، هذا المسرح الروماني الصغير والمحفوظ بشكل مذهل هو الوحيد من نوعه في مصر. بمدرجاته الرخامية وأعمدته الجرانيتية، يشهد على عظمة الحياة الاجتماعية والثقافية في العصر اليوناني الروماني. الموقع، المخبأ في قلب المدينة الحديثة، يفتح نافذة لا مثيل لها على عادات الترفيه لدى سكان المدينة القدماء."
    },
    {
      "name": "عمود السواري",
      "sub_category": "معالم تاريخية",
      "photo_url": "assets/alexendrie/pompe.jpg",
      "description": "ينتصب بفخر على تلة، هذا العمود المكون من قطعة واحدة من الجرانيت الأحمر الأسواني هو إنجاز هندسي قديم. بارتفاع يصل إلى 27 متراً، هو الأثر الوحيد المتبقي من المعبد المهيب للسيرابيوم. هذا الصرح الضخم، الذي يهيمن على الحي الشعبي كرموز، يظل رمزاً قوياً لطول العمر التاريخي للمدينة وتنوعها الثقافي الغني."
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
        itemAAjouter['ville'] = 'الإسكندرية';
        itemAAjouter['region'] = 'المدن التاريخية';
        itemAAjouter['sub_folder'] = 'الإسكندرية';

        _favorisLieuxJson.add(jsonEncode(itemAAjouter));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Future<void> _ouvrirGoogleMaps(String nomLieu) async {
    final String query = Uri.encodeComponent('$nomLieu، الإسكندرية، مصر');
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Impossible d\'ouvrir la carte pour : $nomLieu -> $e');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "معالم تاريخية": return Colors.amber;
      case "أنشطة لا غنى عنها": return Colors.greenAccent;
      case "أماكن تاريخية": return Colors.blueAccent;
      case "ثقافة ومعرفة": return Colors.blueAccent;
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

    return Directionality(
      textDirection: TextDirection.rtl, // FORCE RTL
      child: Scaffold(
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
                title: Text("الإسكندرية", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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