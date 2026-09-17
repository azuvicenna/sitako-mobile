import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitako_mobile/models/user.dart';
import 'package:sitako_mobile/providers/auth_provider.dart';
import 'package:sitako_mobile/screens/auth/login_screen.dart';
import 'package:sitako_mobile/screens/errors/not_found_screen.dart';
import 'package:sitako_mobile/screens/member/member_borrowing_screen.dart';
import 'package:sitako_mobile/screens/member/member_catalog_screen.dart';
import 'package:sitako_mobile/screens/member/member_dashboard_screen.dart';
import 'package:sitako_mobile/screens/member/member_main_screen.dart';
import 'package:sitako_mobile/screens/member/member_profile_screen.dart';
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

  group('LoginScreen', () {
    testWidgets('renders all essential login elements with NIS field',
        (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('NIS'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Kode Verifikasi (CAPTCHA)'), findsOneWidget);
      expect(find.text('Masuk ke Sistem'), findsOneWidget);
    });

    testWidgets('displays form validation error when submitting empty fields',
        (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const LoginScreen()));
      await tester.pumpAndSettle();

      final submitButton = find.text('Masuk ke Sistem');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('NIS wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
      expect(find.text('Kode CAPTCHA wajib diisi'), findsOneWidget);
    });

    testWidgets('toggles password visibility icon', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('MemberMainScreen & Sub-screens', () {
    testWidgets('renders MemberMainScreen with navigation bar destinations',
        (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const MemberMainScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Beranda Anggota'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Beranda'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Katalog'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Peminjaman'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Profil'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('switches tab to Katalog when clicked', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const MemberMainScreen()));
      await tester.pumpAndSettle();

      final navKatalog = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Katalog'),
      );
      await tester.tap(navKatalog);
      await tester.pumpAndSettle();

      expect(find.text('Katalog Buku'), findsOneWidget);
    });

    testWidgets('switches tab to Peminjaman when clicked', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const MemberMainScreen()));
      await tester.pumpAndSettle();

      final navPeminjaman = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Peminjaman'),
      );
      await tester.tap(navPeminjaman);
      await tester.pumpAndSettle();

      expect(find.text('Peminjaman Saya'), findsOneWidget);
    });

    testWidgets('switches tab to Profil when clicked', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const MemberMainScreen()));
      await tester.pumpAndSettle();

      final navProfil = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profil'),
      );
      await tester.tap(navProfil);
      await tester.pumpAndSettle();

      expect(find.text('Profil Saya'), findsOneWidget);
    });
  });

  group('MemberDashboardScreen', () {
    testWidgets('renders greeting and statistical cards', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const MemberDashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Halo,'), findsOneWidget);
      expect(find.text('BUKU DIPINJAM'), findsOneWidget);
      expect(find.text('TOTAL DENDA'), findsOneWidget);
      expect(find.text('BOOKMARK'), findsOneWidget);
      expect(find.text('Peminjaman Aktif'), findsOneWidget);
      expect(find.text('Buku Tersimpan'), findsOneWidget);
    });
  });

  group('MemberCatalogScreen', () {
    testWidgets('renders search bar and type filter chips', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const MemberCatalogScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Fisik'), findsOneWidget);
      expect(find.text('Digital'), findsOneWidget);
    });
  });

  group('MemberBorrowingScreen', () {
    testWidgets('renders borrowing status filter chips', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const MemberBorrowingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Dipinjam'), findsOneWidget);
      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.text('Dikembalikan'), findsOneWidget);
      expect(find.text('Terlambat'), findsOneWidget);
    });
  });

  group('MemberProfileScreen', () {
    testWidgets('renders user profile details and logout button',
        (tester) async {
      final dummyUser = User(
        id: 'usr-1',
        nis: '12345678',
        nama: 'Siswa Contoh',
        role: 'Anggota',
        email: 'siswa@example.com',
        telepon: '08123456789',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sitako_user_data', jsonEncode(dummyUser.toJson()));

      final loggedInAuthProvider = AuthProvider();
      await loggedInAuthProvider.initialize();

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: loggedInAuthProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MemberProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Informasi Data Diri'), findsOneWidget);
      expect(find.text('Nomor Induk Siswa (NIS)'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Keluar dari Akun'), findsOneWidget);
    });
  });

  group('NotFoundScreen', () {
    testWidgets('renders 404 message and back buttons', (tester) async {
      await tester.pumpWidget(wrapWithScaffold(const NotFoundScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Galat 404'), findsOneWidget);
      expect(find.text('Halaman Tidak Ditemukan'), findsOneWidget);
      expect(find.text('Kembali ke Login'), findsOneWidget);
      expect(find.text('Halaman Sebelumnya'), findsOneWidget);
    });
  });
}
