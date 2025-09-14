/// Utilitários de formatação de data/hora (sem pacotes externos).
String _two(int n) => n.toString().padLeft(2, '0');

/// Retorna `DD/MM/AAAA - HH:MM:SS` no horário local.
String fmtDateTime(DateTime dt) {
  final d = dt.toLocal();
  final dd = _two(d.day);
  final mm = _two(d.month);
  final yyyy = d.year.toString().padLeft(4, '0');
  final hh = _two(d.hour);
  final mi = _two(d.minute);
  final ss = _two(d.second);
  return '$dd/$mm/$yyyy - $hh:$mi:$ss';
}
