enum AcademicLevel {
  student('Tıp Öğrencisi'),
  practitioner('Pratisyen Hekim'),
  resident('Asistan Hekim'),
  specialist('Uzman Hekim'),
  subspecialist('Yandal Uzmanı'),
  associateProfessor('Doçent'),
  professor('Profesör');

  final String title;
  const AcademicLevel(this.title);
}

class User {
  final String name;
  final AcademicLevel level;
  final String? branch;

  const User({
    required this.name,
    required this.level,
    this.branch,
  });
}
