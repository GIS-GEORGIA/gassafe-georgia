import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'alerts_screen.dart';
import 'dashboard_screen.dart';
import 'devices_screen.dart';
import 'incidents_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import 'simulation_screen.dart';

const navItems = <(IconData, String)>[
  (Icons.dashboard_outlined, 'Dashboard'),
  (Icons.map_outlined, 'Live Map'),
  (Icons.notifications_active_outlined, 'Alerts'),
  (Icons.sensors, 'Devices'),
  (Icons.history, 'Incidents'),
  (Icons.science_outlined, 'Simulation Center'),
  (Icons.settings_outlined, 'Settings'),
];

const _pages = <Widget>[
  DashboardScreen(),
  MapScreen(),
  AlertsScreen(),
  DevicesScreen(),
  IncidentsScreen(),
  SimulationScreen(),
  SettingsScreen(),
];

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final desktop = isDesktop(context);
    if (s.message != null) {
      final m = s.message!;
      s.clearMessage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text('$m  ·  DEMO'),
            behavior: SnackBarBehavior.floating,
            width: 380,
            duration: const Duration(seconds: 2),
          ));
      });
    }
    return Scaffold(
      drawer: desktop ? null : Drawer(child: SafeArea(child: const _Nav(inDrawer: true))),
      body: Stack(children: [
        Row(children: [
          if (desktop) SizedBox(width: 240, child: _Nav()),
          Expanded(
            child: Column(children: [
              const _TopBar(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(desktop ? 20 : 12),
                  child: _pages[s.navIndex],
                ),
              ),
            ]),
          ),
        ]),
        if (s.banner != null) const Positioned(top: 8, left: 0, right: 0, child: Center(child: _CriticalBanner())),
      ]),
    );
  }
}

class _Nav extends StatelessWidget {
  final bool inDrawer;
  const _Nav({this.inDrawer = false});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Container(
      decoration: const BoxDecoration(color: C.surface, border: Border(right: BorderSide(color: C.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.local_fire_department, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GasSafe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('GEORGIA · NATIONAL GRID', style: TextStyle(fontSize: 9, color: C.muted, letterSpacing: 1)),
            ]),
          ]),
        ),
        for (var i = 0; i < navItems.length; i++)
          _item(context, s, i),
        const Spacer(),
        const Padding(padding: EdgeInsets.all(20), child: DemoBadge()),
      ]),
    );
  }

  Widget _item(BuildContext context, AppState s, int i) {
    final on = s.navIndex == i;
    final badge = i == 2 ? s.openAlerts : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: on ? C.accent.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            s.setNav(i);
            if (inDrawer) Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(children: [
              Icon(navItems[i].$1, size: 20, color: on ? C.accent : C.muted),
              const SizedBox(width: 12),
              Expanded(child: Text(navItems[i].$2, style: TextStyle(fontWeight: FontWeight.w600, color: on ? Colors.white : C.muted))),
              if (badge > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(10)),
                  child: Text('$badge', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final desktop = isDesktop(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(color: C.surface, border: Border(bottom: BorderSide(color: C.border))),
      child: Row(children: [
        if (!desktop)
          Builder(builder: (c) => IconButton(onPressed: () => Scaffold.of(c).openDrawer(), icon: const Icon(Icons.menu))),
        Text(navItems[s.navIndex].$2, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const Spacer(),
        if (s.autoSim)
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Row(children: [
              Icon(Icons.autorenew, size: 16, color: C.green),
              SizedBox(width: 4),
              Text('AUTO-SIM', style: TextStyle(color: C.green, fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          ),
        if (desktop) const DemoBadge(),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () => s.setNav(2),
          icon: Badge(
            isLabelVisible: s.criticalAlerts > 0,
            backgroundColor: C.red,
            label: Text('${s.criticalAlerts}'),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      ]),
    );
  }
}

class _CriticalBanner extends StatelessWidget {
  const _CriticalBanner();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final a = s.banner;
    if (a == null) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      key: ValueKey(a.id),
      tween: Tween(begin: -1, end: 0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.translate(offset: Offset(0, v * 80), child: child),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF7A0F1B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.red, width: 2),
          boxShadow: [BoxShadow(color: C.red.withValues(alpha: 0.6), blurRadius: 30)],
        ),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('CRITICAL — GAS LEAK DETECTED · ${a.id}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
              Text('${a.deviceId} · ${a.address}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Text('DEMO / SIMULATED EVENT', style: TextStyle(color: C.orange, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ]),
          ),
          TextButton(
            onPressed: () {
              s.dismissBanner();
              s.focusOnMap(a.deviceId);
            },
            child: const Text('VIEW MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          IconButton(onPressed: s.dismissBanner, icon: const Icon(Icons.close, color: Colors.white70, size: 18)),
        ]),
      ),
    );
  }
}
