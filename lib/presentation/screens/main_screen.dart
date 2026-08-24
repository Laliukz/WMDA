import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'scan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Inicia en la pestaña 'Scan' (índice 1)

  final List<Widget> _screens = const [
    _PlaceholderTab(title: 'Home', subtitle: 'Resumen y estadísticas'),
    ScanScreen(),
    _PlaceholderTab(title: 'Downloads', subtitle: 'Descargas activas'),
    _PlaceholderTab(title: 'Library', subtitle: 'Historial de medios'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

// Vista temporal para las pestañas que construiremos en los siguientes pasos
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PlaceholderTab({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}
