
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:projet/providers/zones_provider.dart';
import 'package:projet/providers/auth_provider.dart';
import 'package:projet/providers/reglages_provider.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirme != true || !context.mounted) return;

    await context.read<AuthProvider>().deconnexion();
  }

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;

    final nombreZones = context.select<ZonesProvider, int>(
          (provider) => provider.nombre,
    );

    final email = context.select<AuthProvider, String>(
          (provider) => provider.utilisateur?.email ?? '',
    );

    final themeMode = context.select<ReglagesProvider, ThemeMode>(
          (provider) => provider.themeMode,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          const Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.agriculture, size: 40),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'Exploitation AgriSmart',
              style: texte.titleLarge,
            ),
          ),

          Center(child: Text(email)),

          const SizedBox(height: 24),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.grass),
            title: const Text('Zones suivies'),
            trailing: Text('$nombreZones'),
          ),

          // Sélection du thème
          const ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Thème de l’application'),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Système'),
                  icon: Icon(Icons.settings_suggest),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Clair'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Sombre'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (choix) {
                context
                    .read<ReglagesProvider>()
                    .changerTheme(choix.first);
              },
            ),
          ),

          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () => _confirmerDeconnexion(context),
          ),

          const SizedBox(height: 16),
          const Divider(),

          Text('À propos', style: texte.titleLarge),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.eco,
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AgriSmart',
                          style: texte.titleMedium,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'AgriSmart est une application de suivi des '
                        'exploitations agricoles. Elle permet de '
                        'consulter les zones cultivées, de suivre '
                        'leur humidité et d’identifier les zones '
                        'qui nécessitent une irrigation.',
                  ),

                  const SizedBox(height: 16),

                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.water_drop_outlined),
                    title: Text('Suivi de l’humidité'),
                    subtitle: Text(
                      'Consulter le niveau d’humidité de chaque zone.',
                    ),
                  ),

                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.bar_chart),
                    title: Text('Statistiques'),
                    subtitle: Text(
                      'Visualiser les données et les besoins en irrigation.',
                    ),
                  ),

                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.agriculture_outlined),
                    title: Text('Gestion des zones'),
                    subtitle: Text(
                      'Ajouter, modifier et supprimer des zones agricoles.',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'AgriSmart - TP8 Flutter',
              style: texte.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
