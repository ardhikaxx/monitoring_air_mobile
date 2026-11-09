import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_reading_model.dart';

class SensorMiniChart extends StatelessWidget {
  final List<SensorReadingModel> readings;
  final Color lineColor;
  final double height;

  const SensorMiniChart({
    super.key,
    required this.readings,
    this.lineColor = AppColors.techBlue,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Belum ada data',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ),
      );
    }

    // Take last 15 readings
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
    final paddedMin = minY - (yRange == 0 ? 1.0 : yRange * 0.15);
    final paddedMax = maxY + (yRange == 0 ? 1.0 : yRange * 0.15);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
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
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.06), // Flat subtle tint, no gradient
              ),
            ),
          ],
        ),
      ),
    );
  }
}
