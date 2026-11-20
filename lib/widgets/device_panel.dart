import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/format.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class DevicePanel extends StatelessWidget {
  final Device device;
  final bool showMapButton;
  final VoidCallback? onClose;
  const DevicePanel({super.key, required this.device, this.showMapButton = true, this.onClose});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final d = device;
    final history = s.historyFor(d.id);
    return Panel(
      borderColor: d.status.color.withValues(alpha: 0.6),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Icon(Icons.sensors, color: d.status.color),
            const SizedBox(width: 8),
            Expanded(child: Text(d.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            StatusChip.of(d.status),
            if (onClose != null) IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 18)),
          ]),
          const SizedBox(height: 8),
          if (d.status == DeviceStatus.critical)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: C.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('⚠ GAS LEAK DETECTED — dispatch emergency team',
                  style: TextStyle(color: C.red, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          kv('Address', d.address),
          kv('District', d.district),
          kv('City', d.city),
          kv('Coordinates', '${d.lat.toStringAsFixed(4)}, ${d.lng.toStringAsFixed(4)}'),
          kv('Connection', d.connection),
          kv('Last comm.', '${fmtTime(d.lastComm)} (${ago(d.lastComm)})'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              const SizedBox(width: 110, child: Text('Battery', style: TextStyle(color: C.muted, fontSize: 13))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: d.battery / 100,
                    minHeight: 8,
                    backgroundColor: C.border,
                    color: d.battery < 20 ? C.orange : C.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${d.battery}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: C.red),
              onPressed: () => s.simulateLeak(d.id),
              icon: const Icon(Icons.local_fire_department, size: 16),
              label: const Text('Simulate leak'),
            ),
            OutlinedButton(onPressed: () => s.simulateOffline(d.id), child: const Text('Offline')),
            OutlinedButton(onPressed: () => s.restoreDevice(d.id), child: const Text('Restore')),
            if (showMapButton)
              OutlinedButton.icon(
                onPressed: () => s.focusOnMap(d.id),
                icon: const Icon(Icons.map, size: 16),
                label: const Text('View on map'),
              ),
          ]),
          const SizedBox(height: 14),
          const Text('EVENT HISTORY',
              style: TextStyle(color: C.muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 6),
          if (history.isEmpty) const Text('No events recorded', style: TextStyle(color: C.muted, fontSize: 13)),
          for (final e in history.take(8))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, right: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: e.status.color, shape: BoxShape.circle),
                ),
                Expanded(child: Text(e.text, style: const TextStyle(fontSize: 12.5))),
                const SizedBox(width: 6),
                Text(fmtDateTime(e.time), style: const TextStyle(color: C.muted, fontSize: 11)),
              ]),
            ),
        ]),
      ),
    );
  }
}

void showDeviceDialog(BuildContext context, Device d) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: ChangeNotifierProvider.value(
          value: context.read<AppState>(),
          child: DevicePanel(device: d, onClose: () => Navigator.pop(context)),
        ),
      ),
    ),
  );
}
