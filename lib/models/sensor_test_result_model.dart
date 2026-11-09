enum TestStatus {
  passed,
  warning,
  failed;

  String get label {
    switch (this) {
      case TestStatus.passed:
        return 'Test Passed';
      case TestStatus.warning:
        return 'Warning';
      case TestStatus.failed:
        return 'Failed';
    }
  }
}

class SensorTestResultModel {
  final String id;
  final String sensorId;
  final String sensorName;
  final DateTime timestamp;
  final TestStatus status;
  final int latencyMs;
  final double voltage; // e.g. 3.28 V
  final double readingValue;
  final String unit;
  final String testType; // 'Quick Check', 'Comprehensive Diagnostic', 'Calibration'
  final String notes;

  SensorTestResultModel({
    required this.id,
    required this.sensorId,
    required this.sensorName,
    required this.timestamp,
    required this.status,
    required this.latencyMs,
    required this.voltage,
    required this.readingValue,
    required this.unit,
    this.testType = 'Comprehensive Diagnostic',
    required this.notes,
  });
}
