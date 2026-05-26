import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sentiment_motivator/core/errors/failures.dart';
import 'package:sentiment_motivator/domain/usecases/analyze_sentiment_usecase.dart';
import 'package:sentiment_motivator/presentation/bloc/sentiment/sentiment_bloc.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late SentimentBloc bloc;
  late MockSentimentRepository mockRepository;
  late AnalyzeSentimentUseCase useCase;

  setUp(() {
    mockRepository = MockSentimentRepository();
    useCase = AnalyzeSentimentUseCase(repository: mockRepository);
    bloc = SentimentBloc(analyzeSentimentUseCase: useCase);
  });

  tearDown(() => bloc.close());

  const tText = 'I feel great!';

  test('initial state is SentimentInitial', () {
    expect(bloc.state, const SentimentInitial());
  });

  blocTest<SentimentBloc, SentimentState>(
    'emits [Loading, Success] on successful analysis',
    build: () {
      when(mockRepository.analyzeSentiment(tText))
          .thenAnswer((_) async => Right(tPositiveAnalysis));
      return bloc;
    },
    act: (b) => b.add(const SentimentAnalyzeRequested(text: tText)),
    expect: () => [
      const SentimentLoading(),
      SentimentSuccess(analysis: tPositiveAnalysis),
    ],
  );

  blocTest<SentimentBloc, SentimentState>(
    'emits [Loading, Failure] when repository returns failure',
    build: () {
      when(mockRepository.analyzeSentiment(tText))
          .thenAnswer((_) async => const Left(NoInternetFailure()));
      return bloc;
    },
    act: (b) => b.add(const SentimentAnalyzeRequested(text: tText)),
    expect: () => [
      const SentimentLoading(),
      isA<SentimentFailure>(),
    ],
  );

  blocTest<SentimentBloc, SentimentState>(
    'emits SentimentInitial on SentimentReset',
    build: () => bloc,
    seed: () => SentimentSuccess(analysis: tPositiveAnalysis),
    act: (b) => b.add(const SentimentReset()),
    expect: () => [const SentimentInitial()],
  );
}
