import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

class RateLimitFailure extends Failure {
  const RateLimitFailure()
      : super(message: 'API rate limit reached. Please try again later.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super(message: 'Request timed out. Check your connection.');
}

class NoInternetFailure extends Failure {
  const NoInternetFailure()
      : super(message: 'No internet connection. Please check your network.');
}

class MalformedResponseFailure extends Failure {
  const MalformedResponseFailure()
      : super(message: 'Unexpected response from server.');
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to access local storage.'});
}

class InvalidApiKeyFailure extends Failure {
  const InvalidApiKeyFailure()
      : super(message: 'Invalid API key. Please check your configuration.');
}
