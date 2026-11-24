import 'package:flutter/material.dart';
import 'package:projet/models/zone.dart';
import 'package:projet/screens/zone_form_page.dart';
import 'package:projet/service/irrigation_conseil_service.dart';
import 'package:projet/theme/app_them.dart';

class ZoneDetailPage extends StatelessWidget {
  final Zone zone;
  final List<String> nomsAutres;

  const ZoneDetailPage({
    super.key,
    required this.zone,
    this.nomsAutres = const [],
  });

  Future<void> _modifier(BuildContext context) async {
    final nouvelle = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneFormPage(
          zone: zone,
          nomsExistants: nomsAutres,
        ),
      ),
    );

    if (nouvelle == null || !context.mounted) return;

    Navigator.pop(context, nouvelle);
  }

  @override
  Widget build(BuildContext context) {
    final couleur = zone.besoinIrrigation
        ? AppTheme.echec
        : AppTheme.succes;

    final longueur =
    zone.culture.length < 4 ? zone.culture.length : 4;

    final texte = Theme.of(context).textTheme;

    final conseil = IrrigationConseilService.evaluer(
      zone: zone,
      temperatureC: null,
      precipitationMm: null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(zone.nom),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                child: Text(
                  zone.culture.substring(0, longueur),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.nom,
                      style: texte.headlineSmall,
                    ),
                    Text(
                      zone.culture,
                      style: texte.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            '${zone.humidite.toStringAsFixed(0)} %',
            style: texte.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: (zone.humidite / 100).clamp(0.0, 1.0),
            color: couleur,
            minHeight: 10,
          ),
          const SizedBox(height: 12),

          Text(
            diagnostic(zone),
            style: texte.titleMedium?.copyWith(
              color: couleur,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.water_drop),
                  title: const Text('Humidité actuelle'),
                  trailing: Text(
                    '${zone.humidite.toStringAsFixed(0)} %',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Seuil d’irrigation'),
                  trailing: Text(
                    '${zone.seuil.toStringAsFixed(0)} %',
                  ),
                ),
                ListTile(
                  leading: Icon(
                    zone.vanneOuverte
                        ? Icons.toggle_on
                        : Icons.toggle_off,
                  ),
                  title: const Text('Vanne'),
                  trailing: Text(
                    zone.vanneOuverte ? 'Ouverte' : 'Fermée',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: conseil.urgent
                  ? const Color(0xFFFFF4E5)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: conseil.urgent
                    ? const Color(0xFFE6A100)
                    : const Color(0xFF2E7D32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conseil.titre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conseil.message,
                  style: const TextStyle(
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () => _modifier(context),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier cette zone'),
          ),
        ],
      ),
    );
  }
}