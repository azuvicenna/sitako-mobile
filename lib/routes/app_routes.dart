import 'package:flutter/material.dart';

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
        root: (context) => const Scaffold(body: Center(child: Text('SITAKO'))),
        login: (context) => const Scaffold(body: Center(child: Text('Login'))),
        main: (context) => const Scaffold(body: Center(child: Text('Main'))),
        home: (context) => const Scaffold(body: Center(child: Text('Home'))),
        catalog: (context) => const Scaffold(body: Center(child: Text('Catalog'))),
        bookDetail: (context) => const Scaffold(body: Center(child: Text('Book Detail'))),
        borrowing: (context) => const Scaffold(body: Center(child: Text('Borrowing'))),
        bookmarks: (context) => const Scaffold(body: Center(child: Text('Bookmarks'))),
        fines: (context) => const Scaffold(body: Center(child: Text('Fines'))),
        profile: (context) => const Scaffold(body: Center(child: Text('Profile'))),
        editProfile: (context) => const Scaffold(body: Center(child: Text('Edit Profile'))),
      };
}
