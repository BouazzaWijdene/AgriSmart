import 'package:projet/models/zone.dart';

class ConseilIrrigation {
  final String titre;
  final String message;
  final bool urgent;

  const ConseilIrrigation({
    required this.titre,
    required this.message,
    required this.urgent,
  });
}

class IrrigationConseilService {
  static ConseilIrrigation evaluer({
    required Zone zone,
    double? temperatureC,
    double? precipitationMm,
  }) {
    final pluiePrevue = (precipitationMm ?? 0) > 0.2;
    final forteChaleur = (temperatureC ?? 0) >= 35;

    if (!zone.besoinIrrigation) {
      return const ConseilIrrigation(
        titre: 'Humidité satisfaisante',
        message: 'Aucune irrigation nécessaire pour le moment.',
        urgent: false,
      );
    }

    if (pluiePrevue) {
      return ConseilIrrigation(
        titre: 'Pluie prévue à Kébili',
        message:
        'Précipitations détectées (${precipitationMm!.toStringAsFixed(1)} mm) : '
            'envisagez de reporter ou réduire l’irrigation de ${zone.nom}.',
        urgent: false,
      );
    }

    if (forteChaleur) {
      return ConseilIrrigation(
        titre: 'Irrigation prioritaire (Chaleur)',
        message:
        'Température élevée (${temperatureC!.toStringAsFixed(0)} °C) : '
            'arroser ${zone.nom} de préférence tôt le matin ou en soirée.',
        urgent: true,
      );
    }

    return ConseilIrrigation(
      titre: 'Irrigation recommandée',
      message:
      'L’humidité de ${zone.nom} (${zone.humidite.toStringAsFixed(0)} %) '
          'nécessite un apport en eau.',
      urgent: true,
    );
  }
}