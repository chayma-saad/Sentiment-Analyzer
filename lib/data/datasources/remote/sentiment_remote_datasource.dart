import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/sentiment_model.dart';

abstract class SentimentRemoteDataSource {
  Future<SentimentModel> analyzeSentiment({
    required String text,
    required String id,
    required DateTime analyzedAt,
  });
}

class SentimentRemoteDataSourceImpl implements SentimentRemoteDataSource {
  const SentimentRemoteDataSourceImpl({required this.dio});
  final Dio dio;

  @override
  Future<SentimentModel> analyzeSentiment({
    required String text,
    required String id,
    required DateTime analyzedAt,
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'your_groq_api_key_here') {
      throw const InvalidApiKeyException();
    }

    final model = dotenv.env['GROQ_MODEL'] ?? 'llama-3.1-8b-instant';

    try {
      final response = await dio.post(
        AppConstants.groqBaseUrl,
        options: Options(
          headers: {
            'content-type': 'application/json',
            'authorization': 'Bearer $apiKey',
          },
          sendTimeout:
              const Duration(seconds: AppConstants.requestTimeoutSeconds),
          receiveTimeout:
              const Duration(seconds: AppConstants.requestTimeoutSeconds),
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': _buildPrompt(text)},
          ],
          'temperature': 0.4,
          'max_tokens': 512,
        },
      );

      return _parseResponse(
        response.data,
        text: text,
        id: id,
        analyzedAt: analyzedAt,
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  SentimentModel _parseResponse(
    dynamic responseData, {
    required String text,
    required String id,
    required DateTime analyzedAt,
  }) {
    try {
      final choices = responseData['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const MalformedResponseException();
      }

      final rawText = choices.first['message']['content'] as String? ?? '';

      // Extract JSON from the response (Gemini may wrap it in markdown)
      final jsonStart = rawText.indexOf('{');
      final jsonEnd = rawText.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        throw const MalformedResponseException(
            message: 'No JSON found in response');
      }

      final jsonStr = rawText.substring(jsonStart, jsonEnd + 1);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return SentimentModel.fromApiJson(
        json,
        id: id,
        inputText: text,
        analyzedAt: analyzedAt,
      );
    } catch (e) {
      if (e is MalformedResponseException) rethrow;
      throw MalformedResponseException(message: e.toString());
    }
  }

  Never _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 429) throw const RateLimitException();
        if (statusCode == 401 || statusCode == 403) {
          throw const InvalidApiKeyException();
        }
        if (statusCode == 400) {
          final body = error.response?.data?.toString() ?? '';
          throw ServerException(message: 'Bad request: $body');
        }
        throw ServerException(message: 'HTTP $statusCode: ${error.message}');
      case DioExceptionType.connectionError:
        throw const NoInternetException();
      default:
        throw ServerException(message: error.message ?? 'Unknown error');
    }
  }

  String _buildPrompt(String text) => '''
Analyze the sentiment of the following text and respond ONLY with a valid JSON object.

The JSON must have exactly these three fields:
- "sentiment": one of "positive", "negative", or "neutral"
- "confidence": a decimal number between 0.0 and 1.0
- "motivation": a supportive motivational message (2-3 sentences) tailored to the sentiment

Text to analyze:
"$text"

Respond with JSON only. No markdown, no code fences, no extra text.
Example: {"sentiment":"positive","confidence":0.91,"motivation":"Your positive energy is wonderful!"}
''';
}
