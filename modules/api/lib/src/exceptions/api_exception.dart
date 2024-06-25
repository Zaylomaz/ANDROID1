import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:json_reader/json_reader.dart';

abstract class ExceptionWithMessage implements Exception {
  const ExceptionWithMessage();
  String get message => '';
}

class ApiException extends DioException {
  ApiException(
    DioException error,
    this.messages,
  ) : super(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: error.error,
        );

  factory ApiException.fromDioError(DioException error) {
    try {
      final json = JsonReader(error.response?.data);
      if (json.asMap().values.isNotEmpty) {
        return ApiException(
          error,
          json.asMap().map(
                (key, value) => MapEntry(
                  key,
                  value is List
                      ? value.map((e) => e.toString()).toList()
                      : [value.toString()],
                ),
              ),
        );
      }
      return UnknownApiException(error);
    } catch (e) {
      return UnknownApiException(error);
    }
  }

  final Map<String, List<String>> messages;

  @override
  String get message {
    final buffer = StringBuffer();
    for (final item in messages.entries) {
      buffer.write('${item.key}: ');
      for (final errorItem in item.value) {
        buffer.write('$errorItem, ');
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

class UnknownApiException extends ApiException {
  UnknownApiException(DioException error)
      : super(
          error,
          {
            'error': ['Unknown error']
          },
        );
}

class UserIsNotActiveError extends ApiException {
  UserIsNotActiveError(DioException error)
      : super(
          error,
          {
            'error': ['Пользователь не активен']
          },
        );
}
