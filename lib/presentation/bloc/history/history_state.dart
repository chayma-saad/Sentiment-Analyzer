part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded({required this.analyses});
  final List<SentimentAnalysis> analyses;

  @override
  List<Object?> get props => [analyses];
}

class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

class HistoryFailure extends HistoryState {
  const HistoryFailure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class HistoryExportSuccess extends HistoryState {
  const HistoryExportSuccess({required this.csvContent});
  final String csvContent;

  @override
  List<Object?> get props => [csvContent];
}
