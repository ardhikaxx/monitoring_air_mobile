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
              // 1. Hero / Header Greeting & Dynamic Date/Time
              _buildHeaderGreeting(context, provider),

              const SizedBox(height: 14),

              // 2. Device Connection Status Card (ESP32)
              DeviceStatusCard(device: provider.device),

              const SizedBox(height: 14),

              // 3. Statistical Summary Cards (7 Sensors Total, Normal, Warning, Error/Offline, Flow Rate)
              StatisticsCard(
                totalSensors: provider.totalSensorsCount,
                normalCount: provider.normalSensorsCount,
                warningCount: provider.warningSensorsCount,
                errorOrOfflineCount: provider.errorOrOfflineSensorsCount,
                flowRate: provider.device.flowRate,
              ),

              const SizedBox(height: 16),

              // 4. Water Quality Comparison Card (Inlet vs Outlet)
              WaterQualityComparisonCard(comparison: provider.waterQualityComparison),

              const SizedBox(height: 18),

              // 5. INLET MONITORING SECTION (4 Sensors)
              _buildSectionHeader(
                title: 'Inlet Monitoring',
                subtitle: 'Pemantauan kualitas & debit air baku sebelum filtrasi multimedia',
                countLabel: '4 Sensor Terpasang',
                badgeColor: AppColors.rawWater,
                icon: Icons.input_rounded,
              ),
              const SizedBox(height: 10),
              ...inletSensors.map(
                (sensor) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SensorMonitoringCard(sensor: sensor),
                ),
              ),

              const SizedBox(height: 10),

              // 6. OUTLET MONITORING SECTION (3 Sensors)
              _buildSectionHeader(
                title: 'Outlet Monitoring',
                subtitle: 'Evaluasi hasil filtrasi bertingkat & sterilisasi sinar UV',
                countLabel: '3 Sensor Evaluasi',
                badgeColor: AppColors.techBlue,
                icon: Icons.output_rounded,
              ),
              const SizedBox(height: 10),
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
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SensorMonitoringCard(
                    sensor: sensor,
                    inletComparisonValue: compVal,
                  ),
                );
              }),

              const SizedBox(height: 10),

              // 7. Monitoring Chart Card (fl_chart)
              const MonitoringChartCard(),

              const SizedBox(height: 24),
              // Footer
              Center(
                child: Text(
                  'AquaMonitor • Single Page Monitoring Dashboard\nIoT Multimedia Water Treatment System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                    height: 1.4,
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

  Widget _buildHeaderGreeting(BuildContext context, SensorSimulationProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IoT Water Treatment Monitoring',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pantau kondisi air sebelum dan sesudah proses penjernihan melalui sistem monitoring sensor IoT.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.water_rounded,
                  color: AppColors.techBlue,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Pembaruan: ${DateFormatter.formatFull(provider.device.lastSync)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: provider.isMonitoring ? AppColors.statusNormalBg : AppColors.statusWarningBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  provider.isMonitoring ? 'Auto-Sync Active' : 'Paused',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: provider.isMonitoring ? AppColors.statusNormal : AppColors.statusWarning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String countLabel,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: badgeColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        countLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
