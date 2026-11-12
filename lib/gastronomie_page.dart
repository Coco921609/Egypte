import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'egypt_design.dart';

class Plat {
  final String id;
  final String photo_url;
  final Map<String, String> name;
  final Map<String, String> ville;
  final Map<String, String> description;
  final Map<String, String> recette;
  final Map<String, List<String>> tags;

  Plat({
    required this.id,
    required this.photo_url,
    required this.name,
    required this.ville,
    required this.description,
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
  String _lang = 'fr';

  static const Color _accent = Color(0xFFFD79A8);
  static const Color _gold = Color(0xFFF59E0B);

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Gastronomie égyptienne',
      'subtitle': 'Les saveurs de la vallée du Nil, de Louxor au Caire.',
      'recipeTitle': 'Recette traditionnelle',
      'dishes': 'plats',
    },
    'en': {
      'pageTitle': 'Egyptian Gastronomy',
      'subtitle': 'The flavours of the Nile valley, from Luxor to Cairo.',
      'recipeTitle': 'Traditional recipe',
      'dishes': 'dishes',
    },
    'ar': {
      'pageTitle': 'المأكولات المصرية',
      'subtitle': 'نكهات وادي النيل، من الأقصر إلى القاهرة.',
      'recipeTitle': 'وصفة تقليدية',
      'dishes': 'أطباق',
    },
  };

  // --- DONNÉES DES PLATS (inchangées) ---
  final List<Plat> tous_les_plats = [
    Plat(
      id: "koshari",
      photo_url: "assets/plat/k.jpg",
      name: {
        'fr': "Koshari",
        'en': "Koshari",
        'ar': "كشري",
      },
      ville: {
        'fr': "Le Caire",
        'en': "Cairo",
        'ar': "القاهرة",
      },
      description: {
        'fr': "Le plat national cairote, mélange de riz, lentilles, macaronis et pois chiches.",
        'en': "Cairo's national dish, a mix of rice, lentils, macaroni, and chickpeas.",
        'ar': "الطبق الوطني القاهري، مزيج من الأرز والعدس والمعكرونة والحمص.",
      },
      recette: {
        'fr': "Mélangez riz, lentilles, macaronis et pois chiches, puis nappez de sauce tomate et oignons frits.",
        'en': "Mix rice, lentils, macaroni, and chickpeas, then top with tomato sauce and fried onions.",
        'ar': "اخلط الأرز والعدس والمعكرونة والحمص، ثم غطِّ المزيج بصلصة الطماطم والبصل المقرمش.",
      },
      tags: {
        'fr': ["Végétarien", "Populaire", "Rue"],
        'en': ["Vegetarian", "Popular", "Street food"],
        'ar': ["نباتي", "شعبي", "طعام الشارع"],
      },
    ),
    Plat(
      id: "ful_medames",
      photo_url: "assets/plat/f.jpg",
      name: {
        'fr': "Ful medames",
        'en': "Ful Medames",
        'ar': "فول مدمس",
      },
      ville: {
        'fr': "Le Caire",
        'en': "Cairo",
        'ar': "القاهرة",
      },
      description: {
        'fr': "Purée de fèves mijotées aux épices, petit-déjeuner national traditionnel.",
        'en': "Slow-cooked fava bean mash with spices, a traditional national breakfast.",
        'ar': "مهروس الفول المطهو بطريقة هادئة مع التوابل، الإفطار الوطني التقليدي.",
      },
      recette: {
        'fr': "Mijotez les fèves, puis assaisonnez avec huile d'olive, ail, citron et cumin.",
        'en': "Simmer the fava beans, then season with olive oil, garlic, lemon, and cumin.",
        'ar': "اطهِ الفول على نار هادئة، ثم تبل بزيت الزيتون والثوم والليمون والكمون.",
      },
      tags: {
        'fr': ["Petit-déjeuner", "Traditionnel", "Fèves"],
        'en': ["Breakfast", "Traditional", "Fava beans"],
        'ar': ["إفطار", "تقليدي", "فول"],
      },
    ),
    Plat(
      id: "taameya",
      photo_url: "assets/plat/t.webp",
      name: {
        'fr': "Taameya",
        'en': "Taameya",
        'ar': "طعمية",
      },
      ville: {
        'fr': "Le Caire",
        'en': "Cairo",
        'ar': "القاهرة",
      },
      description: {
        'fr': "Falafels aux fèves fraîches et herbes, croustillants à l'extérieur.",
        'en': "Egyptian falafel made with fresh fava beans and herbs, crispy on the outside.",
        'ar': "فلافل بمهروس الفول والأعشاب الطازجة، مقرمشة من الخارج.",
      },
      recette: {
        'fr': "Mixez fèves, coriandre et épices, formez des galettes et faites frire.",
        'en': "Blend fava beans, coriander, and spices, shape into patties, and deep fry.",
        'ar': "اخلط الفول والكزبرة والتوابل، شكل أقراصاً واقلها في الزيت.",
      },
      tags: {
        'fr': ["Falafel", "Rue", "Sandwich"],
        'en': ["Falafel", "Street food", "Sandwich"],
        'ar': ["فلافل", "طعام الشارع", "سندويش"],
      },
    ),
    Plat(
      id: "pain_baladi",
      photo_url: "assets/plat/p.jpg",
      name: {
        'fr': "Pain baladi",
        'en': "Baladi Bread",
        'ar': "عيش بلدي",
      },
      ville: {
        'fr': "Le Caire",
        'en': "Cairo",
        'ar': "القاهرة",
      },
      description: {
        'fr': "Pain traditionnel égyptien cuit à haute température.",
        'en': "Traditional Egyptian flatbread baked at very high temperatures.",
        'ar': "الخبز المصري التقليدي المخبوز في درجات حرارة عالية.",
      },
      recette: {
        'fr': "Pétrissez la farine complète, façonnez des disques et cuisez au four très chaud.",
        'en': "Knead whole wheat flour, shape into discs, and bake in an extremely hot oven.",
        'ar': "اعجن الدقيق الكامل، شكل أقراصاً واخبزها في فرن شديد الحرارة.",
      },
      tags: {
        'fr': ["Pain", "Traditionnel", "Incontournable"],
        'en': ["Bread", "Traditional", "Essential"],
        'ar': ["خبز", "تقليدي", "أساسي"],
      },
    ),
    Plat(
      id: "pigeon_grille",
      photo_url: "assets/plat/g.webp",
      name: {
        'fr': "Pigeon grillé",
        'en': "Stuffed Pigeon",
        'ar': "حمام محشي",
      },
      ville: {
        'fr': "Louxor",
        'en': "Luxor",
        'ar': "الأقصر",
      },
      description: {
        'fr': "Pigeon farci au freekeh, un blé vert torréfié.",
        'en': "Stuffed pigeon with freekeh, a roasted green wheat.",
        'ar': "حمام محشو بالفريك، وهو قمح أخضر محمّص.",
      },
      recette: {
        'fr': "Farcissez le pigeon de freekeh et rôtissez jusqu'à obtenir une peau dorée.",
        'en': "Stuff the pigeon with freekeh and roast until the skin turns golden brown.",
        'ar': "احشُ الحمام بالفريك واشوهِ حتى يكتسب الجلد لوناً ذهبياً.",
      },
      tags: {
        'fr': ["Viande", "Festif", "Spécialité"],
        'en': ["Meat", "Festive", "Specialty"],
        'ar': ["لحوم", "احتفالي", "خاصية"],
      },
    ),
    Plat(
      id: "kebda",
      photo_url: "assets/plat/2.webp",
      name: {
        'fr': "Kebda",
        'en': "Alexandrian Kebda",
        'ar': "كبدة اسكندراني",
      },
      ville: {
        'fr': "Alexandrie",
        'en': "Alexandria",
        'ar': "الإسكندرية",
      },
      description: {
        'fr': "Foie de bœuf mariné aux épices intenses, saisi à feu vif.",
        'en': "Beef liver marinated with intense spices, seared over high heat.",
        'ar': "كبدة بقر متبلة بتوابل قوية، ومطهوة على نار عالية.",
      },
      recette: {
        'fr': "Marinez le foie, puis saisissez sur une plancha brûlante avec du piment.",
        'en': "Marinate the liver, then sear on a hot griddle with chili peppers.",
        'ar': "تبل الكبدة ثم شوّحها على جريل ساخن مع الفلفل الحار.",
      },
      tags: {
        'fr': ["Foie", "Épicé", "Rue"],
        'en': ["Liver", "Spicy", "Street food"],
        'ar': ["كبدة", "حار", "طعام الشارع"],
      },
    ),
    Plat(
      id: "om_ali",
      photo_url: "assets/plat/9.jpg",
      name: {
        'fr': "Om ali",
        'en': "Om Ali",
        'ar': "أم علي",
      },
      ville: {
        'fr': "Le Caire",
        'en': "Cairo",
        'ar': "القاهرة",
      },
      description: {
        'fr': "Pudding chaud au feuilletage, lait, noix de coco et pistaches.",
        'en': "Warm pastry pudding with sweet milk, coconut, and pistachios.",
        'ar': "حلوى المخبوزات الدافئة مع الحليب المحلى والمكسرات وجوز الهند.",
      },
      recette: {
        'fr': "Trempez le feuilletage dans du lait sucré et gratinez au four avec des noix.",
        'en': "Soak puff pastry in sweetened milk and bake in the oven with nuts.",
        'ar': "انقع الرقائق في الحليب المحلى واخبزها في الفرن مع المكسرات.",
      },
      tags: {
        'fr': ["Dessert", "Chaud", "National"],
        'en': ["Dessert", "Warm", "National"],
        'ar': ["حلويات", "دافئ", "وطني"],
      },
    ),
    Plat(
      id: "basbousa",
      photo_url: "assets/plat/4.jpg",
      name: {
        'fr': "Basbousa",
        'en': "Basbousa",
        'ar': "بسبوسة",
      },
      ville: {
        'fr': "Assouan",
        'en': "Aswan",
        'ar': "أسوان",
      },
      description: {
        'fr': "Gâteau de semoule moelleux imbibé de sirop parfumé.",
        'en': "Soft semolina cake soaked in aromatic syrup.",
        'ar': "كعكة السميد الطرية المنقوعة في الشربات المعطر.",
      },
      recette: {
        'fr': "Cuisez la semoule au four et imbibez de sirop à la fleur d'oranger.",
        'en': "Bake the semolina cake and soak thoroughly with orange blossom syrup.",
        'ar': "اخبز خليط السميد وانقعه بالشربات المعطر بماء الزهر.",
      },
      tags: {
        'fr': ["Dessert", "Semoule", "Sucré"],
        'en': ["Dessert", "Semolina", "Sweet"],
        'ar': ["حلويات", "سميد", "حلو"],
      },
    ),
    Plat(
      id: "konafa",
      photo_url: "assets/plat/2.jpg",
      name: {
        'fr': "Konafa",
        'en': "Kunafa",
        'ar': "كنافة",
      },
      ville: {
        'fr': "Le Caire",
        'en': "Cairo",
        'ar': "القاهرة",
      },
      description: {
        'fr': "Vermicelles croustillants au beurre, garnis de crème ou fromage.",
        'en': "Crispy buttered pastry threads filled with cream or cheese.",
        'ar': "شعيرية معجونة بالزبدة مقرمشة ومحشوة بالكريمة أو الجبن.",
      },
      recette: {
        'fr': "Dorez les vermicelles, garnissez de crème et nappez de sirop parfumé.",
        'en': "Brown the pastry threads, fill with cream, and drizzle with scented syrup.",
        'ar': "حمر الشعيرية واحشُها بالكريمة ثم اسقها بالشربات المعطر.",
      },
      tags: {
        'fr': ["Dessert", "Croustillant", "Fromage"],
        'en': ["Dessert", "Crispy", "Cheese"],
        'ar': ["حلويات", "مقرمش", "جبن"],
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _chargerLangue();
  }

  Future<void> _chargerLangue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sauvegardee = prefs.getString('selected_language');
    if (sauvegardee != null && _uiTranslations.containsKey(sauvegardee) && mounted) {
      setState(() => _lang = sauvegardee);
    }
  }

  Future<void> _changerLangue(String nouvelle) async {
    if (_lang == nouvelle) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', nouvelle);
    if (mounted) setState(() => _lang = nouvelle);
  }

  String _t(String key) => _uiTranslations[_lang]?[key] ?? _uiTranslations['fr']![key] ?? key;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = _lang == 'ar';
    final double topPad = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: EgyptPalette.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: EgyptAurora(colors: [_accent, _gold, EgyptPalette.violet, EgyptPalette.rose]),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(topPad, isRtl)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) => EgyptReveal(
                        delay: i < 4 ? i * 90 : 0,
                        child: _dishCard(tous_les_plats[i], i),
                      ),
                      childCount: tous_les_plats.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFooter()),
              ],
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
              EgyptLangSwitch(current: _lang, accent: _accent, onChanged: _changerLangue),
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
          const SizedBox(height: 22),
          EgyptReveal(
            delay: 200,
            child: Text(
              '${tous_les_plats.length} ${_t('dishes')}'.toUpperCase(),
              style: GoogleFonts.montserrat(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
              ),
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }

  // ───────────────────────── Carte d'un plat ─────────────────────────

  Widget _dishCard(Plat plat, int index) {
    final String nom = plat.name[_lang] ?? plat.name['fr']!;
    final String ville = plat.ville[_lang] ?? plat.ville['fr']!;
    final String desc = plat.description[_lang] ?? plat.description['fr']!;
    final String recette = plat.recette[_lang] ?? plat.recette['fr']!;
    final List<String> tags = plat.tags[_lang] ?? plat.tags['fr']!;
    final String numero = (index + 1).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: EgyptPalette.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(38),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: _accent.withOpacity(0.14), blurRadius: 40, offset: const Offset(0, 18)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo qui se fond dans la carte
            SizedBox(
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    plat.photo_url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF151824)),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, EgyptPalette.card],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 18,
                    start: 18,
                    child: EgyptGlass(
                      radius: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, color: _accent, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            ville.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              color: EgyptPalette.sand,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 2,
                    end: 22,
                    child: Text(
                      numero,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white.withOpacity(0.22),
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Texte
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: GoogleFonts.playfairDisplay(
                      color: EgyptPalette.sand,
                      fontSize: 36,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    desc,
                    style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 22),

                  // Recette : bloc avec filet coloré
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: _accent.withOpacity(0.18)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 3,
                            decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(3)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('recipeTitle').toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    color: _accent,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  recette,
                                  style: GoogleFonts.montserrat(
                                    color: EgyptPalette.sand.withOpacity(0.88),
                                    fontSize: 14,
                                    height: 1.65,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final tag in tags) _tagPill(tag)],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagPill(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        tag,
        style: GoogleFonts.montserrat(color: EgyptPalette.muted, fontSize: 11.5, fontWeight: FontWeight.w600),
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
              gradient: LinearGradient(colors: [Colors.transparent, _accent, Colors.transparent]),
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