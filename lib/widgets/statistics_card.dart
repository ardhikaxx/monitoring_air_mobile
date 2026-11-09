import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatisticsCard extends StatelessWidget {
  final int totalSensors;
  final int normalCount;
  final int warningCount;
  final int errorOrOfflineCount;
  final double flowRate;

  const StatisticsCard({
    super.key,
    required this.totalSensors,
    required this.normalCount,
    required this.warningCount,
    required this.errorOrOfflineCount,
    required this.flowRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Top 3 items
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Total Sensor',
                value: '$totalSensors',
                subtitle: '4 Inlet • 3 Outlet',
                icon: Icons.hub_outlined,
                accentColor: AppColors.techBlue,
                bgColor: AppColors.techBlue.withValues(alpha: 0.08),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Normal',
                value: '$normalCount',
                subtitle: 'Parameter Stabil',
                icon: Icons.check_circle_outline_rounded,
                accentColor: AppColors.statusNormal,
                bgColor: AppColors.statusNormalBg,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Bottom 3 items
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Warning',
                value: '$warningCount',
                subtitle: 'Mendekati Batas',
                icon: Icons.warning_amber_rounded,
                accentColor: AppColors.statusWarning,
                bgColor: AppColors.statusWarningBg,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Error / Offline',
                value: '$errorOrOfflineCount',
                subtitle: errorOrOfflineCount > 0 ? 'Perlu Tindakan' : 'Aman',
                icon: Icons.error_outline_rounded,
                accentColor: errorOrOfflineCount > 0
                    ? AppColors.statusCritical
                    : AppColors.statusOffline,
                bgColor: errorOrOfflineCount > 0
                    ? AppColors.statusCriticalBg
                    : AppColors.statusOfflineBg,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricItem(
                context,
                title: 'Flow Rate',
                value: flowRate.toStringAsFixed(1),
                subtitle: 'L/jam (Debit)',
                icon: Icons.water_outlined,
                accentColor: AppColors.accentCyan,
                bgColor: AppColors.accentCyan.withValues(alpha: 0.1),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.navyBlue,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textMuted : AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
