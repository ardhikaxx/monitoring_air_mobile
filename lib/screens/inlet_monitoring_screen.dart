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

    final turb = provider.getSensorById('SEN-IN-TURB')?.currentValue ?? 85.0;
    final ph = provider.getSensorById('SEN-IN-PH')?.currentValue ?? 6.3;
    final flow = provider.getSensorById('SEN-IN-FLOW')?.currentValue ?? 20.0;
    final temp = provider.getSensorById('SEN-IN-TEMP')?.currentValue ?? 27.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHeader(
        title: 'Inlet Monitoring',
        subtitle: 'Kualitas Air Baku Sungai',
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
              // Summary Header Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.rawWater.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.input_rounded,
                            color: AppColors.rawWater,
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
                                'Air baku sungai sebelum proses filtrasi multimedia',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Text(
                            '4 Sensor',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Quick Glance 4-Metric Grid
                    Row(
                      children: [
                        _buildQuickMetric('Kekeruhan', '${turb.toStringAsFixed(1)} NTU', AppColors.rawWater),
                        _buildDivider(),
                        _buildQuickMetric('Derajat pH', '${ph.toStringAsFixed(2)} pH', AppColors.techBlue),
                        _buildDivider(),
                        _buildQuickMetric('Debit Air', '${flow.toStringAsFixed(0)} L/j', AppColors.navyBlue),
                        _buildDivider(),
                        _buildQuickMetric('Suhu Air', '${temp.toStringAsFixed(1)}°C', const Color(0xFFF97316)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4 Detailed Inlet Sensor Cards
              ...inletSensors.map(
                (sensor) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.borderLight,
    );
  }

  Widget _buildQuickMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
