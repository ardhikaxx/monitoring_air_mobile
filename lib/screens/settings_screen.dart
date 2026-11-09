import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/sensor_provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
      final provider = context.read<SensorProvider>();
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
      final provider = context.read<SensorProvider>();

      // Update interval
      provider.setUpdateInterval(_selectedInterval);

      // Update thresholds
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan & ambang batas sensor berhasil disimpan.'),
          backgroundColor: AppColors.statusNormal,
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
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Sistem'),
        backgroundColor: AppColors.navyBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. System Info Card
              _buildSystemInfoCard(provider, isDark),

              const SizedBox(height: 16),

              // 2. Preferences: Theme & Update Interval
              _buildPreferencesCard(provider, isDark),

              const SizedBox(height: 16),

              // 3. Sensor Threshold Configurations
              _buildThresholdConfigCard(isDark),

              const SizedBox(height: 20),

              // 4. Action Buttons (Save & Reset)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetToDefault,
                      child: const Text('Kembalikan ke Default'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('Simpan Pengaturan'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfoCard(SensorProvider provider, bool isDark) {
    return Container(
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
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.techBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Informasi Sistem Penjernihan Air',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Aplikasi', 'AquaMonitor – IoT Water Treatment'),
          _buildInfoRow('Versi Aplikasi', 'v1.0.0 (Industrial Prototype)'),
          _buildInfoRow('Modul Perangkat', provider.device.name),
          _buildInfoRow('Device ID', provider.device.deviceId),
          _buildInfoRow('Kapasitas Desain Filter', '20 Liter/jam (Filter Multimedia)'),
          _buildInfoRow('Media Filtrasi', 'Kerikil, Pasir Silika, Zeolit, Karbon Aktif, UV'),
          _buildInfoRow('Total Sensor Aktif', '7 Sensor (4 Inlet + 3 Outlet)'),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(SensorProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferensi Tampilan & Frekuensi Data',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 12),
          // Theme Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 20,
                    color: AppColors.techBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text('Mode Gelap (Dark Mode)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Switch(
                value: provider.isDarkMode,
                activeThumbColor: AppColors.techBlue,
                onChanged: (_) => provider.toggleTheme(),
              ),
            ],
          ),
          const Divider(height: 16),
          // Interval Selection
          const Text('Interval Pembaruan Telemetri:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                    color: isSel ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
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
        ],
      ),
    );
  }

  Widget _buildThresholdConfigCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfigurasi Ambang Batas Sensor (Threshold)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nilai di luar batas ini akan memicu status Warning atau Critical pada dashboard.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // 1. Turbidity Outlet Max Threshold
          _buildNumericField(
            controller: _turbidityThresholdCtrl,
            label: 'Maksimum Kekeruhan Outlet (NTU)',
            suffix: 'NTU',
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n <= 0 || n > 200) return 'Batas harus antara 0 - 200';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // 2. pH Min & Max
          Row(
            children: [
              Expanded(
                child: _buildNumericField(
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
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumericField(
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
          const SizedBox(height: 12),

          // 3. Flow Min & Max
          Row(
            children: [
              Expanded(
                child: _buildNumericField(
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
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumericField(
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
          const SizedBox(height: 12),

          // 4. Temp Min & Max
          Row(
            children: [
              Expanded(
                child: _buildNumericField(
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
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumericField(
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
        ],
      ),
    );
  }

  Widget _buildNumericField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
