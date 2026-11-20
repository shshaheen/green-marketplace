import 'package:intl/intl.dart';

/// Display formatting for money and dates (Indian locale).
abstract final class Formatters {
  static final NumberFormat _rupees = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final NumberFormat _rupeesWithPaise = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, h:mm a');
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');

  /// 2500000 paise → "₹25,000"; 25050 → "₹250.50".
  static String inrFromPaise(int paise) {
    final rupees = paise / 100;
    return paise % 100 == 0 ? _rupees.format(rupees) : _rupeesWithPaise.format(rupees);
  }

  /// "12 Dec 2026"
  static String date(DateTime value) => _date.format(value.toLocal());

  /// "12 Dec 2026, 4:30 PM"
  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());

  /// "2026-12-12", the format the API expects for dates without time.
  static String apiDate(DateTime value) => _apiDate.format(value);

  /// "under_review" → "Under review"
  static String humanize(String value) {
    final words = value.replaceAll('_', ' ').trim();
    return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
  }
}
