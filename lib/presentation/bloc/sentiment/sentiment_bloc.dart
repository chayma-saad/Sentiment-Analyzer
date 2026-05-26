import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/sentiment_analysis.dart';
import '../../../domain/usecases/analyze_sentiment_usecase.dart';

part 'sentiment_event.dart';
part 'sentiment_state.dart';

class SentimentBloc extends Bloc<SentimentEvent, SentimentState> {
  SentimentBloc({required this.analyzeSentimentUseCase})
      : super(const SentimentInitial()) {
    on<SentimentAnalyzeRequested>(_onAnalyzeRequested);
    on<SentimentReset>(_onReset);
  }

  final AnalyzeSentimentUseCase analyzeSentimentUseCase;

  Future<void> _onAnalyzeRequested(
    SentimentAnalyzeRequested event,
    Emitter<SentimentState> emit,
  ) async {
    emit(const SentimentLoading());
    final result = await analyzeSentimentUseCase(
      AnalyzeParams(text: event.text),
    );
    result.fold(
      (failure) => emit(SentimentFailure(message: failure.message)),
      (analysis) => emit(SentimentSuccess(analysis: analysis)),
    );
  }

  void _onReset(SentimentReset event, Emitter<SentimentState> emit) {
    emit(const SentimentInitial());
  }
}
