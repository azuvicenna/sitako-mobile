import '../models/transaction.dart';
import '../utils/api_client.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<List<Transaction>> getMemberTransactions({
    int page = 1,
    int limit = 30,
    String? status,
  }) async {
    return fetchMemberTransactions(
      page: page,
      limit: limit,
      status: status,
    );
  }

  Future<List<Transaction>> fetchMemberTransactions({
    int page = 1,
    int limit = 30,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status != 'Semua') {
      if (status == 'Menunggu') {
        queryParams['status'] = 'Menunggu Persetujuan';
      } else {
        queryParams['status'] = status;
      }
    }

    final queryString = Uri(queryParameters: queryParams).query;
    dynamic response;
    try {
      response = await _apiClient.get('/member/transactions/?$queryString');
    } catch (_) {
      try {
        response = await _apiClient.get('/member/transaction/?$queryString');
      } catch (_) {
        return [];
      }
    }

    if (response is Map<String, dynamic>) {
      final list = (response['data'] is List)
          ? response['data'] as List<dynamic>
          : [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<Transaction> requestBorrowing({
    required String bookId,
    String? librarianId,
    DateTime? borrowDate,
    DateTime? returnDate,
    int? borrowDays,
    String? notes,
  }) async {
    final effectiveBorrowDate = borrowDate ?? DateTime.now();
    final effectiveReturnDate = returnDate ??
        effectiveBorrowDate.add(Duration(days: borrowDays ?? 7));

    final payload = <String, dynamic>{
      'bukuId': bookId,
      'tglPinjam': effectiveBorrowDate.toIso8601String(),
      'tglKembali': effectiveReturnDate.toIso8601String(),
      'status': 'Menunggu Persetujuan',
    };
    if (librarianId != null && librarianId.isNotEmpty) {
      payload['pustakawanId'] = librarianId;
    }
    if (notes != null && notes.isNotEmpty) {
      payload['catatan'] = notes;
    }

    dynamic response;
    try {
      response = await _apiClient.post('/member/transactions/', body: payload);
    } catch (_) {
      try {
        response = await _apiClient.post('/member/transactions/borrow', body: payload);
      } catch (_) {
        response = await _apiClient.post('/member/transaction/', body: payload);
      }
    }

    if (response is Map<String, dynamic>) {
      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;
      return Transaction.fromJson(data);
    }

    throw Exception('Gagal mengajukan peminjaman buku');
  }

  Future<ReturnTransactionResult> requestReturn({
    required String transactionId,
    bool isLostBook = false,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'isBukuHilang': isLostBook,
    };
    if (notes != null && notes.isNotEmpty) {
      payload['catatan'] = notes;
    }

    dynamic response;
    try {
      response = await _apiClient.post(
        '/member/transactions/$transactionId/return',
        body: payload,
      );
    } catch (_) {
      response = await _apiClient.post(
        '/member/transaction/$transactionId/return',
        body: payload,
      );
    }

    if (response is Map<String, dynamic>) {
      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;
      return ReturnTransactionResult.fromJson(data);
    }

    return const ReturnTransactionResult(
      message: 'Pengembalian berhasil diajukan',
    );
  }

}
