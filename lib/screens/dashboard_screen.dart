import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/format.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_tile.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final desktop = isDesktop(context);
    final cards = [
      StatCard('Total devices', s.total, Icons.sensors, C.accent),
      StatCard('Online devices', s.online, Icons.wifi, C.green),
      StatCard('Offline devices', s.offline, Icons.wifi_off, C.gray),
      StatCard('Critical alerts', s.criticalAlerts, Icons.local_fire_department, C.red),
      StatCard('Resolved incidents', s.resolvedCount, Icons.verified_outlined, C.green),
    ];
    final recent = s.alerts.take(5).toList();

    final alertsPanel = Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Recent alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          TextButton(onPressed: () => s.setNav(2), child: const Text('View all')),
        ]),
        const SizedBox(height: 6),
        for (final a in recent) AlertTile(a),
      ]),
    );

    final side = Column(children: [
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Network status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final st in DeviceStatus.values) _bar(s, st),
        ]),
      ),
      const SizedBox(height: 14),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Live activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final e in s.events.take(7))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(margin: const EdgeInsets.only(top: 5, right: 8), width: 8, height: 8, decoration: BoxDecoration(color: e.status.color, shape: BoxShape.circle)),
                Expanded(child: Text('${e.deviceId} — ${e.text}', style: const TextStyle(fontSize: 12.5))),
                const SizedBox(width: 6),
                Text(fmtTime(e.time), style: const TextStyle(color: C.muted, fontSize: 11)),
              ]),
            ),
        ]),
      ),
    ]);

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader('National overview', 'Residential gas detector network · Georgia',
            trailing: desktop ? const DemoBadge(text: 'DEMO / SIMULATED DATA') : null),
        LayoutBuilder(builder: (_, c) {
          final cols = c.maxWidth >= 1100 ? 5 : (c.maxWidth >= 600 ? 3 : 2);
          final w = (c.maxWidth - 12 * (cols - 1)) / cols;
          return Wrap(spacing: 12, runSpacing: 12, children: [for (final x in cards) SizedBox(width: w, child: x)]);
        }),
        const SizedBox(height: 16),
        if (desktop)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: alertsPanel),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: side),
          ])
        else ...[alertsPanel, const SizedBox(height: 14), side],
      ]),
    );
  }

  Widget _bar(AppState s, DeviceStatus st) {
    final n = s.count(st);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        Row(children: [
          Text(st.label, style: TextStyle(color: st.color, fontSize: 12, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('$n', style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: n / s.total, minHeight: 7, backgroundColor: C.border, color: st.color),
        ),
      ]),
    );
  }
}
