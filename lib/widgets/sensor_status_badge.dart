import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_reading_model.dart';

class SensorStatusBadge extends StatelessWidget {
  final SensorStatus status;
  final bool compact;

  const SensorStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    IconData iconData;

    switch (status) {
      case SensorStatus.normal:
        textColor = AppColors.statusNormal;
        bgColor = AppColors.statusNormalBg;
        borderColor = AppColors.statusNormalBorder;
        iconData = Icons.check_circle_rounded;
        break;
      case SensorStatus.warning:
        textColor = AppColors.statusWarning;
        bgColor = AppColors.statusWarningBg;
        borderColor = AppColors.statusWarningBorder;
        iconData = Icons.warning_amber_rounded;
        break;
      case SensorStatus.critical:
        textColor = AppColors.statusCritical;
        bgColor = AppColors.statusCriticalBg;
        borderColor = AppColors.statusCriticalBorder;
        iconData = Icons.error_rounded;
        break;
      case SensorStatus.offline:
        textColor = AppColors.statusOffline;
        bgColor = AppColors.statusOfflineBg;
        borderColor = AppColors.statusOfflineBorder;
        iconData = Icons.cloud_off_rounded;
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 10, color: textColor),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
