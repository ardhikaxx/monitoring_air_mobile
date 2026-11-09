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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.techBlue,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Efisiensi Filtrasi (Inlet ➔ Outlet)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusNormalBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.statusNormalBorder),
                ),
                child: Text(
                  '${comparison.turbidityReductionPercent.toStringAsFixed(1)}% Reduksi',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusNormal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 3 Metric Comparison Rows
          _buildMetricRow(
            icon: Icons.opacity_rounded,
            title: 'Kekeruhan',
            inletVal: '${comparison.turbidityInlet.toStringAsFixed(1)} NTU',
            outletVal: '${comparison.turbidityOutlet.toStringAsFixed(1)} NTU',
            deltaText: '-${comparison.turbidityReductionPercent.toStringAsFixed(1)}%',
            deltaColor: AppColors.statusNormal,
            deltaBg: AppColors.statusNormalBg,
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            icon: Icons.science_outlined,
            title: 'Derajat pH',
            inletVal: '${comparison.phInlet.toStringAsFixed(2)} pH',
            outletVal: '${comparison.phOutlet.toStringAsFixed(2)} pH',
            deltaText: '${comparison.phDelta >= 0 ? "+" : ""}${comparison.phDelta.toStringAsFixed(2)}',
            deltaColor: AppColors.techBlue,
            deltaBg: AppColors.lightTechBlue,
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            icon: Icons.thermostat_rounded,
            title: 'Temperatur',
            inletVal: '${comparison.tempInlet.toStringAsFixed(1)}°C',
            outletVal: '${comparison.tempOutlet.toStringAsFixed(1)}°C',
            deltaText: '${comparison.tempDelta >= 0 ? "+" : ""}${comparison.tempDelta.toStringAsFixed(1)}°C',
            deltaColor: const Color(0xFFF97316),
            deltaBg: const Color(0xFFFFF7ED),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String title,
    required String inletVal,
    required String outletVal,
    required String deltaText,
    required Color deltaColor,
    required Color deltaBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.navyBlue),
          const SizedBox(width: 8),
          SizedBox(
            width: 75,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  inletVal,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.textMuted),
                ),
                Text(
                  outletVal,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: deltaBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              deltaText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: deltaColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
