import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/word.dart';

class WordListTile extends StatelessWidget {
  const WordListTile({
    super.key,
    required this.word,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final Word word;
  final WordCategory? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(word.term, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(word.meaning),
            if (word.example != null) ...[
              const SizedBox(height: 2),
              Text(
                word.example!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                if (category != null)
                  Chip(
                    label: Text(category!.name),
                    visualDensity: VisualDensity.compact,
                    avatar: CircleAvatar(
                      backgroundColor: Color(category!.colorValue),
                      radius: 6,
                    ),
                  ),
                if (word.isDue)
                  Chip(
                    label: const Text('복습 필요'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '삭제',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
