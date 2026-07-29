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

class LouxorPage extends StatefulWidget {
  const LouxorPage({super.key});

  @override
  State<LouxorPage> createState() => _LouxorPageState();
}

class _LouxorPageState extends State<LouxorPage> {
  final ScrollController _mainScrollController = ScrollController();

  // Clé corrigée pour le tiroir de favoris arabe
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  static const List<Map<String, dynamic>> _louxorData = [
    {
      "name": "معبد الكرنك",
      "sub_category": "معالم",
      "photo_url": "assets/louxor/k.jpg",
      "description": "أضخم مجمع ديني في العصور القديمة، وهو عبارة عن مدينة حقيقية من المعابد حيث ترك كل جيل من الفراعنة بصمته. صالة الأعمدة الكبرى، بأعمدتها الـ 134 الضخمة، تمثل إعجازاً معمارياً يترك الزائر مذهولاً أمام عظمة إيمان المصريين القدماء."
    },
    {
      "name": "متحف الكرنك المفتوح",
      "sub_category": "معالم",
      "photo_url": "assets/louxor/temple.jpg",
      "description": "يقع داخل مجمع الكرنك، ويضم هذا المتحف عناصر معمارية أعيد تجميعها بعناية، مثل المقصورة البيضاء لسنوسرت الأول. محطة لا غنى عنها لفهم التطور الفني والتقني للبناء الديني المصري."
    },
    {
      "name": "معبد الأقصر",
      "sub_category": "معالم",
      "photo_url": "assets/louxor/l.jpg",
      "description": "يقع في قلب المدينة الحديثة، وكان هذا المعبد مكرساً لتجديد السلطة الملكية. يزداد سحراً عند إضاءته ليلاً، ويتميز بتماثيله الضخمة لرمسيس الثاني ومسلاته المنفردة، وأجوائه الصوفية التي تبدو وكأنها تتحدى الزمن وصخب المدينة المحيطة."
    },
    {
      "name": "مقبرة ملكية",
      "sub_category": "وادي الملوك والملكات",
      "photo_url": "assets/louxor/tombe.jpg",
      "description": "اغمر نفسك في خصوصية الحكام الراحلين. توفر المقابر الملكية رحلة فريدة نحو العالم الآخر، حيث تغطي النصوص المقدسة واللوحات الجدارية ذات الألوان الزاهية كل جدار، لحماية الملك والملكة في رحلتهما الأبدية."
    },
    {
      "name": "وادي الملوك والملكات",
      "sub_category": "وادي الملوك والملكات",
      "photo_url": "assets/louxor/rois.jpg",
      "description": "الموقع الأكثر تميزاً في جبانة طيبة. بين الجبال القاحلة في الضفة الغربية، حفر الفراعنة وزوجاتهم مساكنهم السرية، بعيداً عن الأنظار، لضمان خلود حكمهم في عالم الآلهة."
    },
    {
      "name": "تمثالا ممنون",
      "sub_category": "معالم",
      "photo_url": "assets/louxor/me.jpg",
      "description": "تمثالان ضخمان من الحجر الرملي ينتصبان بكل فخر في السهل. على الرغم من اختفاء المعبد الجنائزي لأمنحتب الثالث الذي كانا جزءاً منه، لا يزال هذان التمثالان حارسين مهيبين وشاهدين على عظمة البناء الإمبراطوري في ذلك العصر."
    },
    {
      "name": "معبد مدينة هابو",
      "sub_category": "معالم",
      "photo_url": "assets/louxor/habu.jpg",
      "description": "معبد جنائزي ذو ثراء استثنائي، حيث تروي النقوش انتصارات رمسيس الثالث ضد شعوب البحر. إنه من الأماكن النادرة التي لا تزال فيها الألوان الأصلية للنقوش مرئية، مما يخلق تبايناً مذهلاً بين صرامة الحجر ودقة التفاصيل الفنية."
    },
    {
      "name": "دير المدينة",
      "sub_category": "وادي الحرفيين",
      "photo_url": "assets/louxor/deir.jpg",
      "description": "قرية الحرفيين الذين نحتوا ورسموا روائع وادي الملوك. يقدم هذا المكان نظرة نادرة ومؤثرة على الحياة اليومية للمصريين القدماء، بعيداً عن الأبهة الملكية، مع منازلهم وورش عملهم ومقابرهم العائلية المزينة."
    },
    {
      "name": "الأقصر بالمنطاد",
      "sub_category": "أنشطة",
      "photo_url": "assets/louxor/m.jpg",
      "description": "تجربة جوية لا تُنسى عند شروق الشمس. حلق فوق النيل والمواقع الأثرية لتدرك عظمة المخطط المعماري لطيبة، بين خضرة الأراضي الخصبة وهدوء الهضاب الصحراوية الشاسع."
    },
    {
      "name": "الأقصر بالقارب",
      "sub_category": "أنشطة",
      "photo_url": "assets/louxor/b.jpg",
      "description": "الإبحار في النيل، شريان الحياة، هو جوهر الأقصر. سواء على متن فلوكة تقليدية أو مركب سياحي، يقدم النيل منظوراً هادئاً ومختلفاً على الضفاف، حيث تستمر الحياة الزراعية في اتباع إيقاع الفصول منذ آلاف السنين."
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
        itemAAjouter['ville'] = 'الأقصر';
        itemAAjouter['region'] = 'المدن التاريخية';
        itemAAjouter['sub_folder'] = 'الأقصر';

        _favorisLieuxJson.add(jsonEncode(itemAAjouter));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "معالم": return Colors.amber;
      case "وادي الملوك والملكات": return Colors.redAccent;
      case "وادي الحرفيين": return Colors.blueAccent;
      case "أنشطة": return Colors.greenAccent;
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
                title: Text("الأقصر", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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