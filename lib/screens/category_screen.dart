import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/word_provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const List<int> _palette = [
    0xFF6750A4,
    0xFFB3261E,
    0xFF386A20,
    0xFF0061A4,
    0xFFB4600E,
    0xFF7D5260,
  ];

  Future<void> _addCategory(BuildContext context) async {
    final controller = TextEditingController();
    int selectedColor = _palette.first;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('카테고리 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: '카테고리 이름'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final color in _palette)
                    GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: Color(color),
                        radius: 16,
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );

    if (name != null && name.trim().isNotEmpty && context.mounted) {
      await context.read<WordProvider>().addCategory(name, colorValue: selectedColor);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WordCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('"${category.name}" 카테고리를 삭제할까요?\n포함된 단어는 "없음"으로 변경돼요.'),
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
    if (confirmed == true && context.mounted) {
      await context.read<WordProvider>().deleteCategory(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('카테고리 관리')),
      body: categories.isEmpty
          ? const Center(child: Text('아직 카테고리가 없어요.\n오른쪽 아래 + 버튼으로 추가해보세요.', textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final wordCount =
                    provider.words.where((w) => w.categoryId == category.id).length;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Color(category.colorValue)),
                  title: Text(category.name),
                  subtitle: Text('$wordCount개 단어'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '삭제',
                    onPressed: () => _confirmDelete(context, category),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'category_fab',
        onPressed: () => _addCategory(context),
        tooltip: '카테고리 추가',
        child: const Icon(Icons.add),
      ),
    );
  }
}
