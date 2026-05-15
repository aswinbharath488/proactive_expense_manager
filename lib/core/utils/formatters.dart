import 'package:intl/intl.dart';

String formatInr(num value, {int maxFractionDigits = 0}) {
  final fmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: maxFractionDigits,
  );
  return fmt.format(value);
}

String formatOrdinalDate(DateTime d) {
  final day = d.day;
  String suffix = 'th';
  if (day % 10 == 1 && day != 11) {
    suffix = 'st';
  } else if (day % 10 == 2 && day != 12) {
    suffix = 'nd';
  } else if (day % 10 == 3 && day != 13) {
    suffix = 'rd';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '$day$suffix ${months[d.month - 1]} ${d.year}';
}

String maskPhone(String e164) {
  final d = e164.replaceAll(RegExp(r'\D'), '');
  if (d.length < 10) return e164;
  final local = d.length > 10 ? d.substring(d.length - 10) : d;
  return '${local.substring(0, 4)}****${local.substring(8)}';
}
