import 'package:intl/intl.dart';

String fmtDateTime(DateTime dt) {
  return DateFormat('dd/MM/yyyy - HH:mm:ss').format(dt.toLocal());
}
