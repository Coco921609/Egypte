import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'langues.dart';
import 'presentation.dart';
import 'accueil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verrouillage strict en mode PORTRAIT (bloque le mode paysage)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style de la barre d'état
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Lecture de l'état enregistré dans SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // ATTENTION : Ne pas laisser prefs.clear() actif en production,
  // sinon cela efface le profil et la langue à chaque redémarrage de l'application !
  // await prefs.clear();

  final bool isProfileCreated = prefs.getBool('is_profile_created') ?? false;
  final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final String userName = prefs.getString('user_name') ?? '';
  final String userLang = prefs.getString('user_lang') ?? 'fr';
  final String userAvatar = prefs.getString('user_avatar') ?? '👨🏽';

  // Récupération de la couleur personnalisée stockée (avec la bonne clé 'user_theme_color')
  final int? userThemeColorValue = prefs.getInt('user_theme_color');
  final Color userThemeColor = userThemeColorValue != null
      ? Color(userThemeColorValue)
      : const Color(0xFFE5C158); // Valeur par défaut correspondant au thème égyptien

  // 4. Détermination de l'écran initial selon l'état de l'application :
  // - Si le profil existe déjà -> Accueil
  // - Sinon si la langue a déjà été choisie ou l'onboarding vu -> Présentation (OnboardingScreen)
  // - Sinon (première installation / réinstallation complète) -> Sélection de la langue (LanguageSelectScreen)[cite: 4]
  Widget initialScreen;

  if (isProfileCreated) {
    initialScreen = AccueilScreen(
      userName: userName,
      languageCode: userLang,
      selectedAvatar: userAvatar,
      themeColor: userThemeColor, // Transmission de la couleur récupérée
    );
  } else if (hasSeenOnboarding) {
    initialScreen = PresentationScreen(languageCode: userLang);
  } else {
    initialScreen = const LanguesPage(isProfileCreated: false);
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Égypte',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E131F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE5C158),
          secondary: Color(0xFFC29B38),
          surface: Color(0xFF182236),
        ),
      ),

      // Page de démarrage dynamique
      home: initialScreen,
    );
  }
}