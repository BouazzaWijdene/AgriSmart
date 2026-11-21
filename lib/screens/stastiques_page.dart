import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:projet/providers/zones_provider.dart';
import 'package:projet/providers/meteo_provider.dart';
import 'package:projet/theme/app_them.dart';
import 'package:projet/widgets/resume_exploitation.dart';
import 'package:projet/widgets/meteo_card.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeteoProvider>().chargerMeteo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final zones = context.watch<ZonesProvider>().zones;

    final tri = [...zones]
      ..sort((a, b) => a.humidite.compareTo(b.humidite));

    final aIrriguer =
        zones.where((z) => z.besoinIrrigation).length;

    final pourcentage = zones.isEmpty
        ? 0
        : (aIrriguer * 100 / zones.length).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Statistiques'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MeteoCard(),
          const SizedBox(height: 16),

          if (zones.isEmpty)
            const Center(
              child: Text('Aucune donnée à afficher'),
            )
          else ...[
            ResumeExploitation(zones: zones),
            const SizedBox(height: 16),

            Text(
              '$aIrriguer zone(s) sur ${zones.length} à irriguer ($pourcentage %)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            Text(
              'Humidité par zone',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            for (final z in tri)
              ListTile(
                title: Text(z.nom),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(
                    value: (z.humidite / 100).clamp(0.0, 1.0),
                    color: z.besoinIrrigation
                        ? AppTheme.echec
                        : AppTheme.succes,
                    minHeight: 8,
                  ),
                ),
                trailing: Text(
                  '${z.humidite.toStringAsFixed(0)} %',
                ),
              ),
          ],
        ],
      ),
    );
  }
}
