import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final goalsProvider = context.watch<GoalsProvider>();
    final goals = goalsProvider.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedeflerim'),
        actions: [
          // Debug amaçlı veri temizleme butonu (geliştirme aşamasında)
          if (goals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Tüm Verileri Temizle'),
                    content: const Text(
                        'Bu işlem tüm hedefleri silecek. Devam etmek istiyor musunuz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          goalsProvider.clearAllData();
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: AppTheme.screenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel İlerleme Kartı
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genel İlerleme',
                    style: AppTextStyles.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: goals.isEmpty
                        ? 0
                        : goals.where((goal) => goal.isCompleted).length /
                            goals.length,
                    backgroundColor: AppColors.surface,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tamamlanan: ${goals.where((goal) => goal.isCompleted).length}/${goals.length}',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Okuma Hedeflerim',
              style: AppTextStyles.titleLarge(context),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment,
                            size: size.width * 0.15,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz hedef eklenmemiş',
                            style: AppTextStyles.titleMedium(context).copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"Ne Okusam?" ekranından yeni hedefler ekleyebilirsiniz',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              goal.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: goal.isCompleted
                                  ? AppColors.completedMetric
                                  : AppColors.secondaryText,
                              size: isSmallScreen ? 24 : 28,
                            ),
                            title: Text(
                              goal.chapterName,
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                fontSize: isSmallScreen ? 14 : 16,
                                decoration: goal.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: goal.isCompleted
                                    ? AppColors.completedMetric
                                    : AppColors.primaryText,
                                fontWeight: goal.isCompleted
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.bookTitle,
                                  style: AppTextStyles.bodyMedium(context)
                                      .copyWith(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: AppColors.secondaryText,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  '${goal.branch} • ${goal.type} • Eklenme: ${_formatDate(goal.addedDate)}',
                                  style:
                                      AppTextStyles.bodySmall(context).copyWith(
                                    fontSize: isSmallScreen ? 11 : 13,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    goal.isCompleted
                                        ? Icons.close
                                        : Icons.check,
                                    color: goal.isCompleted
                                        ? AppColors.error
                                        : AppColors.completedMetric,
                                  ),
                                  onPressed: () {
                                    goalsProvider.toggleGoalCompletion(goal);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () {
                                    _showDeleteDialog(goal);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hedefi Sil',
          style: AppTextStyles.titleMedium(context),
        ),
        content: Text(
          'Bu hedefi silmek istediğinizden emin misiniz?',
          style: AppTextStyles.bodyLarge(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppTextStyles.labelLarge(context).copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<GoalsProvider>().removeGoal(goal);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Sil',
              style: AppTextStyles.labelLarge(context).copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
