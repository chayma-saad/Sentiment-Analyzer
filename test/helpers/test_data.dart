import 'package:sentiment_motivator/data/models/sentiment_model.dart';
import 'package:sentiment_motivator/domain/entities/sentiment_analysis.dart';

final tPositiveAnalysis = SentimentModel(
  id: 'test-id-1',
  inputText: 'I am feeling great today!',
  sentiment: SentimentType.positive,
  confidenceScore: 0.92,
  motivation: 'Keep up the great energy! Your positivity is infectious.',
  analyzedAt: DateTime(2024, 1, 15, 10, 30),
);

final tNegativeAnalysis = SentimentModel(
  id: 'test-id-2',
  inputText: 'Everything is going wrong.',
  sentiment: SentimentType.negative,
  confidenceScore: 0.85,
  motivation: 'Remember that tough times never last. You have the strength to get through this.',
  analyzedAt: DateTime(2024, 1, 15, 11, 0),
);

final tNeutralAnalysis = SentimentModel(
  id: 'test-id-3',
  inputText: 'The weather is mild today.',
  sentiment: SentimentType.neutral,
  confidenceScore: 0.75,
  motivation: 'Take a moment to appreciate the calm around you.',
  analyzedAt: DateTime(2024, 1, 15, 11, 30),
);

final tHistoryList = [tPositiveAnalysis, tNegativeAnalysis, tNeutralAnalysis];

const tApiResponse = {
  'content': [
    {
      'type': 'text',
      'text': '{"sentiment":"positive","confidence":0.92,"motivation":"Keep up the great energy!"}',
    }
  ],
};
