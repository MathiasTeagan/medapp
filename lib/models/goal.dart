class Goal {
  final String chapter;
  final String branch;
  final DateTime addedDate;
  bool isCompleted;

  Goal({
    required this.chapter,
    required this.branch,
    required this.addedDate,
    this.isCompleted = false,
  });
}

// Global goals list and addGoal function
List<Goal> goals = [];

void addGoal(String chapter, String branch) {
  goals.add(Goal(
    chapter: chapter,
    branch: branch,
    addedDate: DateTime.now(),
  ));
}
