import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sentiment_motivator/core/usecases/usecase.dart';
import 'package:sentiment_motivator/domain/usecases/get_history_usecase.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late GetHistoryUseCase useCase;
  late MockSentimentRepository mockRepository;

  setUp(() {
    mockRepository = MockSentimentRepository();
    useCase = GetHistoryUseCase(repository: mockRepository);
  });

  test('should return list of analyses from repository', () async {
    when(mockRepository.getHistory())
        .thenAnswer((_) async => Right(tHistoryList));

    final result = await useCase(const NoParams());

    expect(result, Right(tHistoryList));
    verify(mockRepository.getHistory());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when history is empty', () async {
    when(mockRepository.getHistory())
        .thenAnswer((_) async => const Right([]));

    final result = await useCase(const NoParams());

    result.fold(
      (_) => fail('Expected Right'),
      (list) => expect(list, isEmpty),
    );
  });
}
