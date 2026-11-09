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

    final isIdeal = currentPh >= minNormal && currentPh <= maxNormal;
    final isAcidic = currentPh < minNormal;

    final statusText = isIdeal
        ? 'Ideal Netral'
        : isAcidic
            ? 'Cenderung Asam'
            : 'Cenderung Basa';

    final statusColor = isIdeal
        ? AppColors.statusNormal
        : isAcidic
            ? AppColors.statusWarning
            : AppColors.techBlue;

    final statusBg = isIdeal
        ? AppColors.statusNormalBg
        : isAcidic
            ? AppColors.statusWarningBg
            : AppColors.lightTechBlue;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.colorize_rounded, size: 12, color: AppColors.textMuted),
                  SizedBox(width: 4),
                  Text(
                    'Skala Derajat pH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Scale Bar with Pointer
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final pointerLeft = (ratio * width).clamp(8.0, width - 8.0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Flat 3-Segment Track
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          // Asam (0 - 6.5)
                          Expanded(
                            flex: 65,
                            child: Container(color: const Color(0xFFFDE68A)), // Warm amber
                          ),
                          // Netral Ideal (6.5 - 8.5)
                          Expanded(
                            flex: 20,
                            child: Container(color: AppColors.statusNormal), // Emerald
                          ),
                          // Basa (8.5 - 14)
                          Expanded(
                            flex: 55,
                            child: Container(color: const Color(0xFFBAE6FD)), // Soft cyan
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Pin Pointer Indicator
                  Positioned(
                    left: pointerLeft - 6,
                    top: -5,
                    child: Container(
                      width: 12,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 6),

          // Scale Legend Labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 Asam', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
              Text('6.5 – 8.5 Standar Air Bersih',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusNormal)),
              Text('14 Basa', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
