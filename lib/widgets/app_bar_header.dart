import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/device_model.dart';
import '../providers/sensor_simulation_provider.dart';
import 'settings_bottom_sheet.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();
    final isOnline = provider.device.status == DeviceConnectionStatus.online;
    final isUnstable = provider.device.status == DeviceConnectionStatus.unstable;

    Color statusColor = isOnline
        ? AppColors.statusNormal
        : isUnstable
            ? AppColors.statusWarning
            : AppColors.statusCritical;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.borderLight,
          height: 1.0,
        ),
      ),
      leadingWidth: 50,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14.0),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.navyBlue,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      titleSpacing: 8,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'AquaMonitor',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              // Connection Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.device.status.label.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          const Text(
            'Water Treatment System',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.tune_rounded,
            color: AppColors.navyBlue,
            size: 21,
          ),
          tooltip: 'Pengaturan Simulasi',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const SettingsBottomSheet(),
            );
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}
