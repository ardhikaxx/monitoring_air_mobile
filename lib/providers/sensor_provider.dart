import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/device_model.dart';
import '../models/notification_model.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/sensor_test_result_model.dart';
import '../models/water_quality_model.dart';
import '../services/simulation_service.dart';
import '../services/storage_service.dart';

class SensorProvider with ChangeNotifier {
  final SimulationService _simulationService = SimulationService();

  late DeviceModel _device;
  late List<SensorModel> _sensors;
  late List<NotificationModel> _notifications;
  late List<SensorTestResultModel> _testHistory;

  bool _isMonitoring = true;
  int _updateInterval = 4; // seconds
  Timer? _simulationTimer;
  bool _isDarkMode = false;

  SensorProvider() {
    _initData();
    _loadSavedSettings();
    _startTimer();
  }

  void _initData() {
    _device = MockData.initialDevice;
    _sensors = MockData.initialSensors;
    _notifications = MockData.initialNotifications;
    _testHistory = MockData.initialTestHistory;
  }

  Future<void> _loadSavedSettings() async {
    _isDarkMode = await StorageService.isDarkMode();
    _updateInterval = await StorageService.getUpdateInterval();
    notifyListeners();
  }

  // Getters
  DeviceModel get device => _device;
  List<SensorModel> get sensors => _sensors;
  List<NotificationModel> get notifications => _notifications;
  List<SensorTestResultModel> get testHistory => _testHistory;
  bool get isMonitoring => _isMonitoring;
  int get updateInterval => _updateInterval;
  bool get isDarkMode => _isDarkMode;
  DemoScenario get currentScenario => _simulationService.activeScenario;

  // Filtered sensor subsets
  List<SensorModel> get inletSensors =>
      _sensors.where((s) => s.location == SensorLocation.inlet).toList();

  List<SensorModel> get outletSensors =>
      _sensors.where((s) => s.location == SensorLocation.outlet).toList();

  // Statistics counters
  int get totalSensorsCount => _sensors.length; // 7

  int get normalSensorsCount =>
      _sensors.where((s) => s.status == SensorStatus.normal).length;

  int get warningSensorsCount =>
      _sensors.where((s) => s.status == SensorStatus.warning).length;

  int get errorOrOfflineSensorsCount => _sensors
      .where((s) => s.status == SensorStatus.critical || s.status == SensorStatus.offline)
      .length;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  // Water Quality Comparison
  WaterQualityComparison get waterQualityComparison {
    final turbIn = _getSensorValue(SensorType.turbidityInlet, fallback: 85.0);
    final turbOut = _getSensorValue(SensorType.turbidityOutlet, fallback: 3.0);
    final phIn = _getSensorValue(SensorType.phInlet, fallback: 6.3);
    final phOut = _getSensorValue(SensorType.phOutlet, fallback: 7.0);
    final tempIn = _getSensorValue(SensorType.temperatureInlet, fallback: 27.0);
    final tempOut = _getSensorValue(SensorType.temperatureOutlet, fallback: 28.0);
    final flow = _getSensorValue(SensorType.flowRateInlet, fallback: 20.0);

    return WaterQualityComparison(
      turbidityInlet: turbIn,
      turbidityOutlet: turbOut,
      phInlet: phIn,
      phOutlet: phOut,
      tempInlet: tempIn,
      tempOutlet: tempOut,
      flowRate: flow,
    );
  }

  double _getSensorValue(SensorType type, {required double fallback}) {
    try {
      return _sensors.firstWhere((s) => s.type == type).currentValue;
    } catch (_) {
      return fallback;
    }
  }

  SensorModel? getSensorById(String id) {
    try {
      return _sensors.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Timer controls
  void _startTimer() {
    _simulationTimer?.cancel();
    if (!_isMonitoring) return;

    _simulationTimer = Timer.periodic(Duration(seconds: _updateInterval), (_) {
      _tickSimulation();
    });
  }

  void _tickSimulation() {
    if (!_isMonitoring) return;

    // Update uptime and total volume
    _device = _device.copyWith(
      uptime: _device.uptime + Duration(seconds: _updateInterval),
      lastSync: DateTime.now(),
      flowRate: _getSensorValue(SensorType.flowRateInlet, fallback: 20.0),
      totalProcessedVolume: _device.totalProcessedVolume +
          ((_getSensorValue(SensorType.flowRateInlet, fallback: 20.0) / 3600) * _updateInterval),
    );

    // Update sensors
    _sensors = _simulationService.updateSensors(
      currentSensors: _sensors,
      deviceStatus: _device.status,
    );

    notifyListeners();
  }

  void startMonitoring() {
    _isMonitoring = true;
    _startTimer();
    _addNotification(
      title: 'Monitoring Dimulai',
      message: 'Telemetri otomatis aktif dengan interval $_updateInterval detik.',
      type: NotificationType.info,
    );
    notifyListeners();
  }

  void pauseMonitoring() {
    _isMonitoring = false;
    _simulationTimer?.cancel();
    _addNotification(
      title: 'Monitoring Dijeda',
      message: 'Pembaruan otomatis dinonaktifkan. Pengecekan manual tetap tersedia.',
      type: NotificationType.warning,
    );
    notifyListeners();
  }

  void toggleMonitoring() {
    if (_isMonitoring) {
      pauseMonitoring();
    } else {
      startMonitoring();
    }
  }

  void setUpdateInterval(int seconds) {
    _updateInterval = seconds;
    StorageService.saveUpdateInterval(seconds);
    _startTimer();
    notifyListeners();
  }

  // Device status simulation
  void setDeviceStatus(DeviceConnectionStatus status) {
    _device = _device.copyWith(status: status);
    if (status == DeviceConnectionStatus.offline) {
      _simulationService.setScenario(DemoScenario.esp32Disconnected);
      _addNotification(
        title: 'ESP32 Terputus',
        message: 'Koneksi telemetri ke modul utama offline. Semua sensor tidak terbaca.',
        type: NotificationType.critical,
      );
    } else if (status == DeviceConnectionStatus.unstable) {
      _addNotification(
        title: 'Koneksi ESP32 Tidak Stabil',
        message: 'Kualitas sinyal telemetri berfluktuasi (-88 dBm).',
        type: NotificationType.warning,
      );
    } else {
      _simulationService.setScenario(DemoScenario.normal);
      _addNotification(
        title: 'ESP32 Kembali Online',
        message: 'Sinkronisasi telemetri ke AquaNet aktif kembali.',
        type: NotificationType.success,
      );
    }
    _tickSimulation();
    notifyListeners();
  }

  // Check a single sensor
  Future<Map<String, dynamic>> checkSensor(String sensorId) async {
    final sensor = getSensorById(sensorId);
    if (sensor == null) {
      return {'status': 'Error', 'result': 'Sensor tidak ditemukan'};
    }
    final result = await _simulationService.checkSensor(sensor);
    notifyListeners();
    return result;
  }

  // Test a single sensor
  Future<SensorTestResultModel> testSensor(
    String sensorId,
    Function(String step, double progress) onProgress,
  ) async {
    final sensor = getSensorById(sensorId);
    if (sensor == null) {
      throw Exception('Sensor tidak ditemukan');
    }

    final testResult = await _simulationService.testSensor(
      sensor: sensor,
      onProgress: onProgress,
    );

    // Update sensor state
    final index = _sensors.indexWhere((s) => s.id == sensorId);
    if (index != -1) {
      _sensors[index] = _sensors[index].copyWith(
        lastTested: testResult.timestamp,
        lastTestResult: testResult.status.label,
      );
    }

    // Add to test history
    _testHistory.insert(0, testResult);

    _addNotification(
      title: 'Uji Sensor Selesai: ${sensor.name}',
      message: 'Hasil pengujian: ${testResult.status.label}. ${testResult.notes}',
      type: testResult.status == TestStatus.passed
          ? NotificationType.success
          : testResult.status == TestStatus.warning
              ? NotificationType.warning
              : NotificationType.critical,
      sensorId: sensorId,
    );

    notifyListeners();
    return testResult;
  }

  // Test all 7 sensors sequentially
  Future<List<SensorTestResultModel>> testAllSensors(
    Function(int currentIndex, String sensorName, double progress) onProgress,
  ) async {
    final List<SensorTestResultModel> results = [];
    final total = _sensors.length;

    for (int i = 0; i < total; i++) {
      final sensor = _sensors[i];
      onProgress(i, sensor.name, (i / total));

      final testResult = await _simulationService.testSensor(
        sensor: sensor,
        onProgress: (step, prog) {},
      );

      results.add(testResult);

      // Update sensor record
      final idx = _sensors.indexWhere((s) => s.id == sensor.id);
      if (idx != -1) {
        _sensors[idx] = _sensors[idx].copyWith(
          lastTested: testResult.timestamp,
          lastTestResult: testResult.status.label,
        );
      }
    }

    // Prepend all results to test history
    _testHistory.insertAll(0, results);

    final passed = results.where((r) => r.status == TestStatus.passed).length;
    final failed = results.where((r) => r.status == TestStatus.failed).length;

    _addNotification(
      title: 'Diagnostik Seluruh Sensor Selesai',
      message: 'Pemeriksaan 7 sensor: $passed Lolos, $failed Gagal.',
      type: failed > 0 ? NotificationType.warning : NotificationType.success,
    );

    notifyListeners();
    return results;
  }

  // Refresh single sensor
  Future<void> refreshSensor(String sensorId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _sensors.indexWhere((s) => s.id == sensorId);
    if (index != -1) {
      final sensor = _sensors[index];
      final updatedList = _simulationService.updateSensors(
        currentSensors: [sensor],
        deviceStatus: _device.status,
      );
      _sensors[index] = updatedList.first;
      notifyListeners();
    }
  }

  // Refresh all sensors
  Future<void> refreshAllSensors() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _tickSimulation();
    _addNotification(
      title: 'Pembaruan Data Berhasil',
      message: 'Seluruh pembacaan 7 sensor telah diperbarui dengan data terkini.',
      type: NotificationType.info,
    );
  }

  // Calibrate sensor
  Future<Map<String, dynamic>> calibrateSensor(
    String sensorId,
    double referenceValue,
  ) async {
    final sensor = getSensorById(sensorId);
    if (sensor == null) {
      return {'success': false, 'message': 'Sensor tidak ditemukan'};
    }

    final calibResult = await _simulationService.calibrateSensor(
      sensor: sensor,
      referenceStandard: referenceValue,
    );

    // Update sensor value and offset
    final index = _sensors.indexWhere((s) => s.id == sensorId);
    if (index != -1) {
      _sensors[index] = _sensors[index].copyWith(
        currentValue: referenceValue,
        calibrationOffset: calibResult['offset'] as double,
        healthStatus: 'Optimal (100%) • Baru Saja Dikalibrasi',
        lastUpdated: DateTime.now(),
      );
    }

    // Add calibration to test history
    _testHistory.insert(
      0,
      SensorTestResultModel(
        id: 'CAL-${DateTime.now().millisecondsSinceEpoch % 10000}',
        sensorId: sensor.id,
        sensorName: sensor.name,
        timestamp: DateTime.now(),
        status: TestStatus.passed,
        latencyMs: 11,
        voltage: 3.3,
        readingValue: referenceValue,
        unit: sensor.unit,
        testType: 'Simulasi Kalibrasi',
        notes: 'Offset kalibrasi diterapkan: ${calibResult['offset']}. Pembacaan diselaraskan dengan standar $referenceValue ${sensor.unit}.',
      ),
    );

    _addNotification(
      title: 'Kalibrasi Berhasil: ${sensor.name}',
      message: 'Sensor diselaraskan dengan standar referensi $referenceValue ${sensor.unit}.',
      type: NotificationType.success,
      sensorId: sensorId,
    );

    notifyListeners();
    return calibResult;
  }

  // Demonstration Scenarios
  void applyScenario(DemoScenario scenario) {
    _simulationService.setScenario(scenario);

    if (scenario == DemoScenario.esp32Disconnected) {
      _device = _device.copyWith(status: DeviceConnectionStatus.offline);
    } else {
      if (_device.status == DeviceConnectionStatus.offline) {
        _device = _device.copyWith(status: DeviceConnectionStatus.online);
      }
    }

    _tickSimulation();

    _addNotification(
      title: 'Skenario Aktif: ${scenario.title}',
      message: scenario.description,
      type: scenario == DemoScenario.normal
          ? NotificationType.info
          : NotificationType.warning,
    );

    notifyListeners();
  }

  void resetScenario() {
    applyScenario(DemoScenario.normal);
  }

  void resetSimulation() {
    _initData();
    _simulationService.setScenario(DemoScenario.normal);
    _isMonitoring = true;
    _startTimer();
    _addNotification(
      title: 'Simulasi Direset',
      message: 'Seluruh konfigurasi dan pembacaan sensor dikembalikan ke kondisi default.',
      type: NotificationType.info,
    );
    notifyListeners();
  }

  // Notifications management
  void _addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? sensorId,
  }) {
    _notifications.insert(
      0,
      NotificationModel(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: title,
        message: message,
        sensorId: sensorId,
        timestamp: DateTime.now(),
        type: type,
        isRead: false,
      ),
    );
    if (_notifications.length > 30) {
      _notifications.removeLast();
    }
  }

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Theme toggle
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    StorageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  // Update sensor thresholds
  void updateSensorThreshold(String sensorId, double min, double max) {
    final index = _sensors.indexWhere((s) => s.id == sensorId);
    if (index != -1) {
      _sensors[index] = _sensors[index].copyWith(
        minThreshold: min,
        maxThreshold: max,
      );
      _tickSimulation();
      notifyListeners();
    }
  }

  // Export CSV Data
  String exportCsvData() {
    final StringBuffer csv = StringBuffer();
    csv.writeln('Sensor ID,Nama Sensor,Lokasi,Waktu Pembacaan,Nilai,Satuan,Status');

    for (final sensor in _sensors) {
      for (final reading in sensor.readings) {
        csv.writeln(
          '${sensor.id},"${sensor.name}",${sensor.location.name},${reading.timestamp.toIso8601String()},${reading.value},${sensor.unit},${reading.status.name}',
        );
      }
    }
    return csv.toString();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
