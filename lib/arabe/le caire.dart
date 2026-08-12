import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

// --- 1. CLASSE DE DÉFILEMENT WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

// --- 2. PAGE PRINCIPALE (LE CAIRE - VERSION ARABE) ---
class LeCairePage extends StatefulWidget {
  const LeCairePage({super.key});

  @override
  State<LeCairePage> createState() => _LeCairePageState();
}

class _LeCairePageState extends State<LeCairePage> {
  final ScrollController _mainScrollController = ScrollController();

  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  static const List<Map<String, dynamic>> _leCaireData = [
    {
      "name": "برج القاهرة",
      "sub_category": "أنشطة في القاهرة",
      "photo_url": "assets/caire/tour.jpg",
      "description": "يبلغ ارتفاع برج القاهرة 187 متراً، وهو رمز حديث للمدينة بمثابة برج إيفل النسخة المصرية. صُمم من الخرسانة المسلحة على شكل زهرة اللوتس الشهيرة، ويضم منصة مراقبة توفر إطلالة بانورامية بزاوية 360 درجة. إنه المكان المثالي لتأمل اتساع العاصمة، وتعرجات نهر النيل، ورؤية أهرامات الجيزة في الأفق عندما يكون الطقس صافياً."
    },
    {
      "name": "أهرامات الجيزة",
      "sub_category": "معالم أثرية",
      "photo_url": "assets/caire/pyramide.jpg",
      "description": "الأثر الوحيد الباقي من عجائب الدنيا السبع القديمة، تعد أهرامات خوفو وخفرع ومنقرع الرمز المطلق لمصر. هذا الموقع الأثري المهيب، الذي يحرسه أبو الهول الشامخ، يشهد على العبقرية المعمارية والمكانة الدينية لفراعنة الدولة القديمة. استكشاف هذه الهضبة هو بمثابة رحلة عبر تاريخ البشرية الممتد لآلاف السنين في قلب صحراء حفظت هذه الكنوز للأبد."
    },
    {
      "name": "قلعة صلاح الدين",
      "sub_category": "معالم أثرية",
      "photo_url": "assets/caire/saladin.jpg",
      "description": "تهيمن هذه القلعة العصور الوسطى، التي بناها صلاح الدين الأيوبي في القرن الثاني عشر، على المدينة من فوق تلال المقطم، وتعد جوهرة العمارة الإسلامية. تضم القلعة مسجد محمد علي الشهير (مسجد الألباستر) بمآذنه الرشيقة الشاهقة المرئية من أي مكان في القاهرة. لا توفر حصونها لمحة تاريخية عن دفاعات العصور الوسطى فحسب، بل تمنحك أيضاً واحدة من أجمل الإطلالات البانورامية على المدينة."
    },
    {
      "name": "الحي القبطي",
      "sub_category": "أماكن تاريخية",
      "photo_url": "assets/caire/copte.jpg",
      "description": "يخفي حي القاهرة القديمة في طياته الحي القبطي، وهو ملاذ حقيقي للروحانية. ستجد هنا الكنيسة المعلقة المبنية فوق بوابات حصن بابليون الروماني، بالإضافة إلى معبد بن عزرا اليهودي وكنيسة أبي سرجة (مار جرجس)، حيث لجأت العائلة المقدسة وفقاً للروايات التاريخية أثناء هروبها إلى مصر. إنه مكان هادئ مليء بالتاريخ وبعيد عن صخب المدينة."
    },
    {
      "name": "المتحف المصري الكبير",
      "sub_category": "أماكن تاريخية",
      "photo_url": "assets/caire/musee.jpg",
      "description": "واحد من أكبر المتاحف في العالم المخصصة لحضارة واحدة. تحفة معمارية حديثة تحتضن كنوزاً لا تقدر بثمن من التاريخ المصري العريق، ويتميز بموقعه القريب جداً من أهرامات الجيزة."
    },
    {
      "name": "خان الخليلي",
      "sub_category": "أسواق تقليدية",
      "photo_url": "assets/caire/khan.jpg",
      "description": "انغمس في حيوية أشهر سوق تقليدي في القاهرة. يمتد هذا المتاه من الأزقة الضيقة لأكثر من 600 عام، وهو مليء بورش الحرفيين، ومحلات التوابل، والعطور، والنحاسيات، والمجوهرات اليدوية. إنها رحلة حسية مذهلة حيث تمتزج نداءات الباعة مع رائحة القهوة بالهيل وصوت طرق المعادن لتخلق أجواء فريدة من نوعها مثالية للاندماج التام في الثقافة القاهرية."
    },
    {
      "name": "سوق الفسطاط",
      "sub_category": "أسواق تقليدية",
      "photo_url": "assets/caire/fustat.jpg",
      "description": "يقع سوق الفسطاط بالقرب من المتحف القومي للحضارة المصرية، وهو جنة الحرف اليدوية التقليدية والمعاصرة. يتميز هذا السوق بكونه أقل صخباً من خان الخليلي، ويسلط الضوء على جودة العمل اليدوي المصري، وخاصة الفخار والمنسوجات والزجاج المنفوخ."
    },
    {
      "name": "قصر البارون إمبان",
      "sub_category": "عمارة",
      "photo_url": "assets/caire/baron.jpg",
      "description": "قصر مذهل ومبتكر مستوحى من العمارة الهندوسية يقع في منطقة مصر الجديدة. هندسته الفريدة وتاريخه المليء بالغموض يمتزجان ليجعلاه معلماً لا غنى عن زيارته في القاهرة الحديثة."
    },
    {
      "name": "حديقة الأزهر",
      "sub_category": "أماكن استرخاء",
      "photo_url": "assets/caire/al.jpg",
      "description": "واحة خضراء من الهدوء توفر إطلالة ساحرة على القلعة ومناطق القاهرة القديمة. مكان مثالي للتنزه المريح والاسترخاء بعيداً عن ضوضاء وازدحام المدينة."
    },
    {
      "name": "نهر النيل",
      "sub_category": "أماكن تاريخية",
      "photo_url": "assets/caire/nil.jpg",
      "description": "شريان الحياة لمصر منذ العصور القديمة، ونهر النيل هو القلب النابض للقاهرة. هذا النهر الأسطوري سمح بنمو وازدهار الحضارة الفرعونية، ولا يزال يقدم اليوم جولات لا تُنسى بالفلوكة الشراعية عند غروب الشمس."
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
        _favorisLieuxJson.add(jsonEncode(item));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  Future<void> _ouvrirGoogleMaps(String nomLieu) async {
    final String query = Uri.encodeComponent('$nomLieu، القاهرة، مصر');
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Impossible d\'ouvrir la carte pour : $nomLieu -> $e');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "معالم أثرية": return Colors.amber;
      case "أسواق تقليدية": return Colors.redAccent;
      case "أماكن تاريخية": return Colors.blueAccent;
      case "عمارة": return Colors.purpleAccent;
      case "أماكن استرخاء": return Colors.greenAccent;
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: CustomScrollView(
            controller: _mainScrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: false,
                backgroundColor: const Color(0xFF101010),
                title: const Text("القاهرة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                iconTheme: const IconThemeData(color: Colors.white),
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