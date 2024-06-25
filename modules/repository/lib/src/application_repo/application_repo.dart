import 'package:api/api.dart';
import 'package:core/core.dart';

class ApplicationRepository extends AppRepository {
  factory ApplicationRepository() {
    return _singleton;
  }

  ApplicationRepository._internal();

  static final ApplicationRepository _singleton =
      ApplicationRepository._internal();

  Future<TabListResponse<ApplicantData>> getApplicantList(
    int page,
    AppFilter filter,
  ) async {
    final response = await GetRequest('/applicants', secure: true, query: {
      ...filter.toQueryParams(),
      'page': page,
      'per_page': 10,
    }).callRequest(dio);
    return TabListResponse(
      response['data'].asList().map(ApplicantData.fromJson).toList(),
      response['meta']['total'].asInt(),
    );
  }

  Future<ApplicantFilterOptions> getDict() async {
    final response = await const GetRequest(
      '/applicants_filter_options',
      secure: true,
    ).callRequest(dio);
    return ApplicantFilterOptions.fromJson(response);
  }

  Future<ApplicantData> getToWork(int applicantId) async {
    final request = await GetRequest(
      'applicants/get_to_work/$applicantId',
      secure: true,
    ).callRequest(dio);
    return ApplicantData.fromJson(request['data']);
  }

  Future<ApplicantData> editApplicant(
    int applicantId,
    Map<String, dynamic> body,
  ) async {
    final request = await PutRequest(
      'applicants/$applicantId',
      body: body,
      secure: true,
    ).callRequest(dio);
    return ApplicantData.fromJson(request['data']);
  }

  Future<Map<ApplicantFilterInputs, Map<int?, String>>>
      getUpdateOptions() async {
    final request = await const GetRequest(
      '/applicants_update_options',
      secure: true,
    ).callRequest(dio);
    final map = request.asMap();
    return map
        .map((key, value) => MapEntry(
            ApplicantFilterInputs.values.firstWhere((e) => e.backendName == key,
                orElse: () => ApplicantFilterInputs.undefined),
            value))
        .map((key, value) {
      if (value is List) {
        return MapEntry(key, {
          for (var i = 0; i < value.length; i++) i: value[i],
        });
      } else if (value is Map) {
        return MapEntry(
            key, value.map((key, value) => MapEntry(int.tryParse(key), value)));
      } else {
        return MapEntry(key, value);
      }
    });
  }
}
