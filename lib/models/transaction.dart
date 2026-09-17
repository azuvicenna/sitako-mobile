import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../utils/transaction_utils.dart';

class Transaction {
  final String id;
  final String kdTransaksi;
  final DateTime? tglPinjam;
  final DateTime? tglKembali;
  final String status;
  final String namaAnggota;
  final String? namaPustakawan;
  final String judulBuku;
  final String? penulisBuku;
  final String? bukuId;
  final String? pustakawanId;
  final String? anggotaId;
  final DateTime? createdAt;

  const Transaction({
    required this.id,
    required this.kdTransaksi,
    this.tglPinjam,
    this.tglKembali,
    required this.status,
    required this.namaAnggota,
    this.namaPustakawan,
    required this.judulBuku,
    this.penulisBuku,
    this.bukuId,
    this.pustakawanId,
    this.anggotaId,
    this.createdAt,
  });


  // --- English Naming Convention Getters ---
  String get transactionCode => kdTransaksi;
  String get kodeTransaksi => kdTransaksi;
  DateTime? get borrowDate => tglPinjam;
  DateTime? get returnDate => tglKembali;
  String get memberName => namaAnggota;
  String? get librarianName => namaPustakawan;
  String get bookTitle => judulBuku;
  String? get bookAuthor => penulisBuku;
  String? get author => penulisBuku;
  String? get bookId => bukuId;
  String? get librarianId => pustakawanId;
  String? get memberId => anggotaId;


  String get formattedBorrowDate => AppDateUtils.formatDate(borrowDate);
  String get formattedReturnDate => AppDateUtils.formatDate(returnDate);
  String get formattedTglPinjam => formattedBorrowDate;
  String get formattedTglKembali => formattedReturnDate;

  TransactionBadgeVariant get badgeVariant =>
      TransactionUtils.getStatusBadgeVariant(status);

  Color get statusColor => TransactionUtils.getStatusColor(status);
  Color get statusBackgroundColor =>
      TransactionUtils.getStatusBackgroundColor(status);
  Color get statusTextColor => TransactionUtils.getStatusTextColor(status);

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      kdTransaksi: json['transactionCode']?.toString() ??
          json['transaction_code']?.toString() ??
          json['kdTransaksi']?.toString() ??
          json['kd_transaksi']?.toString() ??
          '',
      tglPinjam: json['borrowDate'] != null
          ? DateTime.tryParse(json['borrowDate'].toString())
          : (json['borrow_date'] != null
              ? DateTime.tryParse(json['borrow_date'].toString())
              : (json['tglPinjam'] != null
                  ? DateTime.tryParse(json['tglPinjam'].toString())
                  : (json['tgl_pinjam'] != null
                      ? DateTime.tryParse(json['tgl_pinjam'].toString())
                      : null))),
      tglKembali: json['returnDate'] != null
          ? DateTime.tryParse(json['returnDate'].toString())
          : (json['return_date'] != null
              ? DateTime.tryParse(json['return_date'].toString())
              : (json['tglKembali'] != null
                  ? DateTime.tryParse(json['tglKembali'].toString())
                  : (json['tgl_kembali'] != null
                      ? DateTime.tryParse(json['tgl_kembali'].toString())
                      : null))),
      status: json['status']?.toString() ?? 'Menunggu Persetujuan',
      namaAnggota: json['memberName']?.toString() ??
          json['member_name']?.toString() ??
          json['namaAnggota']?.toString() ??
          json['nama_anggota']?.toString() ??
          '',
      namaPustakawan: json['librarianName']?.toString() ??
          json['librarian_name']?.toString() ??
          json['namaPustakawan']?.toString() ??
          json['nama_pustakawan']?.toString(),
      judulBuku: json['bookTitle']?.toString() ??
          json['book_title']?.toString() ??
          json['judulBuku']?.toString() ??
          json['judul_buku']?.toString() ??
          '',
      bukuId: json['bookId']?.toString() ??
          json['book_id']?.toString() ??
          json['bukuId']?.toString() ??
          json['buku_id']?.toString(),
      pustakawanId: json['librarianId']?.toString() ??
          json['librarian_id']?.toString() ??
          json['pustakawanId']?.toString() ??
          json['pustakawan_id']?.toString(),
      anggotaId: json['memberId']?.toString() ??
          json['member_id']?.toString() ??
          json['anggotaId']?.toString() ??
          json['anggota_id']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionCode': transactionCode,
      'borrowDate': borrowDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status,
      'memberName': memberName,
      'librarianName': librarianName,
      'bookTitle': bookTitle,
      'bookId': bookId,
      'librarianId': librarianId,
      'memberId': memberId,
      'createdAt': createdAt?.toIso8601String(),
      // Backward-compatible keys for backend integration
      'kdTransaksi': kdTransaksi,
      'tglPinjam': tglPinjam?.toIso8601String(),
      'tglKembali': tglKembali?.toIso8601String(),
      'namaAnggota': namaAnggota,
      'namaPustakawan': namaPustakawan,
      'judulBuku': judulBuku,
      'bukuId': bukuId,
      'pustakawanId': pustakawanId,
      'anggotaId': anggotaId,
    };
  }

  Transaction copyWith({
    String? id,
    String? transactionCode,
    DateTime? borrowDate,
    DateTime? returnDate,
    String? status,
    String? memberName,
    String? librarianName,
    String? bookTitle,
    String? bookId,
    String? librarianId,
    String? memberId,
    DateTime? createdAt,
    // Support Indonesian parameter aliases
    String? kdTransaksi,
    DateTime? tglPinjam,
    DateTime? tglKembali,
    String? namaAnggota,
    String? namaPustakawan,
    String? judulBuku,
    String? bukuId,
    String? pustakawanId,
    String? anggotaId,
  }) {
    return Transaction(
      id: id ?? this.id,
      kdTransaksi: transactionCode ?? kdTransaksi ?? this.kdTransaksi,
      tglPinjam: borrowDate ?? tglPinjam ?? this.tglPinjam,
      tglKembali: returnDate ?? tglKembali ?? this.tglKembali,
      status: status ?? this.status,
      namaAnggota: memberName ?? namaAnggota ?? this.namaAnggota,
      namaPustakawan: librarianName ?? namaPustakawan ?? this.namaPustakawan,
      judulBuku: bookTitle ?? judulBuku ?? this.judulBuku,
      bukuId: bookId ?? bukuId ?? this.bukuId,
      pustakawanId: librarianId ?? pustakawanId ?? this.pustakawanId,
      anggotaId: memberId ?? anggotaId ?? this.anggotaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kdTransaksi == other.kdTransaksi;

  @override
  int get hashCode => id.hashCode ^ kdTransaksi.hashCode;
}

class ReturnTransactionResult {
  final bool isLate;
  final int lateDays;
  final int fineAmount;
  final String message;

  const ReturnTransactionResult({
    this.isLate = false,
    this.lateDays = 0,
    this.fineAmount = 0,
    this.message = 'Pengembalian berhasil diajukan',
  });

  bool get isTerlambat => isLate;
  int get dendaPerkiraan => fineAmount;
  int get denda => fineAmount;
  int get terlambatHari => lateDays;
  int get daysLate => lateDays;
  String get pesan => message;

  factory ReturnTransactionResult.fromJson(Map<String, dynamic> json) {
    return ReturnTransactionResult(
      isLate: json['isTerlambat'] == true ||
          json['is_terlambat'] == true ||
          json['isLate'] == true,
      lateDays: int.tryParse(json['terlambatHari']?.toString() ??
              json['hariTerlambat']?.toString() ??
              json['late_days']?.toString() ??
              json['daysLate']?.toString() ??
              '0') ??
          0,
      fineAmount: int.tryParse(json['denda']?.toString() ??
              json['dendaPerkiraan']?.toString() ??
              json['fine_amount']?.toString() ??
              json['fineAmount']?.toString() ??
              '0') ??
          0,
      message: json['pesan']?.toString() ??
          json['message']?.toString() ??
          'Pengembalian berhasil diajukan',
    );
  }
}

