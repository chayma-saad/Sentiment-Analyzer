import '../../domain/entities/sentiment_analysis.dart';

class SentimentModel extends SentimentAnalysis {
  const SentimentModel({
    required super.id,
    required super.inputText,
    required super.sentiment,
    required super.confidenceScore,
    required super.motivation,
    required super.analyzedAt,
  });

  factory SentimentModel.fromApiJson(
    Map<String, dynamic> json, {
    required String id,
    required String inputText,
    required DateTime analyzedAt,
  }) {
    final sentimentRaw = (json['sentiment'] as String?)?.toLowerCase() ?? 'neutral';
    final sentiment = _parseSentiment(sentimentRaw);
    final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.5;
    final motivation = json['motivation'] as String? ?? '';

    return SentimentModel(
      id: id,
      inputText: inputText,
      sentiment: sentiment,
      confidenceScore: confidence.clamp(0.0, 1.0),
      motivation: motivation,
      analyzedAt: analyzedAt,
    );
  }

  factory SentimentModel.fromDbMap(Map<String, dynamic> map) {
    return SentimentModel(
      id: map['id'] as String,
      inputText: map['input_text'] as String,
      sentiment: _parseSentiment(map['sentiment'] as String),
      confidenceScore: (map['confidence_score'] as num).toDouble(),
      motivation: map['motivation'] as String,
      analyzedAt: DateTime.fromMillisecondsSinceEpoch(map['analyzed_at'] as int),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'input_text': inputText,
      'sentiment': sentiment.name,
      'confidence_score': confidenceScore,
      'motivation': motivation,
      'analyzed_at': analyzedAt.millisecondsSinceEpoch,
    };
  }

  static SentimentType _parseSentiment(String raw) {
    switch (raw.toLowerCase()) {
      case 'positive':
        return SentimentType.positive;
      case 'negative':
        return SentimentType.negative;
      default:
        return SentimentType.neutral;
    }
  }
}
