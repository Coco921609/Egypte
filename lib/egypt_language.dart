import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Langue commune à toutes les pages de l'application.
/// La sélection est propagée immédiatement et conservée entre les sessions.
class EgyptLanguage {
  EgyptLanguage._();

  static const List<String> supportedLanguages = ['fr', 'en', 'ar'];
  static const String _preferenceKey = 'selected_language';

  static final ValueNotifier<String> language = ValueNotifier<String>('fr');
  static Future<void>? _initialization;

  static Future<void> initialize() {
    return _initialization ??= _loadSavedLanguage();
  }

  static Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_preferenceKey);
    if (saved != null && supportedLanguages.contains(saved)) {
      language.value = saved;
    }
  }

  static Future<void> setLanguage(String value) async {
    if (!supportedLanguages.contains(value)) return;
    await initialize();
    if (language.value != value) {
      language.value = value;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, value);
  }
}
