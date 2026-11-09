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
                // Color Track
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEF4444), // Red 0-4 (Asam Kuat)
                        Color(0xFFF59E0B), // Orange 4-6.5 (Asam Ringan)
                        Color(0xFF10B981), // Green 6.5-8.5 (Netral Ideal)
                        Color(0xFF06B6D4), // Cyan 8.5-10 (Basa Ringan)
                        Color(0xFF6366F1), // Indigo 10-14 (Basa Kuat)
                      ],
                      stops: [0.0, 0.40, 0.50, 0.65, 1.0],
                    ),
                  ),
                ),

                // Ideal Range Highlight Box (6.5 to 8.5)
                Positioned(
                  left: (6.5 / 14.0) * width,
                  width: ((8.5 - 6.5) / 14.0) * width,
                  top: -2,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),

                // Value Pointer Marker
                Positioned(
                  left: pointerLeft - 7,
                  top: -6,
                  child: Container(
                    width: 14,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 8),

        // Scale Labels
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 Asam', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text('6.5 - 8.5 Ideal',
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
