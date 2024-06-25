import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';

final _userHeaderInfo = JsonPreference<UserHeaderInfo>(
  key: const PreferenceKey(module: 'app', component: 'user', name: 'info'),
  defaultValue: UserHeaderInfo.empty,
  encoder: (data) => data.toJson(),
  decoder: (data) => UserHeaderInfo.fromJson(
    JsonReader(data),
  ),
);

class DeprecatedRepository extends AppRepository {
  factory DeprecatedRepository() {
    return _singleton;
  }

  DeprecatedRepository._internal();

  static final DeprecatedRepository _singleton =
      DeprecatedRepository._internal();

  static ProgressCallback uploadingProgress = (sent, total) {
    uploadingStream.add({sent, total});
  };

  static final uploadingStream = BehaviorSubject<Set<int>?>.seeded(null);

  UserHeaderInfo get userInfo => _userHeaderInfo.value;
  set userInfo(UserHeaderInfo data) => _userHeaderInfo.value = data;
  Stream<UserHeaderInfo> get userInfoStream => _userHeaderInfo.stream;

  Future<TabListResponse<NotificationBase>> getNotifications(
      int page, AppFilter filter) async {
    final response = await GetRequest(
      '/v2/notifications',
      query: {
        'page': page,
        ...filter.toQueryParams(),
      },
      secure: true,
    ).callRequest(dio);
    return TabListResponse(
      response['data'].asList().map(NotificationBase.fromJson).toList(),
      response['meta']['total'].asInt(),
    );
  }

  Future<bool> isLoggedIn() async {
    final response = await const GetRequest(
      '/user/is-logged-in',
      secure: true,
      unauthorizedRedirect: false,
    ).getResponse(dio);

    return response.statusCode == 200;
  }

  Future<UserHeaderInfo> getUserHeaderInfo() async {
    final response = await const GetRequest(
      '/v2/user/header-info',
      secure: true,
    ).callRequest(dio);
    return userInfo = UserHeaderInfo.fromJson(response);
  }

  Future<Response> setInWork() async {
    final response = await const GetRequest(
      '/user/set-in-work',
      secure: true,
    ).getResponse(dio);
    return response;
  }

  Future<Response> registerDevice() async {
    final response = await const PostRequest(
      '/user/register/device',
      secure: true,
    ).getResponse(dio);

    if (response.data is Map) {
      final accessToken = response.data['access_token'];
      if (accessToken != null) {
        // await saveAccessToken(response.data["access_token"]);
      }
    }
    return response;
  }

  Future<PhoneInfo> phoneInfo(
    String phone,
    String originalPhone,
    String callId,
  ) async {
    final response = await GetRequest(
      '/call/info',
      query: {
        'phone': phone,
        'originalPhone': originalPhone,
        'callId': callId,
      },
      secure: true,
    ).callRequest(dio);

    return PhoneInfo.fromJson(response);
  }

  Future<JsonReader> getSipCredential() async {
    final response = await const GetRequest(
      '/user/sip-credential',
      secure: true,
    ).callRequest(dio);

    return response;
  }

  Future<Response> updateSettings(
      double? microphoneVolume, double? speakerVolume) async {
    final response = await PostRequest(
      '/settings/store',
      body: {
        'microphone_volume': microphoneVolume,
        'speaker_volume': speakerVolume,
      },
      secure: true,
    ).getResponse(dio);

    return response;
  }

  Future<FAQList> getFAQList(int page) async {
    final result = await GetRequest(
      '/faqs',
      query: {
        'page': page,
      },
      secure: true,
    ).callRequest(dio);
    return FAQList.fromJson(result);
  }

  Future<FAQDetails> getFAQDetails(int id) async {
    final result = await GetRequest(
      '/faqs/$id',
      secure: true,
    ).callRequest(dio);
    return FAQDetails.fromJson(result['data']);
  }

  Future onColdStart() =>
      const GetRequest('/cold_start_log', secure: true).callRequest(dio);

  Future<HomePageData> getHomePageData(
      {bool unauthorizedRedirect = false}) async {
    final request = await GetRequest(
      '/v2/home',
      secure: true,
      unauthorizedRedirect: unauthorizedRedirect,
    ).callRequest(dio);
    return HomePageData.fromJson(request);
  }
}
