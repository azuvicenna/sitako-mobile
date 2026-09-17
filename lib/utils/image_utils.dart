import 'package:flutter/material.dart';

class ImageUtils {
  ImageUtils._();

  static const List<Color> _avatarColors = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
    Color(0xFFF97316),
  ];

  static String getInitials(String? name, {String fallback = 'U'}) {
    if (name == null || name.trim().isEmpty) {
      return fallback;
    }

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return fallback;

    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : fallback;
    }

    final first = words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    final second = words[1].isNotEmpty ? words[1][0].toUpperCase() : '';

    final result = '$first$second';
    return result.isNotEmpty ? result : fallback;
  }

  static Color getAvatarColor(String? name) {
    if (name == null || name.trim().isEmpty) {
      return const Color(0xFFEAB308);
    }
    final hash = name.trim().codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    return _avatarColors[hash % _avatarColors.length];
  }

  static String getInitialsAvatarSvg(
    String? name, {
    String bg = '#eab308',
    String fg = '#1f2937',
  }) {
    final initials = getInitials(name);
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">'
        '<rect width="100" height="100" fill="$bg"/>'
        '<text x="50" y="55" dominant-baseline="middle" text-anchor="middle" '
        'font-family="system-ui, -apple-system, sans-serif" font-size="38" font-weight="700" fill="$fg">'
        '$initials'
        '</text>'
        '</svg>';
    return 'data:image/svg+xml;utf8,${Uri.encodeComponent(svg)}';
  }

  static String getBookCoverPlaceholderSvg({String? title = 'Buku'}) {
    final effectiveTitle = (title == null || title.trim().isEmpty) ? 'Buku' : title.trim();
    final shortTitle = effectiveTitle.length > 24 ? effectiveTitle.substring(0, 24) : effectiveTitle;

    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 300" width="200" height="300">'
        '<defs>'
        '<linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%">'
        '<stop offset="0%" stop-color="#3b82f6"/>'
        '<stop offset="100%" stop-color="#1d4ed8"/>'
        '</linearGradient>'
        '</defs>'
        '<rect width="200" height="300" rx="8" fill="url(#g)"/>'
        '<rect x="10" y="10" width="180" height="280" rx="6" fill="none" stroke="rgba(255,255,255,0.25)" stroke-width="2"/>'
        '<g fill="rgba(255,255,255,0.85)" transform="translate(80, 105)">'
        '<path d="M20 0C9 0 0 9 0 20v20c0 2 2 4 4 4h32c2 0 4-2 4-4V20C40 9 31 0 20 0zm-2 34H8v-6h10v6zm0-10H8v-6h10v6zm14 10H22v-6h10v6zm0-10H22v-6h10v6z"/>'
        '</g>'
        '<text x="100" y="180" dominant-baseline="middle" text-anchor="middle" '
        'font-family="system-ui, -apple-system, sans-serif" font-size="13" font-weight="600" fill="#ffffff">'
        '$shortTitle'
        '</text>'
        '</svg>';

    return 'data:image/svg+xml;utf8,${Uri.encodeComponent(svg)}';
  }
}

String getInitials(String? name, {String fallback = 'U'}) =>
    ImageUtils.getInitials(name, fallback: fallback);

Color getAvatarColor(String? name) => ImageUtils.getAvatarColor(name);

String getInitialsAvatar(
  String? name, {
  String bg = '#eab308',
  String fg = '#1f2937',
}) =>
    ImageUtils.getInitialsAvatarSvg(name, bg: bg, fg: fg);

String getBookCoverPlaceholder({String? title = 'Buku'}) =>
    ImageUtils.getBookCoverPlaceholderSvg(title: title);
