import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CONFIGURATION WEB ET DÉFILEMENT ---
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

class HieroglyphicsPage extends StatefulWidget {
  const HieroglyphicsPage({super.key});

  @override
  State<HieroglyphicsPage> createState() => _HieroglyphicsPageState();
}

class _HieroglyphicsPageState extends State<HieroglyphicsPage> {
  final ScrollController _scrollController = ScrollController();
  String _lang = 'fr';

  // Palette de couleurs Premium
  final Color _bgDark = const Color(0xFF090A0F);
  final Color _cardDark = const Color(0xFF14151B);
  final Color _accentGold = const Color(0xFFDFB15B);

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Hiéroglyphes égyptiens',
      'uniliteral': 'Signes unilitères (Alphabet de A à Z)',
      'biliteral': 'Symboles sacrés & Cartouches',
      'phonetic': 'Phonétique',
      'code': 'Gardiner',
    },
    'en': {
      'pageTitle': 'Egyptian Hieroglyphics',
      'uniliteral': 'Uniliteral Signs (Alphabet A to Z)',
      'biliteral': 'Sacred Symbols & Cartouches',
      'phonetic': 'Phonetic',
      'code': 'Gardiner',
    },
    'ar': {
      'pageTitle': 'الهيروغليفية المصرية',
      'uniliteral': 'علامات أحادية الحرف (الأبجدية من أ إلى ي)',
      'biliteral': 'الرموز المقدسة والخراطيش',
      'phonetic': 'الصوتي',
      'code': 'جاردنر',
    },
  };

  // --- DONNÉES COMPLÈTES DE A À Z ---
  final List<Map<String, dynamic>> _data = [
    {
      "categoryKey": "uniliteral",
      "items": [
        {
          "glyph": "𓄿",
          "code": "G1",
          "phonetic": "A / Ꜣ",
          "name": { "fr": "vautour d'égypte", "en": "egyptian vulture", "ar": "نسر مصري" },
          "desc": { "fr": "son a", "en": "a sound", "ar": "صوت أ" }
        },
        {
          "glyph": "𓂝",
          "code": "D36",
          "phonetic": "A (ʿ)",
          "name": { "fr": "avant-bras", "en": "forearm", "ar": "ذراع" },
          "desc": { "fr": "son ʿayin", "en": "ʿayin sound", "ar": "صوت ع" }
        },
        {
          "glyph": "𓃀",
          "code": "D58",
          "phonetic": "B",
          "name": { "fr": "jambe et pied", "en": "foot and leg", "ar": "قدم وساق" },
          "desc": { "fr": "son b", "en": "b sound", "ar": "صوت ب" }
        },
        {
          "glyph": "𓆓",
          "code": "I10",
          "phonetic": "DJ (ḏ)",
          "name": { "fr": "cobra", "en": "cobra", "ar": "كوبرا" },
          "desc": { "fr": "son dj", "en": "dj sound", "ar": "صوت ج" }
        },
        {
          "glyph": "𓂧",
          "code": "D46",
          "phonetic": "D",
          "name": { "fr": "main", "en": "hand", "ar": "يد" },
          "desc": { "fr": "son d", "en": "d sound", "ar": "صوت د" }
        },
        {
          "glyph": "𓆑",
          "code": "I9",
          "phonetic": "F",
          "name": { "fr": "vipère cornue", "en": "horned viper", "ar": "أفعى قرناء" },
          "desc": { "fr": "son f", "en": "f sound", "ar": "صوت ف" }
        },
        {
          "glyph": "𓎼",
          "code": "W11",
          "phonetic": "G",
          "name": { "fr": "jarre en osier", "en": "jar stand", "ar": "حامل جرة" },
          "desc": { "fr": "son g", "en": "g sound", "ar": "صوت ج قاسية" }
        },
        {
          "glyph": "𓉔",
          "code": "O4",
          "phonetic": "H",
          "name": { "fr": "abri en roseau", "en": "reed shelter", "ar": "مأوى من القصب" },
          "desc": { "fr": "son h", "en": "h sound", "ar": "صوت ه" }
        },
        {
          "glyph": "𓲤",
          "code": "V28",
          "phonetic": "H (ḥ)",
          "name": { "fr": "mèche de lin", "en": "twisted flax", "ar": "فتيل كتان" },
          "desc": { "fr": "son ḥ", "en": "ḥ sound", "ar": "صوت ح" }
        },
        {
          "glyph": "𓺈",
          "code": "F32",
          "phonetic": "KH (ḫ)",
          "name": { "fr": "ventre", "en": "belly", "ar": "بطن ومشيمة" },
          "desc": { "fr": "son ḫ", "en": "ḫ sound", "ar": "صوت خ" }
        },
        {
          "glyph": "𓄡",
          "code": "F21",
          "phonetic": "KH (ẖ)",
          "name": { "fr": "arrière-train", "en": "hindquarters", "ar": "جزء خلفي" },
          "desc": { "fr": "son ẖ", "en": "ẖ sound", "ar": "صوت خ عميقة" }
        },
        {
          "glyph": "𓇋",
          "code": "M17",
          "phonetic": "I",
          "name": { "fr": "roseau fleuri", "en": "flowering reed", "ar": "قصبة مزهرة" },
          "desc": { "fr": "son i", "en": "i sound", "ar": "صوت ي" }
        },
        {
          "glyph": "𓂓",
          "code": "D28",
          "phonetic": "K",
          "name": { "fr": "bras tendus", "en": "arms raised", "ar": "ذراعان مرفوعتان" },
          "desc": { "fr": "son k", "en": "k sound", "ar": "صوت ك" }
        },
        {
          "glyph": "𓅓",
          "code": "G17",
          "phonetic": "M",
          "name": { "fr": "chouette", "en": "owl", "ar": "بومة" },
          "desc": { "fr": "son m", "en": "m sound", "ar": "صوت م" }
        },
        {
          "glyph": "𓈖",
          "code": "N35",
          "phonetic": "N",
          "name": { "fr": "eau ridée", "en": "water ripple", "ar": "تموج الماء" },
          "desc": { "fr": "son n", "en": "n sound", "ar": "صوت ن" }
        },
        {
          "glyph": "𓊪",
          "code": "Q3",
          "phonetic": "P",
          "name": { "fr": "siège en natte", "en": "reed stool", "ar": "مقعد من القصب" },
          "desc": { "fr": "son p", "en": "p sound", "ar": "صوت ب ثقيلة" }
        },
        {
          "glyph": "𓈎",
          "code": "N29",
          "phonetic": "Q",
          "name": { "fr": "versant colline", "en": "hill slope", "ar": "منحدر تلال" },
          "desc": { "fr": "son q", "en": "q sound", "ar": "صوت ق" }
        },
        {
          "glyph": "𓂋",
          "code": "D21",
          "phonetic": "R",
          "name": { "fr": "bouche humaine", "en": "human mouth", "ar": "فم إنساني" },
          "desc": { "fr": "son r", "en": "r sound", "ar": "صوت ر" }
        },
        {
          "glyph": "𓋴",
          "code": "S29",
          "phonetic": "S",
          "name": { "fr": "verrou de porte", "en": "door bolt", "ar": "مزلاج باب" },
          "desc": { "fr": "son s", "en": "s sound", "ar": "صوت س" }
        },
        {
          "glyph": "𓈛",
          "code": "N37",
          "phonetic": "SH (š)",
          "name": { "fr": "bassin d'eau", "en": "pool of water", "ar": "بركة ماء" },
          "desc": { "fr": "son š", "en": "š sound", "ar": "صوت ش" }
        },
        {
          "glyph": "𓏏",
          "code": "X1",
          "phonetic": "T",
          "name": { "fr": "pain rond", "en": "loaf of bread", "ar": "رغيف خبز" },
          "desc": { "fr": "son t", "en": "t sound", "ar": "صوت ت" }
        },
        {
          "glyph": "𓍿",
          "code": "V13",
          "phonetic": "TJ (ṯ)",
          "name": { "fr": "lien de cordage", "en": "tethering rope", "ar": "حبل الربط" },
          "desc": { "fr": "son ṯ", "en": "ṯ sound", "ar": "صوت تش" }
        },
        {
          "glyph": "𓅱",
          "code": "G43",
          "phonetic": "W",
          "name": { "fr": "poussin caille", "en": "quail chick", "ar": "فرخ السمان" },
          "desc": { "fr": "son w", "en": "w sound", "ar": "صوت و" }
        },
        {
          "glyph": "𓏭",
          "code": "Z4",
          "phonetic": "Y",
          "name": { "fr": "deux traits", "en": "double strokes", "ar": "خطان مائلان" },
          "desc": { "fr": "son y", "en": "y sound", "ar": "صوت ياء مزدوجة" }
        }
      ]
    },
    {
      "categoryKey": "biliteral",
      "items": [
        {
          "glyph": "𓋹",
          "code": "S34",
          "phonetic": "Ankh",
          "name": {
            "fr": "clé de vie",
            "en": "key of life",
            "ar": "مفتاح الحياة"
          },
          "desc": {
            "fr": "symbole sacré de la vie éternelle.",
            "en": "sacred symbol of eternal life.",
            "ar": "رمز مقدس للحياة الأبدية."
          }
        },
        {
          "glyph": "𓇳",
          "code": "N5",
          "phonetic": "Ra",
          "name": {
            "fr": "disque solaire",
            "en": "sun disc",
            "ar": "قرص الشمس"
          },
          "desc": {
            "fr": "représente le dieu soleil ra.",
            "en": "represents the sun god ra.",
            "ar": "يمثل إله الشمس رع."
          }
        },
        {
          "glyph": "𓁹",
          "code": "D4",
          "phonetic": "Oudjat",
          "name": {
            "fr": "œil d'horus",
            "en": "eye of horus",
            "ar": "عين حورس"
          },
          "desc": {
            "fr": "symbole de protection et guérison.",
            "en": "symbol of protection and healing.",
            "ar": "رمز الحماية والشفاء."
          }
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _chargerLangue();
  }

  Future<void> _chargerLangue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langSauvegardee = prefs.getString('selected_language');
    if (langSauvegardee != null && _uiTranslations.containsKey(langSauvegardee)) {
      setState(() {
        _lang = langSauvegardee;
      });
    }
  }

  Future<void> _changerLangue(String nouvelleLangue) async {
    if (_lang == nouvelleLangue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', nouvelleLangue);
    setState(() {
      _lang = nouvelleLangue;
    });
  }

  String _getTranslatedText(String key) {
    return _uiTranslations[_lang]?[key] ?? _uiTranslations['fr']![key] ?? key;
  }

  Widget _buildLangButton(String label, String langCode) {
    final bool isSelected = _lang == langCode;
    return GestureDetector(
      onTap: () => _changerLangue(langCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? _accentGold : _cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _accentGold : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = _lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bgDark,
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- BARRE DE NAVIGATION (TITRE ESPACÉ) ---
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor: _bgDark.withOpacity(0.9),
                elevation: 0,
                toolbarHeight: 70,
                leadingWidth: 50,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
                titleSpacing: 8,
                title: Text(
                  _getTranslatedText('pageTitle').toLowerCase(),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangButton('FR', 'fr'),
                        _buildLangButton('EN', 'en'),
                        _buildLangButton('AR', 'ar'),
                      ],
                    ),
                  ),
                ],
              ),

              // --- CONTENU PRINCIPAL ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildCategorySection(_data[index]),
                    childCount: _data.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> categoryData) {
    final String categoryKey = categoryData["categoryKey"];
    final String categoryTitle = _getTranslatedText(categoryKey);
    final List<dynamic> items = categoryData["items"];
    final bool isUniliteral = categoryKey == "uniliteral";

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
            child: Text(
              categoryTitle.toLowerCase(),
              style: GoogleFonts.montserrat(
                color: _accentGold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          if (isUniliteral)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _buildGlyphCardGrid(items[index]),
            )
          else
            ...items.map((item) => _buildGlyphCardFull(item)),
        ],
      ),
    );
  }

  Widget _buildGlyphCardGrid(Map<String, dynamic> item) {
    final String glyph = item["glyph"];
    final String code = item["code"];
    final String phonetic = item["phonetic"];
    final String name = item["name"][_lang] ?? item["name"]["fr"]!;

    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentGold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accentGold.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                glyph,
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            phonetic,
            style: GoogleFonts.montserrat(
              color: _accentGold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            code,
            style: GoogleFonts.montserrat(
              color: Colors.white54,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlyphCardFull(Map<String, dynamic> item) {
    final String glyph = item["glyph"];
    final String code = item["code"];
    final String phonetic = item["phonetic"];
    final String name = item["name"][_lang] ?? item["name"]["fr"]!;
    final String desc = item["desc"][_lang] ?? item["desc"]["fr"]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentGold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _accentGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accentGold.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      glyph,
                      style: const TextStyle(color: Colors.white, fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${_getTranslatedText('code')}: $code",
                          style: GoogleFonts.montserrat(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  "${_getTranslatedText('phonetic')}: ",
                  style: GoogleFonts.montserrat(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  phonetic,
                  style: GoogleFonts.montserrat(
                    color: _accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}