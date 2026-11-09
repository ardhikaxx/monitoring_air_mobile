enum SensorStatus {
  normal,
  warning,
  critical,
  offline;

  String get label {
    switch (this) {
      case SensorStatus.normal:
        return 'Normal';
      case SensorStatus.warning:
        return 'Warning';
      case SensorStatus.critical:
        return 'Critical';
      case SensorStatus.offline:
        return 'Offline';
    }
  }
}

class SensorReadingModel {
  final DateTime timestamp;
  final double value;
  final SensorStatus status;

  SensorReadingModel({
    required this.timestamp,
    required this.value,
    this.status = SensorStatus.normal,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'status': status.name,
    };
  }

  factory SensorReadingModel.fromMap(Map<String, dynamic> map) {
    return SensorReadingModel(
      timestamp: DateTime.parse(map['timestamp']),
      value: (map['value'] as num).toDouble(),
      status: SensorStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SensorStatus.normal,
      ),
    );
  }
}
