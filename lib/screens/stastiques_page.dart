
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:projet/providers/zones_provider.dart';
import 'package:projet/models/zone.dart';

class StatistiquesPage extends StatelessWidget {
  const StatistiquesPage({super.key});

  static const Color vert = Color(0xFF245C40);
  static const Color fond = Color(0xFFF5F8F3);

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

    final moyenne = humiditeMoyenne(zones);

    return Scaffold(
      backgroundColor: fond,
      appBar: AppBar(
        backgroundColor: fond,
        elevation: 0,
        title: const Text(
          'Statistiques',
          style: TextStyle(
            color: vert,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: zones.isEmpty
          ? const Center(
        child: Text('Aucune donnée à afficher'),
      )
          : ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Vue d’ensemble de votre exploitation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          // Résumé principal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: vert,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Humidité moyenne du sol',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${moyenne.toStringAsFixed(1)} %',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (moyenne / 100).clamp(0.0, 1.0),
                    minHeight: 9,
                    backgroundColor: Colors.white24,
                    color: Colors.lightGreenAccent,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${zones.length} parcelles suivies',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Indicateurs
          Row(
            children: [
              Expanded(
                child: _indicateur(
                  'Zones à irriguer',
                  '$aIrriguer',
                  Icons.water_drop,
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _indicateur(
                  'Besoin en irrigation',
                  '$pourcentage %',
                  Icons.warning_amber,
                  Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            'Humidité par parcelle',
            style: TextStyle(
              color: vert,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...tri.map((zone) => _humiditeCard(zone)),
        ],
      ),
    );
  }

  Widget _indicateur(
      String titre,
      String valeur,
      IconData icon,
      Color couleur,
      ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: couleur, size: 27),

          const SizedBox(height: 12),

          Text(
            valeur,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: vert,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            titre,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _humiditeCard(Zone zone) {
    final besoin = zone.besoinIrrigation;
    final couleur = besoin ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grass, color: vert),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  zone.nom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                '${zone.humidite.toStringAsFixed(0)} %',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: vert,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            zone.culture,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (zone.humidite / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: couleur,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            besoin ? 'Besoin d’irrigation' : 'Niveau correct',
            style: TextStyle(
              color: couleur,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
