import 'package:intl/intl.dart';

/// Format angka ke format Rupiah: 15000 → "Rp 15.000"
String formatCurrency(int amount) {
  final formatter = NumberFormat('#,###', 'id_ID');
  return 'Rp ${formatter.format(amount)}';
}

/// Format tanggal ke format Indonesia: "03 Mei 2026"
String formatDate(DateTime date) {
  final formatter = DateFormat('dd MMM yyyy', 'id_ID');
  return formatter.format(date);
}

/// Format tanggal dengan waktu: "03 Mei 2026, 14:30"
String formatDateTime(DateTime date) {
  final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  return formatter.format(date);
}
