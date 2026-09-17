import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../models/bookmark.dart';
import '../../services/book_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/error_utils.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/app_text_field.dart';
import 'components/book_detail_sheet.dart';

class MemberBookmarkScreen extends StatefulWidget {
  final BookService? bookService;

  const MemberBookmarkScreen({super.key, this.bookService});

  @override
  State<MemberBookmarkScreen> createState() => _MemberBookmarkScreenState();
}

class _MemberBookmarkScreenState extends State<MemberBookmarkScreen> {
  late final BookService _bookService;
  final _searchController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<BookmarkItem> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _bookService = widget.bookService ?? BookService();
    _fetchBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookmarks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _bookService.getBookmarks(
        search: _searchController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _bookmarks = items;
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

  Future<void> _handleDeleteBookmark(BookmarkItem item) async {
    final confirmed = await AppModal.showConfirmDialog(
      context,
      title: 'Hapus Bookmark',
      message: 'Apakah Anda yakin ingin menghapus "${item.title}" dari bookmark?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await _bookService.deleteBookmark(item.id);
      if (success && mounted) {
        setState(() {
          _bookmarks.removeWhere((b) => b.id == item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buku berhasil dihapus dari bookmark'),
            backgroundColor: AppColors.charcoalDark,
          ),
        );
      }
    }
  }

  void _openBookDetail(BookmarkItem item) {
    final book = Book(
      id: item.bookId,
      judul: item.title,
      penulis: item.author,
      isbn: '',
      penerbit: '',
      tipeBuku: item.bookType,
      cover: item.cover,
    );

    BookDetailSheet.show(
      context,
      book: book,
      bookService: _bookService,
      onBookmarkChanged: _fetchBookmarks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buku Tersimpan (Bookmark)'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.charcoalDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppTextField(
                hintText: 'Cari dalam buku tersimpan...',
                controller: _searchController,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _fetchBookmarks();
                        },
                      )
                    : null,
                onSubmitted: (_) => _fetchBookmarks(),
              ),
            ),

            // Content List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchBookmarks,
                color: AppColors.mustard,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mustard),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.charcoalMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchBookmarks,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border, size: 64, color: AppColors.charcoalMuted.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Buku Tersimpan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Simpan buku favorit Anda dari katalog untuk dibaca atau dipinjam nanti.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.charcoalMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _bookmarks[index];
        return AppCard(
          padding: const EdgeInsets.all(12),
          onTap: () => _openBookDetail(item),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: item.cover != null && item.cover!.startsWith('http')
                    ? Image.network(
                        item.cover!,
                        width: 55,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBadge(
                      label: item.bookType,
                      variant: item.isDigital
                          ? AppBadgeVariant.info
                          : AppBadgeVariant.mustard,
                      size: AppBadgeSize.sm,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Penulis: ${item.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.charcoalMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                tooltip: 'Hapus bookmark',
                onPressed: () => _handleDeleteBookmark(item),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 55,
      height: 75,
      color: AppColors.mustardLight,
      alignment: Alignment.center,
      child: const Icon(Icons.book, size: 24, color: AppColors.mustardDark),
    );
  }
}
