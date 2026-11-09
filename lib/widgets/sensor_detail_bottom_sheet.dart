import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../providers/sensor_simulation_provider.dart';
import 'sensor_check_bottom_sheet.dart';
import 'sensor_gauge.dart';
import 'sensor_mini_chart.dart';
import 'sensor_status_badge.dart';

class SensorDetailBottomSheet extends StatelessWidget {
  final String sensorId;

  const SensorDetailBottomSheet({
    super.key,
    required this.sensorId,
  });

  static void show(BuildContext context, String sensorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SensorDetailBottomSheet(sensorId: sensorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();
    final sensor = provider.getSensorById(sensorId);

    if (sensor == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Text('Sensor tidak ditemukan.'),
      );
    }

    final isPh = sensor.type == SensorType.phInlet || sensor.type == SensorType.phOutlet;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header: Name, location, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sensor.id} • ${sensor.location.label}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SensorStatusBadge(status: sensor.status),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reading Value Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nilai Pembacaan Saat Ini',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              sensor.status == SensorStatus.offline
                                  ? '--'
                                  : sensor.currentValue.toStringAsFixed(isPh ? 2 : 1),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navyBlue,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              sensor.unit,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Update: ${DateFormatter.timeAgo(sensor.lastUpdated)}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        if (isPh && sensor.status != SensorStatus.offline) ...[
                          const SizedBox(height: 10),
                          SensorPhGauge(
                            currentPh: sensor.currentValue,
                            minNormal: sensor.minThreshold,
                            maxNormal: sensor.maxThreshold,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mini History Chart
                  const Text(
                    'Grafik Histori Pembacaan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: SensorMiniChart(
                      readings: sensor.readings,
                      lineColor: AppColors.techBlue,
                      height: 55,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Operational Stats: Min, Max, Avg
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          'Minimum',
                          '${sensor.minValue.toStringAsFixed(1)} ${sensor.unit}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          'Rata-Rata',
                          '${sensor.avgValue.toStringAsFixed(1)} ${sensor.unit}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          'Maksimum',
                          '${sensor.maxValue.toStringAsFixed(1)} ${sensor.unit}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Hardware & Diagnostic Specifications
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Jenis Parameter', sensor.type.displayName),
                        const SizedBox(height: 6),
                        _buildRow('Lokasi Pemasangan', sensor.location.label),
                        const SizedBox(height: 6),
                        _buildRow('Model Hardware', sensor.hardwareSpec),
                        const SizedBox(height: 6),
                        _buildRow('Koneksi Pin ESP32', sensor.pinConnection),
                        const SizedBox(height: 6),
                        _buildRow('Rentang Normal', '${sensor.minThreshold} – ${sensor.maxThreshold} ${sensor.unit}'),
                        const SizedBox(height: 6),
                        _buildRow('Status Kesehatan', sensor.healthStatus),
                        const SizedBox(height: 6),
                        _buildRow(
                          'Pengujian Terakhir',
                          sensor.lastTested != null
                              ? '${sensor.lastTestResult} (${DateFormatter.timeAgo(sensor.lastTested!)})'
                              : 'Belum diuji',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Action Button: Periksa Sensor
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                SensorCheckBottomSheet.show(context, sensor);
              },
              icon: const Icon(Icons.radar_rounded, size: 18),
              label: const Text('Periksa Sensor (Diagnostik Sinyal)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navyBlue),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
