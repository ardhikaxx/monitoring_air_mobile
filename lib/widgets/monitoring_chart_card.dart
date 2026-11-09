import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../providers/sensor_simulation_provider.dart';

enum ChartParameter {
  turbidity,
  ph,
  temperature,
  flowRate;

  String get label {
    switch (this) {
      case ChartParameter.turbidity:
        return 'Kekeruhan (NTU)';
      case ChartParameter.ph:
        return 'Derajat pH';
      case ChartParameter.temperature:
        return 'Suhu (°C)';
      case ChartParameter.flowRate:
        return 'Flow Rate (L/j)';
    }
  }
}

class MonitoringChartCard extends StatefulWidget {
  const MonitoringChartCard({super.key});

  @override
  State<MonitoringChartCard> createState() => _MonitoringChartCardState();
}

class _MonitoringChartCardState extends State<MonitoringChartCard> {
  ChartParameter _selectedParameter = ChartParameter.turbidity;
  String _selectedRange = '24 Jam';
  final List<String> _ranges = ['1 Jam', '6 Jam', '24 Jam'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorSimulationProvider>();

    SensorModel? inletSensor;
    SensorModel? outletSensor;

    switch (_selectedParameter) {
      case ChartParameter.turbidity:
        inletSensor = provider.getSensorById('SEN-IN-TURB');
        outletSensor = provider.getSensorById('SEN-IN-OUT-TURB');
        break;
      case ChartParameter.ph:
        inletSensor = provider.getSensorById('SEN-IN-PH');
        outletSensor = provider.getSensorById('SEN-IN-OUT-PH');
        break;
      case ChartParameter.temperature:
        inletSensor = provider.getSensorById('SEN-IN-TEMP');
        outletSensor = provider.getSensorById('SEN-IN-OUT-TEMP');
        break;
      case ChartParameter.flowRate:
        inletSensor = provider.getSensorById('SEN-IN-FLOW');
        outletSensor = null;
        break;
    }

    List<SensorReadingModel> inReadings = inletSensor?.readings ?? [];
    List<SensorReadingModel> outReadings = outletSensor?.readings ?? [];

    if (_selectedRange == '1 Jam') {
      inReadings = inReadings.take(4).toList();
      outReadings = outReadings.take(4).toList();
    } else if (_selectedRange == '6 Jam') {
      inReadings = inReadings.take(8).toList();
      outReadings = outReadings.take(8).toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.techBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.show_chart_rounded, color: AppColors.techBlue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Grafik Monitoring Sensor',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ],
              ),
              // Current Reading Info Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  outletSensor != null
                      ? 'In: ${inletSensor?.currentValue} • Out: ${outletSensor.currentValue}'
                      : 'In: ${inletSensor?.currentValue} ${inletSensor?.unit}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Parameter Selection Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ChartParameter.values.map((param) {
                final isSelected = _selectedParameter == param;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(param.label),
                    selected: isSelected,
                    selectedColor: AppColors.techBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedParameter = param);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Time Range Filter Row & Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Legend
              Row(
                children: [
                  _buildLegendIndicator('Inlet (Air Baku)', AppColors.rawWater),
                  if (outletSensor != null) ...[
                    const SizedBox(width: 12),
                    _buildLegendIndicator('Outlet (Air Olahan)', AppColors.techBlue),
                  ],
                ],
              ),
              // Time Filter Chips
              Row(
                children: _ranges.map((rng) {
                  final isSel = _selectedRange == rng;
                  return InkWell(
                    onTap: () => setState(() => _selectedRange = rng),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.navyBlue : AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        rng,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // The Interactive Line Chart
          SizedBox(
            height: 180,
            child: _buildChart(inReadings, outReadings, inletSensor?.unit ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildChart(
    List<SensorReadingModel> inReadings,
    List<SensorReadingModel> outReadings,
    String unit,
  ) {
    if (inReadings.isEmpty) {
      return const Center(child: Text('Data grafik tidak cukup.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)));
    }

    final inSpots = <FlSpot>[];
    for (int i = 0; i < inReadings.length; i++) {
      inSpots.add(FlSpot(i.toDouble(), inReadings[i].value));
    }

    final outSpots = <FlSpot>[];
    for (int i = 0; i < outReadings.length; i++) {
      outSpots.add(FlSpot(i.toDouble(), outReadings[i].value));
    }

    final allValues = [...inSpots.map((s) => s.y), ...outSpots.map((s) => s.y)];
    final minY = (allValues.reduce((a, b) => a < b ? a : b) * 0.85).clamp(0.0, double.infinity);
    final maxY = allValues.reduce((a, b) => a > b ? a : b) * 1.15;

    final lineBars = <LineChartBarData>[
      // Inlet line
      LineChartBarData(
        spots: inSpots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: AppColors.rawWater,
        barWidth: 2.2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.rawWater.withValues(alpha: 0.08),
        ),
      ),
      // Outlet line
      if (outSpots.isNotEmpty)
        LineChartBarData(
          spots: outSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.techBlue,
          barWidth: 2.2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.techBlue.withValues(alpha: 0.08),
          ),
        ),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.black.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (inReadings.length / 3).clamp(1.0, 15.0),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < inReadings.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      DateFormatter.formatChartTime(inReadings[idx].timestamp),
                      style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.black12, width: 1),
            left: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        minX: 0,
        maxX: (inReadings.length - 1).toDouble(),
        minY: minY,
        maxY: maxY == minY ? minY + 2 : maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isOutlet = spot.barIndex == 1;
                return LineTooltipItem(
                  '${isOutlet ? "Outlet: " : "Inlet: "}${spot.y.toStringAsFixed(1)} $unit',
                  TextStyle(
                    color: isOutlet ? Colors.lightBlueAccent : Colors.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: lineBars,
      ),
    );
  }
}
