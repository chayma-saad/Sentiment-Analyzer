import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'core/network/network_info.dart';
import 'data/datasources/local/history_local_datasource.dart';
import 'data/datasources/remote/sentiment_remote_datasource.dart';
import 'data/repositories/sentiment_repository_impl.dart';
import 'domain/repositories/sentiment_repository.dart';
import 'domain/usecases/analyze_sentiment_usecase.dart';
import 'domain/usecases/clear_history_usecase.dart';
import 'domain/usecases/delete_analysis_usecase.dart';
import 'domain/usecases/export_history_usecase.dart';
import 'domain/usecases/get_history_usecase.dart';
import 'presentation/bloc/history/history_bloc.dart';
import 'presentation/bloc/sentiment/sentiment_bloc.dart';
import 'presentation/bloc/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SentimentRemoteDataSource>(
    () => SentimentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl.instance,
  );

  // Repository
  sl.registerLazySingleton<SentimentRepository>(
    () => SentimentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      uuid: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AnalyzeSentimentUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => ClearHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteAnalysisUseCase(repository: sl()));
  sl.registerLazySingleton(() => ExportHistoryUseCase(repository: sl()));

  // BLoC / Cubits
  sl.registerFactory(
    () => SentimentBloc(analyzeSentimentUseCase: sl()),
  );
  sl.registerFactory(
    () => HistoryBloc(
      getHistoryUseCase: sl(),
      clearHistoryUseCase: sl(),
      deleteAnalysisUseCase: sl(),
      exportHistoryUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => ThemeCubit());
}
