import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/water_quality_model.dart';

class WaterQualityComparisonCard extends StatelessWidget {
  final WaterQualityComparison comparison;

  const WaterQualityComparisonCard({
    super.key,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    final reduction = comparison.turbidityReductionPercent;
    final isOutletSafe = comparison.turbidityOutlet <= 5.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Icon, Title, and Overall Efficiency Pill
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.statusNormal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.statusNormal,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Efisiensi Filtrasi Air',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Hasil Penjernihan Inlet ➔ Outlet',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusNormalBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.statusNormalBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 13, color: AppColors.statusNormal),
                    const SizedBox(width: 4),
                    Text(
                      '${reduction.toStringAsFixed(1)}% Efektif',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusNormal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Visual Progress Bar of Filtration
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tingkat Reduksi Kekeruhan',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${reduction.toStringAsFixed(1)}% / 100%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.statusNormal),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: (reduction / 100).clamp(0.0, 1.0),
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusNormal),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Featured Metric Tile: Kekeruhan (Inlet vs Outlet)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.opacity_rounded, size: 14, color: AppColors.navyBlue),
                        SizedBox(width: 5),
                        Text(
                          'Kekeruhan Air (Turbidity)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    if (isOutletSafe)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.statusNormalBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 10, color: AppColors.statusNormal),
                            SizedBox(width: 3),
                            Text(
                              'Standar < 5 NTU',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.statusNormal),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Inlet Value Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Inlet (Air Baku)', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '${comparison.turbidityInlet.toStringAsFixed(1)} NTU',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.rawWater),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.techBlue),
                    ),
                    // Outlet Value Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Outlet (Air Hasil)', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '${comparison.turbidityOutlet.toStringAsFixed(1)} NTU',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.techBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 4. Dual Metric Tiles: pH & Suhu
          Row(
            children: [
              // pH Comparison Tile
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.science_outlined, size: 13, color: AppColors.statusNormal),
                          SizedBox(width: 4),
                          Text('Derajat pH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navyBlue)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(comparison.phInlet.toStringAsFixed(2), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.textMuted),
                          Text(comparison.phOutlet.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusNormal)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${comparison.phDelta >= 0 ? "+" : ""}${comparison.phDelta.toStringAsFixed(2)} pH (Netral)',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.statusNormal),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Suhu Comparison Tile
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.thermostat_rounded, size: 13, color: Color(0xFFF97316)),
                          SizedBox(width: 4),
                          Text('Suhu Air', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navyBlue)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${comparison.tempInlet.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.textMuted),
                          Text('${comparison.tempOutlet.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF97316))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${comparison.tempDelta >= 0 ? "+" : ""}${comparison.tempDelta.toStringAsFixed(1)}°C (Stabil)',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
