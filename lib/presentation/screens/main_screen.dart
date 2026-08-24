import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'downloads_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'scan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Inicia en la pestaña Home

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToScan: () => _onTabTapped(1),
        onNavigateToLibrary: () => _onTabTapped(3),
      ),
      const ScanScreen(),
      const DownloadsScreen(),
      const LibraryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
