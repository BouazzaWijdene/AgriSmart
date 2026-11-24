import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet/models/zone.dart';
import 'package:projet/providers/zones_provider.dart';
import 'package:projet/screens/zone_detail_page.dart';
import 'package:projet/screens/zone_form_page.dart';
import 'package:projet/widgets/filtre_zones_bar.dart';
import 'package:projet/widgets/zone_card.dart';
import 'package:projet/widgets/rapport_dialog.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  static const vert = Color(0xFF245C40);
  static const fond = Color(0xFFF5F8F3);

  final TextEditingController _rechercheController = TextEditingController();
  String _termeRecherche = '';
  FiltreZone _filtreActif = FiltreZone.toutes;

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  void _effacerRecherche() {
    _rechercheController.clear();
    setState(() {
      _termeRecherche = '';
    });
  }

  void _reinitialiserFiltres() {
    _rechercheController.clear();
    setState(() {
      _termeRecherche = '';
      _filtreActif = FiltreZone.toutes;
    });
  }

  void _message(BuildContext context, String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

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
    _message(context, 'Zone ajoutée avec succès');
  }

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
    _message(context, 'Zone modifiée avec succès');
  }

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

  Widget _carte(BuildContext context, Zone zone) {
    return ZoneCard(
      zone: zone,
      onAugmenter: () {
        context.read<ZonesProvider>().modifierHumidite(zone, 5);
      },
      onDiminuer: () {
        context.read<ZonesProvider>().modifierHumidite(zone, -5);
      },
      onTap: () => _ouvrirDetail(context, zone),
      onLongPress: () => _confirmerSuppression(context, zone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZonesProvider>();
    final zones = provider.zones;

    final rechercheNormalisee = _termeRecherche.trim().toLowerCase();
    final zonesFiltrees = zones.where((z) {
      final correspondNom = rechercheNormalisee.isEmpty ||
          z.nom.toLowerCase().contains(rechercheNormalisee);
      final correspondEtat = switch (_filtreActif) {
        FiltreZone.toutes => true,
        FiltreZone.aIrriguer => z.besoinIrrigation,
        FiltreZone.ok => !z.besoinIrrigation,
      };
      return correspondNom && correspondEtat;
    }).toList();

    return Scaffold(
      backgroundColor: fond,
      appBar: AppBar(
        backgroundColor: fond,
        elevation: 0,
        title: const Text(
          'Mes parcelles',
          style: TextStyle(
            color: vert,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Générer le rapport',
            icon: const Icon(Icons.assignment_outlined, color: vert),
            onPressed: () => RapportDialog.afficher(context, zones),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE1EDE3),
              child: Text(
                '${provider.nombre}',
                style: const TextStyle(
                  color: vert,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ajouter(context),
        backgroundColor: vert,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une parcelle'),
      ),
      body: zones.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.agriculture_outlined,
                size: 65,
                color: vert,
              ),
              const SizedBox(height: 15),
              const Text(
                'Aucune parcelle pour le moment',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: vert,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajoutez votre première parcelle pour commencer le suivi.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _ajouter(context),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une parcelle'),
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          FiltreZonesBar(
            rechercheController: _rechercheController,
            termeRecherche: _termeRecherche,
            filtreActif: _filtreActif,
            onRechercheChanged: (val) =>
                setState(() => _termeRecherche = val),
            onFiltreChanged: (val) =>
                setState(() => _filtreActif = val),
            onEffacerRecherche: _effacerRecherche,
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${zonesFiltrees.length} parcelle(s) affichée(s) sur ${zones.length}',
                style: const TextStyle(
                  color: vert,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: zonesFiltrees.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Aucune parcelle ne correspond à la recherche',
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _reinitialiserFiltres,
                    child: const Text('Réinitialiser les filtres'),
                  ),
                ],
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                final largeur = constraints.maxWidth;

                if (largeur >= 700) {
                  return GridView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: zonesFiltrees.length,
                    itemBuilder: (context, index) {
                      return _carte(context, zonesFiltrees[index]);
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: zonesFiltrees.length,
                  separatorBuilder: (_, _) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _carte(context, zonesFiltrees[index]);
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