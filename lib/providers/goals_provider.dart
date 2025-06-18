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
  String? _currentUserId;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  GoalsProvider() {
    // Kullanıcı değişikliklerini dinle
    _auth.authStateChanges().listen((User? user) {
      if (user?.uid != _currentUserId) {
        _currentUserId = user?.uid;
        _clearLocalData();
        if (user != null) {
          // Yeni kullanıcı için Firebase'den yükle
          loadGoals();
        }
      }
    });
  }

  void _clearLocalData() {
    // Sadece yerel listeyi temizle, depolamayı değil
    _goals = [];
    notifyListeners();
  }

  Future<void> clearAllData() async {
    try {
      // Sadece yerel listeyi temizle
      _goals = [];
      notifyListeners();

      // Yerel depolamayı da temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('goals');

      // Firebase'de de varsa temizle
      if (_auth.currentUser != null) {
        try {
          final snapshot = await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('goals')
              .get();

          // Batch delete
          final batch = _firestore.batch();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        } catch (e) {
          print('Firebase clear error: $e');
        }
      }
    } catch (e) {
      print('Clear data error: $e');
    }
  }

  Future<void> loadGoals() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Kullanıcı oturum açmışsa, Firebase'den hedefleri yükle
      if (_auth.currentUser != null) {
        try {
          final snapshot = await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('goals')
              .get();

          final firebaseGoals = snapshot.docs.map((doc) {
            final data = doc.data();
            return Goal.fromJson({...data, 'id': doc.id});
          }).toList();

          _goals = firebaseGoals;

          // Firebase'den gelen hedefleri yerel depolamaya kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'goals',
              json.encode(
                _goals.map((g) => g.toJson()).toList(),
              ));

          notifyListeners();
        } catch (e) {
          // Firebase'e bağlanamazsa yerel depolamadan yükle
          print('Firebase connection error: $e');
          await _loadFromLocalStorage();
        }
      } else {
        // Kullanıcı oturum açmamışsa yerel depolamadan yükle
        await _loadFromLocalStorage();
      }
    } catch (e) {
      print('Goals loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString('goals');

      if (goalsJson != null) {
        final List<dynamic> decodedGoals = json.decode(goalsJson);
        _goals = decodedGoals.map((g) => Goal.fromJson(g)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Local storage loading error: $e');
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      _isLoading = true;
      notifyListeners();

      Goal goalToAdd = goal;

      if (_auth.currentUser != null) {
        // Firebase'e hedefi ekle
        final docRef = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('goals')
            .add(goal.toJson());

        goalToAdd = goal.copyWith(id: docRef.id);
      }

      // Yerel listeye ekle
      _goals.add(goalToAdd);

      // Yerel depolamaya kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'goals',
          json.encode(
            _goals.map((g) => g.toJson()).toList(),
          ));

      notifyListeners();
    } catch (e) {
      print('Add goal error: $e');
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
    } else {
      // ID yoksa yerel listeden sil
      _goals.remove(goal);

      // Yerel depolamayı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'goals',
          json.encode(
            _goals.map((g) => g.toJson()).toList(),
          ));

      notifyListeners();
    }
  }
}
