
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:projet/providers/zones_provider.dart';
import 'package:projet/screens/accueil_page.dart';
import 'package:projet/screens/zones_page.dart';
import 'package:projet/screens/stastiques_page.dart';
import 'package:projet/screens/profil_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _onglet = 0;

  @override
  Widget build(BuildContext context) {
    final aIrriguer = context.select<ZonesProvider, int>(
          (provider) => provider.nombreAIrriguer,
    );

    const pages = <Widget>[
      AccueilPage(),
      ZonesPage(),
      StatistiquesPage(),
      ProfilPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _onglet,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _onglet,
        onDestinationSelected: (index) {
          setState(() {
            _onglet = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),

          NavigationDestination(
            icon: Badge(
              label: Text('$aIrriguer'),
              isLabelVisible: aIrriguer > 0,
              child: const Icon(Icons.grass_outlined),
            ),
            selectedIcon: const Icon(Icons.grass),
            label: 'Zones',
          ),

          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistiques',
          ),

          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
