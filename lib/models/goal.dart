class Goal {
  final String? id;
  final String bookTitle; // Textbook veya Guideline adı
  final String chapterName; // Chapter adı
  final String branch;
  final DateTime addedDate;
  final String type; // 'Textbook' veya 'Guideline'
  final bool isCompleted;
  final DateTime? completedDate;

  Goal({
    this.id,
    required this.bookTitle,
    required this.chapterName,
    required this.branch,
    required this.addedDate,
    required this.type,
    this.isCompleted = false,
    this.completedDate,
  });

  Goal copyWith({
    String? id,
    String? bookTitle,
    String? chapterName,
    String? branch,
    DateTime? addedDate,
    String? type,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return Goal(
      id: id ?? this.id,
      bookTitle: bookTitle ?? this.bookTitle,
      chapterName: chapterName ?? this.chapterName,
      branch: branch ?? this.branch,
      addedDate: addedDate ?? this.addedDate,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookTitle': bookTitle,
      'chapterName': chapterName,
      'branch': branch,
      'addedDate': addedDate.toIso8601String(),
      'type': type,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String?,
      bookTitle: json['bookTitle'] as String,
      chapterName: json['chapterName'] as String,
      branch: json['branch'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String),
      type: json['type'] as String,
      isCompleted: json['isCompleted'] as bool,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Goal &&
        other.id == id &&
        other.bookTitle == bookTitle &&
        other.chapterName == chapterName &&
        other.branch == branch &&
        other.addedDate == addedDate &&
        other.type == type &&
        other.isCompleted == isCompleted &&
        other.completedDate == completedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bookTitle.hashCode ^
        chapterName.hashCode ^
        branch.hashCode ^
        addedDate.hashCode ^
        type.hashCode ^
        isCompleted.hashCode ^
        completedDate.hashCode;
  }

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
