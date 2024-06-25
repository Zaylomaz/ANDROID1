import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';

/// Старая модель заказа
class AppOrder {
  const AppOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.email,
    required this.textStatus,
    required this.infoForMasterPrevent,
    required this.infoForMasterFact,
    required this.clientName,
    required this.district,
    required this.street,
    required this.building,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.phone,
    required this.additionalPhones,
    required this.availableCloseStatus,
    required this.date,
    required this.master,
    this.time,
    this.lat,
    this.lng,
  });

  factory AppOrder.fromJson(JsonReader json) => AppOrder(
        id: json['id'].asInt(),
        orderNumber: json['order_number'].asInt(),
        status: AppOrderStatus.fromJson(json['status']),
        email: json['email'].asString(),
        textStatus: json['text_status'].asString(),
        infoForMasterPrevent: json['info_for_master_prevent'].asString(),
        infoForMasterFact: json['info_for_master_fact'].asString(),
        clientName: json['client_name'].asString(),
        district: json['district'].asString(),
        street: json['street'].asString(),
        building: json['building'].asString(),
        apartment: json['apartment'].asString(),
        entrance: json['entrance'].asString(),
        floor: json['floor'].asString(),
        phone: json['phone'].asString(),
        additionalPhones: json['additional_phone'].asListOf<String>(),
        availableCloseStatus: json['available_application_statuses'].asMap(),
        date: json['date'].asDateTime(),
        time: json['time'].asString(),
        lat: double.tryParse(json['lat'].asString()),
        lng: double.tryParse(json['lng'].asString()),
        master: AppMaster.fromJson(json['master']),
      );

  static final empty = AppOrder(
    id: -1,
    orderNumber: -1,
    status: AppOrderStatus.undefined,
    email: '',
    textStatus: '',
    infoForMasterPrevent: '',
    infoForMasterFact: '',
    clientName: '',
    district: '',
    street: '',
    building: '',
    apartment: '',
    entrance: '',
    floor: '',
    phone: '',
    additionalPhones: [],
    availableCloseStatus: {},
    date: DateTime(1970),
    master: AppMaster.empty,
  );

  final int id;
  final int orderNumber;
  final AppOrderStatus status;
  final String email;
  final String textStatus;
  final String infoForMasterPrevent;
  final String infoForMasterFact;
  final String clientName;
  final String district;
  final String street;
  final String building;
  final String apartment;
  final String entrance;
  final String floor;
  final String phone;
  final List<String> additionalPhones;
  final Map<String, int> availableCloseStatus;
  final DateTime date;
  final String? time;
  final double? lat;
  final double? lng;
  final AppMaster master;
}

/// Заказ с возможностью скрывать поля на бекенде
class AppOrderV2 {
  const AppOrderV2({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.email,
    required this.textStatus,
    required this.infoForMasterPrevent,
    required this.infoForMasterFact,
    required this.clientName,
    required this.district,
    required this.street,
    required this.building,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.phone,
    required this.additionalPhones,
    required this.availableCloseStatus,
    required this.date,
    required this.master,
    required this.time,
    required this.lat,
    required this.lng,
    required this.canPickAdditionalOrder,
  });

  factory AppOrderV2.fromJson(JsonReader json) {
    final availableFields = json['available_fields'].asListOf<String>();
    final availableActionButtons =
        json['available_action_buttons'].asListOf<String>();
    return AppOrderV2(
      id: json['id'].asInt().toObjectProperty(
            availability: availableFields.contains('id'),
          ),
      orderNumber: json['order_number'].asInt().toObjectProperty(
            availability: availableFields.contains('order_number'),
          ),
      status: AppOrderStatus.fromJson(json['status']).toObjectProperty(
        availability: availableFields.contains('text_status'),
      ),
      email: json['email'].asString().toObjectProperty(
          availability: availableActionButtons.contains('email')),
      textStatus: json['text_status'].asString().toObjectProperty(
            availability: availableFields.contains('text_status'),
          ),
      infoForMasterPrevent: json['info_for_master_prevent']
          .asString()
          .toObjectProperty(
            availability: availableFields.contains('info_for_master_prevent'),
          ),
      infoForMasterFact:
          json['info_for_master_fact'].asString().toObjectProperty(
                availability: availableFields.contains('info_for_master_fact'),
              ),
      clientName: json['client_name'].asString().toObjectProperty(
            availability: availableFields.contains('client_name'),
          ),
      district: json['district'].asString().toObjectProperty(
            availability: availableFields.contains('district'),
          ),
      street: json['street'].asString().toObjectProperty(
            availability: availableFields.contains('street'),
          ),
      building: json['building'].asString().toObjectProperty(
            availability: availableFields.contains('building'),
          ),
      apartment: json['apartment'].asString().toObjectProperty(
            availability: availableFields.contains('apartment'),
          ),
      entrance: json['entrance'].asString().toObjectProperty(
            availability: availableFields.contains('entrance'),
          ),
      floor: json['floor'].asString().toObjectProperty(
            availability: availableFields.contains('floor'),
          ),
      phone: json['phone'].asString().toObjectProperty(
            availability: availableFields.contains('phone'),
          ),
      additionalPhones:
          json['additional_phone'].asListOf<String>().toObjectProperty(
                availability: availableFields.contains('additional_phone'),
              ),
      availableCloseStatus:
          json['available_application_statuses'].asMap().toObjectProperty(
                availability:
                    availableFields.contains('available_application_statuses'),
              ),
      date: json['date'].asDateTime().toObjectProperty(
            availability: availableFields.contains('date'),
          ),
      time: json['time'].asString().toObjectProperty(
            availability: availableFields.contains('time'),
          ),
      lat: json['lat'].asDouble(defaultValue: -1).toObjectProperty(
            availability: availableActionButtons.contains('map'),
          ),
      lng: json['lng'].asDouble(defaultValue: -1).toObjectProperty(
            availability: availableActionButtons.contains('map'),
          ),
      master: AppMaster.fromJson(json['master']).toObjectProperty(
        availability: availableFields.contains('master'),
      ),
      canPickAdditionalOrder: true.toObjectProperty(
        availability: availableActionButtons.contains('additional_order'),
      ),
    );
  }

  AppOrderV2 setEmail(String? email) => AppOrderV2(
        id: id,
        orderNumber: orderNumber,
        status: status,
        email: email?.toObjectProperty() ?? this.email,
        textStatus: textStatus,
        infoForMasterPrevent: infoForMasterPrevent,
        infoForMasterFact: infoForMasterFact,
        clientName: clientName,
        district: district,
        street: street,
        building: building,
        apartment: apartment,
        entrance: entrance,
        floor: floor,
        phone: phone,
        additionalPhones: additionalPhones,
        availableCloseStatus: availableCloseStatus,
        date: date,
        time: time,
        lat: lat,
        lng: lng,
        master: master,
        canPickAdditionalOrder: canPickAdditionalOrder,
      );

  static final empty = AppOrderV2(
    id: (-1).toObjectProperty(),
    orderNumber: (-1).toObjectProperty(),
    status: AppOrderStatus.undefined.toObjectProperty(),
    email: ''.toObjectProperty(),
    textStatus: ''.toObjectProperty(),
    infoForMasterPrevent: ''.toObjectProperty(),
    infoForMasterFact: ''.toObjectProperty(),
    clientName: ''.toObjectProperty(),
    district: ''.toObjectProperty(),
    street: ''.toObjectProperty(),
    building: ''.toObjectProperty(),
    apartment: ''.toObjectProperty(),
    entrance: ''.toObjectProperty(),
    floor: ''.toObjectProperty(),
    phone: ''.toObjectProperty(),
    additionalPhones: <String>[].toObjectProperty(),
    availableCloseStatus: <String, int>{}.toObjectProperty(),
    date: DateTime(1970).toObjectProperty(),
    master: AppMaster.empty.toObjectProperty(),
    time: Property.available(''),
    lat: (-1.0).toObjectProperty(),
    lng: (-1.0).toObjectProperty(),
    canPickAdditionalOrder: false.toObjectProperty(),
  );

  Property<Coords?> get location => lat.availability &&
          lng.availability &&
          lat.value != null &&
          lng.value != null
      ? Coords(
          lat.value!,
          lng.value!,
        ).toObjectProperty(availability: lat.availability)
      : Property.hidden(null);

  bool get showAddress => street.availability || building.availability;

  String get address {
    final _street = street.availability && street.value.isNotEmpty == true
        ? street.value
        : '';
    final _building = building.availability && building.value.isNotEmpty == true
        ? (_street.isNotEmpty ? ', ' : '') + building.value
        : '';
    return _street.isNotEmpty ? '''Адрес: $_street $_building''' : '';
  }

  bool get showFullAddress =>
      floor.availability || entrance.availability || apartment.availability;

  bool get hasOptions =>
      status.value.canSeeCallButton ||
      location.availability ||
      email.availability ||
      canPickAdditionalOrder.availability;

  final Property<int> id;
  final Property<int> orderNumber;
  final Property<AppOrderStatus> status;
  final Property<String> email;
  final Property<String> textStatus;
  final Property<String> infoForMasterPrevent;
  final Property<String> infoForMasterFact;
  final Property<String> clientName;
  final Property<String> district;
  final Property<String> street;
  final Property<String> building;
  final Property<String> apartment;
  final Property<String> entrance;
  final Property<String> floor;
  final Property<String> phone;
  final Property<List<String>> additionalPhones;
  final Property<Map<String, int>> availableCloseStatus;
  final Property<DateTime> date;
  final Property<String> time;
  final Property<double?> lat;
  final Property<double?> lng;
  final Property<AppMaster> master;
  final Property<bool> canPickAdditionalOrder;
}

/// Статус заказа
enum AppOrderStatus {
  s5,
  s6,
  s7,
  s10,
  s11,
  s33,
  s34,
  s35,
  undefined;

  const AppOrderStatus();

  /// Mapper
  factory AppOrderStatus.fromJson(JsonReader json) =>
      AppOrderStatus.values.firstWhere(
        (e) => e.asInt == json.asInt(),
        orElse: () => AppOrderStatus.undefined,
      );

  int get asInt => this == undefined ? -1 : int.parse(name.substring(1));

  bool get canSeeInfoForMasterPrevent => [11, 33, 34].contains(asInt);

  bool get canSeeInfoForMasterFact => [11, 34].contains(asInt);

  bool get canSeeAddress => [10, 11, 7, 33, 34].contains(asInt);

  bool get canSeeCallButton => [7, 11, 34].contains(asInt);

  bool get canSeeFullAddress => [7, 11, 34].contains(asInt);

  bool get canSeeMap => [10, 11, 33, 34].contains(asInt);

  bool get canCloseOrder => [7, 11].contains(asInt);

  String get title {
    switch (this) {
      case AppOrderStatus.s5:
        return 'Гарантия';
      case AppOrderStatus.s6:
        return 'Забор';
      case AppOrderStatus.s7:
        return 'Доработка';
      case AppOrderStatus.s10:
        return 'Выдан';
      case AppOrderStatus.s11:
        return 'Зашел';
      case AppOrderStatus.s33:
        return 'В пути';
      case AppOrderStatus.s34:
        return 'На месте';
      case AppOrderStatus.s35:
        return 'Чек';
      default:
        return '';
    }
  }

  String get actionText {
    switch (this) {
      case AppOrderStatus.s10:
        return 'Принять';
      case AppOrderStatus.s11:
      case AppOrderStatus.s7:
        return 'Закрыть';
      case AppOrderStatus.s33:
        return 'На месте';
      case AppOrderStatus.s34:
        return 'У клиента';
      default:
        return '';
    }
  }

  AppOrderStatus get actionStatus {
    switch (this) {
      case AppOrderStatus.s7:
      case AppOrderStatus.s10:
        return AppOrderStatus.s33;
      case AppOrderStatus.s33:
        return AppOrderStatus.s34;
      case AppOrderStatus.s34:
        return AppOrderStatus.s11;
      default:
        return AppOrderStatus.undefined;
    }
  }

  bool get canSetEmail => this == s7 || this == s11 || this == s34;
}
