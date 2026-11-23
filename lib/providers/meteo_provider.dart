
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet/models/meteo.dart';
import 'package:projet/service/meteo_service.dart';

enum MeteoEtat {
  chargement,
  succes,
  erreur,
}

class MeteoProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final MeteoService _service = MeteoService();

  static const String _cleMeteo = 'meteo_cache';
  static const String _cleDate = 'meteo_date';

  Meteo? _meteo;
  MeteoEtat _etat = MeteoEtat.chargement;
  String? _erreur;

  bool _horsLigne = false;
  DateTime? _miseAJour;

  MeteoProvider(this._prefs);

  Meteo? get meteo => _meteo;
  MeteoEtat get etat => _etat;
  String? get erreur => _erreur;
  bool get horsLigne => _horsLigne;
  DateTime? get miseAJour => _miseAJour;

  Future<void> charger() => chargerMeteo();

  Future<void> chargerMeteo() async {
    _etat = MeteoEtat.chargement;
    _erreur = null;
    notifyListeners();

    try {
      final nouvelleMeteo = await _service.charger();

      final nouvelleDate = DateTime.now();

      await _prefs.setString(
        _cleMeteo,
        jsonEncode(nouvelleMeteo.toJson()),
      );

      await _prefs.setString(
        _cleDate,
        nouvelleDate.toIso8601String(),
      );

      _meteo = nouvelleMeteo;
      _miseAJour = nouvelleDate;
      _horsLigne = false;
      _etat = MeteoEtat.succes;
    } on MeteoException catch (e) {
      await _chargerCache(e.message);
    } catch (_) {
      await _chargerCache(
        'Une erreur inattendue est survenue',
      );
    }

    notifyListeners();
  }

  Future<void> _chargerCache(String message) async {
    final donnees = _prefs.getString(_cleMeteo);
    final date = _prefs.getString(_cleDate);

    if (donnees != null) {
      try {
        final json = jsonDecode(donnees) as Map<String, dynamic>;

        _meteo = Meteo.fromCacheJson(json);
        _miseAJour =
        date != null ? DateTime.tryParse(date) : null;

        _horsLigne = true;
        _erreur = null;
        _etat = MeteoEtat.succes;
        return;
      } catch (_) {
        // Le cache est invalide.
      }
    }

    _meteo = null;
    _miseAJour = null;
    _horsLigne = false;
    _erreur = message;
    _etat = MeteoEtat.erreur;
  }
}

