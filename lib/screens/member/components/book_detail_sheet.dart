import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/book.dart';
import '../../../services/book_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_badge.dart';
import '../../../widgets/app_button.dart';
import 'borrowing_request_sheet.dart';

class BookDetailSheet extends StatefulWidget {
  final Book book;
  final BookService? bookService;
  final VoidCallback? onBookmarkChanged;

  const BookDetailSheet({
    super.key,
    required this.book,
    this.bookService,
    this.onBookmarkChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required Book book,
    BookService? bookService,
    VoidCallback? onBookmarkChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookDetailSheet(
        book: book,
        bookService: bookService,
        onBookmarkChanged: onBookmarkChanged,
      ),
    );
  }

  @override
  State<BookDetailSheet> createState() => _BookDetailSheetState();
}

class _BookDetailSheetState extends State<BookDetailSheet> {
  late final BookService _bookService;
  bool _isBookmarking = false;
  bool _isBookmarked = false;
  bool _isLoadingDigital = false;

  @override
  void initState() {
    super.initState();
    _bookService = widget.bookService ?? BookService();
  }

  Future<void> _handleToggleBookmark() async {
    setState(() => _isBookmarking = true);
    final success = _isBookmarked
        ? await _bookService.deleteBookmark(widget.book.id)
        : await _bookService.addBookmark(widget.book.id);

    if (mounted) {
      setState(() {
        _isBookmarking = false;
        if (success) {
          _isBookmarked = !_isBookmarked;
        }
      });
      if (success) {
        widget.onBookmarkChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBookmarked
                  ? 'Buku berhasil disimpan ke bookmark'
                  : 'Bookmark buku dihapus',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.charcoalDark,
          ),
        );
      }
    }
  }

  Future<void> _handleReadDigital() async {
    setState(() => _isLoadingDigital = true);
    final url = await _bookService.readDigitalBook(widget.book.id);
    if (!mounted) return;

    setState(() {
      _isLoadingDigital = false;
    });

    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka tautan buku: $url'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuka buku digital: ${e.toString()}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berkas digital belum tersedia untuk buku ini'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openBorrowingRequest() {
    Navigator.of(context).pop();
    BorrowingRequestSheet.show(
      context,
      book: widget.book,
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final category = book.kategori ?? 'Umum';

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

          // Header with Cover & Basic Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.cover != null && book.cover!.startsWith('http')
                    ? Image.network(
                        book.cover!,
                        width: 80,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                      )
                    : _buildPlaceholderCover(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppBadge(
                          label: book.bookType,
                          variant: book.isDigital
                              ? AppBadgeVariant.info
                              : AppBadgeVariant.mustard,
                          size: AppBadgeSize.sm,
                        ),
                        const SizedBox(width: 6),
                        AppBadge(
                          label: category,
                          variant: AppBadgeVariant.neutral,
                          size: AppBadgeSize.sm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Penulis: ${book.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.charcoalMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Penerbit: ${book.publisher}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.charcoalMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),

          // Details Grid
          Row(
            children: [
              Expanded(
                child: _buildDetailCell(
                  'Tahun Terbit',
                  book.publishYear > 0 ? book.publishYear.toString() : '-',
                ),
              ),
              Expanded(
                child: _buildDetailCell(
                  'ISBN',
                  book.isbn.isNotEmpty ? book.isbn : '-',
                ),
              ),
              Expanded(
                child: _buildDetailCell(
                  'Ketersediaan',
                  book.isDigital
                      ? 'Tersedia (PDF)'
                      : (book.isAvailable
                          ? '${book.stockCount} eks'
                          : 'Habis'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              // Bookmark Button
              IconButton(
                onPressed: _isBookmarking ? null : _handleToggleBookmark,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.neutralLight,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                icon: _isBookmarking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: _isBookmarked
                            ? AppColors.mustard
                            : AppColors.charcoalDark,
                      ),
              ),
              const SizedBox(width: 12),

              // Main Action Button
              Expanded(
                child: book.isDigital
                    ? AppButton(
                        text: 'Baca Buku Digital',
                        icon: const Icon(Icons.menu_book, size: 18),
                        isLoading: _isLoadingDigital,
                        onPressed: _handleReadDigital,
                      )
                    : AppButton(
                        text: book.isAvailable
                            ? 'Ajukan Peminjaman'
                            : 'Stok Tidak Tersedia',
                        icon: const Icon(Icons.assignment_turned_in, size: 18),
                        onPressed:
                            book.isAvailable ? _openBorrowingRequest : null,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: 80,
      height: 110,
      color: AppColors.mustardLight,
      alignment: Alignment.center,
      child: const Icon(Icons.book, size: 36, color: AppColors.mustardDark),
    );
  }

  Widget _buildDetailCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoalDark,
          ),
        ),
      ],
    );
  }
}
