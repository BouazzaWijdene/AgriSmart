
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet/data/jeu_de_donnees.dart';
import 'package:projet/models/zone.dart';
import 'package:projet/providers/auth_provider.dart';

class ZonesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthProvider _authProvider;

  final List<Zone> _zones = [];

  String? _uidActuel;

  static const String _prefixeCle = 'zones_';

  ZonesProvider(this._prefs, this._authProvider) {
    _authProvider.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  List<Zone> get zones => List.unmodifiable(_zones);

  int get nombre => _zones.length;

  int get nombreAIrriguer =>
      _zones.where((z) => z.besoinIrrigation).length;

  List<String> noms({Zone? sauf}) {
    return _zones
        .where((z) => z != sauf)
        .map((z) => z.nom)
        .toList();
  }

  void _onAuthChanged() {
    unawaited(_chargerZonesUtilisateur());
  }

  Future<void> _chargerZonesUtilisateur() async {
    final utilisateur = _authProvider.utilisateur;
    final uid = utilisateur?.uid;

    if (uid == _uidActuel) return;

    _uidActuel = uid;
    _zones.clear();

    if (uid == null) {
      notifyListeners();
      return;
    }

    final cle = '$_prefixeCle$uid';
    final donnees = _prefs.getString(cle);

    if (donnees == null) {
      _zones.addAll(jeuDeDonnees());
      await _sauvegarderZones();
    } else {
      try {
        final liste = jsonDecode(donnees) as List<dynamic>;

        _zones.addAll(
          liste.map(
                (element) => Zone.fromJson(
              Map<String, dynamic>.from(element as Map),
            ),
          ),
        );
      } catch (_) {
        _zones
          ..clear()
          ..addAll(jeuDeDonnees());

        await _sauvegarderZones();
      }
    }

    if (_uidActuel == uid) {
      notifyListeners();
    }
  }

  Future<void> _sauvegarderZones() async {
    final uid = _uidActuel;
    if (uid == null) return;

    final cle = '$_prefixeCle$uid';

    final donnees = jsonEncode(
      _zones.map((zone) => zone.toJson()).toList(),
    );

    await _prefs.setString(cle, donnees);
  }

  void modifierHumidite(Zone zone, double delta) {
    final index = _zones.indexOf(zone);
    if (index == -1) return;

    zone.humidite =
        (zone.humidite + delta).clamp(0.0, 100.0).toDouble();

    _sauvegarderZones();
    notifyListeners();
  }

  void ajouter(Zone zone) {
    _zones.add(zone);
    _sauvegarderZones();
    notifyListeners();
  }

  void remplacer(Zone ancienne, Zone nouvelle) {
    final index = _zones.indexOf(ancienne);
    if (index == -1) return;

    _zones[index] = nouvelle;
    _sauvegarderZones();
    notifyListeners();
  }

  void supprimer(Zone zone) {
    final supprimee = _zones.remove(zone);

    if (supprimee) {
      _sauvegarderZones();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}
