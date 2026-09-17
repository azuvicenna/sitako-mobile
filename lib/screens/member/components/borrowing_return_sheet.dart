import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../../../services/transaction_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/currency_utils.dart';
import '../../../utils/error_utils.dart';
import '../../../widgets/app_button.dart';

class BorrowingReturnSheet extends StatefulWidget {
  final Transaction transaction;
  final TransactionService? transactionService;
  final VoidCallback? onSuccess;

  const BorrowingReturnSheet({
    super.key,
    required this.transaction,
    this.transactionService,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required Transaction transaction,
    TransactionService? transactionService,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BorrowingReturnSheet(
        transaction: transaction,
        transactionService: transactionService,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<BorrowingReturnSheet> createState() => _BorrowingReturnSheetState();
}

class _BorrowingReturnSheetState extends State<BorrowingReturnSheet> {
  late final TransactionService _transactionService;
  bool _isLostBook = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  ReturnTransactionResult? _result;

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

    try {
      final res = await _transactionService.requestReturn(
        transactionId: widget.transaction.id,
        isLostBook: _isLostBook,
      );

      if (mounted) {
        setState(() {
          _result = res;
          _isSubmitting = false;
        });
        widget.onSuccess?.call();
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
    final tr = widget.transaction;

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
            'Pengembalian Buku',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoalDark,
            ),
          ),
          const SizedBox(height: 12),

          // Transaction summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.bookTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kode: ${tr.transactionCode}',
                  style: const TextStyle(fontSize: 12, color: AppColors.charcoalMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tgl Pinjam: ${tr.formattedBorrowDate}',
                      style: const TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                    ),
                    Text(
                      'Batas: ${tr.formattedReturnDate}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mustardDark),
                    ),
                  ],
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

          if (_result != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _result!.isLate
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _result!.isLate
                      ? AppColors.warning.withValues(alpha: 0.4)
                      : AppColors.success.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _result!.isLate ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        color: _result!.isLate ? AppColors.warning : AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _result!.isLate
                              ? 'Pengembalian Terlambat'
                              : 'Pengembalian Diajukan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _result!.isLate ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _result!.message,
                    style: const TextStyle(fontSize: 12, color: AppColors.charcoalDark),
                  ),
                  if (_result!.fineAmount > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Estimasi Denda: ${CurrencyUtils.formatRupiah(_result!.fineAmount)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Selesai',
              isFullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ] else ...[
            const SizedBox(height: 16),

            // Checkbox lost book
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Buku hilang / rusak saat dipinjam',
                style: TextStyle(fontSize: 13, color: AppColors.charcoalDark),
              ),
              value: _isLostBook,
              activeColor: AppColors.danger,
              onChanged: (val) => setState(() => _isLostBook = val ?? false),
            ),

            const SizedBox(height: 16),

            AppButton(
              text: 'Ajukan Pengembalian Buku',
              isFullWidth: true,
              isLoading: _isSubmitting,
              icon: const Icon(Icons.assignment_return_outlined, size: 18),
              onPressed: _handleSubmit,
            ),
          ],
        ],
      ),
    );
  }
}
