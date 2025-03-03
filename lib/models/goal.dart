class Goal {
  final String bookTitle; // Textbook veya Guideline adı
  final String chapterName; // Chapter adı
  final String branch;
  final DateTime addedDate;
  final String type; // 'Textbook' veya 'Guideline'
  bool isCompleted;
  DateTime? completedDate;

  Goal({
    required this.bookTitle,
    required this.chapterName,
    required this.branch,
    required this.addedDate,
    required this.type,
    this.isCompleted = false,
    this.completedDate,
  });

  String get chapter => '$bookTitle - $chapterName';
}

// Global goals list and addGoal function
List<Goal> goals = [];

void addGoal(String bookTitle, String chapterName, String branch, String type) {
  goals.add(Goal(
    bookTitle: bookTitle,
    chapterName: chapterName,
    branch: branch,
    addedDate: DateTime.now(),
    type: type,
  ));
}
