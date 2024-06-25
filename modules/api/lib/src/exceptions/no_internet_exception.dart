import 'package:api/api.dart';

class NoInternetException implements ExceptionWithMessage {
  @override
  String get message => toString();

  @override
  String toString() => 'No internet connection';
}

class BadHostException implements ExceptionWithMessage {
  BadHostException(this._error);
  final String _error;
  @override
  String get message => _error;

  @override
  String toString() => 'Bad Host Exception';
}
