abstract class AppConstants {
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const int requestTimeoutSeconds = 30;
  static const int maxHistoryItems = 100;
  static const int debounceMilliseconds = 2000;
  static const String dbName = 'sentiment_history.db';
  static const int dbVersion = 1;
  static const String historyTableName = 'analyses';
  static const int maxInputLength = 2000;
}
