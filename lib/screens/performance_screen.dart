import 'package:flutter/material.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyPerformance('Geçen Hafta', _getPreviousWeekDays()),
            const SizedBox(height: 24),
            _buildWeeklyPerformance('Bu Hafta', _getCurrentWeekDays()),
            const SizedBox(height: 32),
            _buildStatistics(),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) => _buildDayBox(day)).toList(),
        ),
      ],
    );
  }

  Widget _buildDayBox(DateTime date) {
    // Dummy data for reading status
    final bool hasRead = date.day % 2 == 0; // Even days marked as read
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
      width: 45,
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
              fontSize: 16,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İstatistikler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Haftalık Başarı', 0.71),
            const SizedBox(height: 12),
            _buildStatRow('Aylık Başarı', 0.65),
            const SizedBox(height: 12),
            _buildStatRow('Genel Başarı', 0.82),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  value >= 0.7 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '%${(value * 100).toInt()}',
              style: TextStyle(
                color: value >= 0.7 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
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
