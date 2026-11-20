import '../models/models.dart';

class _Spec {
  final String code, city, district, address;
  final double lat, lng;
  final DeviceStatus status;
  final int battery;
  const _Spec(this.code, this.city, this.district, this.address, this.lat,
      this.lng, this.battery,
      [this.status = DeviceStatus.normal]);
}

const _specs = <_Spec>[
  _Spec('TB', 'Tbilisi', 'Saburtalo', 'Vazha-Pshavela Ave 45, Apt 12', 41.7270, 44.7510, 91),
  _Spec('TB', 'Tbilisi', 'Vake', 'Chavchavadze Ave 28, Apt 7', 41.7090, 44.7660, 84),
  _Spec('TB', 'Tbilisi', 'Vera', 'Barnov St 14, Apt 3', 41.7020, 44.7950, 77),
  _Spec('TB', 'Tbilisi', 'Isani', 'Samgori Rd 9, Apt 21', 41.6930, 44.8660, 69),
  _Spec('TB', 'Tbilisi', 'Gldani', 'Gldani 3rd Micro 12, Apt 40', 41.7960, 44.8160, 58, DeviceStatus.critical),
  _Spec('TB', 'Tbilisi', 'Didube', 'Tsereteli Ave 71, Apt 5', 41.7560, 44.7810, 95),
  _Spec('TB', 'Tbilisi', 'Nadzaladevi', 'Kakheti Hwy 30, Apt 18', 41.7550, 44.8030, 88),
  _Spec('TB', 'Tbilisi', 'Old Tbilisi', 'Shardeni St 6, Apt 2', 41.6925, 44.8105, 73),
  _Spec('BT', 'Batumi', 'Old Boulevard', 'Gorgiladze St 20, Apt 9', 41.6500, 41.6330, 18, DeviceStatus.warning),
  _Spec('BT', 'Batumi', 'New Boulevard', 'Chavchavadze St 5, Apt 31', 41.6290, 41.6080, 90),
  _Spec('BT', 'Batumi', 'Gonio Road', 'Khimshiashvili St 11, Apt 4', 41.6290, 41.6350, 82),
  _Spec('BT', 'Batumi', 'Bagrationi', 'Rustaveli Ave 34, Apt 15', 41.6440, 41.6370, 79),
  _Spec('BT', 'Batumi', 'Airport District', 'Tamar Mepe Ave 2, Apt 8', 41.6020, 41.6150, 66),
  _Spec('KT', 'Kutaisi', 'Center', 'Tsereteli St 12, Apt 6', 42.2700, 42.6950, 93),
  _Spec('KT', 'Kutaisi', 'Avtokarkhana', 'Chavchavadze Ave 90, Apt 22', 42.2560, 42.7180, 71),
  _Spec('KT', 'Kutaisi', 'Gelati Road', 'Gelati St 3, Apt 1', 42.2780, 42.7120, 12, DeviceStatus.offline),
  _Spec('KT', 'Kutaisi', 'Balakhvani', 'Mshvidoba Ave 19, Apt 10', 42.2620, 42.6770, 85),
  _Spec('RS', 'Rustavi', 'Center', 'Meskheti St 4, Apt 14', 41.5495, 45.0145, 87),
  _Spec('RS', 'Rustavi', 'Micro-district 3', 'Kostava Ave 21, Apt 33', 41.5400, 45.0300, 64),
  _Spec('RS', 'Rustavi', 'Old Rustavi', 'Aghmashenebeli St 8, Apt 5', 41.5600, 45.0000, 76),
  _Spec('GR', 'Gori', 'Center', 'Chavchavadze St 8, Apt 11', 41.9842, 44.1158, 92),
  _Spec('GR', 'Gori', 'Nikoladze', 'Nikoladze St 27, Apt 2', 41.9780, 44.1100, 81),
  _Spec('GR', 'Gori', 'Kutaisi Street', 'Kutaisi St 15, Apt 9', 41.9900, 44.1250, 15, DeviceStatus.warning),
  _Spec('ZG', 'Zugdidi', 'Center', 'Rustaveli St 17, Apt 6', 42.5088, 41.8709, 89),
  _Spec('ZG', 'Zugdidi', 'Dadiani', 'Dadiani St 4, Apt 12', 42.5120, 41.8650, 74),
  _Spec('ZG', 'Zugdidi', 'Anaklia Road', 'Tavisupleba Ave 33, Apt 3', 42.5030, 41.8800, 10, DeviceStatus.offline),
  _Spec('TL', 'Telavi', 'Center', 'Erekle II Sq 6, Apt 4', 41.9198, 45.4731, 83),
  _Spec('TL', 'Telavi', 'Kvareli Road', 'Tsinandali St 10, Apt 1', 41.9250, 45.4600, 78),
  _Spec('PT', 'Poti', 'Port District', 'Rustaveli St 22, Apt 8', 42.1462, 41.6719, 86),
  _Spec('PT', 'Poti', 'Center', 'Aghmashenebeli St 13, Apt 5', 42.1500, 41.6760, 72),
];

List<Device> buildDevices() {
  final now = DateTime.now();
  final counters = <String, int>{};
  return [
    for (var i = 0; i < _specs.length; i++)
      () {
        final s = _specs[i];
        final n = counters.update(s.code, (v) => v + 1, ifAbsent: () => 1);
        return Device(
          id: 'GSG-${s.code}-${n.toString().padLeft(3, '0')}',
          city: s.city,
          district: s.district,
          address: s.address,
          lat: s.lat,
          lng: s.lng,
          status: s.status,
          battery: s.battery,
          lastComm: s.status == DeviceStatus.offline
              ? now.subtract(Duration(hours: 3 + i))
              : now.subtract(Duration(seconds: 5 + (i * 7) % 50)),
        );
      }(),
  ];
}

class SeedData {
  final List<AlertItem> alerts;
  final List<EventLog> events;
  SeedData(this.alerts, this.events);
}

SeedData buildSeed(List<Device> d) {
  final now = DateTime.now();
  Device dev(String id) => d.firstWhere((x) => x.id == id);
  AlertItem a(String id, String dId, String sev, Duration ago,
      {AlertStatus st = AlertStatus.resolved, Duration? took}) {
    final x = dev(dId);
    final t = now.subtract(ago);
    return AlertItem(
      id: id,
      deviceId: dId,
      city: x.city,
      address: x.fullAddress,
      severity: sev,
      time: t,
      status: st,
      resolvedAt: st == AlertStatus.resolved ? t.add(took ?? const Duration(minutes: 22)) : null,
      simulated: true,
    );
  }

  final alerts = [
    a('ALR-1004', 'GSG-TB-005', 'CRITICAL', const Duration(minutes: 3), st: AlertStatus.active),
    a('ALR-1003', 'GSG-BT-001', 'WARNING', const Duration(hours: 5), st: AlertStatus.active),
    a('ALR-1002', 'GSG-RS-002', 'CRITICAL', const Duration(days: 1, hours: 4), took: const Duration(minutes: 17)),
    a('ALR-1001', 'GSG-KT-003', 'CRITICAL', const Duration(days: 3), took: const Duration(minutes: 41)),
    a('ALR-1000', 'GSG-TB-002', 'CRITICAL', const Duration(days: 6, hours: 2), took: const Duration(minutes: 28)),
  ];
  final events = <EventLog>[
    for (final al in alerts.reversed) ...[
      EventLog(al.time, al.deviceId,
          '${al.severity} — ${al.critical ? 'gas concentration above threshold' : 'low battery'} (SIMULATED)',
          al.critical ? DeviceStatus.critical : DeviceStatus.warning),
      if (al.resolvedAt != null)
        EventLog(al.resolvedAt!, al.deviceId, 'Incident resolved, device back to NORMAL', DeviceStatus.normal),
    ],
  ]..sort((x, y) => y.time.compareTo(x.time));
  return SeedData(alerts, events);
}
