// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../providers/planned_readings_provider.dart';
import '../services/notification_service.dart';
import '../screens/library_screen.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _plannedChapters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planlama'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            elevation: 2,
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: {
                CalendarFormat.month: 'Ay',
              },
              enabledDayPredicate: (day) =>
                  day.isAfter(DateTime.now().subtract(const Duration(days: 1))),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red),
                holidayTextStyle: TextStyle(color: Colors.red),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showAddPlanDialog(context, selectedDay);
                }
              },
              eventLoader: (day) {
                return _plannedChapters[day] ?? [];
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Planlanmış Okumalar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _plannedChapters.length,
              itemBuilder: (context, index) {
                final date = _plannedChapters.keys.elementAt(index);
                final chapters = _plannedChapters[date] ?? [];

                return Card(
                  child: ExpansionTile(
                    title: Text(
                      DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: chapters
                        .map((chapter) => ListTile(
                              leading: const Icon(Icons.book),
                              title: Text(chapter),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _plannedChapters[date]?.remove(chapter);
                                    if (_plannedChapters[date]?.isEmpty ??
                                        false) {
                                      _plannedChapters.remove(date);
                                    }
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPlanDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Plan Ekle - ${DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDay)}',
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Consumer<GoalsProvider>(
              builder: (context, goalsProvider, child) {
                final uncompletedGoals = goalsProvider.goals
                    .where((goal) => !goal.isCompleted)
                    .toList();

                if (uncompletedGoals.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Henüz hedef eklenmemiş!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Önce kütüphaneden bir chapter seçip hedeflerinize eklemelisiniz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LibraryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.library_books),
                        label: const Text('Kütüphaneye Git'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: uncompletedGoals.length,
                  itemBuilder: (context, index) {
                    final goal = uncompletedGoals[index];
                    return ListTile(
                      title: Text(goal.chapterName),
                      subtitle: Text(goal.branch),
                      onTap: () {
                        setState(() {
                          if (!_plannedChapters.containsKey(selectedDay)) {
                            _plannedChapters[selectedDay] = [];
                          }
                          _plannedChapters[selectedDay]!.add(goal.chapterName);
                        });
                        Navigator.pop(context);
                        _savePlan(goal.chapterName, selectedDay, goal.branch);
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void _savePlan(
      String chapterName, DateTime selectedDate, String branch) async {
    // Bildirim ayarlama
    await NotificationService.instance.scheduleChapterReminder(
      chapterName,
      selectedDate,
    );

    // Planlanan okumayı provider'a ekle
    final plannedReading = PlannedReading(
      chapter: chapterName,
      branch: branch,
      plannedDate: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        22, // Saat 22:00
        0,
      ),
    );

    context.read<PlannedReadingsProvider>().addPlannedReading(plannedReading);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan başarıyla kaydedildi ve hatırlatıcı ayarlandı'),
        ),
      );
    }
  }
}
