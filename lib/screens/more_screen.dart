import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/sensor_provider.dart';
import 'history_screen.dart';
import 'inlet_monitoring_screen.dart';
import 'notification_screen.dart';
import 'outlet_monitoring_screen.dart';
import 'sensor_testing_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _showAboutFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.water_drop_rounded, color: AppColors.techBlue),
            SizedBox(width: 8),
            Text('Sistem Filter Multimedia', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AquaMonitor mengawasi instalasi penjernihan air baku sungai secara berkelanjutan dengan lapisan filter multimedia:',
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
              SizedBox(height: 10),
              Text('1. Sedimentasi: Pemisahan lumpur kasar gravitasi.'),
              Text('2. Filter Kerikil: Menahan partikel padatan berukuran besar.'),
              Text('3. Pasir Silika: Menyaring suspensi sedimen mikro & lumpur halus.'),
              Text('4. Zeolit: Menyerap amonium, ion kalsium, dan logam berat.'),
              Text('5. Karbon Aktif: Mengikat bau, rasa, klorin, dan senyawa organik.'),
              Text('6. Disinfeksi UV: Membasmi bakteri patogen dan mikroorganisme.'),
              SizedBox(height: 10),
              Text(
                'Telemetri ESP32 memantau parameter 4 sensor inlet dan 3 sensor outlet secara real-time.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = provider.unreadNotificationsCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu & Ekstra'),
        backgroundColor: AppColors.navyBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // User / Device profile banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navyBlue, AppColors.techBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyBlue.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                  child: const Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrator Sistem',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'AquaMonitor IoT System Controller',
                        style: TextStyle(
                          color: Color(0xFFBAE6FD),
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kapasitas: 20 L/jam • ESP32 Online',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Group 1: Monitoring & Visual Diagrams
          _buildGroupHeader('Diagram & Visualisasi Khusus'),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            isDark: isDark,
            icon: Icons.water_rounded,
            accentColor: AppColors.rawWater,
            title: 'Visual Jalur Inlet',
            subtitle: 'Diagram pipa air baku & 4 probe sensor',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InletMonitoringScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            isDark: isDark,
            icon: Icons.water_drop_rounded,
            accentColor: AppColors.cleanWater,
            title: 'Visual Jalur Outlet',
            subtitle: 'Diagram pipa air hasil & disinfeksi UV',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OutletMonitoringScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Group 2: Diagnostics & Analytics
          _buildGroupHeader('Diagnostik & Analisis Data'),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            isDark: isDark,
            icon: Icons.biotech_rounded,
            accentColor: AppColors.techBlue,
            title: 'Pengujian Sensor & Kalibrasi',
            subtitle: 'Uji mandiri, simulasi offset kalibrasi & log',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SensorTestingScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            isDark: isDark,
            icon: Icons.query_stats_rounded,
            accentColor: AppColors.accentCyan,
            title: 'Grafik & Histori Lengkap',
            subtitle: 'Analisis fl_chart, filter waktu & export data CSV',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            isDark: isDark,
            icon: Icons.notifications_none_rounded,
            accentColor: AppColors.statusWarning,
            title: 'Pusat Notifikasi & Alarm',
            subtitle: 'Catatan peringatan nilai batas dan telemetri',
            badgeCount: unread,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Group 3: Sistem & Informasi
          _buildGroupHeader('Sistem & Informasi Teknis'),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            isDark: isDark,
            icon: Icons.tune_rounded,
            accentColor: AppColors.techBlue,
            title: 'Pengaturan & Ambang Batas',
            subtitle: 'Batas NTU, pH, suhu, flow rate & interval',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            isDark: isDark,
            icon: Icons.schema_outlined,
            accentColor: const Color(0xFF8B5CF6),
            title: 'Tentang Filter Multimedia',
            subtitle: 'Alur kerja pasir silika, karbon aktif, zeolit & UV',
            onTap: () => _showAboutFilterDialog(context),
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              'AquaMonitor IoT • Multimedia Water Treatment System\nFrontend Simulation Prototype',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textMuted,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Material(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.navyBlue,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount != null && badgeCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusCritical,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
      ),
    );
  }
}
