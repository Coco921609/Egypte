import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- CONFIGURATION WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class Plat {
  final String name, sub_category, photo_url, description, ville, recette;
  final List<String> tags;

  Plat({
    required this.name,
    required this.sub_category,
    required this.photo_url,
    required this.description,
    required this.ville,
    required this.recette,
    required this.tags,
  });
}

class GastronomiePage extends StatefulWidget {
  const GastronomiePage({super.key});

  @override
  State<GastronomiePage> createState() => _GastronomiePageState();
}

class _GastronomiePageState extends State<GastronomiePage> {
  final ScrollController _scrollController = ScrollController();
  List<String> _favorisLieuxJson = [];
  final String _cleStockageLieux = 'lieux_favoris_complets_ar';

  final Color _bgDark = const Color(0xFF090A0F);
  final Color _cardDark = const Color(0xFF14151B);
  final Color _accentPink = const Color(0xFFFD79A8);

  final List<Plat> tous_les_plats = [
    Plat(name: "كشري", sub_category: "فن الطهي", photo_url: "assets/plat/k.jpg", ville: "القاهرة", description: "الطبق الوطني القاهري، مزيج من الأرز والعدس والمعكرونة والحمص.", recette: "اخلط الأرز والعدس والمعكرونة والحمص، ثم أضف صلصة الطماطم والبصل المقلي.", tags: ["نباتي", "شعبي", "شارع"]),
    Plat(name: "فول مدمس", sub_category: "فن الطهي", photo_url: "assets/plat/f.jpg", ville: "القاهرة", description: "فول مهروس مطهو ببطء مع التوابل، وجبة الإفطار الوطنية التقليدية.", recette: "اطه الفول ببطء، ثم تبله بزيت الزيتون والثوم والليمون والكمون.", tags: ["إفطار", "تقليدي", "فول"]),
    Plat(name: "طعمية", sub_category: "فن الطهي", photo_url: "assets/plat/t.webp", ville: "القاهرة", description: "فلافل بالفول الطازج والأعشاب، مقرمشة من الخارج.", recette: "اخلط الفول والكزبرة والتوابل، وشكلها أقراصاً ثم اقليها.", tags: ["فلافل", "شارع", "ساندوتش"]),
    Plat(name: "عيش بلدي", sub_category: "فن الطهي", photo_url: "assets/plat/p.jpg", ville: "القاهرة", description: "خبز مصري تقليدي يُخبز في درجات حرارة عالية.", recette: "اعجن دقيق القمح الكامل، وشكله أقراصاً ثم اخبزه في فرن ساخن جداً.", tags: ["خبز", "تقليدي", "أساسي"]),
    Plat(name: "حمام محشي", sub_category: "فن الطهي", photo_url: "assets/plat/g.webp", ville: "الأقصر", description: "حمام محشو بالفريك، وهو قمح أخضر محمص.", recette: "احشُ الحمام بالفريك وقم بتحميره حتى يصبح الجلد ذهبياً.", tags: ["لحوم", "احتفالي", "تخصص"]),
    Plat(name: "كبدة إسكندراني", sub_category: "فن الطهي", photo_url: "assets/plat/2.webp", ville: "الإسكندرية", description: "كبدة بقر متبلة بتوابل قوية، مطهوة على نار عالية.", recette: "تبّل الكبدة، ثم شوّحها على صاج ساخن جداً مع الفلفل.", tags: ["كبدة", "حار", "شارع"]),
    Plat(name: "أم علي", sub_category: "فن الطهي", photo_url: "assets/plat/9.jpg", ville: "القاهرة", description: "بودينغ ساخن برقائق العجين، والحليب، وجوز الهند والفستق.", recette: "اغمس رقائق العجين في الحليب المحلى واخبزها في الفرن مع المكسرات.", tags: ["حلوى", "ساخن", "وطني"]),
    Plat(name: "بسبوسة", sub_category: "فن الطهي", photo_url: "assets/plat/4.jpg", ville: "أسوان", description: "كيكة سميد طرية مشربة بشيرة عطرية.", recette: "اخبز السميد في الفرن واسقه بالشيرة المنكهة بماء الزهر.", tags: ["حلوى", "سميد", "مسكر"]),
    Plat(name: "كنافة", sub_category: "فن الطهي", photo_url: "assets/plat/2.jpg", ville: "القاهرة", description: "شعيرية مقرمشة بالزبدة، محشوة بالقشطة أو الجبن.", recette: "حمّص الشعيرية، احشها بالقشطة واسقها بالشيرة العطرية.", tags: ["حلوى", "مقرمش", "جبن"]),
  ];

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorisLieuxJson = prefs.getStringList(_cleStockageLieux) ?? [];
    });
  }

  Future<void> _toggleFavori(Plat plat) async {
    final prefs = await SharedPreferences.getInstance();
    bool existe = false;
    int indexTrouve = -1;

    for (int i = 0; i < _favorisLieuxJson.length; i++) {
      try {
        final map = jsonDecode(_favorisLieuxJson[i]);
        if (map['name'] == plat.name) {
          existe = true;
          indexTrouve = i;
          break;
        }
      } catch (e) {}
    }

    setState(() {
      if (existe) {
        _favorisLieuxJson.removeAt(indexTrouve);
      } else {
        final Map<String, dynamic> platMap = {
          'name': plat.name,
          'sub_category': "فن الطهي",
          'photo_url': plat.photo_url,
          'description': plat.description,
          'ville': plat.ville,
          'recette': plat.recette,
          'region': "معلومات عملية",
          'sub_folder': "Gastronomie",
        };
        _favorisLieuxJson.add(jsonEncode(platMap));
      }
    });
    await prefs.setStringList(_cleStockageLieux, _favorisLieuxJson);
  }

  bool _isFavori(String name) {
    for (var jsonStr in _favorisLieuxJson) {
      try {
        if (jsonDecode(jsonStr)['name'] == name) return true;
      } catch (e) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _bgDark,
          body: ScrollConfiguration(
            behavior: WebScrollBehavior(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: false,
                  stretch: true,
                  backgroundColor: _bgDark.withOpacity(0.9),
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cardDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                  title: Text(
                    "فن الطهي المصري",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _build_plat_card(tous_les_plats[index]),
                      childCount: tous_les_plats.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _build_plat_card(Plat plat) {
    final bool isFav = _isFavori(plat.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentPink.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 16, offset: const Offset(0, 8)),
          BoxShadow(color: _accentPink.withOpacity(0.22), blurRadius: 12, spreadRadius: -2, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(plat.photo_url, height: 200, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _accentPink.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, color: _accentPink, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          plat.ville,
                          style: GoogleFonts.cairo(
                            color: _accentPink,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plat.name,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavori(plat),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFav ? Colors.redAccent.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.white38,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(plat.description, style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("طريقة التحضير", style: GoogleFonts.cairo(color: _accentPink, fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 8),
                        Text(plat.recette, style: GoogleFonts.cairo(color: Colors.white60, fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: plat.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                      child: Text(tag, style: GoogleFonts.cairo(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}