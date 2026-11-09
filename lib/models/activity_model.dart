enum ActivityType {
  success,
  warning,
  critical,
  info;

  String get label {
    switch (this) {
      case ActivityType.success:
        return 'Sukses';
      case ActivityType.warning:
        return 'Peringatan';
      case ActivityType.critical:
        return 'Kritis';
      case ActivityType.info:
        return 'Informasi';
    }
  }
}

class ActivityModel {
  final String id;
  final String title;
  final String description;
  final String? sensorId;
  final DateTime timestamp;
  final ActivityType type;
  final bool isRead;

  ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    this.sensorId,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  ActivityModel copyWith({
    String? id,
    String? title,
    String? description,
    String? sensorId,
    DateTime? timestamp,
    ActivityType? type,
    bool? isRead,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sensorId: sensorId ?? this.sensorId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
