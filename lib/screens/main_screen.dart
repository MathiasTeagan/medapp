import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'library_screen.dart';
import 'performance_screen.dart';
import 'planning_screen.dart';
import 'logbook_screen.dart';
import 'what_to_read_screen.dart';
import 'journals_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LibraryScreen(),
    const WhatToReadScreen(),
    const PlanningScreen(),
    const PerformanceScreen(),
    const JournalsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (!context.mounted) return;
      // Çıkış başarılı bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çıkış yapıldı'),
          backgroundColor: Colors.green,
        ),
      );

      // Tüm ekranları kapat ve login ekranına yönlendir
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        height: screenSize.height * 0.08,
        labelBehavior: isSmallScreen
            ? NavigationDestinationLabelBehavior.alwaysHide
            : NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Kütüphane',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories),
            label: 'Bugün Ne Okusam?',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Planlama',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Performans',
          ),
          NavigationDestination(
            icon: Icon(Icons.article),
            label: 'Dergiler',
          ),
        ],
      ),
    );
  }
}
