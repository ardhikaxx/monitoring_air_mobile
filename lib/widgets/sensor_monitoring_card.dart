import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../screens/sensor_detail_screen.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Sensor Icon, Name, Location Tag, Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOutlet
                                  ? AppColors.techBlue.withValues(alpha: 0.1)
                                  : AppColors.rawWater.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sensor.location.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isOutlet ? AppColors.techBlue : AppColors.rawWater,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sensor.id,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
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

            const SizedBox(height: 14),

            // Reading Value + Comparison or Unit
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
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.navyBlue,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  sensor.unit,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                // Comparison tag for outlet sensor
                if (isOutlet && inletComparisonValue != null && sensor.status != SensorStatus.offline)
                  _buildComparisonTag(sensor, inletComparisonValue!),
              ],
            ),

            const SizedBox(height: 12),

            // Specific visualization: pH Gauge or Mini Line Chart
            if (isPh && sensor.status != SensorStatus.offline) ...[
              SensorPhGauge(
                currentPh: sensor.currentValue,
                minNormal: sensor.minThreshold,
                maxNormal: sensor.maxThreshold,
              ),
              const SizedBox(height: 10),
            ] else if (sensor.status != SensorStatus.offline) ...[
              SensorMiniChart(
                readings: sensor.readings,
                lineColor: accentColor,
                height: 48,
              ),
              const SizedBox(height: 8),
            ],

            // Health Status or Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.5)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    sensor.status == SensorStatus.normal
                        ? Icons.verified_outlined
                        : sensor.status == SensorStatus.warning
                            ? Icons.info_outline
                            : Icons.warning_amber_rounded,
                    size: 13,
                    color: sensor.status == SensorStatus.normal
                        ? AppColors.statusNormal
                        : sensor.status == SensorStatus.warning
                            ? AppColors.statusWarning
                            : AppColors.statusCritical,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sensor.healthStatus,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Footer: Last updated + Detail Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Update: ${DateFormatter.timeAgo(sensor.lastUpdated)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SensorDetailScreen(sensorId: sensor.id),
                      ),
                    );
                  },
                  icon: const Text('Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  label: const Icon(Icons.arrow_forward_rounded, size: 14),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    foregroundColor: AppColors.techBlue,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTag(SensorModel sensor, double inletVal) {
    if (sensor.type == SensorType.turbidityOutlet) {
      final reduction = ((inletVal - sensor.currentValue) / inletVal * 100).clamp(0, 100);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.techBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.techBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$sign${diff.toStringAsFixed(1)}°C vs Inlet',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.techBlue,
          ),
        ),
      );
    }
  }
}
