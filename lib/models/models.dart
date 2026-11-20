import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DeviceStatus { normal, critical, warning, offline }

extension DeviceStatusX on DeviceStatus {
  String get label => name.toUpperCase();
  Color get color => switch (this) {
        DeviceStatus.normal => C.green,
        DeviceStatus.critical => C.red,
        DeviceStatus.warning => C.orange,
        DeviceStatus.offline => C.gray,
      };
}

class Device {
  final String id, city, district, address;
  final double lat, lng;
  DeviceStatus status;
  int battery;
  DateTime lastComm;

  Device({
    required this.id,
    required this.city,
    required this.district,
    required this.address,
    required this.lat,
    required this.lng,
    this.status = DeviceStatus.normal,
    this.battery = 100,
    required this.lastComm,
  });

  String get connection => status == DeviceStatus.offline
      ? 'Disconnected'
      : 'LoRaWAN · ${battery < 20 ? 'weak' : 'strong'} signal';
  String get fullAddress => '$address, $district, $city';
}

enum AlertStatus { active, acknowledged, resolved }

class AlertItem {
  final String id, deviceId, city, address, severity;
  final DateTime time;
  AlertStatus status;
  DateTime? resolvedAt;
  final bool simulated;

  AlertItem({
    required this.id,
    required this.deviceId,
    required this.city,
    required this.address,
    required this.severity,
    required this.time,
    this.status = AlertStatus.active,
    this.resolvedAt,
    this.simulated = true,
  });

  bool get open => status != AlertStatus.resolved;
  bool get critical => severity == 'CRITICAL';
  Color get color => critical ? C.red : C.orange;
}

class EventLog {
  final DateTime time;
  final String deviceId, text;
  final DeviceStatus status;
  EventLog(this.time, this.deviceId, this.text, this.status);
}
