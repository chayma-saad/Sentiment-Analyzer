import 'package:equatable/equatable.dart';

enum SentimentType { positive, negative, neutral }

extension SentimentTypeExtension on SentimentType {
  String get label {
    switch (this) {
      case SentimentType.positive:
        return 'Positive';
      case SentimentType.negative:
        return 'Negative';
      case SentimentType.neutral:
        return 'Neutral';
    }
  }

  String get labelAr {
    switch (this) {
      case SentimentType.positive:
        return 'إيجابي';
      case SentimentType.negative:
        return 'سلبي';
      case SentimentType.neutral:
        return 'محايد';
    }
  }
}

class SentimentAnalysis extends Equatable {
  const SentimentAnalysis({
    required this.id,
    required this.inputText,
    required this.sentiment,
    required this.confidenceScore,
    required this.motivation,
    required this.analyzedAt,
  });

  final String id;
  final String inputText;
  final SentimentType sentiment;
  final double confidenceScore;
  final String motivation;
  final DateTime analyzedAt;

  int get confidencePercent => (confidenceScore * 100).round();

  @override
  List<Object> get props => [
        id,
        inputText,
        sentiment,
        confidenceScore,
        motivation,
        analyzedAt,
      ];
}
