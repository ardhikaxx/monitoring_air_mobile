import 'dart:math';
import '../models/device_model.dart';
import '../models/notification_model.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/sensor_test_result_model.dart';

class MockData {
  static final DateTime _now = DateTime.now();
  static final Random _random = Random();

  // Generate 24 hours of simulated historical readings
  static List<SensorReadingModel> _generateHistory(
    double baseValue,
    double variance,
    SensorStatus Function(double val) statusChecker,
  ) {
    final List<SensorReadingModel> list = [];
    for (int i = 24; i >= 0; i--) {
      final time = _now.subtract(Duration(hours: i));
      // Add slight diurnal wave plus random noise
      final wave = sin(i * 0.25) * (variance * 0.5);
      final noise = (_random.nextDouble() - 0.5) * variance;
      final val = double.parse((baseValue + wave + noise).toStringAsFixed(2));
      list.add(SensorReadingModel(
        timestamp: time,
        value: val,
        status: statusChecker(val),
      ));
    }
    return list;
  }

  static DeviceModel get initialDevice => DeviceModel(
        name: 'ESP32-WROOM-32 WaterStation',
        deviceId: 'AQM-ESP32-9021',
        status: DeviceConnectionStatus.online,
        ipAddress: '192.168.1.145',
        wifiSsid: 'AquaNet_IoT_Industrial',
        wifiRssi: -62, // ~76% strength
        firmwareVersion: 'v2.4.1-rc3',
        uptime: const Duration(days: 3, hours: 14, minutes: 22, seconds: 40),
        lastSync: DateTime.now(),
        flowRate: 20.0,
        totalProcessedVolume: 1740.8,
      );

  static List<SensorModel> get initialSensors {
    final now = DateTime.now();

    return [
      // 1. Inlet Turbidity
      SensorModel(
        id: 'SEN-IN-TURB',
        name: 'Sensor Kekeruhan Inlet',
        type: SensorType.turbidityInlet,
        location: SensorLocation.inlet,
        unit: 'NTU',
        currentValue: 85.0,
        lastUpdated: now,
        status: SensorStatus.warning, // River water is naturally turbid (> 50 NTU)
        minThreshold: 0.0,
        maxThreshold: 50.0,
        hardwareSpec: 'DFRobot Gravity Turbidity Sensor V1.0 (Optik)',
        pinConnection: 'ESP32 GPIO 34 (ADC1_CH6)',
        description: 'Mengukur tingkat kekeruhan air sungai (air baku) sebelum masuk ke tangki sedimentasi dan filter multimedia.',
        readings: _generateHistory(
          85.0,
          8.0,
          (val) => val > 120.0
              ? SensorStatus.critical
              : val > 50.0
                  ? SensorStatus.warning
                  : SensorStatus.normal,
        ),
        healthStatus: 'Optimal (97%) • Kalibrasi: 3 hari lalu',
        lastTested: now.subtract(const Duration(hours: 4)),
        lastTestResult: 'Passed',
      ),

      // 2. Inlet pH
      SensorModel(
        id: 'SEN-IN-PH',
        name: 'Sensor pH Inlet',
        type: SensorType.phInlet,
        location: SensorLocation.inlet,
        unit: 'pH',
        currentValue: 6.3,
        lastUpdated: now,
        status: SensorStatus.warning, // Slightly below 6.5 neutral
        minThreshold: 6.5,
        maxThreshold: 8.5,
        hardwareSpec: 'Analog pH Meter Pro Kit (E-201-C BNC Probe)',
        pinConnection: 'ESP32 GPIO 35 (ADC1_CH7)',
        description: 'Memantau tingkat keasaman atau kebasaan air sungai sebelum melewati penetralan dan filtrasi multimedia.',
        readings: _generateHistory(
          6.3,
          0.3,
          (val) => (val < 6.0 || val > 9.0)
              ? SensorStatus.critical
              : (val < 6.5 || val > 8.5)
                  ? SensorStatus.warning
                  : SensorStatus.normal,
        ),
        healthStatus: 'Optimal (94%) • Probe Bersih',
        lastTested: now.subtract(const Duration(hours: 4)),
        lastTestResult: 'Passed',
      ),

      // 3. Inlet Flow Rate
      SensorModel(
        id: 'SEN-IN-FLOW',
        name: 'Sensor Flow Rate Inlet',
        type: SensorType.flowRateInlet,
        location: SensorLocation.inlet,
        unit: 'L/jam',
        currentValue: 20.0,
        lastUpdated: now,
        status: SensorStatus.normal, // Matches 20 L/jam system capacity
        minThreshold: 15.0,
        maxThreshold: 25.0,
        hardwareSpec: 'YF-S201 Hall Effect Flow Sensor (G1/2)',
        pinConnection: 'ESP32 GPIO 19 (Pulse Counter)',
        description: 'Mengukur debit volume aliran air yang dipompa dari sumber sungai menuju ke dalam sistem instalasi penjernihan.',
        readings: _generateHistory(
          20.0,
          1.8,
          (val) => (val < 10.0 || val > 30.0)
              ? SensorStatus.critical
              : (val < 15.0 || val > 25.0)
                  ? SensorStatus.warning
                  : SensorStatus.normal,
        ),
        healthStatus: 'Normal (99%) • Impeller Lancar',
        lastTested: now.subtract(const Duration(hours: 5)),
        lastTestResult: 'Passed',
      ),

      // 4. Inlet Temperature
      SensorModel(
        id: 'SEN-IN-TEMP',
        name: 'Sensor Suhu Inlet',
        type: SensorType.temperatureInlet,
        location: SensorLocation.inlet,
        unit: '°C',
        currentValue: 27.0,
        lastUpdated: now,
        status: SensorStatus.normal,
        minThreshold: 20.0,
        maxThreshold: 32.0,
        hardwareSpec: 'Dallas DS18B20 Waterproof Stainless Probe (1-Wire)',
        pinConnection: 'ESP32 GPIO 4 (OneWire Bus)',
        description: 'Mencatat temperatur air sungai sebelum perlakuan fisik dan kimia pada media filter.',
        readings: _generateHistory(
          27.0,
          0.8,
          (val) => (val < 15.0 || val > 38.0)
              ? SensorStatus.critical
              : (val < 20.0 || val > 32.0)
                  ? SensorStatus.warning
                  : SensorStatus.normal,
        ),
        healthStatus: 'Optimal (100%) • Bus Stabil',
        lastTested: now.subtract(const Duration(hours: 5)),
        lastTestResult: 'Passed',
      ),

      // 5. Outlet Turbidity
      SensorModel(
        id: 'SEN-IN-OUT-TURB',
        name: 'Sensor Kekeruhan Outlet',
        type: SensorType.turbidityOutlet,
        location: SensorLocation.outlet,
        unit: 'NTU',
        currentValue: 3.0,
        lastUpdated: now,
        status: SensorStatus.normal, // < 5 NTU is high purity!
        minThreshold: 0.0,
        maxThreshold: 5.0,
        hardwareSpec: 'DFRobot High Precision Turbidity Sensor V2.0',
        pinConnection: 'ESP32 GPIO 32 (ADC1_CH4)',
        description: 'Memantau kejernihan air setelah melewati sedimentasi, filter pasir silika, karbon aktif, zeolit, dan disinfeksi UV.',
        readings: _generateHistory(
          3.0,
          0.4,
          (val) => val > 10.0
              ? SensorStatus.critical
              : val > 5.0
                  ? SensorStatus.warning
                  : SensorStatus.normal,
        ),
        healthStatus: 'Optimal (98%) • Efisiensi Filtrasi >96%',
        lastTested: now.subtract(const Duration(hours: 3)),
        lastTestResult: 'Passed',
      ),

      // 6. Outlet pH
      SensorModel(
        id: 'SEN-IN-OUT-PH',
        name: 'Sensor pH Outlet',
        type: SensorType.phOutlet,
        location: SensorLocation.outlet,
        unit: 'pH',
        currentValue: 7.0,
        lastUpdated: now,
        status: SensorStatus.normal, // Neutral 7.0!
        minThreshold: 6.5,
        maxThreshold: 8.5,
        hardwareSpec: 'Industrial Grade BNC Glass pH Electrode Probe',
        pinConnection: 'ESP32 GPIO 33 (ADC1_CH5)',
        description: 'Memastikan nilai pH air hasil filtrasi telah stabil pada batas netral yang aman untuk digunakan.',
        readings: _generateHistory(
          7.0,
          0.15,
          (val) => (val < 6.0 || val > 9.0)
              ? SensorStatus.critical
              : (val < 6.5 || val > 8.5)
                  ? SensorStatus.warning
                  : SensorStatus.normal,
        ),
        healthStatus: 'Optimal (96%) • Pembacaan Sangat Stabil',
        lastTested: now.subtract(const Duration(hours: 3)),
        lastTestResult: 'Passed',
      ),

      // 7. Outlet Temperature
      SensorModel(
        id: 'SEN-IN-OUT-TEMP',
        name: 'Sensor Suhu Outlet',
        type: SensorType.temperatureOutlet,
        location: SensorLocation.outlet,
        unit: '°C',
        currentValue: 28.0,
        lastUpdated: now,
        status: SensorStatus.normal,
        minThreshold: 20.0,
        maxThreshold: 32.0,
        hardwareSpec: 'Dallas DS18B20 Waterproof Probe (1-Wire Stainless)',
        pinConnection: 'ESP32 GPIO 4 (OneWire Sub-address)',
        description: 'Mengukur temperatur air hasil akhir pasca pemaparan lampu ultraviolet dan tabung penampungan bersih.',
        readings: _generateHistory(
          28.0,
          0.6,
          (val) => (val < 15.0 || val > 38.0)
              ? SensorStatus.critical
              : (val < 20.0 || val > 32.0)
                  ? SensorStatus.warning
                  : SensorStatus.normal,
        ),
        healthStatus: 'Optimal (99%) • Termal Stabil',
        lastTested: now.subtract(const Duration(hours: 3)),
        lastTestResult: 'Passed',
      ),
    ];
  }

  static List<NotificationModel> get initialNotifications {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'NOTIF-01',
        title: 'Filtrasi Berjalan Efektif',
        message: 'Kekeruhan air berhasil diturunkan dari 85.0 NTU (inlet) menjadi 3.0 NTU (outlet).',
        timestamp: now.subtract(const Duration(minutes: 8)),
        type: NotificationType.success,
        sensorId: 'SEN-IN-OUT-TURB',
      ),
      NotificationModel(
        id: 'NOTIF-02',
        title: 'Sensor pH Inlet Mendekati Batas',
        message: 'Nilai pH air baku terbaca 6.3 pH (sedikit asam). Filter multimedia aktif melakukan stabilisasi.',
        timestamp: now.subtract(const Duration(minutes: 25)),
        type: NotificationType.warning,
        sensorId: 'SEN-IN-PH',
      ),
      NotificationModel(
        id: 'NOTIF-03',
        title: 'Diagnostik Seluruh Sensor Selesai',
        message: 'Pengujian berkala terhadap 7 sensor utama berhasil dijalankan dengan status lolos (Passed).',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationType.info,
      ),
      NotificationModel(
        id: 'NOTIF-04',
        title: 'ESP32 Terhubung ke AquaNet',
        message: 'Koneksi telemetri Wi-Fi industrial stabil pada sinyal -62 dBm.',
        timestamp: now.subtract(const Duration(hours: 4)),
        type: NotificationType.success,
      ),
    ];
  }

  static List<SensorTestResultModel> get initialTestHistory {
    final now = DateTime.now();
    return [
      SensorTestResultModel(
        id: 'TEST-101',
        sensorId: 'SEN-IN-TURB',
        sensorName: 'Sensor Kekeruhan Inlet',
        timestamp: now.subtract(const Duration(hours: 4)),
        status: TestStatus.passed,
        latencyMs: 14,
        voltage: 3.28,
        readingValue: 85.2,
        unit: 'NTU',
        notes: 'Respon fotodioda optik normal. Sinyal analog stabil tanpa jitter berlebih.',
      ),
      SensorTestResultModel(
        id: 'TEST-102',
        sensorId: 'SEN-IN-OUT-TURB',
        sensorName: 'Sensor Kekeruhan Outlet',
        timestamp: now.subtract(const Duration(hours: 3)),
        status: TestStatus.passed,
        latencyMs: 12,
        voltage: 3.30,
        readingValue: 2.95,
        unit: 'NTU',
        notes: 'Offset nol kalibrasi berada pada deviasi < 0.05 NTU. Sangat akurat.',
      ),
      SensorTestResultModel(
        id: 'TEST-103',
        sensorId: 'SEN-IN-PH',
        sensorName: 'Sensor pH Inlet',
        timestamp: now.subtract(const Duration(hours: 4)),
        status: TestStatus.passed,
        latencyMs: 16,
        voltage: 3.25,
        readingValue: 6.32,
        unit: 'pH',
        notes: 'Probe elektroda merespon cairan penyangga dengan impedansi normal.',
      ),
    ];
  }
}
