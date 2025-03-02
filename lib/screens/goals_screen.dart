import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/goals_provider.dart';

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
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel İlerleme Kartı
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
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
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: goals.isEmpty
                        ? 0
                        : goals.where((goal) => goal.isCompleted).length /
                            goals.length,
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tamamlanan: ${goals.where((goal) => goal.isCompleted).length}/${goals.length}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Okuma Hedeflerim',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
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
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz hedef eklenmemiş',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"Ne Okusam?" ekranından yeni hedefler ekleyebilirsiniz',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey,
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
                              color:
                                  goal.isCompleted ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              goal.chapter,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                decoration: goal.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              '${goal.branch} • Eklenme: ${_formatDate(goal.addedDate)}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    goalsProvider.toggleGoalCompletion(goal);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    goalsProvider.removeGoal(goal);
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
