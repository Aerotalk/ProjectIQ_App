import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy h:mm a');

  static String formatCurrency(dynamic amount) {
    if (amount == null) return _currencyFormat.format(0);
    if (amount is num) return _currencyFormat.format(amount);
    if (amount is String) {
      final parsed = double.tryParse(amount.replaceAll(RegExp(r'[^0-9.-]'), ''));
      return _currencyFormat.format(parsed ?? 0);
    }
    return _currencyFormat.format(0);
  }

  static String formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is DateTime) return _dateFormat.format(date);
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return _dateFormat.format(parsed);
    }
    return date.toString();
  }

  static String formatDateTime(dynamic date) {
    if (date == null) return '-';
    if (date is DateTime) return _dateTimeFormat.format(date);
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return _dateTimeFormat.format(parsed);
    }
    return date.toString();
  }
}
