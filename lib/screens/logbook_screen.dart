import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import 'package:intl/intl.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook'),
      ),
      body: Padding(
        padding: AppTheme.screenPadding(context),
        child: _buildLogList(context, isSmallScreen),
      ),
    );
  }

  Widget _buildLogList(BuildContext context, bool isSmallScreen) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        var completedGoals = goalsProvider.goals
            .where((goal) => goal.isCompleted)
            .toList()
          ..sort((a, b) {
            if (a.completedDate == null && b.completedDate == null) return 0;
            if (a.completedDate == null) return 1;
            if (b.completedDate == null) return -1;
            return b.completedDate!.compareTo(a.completedDate!);
          });

        if (completedGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  size: isSmallScreen ? 48 : 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz okunmuş chapter yok',
                  style: AppTextStyles.titleMedium(context).copyWith(
                    color: Colors.grey,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: completedGoals.length,
          itemBuilder: (context, index) {
            final goal = completedGoals[index];
            final isTextbook = goal.type == 'Textbook';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  isTextbook ? Icons.book : Icons.description,
                  color: isTextbook ? AppColors.primary : AppColors.tertiary,
                  size: isSmallScreen ? 20 : 24,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${goal.bookTitle} - ${goal.chapterName}',
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      goal.branch,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  _formatDate(goal.completedDate!),
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isTextbook
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.type,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color:
                          isTextbook ? AppColors.primary : AppColors.tertiary,
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('d MMMM y', 'tr_TR');
    return formatter.format(date);
  }
}
