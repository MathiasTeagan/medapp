import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _email = '';
  String _specialty = '';
  String _institution = '';
  String _academicLevel = 'Tıp Öğrencisi';
  int _currentYear = 1;

  // Getters
  String get name => _name;
  String get email => _email;
  String get specialty => _specialty;
  String get institution => _institution;
  String get academicLevel => _academicLevel;
  int get currentYear => _currentYear;

  void updateProfile({
    required String name,
    required String email,
    required String specialty,
    required String institution,
    required String academicLevel,
    required int currentYear,
  }) {
    _name = name;
    _email = email;
    _specialty = specialty;
    _institution = institution;
    _academicLevel = academicLevel;
    _currentYear = currentYear;
    notifyListeners();
  }
}
