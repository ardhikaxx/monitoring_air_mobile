import 'dart:async';
import 'dart:math';
import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/sensor_test_result_model.dart';

enum DemoScenario {
  normal,
  highTurbidity,
  abnormalPh,
  lowFlowRate,
  temperatureError,
  sensorOffline,
  esp32Disconnected;

  String get title {
    switch (this) {
      case DemoScenario.normal:
        return 'Normal Operation';
      case DemoScenario.highTurbidity:
        return 'High Turbidity (Kekeruhan Tinggi)';
      case DemoScenario.abnormalPh:
        return 'Abnormal pH (pH Tidak Normal)';
      case DemoScenario.lowFlowRate:
        return 'Low Flow Rate (Debit Rendah)';
      case DemoScenario.temperatureError:
        return 'Sensor Temperature Error';
      case DemoScenario.sensorOffline:
        return 'Sensor Offline (Sensors Terputus)';
      case DemoScenario.esp32Disconnected:
        return 'ESP32 Disconnected (Koneksi Putus)';
    }
  }

  String get description {
    switch (this) {
      case DemoScenario.normal:
        return 'Semua sensor beroperasi stabil dalam rentang normal dan ESP32 terhubung.';
      case DemoScenario.highTurbidity:
        return 'Kekeruhan inlet melonjak drastis akibat limpasan sedimen air sungai.';
      case DemoScenario.abnormalPh:
        return 'Nilai pH air outlet berada di luar batas konfigurasi normal.';
      case DemoScenario.lowFlowRate:
        return 'Debit air inlet menurun drastis akibat sumbatan atau penurunan hisap pompa.';
      case DemoScenario.temperatureError:
        return 'Sensor suhu mengalami anomali pembacaan termal yang tinggi.';
      case DemoScenario.sensorOffline:
        return 'Sensor kekeruhan inlet kehilangan komunikasi kabel analog/ADC.';
      case DemoScenario.esp32Disconnected:
        return 'Modul mikrokontroler ESP32 kehilangan daya atau sinyal telemetri Wi-Fi.';
    }
  }
}

class SimulationService {
  final Random _random = Random();
  DemoScenario _activeScenario = DemoScenario.normal;

  DemoScenario get activeScenario => _activeScenario;

  void setScenario(DemoScenario scenario) {
    _activeScenario = scenario;
  }

  // Update a list of sensors with simulated realistic values based on current scenario
  List<SensorModel> updateSensors({
    required List<SensorModel> currentSensors,
    required DeviceConnectionStatus deviceStatus,
  }) {
    final now = DateTime.now();

    // If ESP32 is offline, mark all sensors as offline
    if (deviceStatus == DeviceConnectionStatus.offline) {
      return currentSensors.map((sensor) {
        return sensor.copyWith(
          status: SensorStatus.offline,
          healthStatus: 'Komunikasi Terputus (ESP32 Offline)',
          lastUpdated: now,
        );
      }).toList();
    }

    return currentSensors.map((sensor) {
      double newValue = sensor.currentValue;
      SensorStatus newStatus = SensorStatus.normal;
      String newHealth = sensor.healthStatus;

      // Handle specific scenarios
      switch (_activeScenario) {
        case DemoScenario.highTurbidity:
          if (sensor.type == SensorType.turbidityInlet) {
            newValue = 185.0 + (_random.nextDouble() - 0.5) * 6.0;
            newStatus = SensorStatus.critical;
            newHealth = 'Peringatan: Kekeruhan Air Baku Sangat Tinggi!';
          } else if (sensor.type == SensorType.turbidityOutlet) {
            // Filter is under stress, slightly higher
            newValue = 6.2 + (_random.nextDouble() - 0.5) * 0.4;
            newStatus = SensorStatus.warning;
            newHealth = 'Beban Filtrasi Tinggi • Efisiensi 96.6%';
          } else {
            newValue = _calculateNormalValue(sensor);
            newStatus = _evaluateStatus(sensor.type, newValue, sensor.minThreshold, sensor.maxThreshold);
          }
          break;

        case DemoScenario.abnormalPh:
          if (sensor.type == SensorType.phOutlet) {
            newValue = 9.4 + (_random.nextDouble() - 0.5) * 0.1;
            newStatus = SensorStatus.critical;
            newHealth = 'Peringatan: pH Melewati Ambang Basa!';
          } else {
            newValue = _calculateNormalValue(sensor);
            newStatus = _evaluateStatus(sensor.type, newValue, sensor.minThreshold, sensor.maxThreshold);
          }
          break;

        case DemoScenario.lowFlowRate:
          if (sensor.type == SensorType.flowRateInlet) {
            newValue = 4.2 + (_random.nextDouble() - 0.5) * 0.5;
            newStatus = SensorStatus.critical;
            newHealth = 'Kritis: Debit Aliran Terlalu Lemah (< 5 L/jam)';
          } else {
            newValue = _calculateNormalValue(sensor);
            newStatus = _evaluateStatus(sensor.type, newValue, sensor.minThreshold, sensor.maxThreshold);
          }
          break;

        case DemoScenario.temperatureError:
          if (sensor.type == SensorType.temperatureInlet || sensor.type == SensorType.temperatureOutlet) {
            newValue = 48.5 + (_random.nextDouble() - 0.5) * 1.5;
            newStatus = SensorStatus.critical;
            newHealth = 'Thermal Error: Temperatur Melebihi Batas Aman';
          } else {
            newValue = _calculateNormalValue(sensor);
            newStatus = _evaluateStatus(sensor.type, newValue, sensor.minThreshold, sensor.maxThreshold);
          }
          break;

        case DemoScenario.sensorOffline:
          if (sensor.type == SensorType.turbidityInlet) {
            newValue = 0.0;
            newStatus = SensorStatus.offline;
            newHealth = 'Hardware Disconnected • No Signal on GPIO 34';
          } else {
            newValue = _calculateNormalValue(sensor);
            newStatus = _evaluateStatus(sensor.type, newValue, sensor.minThreshold, sensor.maxThreshold);
          }
          break;

        case DemoScenario.esp32Disconnected:
          // Controlled via deviceStatus
          newStatus = SensorStatus.offline;
          newHealth = 'Komunikasi Terputus';
          break;

        case DemoScenario.normal:
          newValue = _calculateNormalValue(sensor);
          newStatus = _evaluateStatus(sensor.type, newValue, sensor.minThreshold, sensor.maxThreshold);
          newHealth = _getDefaultHealth(sensor.type);
          break;
      }

      // Add to reading history (retain up to 50 latest points)
      final updatedReadings = List<SensorReadingModel>.from(sensor.readings);
      updatedReadings.add(SensorReadingModel(
        timestamp: now,
        value: double.parse(newValue.toStringAsFixed(2)),
        status: newStatus,
      ));
      if (updatedReadings.length > 50) {
        updatedReadings.removeAt(0);
      }

      return sensor.copyWith(
        currentValue: double.parse(newValue.toStringAsFixed(2)),
        lastUpdated: now,
        status: newStatus,
        healthStatus: newHealth,
        readings: updatedReadings,
      );
    }).toList();
  }

  // Realistic minor fluctuations around baseline
  double _calculateNormalValue(SensorModel sensor) {
    switch (sensor.type) {
      case SensorType.turbidityInlet:
        // ~85 NTU ± 1.5
        return (85.0 + (_random.nextDouble() - 0.5) * 3.0).clamp(70.0, 110.0);
      case SensorType.phInlet:
        // ~6.30 ± 0.06
        return (6.30 + (_random.nextDouble() - 0.5) * 0.12).clamp(5.8, 7.2);
      case SensorType.flowRateInlet:
        // ~20.0 L/jam ± 0.6
        return (20.0 + (_random.nextDouble() - 0.5) * 1.2).clamp(16.0, 24.0);
      case SensorType.temperatureInlet:
        // ~27.0 °C ± 0.3
        return (27.0 + (_random.nextDouble() - 0.5) * 0.6).clamp(24.0, 31.0);
      case SensorType.turbidityOutlet:
        // ~3.0 NTU ± 0.3 (clear purified water!)
        return (3.0 + (_random.nextDouble() - 0.5) * 0.6).clamp(1.5, 4.5);
      case SensorType.phOutlet:
        // ~7.00 ± 0.05 (neutral balanced water!)
        return (7.00 + (_random.nextDouble() - 0.5) * 0.10).clamp(6.8, 7.4);
      case SensorType.temperatureOutlet:
        // ~28.0 °C ± 0.3
        return (28.0 + (_random.nextDouble() - 0.5) * 0.6).clamp(25.0, 32.0);
    }
  }

  SensorStatus _evaluateStatus(
    SensorType type,
    double value,
    double minThreshold,
    double maxThreshold,
  ) {
    switch (type) {
      case SensorType.turbidityInlet:
        // River water is naturally turbid (> 50 is warning, > 130 is critical)
        if (value > 130) return SensorStatus.critical;
        if (value > 50) return SensorStatus.warning;
        return SensorStatus.normal;
      case SensorType.phInlet:
        if (value < 5.8 || value > 9.0) return SensorStatus.critical;
        if (value < minThreshold || value > maxThreshold) return SensorStatus.warning;
        return SensorStatus.normal;
      case SensorType.flowRateInlet:
        if (value < 8.0 || value > 32.0) return SensorStatus.critical;
        if (value < minThreshold || value > maxThreshold) return SensorStatus.warning;
        return SensorStatus.normal;
      case SensorType.temperatureInlet:
      case SensorType.temperatureOutlet:
        if (value < 15.0 || value > 38.0) return SensorStatus.critical;
        if (value < minThreshold || value > maxThreshold) return SensorStatus.warning;
        return SensorStatus.normal;
      case SensorType.turbidityOutlet:
        if (value > 10.0) return SensorStatus.critical;
        if (value > maxThreshold) return SensorStatus.warning;
        return SensorStatus.normal;
      case SensorType.phOutlet:
        if (value < 6.0 || value > 9.0) return SensorStatus.critical;
        if (value < minThreshold || value > maxThreshold) return SensorStatus.warning;
        return SensorStatus.normal;
    }
  }

  String _getDefaultHealth(SensorType type) {
    switch (type) {
      case SensorType.turbidityInlet:
        return 'Optimal (97%) • Optik Bersih';
      case SensorType.phInlet:
        return 'Optimal (94%) • Probe Terkalibrasi';
      case SensorType.flowRateInlet:
        return 'Normal (99%) • Rotasi Stabil';
      case SensorType.temperatureInlet:
        return 'Optimal (100%) • Bus 1-Wire Aktif';
      case SensorType.turbidityOutlet:
        return 'Optimal (98%) • Filtrasi Efektif';
      case SensorType.phOutlet:
        return 'Optimal (96%) • Pembacaan Netral';
      case SensorType.temperatureOutlet:
        return 'Optimal (99%) • Termal Stabil';
    }
  }

  // Check Sensor simulation (Quick ping & analog reading verification)
  Future<Map<String, dynamic>> checkSensor(SensorModel sensor) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final isOnline = sensor.status != SensorStatus.offline;
    final latency = 10 + _random.nextInt(15);
    final voltage = (3.25 + (_random.nextDouble() * 0.1)).clamp(3.1, 3.35);

    return {
      'sensorId': sensor.id,
      'sensorName': sensor.name,
      'status': isOnline ? 'Tersambung (Connected)' : 'Terputus (No Response)',
      'latency': '${latency}ms',
      'voltage': '${voltage.toStringAsFixed(2)} V',
      'currentValue': '${sensor.currentValue} ${sensor.unit}',
      'result': isOnline ? 'Passed' : 'Failed',
      'notes': isOnline
          ? 'Sensor merespon perintah polling mikrokontroler dengan integritas data 100%.'
          : 'Gagal menerima frame data dari sensor. Periksa perkabelan atau catu daya.',
    };
  }

  // Diagnostic Test with multi-step progress
  Future<SensorTestResultModel> testSensor({
    required SensorModel sensor,
    required Function(String step, double progress) onProgress,
  }) async {
    onProgress('Inisialisasi pengujian perangkat...', 0.15);
    await Future.delayed(const Duration(milliseconds: 400));

    onProgress('Mengirim paket sinyal diagnostik ke ESP32...', 0.35);
    await Future.delayed(const Duration(milliseconds: 500));

    onProgress('Membaca respons telemetri sensor...', 0.60);
    await Future.delayed(const Duration(milliseconds: 500));

    onProgress('Memvalidasi integritas data & noise filter...', 0.85);
    await Future.delayed(const Duration(milliseconds: 400));

    onProgress('Menyusun hasil evaluasi akhir...', 1.0);
    await Future.delayed(const Duration(milliseconds: 250));

    final isOffline = sensor.status == SensorStatus.offline;
    final isCritical = sensor.status == SensorStatus.critical;

    TestStatus status;
    String notes;

    if (isOffline) {
      status = TestStatus.failed;
      notes = 'Sensor gagal merespon handshake diagnostik. Tidak ada sinyal pulsa pada jalur ADC/GPIO.';
    } else if (isCritical) {
      status = TestStatus.warning;
      notes = 'Sensor terhubung dan aktif, namun nilai pembacaan melebihi ambang batas toleransi sistem.';
    } else {
      status = TestStatus.passed;
      notes = 'Semua parameter uji terpenuhi: ADC normal, ripple tegangan <2%, delay respon <20ms.';
    }

    return SensorTestResultModel(
      id: 'TEST-${DateTime.now().millisecondsSinceEpoch % 10000}',
      sensorId: sensor.id,
      sensorName: sensor.name,
      timestamp: DateTime.now(),
      status: status,
      latencyMs: isOffline ? 999 : 12 + _random.nextInt(10),
      voltage: isOffline ? 0.0 : 3.28 + (_random.nextDouble() - 0.5) * 0.05,
      readingValue: sensor.currentValue,
      unit: sensor.unit,
      testType: 'Comprehensive Diagnostic',
      notes: notes,
    );
  }

  // Simulate Calibration
  Future<Map<String, dynamic>> calibrateSensor({
    required SensorModel sensor,
    required double referenceStandard,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final offset = double.parse((referenceStandard - sensor.currentValue).toStringAsFixed(2));
    final postValue = referenceStandard;

    return {
      'sensorId': sensor.id,
      'sensorName': sensor.name,
      'preValue': sensor.currentValue,
      'referenceStandard': referenceStandard,
      'offset': offset,
      'postValue': postValue,
      'unit': sensor.unit,
      'success': true,
      'timestamp': DateTime.now(),
      'message': 'Kalibrasi simulasi berhasil disimpan. Titik referensi disesuaikan menjadi $postValue ${sensor.unit}.',
    };
  }
}
