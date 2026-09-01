import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../services/srs_service.dart';
import '../widgets/category_filter_bar.dart';

/// Spaced-repetition review session: shows one due word at a time as a
/// flip card, and lets the user grade their own recall.
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  String? _categoryId;
  List<Word> _queue = [];
  int _index = 0;
  bool _showBack = false;
  int _reviewedCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_queue.isEmpty && _reviewedCount == 0) {
      _startSession();
    }
  }

  void _startSession() {
    final provider = context.read<WordProvider>();
    setState(() {
      _queue = provider.dueWords(categoryId: _categoryId);
      _index = 0;
      _showBack = false;
      _reviewedCount = 0;
    });
  }

  Future<void> _grade(ReviewResult result) async {
    final word = _queue[_index];
    await context.read<WordProvider>().reviewWord(word, result);
    setState(() {
      _reviewedCount++;
      _index++;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final total = _queue.length;
    final done = _index >= total;

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 복습')),
      body: Column(
        children: [
          CategoryFilterBar(
            categories: provider.categories,
            selectedCategoryId: _categoryId,
            onSelected: (id) {
              setState(() => _categoryId = id);
              _startSession();
            },
          ),
          if (total > 0 && !done)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: LinearProgressIndicator(value: _index / total),
            ),
          Expanded(
            child: total == 0
                ? _EmptyState(onRefresh: _startSession)
                : done
                    ? _CompletedState(reviewedCount: _reviewedCount, onRestart: _startSession)
                    : _FlashcardBody(
                        word: _queue[_index],
                        category: provider.categoryById(_queue[_index].categoryId),
                        showBack: _showBack,
                        progressLabel: '${_index + 1} / $total',
                        onFlip: () => setState(() => _showBack = !_showBack),
                        onGrade: _grade,
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              '지금 복습할 단어가 없어요!\n새 단어를 추가하거나 나중에 다시 확인해보세요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({required this.reviewedCount, required this.onRestart});

  final int reviewedCount;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 48),
            const SizedBox(height: 12),
            Text('오늘의 복습 완료! ($reviewedCount개)', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 확인'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardBody extends StatelessWidget {
  const _FlashcardBody({
    required this.word,
    required this.category,
    required this.showBack,
    required this.progressLabel,
    required this.onFlip,
    required this.onGrade,
  });

  final Word word;
  final WordCategory? category;
  final bool showBack;
  final String progressLabel;
  final VoidCallback onFlip;
  final ValueChanged<ReviewResult> onGrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(progressLabel, style: theme.textTheme.labelLarge),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: onFlip,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Card(
                  key: ValueKey('${word.id}-$showBack'),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 220),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: showBack
                          ? [
                              Text(
                                word.meaning,
                                style: theme.textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              if (word.example != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  word.example!,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 16),
                              Text('탭하면 다시 뒤집혀요', style: theme.textTheme.bodySmall),
                            ]
                          : [
                              Text(
                                word.term,
                                style: theme.textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              if (category != null) ...[
                                const SizedBox(height: 12),
                                Chip(label: Text(category!.name)),
                              ],
                              const SizedBox(height: 16),
                              Text('탭해서 뜻 확인하기', style: theme.textTheme.bodySmall),
                            ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: showBack
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onGrade(ReviewResult.again),
                        style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        child: const Text('다시'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onGrade(ReviewResult.hard),
                        child: const Text('애매해요'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => onGrade(ReviewResult.easy),
                        child: const Text('알아요'),
                      ),
                    ),
                  ],
                )
              : FilledButton(
                  onPressed: onFlip,
                  child: const Text('뜻 보기'),
                ),
        ),
      ],
    );
  }
}
