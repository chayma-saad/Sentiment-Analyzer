import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/sentiment_model.dart';

abstract class HistoryLocalDataSource {
  Future<List<SentimentModel>> getHistory();
  Future<void> insertAnalysis(SentimentModel model);
  Future<void> deleteAnalysis(String id);
  Future<void> clearHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  HistoryLocalDataSourceImpl._();
  static final HistoryLocalDataSourceImpl instance = HistoryLocalDataSourceImpl._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.historyTableName} (
            id TEXT PRIMARY KEY,
            input_text TEXT NOT NULL,
            sentiment TEXT NOT NULL,
            confidence_score REAL NOT NULL,
            motivation TEXT NOT NULL,
            analyzed_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<SentimentModel>> getHistory() async {
    try {
      final db = await database;
      final maps = await db.query(
        AppConstants.historyTableName,
        orderBy: 'analyzed_at DESC',
        limit: AppConstants.maxHistoryItems,
      );
      return maps.map(SentimentModel.fromDbMap).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> insertAnalysis(SentimentModel model) async {
    try {
      final db = await database;
      await db.insert(
        AppConstants.historyTableName,
        model.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAnalysis(String id) async {
    try {
      final db = await database;
      await db.delete(
        AppConstants.historyTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final db = await database;
      await db.delete(AppConstants.historyTableName);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
