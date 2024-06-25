import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:json_reader/json_reader.dart';

/*
* Модель мастеров в приложении
*/

class AppMaster {
  const AppMaster({
    required this.id,
    required this.name,
    required this.email,
    required this.number,
    required this.cityId,
    required this.phone,
    required this.homeAddress,
    required this.onesignalToken,
    required this.active,
    required this.weekendDays,
    required this.role,
    required this.orderPercent,
    required this.documentPhoto,
    required this.avatar,
    required this.additionalPhone,
    required this.isGeoAvailable,
    required this.isContactsAvailable,
    required this.isMicrophoneAvailable,
    required this.isCameraAvailable,
    required this.them,
    required this.currentOrderId,
    required this.extNumber,
    required this.microphoneVolume,
    required this.speakerVolume,
    required this.comment,
    required this.orderInterestRateCategoryId,
    required this.cities,
    required this.weekendDaysByName,
    required this.workStatus,
    required this.inWorkToday,
  });

  factory AppMaster.fromJson(JsonReader json) => AppMaster(
        id: json['id'].asInt(),
        name: json['name'].asString(),
        email: json['email'].asString(),
        number: json['number'].asInt(),
        cityId: json['city_id'].asInt(),
        phone: json['phone'].asString(),
        homeAddress: json['home_address'].asString(),
        onesignalToken: json['onesignal_token'].asString(),
        active: json['active'].asBool(),
        weekendDays: json['weekend_days']
            .asList()
            .map((e) => int.parse(e.asString()))
            .toList(),
        role: json['role'].asInt(),
        orderPercent: json['order_percent'].asInt(),
        documentPhoto: Uri.tryParse(
            '''${Environment<AppConfig>.instance().config.apiUrl}${json['document_photo'].asString()}'''),
        avatar: Uri.tryParse(
            '''${Environment<AppConfig>.instance().config.apiUrl}${json['avatar'].asString()}'''),
        additionalPhone: json['additional_phone'].asListOf<String>(),
        isGeoAvailable: json['is_geo_available'].asBool(),
        isContactsAvailable: json['is_contacts_available'].asBool(),
        isMicrophoneAvailable: json['is_microphone_available'].asBool(),
        isCameraAvailable: json['is_camera_available'].asBool(),
        them: json['them'].asInt(),
        currentOrderId: json['current_order_id'].asString(),
        extNumber: json['ext_number'].asInt(),
        microphoneVolume: json['microphone_volume'].asInt(),
        speakerVolume: json['speaker_volume'].asInt(),
        comment: json['comment'].asString(),
        orderInterestRateCategoryId:
            json['order_interest_rate_category_id'].asInt(),
        cities: json['cities']
            .asList()
            .map((e) => int.parse(e.asString()))
            .toList(),
        weekendDaysByName: json['weekend_days_by_name'].asListOf<String>(),
        workStatus: json['work_status'].asInt(),
        inWorkToday: json['in_work_today'].asList(),
      );

  static const empty = AppMaster(
    id: -1,
    name: '',
    email: '',
    number: -1,
    cityId: -1,
    phone: '',
    homeAddress: '',
    onesignalToken: '',
    active: false,
    weekendDays: [],
    role: -1,
    orderPercent: -1,
    documentPhoto: null,
    avatar: null,
    additionalPhone: [],
    isGeoAvailable: false,
    isContactsAvailable: false,
    isMicrophoneAvailable: false,
    isCameraAvailable: false,
    them: -1,
    currentOrderId: '',
    extNumber: -1,
    microphoneVolume: -1,
    speakerVolume: -1,
    comment: '',
    orderInterestRateCategoryId: -1,
    cities: [],
    weekendDaysByName: [],
    workStatus: -1,
    inWorkToday: [],
  );

  final int id;
  final String name;
  final String email;
  final int number;
  final int cityId;
  final String phone;
  final String homeAddress;
  final String onesignalToken;
  final bool active;
  final List<int> weekendDays;
  final int role;
  final int orderPercent;
  final Uri? documentPhoto;
  final Uri? avatar;
  final List<String> additionalPhone;
  final bool isGeoAvailable;
  final bool isContactsAvailable;
  final bool isMicrophoneAvailable;
  final bool isCameraAvailable;
  final int them;
  final String currentOrderId;
  final int extNumber;
  final int microphoneVolume;
  final int speakerVolume;
  final String comment;
  final int orderInterestRateCategoryId;
  final List<int> cities;
  final List<String> weekendDaysByName;
  final int workStatus;
  final List inWorkToday;
}

class AppMasterUser extends AppUser {
  const AppMasterUser({
    required super.id,
    required super.name,
    required super.email,
    required super.contacts,
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.homeAddress,
    required this.comment,
    required this.tags,
    required this.number,
    required this.cityId,
    required this.companyId,
    required this.role,
    required this.them,
    required this.active,
    required this.isCanCall,
    required this.isCanView,
    required this.isCanRemoveMaster,
    required this.isCanEdit,
    required this.documentPhotos,
    this.avatar,
    this.fieldsToEdit = const <String, bool>{},
  });

  factory AppMasterUser.fromJson(JsonReader json) {
    final tags = <String, String>{};
    try {
      final _tags = json['tags'].asMap<String>();
      if (_tags.isNotEmpty) {
        tags.addAll(_tags);
      }
    } catch (_) {}
    return AppMasterUser(
      id: json['id'].asInt(),
      name: json['name'].asString(),
      email: json['email'].asString(),
      contacts: PhoneList.fromJson(json['contacts']),
      firstName: json['first_name'].asString(),
      lastName: json['last_name'].asString(),
      patronymic: json['patronymic'].asString(),
      homeAddress: json['home_address'].asString(),
      comment: json['comment'].asString(),
      tags: tags,
      number: json['number'].asInt(),
      cityId: json['city_id'].asInt(),
      companyId: json['company_id'].asInt(),
      role: json['role'].asInt(),
      them: json['them'].asInt(),
      active: json['active'].asBool(),
      isCanCall: json['is_can_call'].asBool(),
      isCanView: json['is_can_view'].asBool(),
      isCanEdit: json['is_can_edit'].asBool(),
      fieldsToEdit: json['is_can_edit_field'].asMap<bool>(),
      isCanRemoveMaster: json['is_can_remove_master'].asBool(),
      documentPhotos: json['document_photos']
          .asList()
          .map((e) => Uri.parse(e.asString()))
          .toList(),
      avatar: json.containsKey('avatar')
          ? Uri.tryParse(json['avatar'].asString())
          : null,
    );
  }

  static AppMasterUser empty = AppMasterUser.fromJson(JsonReader({}));

  String get fullName {
    final fName = ['$lastName\n$firstName', patronymic].join(' ');
    if (fName.trim().isNotEmpty) return fName;
    return name;
  }

  bool get canEditStatus => fieldsToEdit['status'] ?? true;

  bool get canEditName => fieldsToEdit['name'] ?? true;

  bool get canEditDocuments => fieldsToEdit['documents'] ?? true;

  bool get canEditContactInfo => fieldsToEdit['contact_info'] ?? true;

  bool get canEditCompany => fieldsToEdit['company'] ?? true;

  bool get canEditRole => fieldsToEdit['role'] ?? true;

  bool get canEditThem => fieldsToEdit['them'] ?? true;

  bool get canEditTags => fieldsToEdit['tags'] ?? true;

  bool get canEditComment => fieldsToEdit['comment'] ?? true;

  bool get canEditAvailableButtons => fieldsToEdit['available_buttons'] ?? true;

  bool get canEditSpec => [
        canEditCompany,
        canEditRole,
        canEditThem,
        canEditTags,
        canEditComment
      ].any((e) => e == true);

  final String firstName;
  final String lastName;
  final String patronymic;
  final String homeAddress;
  final String comment;
  final Map<String, String> tags;
  final int number;
  final int cityId;
  final int companyId;
  final int role;
  final int them;
  final bool active;
  final bool isCanCall;
  final bool isCanView;
  final bool isCanEdit;
  final bool isCanRemoveMaster;
  final List<Uri> documentPhotos;
  final Uri? avatar;
  final Map<String, bool> fieldsToEdit;
}

/// Словарь для фильтра
/// TODO перейти на глобальный словарь
class AppMasterUserDict extends AbstractDictionary {
  const AppMasterUserDict({
    required this.companyId,
    required this.cityId,
    required this.role,
    required this.them,
    required this.tags,
  });

  factory AppMasterUserDict.fromJson(JsonReader json) => AppMasterUserDict(
        companyId: DictMapper.jsonMapMapper(json['company_id']),
        cityId: DictMapper.jsonMapMapper(json['city_id']),
        role: DictMapper.jsonMapMapper(json['role']),
        them: DictMapper.jsonMapMapper(json['them']),
        tags: DictMapper.jsonMapMapper(json['tags']),
      );

  static const empty = AppMasterUserDict(
    companyId: {},
    cityId: {},
    role: {},
    them: {},
    tags: {},
  );

  static Map<String, dynamic> toJsonValue(Map<int, String> map) =>
      map.map((key, value) => MapEntry(key.toString(), value));

  bool get isEmpty =>
      companyId.isEmpty &&
      cityId.isEmpty &&
      role.isEmpty &&
      them.isEmpty &&
      tags.isEmpty;

  Map<String, dynamic> toJson() => {
        if (companyId.isNotEmpty) 'company_id': toJsonValue(companyId),
        if (cityId.isNotEmpty) 'city_id': toJsonValue(cityId),
        if (role.isNotEmpty) 'role': toJsonValue(role),
        if (them.isNotEmpty) 'them': toJsonValue(them),
        if (tags.isNotEmpty) 'tags': toJsonValue(tags),
      };

  @override
  List<Object?> get props => [
        companyId,
        cityId,
        role,
        them,
        tags,
      ];

  final DictChapter companyId;
  final DictChapter cityId;
  final DictChapter role;
  final DictChapter them;
  final DictChapter tags;
}

/// Документация в интерфейсе [AppFilter]
class AppMasterUserFilter extends AppFilter {
  const AppMasterUserFilter({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.masterName = '',
    this.number = '',
    this.cityId = const [],
    this.role = const [],
    this.them = const [],
    this.companyId = const [],
    this.active,
  });

  factory AppMasterUserFilter.fromJson(JsonReader json) => AppMasterUserFilter(
        number: json['number'].asString(),
        name: json['filter_name'].asString(),
        email: json['email'].asString(),
        phone: json['phone'].asString(),
        active: json.containsKey('active') ? json['active'].asBool() : null,
        cityId: json['city_id'].asListOf<int>(),
        role: json['role'].asListOf<int>(),
        them: json['them'].asListOf<int>(),
        companyId: json['company_id'].asListOf<int>(),
        masterName: json['name'].asString(),
      );

  static const empty = AppMasterUserFilter();

  final String number;
  final bool? active;
  final String name;
  final String email;
  final String phone;
  final List<int> cityId;
  final List<int> role;
  final List<int> them;
  final List<int> companyId;
  final String masterName;

  @override
  List get props => [
        number,
        name,
        email,
        phone,
        active,
        cityId,
        role,
        them,
        companyId,
        masterName,
      ];

  AppMasterUserFilter clearActive() => AppMasterUserFilter(
        number: number,
        name: name,
        email: email,
        phone: phone,
        cityId: cityId,
        role: role,
        them: them,
        companyId: companyId,
        masterName: masterName,
      );

  @override
  AppMasterUserFilter copyWith({
    String? number,
    String? name,
    String? masterName,
    String? email,
    String? phone,
    bool? active,
    List<int>? cityId,
    List<int>? role,
    List<int>? them,
    List<int>? companyId,
  }) =>
      AppMasterUserFilter(
        number: number ?? this.number,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        active: active ?? this.active,
        cityId: cityId ?? this.cityId,
        role: role ?? this.role,
        them: them ?? this.them,
        companyId: companyId ?? this.companyId,
        masterName: masterName ?? this.masterName,
      );

  @override
  bool get isEmpty =>
      active == null &&
      number.isEmpty &&
      name.isEmpty &&
      email.isEmpty &&
      phone.isEmpty &&
      cityId.isEmpty &&
      role.isEmpty &&
      them.isEmpty &&
      masterName.isNotEmpty &&
      companyId.isEmpty;

  @override
  String get filterName => name;

  @override
  Map<String, dynamic> toJson({bool dateToMemory = false}) => {
        if (active != null) 'active': active!.asInt(),
        if (number.trim().isNotEmpty == true) 'number': number,
        if (masterName.trim().isNotEmpty == true) 'name': masterName,
        if (email.trim().isNotEmpty) 'email': email,
        if (phone.trim().isNotEmpty) 'phone': phone,
        if (cityId.isNotEmpty) 'city_id': cityId,
        if (role.isNotEmpty) 'role': role,
        if (them.isNotEmpty) 'them': them,
        if (companyId.isNotEmpty) 'company_id': companyId,
      };

  @override
  Map<String, dynamic> toQueryParams() => {
        if (active != null) 'active': active!.asInt(),
        if (number.trim().isNotEmpty == true) 'number': number,
        if (masterName.trim().isNotEmpty == true) 'name': masterName,
        if (email.trim().isNotEmpty) 'email': email,
        if (phone.trim().isNotEmpty) 'phone': phone,
        if (cityId.isNotEmpty) 'city_id[]': cityId,
        if (role.isNotEmpty) 'role[]': role,
        if (them.isNotEmpty) 'them[]': them,
        if (companyId.isNotEmpty) 'company_id[]': companyId,
      };
}
