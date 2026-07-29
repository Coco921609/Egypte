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

class AssouanPage extends StatefulWidget {
  const AssouanPage({super.key});

  @override
  State<AssouanPage> createState() => _AssouanPageState();
}

class _AssouanPageState extends State<AssouanPage> {
  final ScrollController _mainScrollController = ScrollController();

  // Clé corrigée pour le tiroir de favoris arabe
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  static const List<Map<String, dynamic>> _assouanData = [
    {
      "name": "أبو سمبل",
      "sub_category": "معالم رئيسية",
      "photo_url": "assets/assouan/s.jpg",
      "description": "تقع في عمق الصحراء، وتعد هاتان المعبدتان المنحوتتان في الصخر بواسطة رمسيس الثاني تحفة معمارية عالمية. عملية النقل الأسطورية لهذه المعابد لإنقاذها من مياه السد العالي تمثل مغامرة إنسانية وتقنية غير مسبوقة."
    },
    {
      "name": "معبد فيلة",
      "sub_category": "معالم رئيسية",
      "photo_url": "assets/assouan/phi.webp",
      "description": "مكرس للإلهة إيزيس، هذا المعبد هو جوهرة من الأناقة يقع على جزيرة أجيليكا. أعمدته ونقوشه الرقيقة وموقعه وسط مياه النيل تجعل منه واحداً من أكثر الأماكن شاعرية والأفضل حفظاً في النوبة السفلى."
    },
    {
      "name": "معبد حورس",
      "sub_category": "معالم رئيسية",
      "photo_url": "assets/assouan/h.jpg",
      "description": "شُيد في إدفو بين أسوان والأقصر، ويعد واحداً من أفضل المعابد حفظاً في مصر. مكرس للإله الصقر حورس، ويتميز بهيكله الكامل وأبراجه المهيبة وأجوائه المهيبة التي تنقل الزائر مباشرة إلى قلب العصر البطلمي."
    },
    {
      "name": "بحيرة ناصر (بحيرة النوبة)",
      "sub_category": "طبيعة ومناظر طبيعية",
      "photo_url": "assets/assouan/nasser.jpg",
      "description": "واحدة من أكبر البحيرات الصناعية في العالم، أنشئت نتيجة بناء السد العالي. مياهها الزرقاء العميقة تتباين بشكل رائع مع قسوة الصحراء المحيطة بها."
    },
    {
      "name": "دير القديس سمعان",
      "sub_category": "تاريخ وثقافة",
      "photo_url": "assets/assouan/saint.jpeg",
      "description": "يقع على الضفة الغربية للنيل، وهو دير محصن من القرن السابع الميلادي وأحد أفضل الأمثلة على العمارة القبطية في مصر. منعزل في المشهد الصحراوي، ويشهد على الحياة الرهبانية بأسواره الطوبية المثيرة للإعجاب وكنائسه ذات اللوحات الجدارية القديمة."
    },
    {
      "name": "جزيرة فيلة (إلفنتين)",
      "sub_category": "تاريخ وثقافة",
      "photo_url": "assets/assouan/ile.jpg",
      "description": "مفترق طرق تاريخي حقيقي، تضم هذه الجزيرة معبد خنوم ومقياس نيل قديم. بين حدائقها الغناء ومنازل القرية النوبية التقليدية، توفر انغماساً تاماً في الحياة اليومية الأسوانية."
    },
    {
      "name": "القرية النوبية",
      "sub_category": "تاريخ وثقافة",
      "photo_url": "assets/assouan/village.jpeg",
      "description": "اكتشف نمط حياة النوبيين من خلال منازلهم الملونة وحرفهم اليدوية المتقنة وكرم ضيافتهم. محطة لا غنى عنها لفهم الهوية الفريدة لهذه الثقافة."
    },
    {
      "name": "الحديقة النباتية بجزيرة كيتشنر",
      "sub_category": "طبيعة ومناظر طبيعية",
      "photo_url": "assets/assouan/parc.jpeg",
      "description": "جنة خضراء وسط النهر، تجمع أنواعاً نادرة وغريبة من جميع القارات. إنها المكان المثالي لاستراحة ظليلة وهادئة."
    },
    {
      "name": "جولة بالفلوكة",
      "sub_category": "أنشطة",
      "photo_url": "assets/assouan/balade.jpg",
      "description": "الانزلاق فوق مياه النيل في فلوكة، بدون ضجيج المحركات، هي تجربة حسية فريدة. إنها الطريقة الأكثر أصالة لاستكشاف الجزر المهجورة والمناظر الطبيعية الساحرة للنوبة."
    },
    {
      "name": "معبد كوم أمبو",
      "sub_category": "معالم رئيسية",
      "photo_url": "assets/assouan/ombo.jpeg",
      "description": "يقع على مرتفع يطل على النيل، وهو نادر من الناحية المعمارية. تصميمه المتماثل تماماً سمح بتكريسه لإلهين في وقت واحد: سوبيك (إله التمساح) وحوروار (الإله الصقر). مكان رائع لفهم الازدواجية في الديانة المصرية القديمة."
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
        itemAAjouter['ville'] = 'أسوان';
        itemAAjouter['region'] = 'المدن التاريخية';
        itemAAjouter['sub_folder'] = 'أسوان';

        _favorisLieuxJson.add(jsonEncode(itemAAjouter));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "معالم رئيسية": return Colors.amber;
      case "طبيعة ومناظر طبيعية": return Colors.greenAccent;
      case "تاريخ وثقافة": return Colors.blueAccent;
      case "أنشطة": return Colors.redAccent;
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
                title: Text("أسوان", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              ],
            ),
          )
        ],
      ),
    );
  }
}