import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/format.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final d = s.dev(s.simDeviceId);

    Widget big(String label, IconData icon, Color color, VoidCallback f) => SizedBox(
          width: 230,
          height: 56,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            onPressed: f,
            icon: Icon(icon),
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        );

    final controls = Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Expanded(child: Text('Scenario controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          DemoBadge(text: 'DEMO / SIMULATED'),
        ]),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: s.simDeviceId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Target device', border: OutlineInputBorder()),
          items: [
            for (final x in s.devices)
              DropdownMenuItem(value: x.id, child: Text('${x.id} · ${x.city}, ${x.district}  [${x.status.label}]', overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => v == null ? null : s.setSimDevice(v),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text('Current status: ', style: const TextStyle(color: C.muted)),
          StatusChip.of(d.status),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          big('SIMULATE GAS LEAK', Icons.local_fire_department, C.red, s.simulateLeak),
          big('DEVICE OFFLINE', Icons.wifi_off, C.gray, s.simulateOffline),
          big('RESTORE DEVICE', Icons.restore, C.green, s.restoreDevice),
          big('RESOLVE INCIDENT', Icons.verified, C.accent, s.resolveIncident),
          big('RESET DEMO', Icons.refresh, C.orange, s.resetDemo),
        ]),
        const Divider(height: 32),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: s.autoSim,
          onChanged: s.toggleAuto,
          title: const Text('Automatic simulation mode', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Random leak / warning / offline / restore events every 4 seconds'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => s.focusOnMap(s.simDeviceId),
          icon: const Icon(Icons.map),
          label: const Text('Show target on live map'),
        ),
      ]),
    );

    final log = Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Event history', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final e in s.events.take(14))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(margin: const EdgeInsets.only(top: 5, right: 8), width: 8, height: 8, decoration: BoxDecoration(color: e.status.color, shape: BoxShape.circle)),
              Expanded(child: Text('${e.deviceId} — ${e.text}', style: const TextStyle(fontSize: 12.5))),
              const SizedBox(width: 6),
              Text(fmtTime(e.time), style: const TextStyle(color: C.muted, fontSize: 11)),
            ]),
          ),
      ]),
    );

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader('Simulation Center', 'Trigger events and watch every screen update'),
        if (isDesktop(context))
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: controls),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: log),
          ])
        else ...[controls, const SizedBox(height: 14), log],
      ]),
    );
  }
}
