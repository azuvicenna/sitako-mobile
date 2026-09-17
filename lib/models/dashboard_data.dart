import '../utils/date_utils.dart';

class DashboardStatistics {
  final int borrowedBooksCount;
  final int totalFines;
  final int totalBookmarks;

  const DashboardStatistics({
    this.borrowedBooksCount = 0,
    this.totalFines = 0,
    this.totalBookmarks = 0,
  });

  // Backward-compatible getters
  int get bukuDipinjam => borrowedBooksCount;
  int get totalDenda => totalFines;
  int get totalBookmark => totalBookmarks;

  dynamic operator [](String key) {
    switch (key) {
      case 'borrowedBooksCount':
      case 'bukuDipinjam':
        return borrowedBooksCount;
      case 'totalFines':
      case 'totalDenda':
        return totalFines;
      case 'totalBookmarks':
      case 'totalBookmark':
        return totalBookmarks;
      default:
        return null;
    }
  }

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      borrowedBooksCount: int.tryParse(json['borrowedBooksCount']?.toString() ??
              json['borrowed_books_count']?.toString() ??
              json['bukuDipinjam']?.toString() ??
              json['buku_dipinjam']?.toString() ??
              '0') ??
          0,
      totalFines: int.tryParse(json['totalFines']?.toString() ??
              json['total_fines']?.toString() ??
              json['totalDenda']?.toString() ??
              json['total_denda']?.toString() ??
              '0') ??
          0,
      totalBookmarks: int.tryParse(json['totalBookmarks']?.toString() ??
              json['total_bookmarks']?.toString() ??
              json['totalBookmark']?.toString() ??
              json['total_bookmark']?.toString() ??
              '0') ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrowedBooksCount': borrowedBooksCount,
      'totalFines': totalFines,
      'totalBookmarks': totalBookmarks,
      'bukuDipinjam': borrowedBooksCount,
      'totalDenda': totalFines,
      'totalBookmark': totalBookmarks,
    };
  }
}

class ActiveLoanItem {
  final String id;
  final String bookTitle;
  final String? bookCover;
  final DateTime? returnDate;
  final String status;

  const ActiveLoanItem({
    required this.id,
    required this.bookTitle,
    this.bookCover,
    this.returnDate,
    required this.status,
  });

  // Backward-compatible getters
  String get title => bookTitle;
  String get judulBuku => bookTitle;
  String? get coverBuku => bookCover;

  DateTime? get tglKembali => returnDate;
  String get formattedReturnDate => AppDateUtils.formatDate(returnDate);

  factory ActiveLoanItem.fromJson(Map<String, dynamic> json) {
    final buku = json['buku'] as Map<String, dynamic>?;
    final bookTitle = json['bookTitle']?.toString() ??
        json['book_title']?.toString() ??
        json['judulBuku']?.toString() ??
        buku?['judul']?.toString() ??
        buku?['title']?.toString() ??
        '';

    final bookCover = json['bookCover']?.toString() ??
        json['book_cover']?.toString() ??
        buku?['cover']?.toString() ??
        json['cover']?.toString();

    final dateStr = json['returnDate']?.toString() ??
        json['return_date']?.toString() ??
        json['tglKembali']?.toString() ??
        json['tgl_kembali']?.toString();

    return ActiveLoanItem(
      id: json['id']?.toString() ?? '',
      bookTitle: bookTitle,
      bookCover: bookCover,
      returnDate: dateStr != null ? DateTime.tryParse(dateStr) : null,
      status: json['status']?.toString() ?? 'Dipinjam',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'bookCover': bookCover,
      'returnDate': returnDate?.toIso8601String(),
      'status': status,
    };
  }
}

class RecentBookmarkItem {
  final String id;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCover;

  const RecentBookmarkItem({
    required this.id,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCover,
  });

  // Backward-compatible getters
  String get title => bookTitle;
  String get author => bookAuthor;
  String get judulBuku => bookTitle;
  String get penulisBuku => bookAuthor;
  String? get coverBuku => bookCover;


  factory RecentBookmarkItem.fromJson(Map<String, dynamic> json) {
    final buku = json['buku'] as Map<String, dynamic>?;
    final title = json['bookTitle']?.toString() ??
        json['book_title']?.toString() ??
        json['judulBuku']?.toString() ??
        json['judul_buku']?.toString() ??
        json['judul']?.toString() ??
        buku?['judul']?.toString() ??
        buku?['title']?.toString() ??
        '';

    final author = json['bookAuthor']?.toString() ??
        json['book_author']?.toString() ??
        json['penulisBuku']?.toString() ??
        json['penulis_buku']?.toString() ??
        json['penulis']?.toString() ??
        buku?['penulis']?.toString() ??
        buku?['author']?.toString() ??
        '';

    final cover = json['bookCover']?.toString() ??
        json['book_cover']?.toString() ??
        buku?['cover']?.toString() ??
        json['cover']?.toString();

    return RecentBookmarkItem(
      id: json['id']?.toString() ?? '',
      bookTitle: title,
      bookAuthor: author,
      bookCover: cover,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCover': bookCover,
    };
  }
}

class FineBillItem {
  final String id;
  final int totalFine;
  final String? checkoutUrl;

  const FineBillItem({
    required this.id,
    required this.totalFine,
    this.checkoutUrl,
  });

  int get totalDenda => totalFine;
  int get amount => totalFine;

  factory FineBillItem.fromJson(Map<String, dynamic> json) {
    return FineBillItem(
      id: json['id']?.toString() ?? '',
      totalFine: int.tryParse(json['totalFine']?.toString() ??
              json['total_fine']?.toString() ??
              json['totalDenda']?.toString() ??
              json['total_denda']?.toString() ??
              json['nominal']?.toString() ??
              json['amount']?.toString() ??
              '0') ??
          0,
      checkoutUrl: json['checkoutUrl']?.toString() ??
          json['checkout_url']?.toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalFine': totalFine,
      'checkoutUrl': checkoutUrl,
    };
  }
}

class DashboardData {
  final DashboardStatistics statistics;
  final List<ActiveLoanItem> activeLoans;
  final List<RecentBookmarkItem> recentBookmarks;
  final List<FineBillItem> fineBills;

  const DashboardData({
    this.statistics = const DashboardStatistics(),
    this.activeLoans = const [],
    this.recentBookmarks = const [],
    this.fineBills = const [],
  });

  // Backward-compatible getters
  DashboardStatistics get statistik => statistics;
  List<ActiveLoanItem> get transaksiAktif => activeLoans;
  List<RecentBookmarkItem> get bookmarkTerbaru => recentBookmarks;
  List<FineBillItem> get tagihanDenda => fineBills;

  dynamic operator [](String key) {
    switch (key) {
      case 'statistics':
      case 'statistik':
        return statistics;
      case 'activeLoans':
      case 'transaksiAktif':
        return activeLoans;
      case 'recentBookmarks':
      case 'bookmarkTerbaru':
        return recentBookmarks;
      case 'fineBills':
      case 'tagihanDenda':
        return fineBills;
      default:
        return null;
    }
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final statsJson = (json['statistics'] ?? json['statistik']) as Map<String, dynamic>? ?? {};
    final activeRaw = (json['activeLoans'] ?? json['transaksiAktif']) as List<dynamic>? ?? [];
    final bookmarkRaw = (json['recentBookmarks'] ?? json['bookmarkTerbaru']) as List<dynamic>? ?? [];
    final finesRaw = (json['fineBills'] ?? json['tagihanDenda']) as List<dynamic>? ?? [];

    return DashboardData(
      statistics: DashboardStatistics.fromJson(statsJson),
      activeLoans: activeRaw
          .whereType<Map<String, dynamic>>()
          .map(ActiveLoanItem.fromJson)
          .toList(),
      recentBookmarks: bookmarkRaw
          .whereType<Map<String, dynamic>>()
          .map(RecentBookmarkItem.fromJson)
          .toList(),
      fineBills: finesRaw
          .whereType<Map<String, dynamic>>()
          .map(FineBillItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statistics': statistics.toJson(),
      'activeLoans': activeLoans.map((e) => e.toJson()).toList(),
      'recentBookmarks': recentBookmarks.map((e) => e.toJson()).toList(),
      'fineBills': fineBills.map((e) => e.toJson()).toList(),
    };
  }
}
