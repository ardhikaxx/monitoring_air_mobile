import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_model.dart';
import '../models/sensor_test_result_model.dart';
import '../providers/sensor_provider.dart';
import '../widgets/calibration_dialog.dart';
import '../widgets/sensor_status_badge.dart';
import '../widgets/sensor_test_modal.dart';

class SensorTestingScreen extends StatefulWidget {
  final String? initialSensorId;

  const SensorTestingScreen({
    super.key,
    this.initialSensorId,
  });

  @override
  State<SensorTestingScreen> createState() => _SensorTestingScreenState();
}

class _SensorTestingScreenState extends State<SensorTestingScreen> {
  late String _selectedSensorId;

  @override
  void initState() {
    super.initState();
    _selectedSensorId = widget.initialSensorId ?? 'SEN-IN-TURB';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentSensor = provider.getSensorById(_selectedSensorId) ?? provider.sensors.first;
    final testHistory = provider.testHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengujian & Kalibrasi'),
        backgroundColor: AppColors.navyBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 1. Sensor Selector Dropdown Card
          _buildSensorSelectorCard(context, provider, currentSensor, isDark),

          const SizedBox(height: 16),

          // 2. Selected Sensor Diagnostic Details
          _buildSensorDetailsCard(context, currentSensor, isDark),

          const SizedBox(height: 16),

          // 3. Test & Calibration Control Actions
          _buildActionButtons(context, currentSensor),

          const SizedBox(height: 20),

          // 4. Test History Logs List
          _buildTestHistorySection(testHistory, isDark),

          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }

  Widget _buildSensorSelectorCard(
    BuildContext context,
    SensorProvider provider,
    SensorModel currentSensor,
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
          const Text(
            'Pilih Sensor untuk Pengujian:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: currentSensor.id,
                items: provider.sensors.map((s) {
                  return DropdownMenuItem<String>(
                    value: s.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: s.location == SensorLocation.inlet
                                ? AppColors.rawWater.withValues(alpha: 0.12)
                                : AppColors.techBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s.location == SensorLocation.inlet ? 'INLET' : 'OUTLET',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: s.location == SensorLocation.inlet
                                  ? AppColors.rawWater
                                  : AppColors.techBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSensorId = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorDetailsCard(
    BuildContext context,
    SensorModel sensor,
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
                sensor.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
              SensorStatusBadge(status: sensor.status, compact: true),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow('Lokasi Pemasangan', sensor.location.label),
          _buildInfoRow('Pembacaan Terkini', '${sensor.currentValue} ${sensor.unit}'),
          _buildInfoRow('Kondisi Kesehatan', sensor.healthStatus),
          _buildInfoRow(
            'Pengujian Terakhir',
            sensor.lastTested != null ? DateFormatter.timeAgo(sensor.lastTested!) : 'Belum diuji',
          ),
          _buildInfoRow(
            'Hasil Uji Sebelumnya',
            sensor.lastTestResult ?? 'N/A',
            highlightColor: sensor.lastTestResult == 'Passed'
                ? AppColors.statusNormal
                : AppColors.statusWarning,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: highlightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SensorModel sensor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  SensorTestModal.showTestModal(context, sensor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.techBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.biotech_rounded, size: 18),
                label: const Text('Mulai Pengujian'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CalibrationDialog(sensor: sensor),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Simulasi Kalibrasi'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestHistorySection(List<SensorTestResultModel> history, bool isDark) {
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
              Row(
                children: [
                  const Icon(Icons.history_rounded, size: 18, color: AppColors.techBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Histori Log Pengujian & Kalibrasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              Text(
                '${history.length} Catatan',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Belum ada log pengujian sensor.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (ctx, i) {
                final item = history[i];
                Color badgeColor = item.status == TestStatus.passed
                    ? AppColors.statusNormal
                    : item.status == TestStatus.warning
                        ? AppColors.statusWarning
                        : AppColors.statusCritical;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.sensorName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.navyBlue,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            item.status.label,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${item.testType} • Latensi: ${item.latencyMs}ms',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Text(
                          DateFormatter.formatShortTime(item.timestamp),
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.notes,
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : AppColors.textSecondary),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
