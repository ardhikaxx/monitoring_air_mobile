import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../screens/sensor_detail_screen.dart';

class WaterTreatmentDiagram extends StatelessWidget {
  final List<SensorModel> sensors;

  const WaterTreatmentDiagram({
    super.key,
    required this.sensors,
  });

  SensorModel? _findSensor(SensorType type) {
    try {
      return sensors.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final turbIn = _findSensor(SensorType.turbidityInlet);
    final phIn = _findSensor(SensorType.phInlet);
    final flowIn = _findSensor(SensorType.flowRateInlet);
    final tempIn = _findSensor(SensorType.temperatureInlet);

    final turbOut = _findSensor(SensorType.turbidityOutlet);
    final phOut = _findSensor(SensorType.phOutlet);
    final tempOut = _findSensor(SensorType.temperatureOutlet);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.techBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.schema_rounded,
                    color: AppColors.techBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alur Pengolahan & Titik Sensor',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.navyBlue,
                        ),
                      ),
                      const Text(
                        'Geser horizontal • Tekan titik sensor untuk melihat detail',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Process Flow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Sumber Air Sungai
                _buildStageCard(
                  icon: Icons.waves_rounded,
                  title: 'Air Sungai',
                  subtitle: 'Sumber Baku Alami',
                  stageColor: AppColors.rawWater,
                  isDark: isDark,
                  stepNumber: '1',
                ),
                _buildFlowArrow(),

                // 2. Tangki Air Baku
                _buildStageCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Tangki Baku',
                  subtitle: 'Reservoir Inlet',
                  stageColor: const Color(0xFF8D6E63),
                  isDark: isDark,
                  stepNumber: '2',
                ),
                _buildFlowArrow(),

                // 3. SENSOR CLUSTER INLET
                _buildSensorClusterCard(
                  context,
                  title: 'TITIK SENSOR INLET',
                  subtitle: '4 Sensor Terpasang',
                  accentColor: AppColors.rawWater,
                  isDark: isDark,
                  sensors: [turbIn, phIn, flowIn, tempIn],
                ),
                _buildFlowArrow(),

                // 4. Bak Pengendapan
                _buildStageCard(
                  icon: Icons.layers_outlined,
                  title: 'Pengendapan',
                  subtitle: 'Sedimentasi Fisik',
                  stageColor: const Color(0xFFB08968),
                  isDark: isDark,
                  stepNumber: '3',
                ),
                _buildFlowArrow(),

                // 5. Filter Kerikil
                _buildStageCard(
                  icon: Icons.grain_rounded,
                  title: 'Filter Kerikil',
                  subtitle: 'Partikel Kasar',
                  stageColor: const Color(0xFF78909C),
                  isDark: isDark,
                  stepNumber: '4',
                ),
                _buildFlowArrow(),

                // 6. Filter Pasir Silika
                _buildStageCard(
                  icon: Icons.blur_on_rounded,
                  title: 'Pasir Silika',
                  subtitle: 'Sedimen Halus',
                  stageColor: const Color(0xFFFBBF24),
                  isDark: isDark,
                  stepNumber: '5',
                ),
                _buildFlowArrow(),

                // 7. Filter Zeolit
                _buildStageCard(
                  icon: Icons.diamond_outlined,
                  title: 'Filter Zeolit',
                  subtitle: 'Adsorpsi Logam & Bau',
                  stageColor: const Color(0xFF2DD4BF),
                  isDark: isDark,
                  stepNumber: '6',
                ),
                _buildFlowArrow(),

                // 8. Filter Karbon Aktif
                _buildStageCard(
                  icon: Icons.filter_b_and_w_rounded,
                  title: 'Karbon Aktif',
                  subtitle: 'Organik & Kejernihan',
                  stageColor: const Color(0xFF475569),
                  isDark: isDark,
                  stepNumber: '7',
                ),
                _buildFlowArrow(),

                // 9. Disinfeksi UV
                _buildStageCard(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Disinfeksi UV',
                  subtitle: 'Sterilisasi Mikroba',
                  stageColor: AppColors.uvPurple,
                  isDark: isDark,
                  stepNumber: '8',
                ),
                _buildFlowArrow(),

                // 10. SENSOR CLUSTER OUTLET
                _buildSensorClusterCard(
                  context,
                  title: 'TITIK SENSOR OUTLET',
                  subtitle: '3 Sensor Evaluasi',
                  accentColor: AppColors.techBlue,
                  isDark: isDark,
                  sensors: [turbOut, phOut, tempOut],
                ),
                _buildFlowArrow(),

                // 11. Tangki Air Hasil
                _buildStageCard(
                  icon: Icons.water_drop_rounded,
                  title: 'Air Bersih',
                  subtitle: 'Tangki Hasil Olahan',
                  stageColor: AppColors.cleanWater,
                  isDark: isDark,
                  stepNumber: '9',
                ),
              ],
            ),
          ),

          // Flow Direction Footer Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.3)
                  : AppColors.lightTechBlue.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.techBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kapasitas filter multimedia: 20 L/jam • Aliran gravitasi bertekanan terpadu',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color stageColor,
    required bool isDark,
    required String stepNumber,
  }) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stageColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$stepNumber',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: stageColor,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: stageColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorClusterCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color accentColor,
    required bool isDark,
    required List<SensorModel?> sensors,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.sensors_rounded, size: 15, color: accentColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sensors.whereType<SensorModel>().map((sensor) {
              return _buildSensorChip(context, sensor, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorChip(BuildContext context, SensorModel sensor, bool isDark) {
    Color statusColor;
    switch (sensor.status) {
      case SensorStatus.normal:
        statusColor = AppColors.statusNormal;
        break;
      case SensorStatus.warning:
        statusColor = AppColors.statusWarning;
        break;
      case SensorStatus.critical:
        statusColor = AppColors.statusCritical;
        break;
      case SensorStatus.offline:
        statusColor = AppColors.statusOffline;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SensorDetailScreen(sensorId: sensor.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.12),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '${sensor.type.displayName.split(' ')[0]}: ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            Text(
              '${sensor.currentValue} ${sensor.unit}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 2,
            color: AppColors.techBlue.withValues(alpha: 0.5),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.techBlue,
          ),
        ],
      ),
    );
  }
}
