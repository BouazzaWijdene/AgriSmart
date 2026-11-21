import 'package:flutter/foundation.dart';
import 'package:projet/models/meteo.dart';
import 'package:projet/service/meteo_service.dart';

enum MeteoEtat {
  chargement,
  succes,
  erreur,
}

class MeteoProvider extends ChangeNotifier {
  final MeteoService _service = MeteoService();

  Meteo? _meteo;
  MeteoEtat _etat = MeteoEtat.chargement;
  String? _erreur;

  Meteo? get meteo => _meteo;
  MeteoEtat get etat => _etat;
  String? get erreur => _erreur;

  Future<void> chargerMeteo() async {
    _etat = MeteoEtat.chargement;
    _erreur = null;
    notifyListeners();

    try {
      _meteo = await _service.charger();
      _etat = MeteoEtat.succes;
    } on MeteoException catch (e) {
      _erreur = e.message;
      _etat = MeteoEtat.erreur;
    } catch (_) {
      _erreur = 'Une erreur inattendue est survenue';
      _etat = MeteoEtat.erreur;
    }

    notifyListeners();
  }
}
