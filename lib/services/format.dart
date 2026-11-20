String two(int n) => n.toString().padLeft(2, '0');

String fmtTime(DateTime t) => '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';

String fmtDateTime(DateTime t) =>
    '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';

String ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return '${d.inSeconds < 0 ? 0 : d.inSeconds}s ago';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  return '${d.inDays} d ago';
}
