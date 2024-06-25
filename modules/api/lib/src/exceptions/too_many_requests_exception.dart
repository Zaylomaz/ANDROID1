import 'package:api/api.dart';

class TooManyRequestsException extends DioException {
  TooManyRequestsException(DioException error)
      : super(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: error.error,
        );
}
