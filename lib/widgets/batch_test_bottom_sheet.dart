import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/sensor_test_result_model.dart';
import '../providers/sensor_simulation_provider.dart';

class BatchTestBottomSheet extends StatefulWidget {
  const BatchTestBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => const BatchTestBottomSheet(),
    );
  }

  @override
  State<BatchTestBottomSheet> createState() => _BatchTestBottomSheetState();
}

class _BatchTestBottomSheetState extends State<BatchTestBottomSheet> {
  bool _isRunning = true;
  int _currentIndex = 0;
  String _currentSensorName = 'Menyiapkan uji diagnostik...';
  double _progress = 0.0;
  List<SensorTestResultModel> _results = [];
  DateTime? _completionTime;

  @override
  void initState() {
    super.initState();
    _startBatchTest();
  }

  Future<void> _startBatchTest() async {
    final provider = context.read<SensorSimulationProvider>();
    final res = await provider.testAllSensors((index, name, prog) {
      if (mounted) {
        setState(() {
          _currentIndex = index;
          _currentSensorName = name;
          _progress = prog;
        });
      }
    });

    if (mounted) {
      setState(() {
        _isRunning = false;
        _progress = 1.0;
        _results = res;
        _completionTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final passed = _results.where((r) => r.status == TestStatus.passed).length;
    final warning = _results.where((r) => r.status == TestStatus.warning).length;
    final failed = _results.where((r) => r.status == TestStatus.failed).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fact_check_rounded, color: AppColors.techBlue, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uji Diagnostik 7 Sensor Sekaligus',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      'Pemeriksaan berurutan jalur Inlet & Outlet',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (_isRunning) ...[
            Text(
              'Memeriksa sensor ${_currentIndex + 1} dari 7:',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              _currentSensorName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: Colors.black12,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.techBlue),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(_progress * 100).toInt()}% Selesai',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ] else ...[
            // Summary Cards
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTally('Passed', passed, AppColors.statusNormal),
                  _buildTally('Warning', warning, AppColors.statusWarning),
                  _buildTally('Failed', failed, AppColors.statusCritical),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_completionTime != null)
              Center(
                child: Text(
                  'Waktu Uji: ${DateFormatter.formatFull(_completionTime!)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
            const SizedBox(height: 14),

            const Text(
              'Hasil Evaluasi Ketujuh Sensor:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _results.length,
                separatorBuilder: (context, index) => const Divider(height: 10),
                itemBuilder: (ctx, i) {
                  final r = _results[i];
                  Color statusColor = r.status == TestStatus.passed
                      ? AppColors.statusNormal
                      : r.status == TestStatus.warning
                          ? AppColors.statusWarning
                          : AppColors.statusCritical;

                  return Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.sensorName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${r.readingValue} ${r.unit}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          r.status.label,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup Laporan Diagnostik'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTally(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
