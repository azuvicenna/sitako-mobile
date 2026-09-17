import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String formatRupiah(dynamic value, {String fallback = 'Rp 0'}) {
    if (value == null) return fallback;

    num? numericValue;
    if (value is num) {
      if (value.isNaN) return fallback;
      numericValue = value;
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return fallback;
      final parsed = num.tryParse(trimmed);
      if (parsed == null || parsed.isNaN) return fallback;
      numericValue = parsed;
    } else {
      return fallback;
    }

    try {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(numericValue).replaceAll('\u00a0', ' ').trim();
    } catch (_) {
      return fallback;
    }
  }

  static num parseRupiah(String? formatted) {
    if (formatted == null) return 0;
    final trimmed = formatted.trim();
    if (trimmed.isEmpty) return 0;

    final cleanNumber = trimmed
        .replaceAll(RegExp(r'[^0-9,-]'), '')
        .replaceAll(',', '.');

    if (cleanNumber.isEmpty || cleanNumber == '-') return 0;
    return num.tryParse(cleanNumber) ?? 0;
  }
}

String formatRupiah(dynamic value, {String fallback = 'Rp 0'}) =>
    CurrencyUtils.formatRupiah(value, fallback: fallback);

num parseRupiah(String? formatted) => CurrencyUtils.parseRupiah(formatted);
