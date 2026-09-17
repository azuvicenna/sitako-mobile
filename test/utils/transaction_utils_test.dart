import 'package:flutter_test/flutter_test.dart';
import 'package:sitako_mobile/utils/transaction_utils.dart';

void main() {
  group('TransactionUtils', () {
    test('maps Dipinjam status to warning variant', () {
      expect(getStatusBadgeVariant('Dipinjam'), equals(TransactionBadgeVariant.warning));
      expect(getStatusBadgeVariant('Dipinjam').name, equals('warning'));
    });

    test('maps Dikembalikan status to success variant', () {
      expect(getStatusBadgeVariant('Dikembalikan'), equals(TransactionBadgeVariant.success));
      expect(getStatusBadgeVariant('Dikembalikan').name, equals('success'));
    });

    test('maps Terlambat and Tidak Mengembalikan status to danger variant', () {
      expect(getStatusBadgeVariant('Terlambat'), equals(TransactionBadgeVariant.danger));
      expect(getStatusBadgeVariant('Tidak Mengembalikan'), equals(TransactionBadgeVariant.danger));
    });

    test('maps Menunggu Persetujuan and Menunggu Diambil status to info variant', () {
      expect(getStatusBadgeVariant('Menunggu Persetujuan'), equals(TransactionBadgeVariant.info));
      expect(getStatusBadgeVariant('Menunggu Diambil'), equals(TransactionBadgeVariant.info));
    });

    test('maps Dibatalkan or unknown status to neutral variant', () {
      expect(getStatusBadgeVariant('Dibatalkan'), equals(TransactionBadgeVariant.neutral));
      expect(getStatusBadgeVariant('Unknown_Status'), equals(TransactionBadgeVariant.neutral));
      expect(getStatusBadgeVariant(null), equals(TransactionBadgeVariant.neutral));
    });

    test('returns valid accent, background, and text colors for each status', () {
      final statuses = [
        'Dipinjam',
        'Dikembalikan',
        'Terlambat',
        'Tidak Mengembalikan',
        'Menunggu Persetujuan',
        'Menunggu Diambil',
        'Dibatalkan',
      ];

      for (final status in statuses) {
        expect(getStatusColor(status), isNotNull);
        expect(getStatusBackgroundColor(status), isNotNull);
        expect(getStatusTextColor(status), isNotNull);
      }
    });

    test('getStatusLabel returns cleaned string or fallback when null', () {
      expect(TransactionUtils.getStatusLabel('Dipinjam'), equals('Dipinjam'));
      expect(TransactionUtils.getStatusLabel(null), equals('-'));
      expect(TransactionUtils.getStatusLabel('   '), equals('-'));
    });
  });
}
