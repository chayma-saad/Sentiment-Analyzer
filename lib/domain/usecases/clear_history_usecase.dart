import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/sentiment_repository.dart';

class ClearHistoryUseCase implements UseCase<void, NoParams> {
  const ClearHistoryUseCase({required this.repository});
  final SentimentRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.clearHistory();
  }
}
