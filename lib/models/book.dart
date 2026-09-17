class Book {
  final String id;
  final String judul;
  final String penulis;
  final String isbn;
  final String penerbit;
  final List<String> genre;
  final String tipeBuku;
  final int tahunTerbit;
  final int jumlahStok;
  final String? cover;
  final String? file;
  final DateTime? createdAt;

  const Book({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.isbn,
    required this.penerbit,
    this.genre = const [],
    this.tipeBuku = 'Fisik',
    this.tahunTerbit = 0,
    this.jumlahStok = 0,
    this.cover,
    this.file,
    this.createdAt,
  });

  bool get isDigital => tipeBuku.toLowerCase() == 'digital';

  bool get isAvailable => jumlahStok > 0;

  factory Book.fromJson(Map<String, dynamic> json) {
    var parsedGenre = <String>[];
    if (json['genre'] is List) {
      parsedGenre = (json['genre'] as List)
          .map((item) => item.toString())
          .toList();
    }

    return Book(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      penulis: json['penulis']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      penerbit: json['penerbit']?.toString() ?? '',
      genre: parsedGenre,
      tipeBuku: json['tipeBuku']?.toString() ??
          json['tipe_buku']?.toString() ??
          'Fisik',
      tahunTerbit: int.tryParse(json['tahunTerbit']?.toString() ??
              json['tahun_terbit']?.toString() ??
              '0') ??
          0,
      jumlahStok: int.tryParse(json['jumlahStok']?.toString() ??
              json['jumlah_stok']?.toString() ??
              '0') ??
          0,
      cover: json['cover']?.toString(),
      file: json['file']?.toString() ?? json['file_digital']?.toString(),
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
      'judul': judul,
      'penulis': penulis,
      'isbn': isbn,
      'penerbit': penerbit,
      'genre': genre,
      'tipeBuku': tipeBuku,
      'tahunTerbit': tahunTerbit,
      'jumlahStok': jumlahStok,
      'cover': cover,
      'file': file,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Book copyWith({
    String? id,
    String? judul,
    String? penulis,
    String? isbn,
    String? penerbit,
    List<String>? genre,
    String? tipeBuku,
    int? tahunTerbit,
    int? jumlahStok,
    String? cover,
    String? file,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      penulis: penulis ?? this.penulis,
      isbn: isbn ?? this.isbn,
      penerbit: penerbit ?? this.penerbit,
      genre: genre ?? this.genre,
      tipeBuku: tipeBuku ?? this.tipeBuku,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      jumlahStok: jumlahStok ?? this.jumlahStok,
      cover: cover ?? this.cover,
      file: file ?? this.file,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
