import 'package:api/api.dart';

/// Ошибки по таймауту
class TimeoutException extends DioException {
  TimeoutException(DioException error)
      : super(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: error.error,
        );
}
