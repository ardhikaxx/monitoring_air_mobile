import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../providers/sensor_provider.dart';
import '../widgets/calibration_dialog.dart';
import '../widgets/history_chart.dart';
import '../widgets/sensor_gauge.dart';
import '../widgets/sensor_status_badge.dart';
import '../widgets/sensor_test_modal.dart';
import 'sensor_testing_screen.dart';

class SensorDetailScreen extends StatefulWidget {
  final String sensorId;

  const SensorDetailScreen({
    super.key,
    required this.sensorId,
  });

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  String _selectedRange = '24 Jam';
  final List<String> _ranges = ['1 Jam', '6 Jam', '12 Jam', '24 Jam', '7 Hari'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sensor = provider.getSensorById(widget.sensorId);

    if (sensor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sensor Tidak Ditemukan')),
        body: const Center(child: Text('Data sensor tidak tersedia.')),
      );
    }

    final isPh = sensor.type == SensorType.phInlet || sensor.type == SensorType.phOutlet;

    // Filter readings according to selected range
    List<SensorReadingModel> filteredReadings = sensor.readings;
    if (_selectedRange == '1 Jam') {
      filteredReadings = sensor.readings.take(4).toList();
    } else if (_selectedRange == '6 Jam') {
      filteredReadings = sensor.readings.take(8).toList();
    } else if (_selectedRange == '12 Jam') {
      filteredReadings = sensor.readings.take(14).toList();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sensor.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${sensor.id} • ${sensor.location.label}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF93C5FD)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SensorStatusBadge(status: sensor.status),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 1. Big Reading Display Card
          _buildBigReadingCard(context, sensor, isDark, isPh),

          const SizedBox(height: 16),

          // 2. Interactive Chart Section with Timeframe Filter Chips
          _buildChartSection(context, sensor, filteredReadings, isDark),

          const SizedBox(height: 16),

          // 3. Statistics (Min, Max, Avg, Latest)
          _buildStatisticsGrid(sensor, isDark),

          const SizedBox(height: 16),

          // 4. Sensor Hardware Specifications
          _buildHardwareSpecsCard(sensor, isDark),

          const SizedBox(height: 16),

          // 5. Sensor Health & Diagnostic Actions
          _buildHealthAndActionsCard(context, sensor, isDark),

          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }

  Widget _buildBigReadingCard(
    BuildContext context,
    SensorModel sensor,
    bool isDark,
    bool isPh,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nilai Pembacaan Terkini',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.sync_rounded, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.timeAgo(sensor.lastUpdated),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                sensor.status == SensorStatus.offline
                    ? '--'
                    : sensor.currentValue.toStringAsFixed(isPh ? 2 : 1),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                sensor.unit,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (isPh && sensor.status != SensorStatus.offline) ...[
            const SizedBox(height: 14),
            SensorPhGauge(
              currentPh: sensor.currentValue,
              minNormal: sensor.minThreshold,
              maxNormal: sensor.maxThreshold,
            ),
          ],

          const SizedBox(height: 12),
          Text(
            sensor.description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    SensorModel sensor,
    List<SensorReadingModel> readings,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grafik Histori Pembacaan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
              Text(
                '${readings.length} Titik Sampel',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Time Range Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ranges.map((range) {
                final isSelected = _selectedRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      range,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.techBlue,
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedRange = range);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // The interactive fl_chart
          HistoryChart(
            readings: readings,
            unit: sensor.unit,
            lineColor: AppColors.techBlue,
            minThreshold: sensor.minThreshold,
            maxThreshold: sensor.maxThreshold,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(SensorModel sensor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Rentang Operasional',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Minimum', '${sensor.minValue.toStringAsFixed(1)} ${sensor.unit}', isDark),
              ),
              Expanded(
                child: _buildStatItem('Rata-Rata', '${sensor.avgValue.toStringAsFixed(1)} ${sensor.unit}', isDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Maksimum', '${sensor.maxValue.toStringAsFixed(1)} ${sensor.unit}', isDark),
              ),
              Expanded(
                child: _buildStatItem('Terakhir', '${sensor.currentValue.toStringAsFixed(1)} ${sensor.unit}', isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareSpecsCard(SensorModel sensor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.memory_rounded, size: 18, color: AppColors.techBlue),
              const SizedBox(width: 8),
              Text(
                'Spesifikasi Perangkat Keras Sensor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildSpecRow('Nama Sensor', sensor.name),
          _buildSpecRow('Model / Tipe Hardware', sensor.hardwareSpec),
          _buildSpecRow('Lokasi Pemasangan', sensor.location.label),
          _buildSpecRow('Pin ESP32 / Saluran ADC', sensor.pinConnection),
          _buildSpecRow('Ambang Normal Bawah', '${sensor.minThreshold} ${sensor.unit}'),
          _buildSpecRow('Ambang Normal Atas', '${sensor.maxThreshold} ${sensor.unit}'),
          _buildSpecRow('Kompensasi Offset Kalibrasi', '${sensor.calibrationOffset}'),
          _buildSpecRow('Status Sambungan', sensor.status == SensorStatus.offline ? 'Terputus' : 'Aktif Terkoneksi'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAndActionsCard(BuildContext context, SensorModel sensor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety_outlined, size: 18, color: AppColors.statusNormal),
              const SizedBox(width: 8),
              Text(
                'Sensor Health & Diagnostics',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.techBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sensor.healthStatus,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons: Periksa Sensor, Uji Sensor, Kalibrasi
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    SensorTestModal.showCheckModal(context, sensor);
                  },
                  icon: const Icon(Icons.radar_rounded, size: 15),
                  label: const Text('Periksa Sensor', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    SensorTestModal.showTestModal(context, sensor);
                  },
                  icon: const Icon(Icons.biotech_rounded, size: 15),
                  label: const Text('Uji Sensor', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CalibrationDialog(sensor: sensor),
                    );
                  },
                  icon: const Icon(Icons.tune_rounded, size: 15),
                  label: const Text('Simulasi Kalibrasi', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SensorTestingScreen(initialSensorId: sensor.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, size: 15),
                  label: const Text('Riwayat Uji', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
