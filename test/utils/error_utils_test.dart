import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sitako_mobile/utils/error_utils.dart';

void main() {
  group('ErrorUtils', () {
    test('extracts error message from http.Response with JSON data.message', () {
      final response = http.Response(
        '{"success": false, "message": "NIP sudah terdaftar di database"}',
        400,
      );

      final message = getErrorMessage(response);
      expect(message, equals('NIP sudah terdaftar di database'));
    });

    test('extracts message from http.Response with error key', () {
      final response = http.Response(
        '{"error": "Email atau password salah"}',
        401,
      );

      final message = getErrorMessage(response);
      expect(message, equals('Email atau password salah'));
    });

    test('handles standard HTTP status codes when response body is empty', () {
      final res401 = http.Response('', 401);
      expect(getErrorMessage(res401), equals('Sesi Anda telah berakhir. Silakan login kembali.'));

      final res404 = http.Response('', 404);
      expect(getErrorMessage(res404), equals('Data atau layanan tidak ditemukan (404)'));

      final res500 = http.Response('', 500);
      expect(getErrorMessage(res500), equals('Terjadi masalah pada server (500)'));
    });

    test('extracts message from ApiException', () {
      const apiException = ApiException('Stok buku telah habis', statusCode: 400);
      expect(getErrorMessage(apiException), equals('Stok buku telah habis'));
    });

    test('handles SocketException for disconnected network', () {
      const socketException = SocketException('Failed host lookup');
      expect(
        getErrorMessage(socketException),
        equals('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'),
      );
    });

    test('handles TimeoutException when request times out', () {
      final timeoutException = TimeoutException('Request timeout');
      expect(
        getErrorMessage(timeoutException),
        equals('Batas waktu koneksi berakhir. Silakan coba kembali.'),
      );
    });

    test('extracts message directly from Map', () {
      final errorMap = {'message': 'Buku sedang dipinjam'};
      expect(getErrorMessage(errorMap), equals('Buku sedang dipinjam'));
    });

    test('extracts message from general Exception object', () {
      final exception = Exception('Terjadi kesalahan lokal');
      expect(getErrorMessage(exception), equals('Terjadi kesalahan lokal'));
    });

    test('returns string value directly when error is String', () {
      expect(getErrorMessage('Pesan error dalam bentuk teks'), equals('Pesan error dalam bentuk teks'));
    });

    test('returns fallback value when error is null or unknown type', () {
      expect(getErrorMessage(null), equals('Terjadi kesalahan pada sistem'));
      expect(getErrorMessage(null, fallback: 'Failed to load'), equals('Failed to load'));
      expect(getErrorMessage(12345), equals('Terjadi kesalahan pada sistem'));
    });
  });
}
