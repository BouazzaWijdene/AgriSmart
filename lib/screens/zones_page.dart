import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet/models/zone.dart';
import 'package:projet/providers/zones_provider.dart';
import 'package:projet/screens/zone_detail_page.dart';
import 'package:projet/screens/zone_form_page.dart';
import 'package:projet/widgets/fiche_exploitation.dart';
import 'package:projet/widgets/resume_exploitation.dart';
import 'package:projet/widgets/zone_card.dart';

class ZonesPage extends StatelessWidget {
const ZonesPage({super.key});

void _message(BuildContext context, String texte) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(texte)),
);
}

// Ajouter une zone.
Future<void> _ajouter(BuildContext context) async {
final provider = context.read<ZonesProvider>();

final nouvelle = await Navigator.push<Zone>(
context,
MaterialPageRoute(
builder: (_) => ZoneFormPage(
nomsExistants: provider.noms(),
),
),
);

if (nouvelle == null || !context.mounted) return;

context.read<ZonesProvider>().ajouter(nouvelle);
_message(context, 'Zone ajoutée');
}

// Ouvrir et modifier une zone.
Future<void> _ouvrirDetail(
BuildContext context,
Zone zone,
) async {
final provider = context.read<ZonesProvider>();

final modifiee = await Navigator.push<Zone>(
context,
MaterialPageRoute(
builder: (_) => ZoneDetailPage(
zone: zone,
nomsAutres: provider.noms(sauf: zone),
),
),
);

if (modifiee == null || !context.mounted) return;

context.read<ZonesProvider>().remplacer(zone, modifiee);
_message(context, 'Zone modifiée');
}

// Confirmer la suppression.
Future<void> _confirmerSuppression(
BuildContext context,
Zone zone,
) async {
final confirme = await showDialog<bool>(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Supprimer la zone ?'),
content: Text(
'La zone ${zone.nom} sera supprimée définitivement.',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(ctx, false),
child: const Text('Annuler'),
),
FilledButton(
onPressed: () => Navigator.pop(ctx, true),
child: const Text('Supprimer'),
),
],
),
);

if (confirme != true || !context.mounted) return;

context.read<ZonesProvider>().supprimer(zone);
_message(context, 'Zone supprimée');
}

// Construire une carte.
Widget _carte(BuildContext context, Zone zone) {
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
onTap: () => _ouvrirDetail(context, zone),
onLongPress: () => _confirmerSuppression(context, zone),
);
}

@override
Widget build(BuildContext context) {
// Une seule source de données : ZonesProvider.
final zones = context.watch<ZonesProvider>().zones;

return Scaffold(
appBar: AppBar(
backgroundColor:
Theme.of(context).colorScheme.inversePrimary,
title: const Text('AgriSmart'),
),
floatingActionButton: FloatingActionButton(
onPressed: () => _ajouter(context),
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
    : LayoutBuilder(
builder: (context, constraints) {
if (constraints.maxWidth >= 600) {
return GridView.builder(
padding: const EdgeInsets.only(
bottom: 80,
),
gridDelegate:
const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
childAspectRatio: 2.8,
),
itemCount: zones.length,
itemBuilder: (context, index) {
return _carte(context, zones[index]);
},
);
}

return ListView.separated(
padding: const EdgeInsets.only(
bottom: 80,
),
itemCount: zones.length,
separatorBuilder: (_, __) =>
const Divider(),
itemBuilder: (context, index) {
return _carte(context, zones[index]);
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