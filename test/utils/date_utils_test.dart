import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sitako_mobile/utils/date_utils.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('DateUtils', () {
    group('formatDate', () {
      test('formats ISO date string to default dd/MM/yyyy', () {
        final result = formatDate('2026-09-17T08:30:00.000Z');
        expect(result, matches(r'^\d{2}/\d{2}/\d{4}$'));
        expect(result, equals('17/09/2026'));
      });

      test('formats date using custom format pattern', () {
        final result = formatDate('2026-09-17', format: 'dd MMMM yyyy');
        expect(result, equals('17 September 2026'));
      });

      test('supports web format tokens such as DD MMMM YYYY', () {
        final result = formatDate('2026-09-17', format: 'DD MMMM YYYY');
        expect(result, equals('17 September 2026'));
      });

      test('returns fallback value when date is null', () {
        expect(formatDate(null), equals('-'));
        expect(formatDate(null, format: 'yyyy-MM-dd', fallback: 'Empty'), equals('Empty'));
      });

      test('returns fallback value when date string is invalid', () {
        expect(formatDate('invalid_date_string'), equals('-'));
      });
    });

    group('formatDateTime', () {
      test('formats date with hours and minutes', () {
        final dateTime = DateTime(2026, 9, 17, 14, 30);
        final result = formatDateTime(dateTime);
        expect(result, equals('17/09/2026 14:30'));
      });

      test('returns fallback when date is null', () {
        expect(formatDateTime(null), equals('-'));
      });
    });

    group('formatRelativeTime', () {
      test('returns relative time for past dates', () {
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        final result = formatRelativeTime(oneHourAgo, relativeTo: now);
        expect(result, contains('yang lalu'));
      });

      test('returns "baru saja" for recent timestamps', () {
        final now = DateTime.now();
        final tenSecondsAgo = now.subtract(const Duration(seconds: 10));
        final result = formatRelativeTime(tenSecondsAgo, relativeTo: now);
        expect(result, equals('baru saja'));
      });

      test('returns relative time for future dates', () {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1, minutes: 5));
        final result = formatRelativeTime(tomorrow, relativeTo: now);
        expect(result, equals('besok'));
      });

      test('returns fallback when date is invalid or null', () {
        expect(formatRelativeTime(null), equals('-'));
        expect(formatRelativeTime('invalid-date'), equals('-'));
      });
    });
  });
}
