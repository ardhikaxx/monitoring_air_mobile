import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_reading_model.dart';

class SensorMiniChart extends StatelessWidget {
  final List<SensorReadingModel> readings;
  final Color lineColor;
  final String unit;
  final double? minValue;
  final double? maxValue;
  final double? avgValue;
  final double height;

  const SensorMiniChart({
    super.key,
    required this.readings,
    this.lineColor = AppColors.techBlue,
    this.unit = '',
    this.minValue,
    this.maxValue,
    this.avgValue,
    this.height = 62,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Belum ada data riwayat',
          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      );
    }

    // Take last 15 readings for clean visualization
    final sample = readings.length > 15
        ? readings.sublist(readings.length - 15)
        : readings;

    final spots = <FlSpot>[];
    for (int i = 0; i < sample.length; i++) {
      spots.add(FlSpot(i.toDouble(), sample[i].value));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yRange = (maxY - minY).abs();
    final paddedMin = (minY - (yRange == 0 ? 1.0 : yRange * 0.2)).clamp(0.0, double.infinity);
    final paddedMax = maxY + (yRange == 0 ? 1.0 : yRange * 0.2);

    final displayMin = minValue ?? minY;
    final displayMax = maxValue ?? maxY;
    final displayAvg = avgValue ?? (spots.map((s) => s.y).reduce((a, b) => a + b) / spots.length);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Statistics Row: Min • Avg • Max
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timeline_rounded, size: 12, color: AppColors.textMuted),
                  SizedBox(width: 4),
                  Text(
                    'Tren 24 Jam',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildStatBadge('Min', displayMin.toStringAsFixed(1)),
                  const SizedBox(width: 6),
                  _buildStatBadge('Avg', displayAvg.toStringAsFixed(1)),
                  const SizedBox(width: 6),
                  _buildStatBadge('Max', displayMax.toStringAsFixed(1)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // The Smooth Curve Chart
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yRange == 0 ? 1.0 : yRange / 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black.withValues(alpha: 0.04),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (sample.length - 1).toDouble(),
                minY: paddedMin,
                maxY: paddedMax,
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: lineColor,
                    barWidth: 2.2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        // Highlight the latest spot (current reading)
                        return spot.x == (sample.length - 1).toDouble();
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Bottom Time Indicators
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '24 jam lalu',
                style: TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
              Text(
                'Terkini',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderLight, width: 0.6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
