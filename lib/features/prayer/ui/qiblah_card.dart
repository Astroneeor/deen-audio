import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'qiblah_compass.dart';

/// Shows the Qiblah bearing for the stored location as a number and a
/// north-up diagram. [direction] is degrees clockwise from true North;
/// null means no location is set.
class QiblahCard extends StatelessWidget {
  final double? direction;

  const QiblahCard({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: direction == null
          ? const Center(
              child: Text(
                'Set your location in Settings to see the Qiblah direction.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            )
          // Wrap: the text drops below the diagram in a narrow window.
          : Wrap(
              spacing: 28,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                QiblahCompass(direction: direction!),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Direction to Mecca',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        '${direction!.toStringAsFixed(1)}° from North',
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cardinalLabel(direction!),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      // This computer has no compass sensor: be explicit that
                      // the drawing is a fixed bearing, not a live needle.
                      const Text(
                        'This is a bearing measured clockwise from true '
                        'north, drawn with north at the top. It is not a '
                        'live compass and does not follow how your screen '
                        'is facing — find north with a compass or a map '
                        'first.',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static String _cardinalLabel(double deg) {
    final dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }
}
