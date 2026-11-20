import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _load();
  }

  final MapController mapController = MapController();
  final _rng = Random();

  List<Device> devices = [];
  List<AlertItem> alerts = [];
  List<EventLog> events = [];

  int navIndex = 0;
  String? selectedId;
  String simDeviceId = 'GSG-TB-001';
  DeviceStatus? filter;
  String query = '';
  bool autoSim = false;
  bool pendingFocus = false;
  AlertItem? banner;
  String? message;
  int _seq = 1005;
  Timer? _autoTimer, _bannerTimer;

  // settings (cosmetic for the demo)
  bool soundAlerts = true;
  bool smsNotify = true;
  bool showLabels = false;

  void _load() {
    devices = buildDevices();
    final seed = buildSeed(devices);
    alerts = seed.alerts;
    events = seed.events;
    _seq = 1005;
  }

  // ---------- derived ----------
  Device dev(String id) => devices.firstWhere((d) => d.id == id);
  Device? get selected => selectedId == null ? null : dev(selectedId!);
  int get total => devices.length;
  int get offline => devices.where((d) => d.status == DeviceStatus.offline).length;
  int get online => total - offline;
  int count(DeviceStatus s) => devices.where((d) => d.status == s).length;
  int get criticalAlerts => alerts.where((a) => a.open && a.critical).length;
  int get openAlerts => alerts.where((a) => a.open).length;
  int get resolvedCount => alerts.where((a) => !a.open).length;
  List<AlertItem> get activeCritical => alerts.where((a) => a.open && a.critical).toList();
  List<EventLog> historyFor(String id) => events.where((e) => e.deviceId == id).toList();

  List<Device> get filteredDevices {
    final q = query.trim().toLowerCase();
    return devices.where((d) {
      if (filter != null && d.status != filter) return false;
      if (q.isEmpty) return true;
      return d.id.toLowerCase().contains(q) ||
          d.city.toLowerCase().contains(q) ||
          d.district.toLowerCase().contains(q) ||
          d.address.toLowerCase().contains(q);
    }).toList();
  }

  // ---------- navigation / selection ----------
  void setNav(int i) {
    navIndex = i;
    notifyListeners();
  }

  void select(String? id) {
    selectedId = id;
    notifyListeners();
  }

  void focusOnMap(String id) {
    selectedId = id;
    navIndex = 1;
    pendingFocus = true;
    notifyListeners();
  }

  void consumeFocus() {
    pendingFocus = false;
    final d = selected;
    if (d == null) return;
    try {
      mapController.move(LatLng(d.lat, d.lng), 13);
    } catch (_) {}
  }

  void setFilter(DeviceStatus? f) {
    filter = f;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setSimDevice(String id) {
    simDeviceId = id;
    notifyListeners();
  }

  void clearMessage() => message = null;

  void toggleSetting(String key, bool v) {
    if (key == 'sound') soundAlerts = v;
    if (key == 'sms') smsNotify = v;
    if (key == 'labels') showLabels = v;
    notifyListeners();
  }

  // ---------- internals ----------
  void _log(Device d, String text) =>
      events.insert(0, EventLog(DateTime.now(), d.id, text, d.status));

  void _touch(Device d) => d.lastComm = DateTime.now();

  void _say(String m) {
    message = m;
  }

  AlertItem _openAlert(Device d, String severity) {
    final a = AlertItem(
      id: 'ALR-${_seq++}',
      deviceId: d.id,
      city: d.city,
      address: d.fullAddress,
      severity: severity,
      time: DateTime.now(),
    );
    alerts.insert(0, a);
    return a;
  }

  void _closeAlerts(Device d, {bool onlyCritical = false}) {
    for (final a in alerts) {
      if (a.deviceId == d.id && a.open && (!onlyCritical || a.critical)) {
        a.status = AlertStatus.resolved;
        a.resolvedAt = DateTime.now();
      }
    }
  }

  void _showBanner(AlertItem a) {
    banner = a;
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 9), dismissBanner);
  }

  void dismissBanner() {
    banner = null;
    notifyListeners();
  }

  // ---------- simulation actions ----------
  void simulateLeak([String? id]) {
    final d = dev(id ?? simDeviceId);
    if (d.status == DeviceStatus.critical) {
      _say('${d.id} is already CRITICAL');
      notifyListeners();
      return;
    }
    d.status = DeviceStatus.critical;
    _touch(d);
    _closeAlerts(d);
    final a = _openAlert(d, 'CRITICAL');
    _log(d, 'GAS LEAK DETECTED — methane above 20% LEL (SIMULATED)');
    _showBanner(a);
    notifyListeners();
  }

  void simulateOffline([String? id]) {
    final d = dev(id ?? simDeviceId);
    d.status = DeviceStatus.offline;
    _closeAlerts(d, onlyCritical: false);
    _log(d, 'Connection lost — device OFFLINE (SIMULATED)');
    _say('${d.id} set to OFFLINE');
    notifyListeners();
  }

  void simulateWarning(Device d) {
    d.status = DeviceStatus.warning;
    d.battery = min(d.battery, 14 + _rng.nextInt(6));
    _touch(d);
    _openAlert(d, 'WARNING');
    _log(d, 'Low battery warning ${d.battery}% (SIMULATED)');
    notifyListeners();
  }

  void restoreDevice([String? id]) {
    final d = dev(id ?? simDeviceId);
    d.status = DeviceStatus.normal;
    if (d.battery < 20) d.battery = 80;
    _touch(d);
    _closeAlerts(d);
    _log(d, 'Device restored to NORMAL (SIMULATED)');
    _say('${d.id} restored to NORMAL');
    notifyListeners();
  }

  void resolveAlert(AlertItem a) {
    if (!a.open) return;
    a.status = AlertStatus.resolved;
    a.resolvedAt = DateTime.now();
    final d = dev(a.deviceId);
    if (!alerts.any((x) => x.deviceId == d.id && x.open && x.critical) &&
        d.status == DeviceStatus.critical) {
      d.status = DeviceStatus.normal;
    }
    if (a.severity == 'WARNING' && d.status == DeviceStatus.warning) {
      d.status = DeviceStatus.normal;
    }
    _touch(d);
    _log(d, 'Incident ${a.id} resolved');
    if (banner?.id == a.id) banner = null;
    notifyListeners();
  }

  void acknowledge(AlertItem a) {
    if (a.status != AlertStatus.active) return;
    a.status = AlertStatus.acknowledged;
    _log(dev(a.deviceId), 'Alert ${a.id} acknowledged by operator');
    if (banner?.id == a.id) banner = null;
    notifyListeners();
  }

  /// Resolves the active incident of the selected sim device, else the latest one.
  void resolveIncident() {
    final open = alerts.where((a) => a.open).toList();
    if (open.isEmpty) {
      _say('No active incident to resolve');
      notifyListeners();
      return;
    }
    final target = open.firstWhere((a) => a.deviceId == simDeviceId,
        orElse: () => open.firstWhere((a) => a.critical, orElse: () => open.first));
    _say('${target.id} resolved');
    resolveAlert(target);
  }

  void resetDemo() {
    stopAuto();
    _bannerTimer?.cancel();
    banner = null;
    selectedId = null;
    filter = null;
    query = '';
    simDeviceId = 'GSG-TB-001';
    _load();
    _say('Demo data reset');
    notifyListeners();
  }

  // ---------- auto simulation ----------
  void toggleAuto(bool on) {
    on ? _startAuto() : stopAuto();
    notifyListeners();
  }

  void _startAuto() {
    autoSim = true;
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) => _randomEvent());
  }

  void stopAuto() {
    autoSim = false;
    _autoTimer?.cancel();
  }

  void _randomEvent() {
    final r = _rng.nextInt(100);
    Device pick(bool Function(Device) f) {
      final c = devices.where(f).toList();
      return c.isEmpty ? devices[_rng.nextInt(devices.length)] : c[_rng.nextInt(c.length)];
    }

    if (r < 25) {
      final d = pick((d) => d.status == DeviceStatus.normal);
      simulateLeak(d.id);
    } else if (r < 45) {
      simulateWarning(pick((d) => d.status == DeviceStatus.normal));
    } else if (r < 60) {
      simulateOffline(pick((d) => d.status == DeviceStatus.normal).id);
    } else if (r < 80) {
      restoreDevice(pick((d) => d.status == DeviceStatus.offline || d.status == DeviceStatus.warning).id);
    } else {
      final open = alerts.where((a) => a.open).toList();
      if (open.isNotEmpty) resolveAlert(open[_rng.nextInt(open.length)]);
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _bannerTimer?.cancel();
    super.dispose();
  }
}
