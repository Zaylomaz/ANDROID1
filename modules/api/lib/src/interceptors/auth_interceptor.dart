import 'package:api/api.dart';
import 'package:core/core.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.refreshSession});

  final Future<bool> Function() refreshSession;
  final _apiStorage = ApiStorage();
  final _dio = ApiBuilder().dio;

  static const flag = 'accessToken';
  static const unauthorizedRedirect = 'redirectToLogin';

  bool needToRefreshToken(DioException err) {
    return false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if ((options.extra.containsKey(flag) && options.extra[flag] == true) &&
        _apiStorage.accessToken.isNotEmpty) {
      if (!options.queryParameters.containsKey('token')) {
        options.queryParameters.addAll({
          'token': _apiStorage.accessToken,
        });
      } else {
        options.queryParameters['token'] = _apiStorage.accessToken;
      }
    }

    return super.onRequest(options, handler);
  }

  @override
  Future onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (needToRefreshToken(err)) {
      final success = await refreshSession();

      if (success) {
        final queryParams = err.requestOptions.queryParameters
          ..addAll({
            'token': _apiStorage.accessToken,
          });

        final options = Options(
          method: err.requestOptions.method,
        );

        try {
          final response = await _dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: queryParams,
            options: options,
            onReceiveProgress: err.requestOptions.onReceiveProgress,
          );

          return handler.resolve(response);
        } on DioException catch (_) {
          debugPrint('EXPIRED FAILED');
          _apiStorage.clear();

          return super.onError(err, handler);
        }
      }
    }

    if (err.response?.statusCode is num && err.response!.statusCode! >= 400) {
      debugPrint('+++ START OF err');
      debugPrint(err.toString());
      debugPrint('=== END OF err');
      return super.onError(err, handler);
    }

    return super.onError(err, handler);
  }
}
