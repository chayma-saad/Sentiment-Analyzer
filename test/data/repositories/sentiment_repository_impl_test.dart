import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';
import 'package:sentiment_motivator/core/errors/exceptions.dart';
import 'package:sentiment_motivator/core/errors/failures.dart';
import 'package:sentiment_motivator/data/repositories/sentiment_repository_impl.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.mocks.dart';

class _FakeNetworkInfo extends MockNetworkInfo {
  final bool connected;
  _FakeNetworkInfo({required this.connected});

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  late SentimentRepositoryImpl repository;
  late MockSentimentRemoteDataSource mockRemote;
  late MockHistoryLocalDataSource mockLocal;
  late _FakeNetworkInfo fakeNetwork;

  const tText = 'I feel amazing today!';

  setUp(() {
    mockRemote = MockSentimentRemoteDataSource();
    mockLocal = MockHistoryLocalDataSource();
    fakeNetwork = _FakeNetworkInfo(connected: true);
    repository = SentimentRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: fakeNetwork,
      uuid: const Uuid(),
    );
  });

  group('analyzeSentiment', () {
    test('returns NoInternetFailure when offline', () async {
      final offlineRepo = SentimentRepositoryImpl(
        remoteDataSource: mockRemote,
        localDataSource: mockLocal,
        networkInfo: _FakeNetworkInfo(connected: false),
        uuid: const Uuid(),
      );

      final result = await offlineRepo.analyzeSentiment(tText);

      expect(result, const Left(NoInternetFailure()));
      verifyNever(mockRemote.analyzeSentiment(
        text: anyNamed('text'),
        id: anyNamed('id'),
        analyzedAt: anyNamed('analyzedAt'),
      ));
    });

    test('returns analysis and caches on success', () async {
      when(mockRemote.analyzeSentiment(
        text: anyNamed('text'),
        id: anyNamed('id'),
        analyzedAt: anyNamed('analyzedAt'),
      )).thenAnswer((_) async => tPositiveAnalysis);
      when(mockLocal.insertAnalysis(any)).thenAnswer((_) async {});

      final result = await repository.analyzeSentiment(tText);

      expect(result.isRight(), true);
      verify(mockLocal.insertAnalysis(any));
    });

    test('returns RateLimitFailure on RateLimitException', () async {
      when(mockRemote.analyzeSentiment(
        text: anyNamed('text'),
        id: anyNamed('id'),
        analyzedAt: anyNamed('analyzedAt'),
      )).thenThrow(const RateLimitException());

      final result = await repository.analyzeSentiment(tText);

      expect(result, const Left(RateLimitFailure()));
    });

    test('returns TimeoutFailure on TimeoutException', () async {
      when(mockRemote.analyzeSentiment(
        text: anyNamed('text'),
        id: anyNamed('id'),
        analyzedAt: anyNamed('analyzedAt'),
      )).thenThrow(const TimeoutException());

      final result = await repository.analyzeSentiment(tText);

      expect(result, const Left(TimeoutFailure()));
    });

    test('returns InvalidApiKeyFailure on InvalidApiKeyException', () async {
      when(mockRemote.analyzeSentiment(
        text: anyNamed('text'),
        id: anyNamed('id'),
        analyzedAt: anyNamed('analyzedAt'),
      )).thenThrow(const InvalidApiKeyException());

      final result = await repository.analyzeSentiment(tText);

      expect(result, const Left(InvalidApiKeyFailure()));
    });

    test('returns MalformedResponseFailure on MalformedResponseException',
        () async {
      when(mockRemote.analyzeSentiment(
        text: anyNamed('text'),
        id: anyNamed('id'),
        analyzedAt: anyNamed('analyzedAt'),
      )).thenThrow(const MalformedResponseException());

      final result = await repository.analyzeSentiment(tText);

      expect(result, const Left(MalformedResponseFailure()));
    });
  });

  group('getHistory', () {
    test('returns list from local datasource', () async {
      when(mockLocal.getHistory()).thenAnswer((_) async => tHistoryList);

      final result = await repository.getHistory();

      expect(result, Right(tHistoryList));
    });

    test('returns CacheFailure on CacheException', () async {
      when(mockLocal.getHistory()).thenThrow(const CacheException());

      final result = await repository.getHistory();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('clearHistory', () {
    test('calls local datasource clearHistory', () async {
      when(mockLocal.clearHistory()).thenAnswer((_) async {});

      final result = await repository.clearHistory();

      expect(result, const Right(null));
      verify(mockLocal.clearHistory());
    });
  });

  group('deleteAnalysis', () {
    test('calls local datasource deleteAnalysis with correct id', () async {
      when(mockLocal.deleteAnalysis(any)).thenAnswer((_) async {});

      final result = await repository.deleteAnalysis('test-id');

      expect(result, const Right(null));
      verify(mockLocal.deleteAnalysis('test-id'));
    });
  });
}
