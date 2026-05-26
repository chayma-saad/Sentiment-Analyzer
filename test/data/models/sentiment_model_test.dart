import 'package:flutter_test/flutter_test.dart';
import 'package:sentiment_motivator/data/models/sentiment_model.dart';
import 'package:sentiment_motivator/domain/entities/sentiment_analysis.dart';

void main() {
  const tId = 'test-id';
  const tInputText = 'I am feeling great!';
  final tAnalyzedAt = DateTime(2024, 1, 15, 10, 30);

  group('SentimentModel.fromApiJson', () {
    test('should parse positive sentiment correctly', () {
      final json = {
        'sentiment': 'positive',
        'confidence': 0.92,
        'motivation': 'Great energy!',
      };

      final model = SentimentModel.fromApiJson(
        json,
        id: tId,
        inputText: tInputText,
        analyzedAt: tAnalyzedAt,
      );

      expect(model.sentiment, SentimentType.positive);
      expect(model.confidenceScore, 0.92);
      expect(model.motivation, 'Great energy!');
      expect(model.id, tId);
      expect(model.inputText, tInputText);
    });

    test('should parse negative sentiment correctly', () {
      final json = {
        'sentiment': 'negative',
        'confidence': 0.80,
        'motivation': 'Stay strong!',
      };

      final model = SentimentModel.fromApiJson(
        json,
        id: tId,
        inputText: tInputText,
        analyzedAt: tAnalyzedAt,
      );

      expect(model.sentiment, SentimentType.negative);
      expect(model.confidenceScore, 0.80);
    });

    test('should default to neutral for unknown sentiment', () {
      final json = {
        'sentiment': 'unknown',
        'confidence': 0.5,
        'motivation': '',
      };

      final model = SentimentModel.fromApiJson(
        json,
        id: tId,
        inputText: tInputText,
        analyzedAt: tAnalyzedAt,
      );

      expect(model.sentiment, SentimentType.neutral);
    });

    test('should clamp confidence score to 0.0-1.0 range', () {
      final jsonOver = {
        'sentiment': 'positive',
        'confidence': 1.5,
        'motivation': '',
      };
      final jsonUnder = {
        'sentiment': 'positive',
        'confidence': -0.2,
        'motivation': '',
      };

      final modelOver = SentimentModel.fromApiJson(
        jsonOver,
        id: tId,
        inputText: tInputText,
        analyzedAt: tAnalyzedAt,
      );
      final modelUnder = SentimentModel.fromApiJson(
        jsonUnder,
        id: tId,
        inputText: tInputText,
        analyzedAt: tAnalyzedAt,
      );

      expect(modelOver.confidenceScore, 1.0);
      expect(modelUnder.confidenceScore, 0.0);
    });

    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final model = SentimentModel.fromApiJson(
        json,
        id: tId,
        inputText: tInputText,
        analyzedAt: tAnalyzedAt,
      );

      expect(model.sentiment, SentimentType.neutral);
      expect(model.confidenceScore, 0.5);
      expect(model.motivation, '');
    });
  });

  group('SentimentModel db round-trip', () {
    test('toDbMap and fromDbMap should be inverse operations', () {
      final original = SentimentModel(
        id: tId,
        inputText: tInputText,
        sentiment: SentimentType.positive,
        confidenceScore: 0.88,
        motivation: 'Keep it up!',
        analyzedAt: tAnalyzedAt,
      );

      final map = original.toDbMap();
      final restored = SentimentModel.fromDbMap(map);

      expect(restored.id, original.id);
      expect(restored.inputText, original.inputText);
      expect(restored.sentiment, original.sentiment);
      expect(restored.confidenceScore, original.confidenceScore);
      expect(restored.motivation, original.motivation);
      expect(
        restored.analyzedAt.millisecondsSinceEpoch,
        original.analyzedAt.millisecondsSinceEpoch,
      );
    });
  });

  group('SentimentAnalysis helpers', () {
    test('confidencePercent returns rounded percentage', () {
      final model = SentimentModel(
        id: tId,
        inputText: tInputText,
        sentiment: SentimentType.positive,
        confidenceScore: 0.876,
        motivation: '',
        analyzedAt: tAnalyzedAt,
      );
      expect(model.confidencePercent, 88);
    });

    test('SentimentType labels are correct', () {
      expect(SentimentType.positive.label, 'Positive');
      expect(SentimentType.negative.label, 'Negative');
      expect(SentimentType.neutral.label, 'Neutral');
    });

    test('SentimentType Arabic labels are correct', () {
      expect(SentimentType.positive.labelAr, 'إيجابي');
      expect(SentimentType.negative.labelAr, 'سلبي');
      expect(SentimentType.neutral.labelAr, 'محايد');
    });
  });
}
