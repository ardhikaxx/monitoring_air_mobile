import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/sensor_simulation_provider.dart';
import '../services/storage_service.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key});

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _turbidityThresholdCtrl;
  late TextEditingController _phMinCtrl;
  late TextEditingController _phMaxCtrl;
  late TextEditingController _flowMinCtrl;
  late TextEditingController _flowMaxCtrl;
  late TextEditingController _tempMinCtrl;
  late TextEditingController _tempMaxCtrl;

  int _selectedInterval = 4;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = context.read<SensorSimulationProvider>();
      _selectedInterval = provider.updateInterval;

      final turbOutlet = provider.getSensorById('SEN-IN-OUT-TURB');
      final phOutlet = provider.getSensorById('SEN-IN-OUT-PH');
      final flow = provider.getSensorById('SEN-IN-FLOW');
      final temp = provider.getSensorById('SEN-IN-OUT-TEMP');

      _turbidityThresholdCtrl = TextEditingController(text: (turbOutlet?.maxThreshold ?? 5.0).toString());
      _phMinCtrl = TextEditingController(text: (phOutlet?.minThreshold ?? 6.5).toString());
      _phMaxCtrl = TextEditingController(text: (phOutlet?.maxThreshold ?? 8.5).toString());
      _flowMinCtrl = TextEditingController(text: (flow?.minThreshold ?? 15.0).toString());
      _flowMaxCtrl = TextEditingController(text: (flow?.maxThreshold ?? 25.0).toString());
      _tempMinCtrl = TextEditingController(text: (temp?.minThreshold ?? 20.0).toString());
      _tempMaxCtrl = TextEditingController(text: (temp?.maxThreshold ?? 32.0).toString());

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _turbidityThresholdCtrl.dispose();
    _phMinCtrl.dispose();
    _phMaxCtrl.dispose();
    _flowMinCtrl.dispose();
    _flowMaxCtrl.dispose();
    _tempMinCtrl.dispose();
    _tempMaxCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<SensorSimulationProvider>();

      provider.setUpdateInterval(_selectedInterval);

      final turbMax = double.parse(_turbidityThresholdCtrl.text.trim());
      final phMin = double.parse(_phMinCtrl.text.trim());
      final phMax = double.parse(_phMaxCtrl.text.trim());
      final flowMin = double.parse(_flowMinCtrl.text.trim());
      final flowMax = double.parse(_flowMaxCtrl.text.trim());
      final tempMin = double.parse(_tempMinCtrl.text.trim());
      final tempMax = double.parse(_tempMaxCtrl.text.trim());

      provider.updateSensorThreshold('SEN-IN-OUT-TURB', 0.0, turbMax);
      provider.updateSensorThreshold('SEN-IN-OUT-PH', phMin, phMax);
      provider.updateSensorThreshold('SEN-IN-PH', phMin, phMax);
      provider.updateSensorThreshold('SEN-IN-FLOW', flowMin, flowMax);
      provider.updateSensorThreshold('SEN-IN-OUT-TEMP', tempMin, tempMax);
      provider.updateSensorThreshold('SEN-IN-TEMP', tempMin, tempMax);

      StorageService.saveThresholds(
        turbidityOutlet: turbMax,
        phMin: phMin,
        phMax: phMax,
        flowMin: flowMin,
        flowMax: flowMax,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan ambang batas & interval telemetri berhasil disimpan.'),
          backgroundColor: AppColors.statusNormal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetToDefault() {
    setState(() {
      _selectedInterval = 4;
      _turbidityThresholdCtrl.text = '5.0';
      _phMinCtrl.text = '6.5';
      _phMaxCtrl.text = '8.5';
      _flowMinCtrl.text = '15.0';
      _flowMaxCtrl.text = '25.0';
      _tempMinCtrl.text = '20.0';
      _tempMaxCtrl.text = '32.0';
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 14),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.techBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.techBlue, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Simulasi & Ambang Batas',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      Text(
                        'Konfigurasi interval telemetri & batas parameter sensor',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interval Selection
                    const Text(
                      'Interval Pembaruan Telemetri Sensor:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [3, 5, 10].map((sec) {
                        final isSel = _selectedInterval == sec;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text('$sec Detik'),
                            selected: isSel,
                            selectedColor: AppColors.techBlue,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedInterval = sec);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Konfigurasi Ambang Batas Parameter (Threshold):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Nilai di luar rentang akan memicu status Warning atau Critical pada dashboard.',
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),

                    // Kekeruhan
                    _buildField(
                      controller: _turbidityThresholdCtrl,
                      label: 'Maksimal Kekeruhan Outlet (NTU)',
                      suffix: 'NTU',
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0 || n > 200) return '0 - 200';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // pH
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _phMinCtrl,
                            label: 'Min pH Ideal',
                            suffix: 'pH',
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n < 0 || n > 14) return '0 - 14';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildField(
                            controller: _phMaxCtrl,
                            label: 'Maks pH Ideal',
                            suffix: 'pH',
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n < 0 || n > 14) return '0 - 14';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Flow Rate
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _flowMinCtrl,
                            label: 'Min Flow Rate',
                            suffix: 'L/jam',
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n < 0) return 'Nilai valid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildField(
                            controller: _flowMaxCtrl,
                            label: 'Maks Flow Rate',
                            suffix: 'L/jam',
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n <= 0) return 'Nilai valid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Temp
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _tempMinCtrl,
                            label: 'Min Suhu',
                            suffix: '°C',
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n < 0 || n > 60) return '0 - 60';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildField(
                            controller: _tempMaxCtrl,
                            label: 'Maks Suhu',
                            suffix: '°C',
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n < 0 || n > 60) return '0 - 60';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefault,
                    child: const Text('Reset Default', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Simpan Pengaturan', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        suffixText: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
