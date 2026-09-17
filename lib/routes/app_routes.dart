import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/errors/not_found_screen.dart';
import '../screens/member/member_borrowing_screen.dart';
import '../screens/member/member_catalog_screen.dart';
import '../screens/member/member_main_screen.dart';
import '../screens/member/member_profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String home = '/home';
  static const String catalog = '/catalog';
  static const String bookDetail = '/book-detail';
  static const String borrowing = '/borrowing';
  static const String bookmarks = '/bookmarks';
  static const String fines = '/fines';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        main: (context) => const MemberMainScreen(),
        home: (context) => const MemberMainScreen(initialTabIndex: 0),
        catalog: (context) => const MemberCatalogScreen(),
        borrowing: (context) => const MemberBorrowingScreen(),
        profile: (context) => const MemberProfileScreen(),
        bookmarks: (context) => const MemberMainScreen(initialTabIndex: 1),
        fines: (context) => const MemberMainScreen(initialTabIndex: 2),
      };

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const NotFoundScreen(),
    );
  }
}
