import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MockData {
  MockData._();

  static const String captchaSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="150" height="50"><rect width="100%" height="100%" fill="#f3f4f6"/><text x="25" y="32" font-size="22" font-family="monospace" fill="#374151">ABCD</text></svg>';

  static const Map<String, dynamic> loginMemberJson = {
    'success': true,
    'message': 'Login berhasil. Selamat datang kembali!',
    'data': {
      'token': 'mock-jwt-token-member-12345',
      'user': {
        'id': 'mem-001',
        'nama': 'Budi Santoso',
        'email': 'budi.santoso@siswa.sch.id',
        'telepon': '081298765432',
        'foto': null,
        'status_aktif': true,
        'createdAt': '2025-07-15T09:30:00.000Z',
        'nis': '20251001',
        'role': 'Anggota',
      },
    },
  };

  static const Map<String, dynamic> userMemberJson = {
    'success': true,
    'data': {
      'id': 'mem-001',
      'nama': 'Budi Santoso',
      'email': 'budi.santoso@siswa.sch.id',
      'telepon': '081298765432',
      'foto': null,
      'status_aktif': true,
      'createdAt': '2025-07-15T09:30:00.000Z',
      'nis': '20251001',
      'role': 'Anggota',
    },
  };

  static const Map<String, dynamic> dashboardMemberJson = {
    'success': true,
    'message': 'Data dashboard anggota berhasil dimuat',
    'data': {
      'statistik': {
        'bukuDipinjam': 2,
        'totalDenda': 5000,
        'totalBookmark': 4,
      },
      'transaksiAktif': [
        {
          'id': 'mem-tx-01',
          'kdTransaksi': 'TRX-20260910-001',
          'buku': {
            'id': 'bk-01',
            'judul': 'Laskar Pelangi',
          },
          'judulBuku': 'Laskar Pelangi',
          'tglPinjam': '2026-09-10',
          'tglKembali': '2026-09-17',
          'status': 'Dipinjam',
        },
      ],
      'tagihanDenda': [
        {
          'transaksiId': 'mem-tx-02',
          'judulBuku': 'Bumi Manusia',
          'keterlambatanHari': 5,
          'totalDenda': 5000,
          'checkoutUrl': null,
        },
      ],
      'bookmarkTerbaru': [
        {
          'id': 'bm-01',
          'bukuId': 'bk-02',
          'judulBuku': 'Clean Code',
          'penulis': 'Robert C. Martin',
          'cover': null,
        },
      ],
    },
  };

  static const Map<String, dynamic> catalogMemberJson = {
    'success': true,
    'message': 'Katalog buku berhasil dimuat',
    'data': [
      {
        'id': 'bk-01',
        'judul': 'Laskar Pelangi',
        'penulis': 'Andrea Hirata',
        'penerbit': 'Bentang Pustaka',
        'isbn': '9789793062792',
        'genre': ['Fiksi', 'Pendidikan'],
        'tipeBuku': 'Fisik',
        'tahunTerbit': 2005,
        'jumlahStok': 15,
        'cover': null,
        'file': null,
      },
      {
        'id': 'bk-02',
        'judul': 'Clean Code',
        'penulis': 'Robert C. Martin',
        'penerbit': 'Prentice Hall',
        'isbn': '9780132350884',
        'genre': ['Teknologi', 'Pemrograman'],
        'tipeBuku': 'Digital',
        'tahunTerbit': 2008,
        'jumlahStok': 0,
        'cover': null,
        'file': 'https://example.com/books/clean-code.pdf',
      },
    ],
    'pagination': {
      'page': 1,
      'limit': 12,
      'totalItems': 2,
      'totalPages': 1,
      'hasNext': false,
      'hasPrev': false,
    },
  };

  static const Map<String, dynamic> borrowingsMemberJson = {
    'success': true,
    'message': 'Daftar peminjaman anggota berhasil dimuat',
    'data': [
      {
        'id': 'mem-tx-01',
        'kdTransaksi': 'TRX-20260910-001',
        'tglPinjam': '2026-09-10',
        'tglKembali': '2026-09-17',
        'status': 'Dipinjam',
        'namaAnggota': 'Budi Santoso',
        'namaPustakawan': 'Siti Rahma',
        'judulBuku': 'Laskar Pelangi',
        'bukuId': 'bk-01',
      },
    ],
    'meta': {
      'page': 1,
      'limit': 10,
      'totalRows': 1,
      'totalPages': 1,
      'hasNextPage': false,
      'hasPrevPage': false,
    },
  };

  static http.Client createMockClient() {
    return MockClient((http.Request request) async {
      final path = request.url.path;

      if (path.endsWith('/auth/captcha')) {
        return http.Response(captchaSvg, 200, headers: {'content-type': 'image/svg+xml'});
      }

      if (path.endsWith('/auth/login')) {
        try {
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          final identifier = payload['identifier']?.toString() ?? '';
          final password = payload['password']?.toString() ?? '';

          if (identifier == '20251001' && password == 'password123') {
            return http.Response(jsonEncode(loginMemberJson), 200, headers: {'content-type': 'application/json'});
          }

          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'NIS atau kata sandi yang Anda masukkan salah',
            }),
            401,
            headers: {'content-type': 'application/json'},
          );
        } catch (_) {
          return http.Response('{"message": "Invalid payload"}', 400);
        }
      }

      if (path.endsWith('/profile/me')) {
        return http.Response(jsonEncode(userMemberJson), 200, headers: {'content-type': 'application/json'});
      }

      if (path.endsWith('/member/dashboard')) {
        return http.Response(jsonEncode(dashboardMemberJson), 200, headers: {'content-type': 'application/json'});
      }

      if (path.contains('/book')) {
        return http.Response(jsonEncode(catalogMemberJson), 200, headers: {'content-type': 'application/json'});
      }

      if (path.contains('/member/transactions')) {
        return http.Response(jsonEncode(borrowingsMemberJson), 200, headers: {'content-type': 'application/json'});
      }

      if (path.endsWith('/auth/logout')) {
        return http.Response(jsonEncode({'success': true, 'message': 'Logout berhasil'}), 200, headers: {'content-type': 'application/json'});
      }

      return http.Response('{"message": "Not Found"}', 404);
    });
  }
}
