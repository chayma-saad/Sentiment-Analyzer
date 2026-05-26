import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/sentiment_analysis.dart';
import '../../../domain/usecases/clear_history_usecase.dart';
import '../../../domain/usecases/delete_analysis_usecase.dart';
import '../../../domain/usecases/export_history_usecase.dart';
import '../../../domain/usecases/get_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required this.getHistoryUseCase,
    required this.clearHistoryUseCase,
    required this.deleteAnalysisUseCase,
    required this.exportHistoryUseCase,
  }) : super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryClearRequested>(_onClearRequested);
    on<HistoryDeleteItemRequested>(_onDeleteItemRequested);
    on<HistoryExportRequested>(_onExportRequested);
  }

  final GetHistoryUseCase getHistoryUseCase;
  final ClearHistoryUseCase clearHistoryUseCase;
  final DeleteAnalysisUseCase deleteAnalysisUseCase;
  final ExportHistoryUseCase exportHistoryUseCase;

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    final result = await getHistoryUseCase(const NoParams());
    result.fold(
      (failure) => emit(HistoryFailure(message: failure.message)),
      (analyses) => analyses.isEmpty
          ? emit(const HistoryEmpty())
          : emit(HistoryLoaded(analyses: analyses)),
    );
  }

  Future<void> _onClearRequested(
    HistoryClearRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await clearHistoryUseCase(const NoParams());
    result.fold(
      (failure) => emit(HistoryFailure(message: failure.message)),
      (_) => emit(const HistoryEmpty()),
    );
  }

  Future<void> _onDeleteItemRequested(
    HistoryDeleteItemRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await deleteAnalysisUseCase(DeleteParams(id: event.id));
    result.fold(
      (failure) => emit(HistoryFailure(message: failure.message)),
      (_) => add(const HistoryLoadRequested()),
    );
  }

  Future<void> _onExportRequested(
    HistoryExportRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await exportHistoryUseCase(const NoParams());
    result.fold(
      (failure) => emit(HistoryFailure(message: failure.message)),
      (csv) => emit(HistoryExportSuccess(csvContent: csv)),
    );
  }
}
