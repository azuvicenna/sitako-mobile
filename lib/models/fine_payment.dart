import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';

class FinePaymentItem {
  final String id;
  final String transactionCode;
  final String bookTitle;
  final int fineAmount;
  final String? status;
  final DateTime? paymentDate;
  final String paymentMethod;
  final String? librarianName;
  final String? checkoutUrl;
  final DateTime? createdAt;

  const FinePaymentItem({
    required this.id,
    required this.transactionCode,
    required this.bookTitle,
    required this.fineAmount,
    this.status,
    this.paymentDate,
    this.paymentMethod = 'Tunai',
    this.librarianName,
    this.checkoutUrl,
    this.createdAt,
  });

  // Backward-compatible getters
  String get kdTransaksi => transactionCode;
  String get judulBuku => bookTitle;
  int get fine => fineAmount;
  int get amount => fineAmount;
  int get totalDenda => fineAmount;
  DateTime? get tglBayar => paymentDate;
  String get metodePembayaran => paymentMethod;
  String? get namaPustakawan => librarianName;
  bool get isPaid =>
      paymentDate != null ||
      (status != null && status!.toLowerCase() == 'lunas');
  String get formattedPaymentDate => AppDateUtils.formatDate(paymentDate);
  String get formattedAmount => CurrencyUtils.formatRupiah(fineAmount);


  factory FinePaymentItem.fromJson(Map<String, dynamic> json) {
    final fineVal = int.tryParse(json['fineAmount']?.toString() ??
            json['fine_amount']?.toString() ??
            json['nominal']?.toString() ??
            json['amount']?.toString() ??
            json['totalDenda']?.toString() ??
            json['total_denda']?.toString() ??
            json['hargaDenda']?.toString() ??
            json['harga_denda']?.toString() ??
            '0') ??
        0;


    final payDateStr = json['paymentDate']?.toString() ??
        json['payment_date']?.toString() ??
        json['tglBayar']?.toString() ??
        json['tgl_bayar']?.toString();

    return FinePaymentItem(
      id: json['id']?.toString() ?? '',
      transactionCode: json['transactionCode']?.toString() ??
          json['transaction_code']?.toString() ??
          json['kdTransaksi']?.toString() ??
          json['kd_transaksi']?.toString() ??
          '-',
      bookTitle: json['bookTitle']?.toString() ??
          json['book_title']?.toString() ??
          json['judulBuku']?.toString() ??
          json['judul_buku']?.toString() ??
          '',
      fineAmount: fineVal,
      status: json['status']?.toString(),
      paymentDate: payDateStr != null ? DateTime.tryParse(payDateStr) : null,
      paymentMethod: json['paymentMethod']?.toString() ??
          json['payment_method']?.toString() ??
          json['metodePembayaran']?.toString() ??
          json['metode_pembayaran']?.toString() ??
          json['metodeBayar']?.toString() ??
          json['metode_bayar']?.toString() ??
          'Tunai',

      librarianName: json['librarianName']?.toString() ??
          json['librarian_name']?.toString() ??
          json['namaPustakawan']?.toString() ??
          json['nama_pustakawan']?.toString(),
      checkoutUrl: json['checkoutUrl']?.toString() ??
          json['checkout_url']?.toString(),
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
      'bookTitle': bookTitle,
      'fineAmount': fineAmount,
      'status': status,
      'paymentDate': paymentDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'librarianName': librarianName,
      'checkoutUrl': checkoutUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

