import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/sensor_simulation_provider.dart';
import '../widgets/app_bar_header.dart';
import '../widgets/sensor_monitoring_card.dart';

class InletMonitoringScreen extends StatelessWidget {
  const InletMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();
    final inletSensors = provider.inletSensors;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHeader(
        title: 'Inlet Monitoring',
        subtitle: 'Sensor Kualitas Air Baku',
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
                        Icons.input_rounded,
                        color: AppColors.navyBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jalur Inlet (Air Sungai Masuk)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            '4 Sensor Aktif Memantau Parameter Air Baku',
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

              const SizedBox(height: 14),

              // 4 Inlet Sensor Cards
              ...inletSensors.map(
                (sensor) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SensorMonitoringCard(sensor: sensor),
                ),
              ),

              // Bottom padding for Floating Pill Bottom Nav
              const SizedBox(height: 85),
            ],
          ),
        ),
      ),
    );
  }
}
