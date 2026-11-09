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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(
            label: 'Total Sensor',
            value: '$totalSensors',
            valueColor: AppColors.navyBlue,
            icon: Icons.sensors_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Normal',
            value: '$normalCount',
            valueColor: AppColors.statusNormal,
            icon: Icons.check_circle_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Warning',
            value: '$warningCount',
            valueColor: AppColors.statusWarning,
            icon: Icons.warning_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Error/Off',
            value: '$errorOrOfflineCount',
            valueColor: errorOrOfflineCount > 0 ? AppColors.statusCritical : AppColors.statusOffline,
            icon: Icons.error_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Debit Air',
            value: '${flowRate.toStringAsFixed(0)} L/j',
            valueColor: AppColors.techBlue,
            icon: Icons.water_drop_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.borderLight,
    );
  }

  Widget _buildItem({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: valueColor),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
