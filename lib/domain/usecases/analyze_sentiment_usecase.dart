import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/sentiment_analysis.dart';
import '../repositories/sentiment_repository.dart';

class AnalyzeSentimentUseCase
    implements UseCase<SentimentAnalysis, AnalyzeParams> {
  const AnalyzeSentimentUseCase({required this.repository});
  final SentimentRepository repository;

  @override
  Future<Either<Failure, SentimentAnalysis>> call(AnalyzeParams params) {
    return repository.analyzeSentiment(params.text);
  }
}

class AnalyzeParams extends Equatable {
  const AnalyzeParams({required this.text});
  final String text;

  @override
  List<Object> get props => [text];
}
