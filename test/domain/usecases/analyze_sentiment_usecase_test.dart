import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sentiment_motivator/core/errors/failures.dart';
import 'package:sentiment_motivator/domain/usecases/analyze_sentiment_usecase.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late AnalyzeSentimentUseCase useCase;
  late MockSentimentRepository mockRepository;

  setUp(() {
    mockRepository = MockSentimentRepository();
    useCase = AnalyzeSentimentUseCase(repository: mockRepository);
  });

  const tText = 'I am feeling great today!';
  const tParams = AnalyzeParams(text: tText);

  test('should return SentimentAnalysis from repository on success', () async {
    when(mockRepository.analyzeSentiment(tText))
        .thenAnswer((_) async => Right(tPositiveAnalysis));

    final result = await useCase(tParams);

    expect(result, Right(tPositiveAnalysis));
    verify(mockRepository.analyzeSentiment(tText));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate failure from repository', () async {
    when(mockRepository.analyzeSentiment(tText))
        .thenAnswer((_) async => const Left(NoInternetFailure()));

    final result = await useCase(tParams);

    expect(result.isLeft(), true);
    verify(mockRepository.analyzeSentiment(tText));
  });

  test('AnalyzeParams equality works correctly', () {
    const params1 = AnalyzeParams(text: 'hello');
    const params2 = AnalyzeParams(text: 'hello');
    const params3 = AnalyzeParams(text: 'world');

    expect(params1, params2);
    expect(params1 == params3, false);
  });
}
