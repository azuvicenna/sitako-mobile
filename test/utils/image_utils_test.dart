import 'package:flutter_test/flutter_test.dart';
import 'package:sitako_mobile/utils/image_utils.dart';

void main() {
  group('ImageUtils', () {
    group('getInitials', () {
      test('generates 2 uppercase initials for names with 2 or more words', () {
        expect(getInitials('Ahmad Fauzi'), equals('AF'));
        expect(getInitials('Atyla Azfa Al Harits'), equals('AA'));
      });

      test('generates 1 uppercase initial for single-word names', () {
        expect(getInitials('Suharto'), equals('S'));
        expect(getInitials('admin'), equals('A'));
      });

      test('returns fallback value when name is null or empty', () {
        expect(getInitials(''), equals('U'));
        expect(getInitials('   '), equals('U'));
        expect(getInitials(null), equals('U'));
        expect(getInitials(null, fallback: '?'), equals('?'));
      });
    });

    group('getAvatarColor', () {
      test('generates consistent color for the same input name', () {
        final color1 = getAvatarColor('Ahmad Fauzi');
        final color2 = getAvatarColor('Ahmad Fauzi');
        expect(color1, equals(color2));
      });

      test('handles null name safely without throwing', () {
        final color = getAvatarColor(null);
        expect(color, isNotNull);
      });
    });

    group('getInitialsAvatar (SVG Data URI)', () {
      test('generates SVG data URI with 2 initials', () {
        final dataUri = getInitialsAvatar('Ahmad Fauzi');
        expect(dataUri, startsWith('data:image/svg+xml;utf8,'));
        final decoded = Uri.decodeComponent(dataUri.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded, contains('AF'));
        expect(decoded, contains('#eab308'));
      });

      test('handles single-word name using first letter', () {
        final dataUri = getInitialsAvatar('Suharto');
        final decoded = Uri.decodeComponent(dataUri.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded, contains('S'));
      });

      test('uses custom background and foreground colors when provided', () {
        final dataUri = getInitialsAvatar('Budi Santoso', bg: '#3b82f6', fg: '#ffffff');
        final decoded = Uri.decodeComponent(dataUri.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded, contains('#3b82f6'));
        expect(decoded, contains('#ffffff'));
        expect(decoded, contains('BS'));
      });

      test('uses fallback initial U when name is empty', () {
        final dataUri = getInitialsAvatar('');
        final decoded = Uri.decodeComponent(dataUri.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded, contains('U'));
      });
    });

    group('getBookCoverPlaceholder (SVG Data URI)', () {
      test('generates SVG data URI for book cover with title', () {
        final dataUri = getBookCoverPlaceholder(title: 'Laskar Pelangi');
        expect(dataUri, startsWith('data:image/svg+xml;utf8,'));
        final decoded = Uri.decodeComponent(dataUri.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded, contains('Laskar Pelangi'));
        expect(decoded, contains('viewBox="0 0 200 300"'));
      });

      test('truncates titles longer than 24 characters for SVG display', () {
        const longTitle = 'Sistem Informasi Perpustakaan Berbasis Komputer Modern Terpadu';
        final dataUri = getBookCoverPlaceholder(title: longTitle);
        final decoded = Uri.decodeComponent(dataUri.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded, contains(longTitle.substring(0, 24)));
      });

      test('uses default title "Buku" when input is empty or null', () {
        final dataUri1 = getBookCoverPlaceholder(title: '');
        final decoded1 = Uri.decodeComponent(dataUri1.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded1, contains('Buku'));

        final dataUri2 = getBookCoverPlaceholder(title: null);
        final decoded2 = Uri.decodeComponent(dataUri2.replaceFirst('data:image/svg+xml;utf8,', ''));
        expect(decoded2, contains('Buku'));
      });
    });
  });
}
