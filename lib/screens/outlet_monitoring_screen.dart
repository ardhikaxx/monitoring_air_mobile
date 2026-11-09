import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../providers/sensor_provider.dart';
import '../widgets/pipe_diagram_widgets.dart';
import '../widgets/sensor_monitoring_card.dart';
import '../widgets/water_quality_comparison_card.dart';

class OutletMonitoringScreen extends StatelessWidget {
  const OutletMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outletSensors = provider.outletSensors;

    final turbInletVal = provider.getSensorById('SEN-IN-TURB')?.currentValue ?? 85.0;
    final phInletVal = provider.getSensorById('SEN-IN-PH')?.currentValue ?? 6.3;
    final tempInletVal = provider.getSensorById('SEN-IN-TEMP')?.currentValue ?? 27.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outlet Monitoring'),
        backgroundColor: AppColors.navyBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header Description
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.techBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop_rounded, color: AppColors.techBlue, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring Jalur Air Bersih (Outlet)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Mengevaluasi hasil penjernihan air pasca filtrasi multimedia bertingkat dan sterilisasi ultraviolet sebelum dialirkan ke tangki bersih.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 1. Interactive Pipe Diagram
          OutletPipeDiagram(outletSensors: outletSensors),

          const SizedBox(height: 16),

          // 2. Comparison Summary Card
          WaterQualityComparisonCard(comparison: provider.waterQualityComparison),

          const SizedBox(height: 16),

          // Title for 3 Full Cards
          Text(
            'Kartu Pembacaan Sensor Outlet (3 Sensor)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 10),

          // 3. Three Complete Sensor Monitoring Cards
          ...outletSensors.map((sensor) {
            double? compVal;
            if (sensor.type == SensorType.turbidityOutlet) {
              compVal = turbInletVal;
            } else if (sensor.type == SensorType.phOutlet) {
              compVal = phInletVal;
            } else if (sensor.type == SensorType.temperatureOutlet) {
              compVal = tempInletVal;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SensorMonitoringCard(
                sensor: sensor,
                inletComparisonValue: compVal,
              ),
            );
          }),
        ],
        ),
      ),
    );
  }
}
