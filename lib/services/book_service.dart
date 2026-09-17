import '../models/book.dart';
import '../models/bookmark.dart';
import '../utils/api_client.dart';

class BookService {
  final ApiClient _apiClient;

  BookService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<List<Book>> getBooks({
    int page = 1,
    int limit = 30,
    String? search,
    String? bookType,
  }) async {
    return fetchBooks(
      page: page,
      limit: limit,
      search: search,
      bookType: bookType,
    );
  }

  Future<List<Book>> fetchBooks({
    int page = 1,
    int limit = 30,
    String? search,
    String? bookType,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    if (bookType != null && bookType != 'Semua') {
      queryParams['bookType'] = bookType;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final response = await _apiClient.get('/book?$queryString');

    if (response is Map<String, dynamic>) {
      final list = (response['data'] is List)
          ? response['data'] as List<dynamic>
          : [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => Book.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<Book?> getBookDetail(String bookId) async {
    try {
      final response = await _apiClient.get('/book/detail/$bookId');
      if (response is Map<String, dynamic>) {
        final data = (response['data'] is Map<String, dynamic>)
            ? response['data'] as Map<String, dynamic>
            : response;
        return Book.fromJson(data);
      }
    } catch (_) {
      try {
        final response = await _apiClient.get('/member/library/detail/$bookId');
        if (response is Map<String, dynamic>) {
          final data = (response['data'] is Map<String, dynamic>)
              ? response['data'] as Map<String, dynamic>
              : response;
          return Book.fromJson(data);
        }
      } catch (_) {}
    }
    return null;
  }

  Future<List<BookmarkItem>> getBookmarks({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    try {
      final response = await _apiClient.get('/member/library/bookmark?$queryString');
      if (response is Map<String, dynamic>) {
        final list = (response['data'] is List)
            ? response['data'] as List<dynamic>
            : [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(BookmarkItem.fromJson)
            .toList();
      }
    } catch (_) {
      try {
        final response = await _apiClient.get('/book/bookmark?$queryString');
        if (response is Map<String, dynamic>) {
          final list = (response['data'] is List)
              ? response['data'] as List<dynamic>
              : [];
          return list
              .whereType<Map<String, dynamic>>()
              .map(BookmarkItem.fromJson)
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }

  Future<bool> addBookmark(String bookId) async {
    try {
      await _apiClient.post('/member/library/bookmark/$bookId', body: {});
      return true;
    } catch (_) {
      try {
        await _apiClient.post('/book/bookmark/$bookId', body: {});
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> deleteBookmark(String bookmarkId) async {
    try {
      await _apiClient.delete('/member/library/bookmark/delete/$bookmarkId');
      return true;
    } catch (_) {
      try {
        await _apiClient.delete('/book/bookmark/delete/$bookmarkId');
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<String?> readDigitalBook(String bookId) async {
    try {
      final response = await _apiClient.get('/member/library/digital/read/$bookId');
      if (response is Map<String, dynamic>) {
        final data = (response['data'] is Map<String, dynamic>)
            ? response['data'] as Map<String, dynamic>
            : response;
        return data['file']?.toString() ?? data['url']?.toString();
      }
    } catch (_) {
      try {
        final response = await _apiClient.get('/book/digital/read/$bookId');
        if (response is Map<String, dynamic>) {
          final data = (response['data'] is Map<String, dynamic>)
              ? response['data'] as Map<String, dynamic>
              : response;
          return data['file']?.toString() ?? data['url']?.toString();
        }
      } catch (_) {}
    }
    return null;
  }
}
