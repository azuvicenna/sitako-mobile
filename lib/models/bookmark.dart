class BookmarkItem {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final String? publisher;
  final String? cover;
  final String bookType;
  final List<String> genres;
  final DateTime? createdAt;

  const BookmarkItem({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    this.publisher,
    this.cover,
    this.bookType = 'Fisik',
    this.genres = const [],
    this.createdAt,
  });

  // Backward-compatible getters
  String get bookmarkId => id;
  String get bukuId => bookId;
  String get judul => title;
  String get penulis => author;
  String? get penerbit => publisher;
  String get tipeBuku => bookType;
  List<String> get genre => genres;

  bool get isDigital => bookType.toLowerCase() == 'digital';

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    var parsedGenres = <String>[];
    final rawGenres = json['genres'] ?? json['genre'];
    if (rawGenres is List) {
      parsedGenres = rawGenres.map((item) => item.toString()).toList();
    }

    final buku = json['buku'] as Map<String, dynamic>?;

    return BookmarkItem(
      id: json['id']?.toString() ??
          json['bookmarkId']?.toString() ??
          json['bookmark_id']?.toString() ??
          '',
      bookId: json['bookId']?.toString() ??
          json['book_id']?.toString() ??
          json['bukuId']?.toString() ??
          json['buku_id']?.toString() ??
          buku?['id']?.toString() ??
          '',
      title: json['title']?.toString() ??
          json['bookTitle']?.toString() ??
          json['judul']?.toString() ??
          buku?['judul']?.toString() ??
          buku?['title']?.toString() ??
          '',
      author: json['author']?.toString() ??
          json['penulis']?.toString() ??
          buku?['penulis']?.toString() ??
          buku?['author']?.toString() ??
          '',
      publisher: json['publisher']?.toString() ??
          json['penerbit']?.toString() ??
          buku?['penerbit']?.toString() ??
          buku?['publisher']?.toString(),
      cover: json['cover']?.toString() ??
          json['cover_url']?.toString() ??
          buku?['cover']?.toString(),
      bookType: json['bookType']?.toString() ??
          json['tipeBuku']?.toString() ??
          json['tipe_buku']?.toString() ??
          buku?['tipeBuku']?.toString() ??
          buku?['tipe_buku']?.toString() ??
          'Fisik',
      genres: parsedGenres,
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
      'bookId': bookId,
      'title': title,
      'author': author,
      'cover': cover,
      'bookType': bookType,
      'genres': genres,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
