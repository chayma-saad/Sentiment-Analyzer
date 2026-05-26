import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/sentiment_analysis.dart';
import '../../domain/repositories/sentiment_repository.dart';
import '../datasources/local/history_local_datasource.dart';
import '../datasources/remote/sentiment_remote_datasource.dart';
import '../models/sentiment_model.dart';

class SentimentRepositoryImpl implements SentimentRepository {
  const SentimentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.uuid,
  });

  final SentimentRemoteDataSource remoteDataSource;
  final HistoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  @override
  Future<Either<Failure, SentimentAnalysis>> analyzeSentiment(String text) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NoInternetFailure());
    }

    try {
      final id = uuid.v4();
      final now = DateTime.now();
      final model = await remoteDataSource.analyzeSentiment(
        text: text,
        id: id,
        analyzedAt: now,
      );
      await localDataSource.insertAnalysis(model);
      return Right(model);
    } on RateLimitException {
      return const Left(RateLimitFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on NoInternetException {
      return const Left(NoInternetFailure());
    } on InvalidApiKeyException {
      return const Left(InvalidApiKeyFailure());
    } on MalformedResponseException {
      return const Left(MalformedResponseFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<SentimentAnalysis>>> getHistory() async {
    try {
      final history = await localDataSource.getHistory();
      return Right(history);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnalysis(String id) async {
    try {
      await localDataSource.deleteAnalysis(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> exportHistoryAsCsv() async {
    try {
      final history = await localDataSource.getHistory();
      final rows = <List<dynamic>>[
        ['ID', 'Text', 'Sentiment', 'Confidence %', 'Motivation', 'Date'],
        ...history.map(
          (item) => [
            item.id,
            item.inputText,
            item.sentiment.label,
            item.confidencePercent,
            item.motivation,
            item.analyzedAt.toIso8601String(),
          ],
        ),
      ];
      final csv = const ListToCsvConverter().convert(rows);
      return Right(csv);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
