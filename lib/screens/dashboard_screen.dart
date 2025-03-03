// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goals_provider.dart';
import '../providers/user_provider.dart';
import '../providers/planned_readings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'what_to_read_screen.dart';
import 'goals_screen.dart';
import 'planning_screen.dart';
import 'logbook_screen.dart';
import 'profile_edit_screen.dart';
import '../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AuthProvider>().setContext(context);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();

    // Kullanıcı null ise veya giriş yapmamışsa veri çekmeyi dene
    if (authProvider.currentUser == null) return;

    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUser?.uid)
          .get();

      if (userData.exists && mounted) {
        await authProvider.updateUserProvider(userData.data()!);
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _handleLogout() async {
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
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (!mounted) return;
      // Çıkış başarılı bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çıkış yapıldı'),
          backgroundColor: Colors.green,
        ),
      );

      // Tüm ekranları kapat ve login ekranına yönlendir
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final goalsProvider = Provider.of<GoalsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(context, theme, size, userProvider),
              SizedBox(height: size.height * 0.015),
              _buildMetricsGrid(context, theme, size, goalsProvider),
              SizedBox(height: size.height * 0.015),
              _buildNextReadingCard(theme, context),
              SizedBox(height: size.height * 0.02),
              _buildQuickAccess(theme, context),
              SizedBox(height: size.height * 0.02),
              _buildRecentActivities(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme, Size size,
      UserProvider userProvider) {
    final isSmallScreen = size.width < 600;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileEditScreen(),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.015,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? size.width * 0.06 : size.width * 0.04,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: isSmallScreen ? size.width * 0.05 : size.width * 0.03,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProvider.name.isEmpty
                          ? 'İsim girilmemiş'
                          : userProvider.name,
                      style: AppTextStyles.titleMedium(context).copyWith(
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Text(
                      '${userProvider.academicLevel} - ${userProvider.currentYear}. Yıl',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    if (userProvider.specialty.isNotEmpty)
                      Text(
                        userProvider.specialty,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: theme.colorScheme.primary,
                size: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ThemeData theme, Size size,
      GoalsProvider goalsProvider) {
    final isSmallScreen = size.width < 600;
    final activeGoals = goalsProvider.goals.where((g) => !g.isCompleted).length;
    final plannedReadings =
        Provider.of<PlannedReadingsProvider>(context).plannedReadings.length;
    final completedChapters =
        goalsProvider.goals.where((g) => g.isCompleted).length;

    return Container(
      height: isSmallScreen ? size.height * 0.08 : size.height * 0.07,
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              context,
              theme,
              'Hedef',
              activeGoals.toString(),
              Icons.flag,
              AppColors.activeMetric,
              size,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: _buildMetricCard(
              context,
              theme,
              'Planlanan',
              plannedReadings.toString(),
              Icons.calendar_today,
              AppColors.monthlyMetric,
              size,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: _buildMetricCard(
              context,
              theme,
              'Tamamlanan',
              completedChapters.toString(),
              Icons.task_alt,
              AppColors.completedMetric,
              size,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
    Size size,
  ) {
    final isSmallScreen = size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: size.height * 0.005,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: isSmallScreen ? 14 : 18,
              ),
              SizedBox(width: size.width * 0.01),
              Text(
                value,
                style: AppTextStyles.headlineMedium(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 18,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 9 : 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextReadingCard(ThemeData theme, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final nextReading =
        Provider.of<PlannedReadingsProvider>(context).nextReading;

    if (nextReading == null) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Sıradaki Okuma',
                    style: AppTextStyles.titleMedium(context).copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Henüz planlanmış bir okuma yok',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlanningScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Okuma Planla',
                  style: AppTextStyles.labelLarge(context).copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormatter = DateFormat('d MMMM y, HH:mm', 'tr_TR');
    final formattedDate = dateFormatter.format(nextReading.plannedDate);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  'Sıradaki Okuma',
                  style: AppTextStyles.titleMedium(context).copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        nextReading.chapter.contains(' - ')
                            ? nextReading.chapter.substring(
                                0, nextReading.chapter.indexOf(' - '))
                            : 'Kitap bilgisi yok',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        nextReading.chapter.contains(' - ')
                            ? nextReading.chapter.substring(
                                nextReading.chapter.indexOf(' - ') + 3)
                            : nextReading.chapter,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlanningScreen(),
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(ThemeData theme, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
          child: Text(
            'Hızlı Erişim',
            style: AppTextStyles.titleLarge(context).copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: size.height * 0.01,
          crossAxisSpacing: size.width * 0.02,
          children: [
            _buildQuickAccessButton(
              theme,
              'Ne Okusam?',
              Icons.auto_stories,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WhatToReadScreen(),
                ),
              ),
              context,
            ),
            _buildQuickAccessButton(
              theme,
              'Hedeflerim',
              Icons.assignment,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoalsScreen(),
                ),
              ),
              context,
            ),
            _buildQuickAccessButton(
              theme,
              'Planlama',
              Icons.calendar_today,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlanningScreen(),
                ),
              ),
              context,
            ),
            _buildQuickAccessButton(
              theme,
              'Logbook',
              Icons.book,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogbookScreen(),
                ),
              ),
              context,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
    BuildContext context,
  ) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Material(
      color: theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.01,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                title,
                style: AppTextStyles.labelLarge(context).copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(ThemeData theme) {
    return Builder(
      builder: (context) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son Aktiviteler',
                    style: AppTextStyles.titleLarge(context).copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      // TODO: Implement activity details navigation
                    },
                  ),
                ],
              ),
              const Divider(),
              _buildActivityItem(
                theme,
                'Braunwald Chapter 4',
                'Tamamlandı',
                '2 saat önce',
                Icons.task_alt,
              ),
              _buildActivityItem(
                theme,
                'ESC Guidelines - Heart Failure',
                'Hedeflere eklendi',
                '5 saat önce',
                Icons.add_task,
              ),
              _buildActivityItem(
                theme,
                'Mayo Clinic ECG',
                'Okumaya başlandı',
                '1 gün önce',
                Icons.play_circle_fill,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    ThemeData theme,
    String title,
    String action,
    String time,
    IconData icon,
  ) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    action,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: AppTextStyles.bodySmall(context).copyWith(
                color: theme.colorScheme.secondary.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
