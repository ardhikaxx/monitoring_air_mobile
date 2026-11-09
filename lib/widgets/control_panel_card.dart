import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../providers/sensor_simulation_provider.dart';
import '../services/simulation_service.dart';
import 'batch_test_bottom_sheet.dart';
import 'confirmation_dialog.dart';
import 'sensor_check_bottom_sheet.dart';
import 'sensor_status_badge.dart';

class ControlPanelCard extends StatelessWidget {
  const ControlPanelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();
    final device = provider.device;
    final isOnline = device.status == DeviceConnectionStatus.online;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.techBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.techBlue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Control Panel & Pengecekan Sensor',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: provider.isMonitoring ? AppColors.statusNormalBg : AppColors.statusWarningBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: provider.isMonitoring ? AppColors.statusNormalBorder : AppColors.statusWarningBorder,
                  ),
                ),
                child: Text(
                  provider.isMonitoring ? 'RUNNING' : 'PAUSED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: provider.isMonitoring ? AppColors.statusNormal : AppColors.statusWarning,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 1. ESP32 Telemetry Status Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'ESP32 Controller: ${device.name}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${device.deviceId}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Wi-Fi: ${isOnline ? "${device.wifiRssi} dBm" : "Offline"}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    const Text('•', style: TextStyle(color: AppColors.textMuted)),
                    Text(
                      'Uptime: ${isOnline ? device.formattedUptime : "0j 0m"}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    const Text('•', style: TextStyle(color: AppColors.textMuted)),
                    Text(
                      'Sync: ${DateFormatter.formatShortTime(device.lastSync)}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Monitoring Engine Toggle (Start & Pause)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isMonitoring ? null : () => provider.startMonitoring(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusNormal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Start Monitoring', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !provider.isMonitoring ? null : () => provider.pauseMonitoring(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusWarning,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.pause_rounded, size: 16),
                  label: const Text('Pause Monitoring', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Device Connection Simulation Buttons
          const Text(
            'Simulasi Koneksi ESP32:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildConnectionChip(
                  label: 'Online',
                  isSelected: device.status == DeviceConnectionStatus.online,
                  color: AppColors.statusNormal,
                  onTap: () => provider.setDeviceStatus(DeviceConnectionStatus.online),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildConnectionChip(
                  label: 'Unstable',
                  isSelected: device.status == DeviceConnectionStatus.unstable,
                  color: AppColors.statusWarning,
                  onTap: () => provider.setDeviceStatus(DeviceConnectionStatus.unstable),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildConnectionChip(
                  label: 'Offline',
                  isSelected: device.status == DeviceConnectionStatus.offline,
                  color: AppColors.statusCritical,
                  onTap: () => provider.setDeviceStatus(DeviceConnectionStatus.offline),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4. Demonstration Scenarios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skenario Demonstrasi IoT:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              if (provider.currentScenario != DemoScenario.normal)
                InkWell(
                  onTap: () => provider.resetScenario(),
                  child: const Text('Reset Normal', style: TextStyle(fontSize: 10, color: AppColors.techBlue, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DemoScenario.values.map((scen) {
                final isCurrent = provider.currentScenario == scen;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(scen.title),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? Colors.white : AppColors.textPrimary,
                    ),
                    selected: isCurrent,
                    selectedColor: scen == DemoScenario.normal ? AppColors.statusNormal : AppColors.techBlue,
                    backgroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    onSelected: (_) => provider.applyScenario(scen),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // 5. Global Actions: Test All Sensors, Refresh All Data, Reset Simulation
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    BatchTestBottomSheet.show(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  icon: const Icon(Icons.fact_check_rounded, size: 15),
                  label: const Text('Test All Sensors', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.refreshAllData(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Refresh All Data', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                onPressed: () async {
                  final confirmed = await ConfirmationDialog.show(
                    context,
                    title: 'Reset Simulasi ke Kondisi Awal?',
                    message: 'Seluruh nilai sensor, ambang batas, dan skenario demonstrasi akan dikembalikan ke default.',
                    confirmText: 'Reset Data',
                    isDestructive: true,
                    icon: Icons.restart_alt_rounded,
                  );
                  if (confirmed == true) {
                    provider.resetSimulation();
                  }
                },
                icon: const Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.statusCritical),
                tooltip: 'Reset Simulasi',
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 6. Sensor Control Center (Grouped List of 7 Sensors)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sensor Control Center (7 Sensor)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Direct Diagnostics', style: TextStyle(fontSize: 9, color: AppColors.techBlue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Inlet sensors list
          _buildGroupHeader('Jalur Inlet (Air Baku)'),
          const SizedBox(height: 6),
          ...provider.inletSensors.map((s) => _buildCompactSensorRow(context, s)),

          const SizedBox(height: 10),

          // Outlet sensors list
          _buildGroupHeader('Jalur Outlet (Air Bersih)'),
          const SizedBox(height: 6),
          ...provider.outletSensors.map((s) => _buildCompactSensorRow(context, s)),
        ],
      ),
    );
  }

  Widget _buildConnectionChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
    );
  }

  Widget _buildCompactSensorRow(BuildContext context, SensorModel sensor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sensor.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      sensor.status == SensorStatus.offline
                          ? '--'
                          : '${sensor.currentValue} ${sensor.unit}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.techBlue),
                    ),
                    const SizedBox(width: 8),
                    SensorStatusBadge(status: sensor.status, compact: true),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              SensorCheckBottomSheet.show(context, sensor);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Check Sensor', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
