part of 'sentiment_bloc.dart';

abstract class SentimentEvent extends Equatable {
  const SentimentEvent();

  @override
  List<Object> get props => [];
}

class SentimentAnalyzeRequested extends SentimentEvent {
  const SentimentAnalyzeRequested({required this.text});
  final String text;

  @override
  List<Object> get props => [text];
}

class SentimentReset extends SentimentEvent {
  const SentimentReset();
}
