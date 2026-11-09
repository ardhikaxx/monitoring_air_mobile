import 'sensor_reading_model.dart';

enum SensorLocation {
  inlet,
  outlet;

  String get label {
    switch (this) {
      case SensorLocation.inlet:
        return 'Inlet (Air Baku)';
      case SensorLocation.outlet:
        return 'Outlet (Air Hasil)';
    }
  }
}

enum SensorType {
  turbidityInlet,
  phInlet,
  flowRateInlet,
  temperatureInlet,
  turbidityOutlet,
  phOutlet,
  temperatureOutlet;

  String get displayName {
    switch (this) {
      case SensorType.turbidityInlet:
        return 'Kekeruhan Inlet';
      case SensorType.phInlet:
        return 'pH Air Inlet';
      case SensorType.flowRateInlet:
        return 'Flow Rate Inlet';
      case SensorType.temperatureInlet:
        return 'Suhu Air Inlet';
      case SensorType.turbidityOutlet:
        return 'Kekeruhan Outlet';
      case SensorType.phOutlet:
        return 'pH Air Outlet';
      case SensorType.temperatureOutlet:
        return 'Suhu Air Outlet';
    }
  }
}

class SensorModel {
  final String id;
  final String name;
  final SensorType type;
  final SensorLocation location;
  final String unit;
  final double currentValue;
  final DateTime lastUpdated;
  final SensorStatus status;
  final double minThreshold;
  final double maxThreshold;
  final String hardwareSpec;
  final String pinConnection;
  final String description;
  final double calibrationOffset;
  final List<SensorReadingModel> readings;
  final String healthStatus;
  final DateTime? lastTested;
  final String? lastTestResult;

  SensorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.unit,
    required this.currentValue,
    required this.lastUpdated,
    required this.status,
    required this.minThreshold,
    required this.maxThreshold,
    required this.hardwareSpec,
    required this.pinConnection,
    required this.description,
    this.calibrationOffset = 0.0,
    required this.readings,
    this.healthStatus = 'Optimal (98%)',
    this.lastTested,
    this.lastTestResult,
  });

  // Calculate statistics from readings
  double get minValue {
    if (readings.isEmpty) return currentValue;
    return readings.map((r) => r.value).reduce((a, b) => a < b ? a : b);
  }

  double get maxValue {
    if (readings.isEmpty) return currentValue;
    return readings.map((r) => r.value).reduce((a, b) => a > b ? a : b);
  }

  double get avgValue {
    if (readings.isEmpty) return currentValue;
    final sum = readings.map((r) => r.value).reduce((a, b) => a + b);
    return sum / readings.length;
  }

  SensorModel copyWith({
    String? id,
    String? name,
    SensorType? type,
    SensorLocation? location,
    String? unit,
    double? currentValue,
    DateTime? lastUpdated,
    SensorStatus? status,
    double? minThreshold,
    double? maxThreshold,
    String? hardwareSpec,
    String? pinConnection,
    String? description,
    double? calibrationOffset,
    List<SensorReadingModel>? readings,
    String? healthStatus,
    DateTime? lastTested,
    String? lastTestResult,
  }) {
    return SensorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      unit: unit ?? this.unit,
      currentValue: currentValue ?? this.currentValue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      hardwareSpec: hardwareSpec ?? this.hardwareSpec,
      pinConnection: pinConnection ?? this.pinConnection,
      description: description ?? this.description,
      calibrationOffset: calibrationOffset ?? this.calibrationOffset,
      readings: readings ?? this.readings,
      healthStatus: healthStatus ?? this.healthStatus,
      lastTested: lastTested ?? this.lastTested,
      lastTestResult: lastTestResult ?? this.lastTestResult,
    );
  }
}
