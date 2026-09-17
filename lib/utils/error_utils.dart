import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(
    this.message, {
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class ErrorUtils {
  ErrorUtils._();

  static String getErrorMessage(
    Object? error, {
    String fallback = 'Terjadi kesalahan pada sistem',
  }) {
    if (error == null) return fallback;

    if (error is String) {
      final trimmed = error.trim();
      return trimmed.isNotEmpty ? trimmed : fallback;
    }

    if (error is ApiException) {
      return error.message.isNotEmpty ? error.message : fallback;
    }

    if (error is http.Response) {
      return _extractFromHttpResponse(error, fallback);
    }

    if (error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }

    if (error is TimeoutException) {
      return 'Batas waktu koneksi berakhir. Silakan coba kembali.';
    }

    if (error is FormatException) {
      return 'Format data dari server tidak valid.';
    }

    if (error is HttpException) {
      return error.message.isNotEmpty ? error.message : 'Terjadi gangguan jaringan.';
    }

    if (error is Map) {
      final message = error['message'] ?? error['error'] ?? error['msg'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
      return fallback;
    }

    if (error is Exception) {
      final raw = error.toString();
      final cleaned = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      return cleaned.trim().isNotEmpty ? cleaned.trim() : fallback;
    }

    if (error is Error) {
      final raw = error.toString();
      return raw.trim().isNotEmpty ? raw.trim() : fallback;
    }

    return fallback;
  }

  static String _extractFromHttpResponse(http.Response response, String fallback) {
    if (response.body.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final message = decoded['message'] ?? decoded['error'] ?? decoded['msg'];
          if (message != null && message.toString().trim().isNotEmpty) {
            return message.toString().trim();
          }
        }
      } catch (_) {}
    }

    if (response.statusCode == 401) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (response.statusCode == 403) {
      return 'Anda tidak memiliki akses untuk tindakan ini (403)';
    } else if (response.statusCode == 404) {
      return 'Data atau layanan tidak ditemukan (404)';
    } else if (response.statusCode >= 500) {
      return 'Terjadi masalah pada server (${response.statusCode})';
    }

    if (response.body.isNotEmpty && response.body.length < 200) {
      return response.body.trim();
    }

    return fallback;
  }
}

String getErrorMessage(
  Object? error, {
  String fallback = 'Terjadi kesalahan pada sistem',
}) =>
    ErrorUtils.getErrorMessage(error, fallback: fallback);
