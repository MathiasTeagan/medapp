import 'package:flutter/material.dart';

class PlannedReading {
  final String chapter;
  final String branch;
  final DateTime plannedDate;

  PlannedReading({
    required this.chapter,
    required this.branch,
    required this.plannedDate,
  });
}

class PlannedReadingsProvider with ChangeNotifier {
  final List<PlannedReading> _plannedReadings = [];

  List<PlannedReading> get plannedReadings => _plannedReadings;

  PlannedReading? get nextReading {
    if (_plannedReadings.isEmpty) return null;

    final now = DateTime.now();
    final futureReadings = _plannedReadings
        .where((reading) => reading.plannedDate.isAfter(now))
        .toList();

    if (futureReadings.isEmpty) return null;

    futureReadings.sort((a, b) => a.plannedDate.compareTo(b.plannedDate));
    return futureReadings.first;
  }

  void addPlannedReading(PlannedReading reading) {
    _plannedReadings.add(reading);
    notifyListeners();
  }

  void removePlannedReading(PlannedReading reading) {
    _plannedReadings.remove(reading);
    notifyListeners();
  }
}
