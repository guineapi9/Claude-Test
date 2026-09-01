import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/word_list_tile.dart';
import 'word_form_screen.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  String? _selectedCategoryId;
  String _query = '';

  Future<void> _confirmDelete(Word word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단어 삭제'),
        content: Text('"${word.term}" 단어를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<WordProvider>().deleteWord(word);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final words = provider.filteredWords(
      categoryId: _selectedCategoryId,
      query: _query,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('단어장')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '단어 또는 뜻 검색',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          CategoryFilterBar(
            categories: provider.categories,
            selectedCategoryId: _selectedCategoryId,
            onSelected: (id) => setState(() => _selectedCategoryId = id),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: words.isEmpty
                ? Center(
                    child: Text(
                      provider.words.isEmpty
                          ? '아직 등록된 단어가 없어요.\n오른쪽 아래 + 버튼으로 추가해보세요.'
                          : '검색 결과가 없어요.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return WordListTile(
                        word: word,
                        category: provider.categoryById(word.categoryId),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WordFormScreen(word: word),
                          ),
                        ),
                        onDelete: () => _confirmDelete(word),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'word_list_fab',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WordFormScreen()),
        ),
        tooltip: '단어 추가',
        child: const Icon(Icons.add),
      ),
    );
  }
}
