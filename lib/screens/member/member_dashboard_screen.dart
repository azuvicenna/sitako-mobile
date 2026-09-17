import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dashboard_data.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/dashboard_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_utils.dart';
import '../../utils/error_utils.dart';
import '../../utils/image_utils.dart';
import '../../utils/transaction_utils.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class MemberDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  final DashboardService? dashboardService;

  const MemberDashboardScreen({
    super.key,
    this.onNavigateTab,
    this.dashboardService,
  });

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  late final DashboardService _dashboardService;
  bool _isLoading = false;
  String? _errorMessage;

  int _bukuDipinjam = 0;
  int _totalDenda = 0;
  int _totalBookmark = 0;

  List<ActiveLoanItem> _activeLoans = [];
  List<RecentBookmarkItem> _recentBookmarks = [];

  @override
  void initState() {
    super.initState();
    _dashboardService = widget.dashboardService ?? DashboardService();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _dashboardService.getDashboardData();

      if (mounted) {
        setState(() {
          _bukuDipinjam = data.statistics.borrowedBooksCount;
          _totalDenda = data.statistics.totalFines;
          _totalBookmark = data.statistics.totalBookmarks;
          _activeLoans = data.activeLoans;
          _recentBookmarks = data.recentBookmarks;
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
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.nama ?? 'Anggota Perpustakaan';

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.mustard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(userName),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              AppAlert(
                variant: AppAlertVariant.danger,
                title: 'Gagal Memuat Dashboard',
                description: _errorMessage,
                action: TextButton(
                  onPressed: _loadDashboardData,
                  child: const Text('Coba Lagi'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildStatsCards(),
            if (_totalDenda > 0) ...[
              const SizedBox(height: 16),
              _buildFineAlert(),
            ],
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildActiveLoansSection(),
            const SizedBox(height: 16),
            _buildRecentBookmarksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(String userName) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $userName 👋',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pantau buku yang sedang Anda pinjam, tenggat pengembalian, dan riwayat bacaan Anda.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.charcoalMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _isLoading ? null : _loadDashboardData,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: AppColors.charcoal),
            tooltip: 'Segarkan Data',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppAccentCard(
                accentColor: AppColors.mustard,
                onTap: () => widget.onNavigateTab?.call(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BUKU DIPINJAM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoalMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Icon(Icons.menu_book_rounded, size: 16, color: AppColors.charcoal),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_bukuDipinjam',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sedang aktif',
                      style: TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppAccentCard(
                accentColor: AppColors.info,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.bookmarks),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BOOKMARK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoalMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Icon(Icons.bookmark_border, size: 16, color: AppColors.info),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_totalBookmark',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Buku wishlist',
                      style: TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppAccentCard(
          accentColor: _totalDenda > 0 ? AppColors.danger : AppColors.success,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.fines),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL DENDA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatRupiah(_totalDenda),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _totalDenda > 0 ? AppColors.danger : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _totalDenda > 0 ? 'Menunggu pembayaran' : 'Bebas tanggungan',
                    style: const TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                  ),
                ],
              ),
              Icon(
                Icons.payments_outlined,
                size: 32,
                color: _totalDenda > 0 ? AppColors.danger : AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFineAlert() {
    return AppAlert(
      variant: AppAlertVariant.danger,
      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
      title: 'Anda Memiliki Tagihan Denda Aktif',
      description:
          'Total kewajiban denda: ${CurrencyUtils.formatRupiah(_totalDenda)}. Silakan selesaikan pembayaran di perpustakaan untuk memulihkan akses peminjaman buku baru.',
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mustardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mustard.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search, size: 18, color: AppColors.charcoalDark),
              SizedBox(width: 8),
              Text(
                'Mencari Koleksi Buku Baru?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Jelajahi ribuan koleksi buku fisik maupun materi perpustakaan SITAKO.',
            style: TextStyle(fontSize: 12, color: AppColors.charcoal),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Buka Katalog',
                  variant: AppButtonVariant.primary,
                  icon: const Icon(Icons.book, size: 16),
                  onPressed: () => widget.onNavigateTab?.call(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Peminjaman',
                  variant: AppButtonVariant.secondary,
                  icon: const Icon(Icons.history, size: 16),
                  onPressed: () => widget.onNavigateTab?.call(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLoansSection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Peminjaman Aktif',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigateTab?.call(2),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mustardHover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_activeLoans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.mustardLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book, color: AppColors.mustardHover, size: 22),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tidak Ada Peminjaman Aktif',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Saat ini Anda tidak memiliki buku yang sedang dipinjam.',
                      style: TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeLoans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _activeLoans[index];
                final judul = item.bookTitle.isNotEmpty ? item.bookTitle : 'Judul Buku';
                final status = item.status;
                final tglKembali = item.returnDate != null ? item.formattedReturnDate : null;

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.book, color: AppColors.charcoalMuted, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppBadge(
                              label: status,
                              size: AppBadgeSize.sm,
                              variant: TransactionUtils.getAppBadgeVariant(status),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              judul,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoalDark,
                              ),
                            ),
                            if (tglKembali != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Batas: $tglKembali',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.charcoalMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentBookmarksSection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Buku Tersimpan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.bookmarks),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mustardHover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentBookmarks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_border, color: AppColors.info, size: 22),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum Ada Bookmark',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Simpan buku favorit Anda di katalog untuk dibaca nanti.',
                      style: TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentBookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _recentBookmarks[index];
                final judul = item.bookTitle.isNotEmpty ? item.bookTitle : 'Judul Buku';
                final penulis = item.bookAuthor.isNotEmpty ? item.bookAuthor : '-';

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 52,
                        decoration: BoxDecoration(
                          color: ImageUtils.getAvatarColor(judul).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ImageUtils.getInitials(judul),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ImageUtils.getAvatarColor(judul),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              judul,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoalDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Penulis: $penulis',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.charcoalMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
