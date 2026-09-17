import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final ScrollController _scrollController = ScrollController();
  String _lang = 'fr';

  // Palette de couleurs Premium harmonisée
  final Color _bgDark = const Color(0xFF090A0F);
  final Color _cardDark = const Color(0xFF14151B);
  final Color _accentPink = const Color(0xFFFD79A8);

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': 'Gastronomie égyptienne',
      'recipeTitle': 'RECETTE TRADITIONNELLE',
    },
    'en': {
      'pageTitle': 'Egyptian Gastronomy',
      'recipeTitle': 'TRADITIONAL RECIPE',
    },
    'ar': {
      'pageTitle': 'المأكولات المصرية',
      'recipeTitle': 'وصفة تقليدية',
    },
  };

  // --- DONNÉES DES PLATS TRADUITES DANS LES 3 LANGUES ---
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? _accentPink : _cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _accentPink : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 11,
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
                // --- BARRE D'APPUI DEFILEMENT SITE WEB ---
                SliverAppBar(
                  pinned: false, // Défile avec l'intégralité de la page
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
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                  title: Text(
                    _getTranslatedText('pageTitle'),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          _buildLangButton('FR', 'fr'),
                          _buildLangButton('EN', 'en'),
                          _buildLangButton('AR', 'ar'),
                        ],
                      ),
                    ),
                  ],
                ),

                // --- LISTE DES PLATS ---
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

  // --- CARTE DE PLAT GASTRONOMIQUE PREMIUM AVEC HALO UNDERGLOW ---
  Widget _build_plat_card(Plat plat) {
    final String platNom = plat.name[_lang] ?? plat.name['fr']!;
    final String platVille = plat.ville[_lang] ?? plat.ville['fr']!;
    final String platDesc = plat.description[_lang] ?? plat.description['fr']!;
    final String platRecette = plat.recette[_lang] ?? plat.recette['fr']!;
    final List<String> platTags = plat.tags[_lang] ?? plat.tags['fr']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentPink.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _accentPink.withOpacity(0.22),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: _accentPink.withOpacity(0.1),
            blurRadius: 36,
            spreadRadius: -4,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Image.asset(
              plat.photo_url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Corps du texte
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de la Ville
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
                          platVille.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: _accentPink,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nom du plat
                  Text(
                    platNom,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    platDesc,
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Zone Recette stylisée
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
                        Text(
                          _getTranslatedText('recipeTitle'),
                          style: GoogleFonts.montserrat(
                            color: _accentPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          platRecette,
                          style: GoogleFonts.montserrat(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags du Plat
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: platTags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.montserrat(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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