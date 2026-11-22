
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:projet/models/zone.dart';
import 'package:projet/providers/zones_provider.dart';
import 'package:projet/providers/meteo_provider.dart';
import 'package:projet/widgets/meteo_card.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  static const vert = Color(0xFF245C40);
  static const fond = Color(0xFFF5F8F3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MeteoProvider>().chargerMeteo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZonesProvider>();
    final zones = provider.zones;
    final humidite = humiditeMoyenne(zones);

    return Scaffold(
      backgroundColor: fond,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bonjour 👋',
                              style: TextStyle(
                                color: Color(0xFF5F6B62),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Bienvenue sur AgriSmart',
                              style: TextStyle(
                                color: vert,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gestion intelligente des oasis',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE1EDE3),
                        child: Icon(
                          Icons.agriculture,
                          color: vert,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/oasis_banner.jpg',
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 190,
                              width: double.infinity,
                              color: const Color(0xFFDCEBDD),
                              child: const Icon(
                                Icons.forest,
                                color: vert,
                                size: 65,
                              ),
                            );
                          },
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 17,
                          right: 17,
                          bottom: 17,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nos oasis, notre richesse',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Cultures intercalaires et palmiers dattiers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _titreSection('Vue générale', 'Aujourd’hui'),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _statCard(
                        icon: Icons.landscape,
                        titre: 'Zones agricoles',
                        valeur: '${provider.nombre}',
                        couleur: const Color(0xFF43845A),
                      ),
                      _statCard(
                        icon: Icons.water_drop,
                        titre: 'Humidité moyenne',
                        valeur: '${humidite.toStringAsFixed(0)} %',
                        couleur: const Color(0xFF3989C9),
                      ),
                      _statCard(
                        icon: Icons.warning_amber_rounded,
                        titre: 'À irriguer',
                        valeur: '${provider.nombreAIrriguer}',
                        couleur: const Color(0xFFE69A36),
                      ),
                      _statCard(
                        icon: Icons.eco,
                        titre: 'Cultures différentes',
                        valeur: '${zones.map((z) => z.culture).toSet().length}',
                        couleur: const Color(0xFF299B91),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _titreSection(
                    'Cultures intercalaires',
                    'Entre les palmiers',
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: const [
                      _CultureCard(
                        image: 'assets/images/tomato.webp',
                        nom: 'Tomates',
                        couleur: Color(0xFFFFF0EA),
                      ),
                      _CultureCard(
                        image: 'assets/images/carrot.webp',
                        nom: 'Carottes',
                        couleur: Color(0xFFFFF4E5),
                      ),
                      _CultureCard(
                        image: 'assets/images/parsley.jpg',
                        nom: 'Persil',
                        couleur: Color(0xFFEAF5E9),
                      ),
                      _CultureCard(
                        image: 'assets/images/pepper.webp',
                        nom: 'Poivrons',
                        couleur: Color(0xFFFFEEEE),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _titreSection('Météo de Kébili', 'Prévisions'),
                  const SizedBox(height: 12),
                  const MeteoCard(),

                  const SizedBox(height: 24),

                  _titreSection(
                    'État des parcelles',
                    '${zones.length} zones',
                  ),
                  const SizedBox(height: 12),

                  if (zones.isEmpty)
                    _emptyState()
                  else
                    ...zones.map((zone) => _zoneCard(zone)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titreSection(String titre, String sousTitre) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            titre,
            style: const TextStyle(
              color: vert,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          sousTitre,
          style: const TextStyle(
            color: Color(0xFF657168),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String titre,
    required String valeur,
    required Color couleur,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: couleur, size: 22),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valeur,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF26382D),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.15,
                    color: Color(0xFF59665D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneCard(Zone zone) {
    final besoin = zone.besoinIrrigation;
    final couleur = besoin
        ? const Color(0xFFE28A16)
        : const Color(0xFF32834A);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.grass, color: vert),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.nom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF26382D),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  zone.culture,
                  style: const TextStyle(
                    color: Color(0xFF657168),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (zone.humidite / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: couleur,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${zone.humidite.toStringAsFixed(0)} %',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF26382D),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                besoin ? 'À irriguer' : 'Correct',
                style: TextStyle(
                  color: couleur,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.agriculture, size: 40, color: vert),
          SizedBox(height: 10),
          Text(
            'Aucune parcelle enregistrée',
            style: TextStyle(color: Color(0xFF435348)),
          ),
        ],
      ),
    );
  }
}

class _CultureCard extends StatelessWidget {
  final String image;
  final String nom;
  final Color couleur;

  const _CultureCard({
    required this.image,
    required this.nom,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF245C40),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              nom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF354A3B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
