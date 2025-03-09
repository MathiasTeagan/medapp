import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goals_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final goalsProvider = context.watch<GoalsProvider>();
    final goals = goalsProvider.goals;
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final completionRate = goals.isEmpty ? 0.0 : completedGoals / goals.length;
    final currentStreak = _calculateCurrentStreak();

    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange.shade400,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentStreak Gün',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kesintisiz Okuma',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Weekly Performance
          Text(
            'Haftalık Performans',
            style: AppTextStyles.titleLarge(context),
          ),
          const SizedBox(height: 12),
          _buildWeeklyPerformance('Geçen Hafta', _getPreviousWeekDays()),
          const SizedBox(height: 16),
          _buildWeeklyPerformance('Bu Hafta', _getCurrentWeekDays()),
          const SizedBox(height: 24),

          // Statistics
          Text(
            'İstatistikler',
            style: AppTextStyles.titleLarge(context),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatisticRow(
                    'Toplam Hedef',
                    goals.length.toString(),
                    Icons.assignment,
                  ),
                  const Divider(),
                  _buildStatisticRow(
                    'Tamamlanan',
                    completedGoals.toString(),
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  const Divider(),
                  _buildStatisticRow(
                    'Başarı Oranı',
                    '${(completionRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Achievements
          Text(
            'Başarılar',
            style: AppTextStyles.titleLarge(context),
          ),
          const SizedBox(height: 12),
          _buildAchievements(completedGoals, currentStreak),
          const SizedBox(height: 24),

          // Motivation Quote
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMotivationalQuote(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPerformance(String title, List<DateTime> days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) => _buildDayBox(day)).toList(),
        ),
      ],
    );
  }

  Widget _buildDayBox(DateTime date) {
    final bool hasRead = date.day % 2 == 0; // Dummy data
    final bool isToday = _isToday(date);

    Color boxColor;
    if (isToday) {
      boxColor = Colors.blue.withOpacity(0.3);
    } else if (hasRead) {
      boxColor = Colors.green.withOpacity(0.3);
    } else {
      boxColor = Colors.red.withOpacity(0.3);
    }

    return Container(
      width: 40,
      height: 45,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getDayName(date),
            style: TextStyle(
              fontSize: 12,
              color: isToday ? Colors.blue : Colors.grey[600],
            ),
          ),
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(int completedGoals, int currentStreak) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildAchievementCard(
          'Başlangıç',
          Icons.star,
          completedGoals >= 1,
          'İlk hedefini tamamla',
        ),
        _buildAchievementCard(
          'Kararlı',
          Icons.local_fire_department,
          currentStreak >= 3,
          '3 gün kesintisiz oku',
        ),
        _buildAchievementCard(
          'Uzman',
          Icons.workspace_premium,
          completedGoals >= 10,
          '10 hedef tamamla',
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
      String title, IconData icon, bool unlocked, String description) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? Colors.amber : Colors.grey.shade300,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: unlocked ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: unlocked ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  List<DateTime> _getPreviousWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1 + 7));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _getDayName(DateTime date) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _calculateCurrentStreak() {
    // Dummy data - gerçek verilerle değiştirilecek
    return 5;
  }

  String _getMotivationalQuote() {
    final quotes = [
      'Bilgi güçtür.',
      'Her gün yeni bir şey öğren.',
      'Küçük adımlar, büyük başarılar getirir.',
      'Başarı, her gün tekrarlanan küçük çabaların toplamıdır.',
      'Öğrenme arzusu, başarının ilk adımıdır.',
    ];
    return quotes[DateTime.now().day % quotes.length];
  }
}
