import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('inrFromPaise uses Indian grouping and hides zero paise', () {
      expect(Formatters.inrFromPaise(25000), '₹250');
      expect(Formatters.inrFromPaise(2500000), '₹25,000');
      expect(Formatters.inrFromPaise(123456700), '₹12,34,567');
      expect(Formatters.inrFromPaise(25050), '₹250.50');
      expect(Formatters.inrFromPaise(0), '₹0');
    });

    test('dates', () {
      final date = DateTime(2026, 12, 5, 16, 30);
      expect(Formatters.date(date), '5 Dec 2026');
      expect(Formatters.dateTime(date), '5 Dec 2026, 4:30 PM');
      expect(Formatters.apiDate(date), '2026-12-05');
    });

    test('humanize', () {
      expect(Formatters.humanize('under_review'), 'Under review');
      expect(Formatters.humanize(''), '');
    });
  });
}
