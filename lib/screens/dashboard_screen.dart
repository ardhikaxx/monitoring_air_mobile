import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_model.dart';
import '../providers/sensor_simulation_provider.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/device_status_card.dart';
import '../widgets/monitoring_chart_card.dart';
import '../widgets/sensor_monitoring_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/water_quality_comparison_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();
    final inletSensors = provider.inletSensors;
    final outletSensors = provider.outletSensors;

    // Turbidity, pH, and temp inlet values for comparison tags in outlet cards
    final turbInletVal = provider.getSensorById('SEN-IN-TURB')?.currentValue ?? 85.0;
    final phInletVal = provider.getSensorById('SEN-IN-PH')?.currentValue ?? 6.3;
    final tempInletVal = provider.getSensorById('SEN-IN-TEMP')?.currentValue ?? 27.0;

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
              // 1. Sleek Header Title & Timestamp
              _buildHeaderTitle(provider),

              const SizedBox(height: 12),

              // 2. Device Connection Status Card (ESP32)
              DeviceStatusCard(device: provider.device),

              const SizedBox(height: 12),

              // 3. Statistical Summary (5 key metrics in one sleek bar)
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

              const SizedBox(height: 16),

              // 5. INLET SENSORS (4 Sensors)
              _buildSectionHeader(
                title: 'Sensor Inlet (Air Baku)',
                countLabel: '4 Sensor',
                icon: Icons.input_rounded,
              ),
              const SizedBox(height: 8),
              ...inletSensors.map(
                (sensor) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SensorMonitoringCard(sensor: sensor),
                ),
              ),

              const SizedBox(height: 10),

              // 6. OUTLET SENSORS (3 Sensors)
              _buildSectionHeader(
                title: 'Sensor Outlet (Air Hasil)',
                countLabel: '3 Sensor',
                icon: Icons.output_rounded,
              ),
              const SizedBox(height: 8),
              ...outletSensors.map((sensor) {
                double? compVal;
                if (sensor.type == SensorType.turbidityOutlet) {
                  compVal = turbInletVal;
                } else if (sensor.type == SensorType.phOutlet) {
                  compVal = phInletVal;
                } else if (sensor.type == SensorType.temperatureOutlet) {
                  compVal = tempInletVal;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SensorMonitoringCard(
                    sensor: sensor,
                    inletComparisonValue: compVal,
                  ),
                );
              }),

              const SizedBox(height: 10),

              // 7. Monitoring Chart Card (fl_chart)
              const MonitoringChartCard(),

              const SizedBox(height: 20),
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
              const SizedBox(height: 16),
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

  Widget _buildSectionHeader({
    required String title,
    required String countLabel,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.navyBlue, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            countLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
