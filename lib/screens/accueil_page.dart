import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet/providers/zones_provider.dart';
import 'package:projet/widgets/fiche_exploitation.dart';
import 'package:projet/widgets/resume_exploitation.dart';
import 'package:projet/widgets/zone_card.dart';
import 'package:projet/models/zone.dart';
class AccueilPage extends StatelessWidget {
const AccueilPage({super.key});

@override
Widget build(BuildContext context) {
final provider = context.watch<ZonesProvider>();
final zones = provider.zones;

return Scaffold(
appBar: AppBar(
title: const Text('AgriSmart'),
backgroundColor:
Theme.of(context).colorScheme.inversePrimary,
),
floatingActionButton: FloatingActionButton(
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Pour ajouter une zone, utilisez l’onglet Zones.',
),
),
);
},
child: const Icon(Icons.add),
),
body: Column(
children: [
FicheExploitation(
humiditeMoyenne: humiditeMoyenne(zones),
),
ResumeExploitation(zones: zones),
Expanded(
child: zones.isEmpty
? const Center(
child: Text('Aucune zone pour le moment'),
)
    : ListView.separated(
padding: const EdgeInsets.only(bottom: 80),
itemCount: zones.length,
separatorBuilder: (_, __) => const Divider(),
itemBuilder: (context, index) {
final zone = zones[index];

return ZoneCard(
zone: zone,
onAugmenter: () {
context
    .read<ZonesProvider>()
    .modifierHumidite(zone, 5);
},
onDiminuer: () {
context
    .read<ZonesProvider>()
    .modifierHumidite(zone, -5);
},
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Consultez les détails depuis l’onglet Zones.',
),
),
);
},
onLongPress: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Gérez les zones depuis l’onglet Zones.',
),
),
);
},
);
},
),
),
],
),
);
}
}
