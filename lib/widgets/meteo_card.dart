
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet/providers/meteo_provider.dart';

class MeteoCard extends StatelessWidget {
  const MeteoCard({super.key});

  static const vert = Color(0xFF245C40);
  static const texte = Color(0xFF34463A);
  static const secondaire = Color(0xFF657168);

  @override
  Widget build(BuildContext context) {
    return Consumer<MeteoProvider>(
      builder: (context, provider, child) {
        switch (provider.etat) {
          case MeteoEtat.chargement:
            return _conteneur(
              child: const Padding(
                padding: EdgeInsets.all(25),
                child: Center(
                  child: CircularProgressIndicator(color: vert),
                ),
              ),
            );

          case MeteoEtat.erreur:
            return _conteneur(
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.orange,
                    size: 38,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.erreur ?? 'Erreur météo',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: texte),
                  ),
                  TextButton.icon(
                    onPressed: provider.chargerMeteo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );

          case MeteoEtat.succes:
            final meteo = provider.meteo;

            if (meteo == null) {
              return _conteneur(
                child: const Text(
                  'Aucune donnée météo disponible',
                  style: TextStyle(color: texte),
                ),
              );
            }

            final pluie = meteo.pluieTotale;
            final conseil = pluie >= 5
                ? 'Pluie prévue : repoussez l’irrigation si les conditions du sol le permettent.'
                : 'Pas de pluie significative prévue : vérifiez les besoins en irrigation.';

            return _conteneur(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: Colors.orange,
                        size: 25,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Météo de Kébili',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: vert,
                          ),
                        ),
                      ),
                      Text(
                        'Open-Meteo',
                        style: TextStyle(
                          fontSize: 10,
                          color: secondaire,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          size: 43,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${meteo.temperature.toStringAsFixed(1)} °C',
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: vert,
                                ),
                              ),
                              const Text(
                                'Température actuelle',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaire,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _infoMeteo(
                          Icons.water_drop_outlined,
                          'Humidité',
                          '${meteo.humiditeAir} %',
                          Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoMeteo(
                          Icons.air,
                          'Vent',
                          '${meteo.vent.toStringAsFixed(1)} km/h',
                          Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Prévisions des prochains jours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: vert,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...meteo.previsions.map((jour) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 17,
                            color: vert,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              '${jour.date.day}/${jour.date.month}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: texte,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '${jour.tMax.toStringAsFixed(0)}° / ${jour.tMin.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: texte,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Icon(
                            Icons.water_drop,
                            color: Colors.blue,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${jour.pluie.toStringAsFixed(1)} mm',
                            style: const TextStyle(
                              fontSize: 11,
                              color: secondaire,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 25),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total des précipitations',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: texte,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${pluie.toStringAsFixed(1)} mm',
                        style: const TextStyle(
                          color: vert,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2DF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFFD88716),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            conseil,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFF65491F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }

  Widget _conteneur({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoMeteo(
      IconData icon,
      String titre,
      String valeur,
      Color couleur,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5EF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: couleur, size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    color: secondaire,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valeur,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: texte,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
