import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/sentiment_analysis.dart';
import '../repositories/sentiment_repository.dart';

class GetHistoryUseCase implements UseCase<List<SentimentAnalysis>, NoParams> {
  const GetHistoryUseCase({required this.repository});
  final SentimentRepository repository;

  @override
  Future<Either<Failure, List<SentimentAnalysis>>> call(NoParams params) {
    return repository.getHistory();
  }
}
