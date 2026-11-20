import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= 900;

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor ?? C.border),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 4))],
        ),
        child: child,
      );
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip(this.label, this.color, {super.key});
  factory StatusChip.of(DeviceStatus s) => StatusChip(s.label, s.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
      );
}

class DemoBadge extends StatelessWidget {
  final String text;
  const DemoBadge({super.key, this.text = 'DEMO MODE'});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: C.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: C.orange),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.science, size: 13, color: C.orange),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: C.orange, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ]),
      );
}

class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const StatCard(this.label, this.value, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Panel(
        borderColor: color.withValues(alpha: 0.45),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: C.muted, fontSize: 12), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            ]),
          ),
        ]),
      );
}

class PageHeader extends StatelessWidget {
  final String title, subtitle;
  final Widget? trailing;
  const PageHeader(this.title, this.subtitle, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(subtitle, style: const TextStyle(color: C.muted, fontSize: 13)),
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

Widget kv(String k, String v, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(k, style: const TextStyle(color: C.muted, fontSize: 13))),
        Expanded(child: Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
      ]),
    );
