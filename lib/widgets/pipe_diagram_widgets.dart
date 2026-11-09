import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../screens/sensor_detail_screen.dart';

class InletPipeDiagram extends StatelessWidget {
  final List<SensorModel> inletSensors;

  const InletPipeDiagram({
    super.key,
    required this.inletSensors,
  });

  SensorModel? _getSensor(SensorType type) {
    try {
      return inletSensors.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  void _showSensorSheet(BuildContext context, SensorModel sensor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSensorBottomSheet(ctx, sensor),
    );
  }

  Widget _buildSensorBottomSheet(BuildContext context, SensorModel sensor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.rawWater.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sensors_rounded, color: AppColors.rawWater, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      'Titik Pemasangan: ${sensor.location.label}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nilai Pembacaan Saat Ini:', style: TextStyle(fontSize: 13)),
                Text(
                  '${sensor.currentValue} ${sensor.unit}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SensorDetailScreen(sensorId: sensor.id)),
                );
              },
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Buka Detail Sensor Lengkap'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final turb = _getSensor(SensorType.turbidityInlet);
    final ph = _getSensor(SensorType.phInlet);
    final flow = _getSensor(SensorType.flowRateInlet);
    final temp = _getSensor(SensorType.temperatureInlet);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diagram Pipa Jalur Inlet',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rawWater.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Air Baku Sungai',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.rawWater,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pipe Custom Representation
          Stack(
            children: [
              // Main Pipe Tube
              Container(
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 45),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8D6E63), Color(0xFFA1887F), Color(0xFF6D4C41)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    8,
                    (index) => const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Probes attached to the pipe
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (turb != null) _buildProbeWidget(context, turb, isTop: true),
                  if (ph != null) _buildProbeWidget(context, ph, isTop: false),
                  if (flow != null) _buildProbeWidget(context, flow, isTop: true),
                  if (temp != null) _buildProbeWidget(context, temp, isTop: false),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Arah Aliran: Dari Tangki Penampung Sungai ➔ Menuju Unit Pengendapan',
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbeWidget(BuildContext context, SensorModel sensor, {required bool isTop}) {
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
      onTap: () => _showSensorSheet(context, sensor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTop) ...[
            _buildSensorChipBox(sensor, statusColor),
            Container(width: 3, height: 16, color: statusColor),
          ] else ...[
            const SizedBox(height: 58),
            Container(width: 3, height: 16, color: statusColor),
            _buildSensorChipBox(sensor, statusColor),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorChipBox(SensorModel sensor, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            sensor.name.replaceAll('Sensor ', '').replaceAll(' Inlet', ''),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
          ),
          Text(
            '${sensor.currentValue} ${sensor.unit}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor),
          ),
        ],
      ),
    );
  }
}

class OutletPipeDiagram extends StatelessWidget {
  final List<SensorModel> outletSensors;

  const OutletPipeDiagram({
    super.key,
    required this.outletSensors,
  });

  SensorModel? _getSensor(SensorType type) {
    try {
      return outletSensors.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  void _showSensorSheet(BuildContext context, SensorModel sensor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSensorBottomSheet(ctx, sensor),
    );
  }

  Widget _buildSensorBottomSheet(BuildContext context, SensorModel sensor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sensors_rounded, color: AppColors.techBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      'Titik Pemasangan: ${sensor.location.label}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nilai Pembacaan Saat Ini:', style: TextStyle(fontSize: 13)),
                Text(
                  '${sensor.currentValue} ${sensor.unit}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.techBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SensorDetailScreen(sensorId: sensor.id)),
                );
              },
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Buka Detail Sensor Lengkap'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final turb = _getSensor(SensorType.turbidityOutlet);
    final ph = _getSensor(SensorType.phOutlet);
    final temp = _getSensor(SensorType.temperatureOutlet);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diagram Pipa Jalur Outlet',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Pasca Disinfeksi UV',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.techBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clean Water Pipe
          Stack(
            children: [
              Container(
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 45),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFF0369A1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.techBlue.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    8,
                    (index) => const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // UV Chamber Marker on the left
              Positioned(
                left: 10,
                top: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.uvPurple,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('UV Active', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 50), // spacer for UV chamber
                  if (turb != null) _buildProbeWidget(context, turb, isTop: true),
                  if (ph != null) _buildProbeWidget(context, ph, isTop: false),
                  if (temp != null) _buildProbeWidget(context, temp, isTop: true),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Arah Aliran: Dari Disinfeksi UV ➔ Menuju Tangki Air Hasil',
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbeWidget(BuildContext context, SensorModel sensor, {required bool isTop}) {
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
      onTap: () => _showSensorSheet(context, sensor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTop) ...[
            _buildSensorChipBox(sensor, statusColor),
            Container(width: 3, height: 16, color: statusColor),
          ] else ...[
            const SizedBox(height: 58),
            Container(width: 3, height: 16, color: statusColor),
            _buildSensorChipBox(sensor, statusColor),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorChipBox(SensorModel sensor, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            sensor.name.replaceAll('Sensor ', '').replaceAll(' Outlet', ''),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
          ),
          Text(
            '${sensor.currentValue} ${sensor.unit}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor),
          ),
        ],
      ),
    );
  }
}
