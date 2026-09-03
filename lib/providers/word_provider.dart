import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/word_repository.dart';
import '../models/category.dart';
import '../models/word.dart';
import '../services/srs_service.dart';

/// Central app state: owns the in-memory word/category lists, keeps them in
/// sync with [WordRepository], and exposes the operations screens need
/// (CRUD, search/filter, spaced-repetition review).
class WordProvider extends ChangeNotifier {
  WordProvider({WordRepository? repository, SrsService? srsService})
      : _repository = repository ?? WordRepository(),
        _srsService = srsService ?? SrsService();

  final WordRepository _repository;
  final SrsService _srsService;
  final _uuid = const Uuid();

  List<Word> _words = [];
  List<WordCategory> _categories = [];
  bool _isLoaded = false;

  List<Word> get words => List.unmodifiable(_words);
  List<WordCategory> get categories => List.unmodifiable(_categories);
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    await _repository.init();
    _words = _repository.getAllWords();
    _categories = _repository.getAllCategories();
    _isLoaded = true;
    notifyListeners();
  }

  // --- Derived views ---------------------------------------------------

  /// Words filtered by category (null/'all' = every category) and a
  /// case-insensitive search over term/meaning.
  List<Word> filteredWords({String? categoryId, String query = ''}) {
    final q = query.trim().toLowerCase();
    return _words.where((w) {
      final matchesCategory =
          categoryId == null || categoryId.isEmpty || w.categoryId == categoryId;
      final matchesQuery = q.isEmpty ||
          w.term.toLowerCase().contains(q) ||
          w.meaning.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Words due for spaced-repetition review right now, oldest due first.
  List<Word> dueWords({String? categoryId}) {
    return _words
        .where((w) =>
            w.isDue && (categoryId == null || categoryId.isEmpty || w.categoryId == categoryId))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  WordCategory? categoryById(String? id) {
    if (id == null) return null;
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  // --- Word CRUD ---------------------------------------------------------

  Future<void> addWord({
    required String term,
    required String meaning,
    String? example,
    String? categoryId,
  }) async {
    final word = Word(
      id: _uuid.v4(),
      term: term.trim(),
      meaning: meaning.trim(),
      example: (example == null || example.trim().isEmpty) ? null : example.trim(),
      categoryId: (categoryId == null || categoryId.isEmpty) ? null : categoryId,
      createdAt: DateTime.now(),
    );
    await _repository.saveWord(word);
    _words.add(word);
    notifyListeners();
  }

  Future<void> updateWord(
    Word word, {
    required String term,
    required String meaning,
    String? example,
    String? categoryId,
  }) async {
    word.term = term.trim();
    word.meaning = meaning.trim();
    word.example = (example == null || example.trim().isEmpty) ? null : example.trim();
    word.categoryId = (categoryId == null || categoryId.isEmpty) ? null : categoryId;
    await _repository.saveWord(word);
    notifyListeners();
  }

  Future<void> deleteWord(Word word) async {
    await _repository.deleteWord(word.id);
    _words.removeWhere((w) => w.id == word.id);
    notifyListeners();
  }

  /// Applies an SM-2 review outcome to [word] and persists the new
  /// spaced-repetition schedule.
  Future<void> reviewWord(Word word, ReviewResult result) async {
    _srsService.review(word, result);
    await _repository.saveWord(word);
    notifyListeners();
  }

  // --- Category CRUD -------------------------------------------------

  Future<WordCategory> addCategory(String name, {int colorValue = 0xFF6750A4}) async {
    final category = WordCategory(id: _uuid.v4(), name: name.trim(), colorValue: colorValue);
    await _repository.saveCategory(category);
    _categories.add(category);
    notifyListeners();
    return category;
  }

  Future<void> deleteCategory(WordCategory category) async {
    await _repository.deleteCategory(category.id);
    _categories.removeWhere((c) => c.id == category.id);
    // Words in the deleted category become uncategorized rather than
    // silently disappearing from the list.
    for (final word in _words.where((w) => w.categoryId == category.id)) {
      word.categoryId = null;
      await _repository.saveWord(word);
    }
    notifyListeners();
  }
}
