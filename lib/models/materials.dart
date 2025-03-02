import '../dummy/materials_data.dart';

class Chapter {
  final String title;
  bool isRead;

  Chapter({
    required this.title,
    this.isRead = false,
  });
}

class Textbook {
  final String title;
  final String branch;
  final List<Chapter> chapters;

  Textbook({
    required this.title,
    required this.branch,
    required this.chapters,
  });

  static Map<String, List<String>> get branchTextbooks =>
      MaterialsData.branchTextbooks;

  static List<Chapter> getChapters(String title, String branch) {
    final chapterTitles = MaterialsData.textbookChapters[title] ?? [];
    return chapterTitles.map((title) => Chapter(title: title)).toList();
  }
}

class Guideline {
  final String title;
  final String branch;
  final String organization;
  final String year;
  final List<Chapter> chapters;

  Guideline({
    required this.title,
    required this.branch,
    required this.organization,
    required this.year,
    required this.chapters,
  });

  static Map<String, List<String>> get branchGuidelines =>
      MaterialsData.branchGuidelines;

  static List<Chapter> getChapters(String title, String branch) {
    final chapterTitles = MaterialsData.guidelineChapters[title] ?? [];
    return chapterTitles.map((title) => Chapter(title: title)).toList();
  }
}
