import 'package:hive/hive.dart';

part 'category.g.dart';

/// A folder-like grouping for words, e.g. "TOEIC", "일상 회화".
@HiveType(typeId: 1)
class WordCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// ARGB color value used to tint the category chip/icon.
  @HiveField(2)
  int colorValue;

  WordCategory({
    required this.id,
    required this.name,
    required this.colorValue,
  });
}
