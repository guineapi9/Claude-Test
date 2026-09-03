import 'package:flutter/material.dart';

import '../models/category.dart';

/// Horizontal row of filter chips: "전체" plus one chip per category.
/// [selectedCategoryId] is null when "전체" is selected.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<WordCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: const Text('전체'),
              selected: selectedCategoryId == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(category.name),
                selected: selectedCategoryId == category.id,
                avatar: CircleAvatar(
                  backgroundColor: Color(category.colorValue),
                  radius: 6,
                ),
                onSelected: (_) => onSelected(category.id),
              ),
            ),
        ],
      ),
    );
  }
}
