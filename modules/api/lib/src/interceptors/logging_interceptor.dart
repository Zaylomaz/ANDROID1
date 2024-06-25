import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (Environment<AppConfig>.instance().config.showApiRequestsInConsole ||
        kDebugMode) {
      logPrint('*** API Request - Start ***');

      printKV('URI', options.uri);
      printKV('METHOD', options.method);
      logPrint('HEADERS:');
      options.headers.forEach((key, v) => printKV(' - $key', v as Object));
      logPrint('BODY:');
      printAll(options.data ?? '');

      logPrint('*** API Request - End ***');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (Environment<AppConfig>.instance().config.showApiRequestsInConsole ||
        kDebugMode) {
      logPrint('*** Api Error - Start ***:');
      logPrint('URI: ${err.requestOptions.uri}');
      if (err.response != null) {
        logPrint('STATUS CODE: ${err.response!.statusCode?.toString()}');
      }
      logPrint('$err');
      if (err.response != null) {
        printKV(
          'REDIRECT',
          err.response!.redirects.isNotEmpty == true
              ? err.response!.realUri
              : err.requestOptions.uri,
        );
        logPrint('BODY:');
        printAll(err.response?.toString());
      }

      logPrint('*** Api Error - End ***:');
    }
    return super.onError(err, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (Environment<AppConfig>.instance().config.showApiRequestsInConsole ||
        kDebugMode) {
      logPrint('*** Api Response - Start ***');

      printKV('URI', response.requestOptions.uri);
      printKV('STATUS CODE', response.statusCode!);
      printKV('REDIRECT', response.isRedirect);
      logPrint('BODY:');
      printAll(response.data ?? '');

      logPrint('*** Api Response - End ***');
    }
    return super.onResponse(response, handler);
  }

  void printKV(String key, Object v) {
    logPrint('$key: $v');
  }

  void printAll(dynamic msg) {
    msg.toString().split('\n').forEach(logPrint);
  }

  void logPrint(String s) {
    printWrapped(s);
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
  }
}
