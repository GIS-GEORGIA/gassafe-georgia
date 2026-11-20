import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/alert_tile.dart';
import '../widgets/common.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final open = s.alerts.where((a) => a.open).toList();
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader('Alerts', '${open.length} open · ${s.alerts.length - open.length} resolved'),
            if (open.isEmpty)
              const Panel(child: Center(child: Text('No open alerts — all clear ✔'))),
            for (final a in open) AlertTile(a),
          ]),
        ),
      ),
    );
  }
}
