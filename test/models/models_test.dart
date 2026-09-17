import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitako_mobile/models/index.dart';
import 'package:sitako_mobile/utils/transaction_utils.dart';

void main() {

  group('User Model', () {
    test('parses User from JSON correctly', () {
      final json = {
        'id': 'usr-1',
        'nama': 'Ahmad Fauzi',
        'nis': '12345',
        'email': 'ahmad@example.com',
        'telepon': '08123456789',
        'foto': 'https://example.com/photo.jpg',
        'status_aktif': true,
        'role': 'Anggota',
        'createdAt': '2026-09-17T08:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('usr-1'));
      expect(user.nama, equals('Ahmad Fauzi'));
      expect(user.nis, equals('12345'));
      expect(user.email, equals('ahmad@example.com'));
      expect(user.telepon, equals('08123456789'));
      expect(user.foto, equals('https://example.com/photo.jpg'));
      expect(user.statusAktif, isTrue);
      expect(user.role, equals('Anggota'));
      expect(user.initials, equals('AF'));
      expect(user.avatarColor, isA<Color>());
      expect(user.createdAt, isNotNull);
    });

    test('serializes User to JSON correctly', () {
      const user = User(
        id: 'usr-2',
        nama: 'Suharto',
        nis: '67890',
        email: 'suharto@example.com',
        telepon: '08987654321',
        statusAktif: true,
      );

      final json = user.toJson();
      expect(json['id'], equals('usr-2'));
      expect(json['nama'], equals('Suharto'));
      expect(json['nis'], equals('67890'));
      expect(json['status_aktif'], isTrue);
    });

    test('copyWith updates specified fields', () {
      const user = User(
        id: 'usr-1',
        nama: 'Nama Lama',
        nis: '11111',
        email: 'old@example.com',
        telepon: '081',
      );

      final updated = user.copyWith(nama: 'Nama Baru', email: 'new@example.com');
      expect(updated.nama, equals('Nama Baru'));
      expect(updated.email, equals('new@example.com'));
      expect(updated.nis, equals('11111'));
    });

    test('English getters return expected properties', () {
      const user = User(
        id: 'usr-9',
        nama: 'English User',
        nis: '99999',
        email: 'eng@example.com',
        telepon: '0812999999',
        foto: 'https://img.example.com/avatar.png',
        statusAktif: true,
      );

      expect(user.name, equals('English User'));
      expect(user.phone, equals('0812999999'));
      expect(user.photo, equals('https://img.example.com/avatar.png'));
      expect(user.isActive, isTrue);
    });
  });


  group('Book Model', () {
    test('parses Book from JSON correctly', () {
      final json = {
        'id': 'bk-1',
        'judul': 'Laskar Pelangi',
        'penulis': 'Andrea Hirata',
        'isbn': '9789793062792',
        'penerbit': 'Bentang Pustaka',
        'genre': ['Fiksi', 'Drama'],
        'tipeBuku': 'Fisik',
        'tahunTerbit': 2005,
        'jumlahStok': 12,
        'cover': 'https://example.com/cover.jpg',
      };

      final book = Book.fromJson(json);

      expect(book.id, equals('bk-1'));
      expect(book.judul, equals('Laskar Pelangi'));
      expect(book.penulis, equals('Andrea Hirata'));
      expect(book.genre, containsAll(['Fiksi', 'Drama']));
      expect(book.isDigital, isFalse);
      expect(book.isAvailable, isTrue);
    });

    test('isDigital returns true for digital books', () {
      const book = Book(
        id: 'bk-2',
        judul: 'E-Book Flutter',
        penulis: 'Google',
        isbn: '123',
        penerbit: 'Tech',
        tipeBuku: 'Digital',
        jumlahStok: 0,
      );

      expect(book.isDigital, isTrue);
      expect(book.isAvailable, isFalse);
    });

    test('serializes Book to JSON correctly', () {
      const book = Book(
        id: 'bk-3',
        judul: 'Algoritma',
        penulis: 'Knuth',
        isbn: '999',
        penerbit: 'Publisher',
        genre: ['Komputer'],
        jumlahStok: 5,
      );

      final json = book.toJson();
      expect(json['id'], equals('bk-3'));
      expect(json['judul'], equals('Algoritma'));
      expect(json['jumlahStok'], equals(5));
    });

    test('English getters return expected properties', () {
      const book = Book(
        id: 'bk-4',
        judul: 'English Title',
        penulis: 'English Author',
        isbn: '123-456',
        penerbit: 'English Publisher',
        tipeBuku: 'Digital',
        tahunTerbit: 2024,
        jumlahStok: 10,
        cover: 'https://img.example.com/book.png',
      );

      expect(book.title, equals('English Title'));
      expect(book.author, equals('English Author'));
      expect(book.publisher, equals('English Publisher'));
      expect(book.bookType, equals('Digital'));
      expect(book.publishYear, equals(2024));
      expect(book.stockCount, equals(10));
      expect(book.coverUrl, equals('https://img.example.com/book.png'));
    });
  });


  group('Transaction Model', () {
    test('parses Transaction from JSON and resolves status formatting', () {
      final json = {
        'id': 'trx-1',
        'kdTransaksi': 'TRX-2026-001',
        'tglPinjam': '2026-09-10T10:00:00.000Z',
        'tglKembali': '2026-09-17T10:00:00.000Z',
        'status': 'Dipinjam',
        'namaAnggota': 'Ahmad Fauzi',
        'namaPustakawan': 'Budi Pustaka',
        'judulBuku': 'Laskar Pelangi',
        'bukuId': 'bk-1',
      };

      final trx = Transaction.fromJson(json);

      expect(trx.id, equals('trx-1'));
      expect(trx.kdTransaksi, equals('TRX-2026-001'));
      expect(trx.status, equals('Dipinjam'));
      expect(trx.badgeVariant, equals(TransactionBadgeVariant.warning));
      expect(trx.statusColor, isA<Color>());
      expect(trx.statusBackgroundColor, isA<Color>());
      expect(trx.statusTextColor, isA<Color>());
      expect(trx.formattedTglPinjam, matches(r'^\d{2}/\d{2}/\d{4}$'));
    });

    test('serializes Transaction to JSON correctly', () {
      final trx = Transaction(
        id: 'trx-2',
        kdTransaksi: 'TRX-002',
        status: 'Dikembalikan',
        namaAnggota: 'Siti',
        judulBuku: 'Bumi Manusia',
        tglPinjam: DateTime(2026, 9, 1),
      );

      final json = trx.toJson();
      expect(json['id'], equals('trx-2'));
      expect(json['kdTransaksi'], equals('TRX-002'));
      expect(json['status'], equals('Dikembalikan'));
    });

    test('English getters map to internal properties', () {
      final trx = Transaction(
        id: 'trx-3',
        kdTransaksi: 'TRX-003',
        status: 'Dipinjam',
        namaAnggota: 'Budi',
        judulBuku: 'Flutter Architecture',
        penulisBuku: 'Dart Team',
        tglPinjam: DateTime(2026, 9, 1),
        tglKembali: DateTime(2026, 9, 8),
      );

      expect(trx.transactionCode, equals('TRX-003'));
      expect(trx.bookTitle, equals('Flutter Architecture'));
      expect(trx.bookAuthor, equals('Dart Team'));
      expect(trx.borrowDate, equals(DateTime(2026, 9, 1)));
      expect(trx.returnDate, equals(DateTime(2026, 9, 8)));
    });

    test('ReturnTransactionResult parses data correctly', () {
      final res = ReturnTransactionResult.fromJson({
        'denda': 15000,
        'terlambatHari': 3,
        'pesan': 'Pengembalian berhasil diproses',
      });

      expect(res.denda, equals(15000));
      expect(res.terlambatHari, equals(3));
      expect(res.pesan, equals('Pengembalian berhasil diproses'));
      expect(res.fineAmount, equals(15000));
      expect(res.daysLate, equals(3));
      expect(res.message, equals('Pengembalian berhasil diproses'));
    });
  });

  group('DashboardData Model', () {
    test('parses nested dashboard payload and supports map indexing fallback', () {
      final json = {
        'statistik': {
          'bukuDipinjam': 4,
          'totalDenda': 10000,
          'totalBookmark': 5,
        },
        'transaksiAktif': [
          {
            'id': 'trx-1',
            'kdTransaksi': 'TRX-101',
            'bukuId': 'bk-1',
            'judulBuku': 'Flutter Advanced',
            'status': 'Dipinjam',
          },
        ],
        'bookmarkTerbaru': [
          {
            'id': 'bm-1',
            'bukuId': 'bk-2',
            'judulBuku': 'Clean Architecture',
            'penulisBuku': 'Robert C. Martin',
          },
        ],
        'tagihanDenda': [
          {
            'id': 'fn-1',
            'nominal': 5000,
            'status': 'Belum Lunas',
            'deskripsi': 'Keterlambatan 5 hari',
          },
        ],
      };

      final data = DashboardData.fromJson(json);

      expect(data.statistics.borrowedBooksCount, equals(4));
      expect(data.statistics.totalFines, equals(10000));
      expect(data.statistics.totalBookmarks, equals(5));
      expect(data.activeLoans.length, equals(1));
      expect(data.activeLoans.first.title, equals('Flutter Advanced'));
      expect(data.recentBookmarks.length, equals(1));
      expect(data.recentBookmarks.first.title, equals('Clean Architecture'));
      expect(data.fineBills.length, equals(1));
      expect(data.fineBills.first.amount, equals(5000));

      // Backward compatibility map operator
      expect(data['statistik']['bukuDipinjam'], equals(4));
      expect(data['transaksiAktif'].length, equals(1));
    });
  });

  group('BookmarkItem Model', () {
    test('parses from JSON correctly with fallback fields', () {
      final json = {
        'id': 'bm-10',
        'bukuId': 'bk-10',
        'createdAt': '2026-09-17T12:00:00.000Z',
        'buku': {
          'id': 'bk-10',
          'judul': 'Algoritma & Struktur Data',
          'penulis': 'Rinaldi Munir',
          'penerbit': 'Informatika',
          'tipeBuku': 'Fisik',
          'jumlahStok': 3,
        },
      };

      final item = BookmarkItem.fromJson(json);

      expect(item.id, equals('bm-10'));
      expect(item.bukuId, equals('bk-10'));
      expect(item.bookId, equals('bk-10'));
      expect(item.title, equals('Algoritma & Struktur Data'));
      expect(item.author, equals('Rinaldi Munir'));
      expect(item.publisher, equals('Informatika'));
      expect(item.bookType, equals('Fisik'));
    });
  });

  group('FinePaymentItem Model', () {
    test('parses from JSON correctly', () {
      final json = {
        'id': 'fine-1',
        'kdTransaksi': 'TRX-FINE-001',
        'judulBuku': 'Clean Code',
        'nominal': 20000,
        'status': 'Lunas',
        'tglBayar': '2026-09-15T09:00:00.000Z',
        'metodeBayar': 'Tunai',
        'keterangan': 'Denda keterlambatan 4 hari',
      };

      final item = FinePaymentItem.fromJson(json);

      expect(item.id, equals('fine-1'));
      expect(item.transactionCode, equals('TRX-FINE-001'));
      expect(item.bookTitle, equals('Clean Code'));
      expect(item.amount, equals(20000));
      expect(item.isPaid, isTrue);
      expect(item.paymentMethod, equals('Tunai'));
      expect(item.formattedAmount, equals('Rp 20.000'));
    });
  });
}


