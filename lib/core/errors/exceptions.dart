class ServerException implements Exception {
  const ServerException({this.message = 'Server error occurred'});
  final String message;

  @override
  String toString() => 'ServerException: $message';
}

class RateLimitException implements Exception {
  const RateLimitException();

  @override
  String toString() => 'RateLimitException: API rate limit exceeded';
}

class TimeoutException implements Exception {
  const TimeoutException();

  @override
  String toString() => 'TimeoutException: Request timed out';
}

class NoInternetException implements Exception {
  const NoInternetException();

  @override
  String toString() => 'NoInternetException: No internet connection';
}

class MalformedResponseException implements Exception {
  const MalformedResponseException({this.message = 'Malformed API response'});
  final String message;

  @override
  String toString() => 'MalformedResponseException: $message';
}

class CacheException implements Exception {
  const CacheException({this.message = 'Local storage error'});
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class InvalidApiKeyException implements Exception {
  const InvalidApiKeyException();

  @override
  String toString() => 'InvalidApiKeyException: Invalid or missing API key';
}
