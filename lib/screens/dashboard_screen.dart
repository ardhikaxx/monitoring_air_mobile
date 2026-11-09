import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../providers/sensor_simulation_provider.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/device_status_card.dart';
import '../widgets/monitoring_chart_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/water_quality_comparison_card.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const DashboardScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();

    final turbInlet = provider.getSensorById('SEN-IN-TURB')?.currentValue ?? 85.0;
    final turbOutlet = provider.getSensorById('SEN-IN-OUT-TURB')?.currentValue ?? 3.0;
    final phInlet = provider.getSensorById('SEN-IN-PH')?.currentValue ?? 6.3;
    final phOutlet = provider.getSensorById('SEN-IN-OUT-PH')?.currentValue ?? 7.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHeader(),
      body: RefreshIndicator(
        color: AppColors.techBlue,
        onRefresh: () async {
          await provider.refreshAllData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sleek Header Title & Auto-Sync Status
              _buildHeaderTitle(provider),

              const SizedBox(height: 12),

              // 2. Device Connection Status Card (ESP32)
              DeviceStatusCard(device: provider.device),

              const SizedBox(height: 12),

              // 3. Statistical Summary Bar
              StatisticsCard(
                totalSensors: provider.totalSensorsCount,
                normalCount: provider.normalSensorsCount,
                warningCount: provider.warningSensorsCount,
                errorOrOfflineCount: provider.errorOrOfflineSensorsCount,
                flowRate: provider.device.flowRate,
              ),

              const SizedBox(height: 14),

              // 4. Water Quality Comparison Card (Inlet vs Outlet)
              WaterQualityComparisonCard(comparison: provider.waterQualityComparison),

              const SizedBox(height: 14),

              // 5. Quick Navigation to Dedicated Inlet & Outlet Screens
              Row(
                children: [
                  Expanded(
                    child: _buildQuickNavCard(
                      context,
                      title: 'Sensor Inlet',
                      subtitle: '4 Sensor Air Baku',
                      metric: '$turbInlet NTU • $phInlet pH',
                      icon: Icons.input_rounded,
                      accentColor: AppColors.rawWater,
                      onTap: () => onNavigateToTab?.call(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickNavCard(
                      context,
                      title: 'Sensor Outlet',
                      subtitle: '3 Sensor Air Hasil',
                      metric: '$turbOutlet NTU • $phOutlet pH',
                      icon: Icons.output_rounded,
                      accentColor: AppColors.techBlue,
                      onTap: () => onNavigateToTab?.call(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 6. Parameter Trend Chart (fl_chart)
              const MonitoringChartCard(),

              const SizedBox(height: 16),
              // Footer
              const Center(
                child: Text(
                  'AquaMonitor • IoT Water Treatment System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              // Bottom padding for Floating Pill Bottom Nav
              const SizedBox(height: 85),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(SensorSimulationProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Monitoring',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyBlue,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Pembaruan ${DateFormatter.formatShortTime(provider.device.lastSync)} WIB',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
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
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: provider.isMonitoring ? AppColors.statusNormal : AppColors.statusWarning,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                provider.isMonitoring ? 'Auto-Sync' : 'Paused',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: provider.isMonitoring ? AppColors.statusNormal : AppColors.statusWarning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String metric,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              metric,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.navyBlue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
