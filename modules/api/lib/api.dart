import 'api.dart';

export 'package:connectivity_plus/connectivity_plus.dart'
    show ConnectivityResult;
export 'package:dio/dio.dart';

export 'src/api_builder.dart';
export 'src/api_storage.dart';
export 'src/exceptions.dart';
export 'src/interceptors.dart';
export 'src/utils/api_request.dart';
export 'src/utils/check_internet.dart';

///
/// extends [AppRepository] в любой класс репозитория
/// даст возможность использовать http клиент по умолчанию
abstract class AppRepository {
  final apiBuilder = ApiBuilder();
  Dio get dio => apiBuilder.dio;
}
