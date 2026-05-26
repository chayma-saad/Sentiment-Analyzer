import 'package:mockito/annotations.dart';
import 'package:sentiment_motivator/core/network/network_info.dart';
import 'package:sentiment_motivator/data/datasources/local/history_local_datasource.dart';
import 'package:sentiment_motivator/data/datasources/remote/sentiment_remote_datasource.dart';
import 'package:sentiment_motivator/domain/repositories/sentiment_repository.dart';

@GenerateMocks([
  SentimentRepository,
  SentimentRemoteDataSource,
  HistoryLocalDataSource,
  NetworkInfo,
])
void main() {}
