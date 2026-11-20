import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/format.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_tile.dart';
import '../widgets/common.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final done = s.alerts.where((a) => !a.open).toList();
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader('Incident history', '${done.length} resolved incidents'),
            if (done.isEmpty) const Panel(child: Text('No resolved incidents yet')),
            for (final a in done) ...[
              AlertTile(a, actions: false),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 12, top: -4),
                child: Row(children: [
                  const Icon(Icons.check_circle, size: 14, color: C.green),
                  const SizedBox(width: 6),
                  Text(
                    'Resolved ${fmtDateTime(a.resolvedAt!)} · response ${a.resolvedAt!.difference(a.time).inMinutes} min',
                    style: const TextStyle(color: C.muted, fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton(onPressed: () => s.focusOnMap(a.deviceId), child: const Text('View on map')),
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
