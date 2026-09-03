import '../models/word.dart';

/// How well the user recalled a word during a review. Maps to the SM-2
/// "quality of response" score (0-5), collapsed down to three buttons that
/// are easier to make sense of in the flashcard UI.
enum ReviewResult {
  /// Did not remember the word at all. SM-2 quality = 2.
  again,

  /// Remembered it, but it took real effort. SM-2 quality = 3.
  hard,

  /// Remembered it easily. SM-2 quality = 5.
  easy,
}

/// Implements the SM-2 spaced-repetition algorithm popularized by SuperMemo.
///
/// Reference: https://en.wikipedia.org/wiki/SuperMemo#Description_of_SM-2_algorithm
class SrsService {
  static const double _minEaseFactor = 1.3;

  int _qualityFor(ReviewResult result) {
    switch (result) {
      case ReviewResult.again:
        return 2;
      case ReviewResult.hard:
        return 3;
      case ReviewResult.easy:
        return 5;
    }
  }

  /// Applies [result] to [word], updating its ease factor, interval,
  /// repetition count and due date in place. Returns the same instance for
  /// convenience.
  Word review(Word word, ReviewResult result) {
    final quality = _qualityFor(result);
    final now = DateTime.now();

    if (quality < 3) {
      // Forgotten: restart the repetition streak, review again tomorrow.
      word.repetitions = 0;
      word.intervalDays = 1;
    } else {
      word.repetitions += 1;
      if (word.repetitions == 1) {
        word.intervalDays = 1;
      } else if (word.repetitions == 2) {
        word.intervalDays = 6;
      } else {
        word.intervalDays = (word.intervalDays * word.easeFactor).round();
      }

      final delta =
          0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
      word.easeFactor = word.easeFactor + delta;
      if (word.easeFactor < _minEaseFactor) {
        word.easeFactor = _minEaseFactor;
      }
    }

    word.lastReviewedAt = now;
    word.dueDate = now.add(Duration(days: word.intervalDays));
    return word;
  }
}
