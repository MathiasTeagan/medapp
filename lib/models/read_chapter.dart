class ReadChapter {
  final String? id;
  final String bookTitle;
  final String chapterName;
  final String branch;
  final String type; // 'Textbook' veya 'Guideline'
  final DateTime readDate;
  final DateTime addedDate;

  ReadChapter({
    this.id,
    required this.bookTitle,
    required this.chapterName,
    required this.branch,
    required this.type,
    required this.readDate,
    required this.addedDate,
  });

  ReadChapter copyWith({
    String? id,
    String? bookTitle,
    String? chapterName,
    String? branch,
    String? type,
    DateTime? readDate,
    DateTime? addedDate,
  }) {
    return ReadChapter(
      id: id ?? this.id,
      bookTitle: bookTitle ?? this.bookTitle,
      chapterName: chapterName ?? this.chapterName,
      branch: branch ?? this.branch,
      type: type ?? this.type,
      readDate: readDate ?? this.readDate,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'chapterName': chapterName,
      'branch': branch,
      'type': type,
      'readDate': readDate.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory ReadChapter.fromJson(Map<String, dynamic> json) {
    return ReadChapter(
      id: json['id'],
      bookTitle: json['bookTitle'],
      chapterName: json['chapterName'],
      branch: json['branch'],
      type: json['type'],
      readDate: DateTime.parse(json['readDate']),
      addedDate: DateTime.parse(json['addedDate']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadChapter &&
        other.bookTitle == bookTitle &&
        other.chapterName == chapterName &&
        other.branch == branch &&
        other.type == type;
  }

  @override
  int get hashCode {
    return bookTitle.hashCode ^
        chapterName.hashCode ^
        branch.hashCode ^
        type.hashCode;
  }
}
