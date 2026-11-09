import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    Color accentColor;
    Color bgColor;

    switch (notification.type) {
      case NotificationType.success:
        icon = Icons.check_circle_rounded;
        accentColor = AppColors.statusNormal;
        bgColor = AppColors.statusNormalBg;
        break;
      case NotificationType.warning:
        icon = Icons.warning_amber_rounded;
        accentColor = AppColors.statusWarning;
        bgColor = AppColors.statusWarningBg;
        break;
      case NotificationType.critical:
        icon = Icons.error_rounded;
        accentColor = AppColors.statusCritical;
        bgColor = AppColors.statusCriticalBg;
        break;
      case NotificationType.info:
        icon = Icons.info_rounded;
        accentColor = AppColors.techBlue;
        bgColor = AppColors.techBlue.withValues(alpha: 0.1);
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? AppColors.darkCard : Colors.white)
              : (isDark ? AppColors.darkSurface : const Color(0xFFF0F7FF)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : AppColors.techBlue.withValues(alpha: 0.35),
            width: notification.isRead ? 1 : 1.3,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.navyBlue,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.techBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (notification.sensorId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.techBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.sensorId!,
                            style: const TextStyle(fontSize: 10, color: AppColors.techBlue, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        DateFormatter.timeAgo(notification.timestamp),
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
