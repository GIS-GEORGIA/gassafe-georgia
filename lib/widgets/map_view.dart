import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'device_panel.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final desktop = isDesktop(context);
    if (s.pendingFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => s.consumeFocus());
    }
    final list = [...s.filteredDevices]
      ..sort((a, b) => (a.status == DeviceStatus.critical ? 1 : 0).compareTo(b.status == DeviceStatus.critical ? 1 : 0));

    final map = Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FlutterMap(
          mapController: s.mapController,
          options: MapOptions(
            initialCenter: const LatLng(42.0, 43.6),
            initialZoom: 7.3,
            minZoom: 5,
            maxZoom: 18,
            backgroundColor: const Color(0xFF0B1630),
            onTap: (_, _) => s.select(null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'ge.gassafe.demo',
            ),
            MarkerLayer(markers: [
              for (final d in list)
                Marker(
                  point: LatLng(d.lat, d.lng),
                  width: 70,
                  height: 70,
                  child: _DeviceMarker(device: d, selected: s.selectedId == d.id, label: s.showLabels),
                ),
            ]),
            const RichAttributionWidget(
              attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
            ),
          ],
        ),
      ),
      // top controls
      Positioned(
        left: 12,
        right: 12,
        top: 12,
        child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SizedBox(
            width: 250,
            height: 42,
            child: TextField(
              onChanged: s.setQuery,
              onSubmitted: (_) {
                final m = s.filteredDevices;
                if (m.isNotEmpty) s.focusOnMap(m.first.id);
              },
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search ID, city, address…',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: C.surface.withValues(alpha: 0.95),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.border)),
              ),
            ),
          ),
          _chip(s, null, 'All', C.accent),
          _chip(s, DeviceStatus.normal, 'Normal', C.green),
          _chip(s, DeviceStatus.critical, 'Critical', C.red),
          _chip(s, DeviceStatus.warning, 'Warning', C.orange),
          _chip(s, DeviceStatus.offline, 'Offline', C.gray),
        ]),
      ),
      // zoom
      Positioned(
        right: 12,
        bottom: desktop ? 28 : 12,
        child: Column(children: [
          _zoomBtn(Icons.add, () => _zoom(s, 1)),
          const SizedBox(height: 6),
          _zoomBtn(Icons.remove, () => _zoom(s, -1)),
          const SizedBox(height: 6),
          _zoomBtn(Icons.my_location, () {
            s.mapController.move(const LatLng(42.0, 43.6), 7.3);
          }),
        ]),
      ),
      // legend
      Positioned(
        left: 12,
        bottom: 12,
        child: Panel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (final st in DeviceStatus.values) ...[
              Container(width: 10, height: 10, decoration: BoxDecoration(color: st.color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('${st.label} ${s.count(st)}', style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 12),
            ],
            const DemoBadge(text: 'SIMULATED DATA'),
          ]),
        ),
      ),
    ]);

    final sel = s.selected;
    if (desktop) {
      return Row(children: [
        Expanded(child: map),
        if (sel != null) ...[
          const SizedBox(width: 14),
          SizedBox(width: 370, child: DevicePanel(key: ValueKey(sel.id), device: sel, showMapButton: false, onClose: () => s.select(null))),
        ],
      ]);
    }
    return Stack(children: [
      map,
      if (sel != null)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
            child: DevicePanel(key: ValueKey(sel.id), device: sel, showMapButton: false, onClose: () => s.select(null)),
          ),
        ),
    ]);
  }

  void _zoom(AppState s, double delta) {
    final cam = s.mapController.camera;
    s.mapController.move(cam.center, (cam.zoom + delta).clamp(5, 18));
  }

  Widget _zoomBtn(IconData i, VoidCallback f) => Material(
        color: C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: C.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: f,
          child: SizedBox(width: 40, height: 40, child: Icon(i, size: 20)),
        ),
      );

  Widget _chip(AppState s, DeviceStatus? st, String label, Color color) {
    final on = s.filter == st;
    final n = st == null ? s.total : s.count(st);
    return GestureDetector(
      onTap: () => s.setFilter(st),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? color : C.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? color : C.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Text('$label · $n', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: on ? Colors.white : C.text))]),
      ),
    );
  }
}

class _DeviceMarker extends StatefulWidget {
  final Device device;
  final bool selected, label;
  const _DeviceMarker({required this.device, required this.selected, required this.label});
  @override
  State<_DeviceMarker> createState() => _DeviceMarkerState();
}

class _DeviceMarkerState extends State<_DeviceMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _DeviceMarker old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.device.status == DeviceStatus.critical) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.device;
    final color = d.status.color;
    final crit = d.status == DeviceStatus.critical;
    return GestureDetector(
      onTap: () => context.read<AppState>().select(d.id),
      child: Stack(alignment: Alignment.center, children: [
        if (crit)
          AnimatedBuilder(
            animation: _c,
            builder: (_, _) => Container(
              width: 24 + 46 * _c.value,
              height: 24 + 46 * _c.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.45 * (1 - _c.value)),
              ),
            ),
          ),
        Container(
          width: crit ? 30 : 24,
          height: crit ? 30 : 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: widget.selected ? Colors.white : Colors.white70, width: widget.selected ? 3 : 2),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: crit ? 14 : 6)],
          ),
          child: Icon(crit ? Icons.warning_amber_rounded : Icons.sensors, size: crit ? 18 : 14, color: Colors.white),
        ),
        if (widget.label)
          Positioned(
            bottom: 2,
            child: Text(d.id.substring(4), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, shadows: [Shadow(blurRadius: 3)])),
          ),
      ]),
    );
  }
}
