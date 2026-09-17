import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_utils.dart';
import '../../utils/error_utils.dart';
import '../../utils/transaction_utils.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_card.dart';
import 'components/borrowing_return_sheet.dart';

class MemberBorrowingScreen extends StatefulWidget {
  final TransactionService? transactionService;

  const MemberBorrowingScreen({super.key, this.transactionService});

  @override
  State<MemberBorrowingScreen> createState() => _MemberBorrowingScreenState();
}

class _MemberBorrowingScreenState extends State<MemberBorrowingScreen> {
  late final TransactionService _transactionService;
  bool _isLoading = false;
  String? _errorMessage;
  List<Transaction> _transactions = [];
  String _selectedStatus = 'Semua';

  final List<String> _statusFilters = [
    'Semua',
    'Dipinjam',
    'Menunggu',
    'Dikembalikan',
    'Terlambat',
  ];

  @override
  void initState() {
    super.initState();
    _transactionService = widget.transactionService ?? TransactionService();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactions = await _transactionService.getMemberTransactions(
        status: _selectedStatus,
      );

      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorUtils.getErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.mustard),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _transactions.isEmpty
                          ? _buildEmptyState()
                          : _buildTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statusFilters.map((status) {
            final isSelected = _selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status),
                selected: isSelected,
                selectedColor: AppColors.mustardLight,
                checkmarkColor: AppColors.charcoalDark,
                backgroundColor: AppColors.background,
                side: BorderSide(
                  color: isSelected ? AppColors.mustard : AppColors.border,
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.charcoalDark : AppColors.charcoal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedStatus = status;
                    });
                    _fetchTransactions();
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return RefreshIndicator(
      onRefresh: _fetchTransactions,
      color: AppColors.mustard,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          final bookTitle = tx.judulBuku.isNotEmpty ? tx.judulBuku : 'Buku Perpustakaan';
          final badgeVariant = TransactionUtils.getAppBadgeVariant(tx.status);
          final dueInfo = TransactionUtils.getDueStatus(tx.tglKembali);
          final canReturn = tx.status == 'Dipinjam' || tx.status == 'Terlambat';

          return AppCard(
            padding: const EdgeInsets.all(14),
            onTap: canReturn
                ? () => BorrowingReturnSheet.show(
                      context,
                      transaction: tx,
                      transactionService: _transactionService,
                      onSuccess: _fetchTransactions,
                    )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx.kodeTransaksi,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    AppBadge(
                      label: tx.status,
                      size: AppBadgeSize.sm,
                      variant: badgeVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bookTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tgl Pinjam',
                            style: TextStyle(fontSize: 10, color: AppColors.charcoalMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppDateUtils.formatDate(tx.tglPinjam),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tenggat Kembali',
                            style: TextStyle(fontSize: 10, color: AppColors.charcoalMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppDateUtils.formatDate(tx.tglKembali),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dueInfo['isOverdue'] == true
                                  ? AppColors.danger
                                  : AppColors.charcoalDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (dueInfo['text'] != null && tx.status == 'Dipinjam') ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: dueInfo['isOverdue'] == true
                          ? AppColors.dangerLight
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dueInfo['text'].toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: dueInfo['isOverdue'] == true
                            ? AppColors.dangerText
                            : AppColors.warningText,
                      ),
                    ),
                  ),
                ],
                if (canReturn) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.charcoalDark,
                        side: const BorderSide(color: AppColors.mustard),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.assignment_return_outlined, size: 16),
                      label: const Text(
                        'Ajukan Pengembalian',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => BorrowingReturnSheet.show(
                        context,
                        transaction: tx,
                        transactionService: _transactionService,
                        onSuccess: _fetchTransactions,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.mustardLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, size: 28, color: AppColors.mustardHover),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Peminjaman',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Riwayat peminjaman buku Anda akan tercatat secara otomatis di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.charcoalMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Gagal memuat daftar peminjaman',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchTransactions,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.mustard),
              child: const Text('Coba Lagi', style: TextStyle(color: AppColors.charcoalDark)),
            ),
          ],
        ),
      ),
    );
  }
}
