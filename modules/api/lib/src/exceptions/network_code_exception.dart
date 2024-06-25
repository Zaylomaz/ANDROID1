import 'package:api/api.dart';

class NetworkCodeException implements ExceptionWithMessage {
  NetworkCodeException(String message, this.code) {
    _message = message;
  }

  String _message = '';
  final int code;

  @override
  String get message => _message;

  @override
  String toString() => 'Error: code = $code, $_message';
}
