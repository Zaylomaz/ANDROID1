import 'package:api/api.dart';
import 'package:core/core.dart';

class AuthRepository extends AppRepository {
  factory AuthRepository() {
    return _singleton;
  }

  AuthRepository._internal();

  static final AuthRepository _singleton = AuthRepository._internal();

  Future<String> login(String login, String password, String userId) async {
    final info = await _getDeviceInfo();
    final request = await GetRequest('/user/login', query: {
      'login': login,
      'password': password,
      'onesignalUserid': userId,
      'deviceId': ApiStorage().deviceId,
      ...info.toJson(),
    }).callRequest(dio);

    return request['token'].asString();
  }

  Future<UserScreenPermissions> getUserPermissions({
    bool unauthorizedRedirect = true,
    bool withInfo = true,
  }) async {
    AppDeviceInfo? info;
    if (withInfo) {
      info = await _getDeviceInfo();
    }
    final response = await GetRequest(
      'user/menu-permission',
      query: {
        'is_playmarket': Environment.instance().isPlayMarket,
        if (withInfo) ...info!.toJson(),
      },
      secure: true,
      unauthorizedRedirect: unauthorizedRedirect,
    ).callRequest(dio);
    return UserScreenPermissions.fromJson(response);
  }

  Future<AppDeviceInfo> _getDeviceInfo() async {
    final info = await AppDeviceInfo.get();
    ApiStorage().deviceId = info.deviceId;
    return info;
  }

  Future<int?> register(FormData data) async {
    final request = await FileUploadRequest(
      '/register',
      formData: data,
    ).upload(dio);
    return request.statusCode;
  }
}
