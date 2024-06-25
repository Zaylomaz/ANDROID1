/// Удалить вместе с моделью [ViewStateModel]
enum ViewState {
  idle,
  busy,
  empty,
  error,
  unAuthorized,
}

enum ErrorType {
  defaultError,
  networkError,
}

class ViewStateError {
  ViewStateError(this.errorType, {this.message, this.errorMessage}) {
    errorType ??= ErrorType.defaultError;
    message ??= errorMessage;
  }

  ErrorType? errorType = ErrorType.defaultError;
  String? message;
  String? errorMessage;

  bool get isNetworkError => errorType == ErrorType.networkError;

  @override
  String toString() {
    return '''ViewStateError{errorType: $errorType, message: $message, errorMessage: $errorMessage}''';
  }
}
