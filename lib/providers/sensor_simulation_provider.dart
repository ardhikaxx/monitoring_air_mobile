import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/activity_model.dart';
import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';
import '../models/sensor_test_result_model.dart';
import '../models/water_quality_model.dart';
import '../services/simulation_service.dart';
import '../services/storage_service.dart';

class SensorSimulationProvider with ChangeNotifier {
  final SimulationService _simulationService = SimulationService();

  late DeviceModel _device;
  late List<SensorModel> _sensors;
  late List<ActivityModel> _activities;
  late List<SensorTestResultModel> _testHistory;

  bool _isMonitoring = true;
  int _updateInterval = 4; // seconds (3 to 5s)
  Timer? _simulationTimer;

  // Stream/callback for important notification events (SnackBar)
  final StreamController<String> _notificationStreamController =
      StreamController<String>.broadcast();
  Stream<String> get notificationEvents => _notificationStreamController.stream;

  SensorSimulationProvider() {
    _initData();
    _loadSavedSettings();
    _startTimer();
  }

  void _initData() {
    _device = MockData.initialDevice;
    _sensors = MockData.initialSensors;
    _activities = MockData.initialActivities;
    _testHistory = MockData.initialTestHistory;
  }

  Future<void> _loadSavedSettings() async {
    _updateInterval = await StorageService.getUpdateInterval();
    final thresholds = await StorageService.getCustomThresholds();
    updateSensorThreshold('SEN-IN-OUT-TURB', 0.0, thresholds['turbidityOutlet'] ?? 5.0);
    updateSensorThreshold('SEN-IN-OUT-PH', thresholds['phMin'] ?? 6.5, thresholds['phMax'] ?? 8.5);
    updateSensorThreshold('SEN-IN-PH', thresholds['phMin'] ?? 6.5, thresholds['phMax'] ?? 8.5);
    updateSensorThreshold('SEN-IN-FLOW', thresholds['flowMin'] ?? 15.0, thresholds['flowMax'] ?? 25.0);
    notifyListeners();
  }

  // Getters
  DeviceModel get device => _device;
  List<SensorModel> get sensors => _sensors;
  List<ActivityModel> get activities => _activities;
  List<SensorTestResultModel> get testHistory => _testHistory;
  bool get isMonitoring => _isMonitoring;
  int get updateInterval => _updateInterval;
  DemoScenario get currentScenario => _simulationService.activeScenario;

  List<SensorModel> get inletSensors =>
      _sensors.where((s) => s.location == SensorLocation.inlet).toList();

  List<SensorModel> get outletSensors =>
      _sensors.where((s) => s.location == SensorLocation.outlet).toList();

  int get totalSensorsCount => _sensors.length; // 7

  int get normalSensorsCount =>
      _sensors.where((s) => s.status == SensorStatus.normal).length;

  int get warningSensorsCount =>
      _sensors.where((s) => s.status == SensorStatus.warning).length;

  int get errorOrOfflineSensorsCount => _sensors
      .where((s) => s.status == SensorStatus.critical || s.status == SensorStatus.offline)
      .length;

  int get unreadActivitiesCount =>
      _activities.where((a) => !a.isRead).length;

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

  // Timer simulation
  void _startTimer() {
    _simulationTimer?.cancel();
    if (!_isMonitoring) return;

    _simulationTimer = Timer.periodic(Duration(seconds: _updateInterval), (timer) {
      _tickSimulation();
    });
  }

  void _tickSimulation() {
    if (!_isMonitoring) return;

    final flowRate = _getSensorValue(SensorType.flowRateInlet, fallback: 20.0);
    _device = _device.copyWith(
      uptime: _device.uptime + Duration(seconds: _updateInterval),
      lastSync: DateTime.now(),
      flowRate: flowRate,
      totalProcessedVolume: _device.totalProcessedVolume +
          ((flowRate / 3600) * _updateInterval),
    );

    // Track previous status to detect critical transitions for alerts
    final prevCriticalCount = errorOrOfflineSensorsCount;

    _sensors = _simulationService.updateSensors(
      currentSensors: _sensors,
      deviceStatus: _device.status,
    );

    // Trigger alert only when status worsens
    if (errorOrOfflineSensorsCount > prevCriticalCount && _device.status != DeviceConnectionStatus.offline) {
      _emitNotification('Perhatian: Terdapat sensor yang membutuhkan tindakan!');
    }

    notifyListeners();
  }

  void startMonitoring() {
    _isMonitoring = true;
    _startTimer();
    _addActivity(
      title: 'Monitoring Dimulai',
      description: 'Telemetri otomatis sensor aktif dengan interval $_updateInterval detik.',
      type: ActivityType.info,
    );
    _emitNotification('Monitoring telemetri otomatis dimulai.');
    notifyListeners();
  }

  void pauseMonitoring() {
    _isMonitoring = false;
    _simulationTimer?.cancel();
    _addActivity(
      title: 'Monitoring Dijeda',
      description: 'Pembaruan otomatis dinonaktifkan. Pengecekan manual tetap berfungsi.',
      type: ActivityType.warning,
    );
    _emitNotification('Monitoring dijeda. Pengecekan manual tetap aktif.');
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
    final prevStatus = _device.status;
    _device = _device.copyWith(status: status);

    if (status == DeviceConnectionStatus.offline) {
      _simulationService.setScenario(DemoScenario.esp32Disconnected);
      _addActivity(
        title: 'ESP32 Terputus (Offline)',
        description: 'Koneksi telemetri modul ESP32 terputus. Sensor tidak dapat berkomunikasi.',
        type: ActivityType.critical,
      );
      _emitNotification('Peringatan Kritis: ESP32 Controller Terputus!');
    } else if (status == DeviceConnectionStatus.unstable) {
      _addActivity(
        title: 'Koneksi ESP32 Tidak Stabil',
        description: 'Sinyal telemetri Wi-Fi berfluktuasi (-88 dBm).',
        type: ActivityType.warning,
      );
      _emitNotification('Peringatan: Koneksi Wi-Fi ESP32 tidak stabil.');
    } else {
      _simulationService.setScenario(DemoScenario.normal);
      _addActivity(
        title: 'ESP32 Kembali Online',
        description: 'Komunikasi telemetri modul ESP32 kembali normal.',
        type: ActivityType.success,
      );
      if (prevStatus == DeviceConnectionStatus.offline) {
        _emitNotification('ESP32 Controller kembali Online.');
      }
    }
    _tickSimulation();
    notifyListeners();
  }

  // Check single sensor
  Future<Map<String, dynamic>> checkSensor(String sensorId) async {
    final sensor = getSensorById(sensorId);
    if (sensor == null) {
      return {'status': 'Error', 'result': 'Sensor tidak ditemukan'};
    }
    final result = await _simulationService.checkSensor(sensor);

    _addActivity(
      title: 'Pemeriksaan Sensor: ${sensor.name}',
      description: 'Hasil: ${result['result']}. Latensi: ${result['latency']}, Tegangan: ${result['voltage']}.',
      type: result['result'] == 'Passed' ? ActivityType.success : ActivityType.critical,
      sensorId: sensorId,
    );

    notifyListeners();
    return result;
  }

  // Test single sensor with step callback
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

    final index = _sensors.indexWhere((s) => s.id == sensorId);
    if (index != -1) {
      _sensors[index] = _sensors[index].copyWith(
        lastTested: testResult.timestamp,
        lastTestResult: testResult.status.label,
      );
    }

    _testHistory.insert(0, testResult);

    _addActivity(
      title: 'Uji Sensor Selesai: ${sensor.name}',
      description: 'Hasil: ${testResult.status.label}. ${testResult.notes}',
      type: testResult.status == TestStatus.passed
          ? ActivityType.success
          : testResult.status == TestStatus.warning
              ? ActivityType.warning
              : ActivityType.critical,
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

      final idx = _sensors.indexWhere((s) => s.id == sensor.id);
      if (idx != -1) {
        _sensors[idx] = _sensors[idx].copyWith(
          lastTested: testResult.timestamp,
          lastTestResult: testResult.status.label,
        );
      }
    }

    _testHistory.insertAll(0, results);

    final passed = results.where((r) => r.status == TestStatus.passed).length;
    final failed = results.where((r) => r.status == TestStatus.failed).length;

    _addActivity(
      title: 'Pengujian Semua Sensor Selesai',
      description: 'Hasil 7 sensor: $passed Passed, $failed Failed.',
      type: failed > 0 ? ActivityType.warning : ActivityType.success,
    );

    _emitNotification('Pengujian 7 sensor selesai: $passed Lolos, $failed Gagal.');
    notifyListeners();
    return results;
  }

  // Refresh single sensor
  Future<void> refreshSensor(String sensorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
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

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _tickSimulation();
    _addActivity(
      title: 'Pembaruan Data Sensor',
      description: 'Seluruh pembacaan 7 sensor berhasil diperbarui.',
      type: ActivityType.info,
    );
    _emitNotification('Data seluruh sensor berhasil diperbarui.');
    notifyListeners();
  }

  // Apply Demonstration Scenario
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

    _addActivity(
      title: 'Skenario: ${scenario.title}',
      description: scenario.description,
      type: scenario == DemoScenario.normal ? ActivityType.info : ActivityType.warning,
    );

    _emitNotification('Skenario simulasi aktif: ${scenario.title}');
    notifyListeners();
  }

  void resetScenario() {
    applyScenario(DemoScenario.normal);
  }

  // Reset simulation to baseline
  void resetSimulation() {
    _initData();
    _simulationService.setScenario(DemoScenario.normal);
    _isMonitoring = true;
    _startTimer();
    _addActivity(
      title: 'Simulasi Direset',
      description: 'Nilai dan status seluruh sensor dikembalikan ke konfigurasi awal.',
      type: ActivityType.info,
    );
    _emitNotification('Simulasi berhasil dikembalikan ke kondisi default.');
    notifyListeners();
  }

  // Threshold update
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

  // Activities management
  void _addActivity({
    required String title,
    required String description,
    required ActivityType type,
    String? sensorId,
  }) {
    _activities.insert(
      0,
      ActivityModel(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: title,
        description: description,
        sensorId: sensorId,
        timestamp: DateTime.now(),
        type: type,
        isRead: false,
      ),
    );
    if (_activities.length > 25) {
      _activities.removeLast();
    }
  }

  void markActivityRead(String id) {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index != -1) {
      _activities[index] = _activities[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllActivitiesRead() {
    _activities = _activities.map((a) => a.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }

  void _emitNotification(String message) {
    if (!_notificationStreamController.isClosed) {
      _notificationStreamController.add(message);
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _notificationStreamController.close();
    super.dispose();
  }
}
