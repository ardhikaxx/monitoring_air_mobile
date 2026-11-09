import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/sensor_provider.dart';
import '../widgets/pipe_diagram_widgets.dart';
import '../widgets/sensor_monitoring_card.dart';

class InletMonitoringScreen extends StatelessWidget {
  const InletMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inletSensors = provider.inletSensors;

    final turb = provider.getSensorById('SEN-IN-TURB');
    final ph = provider.getSensorById('SEN-IN-PH');
    final flow = provider.getSensorById('SEN-IN-FLOW');
    final temp = provider.getSensorById('SEN-IN-TEMP');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inlet Monitoring'),
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
                    color: AppColors.rawWater.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_rounded, color: AppColors.rawWater, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring Jalur Air Baku (Inlet)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Memantau kondisi fisik, kimiawi, dan hidrolik air sungai sebelum melalui proses sedimentasi dan filtrasi multimedia.',
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
          InletPipeDiagram(inletSensors: inletSensors),

          const SizedBox(height: 16),

          // 2. Inlet Water Condition Analysis Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assessment_outlined, size: 18, color: AppColors.techBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Kondisi Karakteristik Air Baku',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.navyBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 12),

                _buildConditionItem(
                  'Tingkat Kekeruhan (NTU)',
                  '${turb?.currentValue ?? 85.0} NTU',
                  'Kekeruhan alami air permukaan sungai akibat partikel suspensi lumpur dan debu batuan.',
                  AppColors.rawWater,
                ),
                const SizedBox(height: 10),
                _buildConditionItem(
                  'Derajat Keasaman (pH)',
                  '${ph?.currentValue ?? 6.3} pH',
                  'pH cenderung sedikit asam (dibawah 6.5 netral), memerlukan penyetaraan media mineral filter.',
                  AppColors.statusWarning,
                ),
                const SizedBox(height: 10),
                _buildConditionItem(
                  'Debit Aliran Masuk (Flow Rate)',
                  '${flow?.currentValue ?? 20.0} L/jam',
                  'Debit hisap pompa stabil pada kapasitas operasional tabung multimedia 20 L/jam.',
                  AppColors.accentCyan,
                ),
                const SizedBox(height: 10),
                _buildConditionItem(
                  'Temperatur Air (°C)',
                  '${temp?.currentValue ?? 27.0} °C',
                  'Suhu air lingkungan normal tropis, aman bagi kelangsungan reaksi adsorpsi zeolit dan karbon aktif.',
                  const Color(0xFFF97316),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Title for 4 Full Cards
          Text(
            'Kartu Pembacaan Sensor Inlet (4 Sensor)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 10),

          // 3. Four Complete Sensor Monitoring Cards
          ...inletSensors.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SensorMonitoringCard(sensor: s),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(String title, String val, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
