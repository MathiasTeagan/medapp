// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goals_provider.dart';
import '../providers/user_provider.dart';
import '../providers/planned_readings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import 'what_to_read_screen.dart';
import 'goals_screen.dart';
import 'planning_screen.dart';
import 'logbook_screen.dart';
import 'profile_edit_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final goalsProvider = Provider.of<GoalsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
              SizedBox(height: size.height * 0.03),
              _buildNavigationGrid(theme, context),
              SizedBox(height: size.height * 0.03),
              _buildRecentActivities(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme, Size size,
      UserProvider userProvider) {
    return Card(
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
          padding: EdgeInsets.all(size.width * 0.04),
          child: Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.08,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: size.width * 0.08,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProvider.name.isEmpty
                          ? 'İsim girilmemiş'
                          : userProvider.name,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userProvider.academicLevel} - ${userProvider.currentYear}. Yıl',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (userProvider.specialty.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        userProvider.specialty,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ThemeData theme, Size size,
      GoalsProvider goalsProvider) {
    final completedGoals =
        goalsProvider.goals.where((g) => g.isCompleted).length;
    final activeGoals = goalsProvider.goals.where((g) => !g.isCompleted).length;
    final monthlyReadings = 12;

    return Container(
      height: size.height * 0.15, // Sabit yükseklik
      decoration: AppTheme.cardDecoration(),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        padding: EdgeInsets.all(size.width * 0.02),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _buildMetricCard(
            context,
            theme,
            'Bu Ay',
            monthlyReadings.toString(),
            Icons.calendar_month,
            AppColors.monthlyMetric,
            size,
          ),
          _buildMetricCard(
            context,
            theme,
            'Tamamlanan',
            completedGoals.toString(),
            Icons.task_alt,
            AppColors.completedMetric,
            size,
          ),
          _buildMetricCard(
            context,
            theme,
            'Aktif',
            activeGoals.toString(),
            Icons.pending_actions,
            AppColors.activeMetric,
            size,
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
      decoration: AppTheme.metricCardDecoration(color: color),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 10 : 12,
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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
                    size: isSmallScreen ? 24 : 28,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Sıradaki Okuma',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Henüz planlanmış bir okuma yok',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlanningScreen(),
                    ),
                  );
                },
                child: Text(
                  'Okuma Planla',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                  size: isSmallScreen ? 24 : 28,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  'Sıradaki Okuma',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextReading.chapter,
                        style: TextStyle(
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PlanningScreen(),
                      ),
                    );
                  },
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

  Widget _buildNavigationGrid(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                theme,
                'Ne Okusam?',
                Icons.auto_stories,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WhatToReadScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                theme,
                'Hedeflerim',
                Icons.assignment,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GoalsScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                theme,
                'Planlama',
                Icons.calendar_today,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PlanningScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavigationCard(
                theme,
                'Logbook',
                Icons.book,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LogbookScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Aktiviteler',
                  style: theme.textTheme.titleLarge?.copyWith(
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
            const SizedBox(height: 16),
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
    );
  }

  Widget _buildActivityItem(
    ThemeData theme,
    String title,
    String action,
    String time,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  action,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
