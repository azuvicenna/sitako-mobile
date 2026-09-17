import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'member_borrowing_screen.dart';
import 'member_catalog_screen.dart';
import 'member_dashboard_screen.dart';
import 'member_profile_screen.dart';

class MemberMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MemberMainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MemberMainScreen> createState() => _MemberMainScreenState();
}

class _MemberMainScreenState extends State<MemberMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      MemberDashboardScreen(onNavigateTab: _onTabChanged),
      const MemberCatalogScreen(),
      const MemberBorrowingScreen(),
      const MemberProfileScreen(),
    ];

    final titles = [
      'Beranda Anggota',
      'Katalog Buku',
      'Peminjaman Saya',
      'Profil Saya',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabChanged,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.mustardLight,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.charcoalDark),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: AppColors.charcoalDark),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history, color: AppColors.charcoalDark),
              label: 'Peminjaman',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.charcoalDark),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
