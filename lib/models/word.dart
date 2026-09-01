import 'package:hive/hive.dart';

part 'word.g.dart';

/// A single vocabulary entry, including its spaced-repetition (SM-2) state.
@HiveType(typeId: 0)
class Word extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String term;

  @HiveField(2)
  String meaning;

  @HiveField(3)
  String? example;

  @HiveField(4)
  String? categoryId;

  @HiveField(5)
  final DateTime createdAt;

  /// SM-2 easiness factor. Higher = easier to remember. Min 1.3.
  @HiveField(6)
  double easeFactor;

  /// Current review interval, in days.
  @HiveField(7)
  int intervalDays;

  /// Number of consecutive successful reviews.
  @HiveField(8)
  int repetitions;

  /// Next date this word should be reviewed.
  @HiveField(9)
  DateTime dueDate;

  @HiveField(10)
  DateTime? lastReviewedAt;

  Word({
    required this.id,
    required this.term,
    required this.meaning,
    this.example,
    this.categoryId,
    required this.createdAt,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    DateTime? dueDate,
    this.lastReviewedAt,
  }) : dueDate = dueDate ?? createdAt;

  bool get isDue => !dueDate.isAfter(DateTime.now());
}
