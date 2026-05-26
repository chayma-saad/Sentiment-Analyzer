import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sentiment_motivator/core/errors/failures.dart';
import 'package:sentiment_motivator/core/usecases/usecase.dart';
import 'package:sentiment_motivator/domain/usecases/clear_history_usecase.dart';
import 'package:sentiment_motivator/domain/usecases/delete_analysis_usecase.dart';
import 'package:sentiment_motivator/domain/usecases/export_history_usecase.dart';
import 'package:sentiment_motivator/domain/usecases/get_history_usecase.dart';
import 'package:sentiment_motivator/presentation/bloc/history/history_bloc.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  late HistoryBloc bloc;
  late MockSentimentRepository mockRepository;

  setUp(() {
    mockRepository = MockSentimentRepository();
    bloc = HistoryBloc(
      getHistoryUseCase: GetHistoryUseCase(repository: mockRepository),
      clearHistoryUseCase: ClearHistoryUseCase(repository: mockRepository),
      deleteAnalysisUseCase: DeleteAnalysisUseCase(repository: mockRepository),
      exportHistoryUseCase: ExportHistoryUseCase(repository: mockRepository),
    );
  });

  tearDown(() => bloc.close());

  test('initial state is HistoryInitial', () {
    expect(bloc.state, const HistoryInitial());
  });

  blocTest<HistoryBloc, HistoryState>(
    'emits [Loading, Loaded] when history has items',
    build: () {
      when(mockRepository.getHistory())
          .thenAnswer((_) async => Right(tHistoryList));
      return bloc;
    },
    act: (b) => b.add(const HistoryLoadRequested()),
    expect: () => [
      const HistoryLoading(),
      HistoryLoaded(analyses: tHistoryList),
    ],
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits [Loading, Empty] when history is empty',
    build: () {
      when(mockRepository.getHistory())
          .thenAnswer((_) async => const Right([]));
      return bloc;
    },
    act: (b) => b.add(const HistoryLoadRequested()),
    expect: () => [
      const HistoryLoading(),
      const HistoryEmpty(),
    ],
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits Empty after clearing history',
    build: () {
      when(mockRepository.clearHistory())
          .thenAnswer((_) async => const Right(null));
      return bloc;
    },
    act: (b) => b.add(const HistoryClearRequested()),
    expect: () => [const HistoryEmpty()],
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits ExportSuccess on successful export',
    build: () {
      when(mockRepository.exportHistoryAsCsv())
          .thenAnswer((_) async => const Right('id,text,sentiment\n'));
      return bloc;
    },
    act: (b) => b.add(const HistoryExportRequested()),
    expect: () => [isA<HistoryExportSuccess>()],
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits Failure when getHistory fails',
    build: () {
      when(mockRepository.getHistory())
          .thenAnswer((_) async => const Left(CacheFailure()));
      return bloc;
    },
    act: (b) => b.add(const HistoryLoadRequested()),
    expect: () => [
      const HistoryLoading(),
      isA<HistoryFailure>(),
    ],
  );
}
