
import 'package:flutter/material.dart';
import 'package:projet/models/zone.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback onAugmenter;
  final VoidCallback onDiminuer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ZoneCard({
    super.key,
    required this.zone,
    required this.onAugmenter,
    required this.onDiminuer,
    this.onTap,
    this.onLongPress,
  });

  static const vert = Color(0xFF245C40);

  String? _imageCulture() {
    final culture = zone.culture.toLowerCase();

    if (culture.contains('tomate')) {
      return 'assets/images/tomato.webp';
    }
    if (culture.contains('carotte')) {
      return 'assets/images/carrot.webp';
    }
    if (culture.contains('persil')) {
      return 'assets/images/parsley.jpg';
    }
    if (culture.contains('poivron')) {
      return 'assets/images/pepper.webp';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final besoin = zone.besoinIrrigation;
    final couleur = besoin
        ? const Color(0xFFE28A16)
        : const Color(0xFF32834A);
    final image = _imageCulture();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  width: 55,
                  height: 55,
                  color: const Color(0xFFEAF3E9),
                  child: image != null
                      ? Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.grass,
                        color: vert,
                        size: 30,
                      );
                    },
                  )
                      : const Icon(
                    Icons.grass,
                    color: vert,
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26382D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      zone.culture,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF657168),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (zone.humidite / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: couleur,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      besoin ? 'Besoin d’irrigation' : 'Sol correct',
                      style: TextStyle(
                        fontSize: 11,
                        color: couleur,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${zone.humidite.toStringAsFixed(0)} %',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: vert,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 38,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onDiminuer,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          size: 21,
                        ),
                        color: const Color(0xFFE28A16),
                        tooltip: 'Diminuer l’humidité',
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 38,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onAugmenter,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 21,
                        ),
                        color: vert,
                        tooltip: 'Augmenter l’humidité',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
