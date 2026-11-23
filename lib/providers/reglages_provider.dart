
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReglagesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  static const String _cleTheme = 'theme_mode';

  late ThemeMode _themeMode;

  ReglagesProvider(this._prefs) {
    final themeSauvegarde = _prefs.getString(_cleTheme);

    switch (themeSauvegarde) {
      case 'clair':
        _themeMode = ThemeMode.light;
        break;
      case 'sombre':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> changerTheme(ThemeMode nouveauTheme) async {
    _themeMode = nouveauTheme;

    String valeur;

    switch (nouveauTheme) {
      case ThemeMode.light:
        valeur = 'clair';
        break;
      case ThemeMode.dark:
        valeur = 'sombre';
        break;
      case ThemeMode.system:
        valeur = 'systeme';
        break;
    }

    await _prefs.setString(_cleTheme, valeur);
    notifyListeners();
  }
}
