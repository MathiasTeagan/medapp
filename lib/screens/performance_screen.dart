import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'dart:async';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool _isLoading = true;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    // Minimum 400ms loading süresi
    _loadingTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final goalsProvider = context.watch<GoalsProvider>();
    final goals = goalsProvider.goals;
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final completionRate = goals.isEmpty ? 0.0 : completedGoals / goals.length;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Performans'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performans'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
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
}
