import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'dart:async';
import '../providers/read_chapters_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool _isLoading = true;
  Timer? _loadingTimer;
  List<int> _animatedCounts = [];
  bool _animationStarted = false;

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
    // Animasyon için gecikmeli başlatma
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _animationStarted = true;
      });
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
    final readChaptersProvider = context.watch<ReadChaptersProvider>();
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
            _buildWeeklyPerformance(
                'Geçen Hafta', _getPreviousWeekDays(), readChaptersProvider),
            const SizedBox(height: 16),
            _buildWeeklyPerformance(
                'Bu Hafta', _getCurrentWeekDays(), readChaptersProvider),
            const SizedBox(height: 24),
            Text(
              'Aylık Okuma Grafiği',
              style: AppTextStyles.titleLarge(context),
            ),
            const SizedBox(height: 12),
            _buildDailyChapterChart(readChaptersProvider),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformance(String title, List<DateTime> days,
      ReadChaptersProvider readChaptersProvider) {
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
          children: days
              .map((day) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildDayBox(day, readChaptersProvider),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyBarChart(ReadChaptersProvider readChaptersProvider) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final days = List.generate(daysInMonth, (i) => i + 1);

    // Her gün için textbook ve guideline sayısı
    final List<int> textbookCounts = List.generate(daysInMonth, (i) => 0);
    final List<int> guidelineCounts = List.generate(daysInMonth, (i) => 0);

    for (var chapter in readChaptersProvider.readChapters) {
      if (chapter.readDate.year == now.year &&
          chapter.readDate.month == now.month) {
        int dayIdx = chapter.readDate.day - 1;
        if (chapter.type == 'Textbook') textbookCounts[dayIdx]++;
        if (chapter.type == 'Guideline') guidelineCounts[dayIdx]++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.menu_book, color: Colors.deepPurple, size: 18),
            const SizedBox(width: 4),
            const Text('Textbook', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 12),
            Icon(Icons.rule, color: Colors.teal, size: 18),
            const SizedBox(width: 4),
            const Text('Guideline', style: TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: (textbookCounts + guidelineCounts)
                      .fold<int>(0, (prev, e) => e > prev ? e : prev) +
                  2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) =>
                        Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx < 0 || idx >= days.length)
                        return const SizedBox.shrink();
                      return Text('${days[idx]}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: true, horizontalInterval: 1),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(days.length, (i) {
                final textbook = textbookCounts[i];
                final guideline = guidelineCounts[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: (textbook + guideline).toDouble(),
                      rodStackItems: [
                        if (textbook > 0)
                          BarChartRodStackItem(
                              0, textbook.toDouble(), Colors.deepPurple),
                        if (guideline > 0)
                          BarChartRodStackItem(textbook.toDouble(),
                              (textbook + guideline).toDouble(), Colors.teal),
                      ],
                      width: 12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayBox(DateTime date, ReadChaptersProvider readChaptersProvider,
      {bool small = false}) {
    final chapters = readChaptersProvider.readChapters
        .where((c) =>
            c.readDate.year == date.year &&
            c.readDate.month == date.month &&
            c.readDate.day == date.day)
        .toList();
    final bool isToday = _isToday(date);
    final bool isFuture = date.isAfter(DateTime.now());
    final bool hasRead = chapters.isNotEmpty;

    Color boxColor;
    if (isFuture) {
      boxColor = const Color(0xFFE0E0E0); // Bir tık koyu gri
    } else if (isToday) {
      boxColor = Colors.blue.withOpacity(0.3);
    } else if (hasRead) {
      boxColor = Colors.green.withOpacity(0.3);
    } else {
      boxColor = Colors.red.withOpacity(0.3);
    }

    return Container(
      width: small ? 32 : 40,
      height: small ? 45 : 55,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getDayName(date),
            style: TextStyle(
              fontSize: small ? 10 : 12,
              color: isToday
                  ? Colors.blue
                  : isFuture
                      ? Colors.black
                      : Colors.grey[600],
            ),
          ),
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: small ? 11 : 16,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday
                  ? Colors.blue
                  : isFuture
                      ? Colors.black
                      : Colors.black,
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

  Widget _buildDailyChapterChart(ReadChaptersProvider readChaptersProvider) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final List<int> days = List.generate(daysInMonth, (i) => i + 1);
    final List<int> dailyCounts = List.generate(daysInMonth, (i) {
      return readChaptersProvider.readChapters
          .where((c) =>
              c.readDate.year == now.year &&
              c.readDate.month == now.month &&
              c.readDate.day == (i + 1))
          .length;
    });
    final maxY = (dailyCounts.isNotEmpty
            ? dailyCounts.reduce((a, b) => a > b ? a : b)
            : 0) +
        2;
    final chartWidth = MediaQuery.of(context).size.width - 32;
    final approxLabelWidth = 60.0;
    final labelCount = (chartWidth / approxLabelWidth).clamp(3, 8).round();
    final labelIndexes = <int>[0];
    for (int i = 1; i < labelCount - 1; i++) {
      labelIndexes.add(((daysInMonth - 1) * i / (labelCount - 1)).round());
    }
    if (!labelIndexes.contains(daysInMonth - 1))
      labelIndexes.add(daysInMonth - 1);
    labelIndexes.sort();

    // Animasyon için değerleri ayarla
    final List<double> animatedValues = List.generate(
      days.length,
      (i) => _animationStarted ? dailyCounts[i].toDouble() : 0.0,
    );

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxY.toDouble(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString()),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= days.length)
                    return const SizedBox.shrink();
                  if (!labelIndexes.contains(idx))
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${days[idx]}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.deepPurple.withOpacity(0.35),
              strokeWidth: 1.5,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.deepPurple.withOpacity(0.35),
              strokeWidth: 1.5,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.deepPurple, width: 2),
              bottom: BorderSide(color: Colors.deepPurple, width: 2),
              right: BorderSide(color: Colors.transparent, width: 0),
              top: BorderSide(color: Colors.transparent, width: 0),
            ),
          ),
          barGroups: List.generate(days.length, (i) {
            final count = animatedValues[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count,
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.purpleAccent,
                      Colors.blueAccent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 10,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY.toDouble(),
                    color: Colors.grey.withOpacity(0.07),
                  ),
                ),
              ],
              showingTooltipIndicators: [],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 700),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }
}
