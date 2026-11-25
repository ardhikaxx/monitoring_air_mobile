import 'package:material_ui/material_ui.dart';
import '../core/constants/app_colors.dart';
import 'settings_bottom_sheet.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  const AppBarHeader({
    super.key,
    this.title = 'AquaMonitor',
    this.subtitle = 'Water Treatment System',
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navyBlue,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(
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
