import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet/models/zone.dart';
import 'package:projet/service/rapport_service.dart';

class RapportDialog extends StatelessWidget {
  final List<Zone> zones;

  const RapportDialog({super.key, required this.zones});

  static Future<void> afficher(BuildContext context, List<Zone> zones) {
    return showDialog(
      context: context,
      builder: (_) => RapportDialog(zones: zones),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rapport = RapportService.genererBilanExploitation(zones);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.description_outlined, color: Color(0xFF245C40)),
          SizedBox(width: 8),
          Text('Rapport d’exploitation'),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              rapport,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: rapport));
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rapport copié dans le presse-papiers'),
              ),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copier le rapport'),
        ),
      ],
    );
  }
}