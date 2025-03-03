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
    final completedGoals =
        goalsProvider.goals.where((g) => g.isCompleted).length;
    final activeGoals = goalsProvider.goals.where((g) => !g.isCompleted).length;
    final monthlyReadings = 12;
    final isSmallScreen = size.width < 600;

    return Container(
      height: isSmallScreen ? size.height * 0.12 : size.height * 0.1,
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              context,
              theme,
              'Bu Ay',
              monthlyReadings.toString(),
              Icons.calendar_month,
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
              completedGoals.toString(),
              Icons.task_alt,
              AppColors.completedMetric,
              size,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: _buildMetricCard(
              context,
              theme,
              'Aktif',
              activeGoals.toString(),
              Icons.pending_actions,
              AppColors.activeMetric,
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
        vertical: size.height * 0.01,
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
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: size.width * 0.01),
              Text(
                value,
                style: AppTextStyles.headlineMedium(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 16 : 20,
                ),
              ),
            ],
          ),
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
                        nextReading.chapter,
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
        Container(
          height: isSmallScreen ? size.height * 0.06 : size.height * 0.08,
          child: ListView(
            scrollDirection: Axis.horizontal,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
      child: Material(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.01,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
