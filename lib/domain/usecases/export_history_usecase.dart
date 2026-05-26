import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/sentiment_repository.dart';

class ExportHistoryUseCase implements UseCase<String, NoParams> {
  const ExportHistoryUseCase({required this.repository});
  final SentimentRepository repository;

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.exportHistoryAsCsv();
  }
}
