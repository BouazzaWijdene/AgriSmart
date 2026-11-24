import 'package:flutter/material.dart';

enum FiltreZone { toutes, aIrriguer, ok }

class FiltreZonesBar extends StatelessWidget {
  final TextEditingController rechercheController;
  final String termeRecherche;
  final FiltreZone filtreActif;
  final ValueChanged<String> onRechercheChanged;
  final ValueChanged<FiltreZone> onFiltreChanged;
  final VoidCallback onEffacerRecherche;

  const FiltreZonesBar({
    super.key,
    required this.rechercheController,
    required this.termeRecherche,
    required this.filtreActif,
    required this.onRechercheChanged,
    required this.onFiltreChanged,
    required this.onEffacerRecherche,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: rechercheController,
            onChanged: onRechercheChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher une zone (ex. Parcelle Nord)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: termeRecherche.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onEffacerRecherche,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Toutes'),
                selected: filtreActif == FiltreZone.toutes,
                onSelected: (_) => onFiltreChanged(FiltreZone.toutes),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('À irriguer'),
                selected: filtreActif == FiltreZone.aIrriguer,
                onSelected: (_) => onFiltreChanged(FiltreZone.aIrriguer),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Humidité OK'),
                selected: filtreActif == FiltreZone.ok,
                onSelected: (_) => onFiltreChanged(FiltreZone.ok),
              ),
            ],
          ),
        ],
      ),
    );
  }
}