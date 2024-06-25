// ignore_for_file: non_constant_identifier_names

/// TODO нужен рефакторинг
/// НЕ КОМЕНТИРУЮ

import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';

class KanbanPageData {
  KanbanPageData.fromJson(JsonReader item)
      : cities = item['cities'].asList().map(KanbanCity.fromJson).toList(),
        orders = item['orders'].asList().map(KanbanOrder.fromJson).toList(),
        isDisplayDateFilter = item['is_display_date_filter'].asBool();

  List<KanbanCity> cities;

  List<KanbanOrder> orders;

  Map<KanbanCity, List<KanbanOrder>> get data => {
        for (final city in cities)
          city: orders.where((order) => order.city_id == city.id).toList()
      };

  bool isDisplayDateFilter = false;
}

class KanbanCity {
  KanbanCity.fromJson(JsonReader json)
      : id = json['id'].asInt(),
        name = json['name'].asStringOrNull(),
        service_address = json['service_address'].asStringOrNull(),
        is_display_in_header = json['is_display_in_header'].asInt(),
        ext_number = json['ext_number'].asStringOrNull(),
        ext_number_sc = json['ext_number_sc'].asStringOrNull(),
        ext_number_ads = json['ext_number_ads'].asStringOrNull(),
        simple_kanban_orders_count = json['simple_kanban_orders_count'].asInt();

  int id;
  String? name;

  String? service_address;
  int is_display_in_header;

  String? ext_number;
  String? ext_number_sc;
  String? ext_number_ads;
  int simple_kanban_orders_count;

  bool isOpened = true;
}

class KanbanOrder {
  KanbanOrder.fromJson(JsonReader json)
      : id = json['id'].asInt(),
        city_id = json['city_id'].asInt(),
        order_number = json['order_number'].asIntOrNull(),
        time = json['time'].asStringOrNull(),
        client_name = json['client_name'].asStringOrNull(),
        them_name = json['them_name'].asStringOrNull(),
        technique_name = json['technique_name'].asStringOrNull(),
        defect = json['defect'].asStringOrNull(),
        phone = json['phone'].asStringOrNull(),
        infoForMasterPrevent = json['info_for_master_prevent'].asStringOrNull(),
        district = json['district'].asStringOrNull(),
        company = json['company'].asMap(),
        additionalPhones =
            json['additional_phone'].asList().map((e) => e.asString()).toList(),
        isCanCall = json['is_can_call'].asBool(),
        isCanView = json['is_can_view'].asBool(),
        isCanRemoveMaster = json['is_can_remove_master'].asBool(),
        master = KanbanMaster.fromJson(json['master']),
        statusBadge = StatusBadge.fromJson(json['status_badge']),
        distance = KanbanOrderDistance.fromJson(json['distance']),
        distanceToOrder =
            KanbanOrderDistance.fromJson(json['top_master_distance_to_order']);

  int id;
  int city_id;
  int? order_number;
  String? time;
  String? client_name;
  String? them_name;
  String? technique_name;
  String? defect;
  String? phone;
  String? infoForMasterPrevent;
  String? district;
  Map<String, dynamic>? company;
  StatusBadge? statusBadge;
  KanbanMaster master;
  List<String>? additionalPhones;
  KanbanOrderDistance? distance;
  KanbanOrderDistance? distanceToOrder;

  bool isLoading = false;
  bool isPhoneCalling = false;
  bool isCanCall = false;
  bool isCanView = false;
  bool isCanRemoveMaster = false;
}

class KanbanOrderDistance {
  KanbanOrderDistance.fromJson(JsonReader json)
      : distance =
            json.containsKey('distance') ? json['distance'].asString() : null,
        unitOfMeasurement = json.containsKey('unit_of_measurement')
            ? json['unit_of_measurement'].asString()
            : null,
        createdAt = json.containsKey('created_at')
            ? json['created_at'].asString()
            : null,
        error = !json.containsKey('distance') ? json.asStringOrNull() : null;

  bool get hasError => error?.isNotEmpty == true;

  bool get hasData => hasError || distance?.isNotEmpty == true;

  final String? distance;
  final String? unitOfMeasurement;
  final String? createdAt;
  final String? error;
}

class KanbanStatus {
  KanbanStatus.fromJson(JsonReader json)
      : color = json['color'].asColor(),
        status = json['status'].asInt(),
        textStatus = json['text_status'].asStringOrNull();

  Color? color;
  int status;
  String? textStatus;
}

class KanbanMaster {
  const KanbanMaster({this.id, this.name, this.number});

  KanbanMaster.fromJson(JsonReader json)
      : id = json['id'].asIntOrNull(),
        name = json['name'].asStringOrNull(),
        number = json['number'].asIntOrNull();

  static const KanbanMaster empty = KanbanMaster();

  KanbanMaster copyWith({
    int? id,
    String? name,
    int? number,
  }) =>
      KanbanMaster(
        id: id ?? this.id,
        name: name ?? this.name,
        number: number ?? this.number,
      );

  bool get hasData => id != null && number != null && name?.isNotEmpty == true;

  final int? id;
  final String? name;
  final int? number;
}
