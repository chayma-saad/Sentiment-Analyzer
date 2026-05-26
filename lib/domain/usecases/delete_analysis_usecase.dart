import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/sentiment_repository.dart';

class DeleteAnalysisUseCase implements UseCase<void, DeleteParams> {
  const DeleteAnalysisUseCase({required this.repository});
  final SentimentRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteParams params) {
    return repository.deleteAnalysis(params.id);
  }
}

class DeleteParams extends Equatable {
  const DeleteParams({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}
