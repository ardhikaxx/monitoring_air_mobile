import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/notification_model.dart';
import '../providers/sensor_provider.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Kritis', 'Peringatan', 'Sukses', 'Informasi'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allNotifs = provider.notifications;
    final unreadCount = provider.unreadNotificationsCount;

    // Filter by category
    final filtered = allNotifs.where((n) {
      if (_selectedCategory == 'Semua') return true;
      if (_selectedCategory == 'Kritis') return n.type == NotificationType.critical;
      if (_selectedCategory == 'Peringatan') return n.type == NotificationType.warning;
      if (_selectedCategory == 'Sukses') return n.type == NotificationType.success;
      if (_selectedCategory == 'Informasi') return n.type == NotificationType.info;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi & Peringatan'),
        backgroundColor: AppColors.navyBlue,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                provider.markAllNotificationsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua notifikasi ditandai dibaca.')),
                );
              },
              icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 16),
              label: const Text('Tandai Dibaca', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
            tooltip: 'Hapus Semua',
            onPressed: allNotifs.isEmpty
                ? null
                : () {
                    provider.clearAllNotifications();
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: isDark ? AppColors.darkCard : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.techBlue,
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Content List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final notif = filtered[i];
                      return NotificationCard(
                        notification: notif,
                        onTap: () {
                          provider.markNotificationRead(notif.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.techBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Notifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sistem monitoring air beroperasi normal. Tidak ada peringatan baru dalam kategori ini.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
