import 'dart:async';
import 'dart:convert';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:uikit/uikit.dart';

class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this.key);
  final GlobalKey<NavigatorState> key;
  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      await checkInternet();
    } on NoInternetException {
      AppConnectivityNotifier.showSnackBar(
        key.currentContext!,
        ConnectivityResult.none,
      );
      return handler.reject(DioException(requestOptions: options));
    } on BadHostException {
      if (options.baseUrl ==
          Environment<AppConfig>.instance().config.apiUrl.toString()) {
        return handler.next(
          options.copyWith(
            baseUrl:
                Environment<AppConfig>.instance().config.proxyUrl.toString(),
          ),
        );
      }
      return handler.reject(DioException(requestOptions: options));
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (![200, 201].contains(response.statusCode)) {
      _checkForErrorDio(response);
    }
    return handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.error is NoInternetException) {
      AppConnectivityNotifier.showSnackBar(
        key.currentContext!,
        ConnectivityResult.none,
      );
      return handler.next(err);
    }

    if (err.type == DioExceptionType.connectionError) {
      try {
        final options = err.requestOptions.copyWith(
          baseUrl: Environment<AppConfig>.instance().config.proxyUrl.toString(),
        );
        final response = await ApiBuilder().dio.fetch(options);
        return handler.resolve(response);
      } catch (_) {
        return handler.next(err);
      }
    }

    if (err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return handler.next(TimeoutException(err));
    }

    if (err.type == DioExceptionType.unknown &&
        err.message?.contains(
                'Connection closed before full header was received') ==
            true) {
      return handler.next(TimeoutException(err));
    }

    if (err.response != null) {
      switch (err.response?.statusCode) {
        case 403:
          if (JsonReader(err.response?.data)['message'].asString() ==
              'not_active') {
            try {
              try {
                hideLoadingDialog();
              } catch (_) {}
              final response = await Navigator.maybeOf(
                key.currentContext!,
                rootNavigator: true,
              )?.pushNamed(
                AwaitAuthScreen.routeName,
                arguments: err,
              ) as Response;
              return handler.resolve(response);
            } catch (_) {}
            return handler.next(UserIsNotActiveError(err));
          }
          return handler.next(UnauthorizedException(err, key.currentContext!));
        case 429:
          return handler.next(TooManyRequestsException(err));
        case 422:
        case 423:
          return handler.next(ApiException.fromDioError(err));
        case 500:
          return handler.next(UnknownApiException(err));
      }
    }
    return handler.next(err);
  }

  void _checkForErrorDio(Response response) {
    var body = '';
    if (response.data is Map) {
      body = json.encode(response.data);
    } else if (response.data is String) {
      body = response.data;
    }

    _checkForError(body, response.realUri, response.statusCode!);
  }

  void _checkForError(String body, Uri url, int statusCode) {
    if (body.isNotEmpty) {
      dynamic errorBody;

      try {
        errorBody = jsonDecode(body)['error']['message'];
      } catch (e) {
        debugPrint(e.toString());
        try {
          errorBody = jsonDecode(body)['error'];
        } catch (e) {
          debugPrint(e.toString());
        }
      }

      if (errorBody != null) {
        String message;
        int code;
        if (errorBody is String) {
          message = errorBody;
          code = statusCode;
        } else {
          message = (errorBody['errors'] as List).last ?? errorBody['message'];
          code = errorBody['code'];
        }
        final exception = NetworkCodeException(message, code);
        throw exception;
      }
    }
  }
}

class AwaitAuthScreen extends StatelessWidget {
  const AwaitAuthScreen(this.error, {Key? key}) : super(key: key);

  static const routeName = '/await_auth';

  final DioException error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Регистрация'),
        leading: SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Image.asset(
                    'assets/salute.png',
                    package: 'uikit',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Поздравляем!',
                textAlign: TextAlign.center,
                style: AppTextStyle.boldTitle2.style(context),
              ),
              const SizedBox(height: 16),
              Text(
                '''Ваши данные для регистрации успешно отправлены. Ожидайте подтверждения от нашего менеджера''',
                textAlign: TextAlign.center,
                style: AppTextStyle.regularHeadline.style(context),
              ),
              const Spacer(flex: 2),
              PrimaryButton.violet(
                onPressed: () async {
                  try {
                    await withLoadingIndicator(() async {
                      final result = await Dio().fetch(error.requestOptions);
                      return Navigator.of(context).pop(result);
                    });
                  } catch (_) {
                    debugPrint(_.toString());
                  }
                },
                text: 'На главную',
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
