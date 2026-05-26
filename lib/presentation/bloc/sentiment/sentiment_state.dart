part of 'sentiment_bloc.dart';

abstract class SentimentState extends Equatable {
  const SentimentState();

  @override
  List<Object?> get props => [];
}

class SentimentInitial extends SentimentState {
  const SentimentInitial();
}

class SentimentLoading extends SentimentState {
  const SentimentLoading();
}

class SentimentSuccess extends SentimentState {
  const SentimentSuccess({required this.analysis});
  final SentimentAnalysis analysis;

  @override
  List<Object?> get props => [analysis];
}

class SentimentFailure extends SentimentState {
  const SentimentFailure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
