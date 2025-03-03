import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = false;
  late BuildContext _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get currentUser => _auth.currentUser;

  Future<void> _updateUserProvider(Map<String, dynamic> userData) {
    if (!_context.mounted) return Future.value();

    final userProvider = Provider.of<UserProvider>(_context, listen: false);
    userProvider.updateProfile(
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      specialty: userData['branch'] ?? '',
      institution: userData['institution'] ?? '',
      academicLevel: userData['academicLevel'] ?? 'Tıp Öğrencisi',
      currentYear: userData['currentYear'] ?? 1,
    );
    return Future.value();
  }

  Future<bool> isAuthenticated() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Kullanıcının token'ının geçerli olup olmadığını kontrol et
    try {
      await user.getIdToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String academicLevel,
    required String branch,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userData = {
        'name': name,
        'email': email,
        'academicLevel': academicLevel,
        'branch': branch,
        'currentYear': 1,
        'institution': '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userBranch', branch);
      await prefs.setString('academicLevel', academicLevel);

      await _updateUserProvider(userData);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userData = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userData.exists) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userBranch', userData.data()!['branch']);
        await prefs.setString(
            'academicLevel', userData.data()!['academicLevel']);

        await _updateUserProvider(userData.data()!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userBranch');
      await prefs.remove('academicLevel');

      if (_context.mounted) {
        final userProvider = Provider.of<UserProvider>(_context, listen: false);
        userProvider.updateProfile(
          name: '',
          email: '',
          specialty: '',
          institution: '',
          academicLevel: 'Tıp Öğrencisi',
          currentYear: 1,
        );
      }

      await _auth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.sendPasswordResetEmail(email: email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
