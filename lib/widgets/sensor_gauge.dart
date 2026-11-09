import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SensorPhGauge extends StatelessWidget {
  final double currentPh;
  final double minNormal;
  final double maxNormal;

  const SensorPhGauge({
    super.key,
    required this.currentPh,
    this.minNormal = 6.5,
    this.maxNormal = 8.5,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPh = currentPh.clamp(0.0, 14.0);
    final ratio = clampedPh / 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scale Bar
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final pointerLeft = (ratio * width).clamp(6.0, width - 6.0);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Flat segmented Track (No gradients)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        // Asam (0 - 6.5)
                        Expanded(
                          flex: 65,
                          child: Container(color: AppColors.statusWarning.withValues(alpha: 0.35)),
                        ),
                        // Netral Ideal (6.5 - 8.5)
                        Expanded(
                          flex: 20,
                          child: Container(color: AppColors.statusNormal),
                        ),
                        // Basa (8.5 - 14)
                        Expanded(
                          flex: 55,
                          child: Container(color: AppColors.techBlue.withValues(alpha: 0.35)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pointer Marker
                Positioned(
                  left: pointerLeft - 6,
                  top: -4,
                  child: Container(
                    width: 12,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 6),

        // Scale Labels
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 Asam', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text('6.5 – 8.5 Normal',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusNormal)),
            Text('14 Basa', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}
