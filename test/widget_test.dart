// Basic smoke tests for the vocabulary app: the app boots, and the SM-2
// spaced-repetition math behaves as expected.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:wordbook_app/data/word_repository.dart';
import 'package:wordbook_app/models/category.dart';
import 'package:wordbook_app/models/word.dart';
import 'package:wordbook_app/providers/word_provider.dart';
import 'package:wordbook_app/screens/home_screen.dart';
import 'package:wordbook_app/services/srs_service.dart';
import 'package:wordbook_app/theme/app_theme.dart';

/// In-memory stand-in for [WordRepository] so widget tests don't touch Hive
/// or the file system.
class FakeWordRepository implements WordRepository {
  final Map<String, Word> _words = {};
  final Map<String, WordCategory> _categories = {};

  @override
  Future<void> init() async {}

  @override
  List<Word> getAllWords() => _words.values.toList();

  @override
  Future<void> saveWord(Word word) async => _words[word.id] = word;

  @override
  Future<void> deleteWord(String id) async => _words.remove(id);

  @override
  List<WordCategory> getAllCategories() => _categories.values.toList();

  @override
  Future<void> saveCategory(WordCategory category) async =>
      _categories[category.id] = category;

  @override
  Future<void> deleteCategory(String id) async => _categories.remove(id);
}

Future<WordProvider> _loadedProvider() async {
  final provider = WordProvider(repository: FakeWordRepository());
  await provider.load();
  return provider;
}

void main() {
  testWidgets('App shows the word list tab with an empty state', (tester) async {
    final provider = await _loadedProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // "단어장" appears both as the AppBar title and the bottom nav label.
    expect(find.text('단어장'), findsWidgets);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.textContaining('아직 등록된 단어가 없어요'), findsOneWidget);
  });

  testWidgets('Adding a word shows it in the list', (tester) async {
    final provider = await _loadedProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '단어 *'), 'ephemeral');
    await tester.enterText(find.widgetWithText(TextFormField, '뜻 *'), '일시적인');
    await tester.tap(find.widgetWithText(FilledButton, '추가'));
    await tester.pumpAndSettle();

    expect(find.text('ephemeral'), findsOneWidget);
    expect(find.text('일시적인'), findsOneWidget);
  });

  group('SrsService', () {
    late SrsService srs;
    late Word word;

    setUp(() {
      srs = SrsService();
      word = Word(
        id: 'w1',
        term: 'ephemeral',
        meaning: '일시적인',
        createdAt: DateTime(2026, 1, 1),
      );
    });

    test('forgetting resets repetitions and schedules for tomorrow', () {
      word.repetitions = 3;
      word.intervalDays = 20;
      srs.review(word, ReviewResult.again);

      expect(word.repetitions, 0);
      expect(word.intervalDays, 1);
    });

    test('first successful review schedules 1 day out', () {
      srs.review(word, ReviewResult.easy);
      expect(word.repetitions, 1);
      expect(word.intervalDays, 1);
    });

    test('second successful review schedules 6 days out', () {
      srs.review(word, ReviewResult.easy);
      srs.review(word, ReviewResult.easy);
      expect(word.repetitions, 2);
      expect(word.intervalDays, 6);
    });

    test('ease factor never drops below 1.3', () {
      for (var i = 0; i < 20; i++) {
        srs.review(word, ReviewResult.hard);
      }
      expect(word.easeFactor, greaterThanOrEqualTo(1.3));
    });
  });
}
