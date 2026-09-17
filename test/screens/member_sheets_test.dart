import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitako_mobile/models/index.dart';
import 'package:sitako_mobile/providers/auth_provider.dart';
import 'package:sitako_mobile/screens/member/components/book_detail_sheet.dart';
import 'package:sitako_mobile/screens/member/components/borrowing_request_sheet.dart';
import 'package:sitako_mobile/screens/member/components/borrowing_return_sheet.dart';
import 'package:sitako_mobile/screens/member/components/edit_profile_sheet.dart';
import 'package:sitako_mobile/screens/member/member_bookmark_screen.dart';
import 'package:sitako_mobile/screens/member/member_fine_screen.dart';
import 'package:sitako_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider authProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authProvider = AuthProvider();
  });

  Widget wrapWithScaffold(Widget child) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  const dummyBook = Book(
    id: 'bk-101',
    judul: 'Pemrograman Flutter Lanjut',
    penulis: 'Tim Pengembang Sitako',
    isbn: '978-602-000-000-0',
    penerbit: 'Penerbit IT',
    tipeBuku: 'Fisik',
    tahunTerbit: 2024,
    jumlahStok: 5,
    genre: ['Teknologi', 'Pemrograman'],
  );


  group('BookDetailSheet', () {
    testWidgets('renders book details and action buttons', (tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          const BookDetailSheet(book: dummyBook),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pemrograman Flutter Lanjut'), findsOneWidget);
      expect(find.textContaining('Tim Pengembang Sitako'), findsOneWidget);
      expect(find.textContaining('Penerbit IT'), findsOneWidget);
      expect(find.text('Ajukan Peminjaman'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });
  });

  group('BorrowingRequestSheet', () {
    testWidgets('renders borrowing duration options and submit button',
        (tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          const BorrowingRequestSheet(book: dummyBook),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ajukan Peminjaman Buku'), findsOneWidget);
      expect(find.text('Durasi Peminjaman'), findsOneWidget);
      expect(find.text('Konfirmasi Ajukan Pinjam'), findsOneWidget);
    });
  });

  group('BorrowingReturnSheet', () {
    testWidgets('renders transaction info and return confirmation button',
        (tester) async {
      final trx = Transaction(
        id: 'trx-ret-1',
        kdTransaksi: 'TRX-2026-RET',
        status: 'Dipinjam',
        judulBuku: 'Pemrograman Flutter Lanjut',
        namaAnggota: 'Ahmad Fauzi',
        tglPinjam: DateTime.now().subtract(const Duration(days: 3)),
        tglKembali: DateTime.now().add(const Duration(days: 4)),
      );

      await tester.pumpWidget(
        wrapWithScaffold(
          BorrowingReturnSheet(transaction: trx),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pengembalian Buku'), findsOneWidget);
      expect(find.textContaining('TRX-2026-RET'), findsOneWidget);
      expect(find.text('Ajukan Pengembalian Buku'), findsOneWidget);
    });
  });

  group('EditProfileSheet', () {
    testWidgets('renders profile fields with user data', (tester) async {
      const user = User(
        id: 'usr-1',
        nama: 'Ahmad Fauzi',
        email: 'ahmad@sitako.sch.id',
        telepon: '081234567890',
        nis: '12345',
      );

      await tester.pumpWidget(
        wrapWithScaffold(
          const EditProfileSheet(user: user),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Informasi Profil'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Nomor Telepon / WhatsApp'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });
  });

  group('MemberBookmarkScreen', () {
    testWidgets('renders title and search field without error',
        (tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          const MemberBookmarkScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Buku Tersimpan (Bookmark)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('MemberFineScreen', () {
    testWidgets('renders title and summary card without error', (tester) async {
      await tester.pumpWidget(
        wrapWithScaffold(
          const MemberFineScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Riwayat & Tagihan Denda'), findsOneWidget);
      expect(find.text('Total Tagihan Denda Aktif'), findsOneWidget);
    });
  });
}


