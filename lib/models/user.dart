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

  // --- English Naming Convention Getters ---
  String get name => nama;
  String get phone => telepon;
  String? get photo => foto;
  bool get isActive => statusAktif;

  String get initials => ImageUtils.getInitials(name);
  Color get avatarColor => ImageUtils.getAvatarColor(name);
  String get identifier => nis;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      nama: json['name']?.toString() ??
          json['nama']?.toString() ??
          '',
      nis: json['nis']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telepon: json['phone']?.toString() ??
          json['telepon']?.toString() ??
          '',
      foto: json['photo']?.toString() ?? json['foto']?.toString(),
      statusAktif: json['isActive'] == true ||
          json['is_active'] == true ||
          json['status_aktif'] == true ||
          json['statusAktif'] == true,
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
      'name': name,
      'nis': nis,
      'email': email,
      'phone': phone,
      'photo': photo,
      'isActive': isActive,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      // Backward-compatible keys
      'nama': nama,
      'telepon': telepon,
      'foto': foto,
      'status_aktif': statusAktif,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? nis,
    String? email,
    String? phone,
    String? photo,
    bool? isActive,
    String? role,
    DateTime? createdAt,
    // Indonesian parameter aliases
    String? nama,
    String? telepon,
    String? foto,
    bool? statusAktif,
  }) {
    return User(
      id: id ?? this.id,
      nama: name ?? nama ?? this.nama,
      nis: nis ?? this.nis,
      email: email ?? this.email,
      telepon: phone ?? telepon ?? this.telepon,
      foto: photo ?? foto ?? this.foto,
      statusAktif: isActive ?? statusAktif ?? this.statusAktif,
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
