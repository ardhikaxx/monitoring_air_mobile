import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import 'sensor_detail_bottom_sheet.dart';
import 'sensor_gauge.dart';
import 'sensor_mini_chart.dart';
import 'sensor_status_badge.dart';

class SensorMonitoringCard extends StatelessWidget {
  final SensorModel sensor;
  final double? inletComparisonValue; // for outlet sensors comparison

  const SensorMonitoringCard({
    super.key,
    required this.sensor,
    this.inletComparisonValue,
  });

  @override
  Widget build(BuildContext context) {
    final isPh = sensor.type == SensorType.phInlet || sensor.type == SensorType.phOutlet;
    final isOutlet = sensor.location == SensorLocation.outlet;

    IconData sensorIcon;
    Color accentColor;

    switch (sensor.type) {
      case SensorType.turbidityInlet:
      case SensorType.turbidityOutlet:
        sensorIcon = Icons.opacity_rounded;
        accentColor = isOutlet ? AppColors.techBlue : AppColors.rawWater;
        break;
      case SensorType.phInlet:
      case SensorType.phOutlet:
        sensorIcon = Icons.science_outlined;
        accentColor = isOutlet ? AppColors.statusNormal : AppColors.statusWarning;
        break;
      case SensorType.flowRateInlet:
        sensorIcon = Icons.speed_rounded;
        accentColor = AppColors.accentCyan;
        break;
      case SensorType.temperatureInlet:
      case SensorType.temperatureOutlet:
        sensorIcon = Icons.thermostat_rounded;
        accentColor = const Color(0xFFF97316);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Sensor Icon, Name, ID, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Icon(sensorIcon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sensor.id,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SensorStatusBadge(status: sensor.status),
            ],
          ),

          const SizedBox(height: 10),

          // Reading Value + Comparison Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                sensor.status == SensorStatus.offline
                    ? '--'
                    : sensor.currentValue.toStringAsFixed(
                        sensor.type == SensorType.phInlet || sensor.type == SensorType.phOutlet
                            ? 2
                            : 1,
                      ),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                sensor.unit,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Comparison tag for outlet sensor
              if (isOutlet && inletComparisonValue != null && sensor.status != SensorStatus.offline)
                _buildComparisonTag(sensor, inletComparisonValue!),
            ],
          ),

          const SizedBox(height: 10),

          // Visualization: pH Gauge or Mini Sparkline
          if (isPh && sensor.status != SensorStatus.offline) ...[
            SensorPhGauge(
              currentPh: sensor.currentValue,
              minNormal: sensor.minThreshold,
              maxNormal: sensor.maxThreshold,
            ),
          ] else if (sensor.status != SensorStatus.offline) ...[
            SensorMiniChart(
              readings: sensor.readings,
              lineColor: accentColor,
              height: 38,
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // Footer: Last updated + Detail Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update: ${DateFormatter.timeAgo(sensor.lastUpdated)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              TextButton(
                onPressed: () {
                  SensorDetailBottomSheet.show(context, sensor.id);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.techBlue)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.techBlue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTag(SensorModel sensor, double inletVal) {
    if (sensor.type == SensorType.turbidityOutlet) {
      final reduction = ((inletVal - sensor.currentValue) / inletVal * 100).clamp(0, 100);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.statusNormalBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.statusNormalBorder),
        ),
        child: Text(
          '-${reduction.toStringAsFixed(1)}% vs Inlet',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.statusNormal,
          ),
        ),
      );
    } else if (sensor.type == SensorType.phOutlet) {
      final diff = sensor.currentValue - inletVal;
      final sign = diff >= 0 ? '+' : '';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.lightTechBlue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$sign${diff.toStringAsFixed(2)} pH',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.techBlue,
          ),
        ),
      );
    } else {
      final diff = sensor.currentValue - inletVal;
      final sign = diff >= 0 ? '+' : '';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$sign${diff.toStringAsFixed(1)}°C',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF97316),
          ),
        ),
      );
    }
  }
}
