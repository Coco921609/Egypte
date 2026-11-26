import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' show ImageFilter;
import 'dart:async';
import 'dart:math' as math;

import 'nile_scene.dart';

import 'le caire.dart';
import 'alexandrie.dart';
import 'louxor.dart';
import 'assouan.dart';
import 'siwa.dart';
import 'fayoum.dart';
import 'desert.dart';
import 'sharm.dart';
import 'parametres.dart';
import 'gastronomie_page.dart';
import 'hieroglyphics_page.dart';
import 'histoire_page.dart';
import 'package:egypte/Hurghada.dart';

// ==========================================
// ACCUEIL — « Le pylône » · édition claire
//
// Inspirée de la présentation produit de la vidéo : fond crème,
// titres en serif, vignettes blanches aux angles doux, pastilles
// de couleur, bouton noir pleine largeur.
// Logique, données, traductions et API inchangées.
// ==========================================

// ==========================================
// HELPER POUR LES MOIS FAVORIS
// ==========================================
class MoisFavorisHelper {
  static List<Map<String, dynamic>> filtrerDestinations(List<Map<String, dynamic>> toutesDestinations) {
    final int moisActuel = DateTime.now().month;
    return toutesDestinations.where((Map<String, dynamic> dest) {
      if (dest['moisFavoris'] == null) return false;
      final List<int> mois = (dest['moisFavoris'] as List<dynamic>).whereType<int>().toList();
      return mois.contains(moisActuel);
    }).toList();
  }
}

// ==========================================
// TRADUCTIONS MULTILINGUES (FR, EN, AR)
// ==========================================
final Map<String, Map<String, String>> localizedAccueilText = <String, Map<String, String>>{
  'fr': <String, String>{
    'greeting': 'Bonjour',
    'welcomeEgypt': 'Bienvenue en Égypte',
    'eyebrow': 'Terre des pharaons',
    'settings': 'Paramètres',
    'recommendedMonth': 'Recommandé ce mois-ci',
    'exploreByRegion': 'Explorer par thème',
    'noDestMonth': 'Aucune recommandation pour ce mois.',
    'element': 'élément',
    'elements': 'éléments',
    'all': 'Tout',
    'discover': 'Découvrir',
    'searchHint': 'Rechercher une destination',
    'searchResults': 'Résultats',
    'noResults': 'Aucun résultat pour votre recherche.',
    'footer': 'Conçu avec passion pour les voyageurs.',
    'bestSeason': 'Meilleure saison',
    'backToTop': 'Retour en haut',
    'catHistorical': 'Villes Historiques',
    'catNature': 'Nature & Aventure',
    'catRedSea': 'Mer Rouge',
    'catDishes': 'Gastronomie',
    'catHieroglyphics': 'Hiéroglyphes Égyptiens',
    'cairo': 'Le Caire',
    'alexandria': 'Alexandrie',
    'luxor': 'Louxor',
    'aswan': 'Assouan',
    'siwa': 'Siwa',
    'fayoum': 'Fayoum',
    'desert': 'Désert',
    'sharm': 'Sharm El-Sheikh',
    'hurghada': 'Hurghada',
    'descCairo': 'Capitale vibrante, berceau des pyramides millénaires.',
    'descAlex': 'Perle de la Méditerranée.',
    'descLuxor': 'Le plus grand musée à ciel ouvert.',
    'descAswan': 'Havre de paix au bord du Nil.',
    'descSiwa': 'Oasis mystique isolée.',
    'descFayoum': 'Écosystème unique entre lacs et désert.',
    'descDesert': 'Expédition au cœur du désert blanc et noir.',
    'descSharm': 'Destination balnéaire et récifs coralliens.',
    'descHurghada': 'Station balnéaire dynamique.',
    'dishesTitle': 'Spécialités Culinaires',
    'descDishes': 'Découvrez la richesse et les saveurs de la cuisine égyptienne.',
    'hieroglyphicsTitle': 'Symboles & Écriture',
    'descHieroglyphics': 'Découvrez la langue sacrée et les symboles pharaoniques.',
    'catHistory': 'Histoire',
    'historyTitle': "5 000+ ans d'histoire",
    'descHistory': 'Année par année, de Narmer à aujourd\'hui.',
    'general': 'Général',
    'navHome': 'Accueil',
    'navMonth': 'Ce mois-ci',
    'navExplore': 'Explorer',
    'statDest': 'destinations',
    'statYears': "ans d'histoire",
    'statNile': 'km du Nil',
    'favorites': 'Favoris',
    'noFavorites': "Aucun favori pour l'instant. Touchez le cœur d'une destination.",
    'recent': 'Récemment consultés',
    'surprise': 'Surprends-moi',
    'resetPassport': "Remettre à zéro",
    'resetAsk': "Effacer tous les tampons du passeport ?",
    'cancelReset': "Annuler",
    'confirmReset': "Confirmer",
    'pointsLabel': "points",
    'toolsTitle': "Outils",
    'toolRoulette': "Roulette",
    'toolCountdown': "Compte à rebours",
    'toolCartouche': "Cartouche",
    'toolMood': "Humeur",
    'toolCalendar': "Mois idéal",
    'toolItinerary': "Itinéraire",
    'toolBreath': "Respiration",
    'toolScarab': "Scarabée",
    'toolPostcard': "Carte postale",
    'toolScratch': "Grattage",
    'toolZoom': "Zoom",
    'toolJournal': "Journal",
    'toolMotion': "Mouvement",
    'toolSort': "Tri A → Z",
    'spinWheel': "Tourner",
    'openDest': "Ouvrir",
    'pickDate': "Choisir la date",
    'daysLeft': "jours restants",
    'nameHint': "Écris ton prénom",
    'moodAdventure': "Aventure",
    'moodCulture': "Culture",
    'moodRelax': "Détente",
    'moodFood': "Gourmand",
    'idealIn': "Le meilleur mois : ",
    'dayLabel': "Jour",
    'itinDays': "Nombre de jours",
    'reroll': "Autre idée",
    'inhale': "Inspire",
    'holdBreath': "Retiens",
    'exhale': "Expire",
    'scarabScore': "Attrapés",
    'bestScore': "Record",
    'tapScarab': "Touche les scarabées !",
    'startGame': "Commencer",
    'playAgain': "Rejouer",
    'copyText': "Copier le texte",
    'copiedText': "Copié !",
    'postcardText': "Cher ami, je suis à %s, et le Nil est magnifique. Bises d'Égypte.",
    'motionOn': "Animations réduites",
    'zoomHint': "Pince pour zoomer",
    'scratchHint': "Gratte la carte",
    'newCard': "Nouvelle carte",
    'journalHint': "Tes notes de voyage…",
    'saveNote': "Enregistrer",
    'pyramidTitle': "Pyramide de visite",
    'myNote': "Ma note",
    'clear': 'Effacer',
    'remove': 'Retirer',
    'passport': 'Passeport numérique',
    'stamps': 'tampons',
    'stampHint': 'Ouvrez une destination pour la tamponner.',
    'badgeFirst': 'Premier pas',
    'badgeExplorer': 'Explorateur',
    'badgePharaoh': 'Pharaon',
    'cairoTime': "Heure d'Égypte",
    'phNight': 'Nuit sur le Nil',
    'phDawn': 'Aube dorée',
    'phDay': 'Soleil de plomb',
    'phDusk': 'Crépuscule',
    'skyCycle': 'Cycle du ciel',
    'cyDawn': 'Aube',
    'cySunrise': 'Lever',
    'cySunriseFull': 'Lever du soleil',
    'cyDay': 'Journée',
    'cyEvening': 'Soirée',
    'cySunset': 'Coucher',
    'cySunsetFull': 'Coucher du soleil',
    'cyNight': 'Nuit',
    'factTitle': 'Fait du jour',
    'tapToFlip': 'Touchez pour révéler',
    'brand': 'ÉGYPTE',
    'fact0': "La Grande Pyramide a été le plus haut édifice construit par l'homme pendant environ 3 800 ans.",
    'fact1': "Cléopâtre vécut plus près de l'alunissage que de la construction de la Grande Pyramide.",
    'fact2': "Les temples d'Abou Simbel ont été déplacés dans les années 1960 pour les sauver des eaux du lac Nasser.",
    'fact3': 'La pierre de Rosette, découverte en 1799, a permis de déchiffrer les hiéroglyphes.',
    'fact4': 'Le Nil coule vers le nord, du sud vers la Méditerranée.',
  },
  'en': <String, String>{
    'greeting': 'Hello',
    'welcomeEgypt': 'Welcome to Egypt',
    'eyebrow': 'Land of the pharaohs',
    'settings': 'Settings',
    'recommendedMonth': 'Recommended this month',
    'exploreByRegion': 'Explore by theme',
    'noDestMonth': 'No recommendations for this month.',
    'element': 'item',
    'elements': 'items',
    'all': 'All',
    'discover': 'Discover',
    'searchHint': 'Search for a destination',
    'searchResults': 'Results',
    'noResults': 'No results for your search.',
    'footer': 'Crafted with passion for travellers.',
    'bestSeason': 'Best season',
    'backToTop': 'Back to top',
    'catHistorical': 'Historical Cities',
    'catNature': 'Nature & Adventure',
    'catRedSea': 'Red Sea',
    'catDishes': 'Gastronomy',
    'catHieroglyphics': 'Egyptian Hieroglyphics',
    'cairo': 'Cairo',
    'alexandria': 'Alexandria',
    'luxor': 'Luxor',
    'aswan': 'Aswan',
    'siwa': 'Siwa',
    'fayoum': 'Fayoum',
    'desert': 'Desert',
    'sharm': 'Sharm El-Sheikh',
    'hurghada': 'Hurghada',
    'descCairo': 'Vibrant capital, cradle of millenary pyramids.',
    'descAlex': 'Pearl of the Mediterranean.',
    'descLuxor': 'Largest open-air museum.',
    'descAswan': 'Peaceful haven on the Nile.',
    'descSiwa': 'Isolated mystic oasis.',
    'descFayoum': 'Unique ecosystem between salt lakes and desert.',
    'descDesert': 'White and black desert expedition.',
    'descSharm': 'Coral reefs seaside destination.',
    'descHurghada': 'Dynamic seaside resort.',
    'dishesTitle': 'Culinary Specialties',
    'descDishes': 'Discover the rich flavors of Egyptian cuisine.',
    'hieroglyphicsTitle': 'Symbols & Writing',
    'descHieroglyphics': 'Discover the sacred language and pharaonic symbols.',
    'catHistory': 'History',
    'historyTitle': '5,000+ years of history',
    'descHistory': 'Year by year, from Narmer to today.',
    'general': 'General',
    'navHome': 'Home',
    'navMonth': 'This month',
    'navExplore': 'Explore',
    'statDest': 'destinations',
    'statYears': 'years of history',
    'statNile': 'km of the Nile',
    'favorites': 'Favorites',
    'noFavorites': 'No favourites yet. Tap the heart on a destination.',
    'recent': 'Recently viewed',
    'surprise': 'Surprise me',
    'resetPassport': "Reset",
    'resetAsk': "Clear all passport stamps?",
    'cancelReset': "Cancel",
    'confirmReset': "Confirm",
    'pointsLabel': "points",
    'toolsTitle': "Tools",
    'toolRoulette': "Roulette",
    'toolCountdown': "Countdown",
    'toolCartouche': "Cartouche",
    'toolMood': "Mood",
    'toolCalendar': "Ideal month",
    'toolItinerary': "Itinerary",
    'toolBreath': "Breathing",
    'toolScarab': "Scarab",
    'toolPostcard': "Postcard",
    'toolScratch': "Scratch card",
    'toolZoom': "Zoom",
    'toolJournal': "Journal",
    'toolMotion': "Motion",
    'toolSort': "Sort A → Z",
    'spinWheel': "Spin",
    'openDest': "Open",
    'pickDate': "Pick a date",
    'daysLeft': "days left",
    'nameHint': "Type your first name",
    'moodAdventure': "Adventure",
    'moodCulture': "Culture",
    'moodRelax': "Relax",
    'moodFood': "Food",
    'idealIn': "Best month: ",
    'dayLabel': "Day",
    'itinDays': "Number of days",
    'reroll': "Another idea",
    'inhale': "Breathe in",
    'holdBreath': "Hold",
    'exhale': "Breathe out",
    'scarabScore': "Caught",
    'bestScore': "Best",
    'tapScarab': "Tap the scarabs!",
    'startGame': "Start",
    'playAgain': "Play again",
    'copyText': "Copy text",
    'copiedText': "Copied!",
    'postcardText': "Dear friend, I am in %s, and the Nile is magnificent. Greetings from Egypt.",
    'motionOn': "Reduce motion",
    'zoomHint': "Pinch to zoom",
    'scratchHint': "Scratch the card",
    'newCard': "New card",
    'journalHint': "Your travel notes…",
    'saveNote': "Save",
    'pyramidTitle': "Visit pyramid",
    'myNote': "My note",
    'clear': 'Clear',
    'remove': 'Remove',
    'passport': 'Digital passport',
    'stamps': 'stamps',
    'stampHint': 'Open a destination to stamp it.',
    'badgeFirst': 'First step',
    'badgeExplorer': 'Explorer',
    'badgePharaoh': 'Pharaoh',
    'cairoTime': 'Egypt time',
    'phNight': 'Night on the Nile',
    'phDawn': 'Golden dawn',
    'phDay': 'Blazing sun',
    'phDusk': 'Dusk',
    'skyCycle': 'Sky cycle',
    'cyDawn': 'Dawn',
    'cySunrise': 'Sunrise',
    'cySunriseFull': 'Sunrise',
    'cyDay': 'Daytime',
    'cyEvening': 'Evening',
    'cySunset': 'Sunset',
    'cySunsetFull': 'Sunset',
    'cyNight': 'Night',
    'factTitle': 'Fact of the day',
    'tapToFlip': 'Tap to reveal',
    'brand': 'EGYPT',
    'fact0': 'The Great Pyramid was the tallest man-made structure for about 3,800 years.',
    'fact1': 'Cleopatra lived closer in time to the Moon landing than to the building of the Great Pyramid.',
    'fact2': 'The Abu Simbel temples were relocated in the 1960s to save them from the rising waters of Lake Nasser.',
    'fact3': 'The Rosetta Stone, found in 1799, made it possible to decipher hieroglyphs.',
    'fact4': 'The Nile flows north, from the south towards the Mediterranean.',
  },
  'ar': <String, String>{
    'greeting': 'مرحباً',
    'welcomeEgypt': 'مرحباً بك في مصر',
    'eyebrow': 'أرض الفراعنة',
    'settings': 'الإعدادات',
    'recommendedMonth': 'موصى به هذا الشهر',
    'exploreByRegion': 'استكشف حسب الموضوع',
    'noDestMonth': 'لا توجد توصيات لهذا الشهر.',
    'element': 'عنصر',
    'elements': 'عناصر',
    'all': 'الكل',
    'discover': 'اكتشف',
    'searchHint': 'ابحث عن وجهة',
    'searchResults': 'النتائج',
    'noResults': 'لا توجد نتائج لبحثك.',
    'footer': 'صُنع بشغف للمسافرين.',
    'bestSeason': 'أفضل موسم',
    'backToTop': 'العودة إلى الأعلى',
    'catHistorical': 'مدن تاريخية',
    'catNature': 'الطبيعة والمغامرة',
    'catRedSea': 'البحر الأحمر',
    'catDishes': 'المأكولات والتذوق',
    'catHieroglyphics': 'الهيروغليفية المصرية',
    'cairo': 'القاهرة',
    'alexandria': 'الإسكندرية',
    'luxor': 'الأقصر',
    'aswan': 'أسوان',
    'siwa': 'سيوة',
    'fayoum': 'الفيوم',
    'desert': 'الصحراء',
    'sharm': 'شرم الشيخ',
    'hurghada': 'الغردقة',
    'descCairo': 'عاصمة نابضة بالحياة، مهد الأهرامات.',
    'descAlex': 'لؤلؤة البحر الأبيض المتوسط.',
    'descLuxor': 'أكبر متحف مفتوح.',
    'descAswan': 'ملاذ هادئ على النيل.',
    'descSiwa': 'واحة صوفية منعزلة.',
    'descFayoum': 'نظام بيئي فريد.',
    'descDesert': 'رحلة الصحراء البيضاء والسوداء.',
    'descSharm': 'وجهة شعاب مرجانية.',
    'descHurghada': 'منتجع ساحلي حيوي.',
    'dishesTitle': 'الأطباق التقليدية',
    'descDishes': 'اكتشف غنى ونكهات المطبخ المصري.',
    'hieroglyphicsTitle': 'الرموز والكتابة',
    'descHieroglyphics': 'اكتشف اللغة المقدسة والرموز الفرعونية.',
    'catHistory': 'التاريخ',
    'historyTitle': 'أكثر من 5000 سنة من التاريخ',
    'descHistory': 'سنةً بسنة، من نارمر إلى اليوم.',
    'general': 'عام',
    'navHome': 'الرئيسية',
    'navMonth': 'هذا الشهر',
    'navExplore': 'استكشف',
    'statDest': 'وجهة',
    'statYears': 'سنة من التاريخ',
    'statNile': 'كم من النيل',
    'favorites': 'المفضلة',
    'noFavorites': 'لا توجد مفضلة بعد. اضغط على القلب في أي وجهة.',
    'recent': 'تمت مشاهدته مؤخراً',
    'surprise': 'فاجئني',
    'resetPassport': "إعادة الضبط",
    'resetAsk': "هل تريد مسح كل أختام جواز السفر؟",
    'cancelReset': "إلغاء",
    'confirmReset': "تأكيد",
    'pointsLabel': "نقطة",
    'toolsTitle': "أدوات",
    'toolRoulette': "عجلة الحظ",
    'toolCountdown': "العد التنازلي",
    'toolCartouche': "الخرطوشة",
    'toolMood': "المزاج",
    'toolCalendar': "الشهر المثالي",
    'toolItinerary': "خط السير",
    'toolBreath': "التنفس",
    'toolScarab': "الخنفساء",
    'toolPostcard': "بطاقة بريدية",
    'toolScratch': "بطاقة الخدش",
    'toolZoom': "تكبير",
    'toolJournal': "اليوميات",
    'toolMotion': "الحركة",
    'toolSort': "ترتيب أبجدي",
    'spinWheel': "أدِر",
    'openDest': "افتح",
    'pickDate': "اختر التاريخ",
    'daysLeft': "يومًا متبقيًا",
    'nameHint': "اكتب اسمك",
    'moodAdventure': "مغامرة",
    'moodCulture': "ثقافة",
    'moodRelax': "استرخاء",
    'moodFood': "طعام",
    'idealIn': "أفضل شهر: ",
    'dayLabel': "يوم",
    'itinDays': "عدد الأيام",
    'reroll': "فكرة أخرى",
    'inhale': "شهيق",
    'holdBreath': "احبس",
    'exhale': "زفير",
    'scarabScore': "تم الإمساك",
    'bestScore': "الأفضل",
    'tapScarab': "المس الخنافس!",
    'startGame': "ابدأ",
    'playAgain': "العب مجددًا",
    'copyText': "نسخ النص",
    'copiedText': "تم النسخ!",
    'postcardText': "عزيزي، أنا في %s، والنيل بديع. تحيات من مصر.",
    'motionOn': "تقليل الحركة",
    'zoomHint': "اقرص للتكبير",
    'scratchHint': "اكشط البطاقة",
    'newCard': "بطاقة جديدة",
    'journalHint': "ملاحظات سفرك…",
    'saveNote': "حفظ",
    'pyramidTitle': "هرم الزيارات",
    'myNote': "ملاحظتي",
    'clear': 'مسح',
    'remove': 'إزالة',
    'passport': 'جواز السفر الرقمي',
    'stamps': 'أختام',
    'stampHint': 'افتح وجهة لختمها.',
    'badgeFirst': 'الخطوة الأولى',
    'badgeExplorer': 'المستكشف',
    'badgePharaoh': 'الفرعون',
    'cairoTime': 'توقيت مصر',
    'phNight': 'ليل على النيل',
    'phDawn': 'فجر ذهبي',
    'phDay': 'شمس حارقة',
    'phDusk': 'الغسق',
    'skyCycle': 'دورة السماء',
    'cyDawn': 'الفجر',
    'cySunrise': 'الشروق',
    'cySunriseFull': 'شروق الشمس',
    'cyDay': 'النهار',
    'cyEvening': 'المساء',
    'cySunset': 'الغروب',
    'cySunsetFull': 'غروب الشمس',
    'cyNight': 'الليل',
    'factTitle': 'حقيقة اليوم',
    'tapToFlip': 'اضغط للكشف',
    'brand': 'مصر',
    'fact0': 'ظل الهرم الأكبر أعلى بناء صنعه الإنسان لنحو 3800 عام.',
    'fact1': 'عاشت كليوباترا زمنياً أقرب إلى هبوط القمر منها إلى بناء الهرم الأكبر.',
    'fact2': 'نُقلت معابد أبو سمبل في ستينيات القرن العشرين لإنقاذها من مياه بحيرة ناصر.',
    'fact3': 'ساعدت حجر رشيد، المكتشف عام 1799، على فك رموز الهيروغليفية.',
    'fact4': 'يجري نهر النيل نحو الشمال، من الجنوب إلى البحر المتوسط.',
  },
};

/// Noms des mois.
const Map<String, List<String>> _accueilMonths = <String, List<String>>{
  'fr': ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
  'en': ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  'ar': ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'],
};


/// Pyramides en filet : signature du pied de page.
class _PyramidsPainter extends CustomPainter {
  final Color color;
  const _PyramidsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double base = h - 2;

    final Paint line = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeJoin = StrokeJoin.round;
    final Paint soft = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeJoin = StrokeJoin.round;

    final Path big = Path()
      ..moveTo(w * 0.25, base)
      ..lineTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.75, base);
    canvas.drawPath(big, line);
    canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, base), soft);

    final Path left = Path()
      ..moveTo(w * 0.03, base)
      ..lineTo(w * 0.16, h * 0.56)
      ..lineTo(w * 0.29, base);
    canvas.drawPath(left, soft);

    final Path right = Path()
      ..moveTo(w * 0.71, base)
      ..lineTo(w * 0.85, h * 0.5)
      ..lineTo(w * 0.97, base);
    canvas.drawPath(right, soft);

    final Paint ground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..shader = LinearGradient(
        colors: <Color>[Colors.transparent, color.withOpacity(0.7), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawLine(Offset(0, base), Offset(w, base), ground);

    canvas.drawCircle(Offset(w * 0.8, h * 0.16), 4.5, soft);
  }

  @override
  bool shouldRepaint(covariant _PyramidsPainter old) => old.color != color;
}

// ==========================================
// ACCUEILSCREEN ET ACCUEILPAGE (API inchangée)
// ==========================================
class AccueilScreen extends StatelessWidget {
  final String? userName;
  final String? languageCode;
  final String? selectedAvatar;
  final Color? themeColor;

  const AccueilScreen({
    super.key,
    this.userName,
    this.languageCode,
    this.selectedAvatar,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AccueilPage(
      userName: userName,
      languageCode: languageCode,
      selectedAvatar: selectedAvatar,
      themeColor: themeColor,
    );
  }
}

class AccueilPage extends StatefulWidget {
  final String? userName;
  final String? languageCode;
  final String? selectedAvatar;
  final Color? themeColor;

  const AccueilPage({
    super.key,
    this.userName,
    this.languageCode,
    this.selectedAvatar,
    this.themeColor,
  });

  @override
  State<AccueilPage> createState() => _HomeState();
}

class _HomeState extends State<AccueilPage> with TickerProviderStateMixin {
  // Palette sombre : nuit profonde, surfaces bleu-encre, ivoire et or.
  static const Color _paper = Color(0xFF080B12);
  static const Color _card = Color(0xFF121924);
  static const Color _ink = Color(0xFFF2E9D8);
  static const Color _muted = Color(0xFF8D95A5);
  static const Color _line = Color(0xFF253047);
  static const Color _field = Color(0xFF1A2330);

  String _lang = 'fr';
  late Color _accent;
  late String _currentAvatar;

  final ScrollController _scroll = ScrollController();
  final PageController _featuredCtrl = PageController(viewportFraction: 0.8);
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<int> _heroIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> _featuredIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> _active = ValueNotifier<int>(0); // 0 accueil, 1 mois, 2 explorer
  final ValueNotifier<double> _progressT = ValueNotifier<double>(0);
  final ValueNotifier<double> _headerT = ValueNotifier<double>(0); // 0 transparent → 1 dépoli
  final GlobalKey _kSearch = GlobalKey();
  final GlobalKey _kMonth = GlobalKey();
  final GlobalKey _kExplore = GlobalKey();
  late final AnimationController _intro;
  late final AnimationController _heroProgress;
  late final AnimationController _ambient;
  late final AnimationController _flip;
  Timer? _clock;
  final ValueNotifier<DateTime> _clockT = ValueNotifier<DateTime>(_egyptNow());
  final _SandField _sand = _SandField();
  final ValueNotifier<int> _sandRepaint = ValueNotifier<int>(0);
  Duration _lastSand = Duration.zero;
  late final _sandTicker = createTicker(_onSandTick);
  Set<String> _stamps = <String>{};
  bool _started = false;

  String? _selectedCat;
  String _query = '';
  Set<String> _favs = <String>{};
  List<String> _recent = <String>[];
  final Map<String, String> _notes = <String, String>{};
  bool _reduce = false;
  bool _sortAz = false;
  String? _trip;
  int _scarabBest = 0;
  late final AnimationController _burst =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _confettiCtrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  bool get _ar => _lang == 'ar';

  List<BoxShadow> get _softShadow => <BoxShadow>[
    BoxShadow(
      color: Colors.black.withOpacity(0.55),
      blurRadius: 30,
      offset: const Offset(0, 14),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _lang = widget.languageCode ?? 'fr';
    _accent = widget.themeColor ?? _seasonAccent();
    _currentAvatar = widget.selectedAvatar ?? '👨🏽';

    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _heroProgress = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 36));
    _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _clock = Timer.periodic(const Duration(seconds: 30), (Timer _) {
      _clockT.value = _egyptNow();
    });
    _heroProgress.addStatusListener((AnimationStatus s) {
      if (s == AnimationStatus.completed && mounted) {
        _heroIndex.value++;
        _heroProgress.forward(from: 0);
      }
    });
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
    _scroll.addListener(_onScroll);
    _chargerParametres();
    _chargerFavoris();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      if (MediaQuery.of(context).disableAnimations || _reduce) {
        _intro.value = 1;
      } else {
        _intro.forward();
        _heroProgress.forward(from: 0);
        _ambient.repeat();
        _sandTicker.start();
      }
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _heroProgress.dispose();
    _ambient.dispose();
    _flip.dispose();
    _burst.dispose();
    _confettiCtrl.dispose();
    _clock?.cancel();
    _clockT.dispose();
    _sandTicker.dispose();
    _sandRepaint.dispose();
    _heroIndex.dispose();
    _featuredIndex.dispose();
    _active.dispose();
    _headerT.dispose();
    _progressT.dispose();
    _scroll.dispose();
    _featuredCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _chargerParametres() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedLang = prefs.getString('selected_language');
    final int? savedColorValue = prefs.getInt('user_theme_color');
    final String? savedAvatar = prefs.getString('user_avatar');

    if (!mounted) return;
    setState(() {
      if (savedLang != null && localizedAccueilText.containsKey(savedLang)) {
        _lang = savedLang;
      }
      if (widget.themeColor != null) {
        _accent = widget.themeColor!;
      } else if (savedColorValue != null) {
        _accent = Color(savedColorValue);
      }
      if (widget.selectedAvatar != null && widget.selectedAvatar!.trim().isNotEmpty) {
        _currentAvatar = widget.selectedAvatar!;
      } else if (savedAvatar != null && savedAvatar.trim().isNotEmpty) {
        _currentAvatar = savedAvatar;
      }
    });
  }

  Future<void> _changerLangue(String newLang) async {
    if (newLang == _lang) return;
    HapticFeedback.selectionClick();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLang);
    if (!mounted) return;
    setState(() => _lang = newLang);
  }

  String t(String key) {
    return localizedAccueilText[_lang]?[key] ?? localizedAccueilText['fr']![key] ?? key;
  }

  void _gererRetour() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _open(Map<String, dynamic> destination) {
    final Object? page = destination['page'];
    if (page is Widget) {
      HapticFeedback.lightImpact();
      _addRecent(destination);
      _stamp(destination);
      Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => page))
          .then((_) => _chargerParametres());
    }
  }

  void _openHistory() {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => const HistoirePage()));
  }

  void _openSettings() {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => const ParametresPage()))
        .then((_) => _chargerParametres());
  }

  void _onQuery(String v) {
    if (v.trim().isNotEmpty && _featuredIndex.value != 0) _featuredIndex.value = 0;
    setState(() => _query = v);
  }

  void _clearSearch() {
    HapticFeedback.selectionClick();
    _searchCtrl.clear();
    setState(() => _query = '');
    FocusScope.of(context).unfocus();
  }

  void _stepHero(int d) {
    HapticFeedback.selectionClick();
    _heroIndex.value += d;
    _heroProgress.forward(from: 0);
  }

  void _goHero(int k) {
    HapticFeedback.selectionClick();
    _heroIndex.value = k;
    _heroProgress.forward(from: 0);
  }

  void _stepFeatured(int d, int count) {
    if (!_featuredCtrl.hasClients) return;
    final int target = (_featuredIndex.value + d).clamp(0, count - 1).toInt();
    HapticFeedback.selectionClick();
    _featuredCtrl.animateToPage(
      target,
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
    );
  }

  /// Hauteur de la barre fixe (zone du statut + deux rangées).
  double _navHeight(MediaQueryData mq) => mq.padding.top + 52 + 40;

  Future<void> _scrollToKey(GlobalKey key, {double gap = 18}) async {
    if (!_scroll.hasClients) return;
    final BuildContext? ctx = key.currentContext;
    if (ctx == null) return;
    final RenderObject? ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached) return;
    final double dy = ro.localToGlobal(Offset.zero).dy;
    final double navH = _navHeight(MediaQuery.of(context));
    final double target = (_scroll.offset + dy - navH - gap)
        .clamp(0.0, _scroll.position.maxScrollExtent)
        .toDouble();
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _goSection(int i) async {
    HapticFeedback.selectionClick();
    if (i == 0) {
      _toTop();
    } else {
      await _scrollToKey(i == 1 ? _kMonth : _kExplore);
    }
  }

  Future<void> _goSearch() async {
    HapticFeedback.selectionClick();
    await _scrollToKey(_kSearch, gap: 28);
    if (mounted) _searchFocus.requestFocus();
  }

  void _toTop() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutCubic);
  }

  /// Met à jour l'effet de verre et le lien actif de la barre fixe.
  /// La barre n'est jamais masquée : seule son apparence change.
  void _onScroll() {
    if (!mounted || !_scroll.hasClients) return;
    final double off = _scroll.offset;
    _headerT.value = ((off - 12) / 140).clamp(0.0, 1.0).toDouble();
    final double maxExt = _scroll.hasClients ? _scroll.position.maxScrollExtent : 0.0;
    _progressT.value = maxExt > 0 ? (off / maxExt).clamp(0.0, 1.0).toDouble() : 0.0;

    final double limit = _navHeight(MediaQuery.of(context)) + 200;
    int a = 0;
    final List<GlobalKey> keys = <GlobalKey>[_kMonth, _kExplore];
    for (int i = 0; i < keys.length; i++) {
      final BuildContext? ctx = keys[i].currentContext;
      if (ctx == null) continue;
      final RenderObject? ro = ctx.findRenderObject();
      if (ro is! RenderBox || !ro.attached || !ro.hasSize) continue;
      if (ro.localToGlobal(Offset.zero).dy <= limit) a = i + 1;
    }
    if (_active.value != a) _active.value = a;
  }

  List<Map<String, dynamic>> getDestinations() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'nom': t('cairo'),
        'description': t('descCairo'),
        'image': 'assets/images/le caire.jpg',
        'couleur': const Color(0xFFD4AF37),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LeCairePage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3, 4],
      },
      <String, dynamic>{
        'nom': t('alexandria'),
        'description': t('descAlex'),
        'image': 'assets/images/alexandrie.jpg',
        'couleur': const Color(0xFF38BDF8),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AlexandriePage(),
        'moisFavoris': <int>[5, 6, 7, 8, 9, 10],
      },
      <String, dynamic>{
        'nom': t('luxor'),
        'description': t('descLuxor'),
        'image': 'assets/images/louxor.jpg',
        'couleur': const Color(0xFFF59E0B),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const LouxorPage(),
        'moisFavoris': <int>[11, 12, 1, 2],
      },
      <String, dynamic>{
        'nom': t('aswan'),
        'description': t('descAswan'),
        'image': 'assets/images/assouan.jpg',
        'couleur': const Color(0xFFEAB308),
        'region': t('catHistorical'),
        'categoryKey': 'Villes Historiques',
        'page': const AssouanPage(),
        'moisFavoris': <int>[11, 12, 1, 2],
      },
      <String, dynamic>{
        'nom': t('siwa'),
        'description': t('descSiwa'),
        'image': 'assets/images/siwa.jpeg',
        'couleur': const Color(0xFF10B981),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const SiwaPage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3],
      },
      <String, dynamic>{
        'nom': t('fayoum'),
        'description': t('descFayoum'),
        'image': 'assets/images/fayoum.jpeg',
        'couleur': const Color(0xFF34D399),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const FayoumPage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3, 4],
      },
      <String, dynamic>{
        'nom': t('desert'),
        'description': t('descDesert'),
        'image': 'assets/images/R.jpg',
        'couleur': const Color(0xFFF97316),
        'region': t('catNature'),
        'categoryKey': 'Nature & Aventure',
        'page': const DesertPage(),
        'moisFavoris': <int>[10, 11, 12, 1, 2, 3, 4],
      },
      <String, dynamic>{
        'nom': t('sharm'),
        'description': t('descSharm'),
        'image': 'assets/images/sharm.jpg',
        'couleur': const Color(0xFF0EA5E9),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const SharmElSheikhPage(),
        'moisFavoris': <int>[3, 4, 5, 9, 10, 11],
      },
      <String, dynamic>{
        'nom': t('hurghada'),
        'description': t('descHurghada'),
        'image': 'assets/images/j.jpg',
        'couleur': const Color(0xFF06B6D4),
        'region': t('catRedSea'),
        'categoryKey': 'Mer Rouge',
        'page': const HurghadaPage(),
        'moisFavoris': <int>[3, 4, 5, 9, 10, 11],
      },
      <String, dynamic>{
        'nom': t('dishesTitle'),
        'description': t('descDishes'),
        'image': 'assets/plat/f.jpg',
        'couleur': const Color(0xFFF59E0B),
        'region': t('catDishes'),
        'categoryKey': 'Gastronomie',
        'page': const GastronomiePage(),
      },
      <String, dynamic>{
        'nom': t('hieroglyphicsTitle'),
        'description': t('descHieroglyphics'),
        'image': 'assets/23.jpeg',
        'couleur': const Color(0xFFDFB15B),
        'region': t('catHieroglyphics'),
        'categoryKey': 'Hiéroglyphes Égyptiens',
        'page': const HieroglyphicsPage(),
      },
      <String, dynamic>{
        'nom': t('historyTitle'),
        'description': t('descHistory'),
        'image': HistoireGraphic.assetKey,
        'couleur': const Color(0xFFD4AF37),
        'region': t('catHistory'),
        'categoryKey': 'Histoire',
        'id': 'histoire_5000_ans',
        'page': const HistoirePage(),
      },
    ];
  }

  List<Map<String, dynamic>> _categories() => <Map<String, dynamic>>[
    <String, dynamic>{'key': 'Villes Historiques', 'label': t('catHistorical'), 'icon': Icons.account_balance_rounded},
    <String, dynamic>{'key': 'Nature & Aventure', 'label': t('catNature'), 'icon': Icons.landscape_rounded},
    <String, dynamic>{'key': 'Mer Rouge', 'label': t('catRedSea'), 'icon': Icons.waves_rounded},
    <String, dynamic>{'key': 'Gastronomie', 'label': t('catDishes'), 'icon': Icons.restaurant_rounded},
    <String, dynamic>{'key': 'Hiéroglyphes Égyptiens', 'label': t('catHieroglyphics'), 'icon': Icons.auto_awesome_rounded},
    <String, dynamic>{'key': 'Histoire', 'label': t('catHistory'), 'icon': Icons.history_edu_rounded},
  ];

  List<Map<String, dynamic>> _filtrer(List<Map<String, dynamic>> all) {
    final List<String> mots = _query.toLowerCase().trim().split(RegExp(r'\s+'));
    return all.where((Map<String, dynamic> d) {
      final String hay = '${d['nom']} ${d['description']} ${d['region']}'.toLowerCase();
      return mots.every((String m) => hay.contains(m));
    }).toList();
  }

  List<int> _favMonths(Map<String, dynamic> d) {
    final Object? raw = d['moisFavoris'];
    if (raw is List) return raw.whereType<int>().toList();
    return const <int>[];
  }

  String _num(int i) => (i + 1).toString().padLeft(2, '0');

  double _heroHeight(MediaQueryData mq) => mq.size.height.clamp(640.0, 820.0).toDouble();

  // ───────────────────────── Typographie ─────────────────────────

  TextStyle _display(double size, {Color? color, double height = 1.15, double spacing = 0}) {
    if (_ar) {
      return GoogleFonts.reemKufi(
        color: color ?? _ink,
        fontSize: size * 0.94,
        fontWeight: FontWeight.w600,
        height: height + 0.25,
      );
    }
    return GoogleFonts.marcellus(
      color: color ?? _ink,
      fontSize: size,
      height: height,
      letterSpacing: spacing,
    );
  }

  TextStyle _text(
      double size, {
        Color? color,
        FontWeight weight = FontWeight.w400,
        double height = 1.5,
        double spacing = 0,
        FontStyle? style,
      }) {
    if (_ar) {
      return GoogleFonts.cairo(
        color: color ?? _ink,
        fontSize: size * 1.06,
        fontWeight: weight,
        height: height,
      );
    }
    return GoogleFonts.jost(
      color: color ?? _ink,
      fontSize: size * 1.04,
      fontWeight: weight,
      fontStyle: style,
      height: height,
      letterSpacing: spacing,
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> all = getDestinations();
    final List<Map<String, dynamic>> month = MoisFavorisHelper.filtrerDestinations(all);
    final List<Map<String, dynamic>> pool = month.isNotEmpty ? month : all;
    final bool isRtl = _lang == 'ar';
    final bool searching = _query.trim().isNotEmpty;
    final List<Map<String, dynamic>> results = searching ? _filtrer(all) : <Map<String, dynamic>>[];

    final String greeting = (widget.userName != null && widget.userName!.trim().isNotEmpty)
        ? '${t('greeting')}, ${widget.userName!.trim()}'
        : t('greeting');

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: PopScope(
        canPop: !Navigator.canPop(context),
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) _gererRetour();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: _paper,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: _paper,
            body: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerMove: _onSandPointer,
              child: Stack(
                children: <Widget>[
                  _buildAmbient(),
                  CustomScrollView(
                    controller: _scroll,
                    primary: false,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: <Widget>[
                      SliverToBoxAdapter(child: _buildHero(pool, greeting, isRtl)),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (!searching) ...<Widget>[
                              _buildSurprise(all, isRtl),
                              _buildRecent(all),
                              _buildMarquee(all),
                              _buildStats(all),
                              _buildTools(all),
                              _buildPassport(all),
                              _buildCairoSky(),
                              _buildFact(),
                            ],
                            _buildSearchSection(),
                            if (searching)
                              _buildResults(results, isRtl)
                            else ...<Widget>[
                              _buildFeatured(month, isRtl),
                              _buildExplore(all, isRtl),
                            ],
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildHeader(),
                  _buildFab(),
                  _buildScrollBar(),
                  _buildSandLayer(),
                  _buildBurst(),
                  _buildConfetti(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Séquence d'ouverture ─────────────────────────

  /// Fait apparaître un élément pendant une fenêtre de la séquence d'ouverture.
  Widget _stage(double begin, double end, Widget child, {double dy = 22}) {
    return AnimatedBuilder(
      animation: _intro,
      child: child,
      builder: (BuildContext context, Widget? ch) {
        final double p = ((_intro.value - begin) / (end - begin)).clamp(0.0, 1.0).toDouble();
        final double v = Curves.easeOutCubic.transform(p);
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, dy * (1 - v)), child: ch),
        );
      },
    );
  }

  Widget _swap(String k, Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget w, Animation<double> a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(a),
          child: w,
        ),
      ),
      child: KeyedSubtree(key: ValueKey<String>(k), child: child),
    );
  }

  // ───────────────────────── Barre fixe (toujours visible) ─────────────────────────

  Widget _buildHeader() {
    final MediaQueryData mq = MediaQuery.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ValueListenableBuilder<double>(
        valueListenable: _headerT,
        builder: (BuildContext context, double k, Widget? _) {
          final Widget bar = DecoratedBox(
            decoration: BoxDecoration(
              color: _paper.withOpacity(0.74 + 0.24 * k),
              border: Border(
                bottom: BorderSide(color: _line.withOpacity(0.9 * k), width: 0.8),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: mq.padding.top),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _headerTop(),
                  _headerNav(),
                ],
              ),
            ),
          );

          // Le flou n'est calculé qu'une fois la barre dépolie (économie de rendu).
          if (k < 0.02) return bar;
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16 * k, sigmaY: 16 * k),
              child: bar,
            ),
          );
        },
      ),
    );
  }

  Widget _headerTop() {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toTop,
              child: Text(
                t('brand'),
                softWrap: false,
                style: _ar ? _display(19, height: 1.2) : GoogleFonts.marcellus(color: _ink, fontSize: 17, letterSpacing: 4),
              ),
            ),
            const Spacer(),
            _langPill(),
            const SizedBox(width: 10),
            _roundButton(Icons.search_rounded, _goSearch, size: 36, tooltip: t('searchHint')),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openSettings,
              child: Tooltip(message: t('settings'), child: _avatar(36)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerNav() {
    final List<String> labels = <String>[t('navHome'), t('navMonth'), t('navExplore')];
    return SizedBox(
      height: 40,
      child: ValueListenableBuilder<int>(
        valueListenable: _active,
        builder: (BuildContext context, int a, Widget? _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (int i = 0; i < labels.length; i++) _navLink(labels[i], i, a == i),
              _navHeart(),
            ],
          );
        },
      ),
    );
  }

  Widget _navHeart() {
    return Tooltip(
      message: t('favorites'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _openFavorites,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.favorite_border_rounded, size: 17, color: _muted),
              const SizedBox(height: 7),
              const SizedBox(width: 12, height: 1.5),
            ],
          ),
        ),
      ),
    );
  }

  void _openFavorites() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext _) => Directionality(
          textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
          child: _FavoritesPage(host: this),
        ),
      ),
    );
  }

  Widget _navLink(String label, int i, bool on) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goSection(i),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: _text(
                11.5,
                color: on ? _ink : _muted,
                weight: on ? FontWeight.w600 : FontWeight.w500,
                spacing: _ar ? 0 : 1.8,
                height: 1.2,
              ),
              child: Text(_ar ? label : label.toUpperCase()),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              height: 1.5,
              width: on ? 26 : 0,
              color: _ink,
            ),
          ],
        ),
      ),
    );
  }

  /// Sélecteur de langue compact. L'ordre FR · EN · AR est identique en RTL.
  Widget _langPill() {
    const List<List<String>> langs = <List<String>>[
      <String>['fr', 'FR'],
      <String>['en', 'EN'],
      <String>['ar', 'AR'],
    ];
    int index = langs.indexWhere((List<String> l) => l[0] == _lang);
    if (index < 0) index = 0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 100,
        height: 30,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _line, width: 0.8),
        ),
        child: Stack(
          children: <Widget>[
            AnimatedAlign(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              alignment: Alignment(index - 1.0, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(12.5),
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                for (final List<String> l in langs) Expanded(child: _langItem(l[1], l[0])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _langItem(String label, String code) {
    final bool selected = _lang == code;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _changerLangue(code),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: GoogleFonts.jost(
            color: selected ? _card : _ink.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  // ───────────────────────── Hero : vignette produit ─────────────────────────

  Widget _buildHero(List<Map<String, dynamic>> pool, String greeting, bool isRtl) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double h = _heroHeight(mq);
    final List<Map<String, dynamic>> slides = pool.take(5).toList();

    return ValueListenableBuilder<int>(
      valueListenable: _heroIndex,
      builder: (BuildContext context, int idx, Widget? _) {
        final int cur = idx % slides.length;
        final Map<String, dynamic> dest = slides[cur];
        final Color c = dest['couleur'] as Color;
        final bool narrow = mq.size.width < 380;

        return Listener(
          onPointerDown: _pauseHero,
          onPointerUp: _resumeHero,
          onPointerCancel: _resumeHero,
          child: GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              final double velocity = details.primaryVelocity ?? 0.0;
              if (velocity.abs() < 220) return;
              final bool next = isRtl ? velocity > 0 : velocity < 0;
              _stepHero(next ? 1 : -1);
            },
            child: SizedBox(
              height: h,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, mq.padding.top + 104, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _stage(
                      0.02,
                      0.36,
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              greeting,
                              style: _text(13, color: _muted, height: 1.2),
                            ),
                          ),
                          Text(
                            '${_num(cur)} / ${_num(slides.length - 1)}',
                            style: _text(12, color: _ink, weight: FontWeight.w600, spacing: 1.4, height: 1.2),
                          ),
                        ],
                      ),
                      dy: 12,
                    ),
                    const SizedBox(height: 14),
                    _stage(0.06, 0.50, _shimmerText(t('welcomeEgypt'), narrow ? 30 : 38), dy: 16),
                    const SizedBox(height: 16),
                    _stage(
                      0.12,
                      0.60,
                      Text(t('eyebrow'), style: _text(13, color: _muted, style: FontStyle.italic, height: 1.3)),
                      dy: 10,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _scroll,
                        builder: (BuildContext context, Widget? child) => Transform.translate(
                          offset: Offset(
                            0,
                            -((_scroll.hasClients ? _scroll.offset : 0.0).clamp(0.0, 600.0).toDouble() * 0.12),
                          ),
                          child: child,
                        ),
                        child: _stage(0.10, 0.90, _doubleTapLove(dest, _heroCard(dest, c, cur, mq)), dy: 24),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _stage(0.20, 0.70, _heroTitle(dest, narrow), dy: 14),
                    const SizedBox(height: 18),
                    _stage(0.28, 1.0, _swatches(slides, cur), dy: 8),
                    const SizedBox(height: 16),
                    _stage(0.36, 1.0, _inkButton(t('discover'), () => _open(dest), isRtl), dy: 14),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Photo dans une carte blanche, comme un produit présenté sur fond clair.
  Widget _heroCard(Map<String, dynamic> dest, Color c, int cur, MediaQueryData mq) {
    return _Pressable(
      semanticLabel: '${dest['nom']}',
      onTap: () => _open(dest),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 900),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _KenBurns(
                  key: ValueKey<String>(_idOf(dest)),
                  dir: cur.isEven ? 1 : -1,
                  child: _photo(dest['image'] as String, logicalWidth: mq.size.width - 60),
                ),
              ),
              PositionedDirectional(
                top: 12,
                start: 12,
                child: _tagPill(_regionRow('${dest['region']}', c, size: 9.5)),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: _favButton(dest, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroTitle(Map<String, dynamic> dest, bool narrow) {
    return _swap(
      '${dest['nom']}',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('${dest['nom']}', style: _display(narrow ? 30 : 34, height: 1.06)),
          const SizedBox(height: 8),
          Text('${dest['description']}', style: _text(13, color: _muted, height: 1.5)),
        ],
      ),
    );
  }

  /// Pastilles de couleur : une par destination. La pastille active affiche
  /// l'avancement du diaporama sous forme d'anneau doré.
  Widget _swatches(List<Map<String, dynamic>> slides, int cur) {
    return Row(
      children: <Widget>[
        for (int k = 0; k < slides.length; k++)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (k != cur) _goHero(k);
              },
              child: SizedBox(
                width: 28,
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    if (k == cur)
                      AnimatedBuilder(
                        animation: _heroProgress,
                        builder: (BuildContext context, Widget? _) => CustomPaint(
                          size: const Size(28, 28),
                          painter: _RingPainter(_heroProgress.value, _accent),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: k == cur ? 18 : 22,
                      height: k == cur ? 18 : 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: slides[k]['couleur'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Titre à reflet doré qui balaie les lettres en boucle.
  Widget _shimmerText(String text, double size) {
    return AnimatedBuilder(
      animation: _ambient,
      builder: (BuildContext context, Widget? _) {
        final double s = _ambient.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect r) => LinearGradient(
            begin: Alignment(-3 + 4 * s, 0),
            end: Alignment(-2 + 4 * s, 0),
            colors: <Color>[_ink, _accent, Colors.white, _accent, _ink],
            stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
          ).createShader(r),
          child: Text(text, style: _display(size, color: Colors.white, height: 1.08)),
        );
      },
    );
  }

  /// Fond animé : nébuleuses qui dérivent et étoiles qui scintillent.
  Widget _buildAmbient() {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _ambient,
            builder: (BuildContext context, Widget? _) => CustomPaint(
              painter: _AmbientPainter(_ambient.value, _accent),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  /// Noms des destinations, un par un, en entier : jamais de mot coupé.
  Widget _buildMarquee(List<Map<String, dynamic>> all) {
    final List<String> names = all.map((Map<String, dynamic> d) => '${d['nom']}').toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: _line, width: 0.8)),
      ),
      child: AnimatedBuilder(
        animation: _ambient,
        builder: (BuildContext context, Widget? _) {
          final int idx = names.isEmpty
              ? 0
              : (_ambient.value * names.length).floor().clamp(0, names.length - 1).toInt();
          final String n = names.isEmpty ? '' : names[idx];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(a),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey<int>(idx),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('✦', style: TextStyle(color: _accent, fontSize: 14)),
                    const SizedBox(width: 12),
                    Text(_ar ? n : n.toUpperCase(), style: _display(26, height: 1.0, spacing: 2)),
                    const SizedBox(width: 12),
                    Text('✦', style: TextStyle(color: _accent, fontSize: 14)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Chiffres clés : le compteur se déroule à l'affichage.
  Widget _buildStats(List<Map<String, dynamic>> all) {
    return _Reveal(
      controller: _scroll,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 56),
        child: Row(
          children: <Widget>[
            Expanded(child: _statItem(all.length, '', t('statDest'))),
            Container(width: 1, height: 56, color: _line),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openHistory,
                child: _statItem(5000, '+', t('statYears')),
              ),
            ),
            Container(width: 1, height: 56, color: _line),
            Expanded(child: _statItem(6650, '', t('statNile'))),
          ],
        ),
      ),
    );
  }

  Widget _statItem(int end, String suffix, String label) {
    return Column(
      children: <Widget>[
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: end.toDouble()),
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double v, Widget? _) => Text(
            '${_fmt(v.round())}$suffix',
            style: _display(28, color: _accent, height: 1.0),
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _ar ? label : label.toUpperCase(),
            textAlign: TextAlign.center,
            softWrap: false,
            style: _text(10, color: _muted, weight: FontWeight.w600, spacing: _ar ? 0 : 1.4, height: 1.3),
          ),
        ),
      ],
    );
  }

  String _fmt(int v) =>
      v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => ' ');

  /// Bouton flottant « retour en haut », visible après le défilement.
  Widget _buildFab() {
    final double bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      right: 20,
      bottom: 20 + bottom,
      child: ValueListenableBuilder<double>(
        valueListenable: _headerT,
        builder: (BuildContext context, double k, Widget? _) {
          final bool show = k > 0.5;
          return AnimatedOpacity(
            opacity: show ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedScale(
              scale: show ? 1 : 0.6,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: IgnorePointer(
                ignoring: !show,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: _accent.withOpacity(0.35), blurRadius: 18),
                    ],
                  ),
                  child: _roundButton(Icons.keyboard_arrow_up_rounded, _toTop, size: 50, tooltip: t('backToTop')),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────── Favoris & historique (persistés) ─────────────────────────

  Future<void> _chargerFavoris() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _favs = (prefs.getStringList('accueil_favs') ?? <String>[]).toSet();
        _recent = prefs.getStringList('accueil_recent') ?? <String>[];
        _stamps = (prefs.getStringList('accueil_stamps') ?? <String>[]).toSet();
        _sortAz = _prefFirst(prefs, 'accueil_sort', '0') == '1';
        _reduce = _prefFirst(prefs, 'accueil_reduce', '0') == '1';
        final String tripV = _prefFirst(prefs, 'accueil_trip', '');
        _trip = tripV.isEmpty ? null : tripV;
        _scarabBest = int.tryParse(_prefFirst(prefs, 'accueil_scarab_best', '0')) ?? 0;
        _notes.clear();
        for (final String k in prefs.getKeys()) {
          if (!k.startsWith('note|')) continue;
          final String? v = prefs.getString(k);
          if (v != null && v.trim().isNotEmpty) _notes[k.substring(5)] = v;
        }
      });
      if (_reduce) _applyReduce();
    } catch (_) {}
  }

  Future<void> _saveList(String key, List<String> values) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, values);
    } catch (_) {}
  }

  bool _isFav(Map<String, dynamic> d) => _favs.contains(_idOf(d));

  void _toggleFav(Map<String, dynamic> d) {
    final String id = _idOf(d);
    HapticFeedback.mediumImpact();
    setState(() {
      if (!_favs.add(id)) _favs.remove(id);
    });
    _saveList('accueil_favs', _favs.toList());
  }

  void _addRecent(Map<String, dynamic> d) {
    final String id = _idOf(d);
    _recent = <String>[id, ..._recent.where((String e) => e != id)].take(6).toList();
    _saveList('accueil_recent', _recent);
  }

  // ───────────────────────── Interactions du hero ─────────────────────────

  /// Le diaporama se met en pause tant que le doigt reste posé.
  void _pauseHero(PointerDownEvent _) => _heroProgress.stop();

  void _resumeHero(PointerEvent _) {
    if (_heroProgress.value < 1 && !_heroProgress.isAnimating) _heroProgress.forward();
  }

  // ───────────────────────── Composants v2 ─────────────────────────

  /// Cœur animé : rebondit à chaque changement d'état.
  Widget _favButton(Map<String, dynamic> d, {double size = 36}) {
    final bool on = _isFav(d);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleFav(d),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _card.withOpacity(0.9),
          border: Border.all(color: on ? _accent : _line, width: 0.9),
        ),
        child: TweenAnimationBuilder<double>(
          key: ValueKey<bool>(on),
          tween: Tween<double>(begin: on ? 0.4 : 1.2, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (BuildContext context, double v, Widget? _) => Transform.scale(
            scale: v,
            child: Icon(
              on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: size * 0.5,
              color: on ? _accent : _ink,
            ),
          ),
        ),
      ),
    );
  }

  /// Barre de progression du défilement, sous la barre fixe.
  Widget _buildScrollBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: ValueListenableBuilder<double>(
          valueListenable: _progressT,
          builder: (BuildContext context, double v, Widget? _) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: v,
              child: Container(height: 2, color: _accent),
            ),
          ),
        ),
      ),
    );
  }

  /// Bouton « Surprends-moi » : ouvre une destination au hasard.
  Widget _buildSurprise(List<Map<String, dynamic>> all, bool isRtl) {
    return _Reveal(
      controller: _scroll,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 56),
        child: _Pressable(
          semanticLabel: t('surprise'),
          onTap: () {
            if (all.isEmpty) return;
            HapticFeedback.mediumImpact();
            _open(all[math.Random().nextInt(all.length)]);
          },
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: <Color>[_card, _accent.withOpacity(0.22), _card]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accent.withOpacity(0.45), width: 0.9),
            ),
            child: Row(
              children: <Widget>[
                AnimatedBuilder(
                  animation: _ambient,
                  builder: (BuildContext context, Widget? child) =>
                      Transform.rotate(angle: _ambient.value * 2 * math.pi * 6, child: child),
                  child: Icon(Icons.auto_awesome_rounded, color: _accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(t('surprise'), style: _display(19, height: 1.1))),
                _arrowDot(isRtl, size: 42),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Liste des destinations ajoutées en favori (filtre « Favoris » de l'explorateur).
  Widget _favBlock(List<Map<String, dynamic>> all, bool isRtl) {
    final List<Map<String, dynamic>> items = _sorted(all.where((Map<String, dynamic> d) => _isFav(d)).toList());
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
        child: Text(t('noFavorites'), style: _text(14.5, color: _muted, height: 1.5)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: _listingCard(items[i], i, isRtl),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── Récents : suppression ─────────────────────────

  void _removeRecent(String id) {
    HapticFeedback.selectionClick();
    setState(() => _recent = _recent.where((String e) => e != id).toList());
    _saveList('accueil_recent', _recent);
  }

  void _clearRecent() {
    HapticFeedback.mediumImpact();
    setState(() => _recent = <String>[]);
    _saveList('accueil_recent', _recent);
  }

  /// Carrousel des destinations récemment ouvertes, avec suppression individuelle et globale.
  Widget _buildRecent(List<Map<String, dynamic>> all) {
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
    for (final String id in _recent) {
      for (final Map<String, dynamic> d in all) {
        if (_idOf(d) == id) items.add(d);
      }
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return _Reveal(
      controller: _scroll,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: <Widget>[
                  Expanded(child: _label(t('recent'))),
                  _Pressable(
                    semanticLabel: t('clear'),
                    onTap: _clearRecent,
                    child: Text(
                      _ar ? t('clear') : t('clear').toUpperCase(),
                      style: _text(11, color: _accent, weight: FontWeight.w600, spacing: _ar ? 0 : 1.6, height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 150,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (Widget child, Animation<double> a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(scale: Tween<double>(begin: 0.92, end: 1).animate(a), child: child),
                ),
                child: ListView.separated(
                  key: ValueKey<String>(_recent.join('|')),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int i) => const SizedBox(width: 12),
                  itemBuilder: (BuildContext context, int i) => _recentCard(items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentCard(Map<String, dynamic> d) {
    final String id = _idOf(d);
    return _Pressable(
      semanticLabel: '${d['nom']}',
      onTap: () => _open(d),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SizedBox(
            width: 132,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 96,
                    width: 132,
                    child: _photo('${d['image']}', logicalWidth: 132),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${d['nom']}',
                  style: _display(14, height: 1.1),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 6,
            end: 6,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _removeRecent(id),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _card.withOpacity(0.92),
                  border: Border.all(color: _line, width: 0.8),
                ),
                child: Icon(Icons.close_rounded, size: 14, color: _ink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Passeport numérique ─────────────────────────

  void _stamp(Map<String, dynamic> d) {
    final String id = _idOf(d);
    if (_stamps.add(id)) {
      _saveList('accueil_stamps', _stamps.toList());
      if (_stamps.length == 1 || _stamps.length == 5) _celebrate();
    }
  }

  Widget _badge(String label, bool on) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: on ? _accent : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: on ? _accent : _line, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(on ? Icons.check_circle_rounded : Icons.lock_outline_rounded, size: 14, color: on ? _card : _muted),
          const SizedBox(width: 6),
          Text(label, style: _text(12, color: on ? _card : _muted, weight: FontWeight.w600, height: 1.2)),
        ],
      ),
    );
  }

  /// Tampon : tombe avec un rebond quand la destination est visitée.
  Widget _stampWidget(Map<String, dynamic> d) {
    final String id = _idOf(d);
    final bool got = _stamps.contains(id);
    final String nom = '${d['nom']}';
    final String initial = nom.isEmpty ? '?' : nom.substring(0, 1).toUpperCase();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(d),
      child: SizedBox(
        width: 80,
        child: Column(
          children: <Widget>[
            TweenAnimationBuilder<double>(
              key: ValueKey<String>('stamp_${id}_$got'),
              tween: Tween<double>(begin: got ? 1.9 : 1.0, end: 1.0),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutBack,
              builder: (BuildContext context, double v, Widget? _) => Transform.scale(
                scale: v,
                child: Transform.rotate(
                  angle: got ? -0.18 : 0,
                  child: Opacity(
                    opacity: got ? 1 : 0.5,
                    child: Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: got ? _accent.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(color: got ? _accent : _line, width: got ? 2.2 : 1.2),
                      ),
                      child: Text(
                        initial,
                        style: _display(20, color: got ? _accent : _muted, height: 1.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nom,
              textAlign: TextAlign.center,
              style: _text(10, color: got ? _ink : _muted, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassport(List<Map<String, dynamic>> all) {
    final int total = all.length;
    final int got = all.where((Map<String, dynamic> d) => _stamps.contains(_idOf(d))).length;
    final double ratio = total == 0 ? 0.0 : got / total;

    return _Reveal(
      controller: _scroll,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 40, 22, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _label(t('passport'), color: _accent)),
                Text(
                  '$got / $total ${t('stamps')}',
                  style: _text(12, color: _muted, weight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 4,
                child: Stack(
                  children: <Widget>[
                    Container(color: _line),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: ratio),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (BuildContext context, double v, Widget? _) => FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: v,
                        child: Container(color: _accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 64,
                  height: 56,
                  child: CustomPaint(painter: _PassportPyramidPainter(ratio, _accent, _line)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label(t('pyramidTitle'), color: _muted),
                      const SizedBox(height: 6),
                      Text('$_points ${t('pointsLabel')}', style: _display(20, color: _accent)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Grille des tampons : colonnes réparties sur toute la largeur,
            // chaque tampon centré dans sa cellule (plus de vide à droite).
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) {
                const double stampWidth = 80;
                const double minGap = 14;
                final int cols = math.max(
                  1,
                  ((box.maxWidth + minGap) / (stampWidth + minGap)).floor(),
                );
                final double cell = box.maxWidth / cols;
                return Wrap(
                  spacing: 0,
                  runSpacing: 18,
                  children: <Widget>[
                    for (final Map<String, dynamic> d in all)
                      SizedBox(
                        width: cell,
                        child: Center(child: _stampWidget(d)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _badge(t('badgeFirst'), got >= 1),
                _badge(t('badgeExplorer'), got >= 5),
                _badge(t('badgePharaoh'), total > 0 && got >= total),
              ],
            ),
            if (got > 0) ...<Widget>[
              const SizedBox(height: 18),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _confirmReset,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      t('resetPassport'),
                      style: _text(12.5, color: _muted, weight: FontWeight.w600, style: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            ],
            if (got == 0) ...<Widget>[
              const SizedBox(height: 14),
              Text(t('stampHint'), style: _text(13, color: _muted, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Heure au Caire ─────────────────────────

  String _two(int v) => v.toString().padLeft(2, '0');

  String _phaseLabel(double h) {
    if (h < 5 || h >= 20) return t('phNight');
    if (h < 8) return t('phDawn');
    if (h < 17) return t('phDay');
    return t('phDusk');
  }

  /// Lever / coucher du soleil au Caire, en minutes depuis minuit (heure d'Égypte).
  List<double> _sunTimes(DateTime now) {
    const double lat = 30.0444 * math.pi / 180;
    const double lon = 31.2357;
    final int n = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(now.year, 1, 1))
        .inDays +
        1;
    final double g = 2 * math.pi / 365 * (n - 1);
    final double eq = 229.18 *
        (0.000075 +
            0.001868 * math.cos(g) -
            0.032077 * math.sin(g) -
            0.014615 * math.cos(2 * g) -
            0.040849 * math.sin(2 * g));
    final double decl = 0.006918 -
        0.399912 * math.cos(g) +
        0.070257 * math.sin(g) -
        0.006758 * math.cos(2 * g) +
        0.000907 * math.sin(2 * g) -
        0.002697 * math.cos(3 * g) +
        0.00148 * math.sin(3 * g);
    const double zenith = 90.833 * math.pi / 180;
    final double cosHa = (math.cos(zenith) / (math.cos(lat) * math.cos(decl)) -
        math.tan(lat) * math.tan(decl))
        .clamp(-1.0, 1.0)
        .toDouble();
    final double ha = math.acos(cosHa) * 180 / math.pi;
    final int offMin =
        (_egyptNow().difference(DateTime.now().toUtc()).inMinutes / 60).round() * 60;
    return <double>[
      720 - 4 * (lon + ha) - eq + offMin,
      720 - 4 * (lon - ha) - eq + offMin,
    ];
  }

  String _hm(double minutes) {
    final int v = minutes.round() % 1440;
    return '${_two(v ~/ 60)}:${_two(v % 60)}';
  }

  /// Cycle du ciel : aube, lever, journée, soirée, coucher, nuit.
  Widget _buildSkyCycle(DateTime now) {
    final List<double> sun = _sunTimes(now);
    final double rise = sun[0];
    final double sunset = sun[1];
    final double m = now.hour * 60 + now.minute.toDouble();
    final List<double> starts = <double>[
      rise - 60,
      rise - 15,
      rise + 45,
      sunset - 120,
      sunset - 15,
      sunset + 45,
    ];
    int current = 5;
    for (int i = 0; i < 5; i++) {
      if (m >= starts[i] && m < starts[i + 1]) current = i;
    }
    final List<String> names = <String>[
      t('cyDawn'),
      t('cySunrise'),
      t('cyDay'),
      t('cyEvening'),
      t('cySunset'),
      t('cyNight'),
    ];
    const List<IconData> icons = <IconData>[
      Icons.brightness_low_rounded,
      Icons.wb_twilight_rounded,
      Icons.wb_sunny_rounded,
      Icons.brightness_medium_rounded,
      Icons.wb_twilight_rounded,
      Icons.nightlight_round,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _label(t('skyCycle'), color: _muted),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < 6; i++)
              Expanded(
                child: Column(
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == current ? _accent.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: i == current ? _accent : _line,
                          width: i == current ? 2.0 : 1.0,
                        ),
                      ),
                      child: Icon(icons[i], size: 18, color: i == current ? _accent : _muted),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        names[i],
                        softWrap: false,
                        style: _text(
                          10.5,
                          color: i == current ? _ink : _muted,
                          weight: i == current ? FontWeight.w600 : FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(_hm(starts[i]), style: _text(10, color: _muted, height: 1.2)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '${t('cySunriseFull')} ${_hm(rise)} · ${t('cySunsetFull')} ${_hm(sunset)}',
          textAlign: TextAlign.center,
          style: _text(12.5, color: _muted, weight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCairoSky() {
    return _Reveal(
      controller: _scroll,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 56),
        child: ValueListenableBuilder<DateTime>(
          valueListenable: _clockT,
          builder: (BuildContext context, DateTime now, Widget? _) {
            final double h = now.hour + now.minute / 60;
            final Widget card = ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: SizedBox(
                height: 214,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    NileSceneView(sky: nileSkyFraction(now)),
                    // Voile sombre en bas pour bien lire l'heure
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[Color(0x33000000), Color(0x00000000), Color(0xB3000000)],
                              stops: <double>[0, 0.45, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 16,
                      start: 18,
                      child: _label(t('cairoTime'), color: Colors.white.withOpacity(0.85)),
                    ),
                    PositionedDirectional(
                      start: 18,
                      bottom: 14,
                      child: Text(
                        '${_two(now.hour)}:${_two(now.minute)}',
                        style: GoogleFonts.marcellus(color: Colors.white, fontSize: 40, height: 1.0),
                      ),
                    ),
                    PositionedDirectional(
                      end: 18,
                      top: 16,
                      child: Text(
                        _phaseLabel(h),
                        style: _text(12, color: Colors.white.withOpacity(0.9), style: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                card,
                const SizedBox(height: 22),
                _buildSkyCycle(now),
              ],
            );
          },
        ),
      ),
    );
  }

  // ───────────────────────── Fait du jour (carte à retourner) ─────────────────────────

  Widget _buildFact() {
    final int idx = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays % 5;
    return _Reveal(
      controller: _scroll,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 56),
        child: _Pressable(
          semanticLabel: t('factTitle'),
          onTap: () {
            HapticFeedback.selectionClick();
            if (_flip.isCompleted) {
              _flip.reverse();
            } else {
              _flip.forward();
            }
          },
          child: AnimatedBuilder(
            animation: _flip,
            builder: (BuildContext context, Widget? _) {
              final double a = Curves.easeInOutCubic.transform(_flip.value) * math.pi;
              final bool back = a > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(a),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: back ? null : _card,
                    gradient: back ? LinearGradient(colors: <Color>[_card, _accent.withOpacity(0.22)]) : null,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: _accent.withOpacity(0.45), width: 0.9),
                  ),
                  child: back
                      ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label(t('factTitle'), color: _accent),
                        const SizedBox(height: 14),
                        Text(t('fact$idx'), style: _display(19, height: 1.35)),
                      ],
                    ),
                  )
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.auto_awesome_rounded, color: _accent, size: 30),
                      const SizedBox(height: 12),
                      Text(t('factTitle'), style: _display(22)),
                      const SizedBox(height: 8),
                      Text(t('tapToFlip'), style: _text(12, color: _muted, style: FontStyle.italic)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Vent du désert (sable interactif) ─────────────────────────

  void _onSandTick(Duration elapsed) {
    final double dt = ((elapsed - _lastSand).inMicroseconds / 1e6).clamp(0.0, 0.05).toDouble();
    _lastSand = elapsed;
    _sand.step(dt);
    _sandRepaint.value++;
  }

  /// Le doigt pousse les grains de sable : le vent les soulève.
  void _onSandPointer(PointerMoveEvent e) {
    final Size s = MediaQuery.of(context).size;
    _sand.push(e.localPosition.dx, e.localPosition.dy, e.delta.dx, e.delta.dy, s.width, s.height);
  }

  Widget _buildSandLayer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _SandPainter(_sand, _accent, _sandRepaint),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Éléments de titrage ─────────────────────────

  // ───────────────────────── Passeport : remise à zéro, points ─────────────────────────

  int get _points => _stamps.length * 10 + _favs.length * 2 + _notes.length * 3;

  Future<void> _confirmReset() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: _card,
        title: Text(t('resetAsk'), style: _display(20, height: 1.25)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('cancelReset'), style: _text(14, color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('confirmReset'), style: _text(14, color: _accent, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _stamps = <String>{});
    _saveList('accueil_stamps', <String>[]);
  }

  /// Couleur d'accent selon la saison en Égypte (remplacée si l'utilisateur choisit la sienne).
  Color _seasonAccent() {
    final int m = _egyptNow().month;
    if (m >= 3 && m <= 5) return const Color(0xFFE0A96D);
    if (m >= 6 && m <= 8) return const Color(0xFFF2C14E);
    if (m >= 9 && m <= 11) return const Color(0xFFC9825B);
    return const Color(0xFF9CC5D8);
  }

  // ───────────────────────── Réglages : tri, mouvement, date ─────────────────────────

  List<Map<String, dynamic>> _sorted(List<Map<String, dynamic>> items) {
    if (!_sortAz) return items;
    final List<Map<String, dynamic>> copy = List<Map<String, dynamic>>.of(items);
    copy.sort((Map<String, dynamic> a, Map<String, dynamic> b) => '${a['nom']}'.compareTo('${b['nom']}'));
    return copy;
  }

  void _setSortAz(bool v) {
    HapticFeedback.selectionClick();
    setState(() => _sortAz = v);
    _saveList('accueil_sort', <String>[v ? '1' : '0']);
  }

  void _setReduce(bool v) {
    HapticFeedback.selectionClick();
    setState(() => _reduce = v);
    _saveList('accueil_reduce', <String>[v ? '1' : '0']);
    _applyReduce();
  }

  /// Mouvement réduit : arrête le diaporama, le sable et les animations de fond.
  void _applyReduce() {
    if (_reduce) {
      _ambient.stop();
      _sandTicker.stop();
      _heroProgress.stop();
    } else if (_started) {
      _ambient.repeat();
      _sandTicker.start();
      _heroProgress.forward();
    }
  }

  void _setTrip(DateTime? date) {
    final String? iso = date == null ? null : '${date.year}-${_two(date.month)}-${_two(date.day)}';
    setState(() => _trip = iso);
    _saveList('accueil_trip', iso == null ? <String>[] : <String>[iso]);
  }

  int? _daysLeft() {
    final String? iso = _trip;
    if (iso == null) return null;
    final DateTime? d = DateTime.tryParse(iso);
    if (d == null) return null;
    final DateTime now = DateTime.now();
    return d.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  // ───────────────────────── Amour, confettis, aperçu ─────────────────────────

  String _idOf(Map<String, dynamic> d) => '${d['id'] ?? d['image']}';

  /// Double-tap sur le hero : ajoute aux favoris, avec un cœur qui s'envole.
  void _love(Map<String, dynamic> d) {
    HapticFeedback.mediumImpact();
    _burst.forward(from: 0);
    if (_favs.contains(_idOf(d))) return;
    setState(() {
      _favs.add(_idOf(d));
    });
    _saveList('accueil_favs', _favs.toList());
  }

  Widget _doubleTapLove(Map<String, dynamic> d, Widget child) {
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () => _love(d),
          ),
        ),
      ],
    );
  }

  Widget _buildBurst() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _burst,
          builder: (BuildContext context, Widget? _) {
            final double v = _burst.value;
            if (v <= 0 || v >= 1) return const SizedBox.shrink();
            return Align(
              alignment: const Alignment(0, -0.25),
              child: Transform.translate(
                offset: Offset(0, -90 * v),
                child: Opacity(
                  opacity: (1 - v).clamp(0.0, 1.0).toDouble(),
                  child: Transform.scale(
                    scale: 0.6 + 0.9 * v,
                    child: Icon(Icons.favorite_rounded, color: _accent, size: 72),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _celebrate() {
    HapticFeedback.heavyImpact();
    _confettiCtrl.forward(from: 0);
  }

  Widget _buildConfetti() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _confettiCtrl,
          builder: (BuildContext context, Widget? _) => CustomPaint(
            painter: _ConfettiPainter(_confettiCtrl.value, _accent),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  /// Appui long sur une carte : aperçu, note personnelle et bouton d'ouverture.
  void _preview(Map<String, dynamic> d) {
    final String id = _idOf(d);
    _sheet('${d['nom']}', (BuildContext ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('${d['description']}', style: _text(15, color: _ink, height: 1.6)),
        if ((_notes[id] ?? '').isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          _label(t('myNote'), color: _accent),
          const SizedBox(height: 8),
          Text(_notes[id]!, style: _text(14, color: _muted, style: FontStyle.italic, height: 1.5)),
        ],
        const SizedBox(height: 22),
        _inkButton(t('openDest'), () {
          Navigator.pop(ctx);
          _open(d);
        }, _ar),
      ],
    ));
  }

  // ───────────────────────── Notes et record du scarabée ─────────────────────────

  void _setNote(String id, String text) {
    final String v = text.trim();
    setState(() {
      if (v.isEmpty) {
        _notes.remove(id);
      } else {
        _notes[id] = v;
      }
    });
    _saveNote(id, v);
  }

  Future<void> _saveNote(String id, String v) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (v.isEmpty) {
        await prefs.remove('note|$id');
      } else {
        await prefs.setString('note|$id', v);
      }
    } catch (_) {}
  }

  void _setScarabBest(int v) {
    setState(() => _scarabBest = v);
    _saveList('accueil_scarab_best', <String>['$v']);
  }

  // ───────────────────────── Feuille d'outil & grille des 14 outils ─────────────────────────

  void _sheet(String title, Widget Function(BuildContext) content) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: _line, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 18),
              _label(title, color: _accent),
              const SizedBox(height: 18),
              content(ctx),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTools(List<Map<String, dynamic>> all) {
    final double half = (MediaQuery.of(context).size.width - 44 - 12) / 2;
    final List<Widget> tiles = <Widget>[
      _toolTile(Icons.casino_rounded, t('toolRoulette'), half,
              () => _sheet(t('toolRoulette'), (BuildContext _) => _RouletteTool(this, all))),
      _toolTile(Icons.event_rounded, t('toolCountdown'), half,
              () => _sheet(t('toolCountdown'), (BuildContext _) => _CountdownTool(this))),
      _toolTile(Icons.edit_rounded, t('toolCartouche'), half,
              () => _sheet(t('toolCartouche'), (BuildContext _) => _CartoucheTool(this))),
      _toolTile(Icons.mood_rounded, t('toolMood'), half,
              () => _sheet(t('toolMood'), (BuildContext _) => _MoodTool(this, all))),
      _toolTile(Icons.calendar_month_rounded, t('toolCalendar'), half,
              () => _sheet(t('toolCalendar'), (BuildContext _) => _CalendarTool(this, all))),
      _toolTile(Icons.route_rounded, t('toolItinerary'), half,
              () => _sheet(t('toolItinerary'), (BuildContext _) => _ItineraryTool(this, all))),
      _toolTile(Icons.self_improvement_rounded, t('toolBreath'), half,
              () => _sheet(t('toolBreath'), (BuildContext _) => _BreathTool(this))),
      _toolTile(Icons.pest_control_rounded, t('toolScarab'), half,
              () => _sheet(t('toolScarab'), (BuildContext _) => _ScarabTool(this))),
      _toolTile(Icons.mail_outline_rounded, t('toolPostcard'), half,
              () => _sheet(t('toolPostcard'), (BuildContext _) => _PostcardTool(this, all))),
      _toolTile(Icons.auto_fix_high_rounded, t('toolScratch'), half,
              () => _sheet(t('toolScratch'), (BuildContext _) => _ScratchTool(this, all))),
      _toolTile(Icons.zoom_in_rounded, t('toolZoom'), half,
              () => _sheet(t('toolZoom'), (BuildContext _) => _ZoomTool(this, all))),
      _toolTile(Icons.menu_book_rounded, t('toolJournal'), half,
              () => _sheet(t('toolJournal'), (BuildContext _) => _JournalTool(this, all))),
      _toolTile(Icons.animation_rounded, t('toolMotion'), half,
              () => _sheet(t('toolMotion'), (BuildContext _) => _SwitchTool(this,
              label: t('motionOn'), value: _reduce, onChanged: _setReduce))),
      _toolTile(Icons.sort_by_alpha_rounded, t('toolSort'), half,
              () => _sheet(t('toolSort'), (BuildContext _) => _SwitchTool(this,
              label: t('toolSort'), value: _sortAz, onChanged: _setSortAz))),
    ];
    return _Reveal(
      controller: _scroll,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _label(t('toolsTitle'), color: _accent),
            const SizedBox(height: 18),
            Wrap(spacing: 12, runSpacing: 12, children: tiles),
          ],
        ),
      ),
    );
  }

  Widget _toolTile(IconData icon, String label, double w, VoidCallback onTap) {
    return SizedBox(
      width: w,
      child: _Pressable(
        semanticLabel: label,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 74),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _line, width: 0.9),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: _accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: _text(13, color: _ink, weight: FontWeight.w600, height: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {Color? color}) {
    return Text(
      _ar ? text : text.toUpperCase(),
      style: _text(11, color: color ?? _muted, weight: FontWeight.w600, spacing: _ar ? 0 : 1.8, height: 1.2),
    );
  }

  /// En-tête de section : surtitre, titre serif, filet. Apparaît au défilement.
  Widget _chapterHead(String eyebrow, String title, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
      child: _Reveal(
        controller: _scroll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _label(eyebrow),
            const SizedBox(height: 10),
            Text(title, style: _display(34, height: 1.08)),
            const SizedBox(height: 18),
            Container(height: 1, color: _line),
          ],
        ),
      ),
    );
  }

  /// Étiquette blanche arrondie, posée sur une photo.
  Widget _tagPill(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _line, width: 0.8),
      ),
      child: child,
    );
  }

  // ───────────────────────── Recherche ─────────────────────────

  Widget _buildSearchSection() {
    final bool focused = _searchFocus.hasFocus;
    return Padding(
      key: _kSearch,
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 44),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: focused ? _card : _field,
          borderRadius: BorderRadius.circular(29),
          border: Border.all(color: focused ? _ink : Colors.transparent, width: 1),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search_rounded, color: _ink, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: _onQuery,
                onSubmitted: (String _) => FocusScope.of(context).unfocus(),
                textInputAction: TextInputAction.search,
                cursorColor: _ink,
                style: _text(16, color: _ink, height: 1.2),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: t('searchHint'),
                  hintStyle: _text(16, color: _muted, height: 1.2),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clearSearch,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _card,
                  ),
                  child: const Icon(Icons.close_rounded, color: _ink, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Recommandé ce mois-ci ─────────────────────────

  Widget _buildFeatured(List<Map<String, dynamic>> month, bool isRtl) {
    final DateTime now = DateTime.now();
    final List<String> names = _accueilMonths[_lang] ?? _accueilMonths['fr']!;
    final String monthLabel = '${names[now.month - 1]} ${now.year}';

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _chapterHead(monthLabel, t('recommendedMonth'), key: _kMonth),
          if (month.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(t('noDestMonth'), style: _text(14, color: _muted)),
            )
          else ...<Widget>[
            SizedBox(
              height: 470,
              child: PageView.builder(
                controller: _featuredCtrl,
                physics: const BouncingScrollPhysics(),
                itemCount: month.length,
                onPageChanged: (int idx) {
                  HapticFeedback.selectionClick();
                  _featuredIndex.value = idx;
                },
                itemBuilder: (BuildContext context, int idx) {
                  return AnimatedBuilder(
                    animation: _featuredCtrl,
                    builder: (BuildContext context, Widget? _) {
                      double page = _featuredIndex.value.toDouble();
                      if (_featuredCtrl.hasClients && _featuredCtrl.position.haveDimensions) {
                        page = _featuredCtrl.page ?? page;
                      }
                      final double delta = (idx - page).clamp(-1.5, 1.5).toDouble();
                      final double dist = delta.abs().clamp(0.0, 1.0).toDouble();
                      return Transform.scale(
                        scale: 1 - dist * 0.05,
                        child: Opacity(
                          opacity: 1 - dist * 0.35,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                            child: _featuredCard(month[idx], isRtl, idx),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (month.length > 1) ...<Widget>[
              const SizedBox(height: 22),
              _featuredControls(month.length, isRtl),
            ],
          ],
        ],
      ),
    );
  }

  Widget _featuredCard(Map<String, dynamic> d, bool isRtl, int idx) {
    final Color c = d['couleur'] as Color;
    final List<int> fav = _favMonths(d);

    return _Pressable(
      semanticLabel: '${d['nom']}',
      onTap: () => _open(d),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _photo(d['image'] as String, logicalWidth: 300),
                    PositionedDirectional(
                      bottom: 12,
                      end: 12,
                      child: _favButton(d, size: 36),
                    ),
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: _tagPill(_regionRow('${d['region']}', c, size: 9)),
                    ),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: _card),
                        child: Text(
                          _num(idx),
                          style: GoogleFonts.marcellus(color: _ink, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('${d['nom']}', style: _display(22, height: 1.1)),
                        const SizedBox(height: 6),
                        Text(
                          '${d['description']}',
                          style: _text(12.5, color: _muted, height: 1.45),
                        ),
                        if (fav.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          _seasonGlyph(fav),
                          const SizedBox(height: 6),
                          Text(
                            t('bestSeason'),
                            style: _text(11, color: _muted, style: FontStyle.italic, height: 1.2),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _arrowDot(isRtl, size: 44),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featuredControls(int n, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: ValueListenableBuilder<int>(
        valueListenable: _featuredIndex,
        builder: (BuildContext context, int v, Widget? _) {
          return Row(
            children: <Widget>[
              Text(
                '${_num(v)} / ${_num(n - 1)}',
                style: _text(12, color: _ink, weight: FontWeight.w600, spacing: 1.2, height: 1.2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: <Widget>[
                    for (int k = 0; k < n; k++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsetsDirectional.only(end: 6),
                        width: k == v ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: k == v ? _ink : _line,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _roundButton(
                isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                    () => _stepFeatured(-1, n),
                size: 42,
              ),
              const SizedBox(width: 8),
              _roundButton(
                isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                    () => _stepFeatured(1, n),
                size: 42,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Frise des douze mois : barres hautes = meilleurs mois, mois courant en accent.
  Widget _seasonGlyph(List<int> fav) {
    final int now = DateTime.now().month;
    final List<String> names = _accueilMonths[_lang] ?? _accueilMonths['fr']!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (int m = 1; m <= 12; m++)
          Padding(
            padding: EdgeInsetsDirectional.only(start: m == 1 ? 0 : 4),
            child: SizedBox(
              width: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 4,
                    height: fav.contains(m) ? 14 : 4,
                    decoration: BoxDecoration(
                      color: m == now ? _accent : (fav.contains(m) ? _ink : _line),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    names[m - 1].substring(0, 1),
                    textAlign: TextAlign.center,
                    style: _text(
                      8.5,
                      color: m == now ? _ink : _muted,
                      weight: m == now ? FontWeight.w700 : FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ───────────────────────── Explorer ─────────────────────────

  Widget _buildExplore(List<Map<String, dynamic>> all, bool isRtl) {
    final List<Map<String, dynamic>> cats = _categories();
    final List<Map<String, dynamic>> shown = _selectedCat == null
        ? cats
        : cats.where((Map<String, dynamic> c) => c['key'] == _selectedCat).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _chapterHead(t('eyebrow'), t('exploreByRegion'), key: _kExplore),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: <Widget>[
                _chip(null, t('all'), Icons.apps_rounded),
                ...cats.map(
                      (Map<String, dynamic> c) => _chip(c['key'] as String, c['label'] as String, c['icon'] as IconData),
                ),
                _chip('__fav__', t('favorites'), Icons.favorite_rounded),
              ],
            ),
          ),
          const SizedBox(height: 36),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[...previous, if (current != null) current],
            ),
            transitionBuilder: (Widget child, Animation<double> anim) => FadeTransition(opacity: anim, child: child),
            child: SizedBox(
              key: ValueKey<String>(_selectedCat ?? '__all__'),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  if (_selectedCat == '__fav__')
                    _favBlock(all, isRtl)
                  else
                    for (final Map<String, dynamic> cat in shown) _categoryBlock(cat, all, isRtl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String? key, String label, IconData icon) {
    final bool selected = _selectedCat == key;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (selected) return;
        HapticFeedback.selectionClick();
        setState(() => _selectedCat = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _ink : _card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? _ink : _line, width: 0.9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: selected ? _card : _ink),
            const SizedBox(width: 8),
            Text(
              label,
              softWrap: false,
              style: _text(
                13.5,
                color: selected ? _card : _ink,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBlock(Map<String, dynamic> cat, List<Map<String, dynamic>> all, bool isRtl) {
    final List<Map<String, dynamic>> items =
    _sorted(all.where((Map<String, dynamic> d) => d['categoryKey'] == cat['key']).toList());
    if (items.isEmpty) return const SizedBox.shrink();
    final int n = items.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Reveal(
            controller: _scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(cat['label'] as String, style: _display(24, height: 1.15)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$n ${n > 1 ? t('elements') : t('element')}',
                      style: _text(12, color: _muted, height: 1.3),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: _line),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: _listingCard(items[i], i, isRtl),
            ),
        ],
      ),
    );
  }

  /// Carte destination : vignette blanche, photo, titre serif et bouton rond noir.
  Widget _listingCard(Map<String, dynamic> d, int i, bool isRtl) {
    final Color c = d['couleur'] as Color;
    final double w = MediaQuery.of(context).size.width - 64;

    return _Reveal(
      controller: _scroll,
      dy: 34,
      child: _Pressable(
        semanticLabel: '${d['nom']}',
        onTap: () => _open(d),
        onLongPress: () => _preview(d),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: _softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _Parallax(
                        controller: _scroll,
                        extent: 0.16,
                        child: _photo(d['image'] as String, logicalWidth: w),
                      ),
                      PositionedDirectional(
                        top: 12,
                        end: 54,
                        child: _favButton(d, size: 34),
                      ),
                      PositionedDirectional(
                        top: 12,
                        start: 12,
                        child: _tagPill(_regionRow('${d['region']}', c, size: 9.5)),
                      ),
                      PositionedDirectional(
                        top: 12,
                        end: 12,
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: _card),
                          child: Text(
                            _num(i),
                            style: GoogleFonts.marcellus(color: _ink, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('${d['nom']}', style: _display(24, height: 1.12)),
                          const SizedBox(height: 8),
                          Text(
                            '${d['description']}',
                            style: _text(13.5, color: _muted, height: 1.55),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _arrowDot(isRtl, size: 44),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Résultats de recherche ─────────────────────────

  Widget _buildResults(List<Map<String, dynamic>> results, bool isRtl) {
    final int n = results.length;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _chapterHead(
            n == 0 ? t('searchResults') : '$n ${n > 1 ? t('elements') : t('element')}',
            t('searchResults'),
          ),
          if (n == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(t('noResults'), style: _text(14.5, color: _muted)),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < n; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 26),
                      child: _listingCard(results[i], i, isRtl),
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
    final double bottom = MediaQuery.of(context).padding.bottom;
    return _Reveal(
      controller: _scroll,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: EdgeInsets.fromLTRB(22, 56, 22, 44 + bottom),
        decoration: const BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 56,
              child: CustomPaint(painter: _PyramidsPainter(_ink)),
            ),
            const SizedBox(height: 24),
            Text(
              t('brand'),
              textAlign: TextAlign.center,
              style: _ar ? _display(22) : GoogleFonts.marcellus(color: _ink, fontSize: 16, letterSpacing: 8),
            ),
            const SizedBox(height: 12),
            Text(
              t('footer'),
              textAlign: TextAlign.center,
              style: _text(13.5, color: _muted, style: FontStyle.italic, height: 1.5),
            ),
            const SizedBox(height: 30),
            _inkButton(
              t('backToTop'),
                  () {
                HapticFeedback.selectionClick();
                _toTop();
              },
              _ar,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Petits composants ─────────────────────────

  /// Image décodée à la taille réelle d'affichage × densité de l'écran (nette).
  Widget _photo(String path, {double? logicalWidth}) {
    if (path == HistoireGraphic.assetKey) return const HistoireGraphic();
    final MediaQueryData mq = MediaQuery.of(context);
    final double w = logicalWidth ?? mq.size.width;
    final int cw = (w * mq.devicePixelRatio).round().clamp(480, 1600).toInt();
    return ColoredBox(
      color: _field,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: cw,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
        const ColoredBox(color: _field),
      ),
    );
  }

  Widget _regionRow(String label, Color c, {double size = 12.5}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _ar ? label : label.toUpperCase(),
            style: _text(
              size,
              color: _ink,
              weight: FontWeight.w600,
              height: 1.2,
              spacing: _ar ? 0 : 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar(double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _accent,
      ),
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _card),
        alignment: Alignment.center,
        child: Text(_currentAvatar, style: TextStyle(fontSize: size * 0.46)),
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap, {double size = 46, String? tooltip}) {
    final Widget btn = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _card,
          border: Border.all(color: _line, width: 0.9),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: _ink, size: size * 0.46),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  /// Bouton noir à coins arrondis, façon « Add to bag ». Pleine largeur dans une colonne étirée.
  Widget _inkButton(String label, VoidCallback onTap, bool isRtl, {bool compact = false}) {
    return _Pressable(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: compact ? 30 : 0),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          widthFactor: compact ? 1 : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _ar ? label : label.toUpperCase(),
                style: _text(13, color: _card, weight: FontWeight.w600, spacing: _ar ? 0 : 1.6, height: 1.2),
              ),
              const SizedBox(width: 10),
              Icon(
                isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                color: _card,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _arrowDot(bool isRtl, {double size = 46}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _accent),
      child: Icon(
        isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
        color: _card,
        size: size * 0.42,
      ),
    );
  }
}

// ==========================================
// COMPOSANTS D'ANIMATION
// ==========================================

/// Légère contraction au toucher.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;
  final VoidCallback? onLongPress;
  const _Pressable({required this.child, required this.onTap, this.semanticLabel, this.onLongPress});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress == null
            ? null
            : () {
          HapticFeedback.mediumImpact();
          widget.onLongPress!();
        },
        child: AnimatedScale(
          scale: _down ? 0.982 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Apparition en fondu et glissement, une seule fois, quand l'élément entre dans l'écran.
/// Le contrôle est répété à chaque défilement ET après le premier rendu, donc un élément
/// ajouté par la recherche ou un changement de catégorie n'attend pas un nouveau scroll.
class _Reveal extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final double dy;
  final int delayMs;
  const _Reveal({required this.controller, required this.child, this.dy = 36, this.delayMs = 0});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 820),
  );
  late final Animation<double> _v = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutQuart,
  );

  bool _shown = false;
  bool _checkScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleCheck);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleCheck());
  }

  @override
  void didUpdateWidget(covariant _Reveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleCheck);
      widget.controller.addListener(_scheduleCheck);
      _scheduleCheck();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleCheck);
    _c.dispose();
    super.dispose();
  }

  /// Vérifie la position après la mise en page : les coordonnées sont ainsi
  /// recalculées une fois que le scroll a réellement déplacé les éléments.
  void _scheduleCheck() {
    if (!mounted || _shown || _checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (mounted) _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (_shown || !mounted) return;

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return;
    }

    final MediaQueryData media = MediaQuery.of(context);
    final Offset origin = renderObject.localToGlobal(Offset.zero);
    final Rect bounds = origin & renderObject.size;
    final double safeTop = media.padding.top + 92;
    final double safeBottom = media.size.height - media.padding.bottom;

    // L'élément doit réellement croiser la zone visible, et non simplement
    // avoir son bord supérieur au-dessus de l'écran.
    final bool entersViewport =
        bounds.bottom > safeTop && bounds.top < safeBottom - 24;
    if (!entersViewport) return;

    _shown = true;
    if (media.disableAnimations) {
      _c.value = 1;
      return;
    }

    if (widget.delayMs <= 0) {
      _c.forward();
    } else {
      Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted && !_c.isAnimating) _c.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _v,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double progress = _v.value;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, widget.dy * (1 - progress)),
            child: Transform.scale(
              scale: 0.985 + (0.015 * progress),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Parallaxe verticale : la photo glisse lentement dans son cadre pendant le défilement.
class _Parallax extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final double extent;
  const _Parallax({required this.controller, required this.child, this.extent = 0.16});

  @override
  State<_Parallax> createState() => _ParallaxState();
}

class _ParallaxState extends State<_Parallax> {
  final GlobalKey _k = GlobalKey();

  double _fraction() {
    final BuildContext? ctx = _k.currentContext;
    if (ctx == null) return 0;
    final RenderObject? ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return 0;
    final double vh = MediaQuery.of(context).size.height;
    final double mid = ro.localToGlobal(Offset.zero).dy + ro.size.height / 2;
    return ((mid - vh / 2) / (vh / 2)).clamp(-1.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      key: _k,
      child: AnimatedBuilder(
        animation: widget.controller,
        child: widget.child,
        builder: (BuildContext context, Widget? child) {
          final double f = _fraction();
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints cons) {
              final double extra = cons.maxHeight * widget.extent;
              return OverflowBox(
                alignment: Alignment.center,
                minHeight: cons.maxHeight + extra,
                maxHeight: cons.maxHeight + extra,
                child: Transform.translate(offset: Offset(0, -f * extra / 2), child: child),
              );
            },
          );
        },
      ),
    );
  }
}

/// Travelling très lent sur la photo du hero.
class _KenBurns extends StatefulWidget {
  final Widget child;
  final int dir;
  const _KenBurns({super.key, required this.child, this.dir = 1});

  @override
  State<_KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<_KenBurns> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool still = MediaQuery.of(context).disableAnimations;
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (BuildContext context, Widget? child) {
          final double v = still ? 0.0 : Curves.easeOut.transform(_c.value);
          return Transform.translate(
            offset: Offset(widget.dir * -10.0 * v, 0),
            child: Transform.scale(scale: 1.04 + 0.05 * v, child: child),
          );
        },
      ),
    );
  }
}

/// Anneau de progression autour de la pastille active.
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.shortestSide / 2 - 1;
    final Paint track = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final Paint arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, track);
    final double sweep = 2 * math.pi * progress.clamp(0.0, 1.0).toDouble();
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.color != color;
}

/// Fond de nuit : nébuleuses lentes et étoiles qui scintillent.
/// t va de 0 à 1 et boucle sans saut (toutes les fréquences sont entières).
class _AmbientPainter extends CustomPainter {
  final double t;
  final Color accent;
  const _AmbientPainter(this.t, this.accent);

  static final List<List<double>> _stars = List<List<double>>.generate(70, (int i) {
    final math.Random r = math.Random(i * 17 + 3);
    return <double>[r.nextDouble(), r.nextDouble(), 0.6 + r.nextDouble() * 1.3, r.nextDouble() * 6.28];
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double a = t * 2 * math.pi;

    void blob(Offset c, double radius, Color col) {
      final Paint p = Paint()
        ..shader = RadialGradient(colors: <Color>[col, col.withOpacity(0)])
            .createShader(Rect.fromCircle(center: c, radius: radius));
      canvas.drawCircle(c, radius, p);
    }

    blob(Offset(w * (0.82 + 0.08 * math.cos(a)), h * (0.12 + 0.05 * math.sin(a))), w * 0.75,
        accent.withOpacity(0.14));
    blob(Offset(w * (0.08 + 0.06 * math.sin(a)), h * (0.55 + 0.04 * math.cos(a))), w * 0.85,
        const Color(0xFF1B4E8C).withOpacity(0.22));
    blob(Offset(w * (0.6 + 0.05 * math.sin(a)), h * (0.9 + 0.03 * math.cos(a))), w * 0.65,
        const Color(0xFF176B68).withOpacity(0.16));

    final Paint s = Paint();
    for (final List<double> st in _stars) {
      final int k = (st[2] * 2).round();
      final double tw = 0.5 + 0.5 * math.sin(a * k + st[3]);
      s.color = const Color(0xFFF2E9D8).withOpacity(0.08 + 0.30 * tw);
      canvas.drawCircle(Offset(st[0] * w, st[1] * h), st[2] * 0.9, s);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) => old.t != t || old.accent != accent;
}

/// Heure du Caire : UTC+2, UTC+3 pendant l'heure d'été.
/// Approximation de la règle égyptienne : du dernier vendredi d'avril au dernier jeudi d'octobre.
DateTime _egyptNow() {
  final DateTime utc = DateTime.now().toUtc();
  final DateTime day = DateTime(utc.year, utc.month, utc.day);
  final DateTime aprEnd = DateTime(utc.year, 4, 30);
  final DateTime dstStart = aprEnd.subtract(Duration(days: (aprEnd.weekday - DateTime.friday + 7) % 7));
  final DateTime octEnd = DateTime(utc.year, 10, 31);
  final DateTime dstEnd = octEnd.subtract(Duration(days: (octEnd.weekday - DateTime.thursday + 7) % 7));
  final bool summer = !day.isBefore(dstStart) && day.isBefore(dstEnd);
  return utc.add(Duration(hours: summer ? 3 : 2));
}

/// Ciel animé : dégradé selon l'heure, soleil ou lune qui suit son arc, silhouette de pyramide.
class _SkyPainter2 extends CustomPainter {
  const _SkyPainter2(this.h);
  final double h;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double ht = size.height;
    final bool day = h >= 6 && h < 18;
    final bool twilight = (h >= 5 && h < 7) || (h >= 17 && h < 19);

    final List<Color> sky = day
        ? <Color>[const Color(0xFF1C63AE), const Color(0xFF6DAEE0), const Color(0xFFF2D49B)]
        : twilight
        ? <Color>[const Color(0xFF2B2160), const Color(0xFFD9653F), const Color(0xFFF5A65B)]
        : <Color>[const Color(0xFF04060E), const Color(0xFF0E1834), const Color(0xFF1F3466)];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
        ).createShader(Offset.zero & size),
    );

    if (!day) {
      final math.Random r = math.Random(3);
      final Paint star = Paint()..color = const Color(0xFFF2E9D8).withOpacity(0.7);
      for (int i = 0; i < 40; i++) {
        canvas.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * ht * 0.6), 0.8 + r.nextDouble(), star);
      }
    }

    final Path ground = Path()
      ..moveTo(0, ht)
      ..lineTo(0, ht * 0.8)
      ..quadraticBezierTo(w * 0.3, ht * 0.62, w * 0.5, ht * 0.82)
      ..quadraticBezierTo(w * 0.78, ht * 0.95, w, ht * 0.76)
      ..lineTo(w, ht)
      ..close();
    canvas.drawPath(ground, Paint()..color = day ? const Color(0xFFC08A52) : const Color(0xFF070A14));

    final Path pyramid = Path()
      ..moveTo(w * 0.70, ht * 0.84)
      ..lineTo(w * 0.80, ht * 0.56)
      ..lineTo(w * 0.90, ht * 0.84)
      ..close();
    canvas.drawPath(pyramid, Paint()..color = day ? const Color(0xFFB07A44) : const Color(0xFF0B1024));

    final double f = (day ? (h - 6) / 12 : (h >= 18 ? (h - 18) / 12 : (h + 6) / 12)).clamp(0.0, 1.0).toDouble();
    final Offset p = Offset(w * (0.08 + 0.84 * f), ht * 0.78 - math.sin(math.pi * f) * ht * 0.6);
    if (day) {
      canvas.drawCircle(
        p,
        46,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[const Color(0xCCFFE08A), const Color(0x00FFE08A)],
          ).createShader(Rect.fromCircle(center: p, radius: 46)),
      );
      canvas.drawCircle(p, 15, Paint()..color = const Color(0xFFFFE9A8));
    } else {
      canvas.drawCircle(p, 13, Paint()..color = const Color(0xFFEFEFF7));
      canvas.drawCircle(p + const Offset(6, -4), 12, Paint()..color = const Color(0xFF0E1834));
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter2 old) => old.h != h;
}

/// Grain de sable : position normalisée (0 à 1), vitesse et taille.
class _Grain {
  _Grain(this.x, this.y, this.s, this.a);
  double x;
  double y;
  double vx = 0;
  double vy = 0;
  final double s;
  final double a;
}

/// Champ de sable : le vent pousse les grains, le doigt les soulève.
class _SandField {
  final math.Random _rnd = math.Random(42);
  late final List<_Grain> grains = List<_Grain>.generate(
    160,
        (int _) => _Grain(_rnd.nextDouble(), _rnd.nextDouble(), 0.6 + _rnd.nextDouble() * 1.8, 0.15 + _rnd.nextDouble() * 0.35),
  );
  double _t = 0;

  void step(double dt) {
    _t += dt;
    for (final _Grain g in grains) {
      g.x += (0.035 * (0.5 + g.s / 3) + g.vx) * dt;
      g.y += (0.006 * math.sin(_t * 1.3 + g.x * 9) + g.vy) * dt;
      final double decay = math.exp(-dt * 1.6);
      g.vx *= decay;
      g.vy *= decay;
      if (g.x > 1.03) {
        g.x = -0.03;
        g.y = _rnd.nextDouble();
      }
      if (g.y < -0.03) g.y = 1.03;
      if (g.y > 1.03) g.y = -0.03;
    }
  }

  void push(double px, double py, double dx, double dy, double w, double h) {
    for (final _Grain g in grains) {
      final double ddx = g.x * w - px;
      final double ddy = g.y * h - py;
      final double d = math.sqrt(ddx * ddx + ddy * ddy);
      if (d < 80) {
        final double k = (1 - d / 80) * 0.9;
        g.vx += dx / w * k * 4;
        g.vy += dy / h * k * 4;
      }
    }
  }
}

class _SandPainter extends CustomPainter {
  _SandPainter(this.field, this.color, Listenable repaint) : super(repaint: repaint);
  final _SandField field;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    for (final _Grain g in field.grains) {
      p.color = color.withOpacity(g.a * 0.55);
      canvas.drawCircle(Offset(g.x * size.width, g.y * size.height), g.s, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SandPainter old) => old.color != color;
}

// ==========================================
// OUTILS DE L'ACCUEIL (contenus des feuilles)
// ==========================================

String _prefFirst(SharedPreferences p, String key, String fallback) {
  final List<String>? list = p.getStringList(key);
  return (list == null || list.isEmpty) ? fallback : list.first;
}

/// Pyramide à 15 blocs : se remplit du bas vers le sommet selon les tampons.
class _PassportPyramidPainter extends CustomPainter {
  final double ratio;
  final Color on;
  final Color off;
  const _PassportPyramidPainter(this.ratio, this.on, this.off);

  @override
  void paint(Canvas canvas, Size size) {
    const int rows = 5;
    const double gap = 3;
    final double bw = (size.width - (rows - 1) * gap) / rows;
    final double bh = (size.height - (rows - 1) * gap) / rows;
    final int lit = (ratio.clamp(0.0, 1.0).toDouble() * 15).round();
    int drawn = 0;
    for (int r = 0; r < rows; r++) {
      final int len = rows - r; // bas : 5 blocs, sommet : 1 bloc
      final int y = rows - 1 - r;
      final double rowW = len * bw + (len - 1) * gap;
      final double x0 = (size.width - rowW) / 2;
      for (int j = 0; j < len; j++) {
        final Rect rect = Rect.fromLTWH(x0 + j * (bw + gap), y * (bh + gap), bw, bh);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          Paint()..color = drawn < lit ? on : off,
        );
        drawn++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PassportPyramidPainter old) =>
      old.ratio != ratio || old.on != on || old.off != off;
}

/// Confettis qui tombent une fois, au déblocage d'un badge.
class _ConfettiPainter extends CustomPainter {
  final double t;
  final Color accent;
  const _ConfettiPainter(this.t, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final math.Random r = math.Random(7);
    final List<Color> palette = <Color>[
      accent,
      const Color(0xFFF2E9D8),
      const Color(0xFF9CC5D8),
      const Color(0xFFE07A5F),
    ];
    final double fade = (1 - t).clamp(0.0, 1.0).toDouble();
    final Paint p = Paint();
    for (int i = 0; i < 70; i++) {
      final double x0 = r.nextDouble() * size.width;
      final double speed = 0.7 + r.nextDouble() * 0.6;
      final double spin = r.nextDouble() * 6;
      final double drift = (r.nextDouble() - 0.5) * 80;
      final double y = -20 + (size.height + 40) * t * speed;
      final double x = x0 + math.sin(t * 6 + spin) * drift;
      p.color = palette[i % palette.length].withOpacity(fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(spin + t * 8);
      canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t || old.accent != accent;
}

/// Couche dorée à gratter : les traits effacent la couche (BlendMode.clear).
class _ScratchPainter extends CustomPainter {
  final List<Offset?> pts;
  final Color gold;
  const _ScratchPainter(this.pts, this.gold);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect area = Offset.zero & size;
    canvas.saveLayer(area, Paint());
    canvas.drawRRect(
      RRect.fromRectAndRadius(area, const Radius.circular(22)),
      Paint()..color = gold,
    );
    final Paint clear = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i < pts.length; i++) {
      final Offset? a = pts[i - 1];
      final Offset? b = pts[i];
      if (a != null && b != null) canvas.drawLine(a, b, clear);
    }
    for (final Offset? p in pts) {
      if (p != null) canvas.drawCircle(p, 18, clear);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter old) =>
      old.pts.length != pts.length || old.gold != gold;
}

/// Interrupteur réutilisable dans une feuille d'outil.
class _SwitchTool extends StatefulWidget {
  final _HomeState host;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTool(this.host, {required this.label, required this.value, required this.onChanged});

  @override
  State<_SwitchTool> createState() => _SwitchToolState();
}

class _SwitchToolState extends State<_SwitchTool> {
  late bool _on = widget.value;

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    return Row(
      children: <Widget>[
        Expanded(child: Text(widget.label, style: h._display(20))),
        Switch(
          value: _on,
          activeColor: h._accent,
          onChanged: (bool v) {
            setState(() => _on = v);
            widget.onChanged(v);
          },
        ),
      ],
    );
  }
}

/// Roulette : fait défiler des noms, puis s'arrête sur une destination au hasard.
class _RouletteTool extends StatefulWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _RouletteTool(this.host, this.all);

  @override
  State<_RouletteTool> createState() => _RouletteToolState();
}

class _RouletteToolState extends State<_RouletteTool> {
  final math.Random _rnd = math.Random();
  Timer? _timer;
  int _shown = 0;
  Map<String, dynamic>? _pick;
  bool _spinning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _spin() {
    if (widget.all.isEmpty || _spinning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _spinning = true;
      _pick = null;
    });
    int ticks = 0;
    final int total = 18 + _rnd.nextInt(8);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 90), (Timer tm) {
      if (!mounted) {
        tm.cancel();
        return;
      }
      ticks++;
      if (ticks >= total) {
        tm.cancel();
        setState(() {
          _spinning = false;
          _pick = widget.all[_rnd.nextInt(widget.all.length)];
        });
        HapticFeedback.mediumImpact();
        return;
      }
      setState(() {
        _shown = _rnd.nextInt(widget.all.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final Map<String, dynamic>? shown = _pick ??
        (widget.all.isEmpty ? null : widget.all[_shown % widget.all.length]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _HomeState._field,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: h._accent.withOpacity(0.5)),
          ),
          child: Text(
            shown == null ? '' : '${shown['nom']}',
            textAlign: TextAlign.center,
            style: h._display(26, color: h._accent),
          ),
        ),
        const SizedBox(height: 16),
        h._inkButton(_spinning ? '…' : h.t(_pick == null ? 'spinWheel' : 'reroll'), _spin, h._ar),
        if (_pick != null && !_spinning) ...<Widget>[
          const SizedBox(height: 10),
          h._inkButton(h.t('openDest'), () {
            Navigator.pop(context);
            h._open(_pick!);
          }, h._ar),
        ],
      ],
    );
  }
}

/// Carte à gratter : révèle une destination au hasard après un certain grattage.
class _ScratchTool extends StatefulWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _ScratchTool(this.host, this.all);

  @override
  State<_ScratchTool> createState() => _ScratchToolState();
}

class _ScratchToolState extends State<_ScratchTool> {
  final math.Random _rnd = math.Random();
  final List<Offset?> _pts = <Offset?>[];
  Map<String, dynamic>? _card;

  @override
  void initState() {
    super.initState();
    _card = _pickCard();
  }

  Map<String, dynamic>? _pickCard() {
    if (widget.all.isEmpty) return null;
    return widget.all[_rnd.nextInt(widget.all.length)];
  }

  int get _scratched => _pts.where((Offset? o) => o != null).length;

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final bool open = _scratched > 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(h.t('scratchHint'), style: h._text(13, color: _HomeState._muted)),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  color: _HomeState._field,
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    _card == null ? '' : '${_card!['nom']}',
                    textAlign: TextAlign.center,
                    style: h._display(26, color: h._accent),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (DragStartDetails d) => setState(() => _pts.add(d.localPosition)),
                  onPanUpdate: (DragUpdateDetails d) => setState(() => _pts.add(d.localPosition)),
                  onPanEnd: (DragEndDetails _) => setState(() => _pts.add(null)),
                  child: CustomPaint(
                    painter: _ScratchPainter(List<Offset?>.of(_pts), h._accent),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (open) ...<Widget>[
          h._inkButton(h.t('openDest'), () {
            if (_card == null) return;
            Navigator.pop(context);
            h._open(_card!);
          }, h._ar),
          const SizedBox(height: 10),
        ],
        h._inkButton(h.t('newCard'), () {
          setState(() {
            _pts.clear();
            _card = _pickCard();
          });
        }, h._ar),
      ],
    );
  }
}

/// Compte à rebours jusqu'à un voyage.
class _CountdownTool extends StatefulWidget {
  final _HomeState host;
  const _CountdownTool(this.host);

  @override
  State<_CountdownTool> createState() => _CountdownToolState();
}

class _CountdownToolState extends State<_CountdownTool> {
  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final int? left = h._daysLeft();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          left == null ? '—' : '${left < 0 ? 0 : left}',
          textAlign: TextAlign.center,
          style: h._display(56, color: h._accent),
        ),
        Text(
          h.t('daysLeft'),
          textAlign: TextAlign.center,
          style: h._text(13, color: _HomeState._muted),
        ),
        const SizedBox(height: 18),
        h._inkButton(h.t('pickDate'), () async {
          final DateTime now = DateTime.now();
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: now.add(const Duration(days: 30)),
            firstDate: now,
            lastDate: now.add(const Duration(days: 1095)),
          );
          if (picked == null || !mounted) return;
          h._setTrip(picked);
          setState(() {});
        }, h._ar),
        if (left != null) ...<Widget>[
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              h._setTrip(null);
              setState(() {});
            },
            child: Text(h.t('resetPassport'), style: h._text(13, color: _HomeState._muted)),
          ),
        ],
      ],
    );
  }
}

/// Cartouche : le prénom s'écrit dans un cadre ovale, à la manière d'une gravure.
class _CartoucheTool extends StatefulWidget {
  final _HomeState host;
  const _CartoucheTool(this.host);

  @override
  State<_CartoucheTool> createState() => _CartoucheToolState();
}

class _CartoucheToolState extends State<_CartoucheTool> {
  final TextEditingController _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final String name = _c.text.trim().toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _c,
          onChanged: (String _) => setState(() {}),
          style: h._text(16, color: _HomeState._ink),
          decoration: InputDecoration(
            hintText: h.t('nameHint'),
            hintStyle: h._text(15, color: _HomeState._muted),
            filled: true,
            fillColor: _HomeState._field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          constraints: const BoxConstraints(minHeight: 110),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: h._accent, width: 2.4),
          ),
          child: Text(
            name.isEmpty ? '—' : name,
            textAlign: TextAlign.center,
            style: h._display(28, color: h._accent, spacing: 4),
          ),
        ),
      ],
    );
  }
}

/// Humeur : chaque humeur ouvre une catégorie de destinations, au hasard.
class _MoodTool extends StatefulWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _MoodTool(this.host, this.all);

  @override
  State<_MoodTool> createState() => _MoodToolState();
}

class _MoodToolState extends State<_MoodTool> {
  final math.Random _rnd = math.Random();
  int _mood = -1;
  Map<String, dynamic>? _pick;

  void _choose(int m) {
    final List<String> keys = <String>[];
    for (final Map<String, dynamic> d in widget.all) {
      final String k = '${d['categoryKey']}';
      if (!keys.contains(k)) keys.add(k);
    }
    final List<Map<String, dynamic>> pool = keys.isEmpty
        ? <Map<String, dynamic>>[]
        : widget.all
        .where((Map<String, dynamic> d) => '${d['categoryKey']}' == keys[m % keys.length])
        .toList();
    setState(() {
      _mood = m;
      _pick = pool.isEmpty ? null : pool[_rnd.nextInt(pool.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final List<String> labels = <String>[
      h.t('moodAdventure'),
      h.t('moodCulture'),
      h.t('moodRelax'),
      h.t('moodFood'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (int i = 0; i < labels.length; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _choose(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _mood == i ? h._accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _mood == i ? h._accent : _HomeState._line, width: 0.9),
                  ),
                  child: Text(
                    labels[i],
                    style: h._text(13,
                        color: _mood == i ? _HomeState._card : _HomeState._ink,
                        weight: FontWeight.w600,
                        height: 1.2),
                  ),
                ),
              ),
          ],
        ),
        if (_pick != null) ...<Widget>[
          const SizedBox(height: 22),
          Text('${_pick!['nom']}', textAlign: TextAlign.center, style: h._display(26, color: h._accent)),
          const SizedBox(height: 16),
          h._inkButton(h.t('openDest'), () {
            Navigator.pop(context);
            h._open(_pick!);
          }, h._ar),
        ],
      ],
    );
  }
}

/// Mois idéal : compte, pour chaque mois, les destinations qui le recommandent.
class _CalendarTool extends StatelessWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _CalendarTool(this.host, this.all);

  @override
  Widget build(BuildContext context) {
    final List<int> counts = List<int>.filled(13, 0);
    for (final Map<String, dynamic> d in all) {
      for (final int m in host._favMonths(d)) {
        if (m >= 1 && m <= 12) counts[m]++;
      }
    }
    int best = 1;
    for (int m = 1; m <= 12; m++) {
      if (counts[m] > counts[best]) best = m;
    }
    final List<String> names = _accueilMonths[host._lang] ?? _accueilMonths['fr']!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${host.t('idealIn')}${names[best - 1]}',
          textAlign: TextAlign.center,
          style: host._display(24, color: host._accent),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (int m = 1; m <= 12; m++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: m == best ? host._accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: m == best ? host._accent : _HomeState._line,
                    width: 0.9,
                  ),
                ),
                child: Text(
                  '${names[m - 1]} · ${counts[m]}',
                  style: host._text(12,
                      color: m == best ? _HomeState._card : _HomeState._muted,
                      weight: FontWeight.w600,
                      height: 1.2),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Itinéraire : un tirage de destinations, une par jour.
class _ItineraryTool extends StatefulWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _ItineraryTool(this.host, this.all);

  @override
  State<_ItineraryTool> createState() => _ItineraryToolState();
}

class _ItineraryToolState extends State<_ItineraryTool> {
  final math.Random _rnd = math.Random();
  int _days = 3;
  List<Map<String, dynamic>> _plan = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _plan = _make();
  }

  List<Map<String, dynamic>> _make() {
    final List<Map<String, dynamic>> copy = List<Map<String, dynamic>>.of(widget.all)
      ..shuffle(_rnd);
    return copy.take(_days).toList();
  }

  void _setDays(int v) {
    setState(() {
      _days = v.clamp(1, 5).toInt();
      _plan = _make();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(h.t('itinDays'), style: h._text(14, color: _HomeState._muted))),
            h._roundButton(Icons.remove_rounded, () => _setDays(_days - 1), size: 42),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('$_days', style: h._display(22, color: h._accent)),
            ),
            h._roundButton(Icons.add_rounded, () => _setDays(_days + 1), size: 42),
          ],
        ),
        const SizedBox(height: 18),
        for (int i = 0; i < _plan.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
              h._open(_plan[i]);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  h._label('${h.t('dayLabel')} ${i + 1}', color: h._accent),
                  const SizedBox(height: 4),
                  Text('${_plan[i]['nom']}', style: h._display(20)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 6),
        h._inkButton(h.t('reroll'), () {
          setState(() => _plan = _make());
        }, h._ar),
      ],
    );
  }
}

/// Respiration : cercle qui se gonfle (4 s), tient (4 s), se dégonfle (4 s).
class _BreathTool extends StatefulWidget {
  final _HomeState host;
  const _BreathTool(this.host);

  @override
  State<_BreathTool> createState() => _BreathToolState();
}

class _BreathToolState extends State<_BreathTool> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? _) {
        final double v = _c.value;
        double scale;
        String label;
        if (v < 1 / 3) {
          label = h.t('inhale');
          scale = 0.5 + 0.5 * (v * 3);
        } else if (v < 2 / 3) {
          label = h.t('holdBreath');
          scale = 1;
        } else {
          label = h.t('exhale');
          scale = 1 - 0.5 * ((v - 2 / 3) * 3);
        }
        return Column(
          children: <Widget>[
            SizedBox(
              height: 200,
              child: Center(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: h._accent.withOpacity(0.15),
                      border: Border.all(color: h._accent, width: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(label, style: h._display(24, color: h._accent)),
          ],
        );
      },
    );
  }
}

/// Scarabée : touche les scarabées qui apparaissent pendant 20 secondes.
class _ScarabTool extends StatefulWidget {
  final _HomeState host;
  const _ScarabTool(this.host);

  @override
  State<_ScarabTool> createState() => _ScarabToolState();
}

class _ScarabToolState extends State<_ScarabTool> {
  static const double _fieldH = 220;
  final math.Random _rnd = math.Random();
  Timer? _spawn;
  Timer? _clock;
  int _left = 20;
  int _score = 0;
  bool _running = false;
  Offset _pos = const Offset(0.5, 0.5);

  @override
  void dispose() {
    _spawn?.cancel();
    _clock?.cancel();
    super.dispose();
  }

  Offset _randomPos() =>
      Offset(0.08 + _rnd.nextDouble() * 0.84, 0.08 + _rnd.nextDouble() * 0.84);

  void _start() {
    _spawn?.cancel();
    _clock?.cancel();
    setState(() {
      _left = 20;
      _score = 0;
      _running = true;
      _pos = _randomPos();
    });
    _spawn = Timer.periodic(const Duration(milliseconds: 850), (Timer _) {
      if (mounted) {
        setState(() {
          _pos = _randomPos();
        });
      }
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (Timer tm) {
      if (!mounted) {
        tm.cancel();
        return;
      }
      setState(() {
        _left--;
      });
      if (_left > 0) return;
      tm.cancel();
      _spawn?.cancel();
      setState(() {
        _running = false;
      });
      if (_score > widget.host._scarabBest) widget.host._setScarabBest(_score);
    });
  }

  void _catch() {
    if (!_running) return;
    HapticFeedback.selectionClick();
    setState(() {
      _score++;
      _pos = _randomPos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${h.t('scarabScore')} : $_score',
                style: h._text(14, color: _HomeState._ink, weight: FontWeight.w600),
              ),
            ),
            Text(
              '${h.t('bestScore')} : ${h._scarabBest}',
              style: h._text(14, color: _HomeState._muted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _running ? '$_left s · ${h.t('tapScarab')}' : h.t('tapScarab'),
          style: h._text(12.5, color: _HomeState._muted),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final double w = box.maxWidth;
            return Container(
              width: w,
              height: _fieldH,
              decoration: BoxDecoration(
                color: _HomeState._field,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                children: <Widget>[
                  if (_running)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      left: _pos.dx * w - 22,
                      top: _pos.dy * _fieldH - 22,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _catch,
                        child: Icon(Icons.pest_control_rounded, size: 44, color: h._accent),
                      ),
                    )
                  else
                    Center(
                      child: h._inkButton(
                        _score > 0 ? h.t('playAgain') : h.t('startGame'),
                        _start,
                        h._ar,
                        compact: true,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Carte postale : phrase prête à copier, avec le nom d'une destination.
class _PostcardTool extends StatefulWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _PostcardTool(this.host, this.all);

  @override
  State<_PostcardTool> createState() => _PostcardToolState();
}

class _PostcardToolState extends State<_PostcardTool> {
  final math.Random _rnd = math.Random();
  Map<String, dynamic>? _d;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _d = _pickOne();
  }

  Map<String, dynamic>? _pickOne() {
    if (widget.all.isEmpty) return null;
    return widget.all[_rnd.nextInt(widget.all.length)];
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final String nom = _d == null ? '' : '${_d!['nom']}';
    final String text = h.t('postcardText').replaceFirst('%s', nom);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _HomeState._ink,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(text, style: h._display(18, color: _HomeState._paper, height: 1.45)),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: h._inkButton(
                _copied ? h.t('copiedText') : h.t('copyText'),
                    () {
                  Clipboard.setData(ClipboardData(text: text));
                  HapticFeedback.selectionClick();
                  setState(() {
                    _copied = true;
                  });
                },
                h._ar,
              ),
            ),
            const SizedBox(width: 12),
            h._roundButton(Icons.refresh_rounded, () {
              setState(() {
                _d = _pickOne();
                _copied = false;
              });
            }, size: 52, tooltip: h.t('newCard')),
          ],
        ),
      ],
    );
  }
}

/// Zoom : photo pincée et zoomable, avec défilement entre les destinations.
class _ZoomTool extends StatefulWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _ZoomTool(this.host, this.all);

  @override
  State<_ZoomTool> createState() => _ZoomToolState();
}

class _ZoomToolState extends State<_ZoomTool> {
  int _i = 0;

  void _step(int k) {
    if (widget.all.isEmpty) return;
    setState(() {
      _i = (_i + k + widget.all.length) % widget.all.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final Map<String, dynamic>? d = widget.all.isEmpty ? null : widget.all[_i % widget.all.length];
    final double w = MediaQuery.of(context).size.width - 50;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 260,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: d == null
                  ? const SizedBox.shrink()
                  : SizedBox(width: w, height: 260, child: h._photo('${d['image']}')),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          h.t('zoomHint'),
          textAlign: TextAlign.center,
          style: h._text(12, color: _HomeState._muted, style: FontStyle.italic),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            h._roundButton(Icons.chevron_left_rounded, () => _step(-1), size: 44),
            Expanded(
              child: Text(
                d == null ? '' : '${d['nom']}',
                textAlign: TextAlign.center,
                style: h._display(20),
              ),
            ),
            h._roundButton(Icons.chevron_right_rounded, () => _step(1), size: 44),
          ],
        ),
      ],
    );
  }
}

/// Journal : une note personnelle par destination, enregistrée sur l'appareil.
class _JournalTool extends StatefulWidget {
  final _HomeState host;
  final List<Map<String, dynamic>> all;
  const _JournalTool(this.host, this.all);

  @override
  State<_JournalTool> createState() => _JournalToolState();
}

class _JournalToolState extends State<_JournalTool> {
  final TextEditingController _c = TextEditingController();
  String? _opened;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _select(String id) {
    setState(() {
      _opened = _opened == id ? null : id;
      _c.text = widget.host._notes[id] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Map<String, dynamic> d in widget.all) ...<Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _select(h._idOf(d)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text('${d['nom']}', style: h._display(19))),
                  Icon(
                    h._notes.containsKey(h._idOf(d)) ? Icons.edit_note_rounded : Icons.add_rounded,
                    color: h._accent,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (_opened == h._idOf(d)) ...<Widget>[
            TextField(
              controller: _c,
              maxLines: 4,
              style: h._text(15, color: _HomeState._ink, height: 1.5),
              decoration: InputDecoration(
                hintText: h.t('journalHint'),
                hintStyle: h._text(14, color: _HomeState._muted),
                filled: true,
                fillColor: _HomeState._field,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            h._inkButton(h.t('saveNote'), () {
              h._setNote(h._idOf(d), _c.text);
              setState(() {
                _opened = null;
              });
            }, h._ar),
            const SizedBox(height: 12),
          ],
          Container(height: 1, color: _HomeState._line),
        ],
      ],
    );
  }
}

// ───────────────────────── Page Favoris ─────────────────────────

class _FavoritesPage extends StatefulWidget {
  final _HomeState host;
  const _FavoritesPage({required this.host});

  @override
  State<_FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<_FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final _HomeState h = widget.host;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final List<Map<String, dynamic>> favs = h._sorted(
      h.getDestinations().where((Map<String, dynamic> d) => h._isFav(d)).toList(),
    );

    return Scaffold(
      backgroundColor: _HomeState._paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 22, 6),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: _HomeState._ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(h.t('favorites'), style: h._display(30, height: 1.1)),
                  ),
                  Text(
                    '${favs.length}',
                    style: h._text(13, color: _HomeState._muted, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favs.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    h.t('noFavorites'),
                    textAlign: TextAlign.center,
                    style: h._text(15, color: _HomeState._muted, height: 1.6),
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
                physics: const BouncingScrollPhysics(),
                itemCount: favs.length,
                separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 22),
                itemBuilder: (BuildContext context, int i) => _tile(h, favs[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(_HomeState h, Map<String, dynamic> d) {
    final double w = MediaQuery.of(context).size.width - 64;
    return _Pressable(
      semanticLabel: '${d['nom']}',
      onTap: () => h._open(d),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _HomeState._card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: h._softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    h._photo(d['image'] as String, logicalWidth: w),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          h._toggleFav(d);
                          setState(() {});
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _HomeState._card,
                          ),
                          child: Icon(Icons.favorite_rounded, size: 18, color: h._accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 8, 8),
              child: Text('${d['nom']}', style: h._display(24, height: 1.12)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                '${d['description']}',
                style: h._text(13.5, color: _HomeState._muted, height: 1.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}