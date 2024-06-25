import 'package:api/api.dart';
import 'package:core/core.dart';

///
/// Репозиторий для получения и хранения данных о вызовах
///
class PhoneCallsRepository extends AppRepository {
  factory PhoneCallsRepository() {
    return _singleton;
  }

  PhoneCallsRepository._internal();

  static final PhoneCallsRepository _singleton =
      PhoneCallsRepository._internal();

  Future<TabListResponse<AppPhoneCall>> getCallHistory(
      int page, AppFilter filter) async {
    final response = await GetRequest(
      '/v2/calls',
      secure: true,
      query: filter.toQueryParams()
        ..addEntries(
          [
            MapEntry('page', page),
          ],
        ),
    ).callRequest(dio);

    return TabListResponse(
      response['data'].asList().map(AppPhoneCall.fromJson).toList(),
      response['meta']['total'].asInt(),
    );
  }

  Future<AppPhoneCall> getCallDetails(int id) async {
    final response = await GetRequest(
      '/v2/calls/$id',
      secure: true,
    ).callRequest(dio);
    return AppPhoneCall.fromJson(response);
  }
}
