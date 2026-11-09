import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../providers/sensor_simulation_provider.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/sensor_monitoring_card.dart';

class OutletMonitoringScreen extends StatelessWidget {
  const OutletMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();
    final outletSensors = provider.outletSensors;

    final turbInletVal = provider.getSensorById('SEN-IN-TURB')?.currentValue ?? 85.0;
    final phInletVal = provider.getSensorById('SEN-IN-PH')?.currentValue ?? 6.3;
    final tempInletVal = provider.getSensorById('SEN-IN-TEMP')?.currentValue ?? 27.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHeader(
        title: 'Outlet Monitoring',
        subtitle: 'Sensor Kualitas Air Hasil',
      ),
      body: RefreshIndicator(
        color: AppColors.techBlue,
        onRefresh: () async {
          await provider.refreshAllData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.output_rounded,
                        color: AppColors.techBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jalur Outlet (Air Hasil Filtrasi)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${provider.waterQualityComparison.turbidityReductionPercent.toStringAsFixed(1)}% Kekeruhan Terjernihkan',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusNormal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3 Outlet Sensor Cards
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
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SensorMonitoringCard(
                    sensor: sensor,
                    inletComparisonValue: compVal,
                  ),
                );
              }),

              // Bottom padding for Floating Pill Bottom Nav
              const SizedBox(height: 85),
            ],
          ),
        ),
      ),
    );
  }
}
