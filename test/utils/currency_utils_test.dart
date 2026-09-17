import 'package:flutter_test/flutter_test.dart';
import 'package:sitako_mobile/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils', () {
    group('formatRupiah', () {
      test('formats positive integer to Indonesian Rupiah currency format', () {
        final result = formatRupiah(50000);
        expect(result.replaceAll(RegExp(r'\s'), ' '), equals('Rp 50.000'));
      });

      test('formats zero value correctly', () {
        final result = formatRupiah(0);
        expect(result.replaceAll(RegExp(r'\s'), ' '), equals('Rp 0'));
      });

      test('formats numeric string to Rupiah format', () {
        final result = formatRupiah('125000');
        expect(result.replaceAll(RegExp(r'\s'), ' '), equals('Rp 125.000'));
      });

      test('returns fallback value when input is null', () {
        expect(formatRupiah(null), equals('Rp 0'));
        expect(formatRupiah(null, fallback: '-'), equals('-'));
      });

      test('returns fallback when input is invalid or NaN', () {
        expect(formatRupiah('not_a_number'), equals('Rp 0'));
        expect(formatRupiah('abc', fallback: 'Invalid'), equals('Invalid'));
        expect(formatRupiah(''), equals('Rp 0'));
      });
    });

    group('parseRupiah', () {
      test('parses formatted Rupiah string to numeric value', () {
        expect(parseRupiah('Rp 50.000'), equals(50000));
        expect(parseRupiah('Rp 1.500.000'), equals(1500000));
      });

      test('parses decimal commas when present', () {
        expect(parseRupiah('Rp 25.000,50'), equals(25000.5));
      });

      test('returns 0 when string contains no digits or is null', () {
        expect(parseRupiah('Rp -'), equals(0));
        expect(parseRupiah('abc'), equals(0));
        expect(parseRupiah(''), equals(0));
        expect(parseRupiah(null), equals(0));
      });
    });
  });
}
