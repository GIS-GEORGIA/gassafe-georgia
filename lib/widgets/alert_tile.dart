import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/format.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class AlertTile extends StatelessWidget {
  final AlertItem alert;
  final bool actions;
  const AlertTile(this.alert, {super.key, this.actions = true});

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final a = alert;
    final stColor = switch (a.status) {
      AlertStatus.active => C.red,
      AlertStatus.acknowledged => C.orange,
      AlertStatus.resolved => C.green,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: a.color, width: 4), top: const BorderSide(color: C.border), right: const BorderSide(color: C.border), bottom: const BorderSide(color: C.border)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(a.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          StatusChip(a.severity, a.color),
          StatusChip(a.status.name.toUpperCase(), stColor),
          const DemoBadge(text: 'SIMULATED'),
        ]),
        const SizedBox(height: 8),
        Text('${a.deviceId} · ${a.city}', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(a.address, style: const TextStyle(color: C.muted, fontSize: 13)),
        const SizedBox(height: 2),
        Text('${fmtDateTime(a.time)} · ${ago(a.time)}', style: const TextStyle(color: C.muted, fontSize: 12)),
        if (actions) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (a.status == AlertStatus.active)
              FilledButton(onPressed: () => s.acknowledge(a), child: const Text('Acknowledge')),
            if (a.open)
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: C.green),
                onPressed: () => s.resolveAlert(a),
                child: const Text('Resolve'),
              ),
            OutlinedButton.icon(
              onPressed: () => s.focusOnMap(a.deviceId),
              icon: const Icon(Icons.map, size: 16),
              label: const Text('View on map'),
            ),
          ]),
        ],
      ]),
    );
  }
}
