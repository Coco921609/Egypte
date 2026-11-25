import 'package:flutter/material.dart';
import '../lib/langues.dart' show LanguesPage;
import '../lib/presentation.dart';
import '../lib/profil.dart' show ProfileScreen;
import '../lib/accueil.dart' show AccueilScreen;
import '../lib/parametres.dart';
import '../lib/le caire.dart';
import '../lib/alexandrie.dart';
import '../lib/louxor.dart';
import '../lib/assouan.dart';
import '../lib/siwa.dart';
import '../lib/fayoum.dart';
import '../lib/desert.dart';
import '../lib/sharm.dart';
import '../lib/Hurghada.dart';
import '../lib/gastronomie_page.dart';
import '../lib/hieroglyphics_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final screen = Uri.base.queryParameters['screen'] ?? 'language';

  final Widget page = switch (screen) {
    'language' => const LanguesPage(isProfileCreated: false),
    'presentation' => const PresentationScreen(languageCode: 'fr'),
    'profile' => const ProfileScreen(languageCode: 'fr'),
    'home' => const AccueilScreen(
        userName: 'Visiteur',
        languageCode: 'fr',
        selectedAvatar: '👨🏽',
        themeColor: Color(0xFFE5C158),
      ),
    'settings' => const ParametresPage(languageCode: 'fr'),
    'cairo' => const LeCairePage(),
    'alexandria' => const AlexandriePage(),
    'luxor' => const LouxorPage(),
    'aswan' => const AssouanPage(),
    'siwa' => const SiwaPage(),
    'fayoum' => const FayoumPage(),
    'desert' => const DesertPage(),
    'sharm' => const SharmElSheikhPage(),
    'hurghada' => const HurghadaPage(),
    'gastronomy' => const GastronomiePage(),
    'hieroglyphs' => const HieroglyphicsPage(),
    _ => const LanguesPage(isProfileCreated: false),
  };

  runApp(MaterialApp(
    title: 'Égypte – aperçu des écrans',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0E131F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE5C158),
        secondary: Color(0xFFC29B38),
        surface: Color(0xFF182236),
      ),
    ),
    home: page,
  ));
}
