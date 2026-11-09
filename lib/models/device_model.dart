enum DeviceConnectionStatus {
  online,
  unstable,
  offline;

  String get label {
    switch (this) {
      case DeviceConnectionStatus.online:
        return 'Online';
      case DeviceConnectionStatus.unstable:
        return 'Unstable';
      case DeviceConnectionStatus.offline:
        return 'Offline';
    }
  }
}

class DeviceModel {
  final String name;
  final String deviceId;
  final DeviceConnectionStatus status;
  final String ipAddress;
  final String wifiSsid;
  final int wifiRssi; // in dBm, e.g. -62
  final String firmwareVersion;
  final Duration uptime;
  final DateTime lastSync;
  final double flowRate; // in L/jam
  final double totalProcessedVolume; // in Liters

  DeviceModel({
    required this.name,
    required this.deviceId,
    required this.status,
    required this.ipAddress,
    required this.wifiSsid,
    required this.wifiRssi,
    required this.firmwareVersion,
    required this.uptime,
    required this.lastSync,
    required this.flowRate,
    required this.totalProcessedVolume,
  });

  int get signalPercentage {
    if (status == DeviceConnectionStatus.offline) return 0;
    // Map -100 dBm (0%) to -50 dBm (100%)
    if (wifiRssi <= -100) return 0;
    if (wifiRssi >= -50) return 100;
    return (2 * (wifiRssi + 100)).clamp(0, 100);
  }

  String get formattedUptime {
    final days = uptime.inDays;
    final hours = uptime.inHours % 24;
    final minutes = uptime.inMinutes % 60;
    final seconds = uptime.inSeconds % 60;
    if (days > 0) {
      return '${days}h ${hours}j ${minutes}m';
    }
    return '${hours}j ${minutes}m ${seconds}s';
  }

  DeviceModel copyWith({
    String? name,
    String? deviceId,
    DeviceConnectionStatus? status,
    String? ipAddress,
    String? wifiSsid,
    int? wifiRssi,
    String? firmwareVersion,
    Duration? uptime,
    DateTime? lastSync,
    double? flowRate,
    double? totalProcessedVolume,
  }) {
    return DeviceModel(
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiRssi: wifiRssi ?? this.wifiRssi,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      uptime: uptime ?? this.uptime,
      lastSync: lastSync ?? this.lastSync,
      flowRate: flowRate ?? this.flowRate,
      totalProcessedVolume: totalProcessedVolume ?? this.totalProcessedVolume,
    );
  }
}
