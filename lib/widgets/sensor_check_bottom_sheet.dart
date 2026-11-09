import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../providers/sensor_simulation_provider.dart';

class SensorCheckBottomSheet extends StatefulWidget {
  final SensorModel sensor;

  const SensorCheckBottomSheet({
    super.key,
    required this.sensor,
  });

  static void show(BuildContext context, SensorModel sensor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SensorCheckBottomSheet(sensor: sensor),
    );
  }

  @override
  State<SensorCheckBottomSheet> createState() => _SensorCheckBottomSheetState();
}

class _SensorCheckBottomSheetState extends State<SensorCheckBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  bool _isChecking = true;
  String _currentStep = 'Memeriksa jalur koneksi mikrokontroler...';
  double _progress = 0.2;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _runDiagnosticSteps();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _runDiagnosticSteps() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _currentStep = 'Membaca sinyal respons & handshake ADC...';
      _progress = 0.55;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _currentStep = 'Memvalidasi integritas data & filtering noise...';
      _progress = 0.85;
    });

    final provider = context.read<SensorSimulationProvider>();
    final res = await provider.checkSensor(widget.sensor.id);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _progress = 1.0;
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: const Icon(Icons.radar_rounded, color: AppColors.techBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pemeriksaan Diagnostik Sensor',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    Text(
                      widget.sensor.name,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (_isChecking) ...[
            // Animated Scanning Radar Container
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 70 + (40 * _scanAnimation.value),
                        height: 70 + (40 * _scanAnimation.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.techBlue.withValues(
                              alpha: 0.6 * (1.0 - _scanAnimation.value),
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.techBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sensors_rounded, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: Colors.black12,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.techBlue),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _currentStep,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ] else if (_result != null) ...[
            // Result Information Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _result!['result'] == 'Passed'
                      ? AppColors.statusNormalBorder
                      : AppColors.statusCriticalBorder,
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hasil Pengecekan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _result!['result'] == 'Passed'
                              ? AppColors.statusNormalBg
                              : AppColors.statusCriticalBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _result!['result'] == 'Passed'
                                ? AppColors.statusNormalBorder
                                : AppColors.statusCriticalBorder,
                          ),
                        ),
                        child: Text(
                          _result!['result'] == 'Passed' ? 'Passed' : 'Failed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _result!['result'] == 'Passed'
                                ? AppColors.statusNormal
                                : AppColors.statusCritical,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 14),
                  _buildResultRow('Status Sambungan', _result!['status']),
                  const SizedBox(height: 5),
                  _buildResultRow('Respon Latensi', _result!['latency']),
                  const SizedBox(height: 5),
                  _buildResultRow('Tegangan Catu ADC', _result!['voltage']),
                  const SizedBox(height: 5),
                  _buildResultRow('Nilai Terbaca', _result!['currentValue']),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _result!['notes'] ?? '',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup Hasil Pemeriksaan'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
        ),
      ],
    );
  }
}
