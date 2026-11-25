import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────
//  PALETTE « OR & NUIT »
// ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0C0A09);
  static const surface = Color(0xFF14100C);
  static const gold = Color(0xFFD9B77A);
  static const goldLight = Color(0xFFF1DFB4);
  static const goldDeep = Color(0xFFA8823F);
  static const cream = Color(0xFFF4ECDF);
  static const ink = Color(0xFF16110A);
}

// --- 1. CLASSE DE DÉFILEMENT WEB ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

/// Petite icône qui s'inverse automatiquement en contexte RTL
/// (remplace le paramètre `matchTextDirection`, qui n'existe pas sur [Icon]).
class _DirectionalIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  const _DirectionalIcon(
      this.icon, {
        required this.size,
        required this.color,
      });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Transform(
      alignment: Alignment.center,
      transform: isRtl ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
      child: Icon(icon, size: size, color: color),
    );
  }
}

// --- 2. PAGE PRINCIPALE (SHARM EL-SHEIKH) ---
class SharmElSheikhPage extends StatefulWidget {
  const SharmElSheikhPage({super.key});

  @override
  State<SharmElSheikhPage> createState() => _SharmElSheikhPageState();
}

class _SharmElSheikhPageState extends State<SharmElSheikhPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _mainScrollController = ScrollController();
  late final AnimationController _shimmer;
  String _lang = 'fr';
  String _filter = 'all'; // 'all' | 'fav' | clé de catégorie
  Set<String> _favs = {};
  bool _showTop = false;

  // --- TRADUCTIONS DE L'INTERFACE ---
  static const Map<String, Map<String, String>> _uiTranslations = {
    'fr': {
      'pageTitle': "Sharm El-Sheikh",
      'tagline': "Entre mer Rouge et montagnes du Sinaï",
      'places': "lieux",
      'all': "Tout",
      'favs': "Favoris",
      'noFav': "Aucun favori pour le moment.\nTouche le ♡ pour en ajouter.",
      'discover': "Découvrir",
      'mapsBtn': "Ouvrir dans Google Maps",
      'about': "À propos",
      'overview': "En bref",
      'duration': "Durée conseillée",
      'bestTime': "Meilleur moment",
      'category': "Catégorie",
      'highlights': "Points forts",
      'didYouKnow': "Le saviez-vous ?",
      'tip': "Conseil du voyageur",
      'seeAlso': "À voir aussi",
      'catMonuments': "Monuments & Culture",
      'catExcursions': "Excursions incontournables",
      'catSeaNature': "Mer & Nature",
    },
    'en': {
      'pageTitle': "Sharm El-Sheikh",
      'tagline': "Between the Red Sea and the Sinai mountains",
      'places': "places",
      'all': "All",
      'favs': "Favorites",
      'noFav': "No favorites yet.\nTap the ♡ to add some.",
      'discover': "Discover",
      'mapsBtn': "Open in Google Maps",
      'about': "About",
      'overview': "At a glance",
      'duration': "Suggested time",
      'bestTime': "Best time",
      'category': "Category",
      'highlights': "Highlights",
      'didYouKnow': "Did you know?",
      'tip': "Traveller's tip",
      'seeAlso': "Also worth a visit",
      'catMonuments': "Monuments & Culture",
      'catExcursions': "Must-See Excursions",
      'catSeaNature': "Sea & Nature",
    },
    'ar': {
      'pageTitle': "شرم الشيخ",
      'tagline': "بين البحر الأحمر وجبال سيناء",
      'places': "مكان",
      'all': "الكل",
      'favs': "المفضلة",
      'noFav': "لا توجد أماكن مفضلة بعد.\nاضغط على ♡ للإضافة.",
      'discover': "اكتشف",
      'mapsBtn': "الفتح في خرائط Google",
      'about': "نبذة",
      'overview': "لمحة سريعة",
      'duration': "المدة المقترحة",
      'bestTime': "أفضل وقت",
      'category': "الفئة",
      'highlights': "أبرز المعالم",
      'didYouKnow': "هل تعلم؟",
      'tip': "نصيحة للمسافر",
      'seeAlso': "اكتشف أيضًا",
      'catMonuments': "المعالم والثقافة",
      'catExcursions': "رحلات لا بد منها",
      'catSeaNature': "البحر والطبيعة",
    },
  };

  // --- DONNÉES TRADUITES PAR LANGUE ---
  static const Map<String, List<Map<String, dynamic>>> _localizedSharmData = {
    'fr': [
      {
        "id": "mosque",
        "name": "La mosquée Al Sahaba",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "Située au cœur de la vieille ville, cette mosquée est un véritable chef-d'œuvre architectural. Alliant avec élégance les styles ottoman, fatimide et mamelouk, elle impressionne par ses détails complexes et sa silhouette imposante. Lorsque la nuit tombe, son éclairage savamment étudié sublime ses façades et ses minarets, créant une atmosphère mystique et majestueuse qui attire les visiteurs du monde entier.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "L'Église Copte Orthodoxe",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "Cette église est un joyau de sérénité et de beauté spirituelle. Ses vitraux aux couleurs vibrantes projettent des jeux de lumière fascinants à l'intérieur, tandis que ses fresques murales détaillées racontent avec précision la riche tradition copte égyptienne. C'est un havre de paix essentiel pour ceux qui souhaitent découvrir la profondeur culturelle et chrétienne de la région, loin du tumulte balnéaire.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "Hollywood Sharm El-Sheikh",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/h.jpg",
        "description": "Véritable parc à thème spectaculaire, ce lieu unique transporte les visiteurs dans un univers fantastique. Entre les répliques géantes de statues célèbres, les fontaines dansantes chorégraphiées et les installations lumineuses féeriques, c'est une destination incontournable pour les familles et les amateurs de photographie. L'ambiance y est constamment animée, offrant une expérience ludique et totalement dépaysante.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "La Vieille Ville",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/la.jpg",
        "description": "Le Vieux Marché représente le cœur battant et historique de Sharm El-Sheikh. C’est un labyrinthe vivant de ruelles où l'on découvre l'essence même de la culture locale. Entre les étals d'artisanat traditionnel, les épices aux parfums envoûtants et les boutiques de souvenirs, le visiteur s'immerge dans une ambiance authentique. C'est l'endroit rêvé pour goûter à la gastronomie égyptienne et échanger avec les commerçants dans une atmosphère chaleureuse.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "Le monastère Sainte-Catherine",
        "sub_category_key": "catExcursions",
        "sub_category": "Excursions incontournables",
        "photo_url": "assets/sharm/saint.webp",
        "description": "Niché au pied des montagnes grandioses du Sinaï, ce monastère est l'un des plus anciens lieux de culte chrétien encore en activité dans le monde. Classé au patrimoine mondial, il abrite une collection inestimable d'icônes byzantines, de manuscrits anciens et le célèbre 'Buisson Ardent'. Une visite ici est un voyage dans le temps, imprégné de spiritualité et d'une histoire séculaire qui semble figée dans le désert.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "Le mont Sinaï",
        "sub_category_key": "catExcursions",
        "sub_category": "Excursions incontournables",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "Lieu chargé d'une puissance symbolique immense, le mont Sinaï est la destination par excellence des pèlerins et randonneurs. L'ascension, traditionnellement effectuée de nuit pour atteindre le sommet avant l'aube, est une épreuve physique récompensée par un lever de soleil spectaculaire. Voir la lumière embraser les cimes désertiques depuis ce sommet historique offre un moment de contemplation rare et une expérience visuelle absolument inoubliable.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "Dahab",
        "sub_category_key": "catExcursions",
        "sub_category": "Excursions incontournables",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "Ancien village de pêcheurs devenu un repaire mythique pour les voyageurs en quête de liberté, Dahab possède une atmosphère bohème unique. Réputée mondialement pour son rythme de vie détendu et ses sites de plongée d'exception, la ville est une étape incontournable. Son mélange de culture bédouine et de mode de vie décontracté en bord de mer, couplé à la proximité de sites naturels grandioses, en fait une destination fascinante.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "L’île de Tiran",
        "sub_category_key": "catSeaNature",
        "sub_category": "Mer & Nature",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "L'île de Tiran est un véritable sanctuaire pour les amoureux de la mer. Située à l'embouchure du golfe d'Aqaba, elle est entourée de récifs coralliens parmi les plus préservés et les plus riches de la mer Rouge. Ses eaux d'une clarté incroyable permettent d'observer une faune marine dense, incluant des tortues marines, des raies et une multitude de poissons tropicaux, faisant de chaque excursion une aventure immersive dans un aquarium naturel à ciel ouvert.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "La mer",
        "sub_category_key": "catSeaNature",
        "sub_category": "Mer & Nature",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "La mer Rouge, véritable joyau de l'Égypte, offre des conditions de baignade et de plongée inégalées. Avec ses eaux turquoise dont la température est idéale toute l'année et une biodiversité marine d'une richesse rare au monde, elle constitue le terrain de jeu favori des plongeurs. Explorer ses fonds marins, c'est plonger dans un univers de coraux colorés et de vie sauvage où le spectacle sous-marin est un émerveillement constant.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "Dahab Blue Hole",
        "sub_category_key": "catSeaNature",
        "sub_category": "Mer & Nature",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "Le Blue Hole de Dahab est un site légendaire qui exerce une fascination magnétique sur tous les plongeurs du globe. Il s'agit d'un gouffre sous-marin naturel d'une profondeur vertigineuse, entouré de récifs coralliens d'une densité incroyable. La transition brutale entre le bleu lagon peu profond et le bleu profond et mystérieux de l'abîme offre un spectacle visuel saisissant, faisant de cet endroit un défi et un rêve pour les passionnés d'exploration sous-marine.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
    'en': [
      {
        "id": "mosque",
        "name": "Al Sahaba Mosque",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "Located in the heart of the Old Town, this mosque is a true architectural masterpiece. Elegantly blending Ottoman, Fatimid, and Mamluk styles, it impresses with intricate details and a grand silhouette. At night, thoughtfully designed lighting highlights its facades and minarets, creating a mystical and majestic atmosphere.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "Coptic Orthodox Church",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "This church is a sanctuary of serenity and spiritual beauty. Vibrant stained-glass windows cast fascinating light patterns inside, while detailed wall frescoes meticulously tell the rich story of Egyptian Coptic tradition. It offers a peaceful retreat for those wishing to discover the region's deep spiritual heritage.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "Hollywood Sharm El-Sheikh",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/h.jpg",
        "description": "A spectacular theme park, this unique attraction transports visitors into a world of fantasy. Featuring giant replicas of iconic statues, choreographed dancing fountains, and magical light displays, it is a must-visit for families and photography enthusiasts seeking lively entertainment.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "Old Town Market",
        "sub_category_key": "catMonuments",
        "sub_category": "Monuments & Culture",
        "photo_url": "assets/sharm/la.jpg",
        "description": "The Old Market is the vibrant, historic heart of Sharm El-Sheikh. A lively maze of alleys where you can experience the true essence of local culture. Surrounded by traditional crafts, fragrant spice stalls, and souvenir shops, visitors immerse themselves in an authentic atmosphere and local cuisine.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "Saint Catherine's Monastery",
        "sub_category_key": "catExcursions",
        "sub_category": "Must-See Excursions",
        "photo_url": "assets/sharm/saint.webp",
        "description": "Nestled at the foot of Mount Sinai, this UNESCO World Heritage site is one of the oldest continuously operating Christian monasteries in the world. It houses an invaluable collection of Byzantine icons, ancient manuscripts, and the famous 'Burning Bush', offering a profound journey through spiritual history.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "Mount Sinai",
        "sub_category_key": "catExcursions",
        "sub_category": "Must-See Excursions",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "A site of immense symbolic importance, Mount Sinai is a revered destination for pilgrims and hikers. Typically climbed overnight to reach the summit before dawn, hikers are rewarded with a breathtaking sunrise igniting the desert peaks in a truly unforgettable spectacle.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "Dahab",
        "sub_category_key": "catExcursions",
        "sub_category": "Must-See Excursions",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "Once a quiet fishing village, Dahab has evolved into a famous coastal haven with a unique bohemian vibe. Renowned for its laid-back lifestyle and world-class diving sites, it seamlessly blends Bedouin tradition with relaxed seaside charm.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "Tiran Island",
        "sub_category_key": "catSeaNature",
        "sub_category": "Sea & Nature",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "Tiran Island is a marine sanctuary situated at the mouth of the Gulf of Aqaba. Surrounded by pristine coral reefs teeming with marine life—including sea turtles, rays, and vibrant tropical fish—it offers unparalleled snorkeling and diving in a natural open-air aquarium.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "The Red Sea",
        "sub_category_key": "catSeaNature",
        "sub_category": "Sea & Nature",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "The Red Sea is Egypt's coastal crown jewel, offering world-class swimming, snorkeling, and diving conditions. With warm turquoise waters year-round and rich marine biodiversity, exploring its coral gardens is a constantly breathtaking underwater adventure.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "Dahab Blue Hole",
        "sub_category_key": "catSeaNature",
        "sub_category": "Sea & Nature",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "The Dahab Blue Hole is a world-renowned submarine sinkhole that fascinates divers globally. Dropping into dizzying depths and framed by dense coral walls, the dramatic shift from shallow turquoise lagoon to abyssal deep blue creates a thrilling underwater landmark.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
    'ar': [
      {
        "id": "mosque",
        "name": "مسجد الصحابة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/mosque.jpeg",
        "description": "يقع هذا المسجد في قلب المدينة القديمة، ويُعد شاهكاراً معمارياً حقيقياً. يجمع بأناقة بين الأنماط العثمانية والفاطمية والمملوكية، ويثير الإعجاب بتفاصيله المعقدة ومأذنتيه الشامختين. عند حلول الليل، تبرز إضاءته المدروسة بعناية واجهاته ومآذنه، مما يخلق أجواءً ساحرة ومجيدة تجذب الزوار من جميع أنحاء العالم.",
        "mapsQuery": "Al Sahaba Mosque Sharm El-Sheikh"
      },
      {
        "id": "eglise",
        "name": "الكنيسة القبطية الأرثوذكسية",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/eglise.jpg",
        "description": "تعتبر هذه الكنيسة جوهرة من الهدوء والجمال الروحي. تعكس زجاجياتها الملونة الزاهية ألعاباً ضوئية ساحرة بالداخل، بينما تحكي جدارياتها المفصلة بدقة التقاليد القبطية المصرية الغنية. إنها واحة من السلام لمن يرغب في اكتشاف العمق الثقافي والروحي للمنطقة.",
        "mapsQuery": "Coptic Church Sharm El-Sheikh"
      },
      {
        "id": "hollywood",
        "name": "هوليوود شرم الشيخ",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/h.jpg",
        "description": "متنزّه ترفيهي مذهل ينقل الزوار إلى عالم خيالي حافل بالإثارة. يضم مجسمات عملاقة لتماثيل شهيرة، ونوافير راقصة ومجسمات مضيئة ساحرة، مما يجعله وجهة مثالية للعائلات ومحبي التصوير الفوتوغرافي للاستمتاع بأجواء مليئة بالبهجة والمرح.",
        "mapsQuery": "Hollywood Sharm El-Sheikh"
      },
      {
        "id": "old_market",
        "name": "المدينة القديمة",
        "sub_category_key": "catMonuments",
        "sub_category": "المعالم والثقافة",
        "photo_url": "assets/sharm/la.jpg",
        "description": "يمثل السوق القديم النابض بالحياة القلب التاريخي لشرم الشيخ. إنه متاهة حية من الأزقة المليئة بالمصنوعات اليدوية التقليدية والتوابل العطرة ومتاجر الهدايا التذكارية، حيث ينغمس الزائر في أجواء أصلية ويتذوق أفضل المأكولات المصرية.",
        "mapsQuery": "Old Market Sharm El-Sheikh"
      },
      {
        "id": "saint_catherine",
        "name": "دير سانت كاترين",
        "sub_category_key": "catExcursions",
        "sub_category": "رحلات لا بد منها",
        "photo_url": "assets/sharm/saint.webp",
        "description": "يقع هذا الدير عند قدم جبال سيناء الشامخة، وهو أحد أقدم الأديرة المسيحية المأهولة في العالم. مدرج ضمن التراث العالمي لليونسكو، ويضم مجموعة لا تُقدر بثمن من الأيقونات البيزنطية والمخطوطات القديمة بالإضافة إلى الشجيرة المشتعلة الشهيرة.",
        "mapsQuery": "Saint Catherine's Monastery Sinai"
      },
      {
        "id": "mount_sinai",
        "name": "جبل سيناء",
        "sub_category_key": "catExcursions",
        "sub_category": "رحلات لا بد منها",
        "photo_url": "assets/sharm/mont.jpeg",
        "description": "مكان ذو أهمية رمزية وروحية عظيمة، ويُعد وجهة ممتازة للحجاج ومحبي تسلق الجبال. تتم الصعود عادةً ليلاً للوصول إلى القمة قبل الفجر، حيث يُكافأ الصاعدون بمشهد شروق شمس مذهل يضيء قمم الصحراء في لحظة تأمل لا تُنسى.",
        "mapsQuery": "Mount Sinai Egypt"
      },
      {
        "id": "dahab",
        "name": "دهب",
        "sub_category_key": "catExcursions",
        "sub_category": "رحلات لا بد منها",
        "photo_url": "assets/sharm/Dahab.webp",
        "description": "قرية صيادين سابقة تحولت إلى ملاذ شهير للمسافرين الباحثين عن الهدوء والحرية. تتميز دهب بأجوائها البوهيمية الفريدة وشواطئها الخلابة ومواقع الغوص العالمية، حيث تمزج بين الثقافة البدوية وأسلوب الحياة الاسترخائي على البحر.",
        "mapsQuery": "Dahab South Sinai"
      },
      {
        "id": "tiran_island",
        "name": "جزيرة تيران",
        "sub_category_key": "catSeaNature",
        "sub_category": "البحر والطبيعة",
        "photo_url": "assets/sharm/tirana.jpg",
        "description": "تعتبر جزيرة تيران محمية طبيعية لعشاق البحر. تقع عند مدخل خليج العقبة وتحيط بها شعاب مرجانية من الأجمل والأكثر تنوعاً في البحر الأحمر، حيث تتيح مياهها الكريستالية رؤية السلاحف البحرية والكائنات البحرية الملونة.",
        "mapsQuery": "Tiran Island Red Sea"
      },
      {
        "id": "red_sea",
        "name": "البحر الأحمر",
        "sub_category_key": "catSeaNature",
        "sub_category": "البحر والطبيعة",
        "photo_url": "assets/sharm/mer.jpg",
        "description": "البحر الأحمر هو الجوهرة الساحلية لمصر، ويوفر أروع ظروف السباحة والغوص على مدار العام. بفضل مياهه الفيروزية الدافئة وتنوعه البيولوجي الغني، يُعد الاستكشاف تحت الماء رحلة مذهلة بين الشعاب المرجانية والأحياء البحرية.",
        "mapsQuery": "Red Sea Sharm El-Sheikh"
      },
      {
        "id": "blue_hole",
        "name": "الثقب الأزرق بدهب",
        "sub_category_key": "catSeaNature",
        "sub_category": "البحر والطبيعة",
        "photo_url": "assets/sharm/ll.jpg",
        "description": "يُعد الثقب الأزرق في دهب موقعاً أسطورياً يجذب الغواصين من جميع أنحاء العالم. وهو حفرة عميقة تحت الماء محاطة بالشعاب المرجانية، ويتيح التباين المذهل بين الأزرق الفاتح والأزرق الداكن للعمق تجربة غوص فريدة وساحرة.",
        "mapsQuery": "Blue Hole Dahab"
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _mainScrollController.addListener(() {
      final show = _mainScrollController.offset > 600;
      if (show != _showTop) setState(() => _showTop = show);
    });
    _chargerPrefs();
  }

  Future<void> _chargerPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langSauvegardee = prefs.getString('selected_language');
    final favs = prefs.getStringList('favorite_places') ?? <String>[];
    if (!mounted) return;
    setState(() {
      if (langSauvegardee != null &&
          _uiTranslations.containsKey(langSauvegardee)) {
        _lang = langSauvegardee;
      }
      _favs = favs.toSet();
    });
  }

  Future<void> _changerLangue(String nouvelleLangue) async {
    if (_lang == nouvelleLangue) return;
    HapticFeedback.selectionClick();
    setState(() => _lang = nouvelleLangue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', nouvelleLangue);
  }

  Future<void> _toggleFav(String id) async {
    HapticFeedback.lightImpact();
    setState(() {
      if (!_favs.remove(id)) _favs.add(id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_places', _favs.toList());
  }

  Future<void> _ouvrirMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('Impossible d\'ouvrir Google Maps');
      }
    } catch (e) {
      debugPrint('Erreur ouverture Maps : $e');
    }
  }

  // Palette monochrome : tout en or champagne
  Color _getCategoryColor(String categoryKey) => _C.gold;

  IconData _getCategoryIcon(String categoryKey) {
    switch (categoryKey) {
      case "catMonuments":
        return Icons.account_balance_outlined;
      case "catExcursions":
        return Icons.explore_outlined;
      case "catSeaNature":
        return Icons.waves_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  String _getTranslatedText(String key) {
    return _uiTranslations[_lang]?[key] ?? _uiTranslations['fr']![key] ?? key;
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  // ───────────── Sélecteur de langue ─────────────
  Widget _buildLangSwitcher() {
    const codes = ['fr', 'en', 'ar'];
    const labels = ['FR', 'EN', 'AR'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _C.gold.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final active = _lang == codes[i];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _changerLangue(codes[i]),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color:
                            active ? _C.gold : _C.cream.withOpacity(0.6),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                          child: Text(labels[i]),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          height: 1,
                          width: active ? 16 : 0,
                          color: _C.gold,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ───────────── Onglets de filtre (texte + filet doré) ─────────────
  Widget _buildTab({
    required String id,
    required String label,
    IconData? icon,
  }) {
    final selected = _filter == id;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_filter == id) return;
          HapticFeedback.selectionClick();
          setState(() => _filter = id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 13,
                        color: selected
                            ? _C.gold
                            : _C.cream.withOpacity(0.5)),
                    const SizedBox(width: 7),
                  ],
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      color: selected ? _C.gold : _C.cream.withOpacity(0.55),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: _ls(context, 2.2),
                    ),
                    child: Text(label.toUpperCase()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                height: 1.5,
                width: selected ? 30 : 0,
                color: _C.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(Map<String, dynamic> item, Color color, IconData icon) {
    HapticFeedback.selectionClick();
    final isRtl = _lang == 'ar';
    final id = item['id'] as String;
    final extraAll = _placeExtras[id];
    final extra =
    (extraAll?[_lang] ?? extraAll?['fr']) as Map<String, dynamic>?;
    final relIds = ((extraAll?['related'] as List?) ?? const []).cast<String>();
    final all = _localizedSharmData[_lang] ?? _localizedSharmData['fr']!;
    final related = <Map<String, dynamic>>[
      for (final r in relIds) ...all.where((e) => e['id'] == r),
    ];
    final labels = <String, String>{
      for (final k in const [
        'about', 'overview', 'duration', 'bestTime', 'category',
        'highlights', 'didYouKnow', 'tip', 'seeAlso',
      ])
        k: _getTranslatedText(k),
    };
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: _PlaceDetailPage(
            item: item,
            color: color,
            icon: icon,
            mapsLabel: _getTranslatedText('mapsBtn'),
            isFav: _favs.contains(item['id']),
            onFav: () => _toggleFav(item['id'] as String),
            onMaps: () =>
                _ouvrirMaps(item['mapsQuery'] ?? "${item['name']} Sharm"),
            labels: labels,
            extra: extra,
            related: related,
            onOpenRelated: (r) {
              final k = r['sub_category_key'] as String? ?? 'catHistory';
              _openDetail(r, _getCategoryColor(k), _getCategoryIcon(k));
            },
          ),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: child,
        ),
      ),
    );
  }

  Widget _wrap(Key key, Widget child) {
    return Center(
      key: key,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> currentData =
        _localizedSharmData[_lang] ?? _localizedSharmData['fr']!;
    final bool isRtl = _lang == 'ar';
    final double topPad = MediaQuery.of(context).padding.top;
    final double screenH = MediaQuery.of(context).size.height;
    final double heroH = (screenH * 0.82).clamp(500.0, 800.0).toDouble();

    // Catégories dans l'ordre d'apparition
    final List<String> catKeys = [];
    for (final item in currentData) {
      final k = item['sub_category_key'] as String? ?? 'catHistory';
      if (!catKeys.contains(k)) catKeys.add(k);
    }

    // Filtrage
    final List<Map<String, dynamic>> visible = currentData.where((item) {
      if (_filter == 'all') return true;
      if (_filter == 'fav') return _favs.contains(item['id']);
      return item['sub_category_key'] == _filter;
    }).toList();

    // Lignes (en-têtes + cartes)
    final List<_Entry> entries = [];
    if (_filter == 'all') {
      for (final k in catKeys) {
        final items =
        visible.where((e) => e['sub_category_key'] == k).toList();
        entries.add(_Entry(header: k, count: items.length));
        for (final it in items) {
          entries.add(_Entry(item: it));
        }
      }
    } else {
      for (final it in visible) {
        entries.add(_Entry(item: it));
      }
    }

    // Numérotation éditoriale des cartes (01, 02, 03…)
    final List<int> nums = [];
    int n = 0;
    for (final e in entries) {
      if (e.item != null) {
        n++;
        nums.add(n);
      } else {
        nums.add(0);
      }
    }

    final String ctxKey = '${_lang}_$_filter';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _C.bg,
        floatingActionButton: AnimatedScale(
          scale: _showTop ? 1 : 0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          child: FloatingActionButton.small(
            backgroundColor: _C.bg.withOpacity(0.92),
            foregroundColor: _C.gold,
            elevation: 0,
            hoverElevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            shape: CircleBorder(
              side: BorderSide(color: _C.gold.withOpacity(0.6)),
            ),
            onPressed: () => _mainScrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOutCubic,
            ),
            child: const Icon(Icons.keyboard_arrow_up_rounded, size: 26),
          ),
        ),
        body: ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: CustomScrollView(
            controller: _mainScrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Hero(
                  topPad: topPad,
                  height: heroH,
                  title: _getTranslatedText('pageTitle'),
                  tagline: _getTranslatedText('tagline'),
                  countText:
                  '${currentData.length} ${_getTranslatedText('places')}',
                  langSwitcher: _buildLangSwitcher(),
                  shimmer: _shimmer,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 148,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/sharm.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterBarDelegate(
                  topPad: topPad,
                  child: LayoutBuilder(
                    builder: (context, cons) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: cons.maxWidth),
                        child: SizedBox(
                          height: 64,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              _buildTab(
                                id: 'all',
                                label: _getTranslatedText('all'),
                              ),
                              _buildTab(
                                id: 'fav',
                                label: _getTranslatedText('favs'),
                                icon: Icons.favorite_border_rounded,
                              ),
                              ...catKeys.map(
                                    (k) => _buildTab(
                                  id: k,
                                  label: _getTranslatedText(k),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                sliver: entries.isEmpty
                    ? SliverToBoxAdapter(
                  child: _Reveal(
                    key: ValueKey('empty_$ctxKey'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 110, horizontal: 30),
                      child: Column(
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 46,
                              color: _C.gold.withOpacity(0.6)),
                          const SizedBox(height: 22),
                          const _Ornament(width: 110),
                          const SizedBox(height: 22),
                          Text(
                            _getTranslatedText('noFav'),
                            textAlign: TextAlign.center,
                            style: _serif(
                              context,
                              size: 20,
                              weight: FontWeight.w400,
                              color: _C.cream.withOpacity(0.75),
                              height: 1.7,
                              style: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final e = entries[i];
                      if (e.header != null) {
                        final k = e.header!;
                        return _wrap(
                          ValueKey('h_${ctxKey}_$k'),
                          _Reveal(
                            child: _SectionHeader(
                              title: _getTranslatedText(k),
                              countLabel:
                              '${e.count} ${_getTranslatedText('places')}',
                            ),
                          ),
                        );
                      }
                      final item = e.item!;
                      final k = item['sub_category_key'] as String? ??
                          'catHistory';
                      final id = item['id'] as String;
                      return _wrap(
                        ValueKey('c_${ctxKey}_$id'),
                        _Reveal(
                          delay:
                          Duration(milliseconds: math.min(i, 2) * 80),
                          dy: 44,
                          child: _PlaceCard(
                            item: item,
                            number: nums[i],
                            icon: _getCategoryIcon(k),
                            isFav: _favs.contains(id),
                            discoverLabel: _getTranslatedText('discover'),
                            onFav: () => _toggleFav(id),
                            onTap: () => _openDetail(
                                item, _getCategoryColor(k), _getCategoryIcon(k)),
                          ),
                        ),
                      );
                    },
                    childCount: entries.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _Footer(title: _getTranslatedText('pageTitle')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
//  OUTILS
// ─────────────────────────────────────────────────────────────

/// Le letterSpacing casse la liaison des lettres arabes : on l'annule en RTL.
double _ls(BuildContext c, double v) =>
    Directionality.of(c) == TextDirection.rtl ? 0 : v;

class _Entry {
  final String? header;
  final int count;
  final Map<String, dynamic>? item;
  _Entry({this.header, this.count = 0, this.item});
}

/// Apparition douce : fondu + glissement vers le haut, avec délai.
class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double dy;
  const _Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.dy = 36,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: _a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, widget.dy * (1 - _a.value)),
          child: child,
        ),
      ),
    );
  }
}

class _PlaceImage extends StatelessWidget {
  final String path;
  const _PlaceImage(this.path);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2017), Color(0xFF5A4122)],
          ),
        ),
        child: Center(
          child: Icon(Icons.landscape_outlined, color: _C.gold, size: 48),
        ),
      ),
    );
  }
}

/// Motif de losanges façon moucharabieh.
class _LatticePainter extends CustomPainter {
  final double opacity;
  _LatticePainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final p = Paint()
      ..color = _C.gold.withOpacity(opacity)
      ..strokeWidth = 0.8;
    const s = 46.0;
    for (double x = -size.height; x < size.width + size.height; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant _LatticePainter old) => old.opacity != opacity;
}


// ─────────────────────────────────────────────────────────────
//  TYPOGRAPHIE & ORNEMENTS
// ─────────────────────────────────────────────────────────────
const List<String> _serifFallback = [
  'Cormorant Garamond',
  'Playfair Display',
  'Georgia',
  'Times New Roman',
  'Noto Serif',
  'serif',
];

TextStyle _serif(
    BuildContext c, {
      required double size,
      FontWeight weight = FontWeight.w500,
      Color color = _C.cream,
      double height = 1.2,
      double ls = 0,
      FontStyle? style,
    }) =>
    TextStyle(
      fontFamily: 'Cormorant Garamond',
      fontFamilyFallback: _serifFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: _ls(c, ls),
      fontStyle: style,
    );

/// Filet doré – losange – filet doré.
class _Ornament extends StatelessWidget {
  final double width;
  const _Ornament({this.width = 140});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _C.gold.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(width: 6, height: 6, color: _C.gold),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_C.gold.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HERO PLEIN ÉCRAN (un bloc de la page : il défile comme sur un site)
// ─────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  final double topPad;
  final double height;
  final String title;
  final String tagline;
  final String countText;
  final Widget langSwitcher;
  final AnimationController shimmer;

  const _Hero({
    required this.topPad,
    required this.height,
    required this.title,
    required this.tagline,
    required this.countText,
    required this.langSwitcher,
    required this.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final titleSize = (w * 0.15).clamp(56.0, 118.0).toDouble();

    return SizedBox(
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo avec très lente respiration
            AnimatedBuilder(
              animation: shimmer,
              builder: (_, __) {
                final z = 1.08 + 0.04 * math.sin(shimmer.value * 2 * math.pi);
                return Transform.scale(
                  scale: z,
                  child: const _PlaceImage('assets/sharm/mer.jpg'),
                );
              },
            ),
            // Voile cinéma, qui se fond dans le fond de la page
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x1A000000),
                    Color(0x66000000),
                    Color(0xFF0C0A09),
                  ],
                  stops: [0, 0.28, 0.62, 1],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _LatticePainter(0.035)),
              ),
            ),
            // Cadre doré fin
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, topPad + 74, 18, 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _C.gold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Contenu central
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 24,
              end: 24,
              bottom: 70,
              child: _HeroTitle(
                title: title,
                tagline: tagline,
                countText: countText,
                titleSize: titleSize,
                shimmer: shimmer,
              ),
            ),
            // Langues, en haut de la page
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: topPad + 14,
              end: 18,
              child: langSwitcher,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTitle extends StatelessWidget {
  final String title;
  final String tagline;
  final String countText;
  final double titleSize;
  final AnimationController shimmer;

  const _HeroTitle({
    required this.title,
    required this.tagline,
    required this.countText,
    required this.titleSize,
    required this.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 34 * (1 - v)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Ornament(width: 150),
              const SizedBox(height: 22),
              Text(
                countText.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _ls(context, 5),
                ),
              ),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: shimmer,
                builder: (_, child) => ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [_C.cream, _C.gold, _C.cream],
                    stops: [
                      (shimmer.value - 0.25).clamp(0.0, 1.0).toDouble(),
                      shimmer.value,
                      (shimmer.value + 0.25).clamp(0.0, 1.0).toDouble(),
                    ],
                  ).createShader(r),
                  child: child,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: _serif(
                    context,
                    size: titleSize,
                    weight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.0,
                    ls: 3,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tagline,
                textAlign: TextAlign.center,
                style: _serif(
                  context,
                  size: 22,
                  weight: FontWeight.w400,
                  color: _C.cream.withOpacity(0.92),
                  style: FontStyle.italic,
                  ls: 0.4,
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: 1,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_C.gold, _C.gold.withOpacity(0)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BARRE DE FILTRES ÉPINGLÉE
// ─────────────────────────────────────────────────────────────
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double topPad;
  _FilterBarDelegate({required this.child, this.topPad = 0});

  @override
  double get minExtent => 64 + topPad;
  @override
  double get maxExtent => 64 + topPad;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _C.bg.withOpacity(overlapsContent ? 0.9 : 0.97),
            border: Border(
              bottom: BorderSide(color: _C.gold.withOpacity(0.18)),
            ),
          ),
          padding: EdgeInsets.only(top: topPad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterBarDelegate old) => true;
}

// ─────────────────────────────────────────────────────────────
//  EN-TÊTE DE SECTION & PIED DE PAGE
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String countLabel;
  const _SectionHeader({required this.title, required this.countLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90, bottom: 28),
      child: Column(
        children: [
          const _Ornament(width: 120),
          const SizedBox(height: 26),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _serif(
              context,
              size: 40,
              weight: FontWeight.w500,
              height: 1.1,
              ls: 1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            countLabel.toUpperCase(),
            style: TextStyle(
              color: _C.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: _ls(context, 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String title;
  const _Footer({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, bottom: 130),
      child: Column(
        children: [
          const _Ornament(width: 160),
          const SizedBox(height: 24),
          Text(
            title.toUpperCase(),
            style: _serif(
              context,
              size: 18,
              weight: FontWeight.w600,
              color: _C.gold,
              ls: 7,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CARTE ÉDITORIALE
// ─────────────────────────────────────────────────────────────
class _PlaceCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int number;
  final IconData icon;
  final bool isFav;
  final String discoverLabel;
  final VoidCallback onFav;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.item,
    required this.number,
    required this.icon,
    required this.isFav,
    required this.discoverLabel,
    required this.onFav,
    required this.onTap,
  });

  @override
  State<_PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<_PlaceCard> {
  bool _hover = false;

  Widget _image(BuildContext context, double aspect) {
    final it = widget.item;
    final id = it['id'] as String;
    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScale(
              scale: _hover ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              child: Hero(
                tag: 'img_$id',
                child: _PlaceImage(it['photo_url'] ?? ''),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x59000000),
                  ],
                  stops: [0, 0.25, 0.7, 1],
                ),
              ),
            ),
            // Cadre doré intérieur
            Padding(
              padding: const EdgeInsets.all(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _C.gold.withOpacity(_hover ? 0.85 : 0.32),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 26,
              start: 28,
              child: Text(
                widget.number.toString().padLeft(2, '0'),
                style: _serif(
                  context,
                  size: 26,
                  weight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.92),
                  height: 1.0,
                  ls: 1,
                ),
              ),
            ),
            PositionedDirectional(
              top: 18,
              end: 20,
              child: _HeartButton(isFav: widget.isFav, onTap: widget.onFav),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(BuildContext context, {required bool wide}) {
    final it = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 28, height: 1, color: _C.gold),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                (it['sub_category'] ?? '').toString().toUpperCase(),
                style: TextStyle(
                  color: _C.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _ls(context, 2.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          it['name'] ?? '',
          style: _serif(
            context,
            size: wide ? 44 : 36,
            weight: FontWeight.w500,
            height: 1.08,
            ls: 0.2,
          ),
        ),
        const SizedBox(height: 22),
        Container(width: 48, height: 1, color: _C.gold.withOpacity(0.5)),
        const SizedBox(height: 22),
        Text(
          it['description'] ?? '',
          style: TextStyle(
            color: _C.cream.withOpacity(0.74),
            fontSize: 14.5,
            height: 1.9,
            letterSpacing: _ls(context, 0.15),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.discoverLabel.toUpperCase(),
              style: TextStyle(
                color: _C.gold,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: _ls(context, 2.8),
              ),
            ),
            const SizedBox(width: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              width: _hover ? 64 : 34,
              height: 1,
              color: _C.gold,
            ),
            const SizedBox(width: 6),
            const _DirectionalIcon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: _C.gold,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 820;
            if (wide) {
              final imageFirst = widget.number.isOdd;
              final img = Expanded(flex: 6, child: _image(context, 1.12));
              final txt = Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: _text(context, wide: true),
                ),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 38),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: imageFirst ? [img, txt] : [txt, img],
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _image(context, 0.86),
                      const SizedBox(height: 28),
                      _text(context, wide: false),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BOUTONS
// ─────────────────────────────────────────────────────────────
class _HeartButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onTap;
  const _HeartButton({required this.isFav, required this.onTap});

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  double _scale = 1;

  void _pop() {
    widget.onTap();
    setState(() => _scale = 1.35);
    Future.delayed(const Duration(milliseconds: 170), () {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pop,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.38),
                border: Border.all(color: _C.gold.withOpacity(0.55)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: Icon(
                  widget.isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(widget.isFav),
                  size: 18,
                  color: widget.isFav ? _C.gold : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.35),
                border: Border.all(color: _C.gold.withOpacity(0.5)),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _ShineButton({required this.label, required this.onTap});

  @override
  State<_ShineButton> createState() => _ShineButtonState();
}

class _ShineButtonState extends State<_ShineButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.98 : 1,
          duration: const Duration(milliseconds: 160),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [_C.goldDeep, _C.gold, _C.goldLight, _C.gold],
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.gold.withOpacity(0.28),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: LayoutBuilder(
                        builder: (_, cons) => AnimatedBuilder(
                          animation: _c,
                          builder: (_, __) => Stack(
                            children: [
                              Positioned(
                                left: -120 + (cons.maxWidth + 240) * _c.value,
                                top: 0,
                                bottom: 0,
                                width: 90,
                                child: Transform(
                                  transform: Matrix4.skewX(-0.4),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0),
                                          Colors.white.withOpacity(0.42),
                                          Colors.white.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Double filet intérieur
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: _C.ink.withOpacity(0.28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 58),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me_outlined,
                            color: _C.ink, size: 18),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _C.ink,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: _ls(context, 2.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PAGE DÉTAIL
// ─────────────────────────────────────────────────────────────
class _PlaceDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color color;
  final IconData icon;
  final String mapsLabel;
  final bool isFav;
  final VoidCallback onFav;
  final VoidCallback onMaps;
  final Map<String, String> labels;
  final Map<String, dynamic>? extra;
  final List<Map<String, dynamic>> related;
  final ValueChanged<Map<String, dynamic>> onOpenRelated;

  const _PlaceDetailPage({
    required this.item,
    required this.color,
    required this.icon,
    required this.mapsLabel,
    required this.isFav,
    required this.onFav,
    required this.onMaps,
    required this.labels,
    required this.extra,
    required this.related,
    required this.onOpenRelated,
  });

  @override
  State<_PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<_PlaceDetailPage> {
  late bool _fav = widget.isFav;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final id = it['id'] as String;
    final size = MediaQuery.of(context).size;
    final heroH = (size.height * 0.68).clamp(440.0, 700.0).toDouble();
    final titleSize = (size.width * 0.11).clamp(38.0, 68.0).toDouble();

    return Scaffold(
      backgroundColor: _C.bg,
      extendBody: true,
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: WebScrollBehavior(),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: heroH,
                  backgroundColor: _C.bg,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leadingWidth: 70,
                  leading: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 18),
                    child: Center(
                      child: _GlassButton(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const _DirectionalIcon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 14),
                      child: Center(
                        child: _HeartButton(
                          isFav: _fav,
                          onTap: () {
                            widget.onFav();
                            setState(() => _fav = !_fav);
                          },
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'img_$id',
                          child: _PlaceImage(it['photo_url'] ?? ''),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x80000000),
                                Color(0x00000000),
                                Color(0x73000000),
                                Color(0xFF0C0A09),
                              ],
                              stops: [0, 0.25, 0.65, 1],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(28, 0, 28, 44),
                            child: _Reveal(
                              delay: const Duration(milliseconds: 250),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (it['sub_category'] ?? '')
                                        .toString()
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _C.gold,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: _ls(context, 4),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    it['name'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: _serif(
                                      context,
                                      size: titleSize,
                                      weight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1.05,
                                      ls: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _DetailBody(
                    item: it,
                    labels: widget.labels,
                    extra: widget.extra,
                    related: widget.related,
                    onOpenRelated: widget.onOpenRelated,
                  ),
                ),
              ],
            ),
          ),
          // Bouton Google Maps flottant
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    24, 40, 24, 22 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x000C0A09), Color(0xF20C0A09)],
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _ShineButton(
                      label: widget.mapsLabel,
                      onTap: widget.onMaps,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CORPS DE LA PAGE DÉTAIL (sections enrichies)
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 28, height: 1, color: _C.gold),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: _C.gold,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: _ls(context, 2.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _C.gold.withOpacity(0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: _C.cream.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _ls(context, 2.2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: _serif(
                context,
                size: 19,
                weight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  final int index;
  final String title;
  final String text;
  const _Highlight(
      {required this.index, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    const numerals = ['I', 'II', 'III', 'IV', 'V', 'VI'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 34),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              numerals[index % numerals.length],
              style: _serif(
                context,
                size: 30,
                weight: FontWeight.w400,
                color: _C.gold,
                height: 1.1,
                style: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _serif(
                    context,
                    size: 25,
                    weight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: _C.cream.withOpacity(0.72),
                    fontSize: 14.5,
                    height: 1.85,
                    letterSpacing: _ls(context, 0.15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DidYouKnow extends StatelessWidget {
  final String label;
  final String text;
  const _DidYouKnow({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 38),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: _C.gold.withOpacity(0.35)),
        ),
      ),
      child: Column(
        children: [
          Text(
            '“',
            style: _serif(
              context,
              size: 84,
              weight: FontWeight.w500,
              color: _C.gold,
              height: 1.0,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: _C.gold,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: _ls(context, 3.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: _serif(
              context,
              size: 22,
              weight: FontWeight.w400,
              color: _C.cream.withOpacity(0.92),
              height: 1.7,
              style: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String label;
  final String text;
  const _TipBox({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _C.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: _C.gold.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.lightbulb_outline_rounded,
                color: _C.gold, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: _C.gold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: _ls(context, 2.6),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: _C.cream.withOpacity(0.84),
                    fontSize: 14.5,
                    height: 1.8,
                    letterSpacing: _ls(context, 0.15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _RelatedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PlaceImage(item['photo_url'] ?? ''),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x33000000),
                        Color(0xE6000000),
                      ],
                      stops: [0.3, 0.55, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: _C.gold.withOpacity(0.35)),
                    ),
                  ),
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 22,
                  end: 22,
                  bottom: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (item['sub_category'] ?? '').toString().toUpperCase(),
                        style: TextStyle(
                          color: _C.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: _ls(context, 2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['name'] ?? '',
                        style: _serif(
                          context,
                          size: 23,
                          weight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, String> labels;
  final Map<String, dynamic>? extra;
  final List<Map<String, dynamic>> related;
  final ValueChanged<Map<String, dynamic>> onOpenRelated;

  const _DetailBody({
    required this.item,
    required this.labels,
    required this.extra,
    required this.related,
    required this.onOpenRelated,
  });

  String _l(String k) => labels[k] ?? k;

  @override
  Widget build(BuildContext context) {
    final List hl = (extra?['hl'] as List?) ?? const [];
    final String? fact = extra?['fact'] as String?;
    final String? tip = extra?['tip'] as String?;
    final String? duration = extra?['duration'] as String?;
    final String? best = extra?['best'] as String?;
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: _Reveal(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: _Ornament(width: 150)),
                    const SizedBox(height: 44),
                    _SectionLabel(_l('about')),
                    const SizedBox(height: 22),
                    Text(
                      item['description'] ?? '',
                      style: _serif(
                        context,
                        size: 19,
                        weight: FontWeight.w400,
                        color: _C.cream.withOpacity(0.86),
                        height: 1.95,
                        ls: 0.2,
                      ),
                    ),
                    if (duration != null || best != null) ...[
                      const SizedBox(height: 64),
                      _SectionLabel(_l('overview')),
                      const SizedBox(height: 14),
                      if (duration != null)
                        _InfoRow(label: _l('duration'), value: duration),
                      if (best != null)
                        _InfoRow(label: _l('bestTime'), value: best),
                      _InfoRow(
                        label: _l('category'),
                        value: (item['sub_category'] ?? '').toString(),
                      ),
                    ],
                    if (hl.isNotEmpty) ...[
                      const SizedBox(height: 70),
                      _SectionLabel(_l('highlights')),
                      const SizedBox(height: 34),
                      for (int i = 0; i < hl.length; i++)
                        _Highlight(
                          index: i,
                          title: (hl[i] as Map)['t'] as String,
                          text: (hl[i] as Map)['d'] as String,
                        ),
                    ],
                    if (fact != null) ...[
                      const SizedBox(height: 40),
                      _DidYouKnow(label: _l('didYouKnow'), text: fact),
                    ],
                    if (tip != null) ...[
                      const SizedBox(height: 40),
                      _TipBox(label: _l('tip'), text: tip),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (related.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                const _Ornament(width: 130),
                const SizedBox(height: 26),
                Text(
                  _l('seeAlso'),
                  textAlign: TextAlign.center,
                  style: _serif(context,
                      size: 38, weight: FontWeight.w500, ls: 1),
                ),
                const SizedBox(height: 34),
                SizedBox(
                  height: 300,
                  child: Builder(builder: (context) {
                    final total = related.length * 220.0 +
                        (related.length - 1) * 16.0;
                    final side = ((width - total) / 2)
                        .clamp(24.0, double.infinity)
                        .toDouble();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: side),
                      itemCount: related.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) => _RelatedCard(
                        item: related[i],
                        onTap: () => onOpenRelated(related[i]),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        const SizedBox(height: 200),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CONTENU ENRICHI DE LA PAGE DÉTAIL (par lieu et par langue)
// ─────────────────────────────────────────────────────────────
const Map<String, Map<String, dynamic>> _placeExtras = {
  'mosque': {
    'related': ['old_market', 'eglise', 'hollywood'],
    'fr': {
      'duration': "30 à 45 min",
      'best': "Au crépuscule, quand l'éclairage s'allume",
      'tip': "Portez une tenue couvrante et préparez-vous à vous déchausser. Renseignez-vous sur place sur les horaires de visite, qui s'adaptent aux heures de prière.",
      'fact': "Sharm El-Sheikh n'était qu'un petit village de pêcheurs il y a quelques décennies : la mosquée, de construction récente, reprend l'élégance des grandes mosquées historiques d'Égypte.",
      'hl': [
        {'t': "Un mélange de styles", 'd': "Ses lignes empruntent aux traditions ottomane, fatimide et mamelouke, avec une profusion de détails."},
        {'t': "Des minarets illuminés", 'd': "À la nuit tombée, l'éclairage dessine la silhouette de la mosquée sur le ciel."},
        {'t': "Au cœur de la vieille ville", 'd': "Elle se visite facilement avec une balade dans les ruelles voisines."},
      ],
    },
    'en': {
      'duration': "30 to 45 minutes",
      'best': "At dusk, when the lighting comes on",
      'tip': "Wear modest clothing and be ready to remove your shoes. Ask on site about visiting hours, which adapt to prayer times.",
      'fact': "Sharm El-Sheikh was just a small fishing village a few decades ago: the mosque, recently built, echoes the elegance of Egypt's great historic mosques.",
      'hl': [
        {'t': "A blend of styles", 'd': "Its lines draw on Ottoman, Fatimid and Mamluk traditions, with a wealth of detail."},
        {'t': "Illuminated minarets", 'd': "At nightfall, the lighting traces the mosque's silhouette against the sky."},
        {'t': "In the heart of the old town", 'd': "It is easily combined with a stroll through the neighbouring lanes."},
      ],
    },
    'ar': {
      'duration': "من 30 إلى 45 دقيقة",
      'best': "عند الغسق حين تُضاء الأنوار",
      'tip': "ارتدِ ملابس محتشمة واستعد لخلع حذائك. واسأل في الموقع عن مواعيد الزيارة التي تتكيف مع أوقات الصلاة.",
      'fact': "كانت شرم الشيخ قرية صيد صغيرة قبل عقود قليلة، ويستلهم المسجد حديث البناء أناقة المساجد التاريخية الكبرى في مصر.",
      'hl': [
        {'t': "مزيج من الأنماط", 'd': "تستمد خطوطه من التقاليد العثمانية والفاطمية والمملوكية مع وفرة من التفاصيل."},
        {'t': "مآذن مضاءة", 'd': "عند حلول الليل ترسم الإضاءة صورة المسجد على صفحة السماء."},
        {'t': "في قلب المدينة القديمة", 'd': "يسهل جمع زيارته مع جولة في الأزقة المجاورة."},
      ],
    },
  },
  'eglise': {
    'related': ['mosque', 'old_market', 'saint_catherine'],
    'fr': {
      'duration': "30 à 45 min",
      'best': "En matinée, en dehors des offices",
      'tip': "Habillez-vous avec respect (épaules et genoux couverts) et renseignez-vous sur les horaires d'ouverture, qui varient selon les offices.",
      'fact': "Selon la tradition, l'Église d'Égypte aurait été fondée par saint Marc au Ier siècle ; l'Église copte orthodoxe est aujourd'hui la principale communauté chrétienne du pays.",
      'hl': [
        {'t': "Des vitraux colorés", 'd': "La lumière du jour les traverse et dessine des taches de couleurs sur les murs."},
        {'t': "Des fresques détaillées", 'd': "Les peintures murales racontent des épisodes de la tradition copte."},
        {'t': "Un havre de paix", 'd': "Un lieu calme, à l'écart de l'animation balnéaire."},
      ],
    },
    'en': {
      'duration': "30 to 45 minutes",
      'best': "Mid-morning, outside services",
      'tip': "Dress respectfully (shoulders and knees covered) and check opening hours, which vary with services.",
      'fact': "According to tradition, the Church of Egypt was founded by Saint Mark in the 1st century; the Coptic Orthodox Church is today the country's main Christian community.",
      'hl': [
        {'t': "Coloured stained glass", 'd': "Daylight passes through them and paints patches of colour on the walls."},
        {'t': "Detailed frescoes", 'd': "The wall paintings recount episodes from the Coptic tradition."},
        {'t': "A haven of peace", 'd': "A calm place, away from the seaside bustle."},
      ],
    },
    'ar': {
      'duration': "من 30 إلى 45 دقيقة",
      'best': "في الصباح بعيدًا عن أوقات القداس",
      'tip': "ارتدِ ملابس محتشمة تغطي الكتفين والركبتين، واسأل عن مواعيد الفتح التي تختلف بحسب القداسات.",
      'fact': "وفق التقليد أسس القديس مرقس الكنيسة في مصر في القرن الأول، وتُعد الكنيسة القبطية الأرثوذكسية اليوم أكبر طائفة مسيحية في البلاد.",
      'hl': [
        {'t': "زجاج ملون", 'd': "يخترقه ضوء النهار ويرسم بقعًا من الألوان على الجدران."},
        {'t': "جداريات مفصلة", 'd': "تروي اللوحات الجدارية مشاهد من التقاليد القبطية."},
        {'t': "واحة من السكينة", 'd': "مكان هادئ بعيد عن صخب الساحل."},
      ],
    },
  },
  'hollywood': {
    'related': ['old_market', 'mosque', 'red_sea'],
    'fr': {
      'duration': "2 h à 3 h",
      'best': "En soirée, pour les fontaines et les lumières",
      'tip': "L'endroit s'anime surtout à la nuit tombée : vérifiez les horaires des spectacles et les tarifs sur place avant de venir.",
      'fact': "Le soleil brille presque toute l'année à Sharm El-Sheikh, ce qui en fait une station balnéaire ouverte en toutes saisons, avec des animations tard dans la soirée.",
      'hl': [
        {'t': "Des statues géantes", 'd': "Des répliques monumentales de statues célèbres offrent un décor idéal pour les photos."},
        {'t': "Des fontaines dansantes", 'd': "Jeux d'eau et de lumière sont chorégraphiés sur de la musique."},
        {'t': "Une sortie en famille", 'd': "Une ambiance festive et ludique qui plaît aux petits comme aux grands."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the evening, for the fountains and lights",
      'tip': "The place comes alive mostly after dark: check show times and prices on site before you go.",
      'fact': "The sun shines almost all year round in Sharm El-Sheikh, making it a resort open in every season, with entertainment late into the evening.",
      'hl': [
        {'t': "Giant statues", 'd': "Monumental replicas of famous statues make an ideal backdrop for photos."},
        {'t': "Dancing fountains", 'd': "Water and light displays are choreographed to music."},
        {'t': "A family outing", 'd': "A festive, playful atmosphere that appeals to young and old."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في المساء لمشاهدة النوافير والأضواء",
      'tip': "يزدهر المكان خاصة بعد حلول الظلام، فتحقق من مواعيد العروض والأسعار في الموقع قبل المجيء.",
      'fact': "تسطع الشمس تقريبًا طوال العام في شرم الشيخ، مما يجعلها منتجعًا مفتوحًا في كل الفصول مع فعاليات تمتد حتى ساعات متأخرة.",
      'hl': [
        {'t': "تماثيل عملاقة", 'd': "نسخ ضخمة لتماثيل شهيرة تصنع خلفية مثالية للصور."},
        {'t': "نوافير راقصة", 'd': "عروض ماء وضوء منسقة على إيقاع الموسيقى."},
        {'t': "نزهة عائلية", 'd': "أجواء احتفالية ومرحة تناسب الكبار والصغار."},
      ],
    },
  },
  'old_market': {
    'related': ['mosque', 'hollywood', 'eglise'],
    'fr': {
      'duration': "1 h 30 à 2 h",
      'best': "En soirée, quand l'air se rafraîchit",
      'tip': "Marchandez avec le sourire et faites une pause pour un thé à la menthe ou un jus de canne à sucre pressé devant vous.",
      'fact': "Le mot arabe « sharm » désigne une baie ou une crique : Sharm El-Sheikh signifie littéralement « la baie du cheikh ».",
      'hl': [
        {'t': "Épices et parfums", 'd': "Les étals de safran, de cumin et d'huiles parfumées embaument les ruelles."},
        {'t': "Artisanat et souvenirs", 'd': "Lanternes, papyrus, bijoux et textiles se côtoient dans les petites boutiques."},
        {'t': "Gastronomie locale", 'd': "Restaurants et stands proposent une cuisine égyptienne généreuse."},
      ],
    },
    'en': {
      'duration': "1.5 to 2 hours",
      'best': "In the evening, as the air cools",
      'tip': "Haggle with a smile and stop for a mint tea or a sugarcane juice pressed in front of you.",
      'fact': "The Arabic word “sharm” means a bay or cove: Sharm El-Sheikh literally means “the sheikh's bay”.",
      'hl': [
        {'t': "Spices and perfumes", 'd': "Stalls of saffron, cumin and scented oils perfume the alleys."},
        {'t': "Crafts and souvenirs", 'd': "Lanterns, papyrus, jewellery and textiles sit side by side in small shops."},
        {'t': "Local cuisine", 'd': "Restaurants and stalls serve hearty Egyptian food."},
      ],
    },
    'ar': {
      'duration': "من ساعة ونصف إلى ساعتين",
      'best': "في المساء حين يبرد الهواء",
      'tip': "فاصِل بابتسامة وخذ استراحة لشرب شاي بالنعناع أو عصير قصب يُعصر أمامك.",
      'fact': "كلمة «شرم» العربية تعني الخليج الصغير أو الخور، ومعنى شرم الشيخ حرفيًا «خليج الشيخ».",
      'hl': [
        {'t': "التوابل والعطور", 'd': "تعطر أكشاك الزعفران والكمون والزيوت العطرية الأزقة."},
        {'t': "حرف وهدايا تذكارية", 'd': "تتجاور الفوانيس والبردي والمجوهرات والمنسوجات في المتاجر الصغيرة."},
        {'t': "المطبخ المحلي", 'd': "تقدم المطاعم والأكشاك أطباقًا مصرية سخية."},
      ],
    },
  },
  'saint_catherine': {
    'related': ['mount_sinai', 'dahab', 'eglise'],
    'fr': {
      'duration': "1 h 30 sur place (environ 3 h de route depuis Sharm)",
      'best': "En matinée",
      'tip': "Le monastère n'est ouvert aux visiteurs que quelques heures le matin et pas tous les jours : vérifiez avant de partir. Une tenue couvrante est exigée.",
      'fact': "Édifié au VIe siècle sous l'empereur Justinien, le monastère est inscrit à l'UNESCO depuis 2002. Il conserve l'une des plus riches bibliothèques de manuscrits anciens au monde.",
      'hl': [
        {'t': "Le Buisson ardent", 'd': "Selon la tradition, il s'agit du buisson dont parle la Bible dans l'épisode de Moïse."},
        {'t': "Une collection d'icônes", 'd': "Le monastère garde des icônes byzantines parmi les plus anciennes qui subsistent."},
        {'t': "Des manuscrits précieux", 'd': "La bibliothèque abrite des milliers de manuscrits, dont des textes très anciens."},
      ],
    },
    'en': {
      'duration': "1.5 hours on site (about 3 hours' drive from Sharm)",
      'best': "Mid-morning",
      'tip': "The monastery is open to visitors only a few hours in the morning and not every day: check before setting out. Modest dress is required.",
      'fact': "Built in the 6th century under Emperor Justinian, the monastery has been a UNESCO site since 2002. It holds one of the richest libraries of ancient manuscripts in the world.",
      'hl': [
        {'t': "The Burning Bush", 'd': "By tradition, this is the bush mentioned in the Bible in the story of Moses."},
        {'t': "A collection of icons", 'd': "The monastery keeps some of the oldest Byzantine icons that survive."},
        {'t': "Precious manuscripts", 'd': "The library houses thousands of manuscripts, including very ancient texts."},
      ],
    },
    'ar': {
      'duration': "ساعة ونصف في الموقع (نحو 3 ساعات بالسيارة من شرم الشيخ)",
      'best': "في الصباح",
      'tip': "لا يفتح الدير للزوار إلا بضع ساعات صباحًا وليس كل الأيام، فتحقق قبل الانطلاق. ويُشترط ارتداء ملابس محتشمة.",
      'fact': "شُيّد الدير في القرن السادس في عهد الإمبراطور جستنيان، وهو مدرج لدى اليونسكو منذ عام 2002. ويحتفظ بواحدة من أغنى مكتبات المخطوطات القديمة في العالم.",
      'hl': [
        {'t': "العليقة المشتعلة", 'd': "وفق التقليد هي الشجيرة التي ورد ذكرها في الكتاب المقدس في قصة موسى."},
        {'t': "مجموعة من الأيقونات", 'd': "يحتفظ الدير بأيقونات بيزنطية من أقدم ما بقي."},
        {'t': "مخطوطات نفيسة", 'd': "تضم المكتبة آلاف المخطوطات ومنها نصوص قديمة جدًا."},
      ],
    },
  },
  'mount_sinai': {
    'related': ['saint_catherine', 'dahab', 'blue_hole'],
    'fr': {
      'duration': "3 à 4 h de montée, départ en pleine nuit",
      'best': "Avant l'aube, pour le lever du soleil",
      'tip': "Emportez une lampe frontale, des vêtements chauds même en été (il fait froid au sommet), de l'eau et de bonnes chaussures. Un chameau peut vous aider sur une partie du chemin.",
      'fact': "Le sommet culmine à environ 2 285 mètres. Au dernier tronçon, on gravit environ 3 750 marches taillées dans la roche, surnommées l'escalier de la Pénitence.",
      'hl': [
        {'t': "Le chemin des chameaux", 'd': "Un sentier plus doux, emprunté à pied ou à dos de chameau, mène vers les pentes supérieures."},
        {'t': "L'escalier de la Pénitence", 'd': "Les marches de pierre conduisent au sommet dans l'obscurité, éclairées par les lampes frontales."},
        {'t': "Le lever du soleil", 'd': "La lumière embrase les cimes rocheuses et dévoile un océan de montagnes."},
      ],
    },
    'en': {
      'duration': "3 to 4 hours' climb, starting in the middle of the night",
      'best': "Before dawn, for sunrise",
      'tip': "Bring a headlamp, warm clothes even in summer (it is cold at the summit), water and good shoes. A camel can help you along part of the route.",
      'fact': "The summit peaks at about 2,285 metres. On the last stretch, you climb some 3,750 steps cut into the rock, nicknamed the Steps of Penance.",
      'hl': [
        {'t': "The camel path", 'd': "A gentler trail, walked or ridden by camel, leads toward the upper slopes."},
        {'t': "The Steps of Penance", 'd': "Stone steps lead to the summit in the dark, lit by headlamps."},
        {'t': "The sunrise", 'd': "Light sets the rocky peaks ablaze and reveals a sea of mountains."},
      ],
    },
    'ar': {
      'duration': "من 3 إلى 4 ساعات صعودًا، والانطلاق في منتصف الليل",
      'best': "قبل الفجر لمشاهدة الشروق",
      'tip': "احمل مصباحًا للرأس وملابس دافئة حتى في الصيف (فالجو بارد عند القمة) والماء وحذاءً جيدًا. ويمكن لجمل أن يساعدك في جزء من الطريق.",
      'fact': "يبلغ ارتفاع القمة نحو 2285 مترًا. وفي المرحلة الأخيرة تصعد نحو 3750 درجة منحوتة في الصخر تُعرف بسلم التوبة.",
      'hl': [
        {'t': "درب الجمال", 'd': "مسار أخف يُسلك مشيًا أو على ظهر جمل ويقود إلى المنحدرات العليا."},
        {'t': "سلم التوبة", 'd': "تقود درجات الحجر إلى القمة في الظلام على ضوء المصابيح."},
        {'t': "شروق الشمس", 'd': "يشعل الضوء القمم الصخرية ويكشف بحرًا من الجبال."},
      ],
    },
  },
  'dahab': {
    'related': ['blue_hole', 'mount_sinai', 'red_sea'],
    'fr': {
      'duration': "Une journée",
      'best': "Toute l'année, avec une préférence pour le printemps et l'automne",
      'tip': "Promenez-vous sur le front de mer, où cafés et restaurants se partagent la plage, et profitez-en pour tester le snorkeling depuis le rivage.",
      'fact': "Dahab signifie « or » en arabe, en référence au sable doré de sa baie.",
      'hl': [
        {'t': "Le front de mer d'Assalah", 'd': "Cafés, boutiques et restaurants bordent la plage dans une ambiance détendue."},
        {'t': "Plongée et snorkeling", 'd': "Les récifs se trouvent tout près du rivage, accessibles dès les premiers mètres."},
        {'t': "Vent et kitesurf", 'd': "Les conditions de vent attirent aussi les amateurs de glisse."},
      ],
    },
    'en': {
      'duration': "A day",
      'best': "Year round, with a preference for spring and autumn",
      'tip': "Stroll along the seafront, where cafés and restaurants share the beach, and take the chance to try snorkelling from the shore.",
      'fact': "Dahab means “gold” in Arabic, in reference to the golden sand of its bay.",
      'hl': [
        {'t': "The Assalah seafront", 'd': "Cafés, shops and restaurants line the beach in a relaxed atmosphere."},
        {'t': "Diving and snorkelling", 'd': "The reefs lie close to the shore, reachable from the first few metres."},
        {'t': "Wind and kitesurfing", 'd': "The wind conditions also attract watersports fans."},
      ],
    },
    'ar': {
      'duration': "يوم واحد",
      'best': "على مدار العام مع تفضيل الربيع والخريف",
      'tip': "تجول على الواجهة البحرية حيث تتقاسم المقاهي والمطاعم الشاطئ، وانتهز الفرصة لتجربة الغطس السطحي من الشاطئ.",
      'fact': "تعني «دهب» الذهب بالعربية في إشارة إلى رمال خليجها الذهبية.",
      'hl': [
        {'t': "الواجهة البحرية في أسالة", 'd': "تصطف المقاهي والمتاجر والمطاعم على الشاطئ في أجواء مريحة."},
        {'t': "الغوص والغطس السطحي", 'd': "الشعاب قريبة من الشاطئ ويمكن الوصول إليها من الأمتار الأولى."},
        {'t': "الرياح والكايت سيرفينغ", 'd': "تجذب ظروف الرياح أيضًا عشاق الرياضات المائية."},
      ],
    },
  },
  'tiran_island': {
    'related': ['red_sea', 'blue_hole', 'dahab'],
    'fr': {
      'duration': "Une journée (6 à 8 h)",
      'best': "Le matin, quand la mer est calme",
      'tip': "Les excursions partent en bateau depuis Sharm et se concentrent sur les récifs du détroit, avec plusieurs arrêts de snorkeling. Respectez les règles de protection du corail.",
      'fact': "Le détroit de Tiran, entre le golfe d'Aqaba et la mer Rouge, abrite des récifs célèbres : Jackson, Woodhouse, Thomas et Gordon.",
      'hl': [
        {'t': "Des récifs coralliens préservés", 'd': "Murs de coraux colorés et jardins sous-marins s'étendent à perte de vue."},
        {'t': "Tortues et raies", 'd': "Les eaux claires permettent d'observer une faune marine variée."},
        {'t': "Une journée en mer", 'd': "Traversée en bateau, snorkeling et déjeuner à bord rythment l'excursion."},
      ],
    },
    'en': {
      'duration': "A day (6 to 8 hours)",
      'best': "In the morning, when the sea is calm",
      'tip': "Excursions leave by boat from Sharm and focus on the reefs of the strait, with several snorkelling stops. Follow the coral protection rules.",
      'fact': "The Strait of Tiran, between the Gulf of Aqaba and the Red Sea, hosts famous reefs: Jackson, Woodhouse, Thomas and Gordon.",
      'hl': [
        {'t': "Pristine coral reefs", 'd': "Walls of coloured coral and underwater gardens stretch as far as the eye can see."},
        {'t': "Turtles and rays", 'd': "The clear waters let you observe a varied marine fauna."},
        {'t': "A day at sea", 'd': "A boat crossing, snorkelling and lunch on board punctuate the excursion."},
      ],
    },
    'ar': {
      'duration': "يوم كامل (من 6 إلى 8 ساعات)",
      'best': "في الصباح حين يكون البحر هادئًا",
      'tip': "تنطلق الرحلات بالقارب من شرم الشيخ وتركز على شعاب المضيق مع عدة محطات للغطس السطحي. التزم بقواعد حماية المرجان.",
      'fact': "يضم مضيق تيران بين خليج العقبة والبحر الأحمر شعابًا شهيرة هي جاكسون ووودهاوس وتوماس وغوردون.",
      'hl': [
        {'t': "شعاب مرجانية محفوظة", 'd': "جدران من المرجان الملون وحدائق تحت الماء تمتد على مد البصر."},
        {'t': "سلاحف وأسماك الراي", 'd': "تتيح المياه الصافية مشاهدة حياة بحرية متنوعة."},
        {'t': "يوم في البحر", 'd': "تتخلل الرحلة عبور بالقارب وغطس سطحي وغداء على متن المركب."},
      ],
    },
  },
  'red_sea': {
    'related': ['tiran_island', 'blue_hole', 'dahab'],
    'fr': {
      'duration': "Selon l'activité : de 2 h à une journée",
      'best': "Toute l'année : l'eau reste douce en toute saison",
      'tip': "Choisissez un centre de plongée agréé, ne touchez pas et ne piétinez pas le corail, et utilisez une crème solaire respectueuse des récifs.",
      'fact': "La mer Rouge abrite plus d'un millier d'espèces de poissons, dont de nombreuses ne se trouvent nulle part ailleurs. Le parc national de Ras Mohammed, à la pointe du Sinaï, est tout proche de Sharm.",
      'hl': [
        {'t': "Des eaux turquoise", 'd': "Claires et chaudes, elles se prêtent à la baignade comme au snorkeling toute l'année."},
        {'t': "Des jardins de corail", 'd': "Coraux colorés et poissons tropicaux se découvrent près du rivage."},
        {'t': "Le parc de Ras Mohammed", 'd': "Un site protégé réputé, à la pointe sud du Sinaï, à courte distance de Sharm."},
      ],
    },
    'en': {
      'duration': "Depending on the activity: from 2 hours to a full day",
      'best': "Year round: the water stays warm in every season",
      'tip': "Choose a licensed dive centre, don't touch or stand on the coral, and use reef-safe sunscreen.",
      'fact': "The Red Sea is home to more than a thousand species of fish, many found nowhere else. Ras Mohammed National Park, at the tip of the Sinai, is close to Sharm.",
      'hl': [
        {'t': "Turquoise waters", 'd': "Clear and warm, they suit swimming and snorkelling all year long."},
        {'t': "Coral gardens", 'd': "Coloured corals and tropical fish can be found close to shore."},
        {'t': "Ras Mohammed Park", 'd': "A renowned protected site at the southern tip of the Sinai, a short distance from Sharm."},
      ],
    },
    'ar': {
      'duration': "بحسب النشاط: من ساعتين إلى يوم كامل",
      'best': "على مدار العام فالماء دافئ في كل الفصول",
      'tip': "اختر مركز غوص مرخصًا، ولا تلمس المرجان ولا تقف عليه، واستخدم واقيًا من الشمس صديقًا للشعاب.",
      'fact': "يضم البحر الأحمر أكثر من ألف نوع من الأسماك، كثير منها لا يوجد في مكان آخر. ويقع متنزه رأس محمد الوطني عند طرف سيناء قرب شرم الشيخ.",
      'hl': [
        {'t': "مياه فيروزية", 'd': "صافية ودافئة، تصلح للسباحة والغطس السطحي طوال العام."},
        {'t': "حدائق مرجانية", 'd': "يمكن اكتشاف المرجان الملون والأسماك الاستوائية قرب الشاطئ."},
        {'t': "متنزه رأس محمد", 'd': "موقع محمي شهير عند الطرف الجنوبي لسيناء على مسافة قصيرة من شرم الشيخ."},
      ],
    },
  },
  'blue_hole': {
    'related': ['dahab', 'red_sea', 'tiran_island'],
    'fr': {
      'duration': "2 h à 3 h",
      'best': "Le matin, avant l'arrivée des groupes",
      'tip': "Les plongées profondes sont réservées aux plongeurs expérimentés et encadrés. Le snorkeling le long du bord est accessible à tous et donne déjà un bel aperçu du site.",
      'fact': "Le gouffre descend à plus de 100 mètres. Une arche sous-marine, vers 55 mètres de profondeur, en a fait un site célèbre mais exigeant, qui ne pardonne pas les erreurs.",
      'hl': [
        {'t': "Un gouffre sous-marin", 'd': "Le fond tombe à pic, depuis le lagon turquoise vers un bleu profond."},
        {'t': "Des récifs denses", 'd': "Les parois du gouffre sont couvertes de coraux et de poissons."},
        {'t': "Le snorkeling depuis le bord", 'd': "On entre depuis la plage et on flotte au-dessus du vide, sans plonger profond."},
      ],
    },
    'en': {
      'duration': "2 to 3 hours",
      'best': "In the morning, before the groups arrive",
      'tip': "Deep dives are reserved for experienced, supervised divers. Snorkelling along the edge is open to everyone and already gives a fine overview of the site.",
      'fact': "The sinkhole drops to more than 100 metres. An underwater arch, around 55 metres deep, has made it a famous but demanding site that does not forgive mistakes.",
      'hl': [
        {'t': "An underwater sinkhole", 'd': "The bottom falls away sharply, from the turquoise lagoon into deep blue."},
        {'t': "Dense reefs", 'd': "The walls of the sinkhole are covered in corals and fish."},
        {'t': "Snorkelling from the edge", 'd': "You enter from the beach and float above the void, without diving deep."},
      ],
    },
    'ar': {
      'duration': "من ساعتين إلى 3 ساعات",
      'best': "في الصباح قبل وصول المجموعات",
      'tip': "الغوص العميق مخصص للغواصين ذوي الخبرة وتحت الإشراف. أما الغطس السطحي على الحافة فمتاح للجميع ويمنح لمحة جيدة عن الموقع.",
      'fact': "ينحدر الثقب إلى أكثر من 100 متر. وقد جعله قوس تحت الماء على عمق نحو 55 مترًا موقعًا شهيرًا لكنه صعب لا يرحم الأخطاء.",
      'hl': [
        {'t': "حفرة عميقة تحت الماء", 'd': "ينحدر القاع فجأة من البحيرة الفيروزية إلى زرقة عميقة."},
        {'t': "شعاب كثيفة", 'd': "تغطي جدران الحفرة المرجانيات والأسماك."},
        {'t': "الغطس السطحي من الحافة", 'd': "تدخل من الشاطئ وتطفو فوق الفراغ دون غوص عميق."},
      ],
    },
  },
};