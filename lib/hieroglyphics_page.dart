import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'egypt_design.dart';
import 'egypt_language.dart';

class HieroglyphicsPage extends StatefulWidget {
  const HieroglyphicsPage({super.key});

  @override
  State<HieroglyphicsPage> createState() => _HieroglyphicsPageState();
}

class _HieroglyphicsPageState extends State<HieroglyphicsPage> {
  String _lang = 'fr';

  static const Color _gold = Color(0xFFDFB15B);
  static const Color _teal = Color(0xFF0F766E);

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Hiéroglyphes égyptiens',
      'subtitle': "Déchiffrez l'écriture sacrée des pharaons.",
      'uniliteral': 'Signes unilitères (Alphabet de A à Z)',
      'biliteral': 'Symboles sacrés & Cartouches',
      'phonetic': 'Phonétique',
      'code': 'Gardiner',
    },
    'en': {
      'pageTitle': 'Egyptian Hieroglyphics',
      'subtitle': 'Decode the sacred writing of the pharaohs.',
      'uniliteral': 'Uniliteral Signs (Alphabet A to Z)',
      'biliteral': 'Sacred Symbols & Cartouches',
      'phonetic': 'Phonetic',
      'code': 'Gardiner',
    },
    'ar': {
      'pageTitle': 'الهيروغليفية المصرية',
      'subtitle': 'افكّ شفرة الكتابة المقدسة للفراعنة.',
      'uniliteral': 'علامات أحادية الحرف (الأبجدية من أ إلى ي)',
      'biliteral': 'الرموز المقدسة والخراطيش',
      'phonetic': 'الصوتي',
      'code': 'جاردنر',
    },
  };

  // --- DONNÉES COMPLÈTES DE A À Z (inchangées) ---
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
    EgyptLanguage.language.addListener(_onLanguageChanged);
    EgyptLanguage.initialize();
  }

  void _onLanguageChanged() {
    final String nouvelle = EgyptLanguage.language.value;
    if (mounted && _lang != nouvelle) {
      setState(() => _lang = nouvelle);
    }
  }

  Future<void> _changerLangue(String nouvelle) async {
    if (_lang == nouvelle) return;
    await EgyptLanguage.setLanguage(nouvelle);
  }

  @override
  void dispose() {
    EgyptLanguage.language.removeListener(_onLanguageChanged);
    super.dispose();
  }

  String _t(String key) => _uiTranslations[_lang]?[key] ?? _uiTranslations['fr']![key] ?? key;

  /// Texte localisé d'une entrée de données (name / desc).
  String _loc(Map m) => (m[_lang] ?? m['fr']) as String;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = _lang == 'ar';
    final double topPad = MediaQuery.of(context).padding.top;

    final List<Widget> slivers = <Widget>[
      SliverToBoxAdapter(child: _buildHeader(topPad, isRtl)),
    ];

    for (int s = 0; s < _data.length; s++) {
      final Map<String, dynamic> cat = _data[s];
      final String key = cat['categoryKey'] as String;
      final List<dynamic> items = cat['items'] as List<dynamic>;
      final bool isUniliteral = key == 'uniliteral';

      slivers.add(SliverToBoxAdapter(
        child: EgyptSectionLabel(
          index: (s + 1).toString().padLeft(2, '0'),
          title: _t(key),
          accent: _gold,
        ),
      ));

      if (isUniliteral) {
        slivers.add(SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.56,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, i) => _glyphTile(items[i] as Map<String, dynamic>),
              childCount: items.length,
            ),
          ),
        ));
      } else {
        slivers.add(SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _cartoucheCard(items[i] as Map<String, dynamic>),
              ),
              childCount: items.length,
            ),
          ),
        ));
      }

      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 40)));
    }

    slivers.add(SliverToBoxAdapter(child: _buildFooter()));

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: EgyptPalette.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: EgyptAurora(
                colors: [_gold, _teal, EgyptPalette.violet, EgyptPalette.terracotta],
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: slivers,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── En-tête ─────────────────────────

  Widget _buildHeader(double topPad, bool isRtl) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, topPad + 12, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EgyptBackButton(isRtl: isRtl, onTap: () => Navigator.pop(context)),
              const Spacer(),
              EgyptLangSwitch(current: _lang, accent: _gold, onChanged: _changerLangue),
            ],
          ),
          const SizedBox(height: 40),
          EgyptReveal(
            child: Text(
              _t('pageTitle'),
              style: GoogleFonts.playfairDisplay(
                color: EgyptPalette.sand,
                fontSize: 46,
                height: 1.04,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          EgyptReveal(
            delay: 120,
            child: Text(
              _t('subtitle'),
              style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 14, height: 1.6),
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }

  // ───────────────────────── Signes unilitères : tuile en verre ─────────────────────────

  Widget _glyphTile(Map<String, dynamic> item) {
    final String glyph = item['glyph'] as String;
    final String code = item['code'] as String;
    final String phonetic = item['phonetic'] as String;
    final String name = _loc(item['name'] as Map);

    return EgyptGlass(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_gold.withOpacity(0.22), _gold.withOpacity(0.04)],
              ),
              border: Border.all(color: _gold.withOpacity(0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              glyph,
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: EgyptPalette.sand,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            phonetic,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: _gold, fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${_t('code')} $code',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Symboles : cartouche en verre ─────────────────────────

  Widget _cartoucheCard(Map<String, dynamic> item) {
    final String glyph = item['glyph'] as String;
    final String code = item['code'] as String;
    final String phonetic = item['phonetic'] as String;
    final String name = _loc(item['name'] as Map);
    final String desc = _loc(item['desc'] as Map);

    return EgyptGlass(
      radius: 34,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartouche : cadre ovale qui enferme le signe
          Container(
            width: 98,
            height: 128,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(49),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gold.withOpacity(0.2), _gold.withOpacity(0.03)],
              ),
              border: Border.all(color: _gold.withOpacity(0.55), width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(
              glyph,
              style: const TextStyle(color: Colors.white, fontSize: 56),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    color: EgyptPalette.sand,
                    fontSize: 24,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_t('code')}: $code',
                    style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 10.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${_t('phonetic')}: ',
                        style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: phonetic,
                        style: GoogleFonts.montserrat(color: _gold, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 13, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Pied de page ─────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 60),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, _gold, Colors.transparent]),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'ÉGYPTE',
            style: GoogleFonts.cinzel(color: EgyptPalette.sand, fontSize: 14, letterSpacing: 5),
          ),
        ],
      ),
    );
  }
}