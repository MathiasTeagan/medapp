import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/read_chapter.dart';

class ReadChaptersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<ReadChapter> _readChapters = [];
  bool _isLoading = false;

  List<ReadChapter> get readChapters => _readChapters;
  bool get isLoading => _isLoading;

  // Belirli bir chapter'ın okunup okunmadığını kontrol et
  bool isChapterRead(
      String bookTitle, String chapterName, String branch, String type) {
    return _readChapters.any((chapter) =>
        chapter.bookTitle == bookTitle &&
        chapter.chapterName == chapterName &&
        chapter.branch == branch &&
        chapter.type == type);
  }

  // Belirli bir kitabın okunan chapter'larını getir
  List<String> getReadChaptersForBook(
      String bookTitle, String branch, String type) {
    return _readChapters
        .where((chapter) =>
            chapter.bookTitle == bookTitle &&
            chapter.branch == branch &&
            chapter.type == type)
        .map((chapter) => chapter.chapterName)
        .toList();
  }

  Future<void> loadReadChapters() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Önce yerel depolamadan okunan chapter'ları yükle
      final prefs = await SharedPreferences.getInstance();
      final chaptersJson = prefs.getString('readChapters');

      if (chaptersJson != null) {
        final List<dynamic> decodedChapters = json.decode(chaptersJson);
        _readChapters =
            decodedChapters.map((c) => ReadChapter.fromJson(c)).toList();
        notifyListeners();
      }

      // Kullanıcı oturum açmışsa, Firebase'den okunan chapter'ları yükle
      if (_auth.currentUser != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('readChapters')
            .get();

        _readChapters = snapshot.docs.map((doc) {
          final data = doc.data();
          return ReadChapter.fromJson({...data, 'id': doc.id});
        }).toList();

        // Firebase'den gelen verileri yerel depolamaya kaydet
        await prefs.setString(
            'readChapters',
            json.encode(
              _readChapters.map((c) => c.toJson()).toList(),
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

  Future<void> markChapterAsRead(
      String bookTitle, String chapterName, String branch, String type) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Eğer chapter zaten okunmuşsa, işlemi iptal et
      if (isChapterRead(bookTitle, chapterName, branch, type)) {
        return;
      }

      var readChapter = ReadChapter(
        bookTitle: bookTitle,
        chapterName: chapterName,
        branch: branch,
        type: type,
        readDate: DateTime.now(),
        addedDate: DateTime.now(),
      );

      if (_auth.currentUser != null) {
        // Firebase'e ekle
        final docRef = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('readChapters')
            .add(readChapter.toJson());

        readChapter = readChapter.copyWith(id: docRef.id);
      }

      // Yerel listeye ekle
      _readChapters.add(readChapter);

      // Yerel depolamaya kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'readChapters',
          json.encode(
            _readChapters.map((c) => c.toJson()).toList(),
          ));

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markChapterAsUnread(
      String bookTitle, String chapterName, String branch, String type) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Yerel listeden kaldır
      _readChapters.removeWhere((chapter) =>
          chapter.bookTitle == bookTitle &&
          chapter.chapterName == chapterName &&
          chapter.branch == branch &&
          chapter.type == type);

      if (_auth.currentUser != null) {
        // Firebase'den kaldır
        final querySnapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('readChapters')
            .where('bookTitle', isEqualTo: bookTitle)
            .where('chapterName', isEqualTo: chapterName)
            .where('branch', isEqualTo: branch)
            .where('type', isEqualTo: type)
            .get();

        for (final doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Yerel depolamayı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'readChapters',
          json.encode(
            _readChapters.map((c) => c.toJson()).toList(),
          ));

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleChapterReadStatus(
      String bookTitle, String chapterName, String branch, String type) async {
    if (isChapterRead(bookTitle, chapterName, branch, type)) {
      await markChapterAsUnread(bookTitle, chapterName, branch, type);
    } else {
      await markChapterAsRead(bookTitle, chapterName, branch, type);
    }
  }

  Future<void> syncReadChapters() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('readChapters')
          .get();

      final serverChapters = snapshot.docs.map((doc) {
        final data = doc.data();
        return ReadChapter.fromJson({...data, 'id': doc.id});
      }).toList();

      // Yerel verileri sunucudakilerle birleştir
      final mergedChapters = <ReadChapter>[];
      final seenIds = <String>{};

      // Sunucudaki verileri ekle
      for (final chapter in serverChapters) {
        mergedChapters.add(chapter);
        seenIds.add(chapter.id!);
      }

      // Yerel verilerden sunucuda olmayanları ekle
      for (final chapter in _readChapters) {
        if (chapter.id == null || !seenIds.contains(chapter.id)) {
          final docRef = await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('readChapters')
              .add(chapter.toJson());

          mergedChapters.add(chapter.copyWith(id: docRef.id));
        }
      }

      _readChapters = mergedChapters;

      // Yerel depolamayı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'readChapters',
          json.encode(
            _readChapters.map((c) => c.toJson()).toList(),
          ));

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli bir tarih aralığında okunan chapter'ları getir
  List<ReadChapter> getReadChaptersInDateRange(
      DateTime startDate, DateTime endDate) {
    return _readChapters
        .where((chapter) =>
            chapter.readDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            chapter.readDate.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // Bugün okunan chapter'ları getir
  List<ReadChapter> getTodayReadChapters() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return getReadChaptersInDateRange(today, tomorrow);
  }

  // Bu hafta okunan chapter'ları getir
  List<ReadChapter> getThisWeekReadChapters() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));

    return getReadChaptersInDateRange(startDate, endDate);
  }
}
