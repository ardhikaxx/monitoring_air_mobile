enum NotificationType {
  success,
  warning,
  critical,
  info;

  String get label {
    switch (this) {
      case NotificationType.success:
        return 'Sukses';
      case NotificationType.warning:
        return 'Peringatan';
      case NotificationType.critical:
        return 'Kritis';
      case NotificationType.info:
        return 'Informasi';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? sensorId;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.sensorId,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? sensorId,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      sensorId: sensorId ?? this.sensorId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
