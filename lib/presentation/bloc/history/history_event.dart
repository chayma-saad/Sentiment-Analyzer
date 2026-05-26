part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

class HistoryClearRequested extends HistoryEvent {
  const HistoryClearRequested();
}

class HistoryDeleteItemRequested extends HistoryEvent {
  const HistoryDeleteItemRequested({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}

class HistoryExportRequested extends HistoryEvent {
  const HistoryExportRequested();
}
