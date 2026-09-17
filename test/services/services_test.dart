import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sitako_mobile/models/index.dart';
import 'package:sitako_mobile/services/index.dart';
import 'package:sitako_mobile/utils/api_client.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    test('login successfully parses user and token', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'token': 'mock-jwt-token',
                'user': {
                  'id': 'usr-123',
                  'nama': 'Siswa Teladan',
                  'nis': '2024001',
                  'email': 'siswa@sitako.sch.id',
                  'telepon': '081234567890',
                  'role': 'Anggota',
                  'status_aktif': true,
                },
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final authService = AuthService(apiClient: apiClient);

      final result = await authService.login(
        identifier: '2024001',
        password: 'password123',
        captcha: 'ABCD',
      );

      expect(result['token'], equals('mock-jwt-token'));
      expect(result['user'], isA<User>());
      final user = result['user'] as User;
      expect(user.nama, equals('Siswa Teladan'));
      expect(user.nis, equals('2024001'));
    });

    test('getProfile returns User model', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/profile/me') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'id': 'usr-123',
                'nama': 'Profil Siswa',
                'nis': '2024001',
                'email': 'profil@sitako.sch.id',
                'telepon': '081234567890',
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final authService = AuthService(apiClient: apiClient);

      final user = await authService.getProfile();
      expect(user.nama, equals('Profil Siswa'));
      expect(user.nis, equals('2024001'));
    });

    test('updateProfile sends updated fields and returns updated User', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/profile/me' && request.method == 'PUT') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'id': 'usr-123',
                'nama': body['nama'] ?? 'Profil Siswa',
                'nis': '2024001',
                'email': body['email'] ?? 'profil@sitako.sch.id',
                'telepon': body['telepon'] ?? '081234567890',
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final authService = AuthService(apiClient: apiClient);

      final updated = await authService.updateProfile(
        nama: 'Nama Baru',
        email: 'baru@sitako.sch.id',
      );

      expect(updated.nama, equals('Nama Baru'));
      expect(updated.email, equals('baru@sitako.sch.id'));
    });

    test('fetchCaptcha returns captcha SVG string', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/captcha') {
          return http.Response('<svg>captcha</svg>', 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final authService = AuthService(apiClient: apiClient);

      final captcha = await authService.fetchCaptcha();
      expect(captcha, equals('<svg>captcha</svg>'));
    });
  });

  group('BookService', () {
    test('getBooks sends query parameters and returns parsed Book list', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/book') {
          expect(request.url.queryParameters['search'], equals('laskar'));
          expect(request.url.queryParameters['bookType'], equals('Fiksi'));

          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': [
                {
                  'id': 'b-1',
                  'judul': 'Laskar Pelangi',
                  'penulis': 'Andrea Hirata',
                  'isbn': '978-979-3062-79-2',
                  'penerbit': 'Bentang Pustaka',
                  'genre': ['Fiksi'],
                  'tipeBuku': 'Fisik',
                  'jumlahStok': 5,
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final bookService = BookService(apiClient: apiClient);

      final books = await bookService.getBooks(
        search: 'laskar',
        bookType: 'Fiksi',
      );

      expect(books.length, equals(1));
      expect(books.first, isA<Book>());
      expect(books.first.judul, equals('Laskar Pelangi'));
      expect(books.first.penulis, equals('Andrea Hirata'));
    });

    test('getBookDetail returns full book detail', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/book/detail/b-1') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'id': 'b-1',
                'judul': 'Laskar Pelangi',
                'penulis': 'Andrea Hirata',
                'isbn': '978-979-3062-79-2',
                'penerbit': 'Bentang Pustaka',
                'genre': ['Fiksi'],
                'tipeBuku': 'Digital',
                'jumlahStok': 1,
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = BookService(apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api'));
      final book = await service.getBookDetail('b-1');

      expect(book?.id, equals('b-1'));
      expect(book?.isDigital, isTrue);
    });

    test('getBookmarks returns bookmark list', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/library/bookmark') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': [
                {
                  'id': 'bm-1',
                  'bukuId': 'b-1',
                  'buku': {'judul': 'Laskar Pelangi', 'penulis': 'Andrea Hirata'},
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = BookService(apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api'));
      final bookmarks = await service.getBookmarks();

      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.title, equals('Laskar Pelangi'));
    });

    test('addBookmark and deleteBookmark succeed', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/library/bookmark/b-1' && request.method == 'POST') {
          return http.Response(jsonEncode({'status': 'success', 'data': {'id': 'bm-new'}}), 201);
        }
        if (request.url.path == '/api/member/library/bookmark/delete/b-1' && request.method == 'DELETE') {
          return http.Response(jsonEncode({'status': 'success'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = BookService(apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api'));
      expect(await service.addBookmark('b-1'), isTrue);
      expect(await service.deleteBookmark('b-1'), isTrue);
    });

    test('readDigitalBook returns digital book content URL or payload', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/library/digital/read/b-1') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {'file': 'https://storage.sitako.sch.id/ebooks/b-1.pdf'},
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = BookService(apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api'));
      final readData = await service.readDigitalBook('b-1');

      expect(readData, equals('https://storage.sitako.sch.id/ebooks/b-1.pdf'));
    });
  });



  group('TransactionService', () {
    test('getMemberTransactions sends status and returns parsed Transaction list', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/transactions/') {
          expect(request.url.queryParameters['status'], equals('Dipinjam'));

          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': [
                {
                  'id': 'trx-1',
                  'kdTransaksi': 'TRX-001',
                  'status': 'Dipinjam',
                  'namaAnggota': 'Ahmad Fauzi',
                  'judulBuku': 'Laskar Pelangi',
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final transactionService = TransactionService(apiClient: apiClient);

      final list = await transactionService.getMemberTransactions(
        status: 'Dipinjam',
      );

      expect(list.length, equals(1));
      expect(list.first, isA<Transaction>());
      expect(list.first.kdTransaksi, equals('TRX-001'));
      expect(list.first.status, equals('Dipinjam'));
    });

    test('requestBorrowing sends payload and returns Transaction', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/transactions/borrow' && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['bukuId'], equals('bk-1'));
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'id': 'trx-new',
                'kdTransaksi': 'TRX-REQ-001',
                'bukuId': 'bk-1',
                'status': 'Menunggu Persetujuan',
                'judulBuku': 'Flutter Mastery',
              },
            }),
            201,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = TransactionService(apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api'));
      final trx = await service.requestBorrowing(
        bookId: 'bk-1',
        borrowDays: 7,
        notes: 'Keperluan riset',
      );

      expect(trx.id, equals('trx-new'));
      expect(trx.status, equals('Menunggu Persetujuan'));
    });

    test('requestReturn sends payload and returns ReturnTransactionResult', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/transactions/trx-1/return' && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'denda': 5000,
                'terlambatHari': 1,
                'pesan': 'Buku berhasil dikembalikan',
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = TransactionService(apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api'));
      final result = await service.requestReturn(
        transactionId: 'trx-1',
        notes: 'Kondisi baik',
      );

      expect(result.fineAmount, equals(5000));
      expect(result.daysLate, equals(1));
      expect(result.message, equals('Buku berhasil dikembalikan'));
    });
  });

  group('FineService', () {
    test('getMemberFines returns fine payment history list', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/fine-payment' ||
            request.url.path == '/api/member/fines') {
          return http.Response(

            jsonEncode({
              'status': 'success',
              'data': [
                {
                  'id': 'fn-100',
                  'kdTransaksi': 'TRX-FN-100',
                  'judulBuku': 'Clean Architecture',
                  'nominal': 10000,
                  'status': 'Lunas',
                  'metodeBayar': 'Transfer Bank',
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = FineService(apiClient: ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api'));
      final fines = await service.getMemberFines();

      expect(fines.length, equals(1));
      expect(fines.first.id, equals('fn-100'));
      expect(fines.first.amount, equals(10000));
      expect(fines.first.isPaid, isTrue);
      expect(fines.first.paymentMethod, equals('Transfer Bank'));
    });
  });

  group('DashboardService', () {
    test('getDashboardData parses stats, active loans, and bookmarks', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/member/dashboard') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'statistik': {
                  'bukuDipinjam': 2,
                  'totalDenda': 5000,
                  'totalBookmark': 3,
                },
                'transaksiAktif': [
                  {
                    'id': 'trx-1',
                    'kdTransaksi': 'TRX-001',
                    'status': 'Dipinjam',
                    'judulBuku': 'Laskar Pelangi',
                  },
                ],
                'bookmarkTerbaru': [
                  {
                    'id': 'bm-1',
                    'buku': {'judul': 'Bumi Manusia'},
                  },
                ],
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final dashboardService = DashboardService(apiClient: apiClient);

      final data = await dashboardService.getDashboardData();

      expect(data['statistik']['bukuDipinjam'], equals(2));
      expect(data['statistik']['totalDenda'], equals(5000));
      expect(data['transaksiAktif'].length, equals(1));
      expect(data['bookmarkTerbaru'].length, equals(1));
    });
  });
}

