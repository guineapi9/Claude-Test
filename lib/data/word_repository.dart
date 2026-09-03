import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';
import '../models/word.dart';

/// Thin persistence layer over two Hive boxes: one for words, one for
/// categories. Kept separate from [WordProvider] so the storage engine can
/// be swapped later without touching UI/state-management code.
class WordRepository {
  static const String wordsBoxName = 'words';
  static const String categoriesBoxName = 'categories';

  late final Box<Word> _wordsBox;
  late final Box<WordCategory> _categoriesBox;

  /// Registers Hive adapters and opens the boxes. Must be awaited once,
  /// before the repository is used, typically in `main()`.
  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(WordAdapter().typeId)) {
      Hive.registerAdapter(WordAdapter());
    }
    if (!Hive.isAdapterRegistered(WordCategoryAdapter().typeId)) {
      Hive.registerAdapter(WordCategoryAdapter());
    }

    _wordsBox = await Hive.openBox<Word>(wordsBoxName);
    _categoriesBox = await Hive.openBox<WordCategory>(categoriesBoxName);
  }

  // --- Words ---------------------------------------------------------

  List<Word> getAllWords() => _wordsBox.values.toList();

  Future<void> saveWord(Word word) => _wordsBox.put(word.id, word);

  Future<void> deleteWord(String id) => _wordsBox.delete(id);

  // --- Categories ------------------------------------------------------

  List<WordCategory> getAllCategories() => _categoriesBox.values.toList();

  Future<void> saveCategory(WordCategory category) =>
      _categoriesBox.put(category.id, category);

  Future<void> deleteCategory(String id) => _categoriesBox.delete(id);
}
