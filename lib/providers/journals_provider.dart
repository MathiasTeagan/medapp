import 'package:flutter/foundation.dart';
import '../models/journal.dart';
import '../services/rss_service.dart';

class JournalsProvider with ChangeNotifier {
  String? _selectedBranch;
  List<Journal> _journals = [];
  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get selectedBranch => _selectedBranch;
  List<Journal> get journals => _journals;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSelectedBranch(String? branch) {
    _selectedBranch = branch;
    _loadJournalsForBranch();
    notifyListeners();
  }

  Future<void> _loadJournalsForBranch() async {
    if (_selectedBranch == null) {
      _journals = [];
      _articles = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _journals = RssService.getJournalsForBranch(_selectedBranch!);

      // İlk derginin makalelerini yükle
      if (_journals.isNotEmpty) {
        await loadArticlesForJournal(_journals.first);
      }
    } catch (e) {
      _error = 'Dergiler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArticlesForJournal(Journal journal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await RssService.fetchArticlesFromRss(journal.rssUrl);
    } catch (e) {
      _error = 'Makaleler yüklenirken hata oluştu: $e';
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
