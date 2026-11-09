import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/notification_model.dart';
import '../providers/sensor_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/device_connection_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/water_quality_comparison_card.dart';
import '../widgets/water_treatment_diagram.dart';
import 'inlet_monitoring_screen.dart';
import 'outlet_monitoring_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.refreshAllSensors();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner & Last Update
              _buildGreetingHeader(context, provider, isDark),

              const SizedBox(height: 16),

              // 1. Device Connection Status Card (ESP32)
              DeviceConnectionCard(
                device: provider.device,
                onStatusTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Status ESP32: ${provider.device.status.label}. Kontrol koneksi dapat diubah melalui Control Panel.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. Summary Statistics Card (Total 7, Normal, Warning, Error/Offline, Flow Rate)
              StatisticsCard(
                totalSensors: provider.totalSensorsCount,
                normalCount: provider.normalSensorsCount,
                warningCount: provider.warningSensorsCount,
                errorOrOfflineCount: provider.errorOrOfflineSensorsCount,
                flowRate: provider.device.flowRate,
              ),

              const SizedBox(height: 16),

              // Quick Shortcuts to Pipe Monitoring Pages
              _buildPipeQuickShortcuts(context, isDark),

              const SizedBox(height: 16),

              // 3. Water Treatment Overview Diagram
              WaterTreatmentDiagram(sensors: provider.sensors),

              const SizedBox(height: 16),

              // 4. Water Quality Summary Comparison Card (Inlet vs Outlet)
              WaterQualityComparisonCard(
                comparison: provider.waterQualityComparison,
              ),

              const SizedBox(height: 16),

              // 5. Recent Activity Section
              _buildRecentActivitySection(context, provider, isDark),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(
    BuildContext context,
    SensorProvider provider,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, Administrator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Pantau sistem penjernihan air secara langsung melalui IoT.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.water_rounded,
                  color: AppColors.techBlue,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Pembaruan: ${DateFormatter.formatFull(provider.device.lastSync)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: provider.isMonitoring
                      ? AppColors.statusNormalBg
                      : AppColors.statusWarningBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  provider.isMonitoring ? 'Auto-Sync' : 'Paused',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: provider.isMonitoring
                        ? AppColors.statusNormal
                        : AppColors.statusWarning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPipeQuickShortcuts(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InletMonitoringScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.rawWater.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.input_rounded, size: 16, color: AppColors.rawWater),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jalur Inlet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Air Baku (4 Sensor)', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OutletMonitoringScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.techBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.output_rounded, size: 16, color: AppColors.techBlue),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jalur Outlet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Air Hasil (3 Sensor)', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(
    BuildContext context,
    SensorProvider provider,
    bool isDark,
  ) {
    final activities = provider.notifications.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppColors.techBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Aktivitas Terbaru Sistem',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              Text(
                '${provider.notifications.length} Catatan',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (activities.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Belum ada riwayat aktivitas.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 14),
              itemBuilder: (ctx, i) {
                final notif = activities[i];
                Color dotColor;
                switch (notif.type) {
                  case NotificationType.success:
                    dotColor = AppColors.statusNormal;
                    break;
                  case NotificationType.warning:
                    dotColor = AppColors.statusWarning;
                    break;
                  case NotificationType.critical:
                    dotColor = AppColors.statusCritical;
                    break;
                  case NotificationType.info:
                    dotColor = AppColors.techBlue;
                    break;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                DateFormatter.timeAgo(notif.timestamp),
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notif.message,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
