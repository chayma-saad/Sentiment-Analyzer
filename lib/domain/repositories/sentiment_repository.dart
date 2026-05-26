import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/sentiment_analysis.dart';

abstract class SentimentRepository {
  Future<Either<Failure, SentimentAnalysis>> analyzeSentiment(String text);

  Future<Either<Failure, List<SentimentAnalysis>>> getHistory();

  Future<Either<Failure, void>> clearHistory();

  Future<Either<Failure, void>> deleteAnalysis(String id);

  Future<Either<Failure, String>> exportHistoryAsCsv();
}
