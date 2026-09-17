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
    this.bukuId,
    this.pustakawanId,
    this.anggotaId,
    this.createdAt,
  });

  TransactionBadgeVariant get badgeVariant =>
      TransactionUtils.getStatusBadgeVariant(status);

  String get kodeTransaksi => kdTransaksi;

  Color get statusColor => TransactionUtils.getStatusColor(status);

  Color get statusBackgroundColor =>
      TransactionUtils.getStatusBackgroundColor(status);

  Color get statusTextColor => TransactionUtils.getStatusTextColor(status);

  String get formattedTglPinjam => AppDateUtils.formatDate(tglPinjam);

  String get formattedTglKembali => AppDateUtils.formatDate(tglKembali);

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      kdTransaksi: json['kdTransaksi']?.toString() ??
          json['kd_transaksi']?.toString() ??
          '',
      tglPinjam: json['tglPinjam'] != null
          ? DateTime.tryParse(json['tglPinjam'].toString())
          : (json['tgl_pinjam'] != null
              ? DateTime.tryParse(json['tgl_pinjam'].toString())
              : null),
      tglKembali: json['tglKembali'] != null
          ? DateTime.tryParse(json['tglKembali'].toString())
          : (json['tgl_kembali'] != null
              ? DateTime.tryParse(json['tgl_kembali'].toString())
              : null),
      status: json['status']?.toString() ?? 'Menunggu Persetujuan',
      namaAnggota: json['namaAnggota']?.toString() ??
          json['nama_anggota']?.toString() ??
          '',
      namaPustakawan: json['namaPustakawan']?.toString() ??
          json['nama_pustakawan']?.toString(),
      judulBuku: json['judulBuku']?.toString() ??
          json['judul_buku']?.toString() ??
          '',
      bukuId: json['bukuId']?.toString() ?? json['buku_id']?.toString(),
      pustakawanId: json['pustakawanId']?.toString() ??
          json['pustakawan_id']?.toString(),
      anggotaId: json['anggotaId']?.toString() ??
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
      'kdTransaksi': kdTransaksi,
      'tglPinjam': tglPinjam?.toIso8601String(),
      'tglKembali': tglKembali?.toIso8601String(),
      'status': status,
      'namaAnggota': namaAnggota,
      'namaPustakawan': namaPustakawan,
      'judulBuku': judulBuku,
      'bukuId': bukuId,
      'pustakawanId': pustakawanId,
      'anggotaId': anggotaId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? kdTransaksi,
    DateTime? tglPinjam,
    DateTime? tglKembali,
    String? status,
    String? namaAnggota,
    String? namaPustakawan,
    String? judulBuku,
    String? bukuId,
    String? pustakawanId,
    String? anggotaId,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      kdTransaksi: kdTransaksi ?? this.kdTransaksi,
      tglPinjam: tglPinjam ?? this.tglPinjam,
      tglKembali: tglKembali ?? this.tglKembali,
      status: status ?? this.status,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      namaPustakawan: namaPustakawan ?? this.namaPustakawan,
      judulBuku: judulBuku ?? this.judulBuku,
      bukuId: bukuId ?? this.bukuId,
      pustakawanId: pustakawanId ?? this.pustakawanId,
      anggotaId: anggotaId ?? this.anggotaId,
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
