import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'language_page.dart';

// --- 1. COMPORTEMENT DE DÉFILEMENT GLOBAL (WEB/MOBILE) ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Retire l'effet élastique partout pour un comportement fluide type Web
    return const ClampingScrollPhysics();
  }
}

// --- 2. POINT D'ENTRÉE DE L'APPLICATION ---
void main() async {
  // Initialise les liaisons Flutter pour sécuriser les appels natifs asynchrones
  WidgetsFlutterBinding.ensureInitialized();

  // Fixe l'orientation de l'application en mode Portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Personnalise la barre de statut système (transparente avec icônes sombres)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

// --- 3. WIDGET RACINE DE L'APPLICATION ---
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Ajout du constructeur constant (Bonne pratique Flutter)

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Egypts',
      // Application du comportement de défilement personnalisé à l'ensemble de l'application
      scrollBehavior: WebScrollBehavior(),
      home: LanguagePage(),
    );
  }
}