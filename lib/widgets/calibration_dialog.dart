import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../providers/sensor_provider.dart';

class CalibrationDialog extends StatefulWidget {
  final SensorModel sensor;

  const CalibrationDialog({
    super.key,
    required this.sensor,
  });

  @override
  State<CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends State<CalibrationDialog> {
  late TextEditingController _referenceController;
  bool _isCalibrating = false;
  Map<String, dynamic>? _calibrationResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default reference standard suggestion
    double defaultRef = widget.sensor.currentValue;
    if (widget.sensor.type == SensorType.phInlet || widget.sensor.type == SensorType.phOutlet) {
      defaultRef = 7.00; // standard neutral buffer
    } else if (widget.sensor.type == SensorType.turbidityOutlet) {
      defaultRef = 0.00; // pure distilled standard
    } else if (widget.sensor.type == SensorType.turbidityInlet) {
      defaultRef = 80.0;
    } else if (widget.sensor.type == SensorType.flowRateInlet) {
      defaultRef = 20.0;
    } else if (widget.sensor.type == SensorType.temperatureInlet ||
        widget.sensor.type == SensorType.temperatureOutlet) {
      defaultRef = 25.0; // room standard
    }

    _referenceController = TextEditingController(text: defaultRef.toString());
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submitCalibration() async {
    final val = double.tryParse(_referenceController.text.trim());
    if (val == null) {
      setState(() => _errorMessage = 'Masukkan angka referensi yang valid');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isCalibrating = true;
    });

    final provider = context.read<SensorProvider>();
    final res = await provider.calibrateSensor(widget.sensor.id, val);

    if (mounted) {
      setState(() {
        _isCalibrating = false;
        _calibrationResult = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.techBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.techBlue, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Simulasi Kalibrasi Sensor',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),

            if (_isCalibrating) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 14),
                      Text(
                        'Menyesuaikan offset ADC & kurva kompensasi...',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_calibrationResult != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusNormalBorder),
                ),
                child: Column(
                  children: [
                    _buildRow('Nilai Sebelum Kalibrasi', '${_calibrationResult!['preValue']} ${widget.sensor.unit}'),
                    const Divider(height: 14),
                    _buildRow('Standar Referensi', '${_calibrationResult!['referenceStandard']} ${widget.sensor.unit}'),
                    const Divider(height: 14),
                    _buildRow('Offset Kompensasi', '${_calibrationResult!['offset']}'),
                    const Divider(height: 14),
                    _buildRow(
                      'Nilai Setelah Kalibrasi',
                      '${_calibrationResult!['postValue']} ${widget.sensor.unit}',
                      color: AppColors.statusNormal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _calibrationResult!['message'],
                style: const TextStyle(fontSize: 11, color: AppColors.statusNormal, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Selesai'),
                ),
              ),
            ] else ...[
              // Current Reading Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pembacaan Saat Ini:', style: TextStyle(fontSize: 12)),
                    Text(
                      '${widget.sensor.currentValue} ${widget.sensor.unit}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Nilai Standar Referensi (Buffer Larutan/Standar):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _referenceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  suffixText: widget.sensor.unit,
                  hintText: 'Contoh: 7.00',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  errorText: _errorMessage,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Catatan: Ini adalah simulasi kompensasi offset software di sisi antarmuka, bukan kalibrasi fisik sensor.',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitCalibration,
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
