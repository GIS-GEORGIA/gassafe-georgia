import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PageHeader('Settings', 'Operator preferences (demo — not persisted)'),
            Panel(
              child: Column(children: [
                SwitchListTile(
                  value: s.soundAlerts,
                  onChanged: (v) => s.toggleSetting('sound', v),
                  title: const Text('Audible critical alerts'),
                  subtitle: const Text('Play siren when a gas leak is detected'),
                ),
                SwitchListTile(
                  value: s.smsNotify,
                  onChanged: (v) => s.toggleSetting('sms', v),
                  title: const Text('SMS / push notifications'),
                  subtitle: const Text('Notify on-duty dispatcher'),
                ),
                SwitchListTile(
                  value: s.showLabels,
                  onChanged: (v) => s.toggleSetting('labels', v),
                  title: const Text('Show device labels on map'),
                ),
                const ListTile(
                  title: Text('Version'),
                  subtitle: Text('GasSafe Georgia · Demo build 0.1 · all data is fictional'),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
