import 'package:flutter/material.dart';
import '../utils/image_utils.dart';

class User {
  final String id;
  final String nama;
  final String nis;
  final String email;
  final String telepon;
  final String? foto;
  final bool statusAktif;
  final String role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.nama,
    required this.nis,
    required this.email,
    required this.telepon,
    this.foto,
    this.statusAktif = true,
    this.role = 'Anggota',
    this.createdAt,
  });

  String get initials => ImageUtils.getInitials(nama);

  Color get avatarColor => ImageUtils.getAvatarColor(nama);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telepon: json['telepon']?.toString() ?? '',
      foto: json['foto']?.toString(),
      statusAktif: json['status_aktif'] == true || json['statusAktif'] == true,
      role: json['role']?.toString() ?? 'Anggota',
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
      'nama': nama,
      'nis': nis,
      'email': email,
      'telepon': telepon,
      'foto': foto,
      'status_aktif': statusAktif,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? nama,
    String? nis,
    String? email,
    String? telepon,
    String? foto,
    bool? statusAktif,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nis: nis ?? this.nis,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      foto: foto ?? this.foto,
      statusAktif: statusAktif ?? this.statusAktif,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nis == other.nis;

  @override
  int get hashCode => id.hashCode ^ nis.hashCode;
}
