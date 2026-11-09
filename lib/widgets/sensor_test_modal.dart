import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../models/sensor_test_result_model.dart';
import '../providers/sensor_provider.dart';

class SensorTestModal {
  // 1. Check Sensor Modal
  static void showCheckModal(BuildContext context, SensorModel sensor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CheckSensorBottomSheet(sensor: sensor),
    );
  }

  // 2. Full Test Sensor Modal
  static void showTestModal(BuildContext context, SensorModel sensor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TestSensorBottomSheet(sensor: sensor),
    );
  }

  // 3. Batch Test All 7 Sensors Modal
  static void showBatchTestModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _BatchTestDialog(),
    );
  }
}

class _CheckSensorBottomSheet extends StatefulWidget {
  final SensorModel sensor;

  const _CheckSensorBottomSheet({required this.sensor});

  @override
  State<_CheckSensorBottomSheet> createState() => _CheckSensorBottomSheetState();
}

class _CheckSensorBottomSheetState extends State<_CheckSensorBottomSheet> {
  bool _loading = true;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  Future<void> _runCheck() async {
    final provider = context.read<SensorProvider>();
    final res = await provider.checkSensor(widget.sensor.id);
    if (mounted) {
      setState(() {
        _loading = false;
        _result = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.techBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.radar_rounded, color: AppColors.techBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pemeriksaan Sambungan Sensor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.sensor.name,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_loading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Memindai sinyal ADC & protokol komunikasi...',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_result != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _result!['result'] == 'Passed'
                      ? AppColors.statusNormalBorder
                      : AppColors.statusCriticalBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildResultRow('Status Komunikasi', _result!['status'], isDark),
                  const Divider(height: 16),
                  _buildResultRow('Respon Latensi', _result!['latency'], isDark),
                  const Divider(height: 16),
                  _buildResultRow('Tegangan Sensor', _result!['voltage'], isDark),
                  const Divider(height: 16),
                  _buildResultRow('Nilai Terbaca', _result!['currentValue'], isDark),
                  const Divider(height: 16),
                  _buildResultRow(
                    'Hasil Pemeriksaan',
                    _result!['result'],
                    isDark,
                    color: _result!['result'] == 'Passed'
                        ? AppColors.statusNormal
                        : AppColors.statusCritical,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _result!['notes'],
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup Pemeriksaan'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isDark, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? (isDark ? Colors.white : AppColors.navyBlue),
          ),
        ),
      ],
    );
  }
}

class _TestSensorBottomSheet extends StatefulWidget {
  final SensorModel sensor;

  const _TestSensorBottomSheet({required this.sensor});

  @override
  State<_TestSensorBottomSheet> createState() => _TestSensorBottomSheetState();
}

class _TestSensorBottomSheetState extends State<_TestSensorBottomSheet> {
  bool _testing = true;
  double _progress = 0.0;
  String _currentStep = 'Memulai pengujian...';
  SensorTestResultModel? _testResult;

  @override
  void initState() {
    super.initState();
    _startDiagnostic();
  }

  Future<void> _startDiagnostic() async {
    final provider = context.read<SensorProvider>();
    try {
      final res = await provider.testSensor(
        widget.sensor.id,
        (step, progress) {
          if (mounted) {
            setState(() {
              _currentStep = step;
              _progress = progress;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _testing = false;
          _testResult = res;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _testing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.biotech_rounded, color: AppColors.accentCyan, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uji Diagnostik Mandiri Sensor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.sensor.name,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_testing) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.techBlue),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentStep,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.techBlue),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ] else if (_testResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _testResult!.status == TestStatus.passed
                      ? AppColors.statusNormalBorder
                      : _testResult!.status == TestStatus.warning
                          ? AppColors.statusWarningBorder
                          : AppColors.statusCriticalBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hasil Pengujian', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _testResult!.status == TestStatus.passed
                              ? AppColors.statusNormalBg
                              : _testResult!.status == TestStatus.warning
                                  ? AppColors.statusWarningBg
                                  : AppColors.statusCriticalBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _testResult!.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _testResult!.status == TestStatus.passed
                                ? AppColors.statusNormal
                                : _testResult!.status == TestStatus.warning
                                    ? AppColors.statusWarning
                                    : AppColors.statusCritical,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _buildResultRow('ID Uji', _testResult!.id, isDark),
                  const SizedBox(height: 6),
                  _buildResultRow('Latensi Sinyal', '${_testResult!.latencyMs} ms', isDark),
                  const SizedBox(height: 6),
                  _buildResultRow('Tegangan Bus', '${_testResult!.voltage.toStringAsFixed(2)} V', isDark),
                  const SizedBox(height: 6),
                  _buildResultRow('Nilai Validasi', '${_testResult!.readingValue} ${_testResult!.unit}', isDark),
                  const Divider(height: 16),
                  Text(
                    _testResult!.notes,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textPrimary)),
      ],
    );
  }
}

class _BatchTestDialog extends StatefulWidget {
  const _BatchTestDialog();

  @override
  State<_BatchTestDialog> createState() => _BatchTestDialogState();
}

class _BatchTestDialogState extends State<_BatchTestDialog> {
  bool _running = true;
  int _currentIndex = 0;
  String _currentSensorName = 'Memulai...';
  double _progress = 0.0;
  List<SensorTestResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _startBatch();
  }

  Future<void> _startBatch() async {
    final provider = context.read<SensorProvider>();
    final res = await provider.testAllSensors(
      (index, name, prog) {
        if (mounted) {
          setState(() {
            _currentIndex = index;
            _currentSensorName = name;
            _progress = prog;
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _running = false;
        _progress = 1.0;
        _results = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final passed = _results.where((r) => r.status == TestStatus.passed).length;
    final warning = _results.where((r) => r.status == TestStatus.warning).length;
    final failed = _results.where((r) => r.status == TestStatus.failed).length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.techBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fact_check_rounded, color: AppColors.techBlue, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Uji Diagnostik Semua Sensor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_running) ...[
              Text(
                'Memeriksa sensor ${_currentIndex + 1} dari 7:',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                _currentSensorName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.techBlue),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(_progress * 100).toInt()}% Selesai',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ] else ...[
              // Summary Result
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryBadge('Lolos', passed, AppColors.statusNormal),
                    _buildSummaryBadge('Warning', warning, AppColors.statusWarning),
                    _buildSummaryBadge('Gagal', failed, AppColors.statusCritical),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Daftar Hasil Uji Sensor (7 Total):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => const Divider(height: 8),
                  itemBuilder: (ctx, i) {
                    final r = _results[i];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            r.sensorName,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          r.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: r.status == TestStatus.passed
                                ? AppColors.statusNormal
                                : r.status == TestStatus.warning
                                    ? AppColors.statusWarning
                                    : AppColors.statusCritical,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup Laporan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
