import 'package:flutter/material.dart';
import '../../models/fine_payment.dart';
import '../../services/fine_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_utils.dart';
import '../../utils/error_utils.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_card.dart';

class MemberFineScreen extends StatefulWidget {
  final FineService? fineService;
  final int initialUnpaidFine;

  const MemberFineScreen({
    super.key,
    this.fineService,
    this.initialUnpaidFine = 0,
  });

  @override
  State<MemberFineScreen> createState() => _MemberFineScreenState();
}

class _MemberFineScreenState extends State<MemberFineScreen> {
  late final FineService _fineService;
  bool _isLoading = false;
  String? _errorMessage;
  List<FinePaymentItem> _fines = [];

  @override
  void initState() {
    super.initState();
    _fineService = widget.fineService ?? FineService();
    _fetchFines();
  }

  Future<void> _fetchFines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _fineService.getMemberFines();
      if (mounted) {
        setState(() {
          _fines = items;
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
    final unpaidTotal = _fines
        .where((f) => !f.isPaid)
        .fold<int>(0, (sum, f) => sum + f.fineAmount);

    final displayUnpaid = unpaidTotal > 0 ? unpaidTotal : widget.initialUnpaidFine;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat & Tagihan Denda'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.charcoalDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchFines,
          color: AppColors.mustard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card
              AppCard(
                padding: const EdgeInsets.all(18),
                color: displayUnpaid > 0
                    ? AppColors.danger.withValues(alpha: 0.05)
                    : AppColors.success.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: displayUnpaid > 0
                            ? AppColors.danger.withValues(alpha: 0.15)
                            : AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        displayUnpaid > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: displayUnpaid > 0 ? AppColors.danger : AppColors.success,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Tagihan Denda Aktif',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.charcoalMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyUtils.formatRupiah(displayUnpaid),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: displayUnpaid > 0 ? AppColors.danger : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Daftar Pembayaran Denda',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 12),

              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.mustard),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.charcoalMuted)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchFines, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    if (_fines.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.charcoalMuted.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              const Text(
                'Tidak Ada Riwayat Denda',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Anda tidak memiliki tagihan denda keterlambatan saat ini.',
                style: TextStyle(fontSize: 12, color: AppColors.charcoalMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final fine = _fines[index];
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fine.transactionCode,
                    style: const TextStyle(fontSize: 12, color: AppColors.charcoalMuted),
                  ),
                  AppBadge(
                    label: fine.isPaid ? 'Lunas' : 'Belum Bayar',
                    variant: fine.isPaid ? AppBadgeVariant.success : AppBadgeVariant.danger,
                    size: AppBadgeSize.sm,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                fine.bookTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Metode: ${fine.paymentMethod}',
                    style: const TextStyle(fontSize: 12, color: AppColors.charcoalMuted),
                  ),
                  Text(
                    CurrencyUtils.formatRupiah(fine.fineAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                ],
              ),
              if (fine.isPaid && fine.paymentDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Dibayar: ${fine.formattedPaymentDate}',
                  style: const TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
