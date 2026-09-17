import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String _normalizeFormatPattern(String pattern) {
    return pattern
        .replaceAll('YYYY', 'yyyy')
        .replaceAll('YY', 'yy')
        .replaceAll('DD', 'dd');
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }
    return null;
  }

  static String formatDate(
    dynamic date, {
    String format = 'dd/MM/yyyy',
    String fallback = '-',
    String locale = 'id_ID',
  }) {
    final parsed = parseDateTime(date);
    if (parsed == null) return fallback;

    final normalizedPattern = _normalizeFormatPattern(format);
    try {
      final formatter = DateFormat(normalizedPattern, locale);
      return formatter.format(parsed);
    } catch (_) {
      try {
        final fallbackFormatter = DateFormat(normalizedPattern);
        return fallbackFormatter.format(parsed);
      } catch (_) {
        return fallback;
      }
    }
  }

  static String formatDateTime(
    dynamic date, {
    String format = 'dd/MM/yyyy HH:mm',
    String fallback = '-',
    String locale = 'id_ID',
  }) {
    return formatDate(
      date,
      format: format,
      fallback: fallback,
      locale: locale,
    );
  }

  static String formatRelativeTime(
    dynamic date, {
    String fallback = '-',
    DateTime? relativeTo,
  }) {
    final parsed = parseDateTime(date);
    if (parsed == null) return fallback;

    final now = relativeTo ?? DateTime.now();
    final difference = now.difference(parsed);

    if (difference.isNegative) {
      final futureDiff = parsed.difference(now);
      final seconds = futureDiff.inSeconds;
      final minutes = futureDiff.inMinutes;
      final hours = futureDiff.inHours;
      final days = futureDiff.inDays;

      if (seconds < 60) {
        return 'segera';
      } else if (minutes < 60) {
        return 'dalam $minutes menit';
      } else if (hours < 24) {
        return 'dalam $hours jam';
      } else if (days == 1) {
        return 'besok';
      } else if (days < 30) {
        return 'dalam $days hari';
      } else if (days < 365) {
        final months = (days / 30).floor();
        return 'dalam $months bulan';
      } else {
        final years = (days / 365).floor();
        return 'dalam $years tahun';
      }
    }

    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (seconds < 45) {
      return 'baru saja';
    } else if (minutes < 45) {
      return '$minutes menit yang lalu';
    } else if (hours < 24) {
      return '$hours jam yang lalu';
    } else if (days == 1) {
      return '1 hari yang lalu';
    } else if (days < 30) {
      return '$days hari yang lalu';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months bulan yang lalu';
    } else {
      final years = (days / 365).floor();
      return '$years tahun yang lalu';
    }
  }
}

String formatDate(
  dynamic date, {
  String format = 'dd/MM/yyyy',
  String fallback = '-',
  String locale = 'id_ID',
}) =>
    AppDateUtils.formatDate(
      date,
      format: format,
      fallback: fallback,
      locale: locale,
    );

String formatDateTime(
  dynamic date, {
  String format = 'dd/MM/yyyy HH:mm',
  String fallback = '-',
  String locale = 'id_ID',
}) =>
    AppDateUtils.formatDateTime(
      date,
      format: format,
      fallback: fallback,
      locale: locale,
    );

String formatRelativeTime(
  dynamic date, {
  String fallback = '-',
  DateTime? relativeTo,
}) =>
    AppDateUtils.formatRelativeTime(
      date,
      fallback: fallback,
      relativeTo: relativeTo,
    );
