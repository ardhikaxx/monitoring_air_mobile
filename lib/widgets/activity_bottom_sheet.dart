import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/activity_model.dart';
import '../providers/sensor_simulation_provider.dart';

class ActivityBottomSheet extends StatelessWidget {
  const ActivityBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();
    final activities = provider.activities;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.techBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_active_outlined, color: AppColors.techBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pusat Notifikasi & Aktivitas',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      Text(
                        'Riwayat peristiwa sistem & peringatan telemetri',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              if (activities.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.done_all_rounded, size: 20, color: AppColors.techBlue),
                  tooltip: 'Tandai Semua Dibaca',
                  onPressed: () {
                    provider.markAllActivitiesRead();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Expanded(
            child: activities.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada riwayat aktivitas sistem.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (context, index) => const Divider(height: 14),
                    itemBuilder: (ctx, i) {
                      final item = activities[i];
                      Color color;
                      IconData icon;

                      switch (item.type) {
                        case ActivityType.success:
                          color = AppColors.statusNormal;
                          icon = Icons.check_circle_rounded;
                          break;
                        case ActivityType.warning:
                          color = AppColors.statusWarning;
                          icon = Icons.warning_amber_rounded;
                          break;
                        case ActivityType.critical:
                          color = AppColors.statusCritical;
                          icon = Icons.error_rounded;
                          break;
                        case ActivityType.info:
                          color = AppColors.techBlue;
                          icon = Icons.info_rounded;
                          break;
                      }

                      return InkWell(
                        onTap: () => provider.markActivityRead(item.id),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, color: color, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                            color: AppColors.navyBlue,
                                          ),
                                        ),
                                      ),
                                      if (!item.isRead)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.techBlue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormatter.timeAgo(item.timestamp),
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
