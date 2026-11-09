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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: AppColors.techBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Kualitas Air (Inlet vs Outlet)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.navyBlue,
                      ),
                    ),
                    const Text(
                      'Evaluasi efisiensi filtrasi sebelum dan setelah perlakuan filter',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // 1. Kekeruhan (Turbidity)
          _buildParamComparison(
            context,
            isDark: isDark,
            title: 'Kekeruhan Air (Turbidity)',
            unit: 'NTU',
            inletVal: comparison.turbidityInlet,
            outletVal: comparison.turbidityOutlet,
            deltaText: 'Turun ${comparison.turbidityReductionPercent.toStringAsFixed(1)}%',
            deltaColor: AppColors.statusNormal,
            summary: comparison.turbiditySummary,
            progress: (1.0 - (comparison.turbidityOutlet / (comparison.turbidityInlet > 0 ? comparison.turbidityInlet : 1.0))).clamp(0.0, 1.0),
          ),

          const SizedBox(height: 14),

          // 2. Derajat Keasaman (pH)
          _buildParamComparison(
            context,
            isDark: isDark,
            title: 'Derajat Keasaman (pH)',
            unit: 'pH',
            inletVal: comparison.phInlet,
            outletVal: comparison.phOutlet,
            deltaText: '${comparison.phDelta >= 0 ? "+" : ""}${comparison.phDelta.toStringAsFixed(2)} pH',
            deltaColor: AppColors.techBlue,
            summary: comparison.phSummary,
            progress: (comparison.phOutlet / 14.0).clamp(0.0, 1.0),
          ),

          const SizedBox(height: 14),

          // 3. Suhu (Temperature)
          _buildParamComparison(
            context,
            isDark: isDark,
            title: 'Temperatur Air',
            unit: '°C',
            inletVal: comparison.tempInlet,
            outletVal: comparison.tempOutlet,
            deltaText: '${comparison.tempDelta >= 0 ? "+" : ""}${comparison.tempDelta.toStringAsFixed(1)}°C',
            deltaColor: const Color(0xFFF97316),
            summary: comparison.tempSummary,
            progress: (comparison.tempOutlet / 50.0).clamp(0.0, 1.0),
          ),

          const SizedBox(height: 14),

          // Disclaimer note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 16, color: AppColors.techBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perhatian: Parameter ini mencerminkan hasil pembacaan sensor IoT terhadap proses penjernihan fisik. Kelayakan konsumsi air minum wajib melalui uji laboratorium mikrobiologi dan standar Permenkes.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamComparison(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String unit,
    required double inletVal,
    required double outletVal,
    required String deltaText,
    required Color deltaColor,
    required String summary,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  deltaText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: deltaColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Inlet box
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Inlet (Air Baku)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${inletVal.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.rawWater,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              // Outlet box
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Outlet (Air Olahan)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${outletVal.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.cleanWater,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(deltaColor),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
