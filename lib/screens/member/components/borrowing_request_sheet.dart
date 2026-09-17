import 'package:flutter/material.dart';
import '../../../models/book.dart';
import '../../../services/transaction_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/error_utils.dart';
import '../../../widgets/app_button.dart';

class BorrowingRequestSheet extends StatefulWidget {
  final Book book;
  final TransactionService? transactionService;
  final VoidCallback? onSuccess;

  const BorrowingRequestSheet({
    super.key,
    required this.book,
    this.transactionService,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required Book book,
    TransactionService? transactionService,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BorrowingRequestSheet(
        book: book,
        transactionService: transactionService,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<BorrowingRequestSheet> createState() => _BorrowingRequestSheetState();
}

class _BorrowingRequestSheetState extends State<BorrowingRequestSheet> {
  late final TransactionService _transactionService;
  int _durationDays = 7;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _transactionService = widget.transactionService ?? TransactionService();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final borrowDate = DateTime.now();
    final returnDate = borrowDate.add(Duration(days: _durationDays));

    try {
      await _transactionService.requestBorrowing(
        bookId: widget.book.id,
        borrowDate: borrowDate,
        returnDate: returnDate,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan peminjaman berhasil dikirim! Menunggu persetujuan pustakawan.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorUtils.getErrorMessage(e);
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final returnDate = now.add(Duration(days: _durationDays));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text(
            'Ajukan Peminjaman Buku',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoalDark,
            ),
          ),
          const SizedBox(height: 12),

          // Book summary banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.book_outlined, color: AppColors.mustard, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                      Text(
                        'Penulis: ${widget.book.author}',
                        style: const TextStyle(fontSize: 12, color: AppColors.charcoalMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text(
            'Durasi Peminjaman',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoalDark),
          ),
          const SizedBox(height: 8),

          // Duration options
          Row(
            children: [3, 7, 14].map((days) {
              final isSelected = _durationDays == days;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$days Hari'),
                  selected: isSelected,
                  selectedColor: AppColors.mustard,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.charcoalDark,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _durationDays = days);
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Date overview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tanggal Pinjam:', style: TextStyle(fontSize: 12, color: AppColors.charcoalMuted)),
                    Text(
                      AppDateUtils.formatDate(now),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.charcoalDark),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Batas Pengembalian:', style: TextStyle(fontSize: 12, color: AppColors.charcoalMuted)),
                    Text(
                      AppDateUtils.formatDate(returnDate),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mustardDark),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Submit button
          AppButton(
            text: 'Konfirmasi Ajukan Pinjam',
            isLoading: _isSubmitting,
            isFullWidth: true,
            icon: const Icon(Icons.send_outlined, size: 18),
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
