import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/device_model.dart';
import '../providers/sensor_provider.dart';
import '../screens/notification_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotification = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isOnline = provider.device.status == DeviceConnectionStatus.online;
    final isUnstable = provider.device.status == DeviceConnectionStatus.unstable;
    final unread = provider.unreadNotificationsCount;

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.navyBlue,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14.0),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentCyan, AppColors.techBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
      titleSpacing: 10,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              // Connection Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.statusNormal.withValues(alpha: 0.2)
                      : isUnstable
                          ? AppColors.statusWarning.withValues(alpha: 0.2)
                          : AppColors.statusCritical.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOnline
                        ? AppColors.statusNormal.withValues(alpha: 0.6)
                        : isUnstable
                            ? AppColors.statusWarning.withValues(alpha: 0.6)
                            : AppColors.statusCritical.withValues(alpha: 0.6),
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
                        color: isOnline
                            ? AppColors.statusNormal
                            : isUnstable
                                ? AppColors.statusWarning
                                : AppColors.statusCritical,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.device.status.label.toUpperCase(),
                      style: TextStyle(
                        color: isOnline
                            ? const Color(0xFF6EE7B7)
                            : isUnstable
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFFCA5A5),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Text(
            'AquaMonitor • Water Treatment IoT',
            style: TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        ...?actions,
        if (showNotification)
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                if (unread > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.statusCritical,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Notifikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
        const SizedBox(width: 6),
      ],
    );
  }
}
