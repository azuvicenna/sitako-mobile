import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/error_utils.dart';
import '../../utils/image_utils.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import 'components/book_detail_sheet.dart';

class MemberCatalogScreen extends StatefulWidget {
  final BookService? bookService;

  const MemberCatalogScreen({super.key, this.bookService});

  @override
  State<MemberCatalogScreen> createState() => _MemberCatalogScreenState();
}

class _MemberCatalogScreenState extends State<MemberCatalogScreen> {
  late final BookService _bookService;
  final _searchController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<Book> _books = [];
  String _selectedType = 'Semua';

  @override
  void initState() {
    super.initState();
    _bookService = widget.bookService ?? BookService();
    _fetchBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _bookService.getBooks(
        search: _searchController.text.trim(),
        bookType: _selectedType,
      );

      if (mounted) {
        setState(() {
          _books = books;
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
            _buildSearchAndFilters(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.mustard),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _books.isEmpty
                          ? _buildEmptyState()
                          : _buildBookGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          AppTextField(
            controller: _searchController,
            hintText: 'Cari judul buku, penulis, atau penerbit...',
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.charcoalMuted),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _fetchBooks();
                    },
                  )
                : null,
            onSubmitted: (_) => _fetchBooks(),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'Fisik', 'Digital'].map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
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
                          _selectedType = type;
                        });
                        _fetchBooks();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid() {
    return RefreshIndicator(
      onRefresh: _fetchBooks,
      color: AppColors.mustard,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          final hasStock = book.stokTersedia > 0;

          return AppCard(
            padding: const EdgeInsets.all(10),
            onTap: () => BookDetailSheet.show(
              context,
              book: book,
              bookService: _bookService,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ImageUtils.getAvatarColor(book.judul).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (book.cover != null && book.cover!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book.cover!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildCoverFallback(book.judul),
                            ),
                          )
                        : _buildCoverFallback(book.judul),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    AppBadge(
                      label: hasStock ? 'Tersedia' : 'Habis',
                      size: AppBadgeSize.sm,
                      variant: hasStock ? AppBadgeVariant.success : AppBadgeVariant.danger,
                    ),
                    const Spacer(),
                    if (book.kategori != null && book.kategori!.isNotEmpty)
                      Expanded(
                        child: Text(
                          book.kategori!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 10, color: AppColors.charcoalMuted),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  book.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.penulis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoverFallback(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 28, color: AppColors.charcoalMuted),
            const SizedBox(height: 4),
            Text(
              ImageUtils.getInitials(title),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalDark,
              ),
            ),
          ],
        ),
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
              child: const Icon(Icons.search_off, size: 28, color: AppColors.mustardHover),
            ),
            const SizedBox(height: 12),
            const Text(
              'Buku Tidak Ditemukan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coba ubah kata kunci pencarian atau filter kategori yang dipilih.',
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
              _errorMessage ?? 'Terjadi kesalahan memuat katalog',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchBooks,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.mustard),
              child: const Text('Coba Lagi', style: TextStyle(color: AppColors.charcoalDark)),
            ),
          ],
        ),
      ),
    );
  }
}
