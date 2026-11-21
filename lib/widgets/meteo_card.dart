
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet/providers/meteo_provider.dart';

class MeteoCard extends StatelessWidget {
  const MeteoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeteoProvider>(
      builder: (context, provider, child) {
        switch (provider.etat) {
          case MeteoEtat.chargement:
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );

          case MeteoEtat.erreur:
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 35),
                    const SizedBox(height: 10),
                    Text(provider.erreur ?? 'Erreur météo'),
                    TextButton(
                      onPressed: provider.chargerMeteo,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );

          case MeteoEtat.succes:
            final meteo = provider.meteo!;
            final pluie = meteo.pluieTotale;

            final conseil = pluie >= 5
                ? 'Pluie prévue : repoussez l’irrigation'
                : 'Pas de pluie significative prévue';

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Météo de Kébili',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text('Température : ${meteo.temperature} °C'),
                    Text('Humidité : ${meteo.humiditeAir} %'),
                    Text('Vent : ${meteo.vent} km/h'),
                    const Divider(),
                    const Text(
                      'Prévisions des 3 prochains jours',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...meteo.previsions.map(
                          (jour) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${jour.date.day}/${jour.date.month}',
                        ),
                        subtitle: Text(
                          'Max: ${jour.tMax} °C | Min: ${jour.tMin} °C',
                        ),
                        trailing: Text('${jour.pluie} mm'),
                      ),
                    ),
                    Text(
                      'Pluie totale : ${meteo.pluieTotale} mm',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      conseil,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
