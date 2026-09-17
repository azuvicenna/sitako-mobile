import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitako_mobile/main.dart';
import 'package:sitako_mobile/utils/api_client.dart';
import 'mock_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ApiClient.setMockClient(MockData.createMockClient());
  });

  tearDown(() {
    ApiClient.setMockClient(null);
  });

  group('01 - Auth E2E Flows', () {
    testWidgets('renders login screen with inputs and validates empty submission',
        (tester) async {
      await tester.pumpWidget(const SitakoApp());
      await tester.pumpAndSettle();

      expect(find.text('SITAKO'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('NIS'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Kode Verifikasi (CAPTCHA)'), findsOneWidget);

      final submitBtn = find.text('Masuk ke Sistem');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('NIS wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
      expect(find.text('Kode CAPTCHA wajib diisi'), findsOneWidget);
    });

    testWidgets('displays error alert on invalid credentials', (tester) async {
      await tester.pumpWidget(const SitakoApp());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'wrong-nis');
      await tester.enterText(textFields.at(1), 'wrong-pass');
      await tester.enterText(textFields.at(2), 'ABCD');

      final submitBtn = find.text('Masuk ke Sistem');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('NIS atau kata sandi yang Anda masukkan salah'),
        findsOneWidget,
      );
    });

    testWidgets('logs in successfully as member and redirects to dashboard',
        (tester) async {
      await tester.pumpWidget(const SitakoApp());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '20251001');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'ABCD');

      final submitBtn = find.text('Masuk ke Sistem');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Beranda Anggota'), findsOneWidget);
      expect(find.textContaining('Budi Santoso'), findsOneWidget);
    });
  });

  group('03 - Member Views E2E Flows', () {
    testWidgets('navigates through member dashboard, catalog, borrowing, and profile with logout',
        (tester) async {
      await tester.pumpWidget(const SitakoApp());
      await tester.pumpAndSettle();

      // Login first
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '20251001');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'ABCD');

      final submitBtn = find.text('Masuk ke Sistem');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // 1. DASHBOARD VIEW: Verify stats & fixture cards
      expect(find.textContaining('Halo, Budi Santoso'), findsOneWidget);
      expect(find.text('BUKU DIPINJAM'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('TOTAL DENDA'), findsOneWidget);
      expect(find.text('Rp 5.000'), findsOneWidget);
      expect(find.text('BOOKMARK'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Laskar Pelangi'), findsOneWidget);
      expect(find.text('Clean Code'), findsOneWidget);

      // 2. KATALOG VIEW: Tap Katalog in NavigationBar
      final navKatalog = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Katalog'),
      );
      await tester.tap(navKatalog);
      await tester.pumpAndSettle();

      expect(find.text('Katalog Buku'), findsOneWidget);
      expect(find.text('Laskar Pelangi'), findsOneWidget);
      expect(find.text('Clean Code'), findsOneWidget);
      expect(find.text('Fisik'), findsOneWidget);
      expect(find.text('Digital'), findsOneWidget);

      // 3. PEMINJAMAN VIEW: Tap Peminjaman in NavigationBar
      final navPeminjaman = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Peminjaman'),
      );
      await tester.tap(navPeminjaman);
      await tester.pumpAndSettle();

      expect(find.text('Peminjaman Saya'), findsOneWidget);
      expect(find.text('TRX-20260910-001'), findsOneWidget);
      expect(find.text('Laskar Pelangi'), findsOneWidget);
      expect(find.text('Dipinjam'), findsNWidgets(2));

      // 4. PROFIL VIEW & LOGOUT: Tap Profil in NavigationBar
      final navProfil = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profil'),
      );
      await tester.tap(navProfil);
      await tester.pumpAndSettle();

      expect(find.text('Profil Saya'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsNWidgets(2));
      expect(find.text('20251001'), findsOneWidget);
      expect(find.text('budi.santoso@siswa.sch.id'), findsOneWidget);

      final logoutBtn = find.text('Keluar dari Akun');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Keluar'), findsOneWidget);

      // Confirm Logout dialog
      final confirmBtn = find.text('Keluar');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Back to Login Screen
      expect(find.text('Masuk ke Akun'), findsOneWidget);
    });
  });
}
