import 'package:projet/models/zone.dart';

class RapportService {
  static String genererBilanExploitation(List<Zone> zones) {
    final maintenant = DateTime.now();
    final dateFormatee =
        '${maintenant.day.toString().padLeft(2, '0')}/${maintenant.month.toString().padLeft(2, '0')}/${maintenant.year} '
        'à ${maintenant.hour.toString().padLeft(2, '0')}:${maintenant.minute.toString().padLeft(2, '0')}';

    if (zones.isEmpty) {
      return '=== RAPPORT AGRISMART (Kébili) ===\n'
          'Date : $dateFormatee\n\n'
          'Aucune parcelle enregistrée pour le moment.';
    }

    final total = zones.length;
    final aIrriguer = zones.where((z) => z.besoinIrrigation).toList();
    final humiditeMoyenne =
        zones.map((z) => z.humidite).reduce((a, b) => a + b) / total;

    final buffer = StringBuffer()
      ..writeln('=== RAPPORT AGRISMART — KÉBILI ===')
      ..writeln('Date du relevé : $dateFormatee')
      ..writeln('')
      ..writeln('--- SYNTHÈSE GLOBALE ---')
      ..writeln('• Nombre total de parcelles : $total')
      ..writeln('• Humidité moyenne du sol : ${humiditeMoyenne.toStringAsFixed(1)} %')
      ..writeln('• Parcelles à irriguer : ${aIrriguer.length} / $total')
      ..writeln('')
      ..writeln('--- DÉTAIL DES PARCELLES ---');

    for (final z in zones) {
      final statut = z.besoinIrrigation ? 'À IRRIGUER' : 'OK';
      buffer.writeln(
        '• ${z.nom} : ${z.humidite.toStringAsFixed(0)} % [$statut]',
      );
    }

    if (aIrriguer.isNotEmpty) {
      buffer
        ..writeln('')
        ..writeln('--- RECOMMANDATION ---')
        ..writeln(
          'Prioriser l’arrosage sur : ${aIrriguer.map((z) => z.nom).join(', ')}.',
        );
    }

    return buffer.toString();
  }
}