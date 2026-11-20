import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/format.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/device_panel.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.filteredDevices;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader('Devices', '${list.length} of ${s.total} detectors'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final f in <DeviceStatus?>[null, ...DeviceStatus.values])
          ChoiceChip(
            label: Text(f == null ? 'All' : f.label),
            selected: s.filter == f,
            onSelected: (_) => s.setFilter(f),
          ),
      ]),
      const SizedBox(height: 12),
      Expanded(
        child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final d = list[i];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showDeviceDialog(context, d),
              child: Panel(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: d.status.color, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d.id, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('${d.address} · ${d.city}', style: const TextStyle(color: C.muted, fontSize: 12.5), overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  if (isDesktop(context)) ...[
                    Text('${d.battery}%', style: TextStyle(color: d.battery < 20 ? C.orange : C.text)),
                    const SizedBox(width: 20),
                    Text(ago(d.lastComm), style: const TextStyle(color: C.muted, fontSize: 12)),
                    const SizedBox(width: 20),
                  ],
                  StatusChip.of(d.status),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
