import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
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
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Icon, Name, Sensor ID & Pin, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(sensorIcon, color: accentColor, size: 20),
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
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          sensor.id,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(fontSize: 10, color: AppColors.borderLight)),
                        const SizedBox(width: 6),
                        Text(
                          sensor.pinConnection.split('(').first.trim(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SensorStatusBadge(status: sensor.status),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Main Reading Value + Threshold & Comparison Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Value + Unit
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
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyBlue,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    sensor.unit,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Comparison Tag (for Outlet Sensors) or Threshold Range (for Inlet)
              if (isOutlet && inletComparisonValue != null && sensor.status != SensorStatus.offline)
                _buildComparisonTag(sensor, inletComparisonValue!)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderLight, width: 0.8),
                  ),
                  child: Text(
                    'Target: ${sensor.minThreshold.toStringAsFixed(0)}–${sensor.maxThreshold.toStringAsFixed(0)} ${sensor.unit}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Visual Graph Section (Trend Curve with Min/Avg/Max)
          if (sensor.status != SensorStatus.offline) ...[
            SensorMiniChart(
              readings: sensor.readings,
              lineColor: accentColor,
              unit: sensor.unit,
              minValue: sensor.minValue,
              maxValue: sensor.maxValue,
              avgValue: sensor.avgValue,
              height: 52,
            ),
            // For pH: Also display the 0-14 acid/neutral/base scale meter below the trend!
            if (isPh) ...[
              const SizedBox(height: 8),
              SensorPhGauge(
                currentPh: sensor.currentValue,
                minNormal: sensor.minThreshold,
                maxNormal: sensor.maxThreshold,
              ),
            ],
          ],

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // 4. Footer: Hardware Model + Detail Trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.memory_rounded, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    sensor.hardwareSpec.split('(').first.trim(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.statusNormalBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.statusNormalBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.trending_down_rounded, size: 14, color: AppColors.statusNormal),
            const SizedBox(width: 3),
            Text(
              '-${reduction.toStringAsFixed(1)}% vs Inlet',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.statusNormal,
              ),
            ),
          ],
        ),
      );
    } else if (sensor.type == SensorType.phOutlet) {
      final diff = sensor.currentValue - inletVal;
      final sign = diff >= 0 ? '+' : '';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.lightTechBlue,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.techBlue.withValues(alpha: 0.2)),
        ),
        child: Text(
          '$sign${diff.toStringAsFixed(2)} pH vs Inlet',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.techBlue,
          ),
        ),
      );
    } else {
      final diff = sensor.currentValue - inletVal;
      final sign = diff >= 0 ? '+' : '';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFDBA74)),
        ),
        child: Text(
          '$sign${diff.toStringAsFixed(1)}°C vs Inlet',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF97316),
          ),
        ),
      );
    }
  }
}
