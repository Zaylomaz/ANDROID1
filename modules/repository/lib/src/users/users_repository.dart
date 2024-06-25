import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';

final appMasterUserDict = JsonPreference<AppMasterUserDict>(
  key: const PreferenceKey(
    module: 'repository',
    component: 'user',
    name: 'dict',
  ),
  defaultValue: AppMasterUserDict.empty,
  encoder: (dict) => dict.toJson(),
  decoder: (json) => AppMasterUserDict.fromJson(JsonReader(json)),
);

class UsersRepository extends AppRepository {
  factory UsersRepository() {
    return _singleton;
  }

  UsersRepository._internal();

  static final UsersRepository _singleton = UsersRepository._internal();

  AppMasterUserDict get dict => appMasterUserDict.value;

  Future addNewUser({
    required Map<String, dynamic> body,
    XFile? avatar,
    List<XFile> documents = const [],
  }) async {
    final formData = FormData.fromMap(body);
    if (avatar != null) {
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
        ),
      ));
    }
    for (final document in documents) {
      formData.files.add(MapEntry(
        'document_photos[]',
        await MultipartFile.fromFile(
          document.path,
          filename: document.path.split('/').last,
        ),
      ));
    }

    await FileUploadRequest('/v2/users', secure: true, formData: formData)
        .upload(dio);
  }

  Future editUser(
    int id, {
    required Map<String, dynamic> body,
    XFile? avatar,
    List<XFile> documents = const [],
  }) async {
    final formData = FormData.fromMap(body);
    if (avatar != null) {
      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.path.split('/').last,
          ),
        ),
      );
    }
    for (final document in documents) {
      formData.files.add(MapEntry(
        'document_photos[]',
        await MultipartFile.fromFile(
          document.path,
          filename: document.path.split('/').last,
        ),
      ));
    }
    await FileUploadRequest(
      '/v2/users/$id',
      secure: true,
      formData: formData,
    ).upload(dio);
  }

  Future<AppMasterUser> getUserInfo(int id) async {
    final json =
        await GetRequest('/v2/users/$id', secure: true).callRequest(dio);
    return AppMasterUser.fromJson(json['data']);
  }

  Future<TabListResponse<AppMasterUser>> getUsersList(
      int page, AppFilter filter) async {
    final response = await GetRequest('/v2/users', secure: true, query: {
      'page': page,
      ...filter.toQueryParams(),
    }).callRequest(dio);
    return TabListResponse(
      response['data'].asList().map(AppMasterUser.fromJson).toList(),
      response['meta']['total'].asInt(),
    );
  }

  Future<AppMasterUserDict> getUsersListFilter() async {
    final data = await const GetRequest('/v2/users/filter', secure: true)
        .callRequest(dio);
    appMasterUserDict.value = AppMasterUserDict.fromJson(data);
    return dict;
  }

  Future<TabListResponse<AppContact>> getContacts(int page) async {
    final response = await GetRequest(
      '/v2/users-contacts',
      query: {
        'page': page,
        'per_page': AppContact.perPage,
      },
      secure: true,
    ).callRequest(dio);
    return TabListResponse(
      response['data'].asList().map(AppContact.fromJson).toList(),
      response['meta']['total'].asInt(),
    );
  }
}
