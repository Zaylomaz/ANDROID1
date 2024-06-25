import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:uikit/uikit.dart';

import 'view_state.dart';

@Deprecated('Перестать использовать и удалить')
class ViewStateModel with ChangeNotifier {
  ViewStateModel({ViewState? viewState})
      : _viewState = viewState ?? ViewState.busy;

  bool _disposed = false;

  ViewState _viewState;

  ViewState get viewState => _viewState;

  set viewState(ViewState viewState) {
    if (viewState == _viewState) return;
    _viewStateError = null;
    _viewState = viewState;
    notifyListeners();
  }

  ViewStateError? _viewStateError;

  ViewStateError? get viewStateError => _viewStateError;

  String? get errorMessage => _viewStateError?.message;

  bool get busy => viewState == ViewState.busy;

  bool get idle => viewState == ViewState.idle;

  bool get empty => viewState == ViewState.empty;

  bool get error => viewState == ViewState.error;

  bool get unAuthorized => viewState == ViewState.unAuthorized;

  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  void setUnAuthorized() {
    viewState = ViewState.unAuthorized;
    onUnAuthorizedException();
  }

  void onUnAuthorizedException() {}

  void setError(dynamic e, StackTrace stackTrace, {String? message}) {
    if (e is DioError && e.response?.statusCode == 404) {
      try {
        ScaffoldMessenger.maybeOf(AppRouter
                .navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!)
            ?.showSnackBar(
          const SnackBar(
            content: Text(
              'Заказ не найден',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } catch (_) {}
    }
    dynamic error;
    var errorType = ErrorType.defaultError;
    if (e is DioError) {
      error = e.error;
//      if (e is UnAuthorizedException) {
//        stackTrace = null;
//
//        setUnAuthorized();
//        return;
//      } else
      if (e is ExceptionWithMessage) {
      } else {
        errorType = ErrorType.networkError;
      }
    }
    viewState = ViewState.error;
    _viewStateError = ViewStateError(
      errorType,
      message: e is ExceptionWithMessage ? e.toString() : message,
      errorMessage: error.toString(),
    );
    printErrorStack(error, e is ExceptionWithMessage ? null : stackTrace);
  }

  void showErrorMessage(BuildContext context, {String? message}) {
    var message0 = message;
    if (viewStateError != null || message != null) {
      if (viewStateError?.isNetworkError == true) {
        message0 = 'Network error';
      } else {
        message0 = viewStateError?.message;
      }
      if (message0?.isNotEmpty == true) {
        Future.microtask(() {
          showMessage(context, message: message0!);
        });
      }
    }
  }

  @override
  String toString() {
    return '''BaseModel{_viewState: $viewState, _viewStateError: $_viewStateError}''';
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

void printErrorStack(dynamic e, StackTrace? s) {
  debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----error-----↓↓↓↓↓↓↓↓↓↓----->
$e
<-----↑↑↑↑↑↑↑↑↑↑-----error-----↑↑↑↑↑↑↑↑↑↑----->''');
  if (s != null) {
    debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----trace-----↓↓↓↓↓↓↓↓↓↓----->
$s
<-----↑↑↑↑↑↑↑↑↑↑-----trace-----↑↑↑↑↑↑↑↑↑↑----->
    ''');
  }
}
