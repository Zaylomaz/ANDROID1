import 'package:api/api.dart';
import 'package:core/core.dart';

class UnauthorizedException extends DioException {
  UnauthorizedException(DioException error, this.context)
      : super(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: error.error,
        ) {
    if (requestOptions.extra
            .containsKey(AuthInterceptor.unauthorizedRedirect) &&
        requestOptions.extra[AuthInterceptor.unauthorizedRedirect] == true) {
      _navigateLogin(context);
    }
  }
  final BuildContext context;

  Future<void> _navigateLogin(BuildContext context,
          {String routeName = '/sign_in'}) =>
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(routeName);
}
