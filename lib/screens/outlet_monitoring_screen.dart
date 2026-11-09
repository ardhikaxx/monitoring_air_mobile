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
    final quality = provider.waterQualityComparison;

    final turbInletVal = provider.getSensorById('SEN-IN-TURB')?.currentValue ?? 85.0;
    final phInletVal = provider.getSensorById('SEN-IN-PH')?.currentValue ?? 6.3;
    final tempInletVal = provider.getSensorById('SEN-IN-TEMP')?.currentValue ?? 27.0;

    final turbOutVal = provider.getSensorById('SEN-IN-OUT-TURB')?.currentValue ?? 3.0;
    final phOutVal = provider.getSensorById('SEN-IN-OUT-PH')?.currentValue ?? 7.0;
    final tempOutVal = provider.getSensorById('SEN-IN-OUT-TEMP')?.currentValue ?? 28.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBarHeader(
        title: 'Outlet Monitoring',
        subtitle: 'Kualitas Air Hasil Filtrasi',
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
                            color: AppColors.techBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.output_rounded,
                            color: AppColors.techBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jalur Outlet (Air Hasil Filtrasi)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyBlue,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Hasil penyaringan multimedia & disinfeksi UV',
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
                            color: AppColors.statusNormalBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.statusNormalBorder),
                          ),
                          child: Text(
                            '${quality.turbidityReductionPercent.toStringAsFixed(1)}% Reduksi',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusNormal,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Quick Glance 3-Metric Grid
                    Row(
                      children: [
                        _buildQuickMetric('Kekeruhan Outlet', '${turbOutVal.toStringAsFixed(1)} NTU', AppColors.techBlue),
                        _buildDivider(),
                        _buildQuickMetric('pH Air Olahan', '${phOutVal.toStringAsFixed(2)} pH', AppColors.statusNormal),
                        _buildDivider(),
                        _buildQuickMetric('Suhu Air Olahan', '${tempOutVal.toStringAsFixed(1)}°C', const Color(0xFFF97316)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3 Detailed Outlet Sensor Cards
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
                  padding: const EdgeInsets.only(bottom: 12.0),
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
              fontSize: 12,
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
