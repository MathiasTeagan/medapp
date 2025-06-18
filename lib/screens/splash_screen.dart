import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/goals_provider.dart';
import '../providers/read_chapters_provider.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AuthProvider>().setContext(context);
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Splash ekranını biraz göster

    if (!mounted) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = await authProvider.isAuthenticated();

      if (!mounted) return;

      // Kullanıcı giriş yapmışsa verileri yükle
      if (isAuthenticated) {
        try {
          await context.read<GoalsProvider>().loadGoals();
        } catch (e) {
          // Goals yükleme hatası durumunda devam et
        }

        try {
          await context.read<ReadChaptersProvider>().loadReadChapters();
        } catch (e) {
          // ReadChapters yükleme hatası durumunda devam et
        }
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              isAuthenticated ? const MainScreen() : const LoginScreen(),
        ),
      );
    } catch (e) {
      // Hata durumunda login ekranına yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 150,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
