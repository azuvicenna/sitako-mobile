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

  // --- English Naming Convention Getters ---
  String get title => judul;
  String get author => penulis;
  String get publisher => penerbit;
  String get bookType => tipeBuku;
  int get publishYear => tahunTerbit;
  int get stockCount => jumlahStok;
  int get stokTersedia => jumlahStok;
  String? get kategori => genre.isNotEmpty ? genre.first : null;
  String? get coverUrl => cover;

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
      judul: json['title']?.toString() ??
          json['judul']?.toString() ??
          '',
      penulis: json['author']?.toString() ??
          json['penulis']?.toString() ??
          '',
      isbn: json['isbn']?.toString() ?? '',
      penerbit: json['publisher']?.toString() ??
          json['penerbit']?.toString() ??
          '',
      genre: parsedGenre,
      tipeBuku: json['bookType']?.toString() ??
          json['book_type']?.toString() ??
          json['tipeBuku']?.toString() ??
          json['tipe_buku']?.toString() ??
          'Fisik',
      tahunTerbit: int.tryParse(json['publishYear']?.toString() ??
              json['publish_year']?.toString() ??
              json['tahunTerbit']?.toString() ??
              json['tahun_terbit']?.toString() ??
              '0') ??
          0,
      jumlahStok: int.tryParse(json['stockCount']?.toString() ??
              json['stock_count']?.toString() ??
              json['jumlahStok']?.toString() ??
              json['jumlah_stok']?.toString() ??
              '0') ??
          0,
      cover: json['cover']?.toString() ?? json['cover_url']?.toString(),
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
      'title': title,
      'author': author,
      'isbn': isbn,
      'publisher': publisher,
      'genre': genre,
      'bookType': bookType,
      'publishYear': publishYear,
      'stockCount': stockCount,
      'cover': cover,
      'file': file,
      'createdAt': createdAt?.toIso8601String(),
      // Backward-compatible keys for backend integration
      'judul': judul,
      'penulis': penulis,
      'penerbit': penerbit,
      'tipeBuku': tipeBuku,
      'tahunTerbit': tahunTerbit,
      'jumlahStok': jumlahStok,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? publisher,
    List<String>? genre,
    String? bookType,
    int? publishYear,
    int? stockCount,
    String? cover,
    String? file,
    DateTime? createdAt,
    // Support Indonesian parameters in copyWith
    String? judul,
    String? penulis,
    String? penerbit,
    String? tipeBuku,
    int? tahunTerbit,
    int? jumlahStok,
  }) {
    return Book(
      id: id ?? this.id,
      judul: title ?? judul ?? this.judul,
      penulis: author ?? penulis ?? this.penulis,
      isbn: isbn ?? this.isbn,
      penerbit: publisher ?? penerbit ?? this.penerbit,
      genre: genre ?? this.genre,
      tipeBuku: bookType ?? tipeBuku ?? this.tipeBuku,
      tahunTerbit: publishYear ?? tahunTerbit ?? this.tahunTerbit,
      jumlahStok: stockCount ?? jumlahStok ?? this.jumlahStok,
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
