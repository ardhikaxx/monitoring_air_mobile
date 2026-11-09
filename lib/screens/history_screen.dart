import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_reading_model.dart';
import '../providers/sensor_provider.dart';
import '../widgets/history_chart.dart';
import '../widgets/sensor_status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedSensorId = 'SEN-IN-TURB';
  String _selectedRange = '24 Jam';
  final List<String> _ranges = ['1 Jam', '6 Jam', '12 Jam', '24 Jam', '7 Hari', '30 Hari'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showExportCsvModal(BuildContext context, String csvData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExportCsvBottomSheet(csvData: csvData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentSensor = provider.getSensorById(_selectedSensorId) ?? provider.sensors.first;

    // Filter by timeframe
    List<SensorReadingModel> readings = currentSensor.readings;
    if (_selectedRange == '1 Jam') {
      readings = currentSensor.readings.take(4).toList();
    } else if (_selectedRange == '6 Jam') {
      readings = currentSensor.readings.take(8).toList();
    } else if (_selectedRange == '12 Jam') {
      readings = currentSensor.readings.take(14).toList();
    }

    // Filter table by search query
    final tableReadings = readings.where((r) {
      if (_searchQuery.isEmpty) return true;
      final valStr = r.value.toString();
      final timeStr = DateFormatter.formatFull(r.timestamp).toLowerCase();
      final q = _searchQuery.toLowerCase();
      return valStr.contains(q) || timeStr.contains(q) || r.status.label.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori & Grafik Sensor'),
        backgroundColor: AppColors.navyBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            tooltip: 'Export CSV',
            onPressed: () {
              final csv = provider.exportCsvData();
              _showExportCsvModal(context, csv);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 1. Sensor Selector Dropdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Parameter Sensor:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: currentSensor.id,
                      items: provider.sensors.map((s) {
                        return DropdownMenuItem<String>(
                          value: s.id,
                          child: Text('${s.name} (${s.unit})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSensorId = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Time Range Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ranges.map((range) {
                final isSelected = _selectedRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      range,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.techBlue,
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedRange = range);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // 3. Interactive History Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSensor.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.navyBlue),
                        ),
                        Text(
                          'Rentang Waktu: $_selectedRange • Satuan: ${currentSensor.unit}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    SensorStatusBadge(status: currentSensor.status, compact: true),
                  ],
                ),
                const SizedBox(height: 16),
                HistoryChart(
                  readings: readings,
                  unit: currentSensor.unit,
                  lineColor: AppColors.techBlue,
                  minThreshold: currentSensor.minThreshold,
                  maxThreshold: currentSensor.maxThreshold,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 4. Statistics Summary (Min, Max, Avg)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('Min', '${currentSensor.minValue.toStringAsFixed(1)} ${currentSensor.unit}', AppColors.techBlue),
                _buildStatPill('Rata-Rata', '${currentSensor.avgValue.toStringAsFixed(1)} ${currentSensor.unit}', AppColors.accentCyan),
                _buildStatPill('Maks', '${currentSensor.maxValue.toStringAsFixed(1)} ${currentSensor.unit}', AppColors.statusWarning),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Search & Readings Table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tabel Rekaman Data Pembacaan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('${tableReadings.length} Baris', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 10),
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nilai atau status...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
                const SizedBox(height: 12),

                if (tableReadings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Tidak ada rekaman yang sesuai.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tableReadings.length,
                    separatorBuilder: (context, index) => const Divider(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = tableReadings[i];
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormatter.formatFull(item.timestamp),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  currentSensor.name,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${item.value} ${currentSensor.unit}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SensorStatusBadge(status: item.status, compact: true),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _ExportCsvBottomSheet extends StatelessWidget {
  final String csvData;

  const _ExportCsvBottomSheet({required this.csvData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.table_chart_rounded, color: AppColors.techBlue, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Data Simulasi (CSV)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Format CSV standar untuk spreadsheet / analisis eksternal', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                csvData,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: csvData));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data CSV disalin ke clipboard.')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Salin CSV'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File CSV siap diunduh.')),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
