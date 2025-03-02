import 'package:flutter/foundation.dart';
import '../models/goal.dart';

class GoalsProvider with ChangeNotifier {
  final List<Goal> _goals = [];

  List<Goal> get goals => List.unmodifiable(_goals);

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void removeGoal(Goal goal) {
    _goals.remove(goal);
    notifyListeners();
  }

  void toggleGoalCompletion(Goal goal) {
    final index = _goals.indexOf(goal);
    if (index != -1) {
      _goals[index] = Goal(
        chapter: goal.chapter,
        branch: goal.branch,
        addedDate: goal.addedDate,
        isCompleted: !goal.isCompleted,
      );
      notifyListeners();
    }
  }
}
