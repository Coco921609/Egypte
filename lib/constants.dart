import 'package:flutter/material.dart';

class EgyptianTheme {
  // Couleurs principales
  static const Color background = Color(0xFF0E131F); // Nuit profonde du désert
  static const Color cardDark = Color(0xFF182236); // Bleu Lapis-Lazuli royal
  static const Color cardBorder = Color(0xFF2D3B56); // Bordure subtile bleu/or

  static const Color primaryGradientStart = Color(0xFFE5C158); // Or Pharaonique
  static const Color primaryGradientEnd = Color(0xFFC29B38); // Or Ancien / Cuivré
  static const Color accentGold = Color(0xFFFFD700); // Or éclatant

  static const Color textLight = Color(0xFFFDF8E2); // Sable clair / Papyrus
  static const Color textMuted = Color(0xFFB5A88F); // Sable grisé

  // Couleurs d'accent et variantes
  static const Color coral = Color(0xFFD9534F); // Terre cuite / Corail
  static const Color desertCoral = Color(0xFFD9534F);
  static const Color nileTeal = Color(0xFF0288D1); // Bleu Nil
  static const Color oasisGreen = Color(0xFF2E7D32); // Vert Oasis

  // Styles de texte réutilisables
  static const TextStyle headingStyle = TextStyle(
    color: textLight,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    color: textMuted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

// ==========================================
// PAINTER PYRAMIDE (STYLE ÉGYPTIEN)
// ==========================================
class PyramidPainter extends CustomPainter {
  final Color color;
  PyramidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Sommet
    path.lineTo(size.width, size.height); // Coin bas-droit
    path.lineTo(0, size.height); // Coin bas-gauche
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// DONNÉES LOCALISÉES (SLIDES & UI)
// ==========================================
final Map<String, List<Map<String, String>>> localizedSlides = {
  'fr': [
    {
      "tag": "01. MYSTÈRES",
      "title": "Saviez-vous ?",
      "highlight": "Terres des Pharaons",
      "description": "L'Égypte ancienne abrite des monuments colossaux et des secrets millénaires encore inexplorés.",
      "icon": "compass"
    },
    {
      "tag": "02. ÉVASION",
      "title": "Le Nil majestueux !",
      "highlight": "Dépaysement total",
      "description": "De Gizeh à Louxor : naviguez sur le fleuve sacré au cœur de paysages intemporels.",
      "icon": "landscape"
    },
    {
      "tag": "03. INSOLITE",
      "title": "Trésors sacrés !",
      "highlight": "Merveilles antiques",
      "description": "Partez à la découverte des vallées secrètes, des temples sublimes et des hiéroglyphes mystiques.",
      "icon": "stars"
    },
    {
      "tag": "04. EXPLORATION",
      "title": "Prêt pour l'aventure ?",
      "highlight": "Terre de légende",
      "description": "Découvrez le Pays des Pyramides sous un tout autre angle dès maintenant.",
      "icon": "explore"
    },
  ],
  'en': [
    {
      "tag": "01. MYSTERIES",
      "title": "Did you know ?",
      "highlight": "Land of the Pharaohs",
      "description": "Ancient Egypt holds colossal monuments and millennia-old secrets yet to be fully explored.",
      "icon": "compass"
    },
    {
      "tag": "02. GETAWAY",
      "title": "The majestic Nile !",
      "highlight": "Total escape",
      "description": "From Giza to Luxor: sail along the sacred river through timeless landscapes.",
      "icon": "landscape"
    },
    {
      "tag": "03. UNUSUAL",
      "title": "Sacred treasures !",
      "highlight": "Ancient wonders",
      "description": "Explore secret valleys, magnificent temples, and mystical hieroglyphs.",
      "icon": "stars"
    },
    {
      "tag": "04. EXPLORATION",
      "title": "Ready for adventure ?",
      "highlight": "Land of legends",
      "description": "Discover the Land of the Pyramids from a whole new angle right now.",
      "icon": "explore"
    },
  ],
  'ar': [
    {
      "tag": "01. أسرار",
      "title": "هل تعلم ؟",
      "highlight": "أرض الفراعنة",
      "description": "تحتضن مصر القديمة معالم ضخمة وأسرارًا تعود لآلاف السنين لم يتم اكتشافها بالكامل بعد.",
      "icon": "compass"
    },
    {
      "tag": "02. هروب",
      "title": "النيل العظيم !",
      "highlight": "تغيير جو كامل",
      "description": "من الجيزة إلى الأقصر: أبحر في النهر المقدس وسط مناظر طبيعية خالدة.",
      "icon": "landscape"
    },
    {
      "tag": "03. غريب",
      "title": "كنوز مقدسة !",
      "highlight": "عجائب أثرية",
      "description": "انطلق لاستكشاف الوديان السرية والمعابد الرائعة والرموز الهيروغليفية الغامضة.",
      "icon": "stars"
    },
    {
      "tag": "04. استكشاف",
      "title": "مستعد للمغامرة ؟",
      "highlight": "أرض الأساطير",
      "description": "اكتشف أرض الأهرامات من منظور آخر تماماً ابتداءً من الآن.",
      "icon": "explore"
    },
  ],
};

final Map<String, Map<String, String>> localizedUi = {
  'fr': {
    'welcome': 'Bienvenue !',
    'validate': 'Valider',
    'next': 'Continuer',
    'finish': 'Créer mon profil',
    'country': 'Égypte',
  },
  'en': {
    'welcome': 'Welcome !',
    'validate': 'Validate',
    'next': 'Continue',
    'finish': 'Create my profile',
    'country': 'Egypt',
  },
  'ar': {
    'welcome': 'مرحبًا !',
    'validate': 'تأكيد',
    'next': 'متابعة',
    'finish': 'إنشاء ملفي الشخصي',
    'country': 'مصر',
  },
};

final Map<String, List<Map<String, dynamic>>> localizedLanguagesData = {
  'fr': [
    {'code': 'fr', 'name': 'Français', 'question': 'Quelle est votre langue ?', 'color': EgyptianTheme.nileTeal, 'icon': Icons.language},
    {'code': 'en', 'name': 'English', 'question': 'Quelle est votre langue ?', 'color': EgyptianTheme.accentGold, 'icon': Icons.language},
    {'code': 'ar', 'name': 'العربية', 'question': 'Quelle est votre langue ?', 'color': EgyptianTheme.coral, 'icon': Icons.language},
  ],
  'en': [
    {'code': 'fr', 'name': 'Français', 'question': 'What is your language?', 'color': EgyptianTheme.nileTeal, 'icon': Icons.language},
    {'code': 'en', 'name': 'English', 'question': 'What is your language?', 'color': EgyptianTheme.accentGold, 'icon': Icons.language},
    {'code': 'ar', 'name': 'العربية', 'question': 'What is your language?', 'color': EgyptianTheme.coral, 'icon': Icons.language},
  ],
  'ar': [
    {'code': 'fr', 'name': 'Français', 'question': 'ما هي لغتك المفضلة؟', 'color': EgyptianTheme.nileTeal, 'icon': Icons.language},
    {'code': 'en', 'name': 'English', 'question': 'ما هي لغتك المفضلة؟', 'color': EgyptianTheme.accentGold, 'icon': Icons.language},
    {'code': 'ar', 'name': 'العربية', 'question': 'ما هي لغتك المفضلة؟', 'color': EgyptianTheme.coral, 'icon': Icons.language},
  ],
};