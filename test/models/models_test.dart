import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitako_mobile/models/book.dart';
import 'package:sitako_mobile/models/transaction.dart';
import 'package:sitako_mobile/models/user.dart';
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
  });
}
