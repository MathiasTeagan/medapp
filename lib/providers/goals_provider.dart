import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/goal.dart';

class GoalsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Önce yerel depolamadan hedefleri yükle
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString('goals');

      if (goalsJson != null) {
        final List<dynamic> decodedGoals = json.decode(goalsJson);
        _goals = decodedGoals.map((g) => Goal.fromJson(g)).toList();
        notifyListeners();
      }

      // Kullanıcı oturum açmışsa, Firebase'den hedefleri yükle
      if (_auth.currentUser != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('goals')
            .get();

        _goals = snapshot.docs.map((doc) {
          final data = doc.data();
          return Goal.fromJson({...data, 'id': doc.id});
        }).toList();

        // Firebase'den gelen hedefleri yerel depolamaya kaydet
        await prefs.setString(
            'goals',
            json.encode(
              _goals.map((g) => g.toJson()).toList(),
            ));

        notifyListeners();
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_auth.currentUser != null) {
        // Firebase'e hedefi ekle
        final docRef = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('goals')
            .add(goal.toJson());

        goal = goal.copyWith(id: docRef.id);
      }

      // Yerel listeye ekle
      _goals.add(goal);

      // Yerel depolamaya kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'goals',
          json.encode(
            _goals.map((g) => g.toJson()).toList(),
          ));

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Yerel listeyi güncelle
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
      }

      if (_auth.currentUser != null && goal.id != null) {
        // Firebase'i güncelle
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('goals')
            .doc(goal.id)
            .update(goal.toJson());
      }

      // Yerel depolamayı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'goals',
          json.encode(
            _goals.map((g) => g.toJson()).toList(),
          ));

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Yerel listeden sil
      _goals.removeWhere((g) => g.id == goalId);

      if (_auth.currentUser != null) {
        // Firebase'den sil
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('goals')
            .doc(goalId)
            .delete();
      }

      // Yerel depolamayı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'goals',
          json.encode(
            _goals.map((g) => g.toJson()).toList(),
          ));

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncGoals() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('goals')
          .get();

      final serverGoals = snapshot.docs.map((doc) {
        final data = doc.data();
        return Goal.fromJson({...data, 'id': doc.id});
      }).toList();

      // Yerel hedefleri sunucudakilerle birleştir
      final mergedGoals = <Goal>[];
      final seenIds = <String>{};

      // Sunucudaki hedefleri ekle
      for (final goal in serverGoals) {
        mergedGoals.add(goal);
        seenIds.add(goal.id!);
      }

      // Yerel hedeflerden sunucuda olmayanları ekle
      for (final goal in _goals) {
        if (goal.id == null || !seenIds.contains(goal.id)) {
          final docRef = await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('goals')
              .add(goal.toJson());

          mergedGoals.add(goal.copyWith(id: docRef.id));
        }
      }

      _goals = mergedGoals;

      // Yerel depolamayı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'goals',
          json.encode(
            _goals.map((g) => g.toJson()).toList(),
          ));

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleGoalCompletion(Goal goal) async {
    final updatedGoal = goal.copyWith(
      isCompleted: !goal.isCompleted,
      completedDate: !goal.isCompleted ? DateTime.now() : null,
    );
    await updateGoal(updatedGoal);
  }

  Future<void> removeGoal(Goal goal) async {
    if (goal.id != null) {
      await deleteGoal(goal.id!);
    }
  }
}
