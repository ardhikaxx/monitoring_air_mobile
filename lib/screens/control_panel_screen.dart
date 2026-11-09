import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../providers/sensor_provider.dart';
import '../services/simulation_service.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/sensor_status_badge.dart';
import '../widgets/sensor_test_modal.dart';

class ControlPanelScreen extends StatelessWidget {
  const ControlPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Control Panel IoT'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 1. Device Control Center (ESP32)
          _buildDeviceControlCenter(context, provider, isDark),

          const SizedBox(height: 16),

          // 2. Monitoring State Controls (Start / Pause)
          _buildMonitoringToggleCard(context, provider, isDark),

          const SizedBox(height: 16),

          // 3. Demonstration Scenarios Section
          _buildDemonstrationScenariosCard(context, provider, isDark),

          const SizedBox(height: 16),

          // 4. Global Batch Actions (Test All, Refresh All, Reset Simulation)
          _buildGlobalBatchActionsCard(context, provider, isDark),

          const SizedBox(height: 16),

          // 5. Sensor Control Center (Grouped Inlet & Outlet)
          _buildSensorControlCenter(context, provider, isDark),

          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }

  // 1. Device Control Center
  Widget _buildDeviceControlCenter(
    BuildContext context,
    SensorProvider provider,
    bool isDark,
  ) {
    final device = provider.device;
    final isOnline = device.status == DeviceConnectionStatus.online;

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.settings_input_composite_rounded, color: AppColors.techBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Control Center (ESP32)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      'ID: ${device.deviceId} • ${device.ipAddress}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Connection simulation toggles (Online, Unstable, Offline)
          const Text(
            'Simulasi Status Konektivitas ESP32:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatusRadio(
                  title: 'Online',
                  isSelected: device.status == DeviceConnectionStatus.online,
                  activeColor: AppColors.statusNormal,
                  onTap: () => provider.setDeviceStatus(DeviceConnectionStatus.online),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusRadio(
                  title: 'Unstable',
                  isSelected: device.status == DeviceConnectionStatus.unstable,
                  activeColor: AppColors.statusWarning,
                  onTap: () => provider.setDeviceStatus(DeviceConnectionStatus.unstable),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusRadio(
                  title: 'Offline',
                  isSelected: device.status == DeviceConnectionStatus.offline,
                  activeColor: AppColors.statusCritical,
                  onTap: () => provider.setDeviceStatus(DeviceConnectionStatus.offline),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Telemetry Details Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Nama Modul', device.name),
                const SizedBox(height: 6),
                _buildInfoRow('SSID Wi-Fi', device.wifiSsid),
                const SizedBox(height: 6),
                _buildInfoRow('Kekuatan Sinyal', isOnline ? '${device.wifiRssi} dBm (${device.signalPercentage}%)' : 'Terputus'),
                const SizedBox(height: 6),
                _buildInfoRow('Uptime Sistem', isOnline ? device.formattedUptime : '0j 0m 0s'),
                const SizedBox(height: 6),
                _buildInfoRow('Volume Diolah', '${device.totalProcessedVolume.toStringAsFixed(1)} Liter'),
                const SizedBox(height: 6),
                _buildInfoRow('Waktu Komunikasi', DateFormatter.formatShortTime(device.lastSync)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRadio({
    required String title,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // 2. Monitoring State Controls (Start / Pause)
  Widget _buildMonitoringToggleCard(
    BuildContext context,
    SensorProvider provider,
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
                'Monitoring Control Engine',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.isMonitoring ? AppColors.statusNormalBg : AppColors.statusWarningBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.isMonitoring ? AppColors.statusNormalBorder : AppColors.statusWarningBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: provider.isMonitoring ? AppColors.statusNormal : AppColors.statusWarning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.isMonitoring ? 'Status: RUNNING' : 'Status: PAUSED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: provider.isMonitoring ? AppColors.statusNormal : AppColors.statusWarning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            provider.isMonitoring
                ? 'Telemetri otomatis sedang berjalan setiap ${provider.updateInterval} detik.'
                : 'Telemetri otomatis dijeda. Sensor tidak diperbarui secara periodik kecuali manual.',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isMonitoring ? null : () => provider.startMonitoring(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusNormal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start Monitoring'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !provider.isMonitoring ? null : () => provider.pauseMonitoring(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusWarning,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
                  ),
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: const Text('Pause Monitoring'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Demonstration Scenarios
  Widget _buildDemonstrationScenariosCard(
    BuildContext context,
    SensorProvider provider,
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
              Row(
                children: [
                  const Icon(Icons.science_outlined, size: 18, color: AppColors.techBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Skenario Demonstrasi Simulasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => provider.resetScenario(),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                child: const Text('Reset Normal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Uji reaksi dashboard & notifikasi saat terjadi gangguan spesifik:',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DemoScenario.values.map((scen) {
              final isCurrent = provider.currentScenario == scen;
              return FilterChip(
                label: Text(
                  scen.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? Colors.white : (isDark ? Colors.white70 : AppColors.navyBlue),
                  ),
                ),
                selected: isCurrent,
                selectedColor: scen == DemoScenario.normal
                    ? AppColors.statusNormal
                    : (scen == DemoScenario.esp32Disconnected || scen == DemoScenario.temperatureError)
                        ? AppColors.statusCritical
                        : AppColors.techBlue,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
                onSelected: (_) {
                  provider.applyScenario(scen);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Skenario diterapkan: ${scen.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 4. Global Batch Actions
  Widget _buildGlobalBatchActionsCard(
    BuildContext context,
    SensorProvider provider,
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
          Text(
            'Tindakan Global Sistem',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 12),
          // Test All Sensors button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                SensorTestModal.showBatchTestModal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.fact_check_rounded, size: 18),
              label: const Text('Test All Sensors (Uji 7 Sensor Sekaligus)'),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await ConfirmationDialog.show(
                      context,
                      title: 'Perbarui Seluruh Sensor?',
                      message: 'Sistem akan meminta pembacaan ulang instan dari seluruh 7 sensor yang terpasang.',
                      confirmText: 'Perbarui',
                      icon: Icons.sync_rounded,
                    );
                    if (confirmed == true) {
                      await provider.refreshAllSensors();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seluruh sensor berhasil diperbarui.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh All', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await ConfirmationDialog.show(
                      context,
                      title: 'Reset Simulasi ke Awal?',
                      message: 'Semua nilai sensor, ambang batas, dan skenario akan dikembalikan ke kondisi awal pabrik.',
                      confirmText: 'Reset Data',
                      isDestructive: true,
                      icon: Icons.restart_alt_rounded,
                    );
                    if (confirmed == true) {
                      provider.resetSimulation();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Simulasi berhasil direset ke kondisi default.')),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusCritical,
                    side: const BorderSide(color: AppColors.statusCritical, width: 1.2),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Reset Simulation', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Sensor Control Center (Grouped by Inlet & Outlet)
  Widget _buildSensorControlCenter(
    BuildContext context,
    SensorProvider provider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sensor Control Center (7 Sensor)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.navyBlue,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.techBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Independen Control',
                style: TextStyle(fontSize: 10, color: AppColors.techBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Section: INLET SENSORS
        _buildSectionHeader('Sensor Jalur Inlet (4 Sensor Air Baku)', AppColors.rawWater),
        const SizedBox(height: 8),
        ...provider.inletSensors.map((s) => _buildSensorControlCard(context, provider, s, isDark)),

        const SizedBox(height: 16),

        // Section: OUTLET SENSORS
        _buildSectionHeader('Sensor Jalur Outlet (3 Sensor Air Bersih)', AppColors.techBlue),
        const SizedBox(height: 8),
        ...provider.outletSensors.map((s) => _buildSensorControlCard(context, provider, s, isDark)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildSensorControlCard(
    BuildContext context,
    SensorProvider provider,
    SensorModel sensor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Name + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      '${sensor.id} • ${sensor.location.label}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              SensorStatusBadge(status: sensor.status, compact: true),
            ],
          ),
          const SizedBox(height: 8),

          // Values & Health
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nilai: ${sensor.status == SensorStatus.offline ? "--" : sensor.currentValue} ${sensor.unit}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
              Text(
                sensor.lastTestResult != null ? 'Uji: ${sensor.lastTestResult}' : 'Belum Diuji',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Three action buttons: Check Sensor, Test Sensor, Refresh Data
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    SensorTestModal.showCheckModal(context, sensor);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Check Sensor', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    SensorTestModal.showTestModal(context, sensor);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Test Sensor', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: () async {
                  await provider.refreshSensor(sensor.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data ${sensor.name} berhasil diperbarui.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
