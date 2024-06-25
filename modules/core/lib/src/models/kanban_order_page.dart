import 'package:json_reader/json_reader.dart';

/// TODO нужен рефакторинг
/// НЕ КОМЕНТИРУЮ

class KanbanOrderEdit {
  const KanbanOrderEdit._({
    required this.id,
    required this.clientName,
    required this.defect,
    required this.infoForMasterPrevent,
    required this.operatorComment,
    required this.technique,
    required this.them,
    required this.city,
    required this.date,
    required this.time,
    required this.status,
    required this.checkPhoto,
    required this.photoActOfTakeawayTechnique,
    required this.masters,
    required this.availableStatuses,
    required this.availableTime,
    this.orderNumber,
    this.masterId,
    this.orderSum,
    this.isLoading = false,
  });

  factory KanbanOrderEdit.fromJson(JsonReader item) => KanbanOrderEdit._(
      id: item['id'].asInt(),
      orderNumber: item['order_number'].asIntOrNull(),
      clientName: item['client_name'].asString(defaultValue: '-'),
      defect: item['defect'].asString(defaultValue: '-'),
      infoForMasterPrevent:
          item['info_for_master_prevent'].asString(defaultValue: '-'),
      operatorComment: item['operator_comment'].asString(defaultValue: '-'),
      technique: item['technique'].asString(),
      them: item['them'].asString(),
      city: item['city'].asString(),
      date: item['date'].asDateTime(),
      time: item['time'].asString(),
      masterId: item['master_id'].asIntOrNull(),
      status: item['status'].asInt(),
      orderSum: item['order_sum'].asIntOrNull(),
      checkPhoto: item['check_photo'].asString(),
      photoActOfTakeawayTechnique:
          item['photo_act_of_takeaway_technique'].asString(),
      masters: createMasters(item['masters'].asMap()),
      availableStatuses: item['available_statuses']
          .asList()
          .map<KanbanOrderEditStatus>(KanbanOrderEditStatus.fromJson)
          .toList(),
      availableTime: createAvailableTime(item['available_time'].asMap()));

  KanbanOrderEdit copyWith({
    bool? isLoading,
    String? photoActOfTakeawayTechnique,
    String? checkPhoto,
    String? defect,
    String? infoForMasterPrevent,
    DateTime? date,
    String? time,
    List<KanbanOrderEditMaster>? masters,
    int? masterId,
    int? status,
    int? orderSum,
  }) =>
      KanbanOrderEdit._(
        id: id,
        orderNumber: orderNumber,
        clientName: clientName,
        defect: defect ?? this.defect,
        infoForMasterPrevent: infoForMasterPrevent ?? this.infoForMasterPrevent,
        operatorComment: operatorComment,
        technique: technique,
        them: them,
        city: city,
        date: date ?? this.date,
        time: time ?? this.time,
        masterId: masterId ?? this.masterId,
        status: status ?? this.status,
        orderSum: orderSum ?? this.orderSum,
        checkPhoto: checkPhoto ?? this.checkPhoto,
        photoActOfTakeawayTechnique:
            photoActOfTakeawayTechnique ?? this.photoActOfTakeawayTechnique,
        masters: masters ?? this.masters,
        availableStatuses: availableStatuses,
        availableTime: availableTime,
        isLoading: isLoading ?? this.isLoading,
      );

  final int id;
  final int? orderNumber;
  final String clientName;
  final String defect;
  final String infoForMasterPrevent;
  final String operatorComment;
  final String technique;
  final String them;
  final String city;
  final DateTime date;
  final String time;
  final int? masterId;
  final int status;
  final int? orderSum;
  final String checkPhoto;
  final String photoActOfTakeawayTechnique;
  final List<KanbanOrderEditMaster> masters;
  final List<KanbanOrderEditStatus> availableStatuses;
  final List<KanbanOrderEditTime> availableTime;
  final bool isLoading;

  static List<KanbanOrderEditMaster> createMasters(Map item) {
    final list = <KanbanOrderEditMaster>[];
    item.forEach((id, name) {
      list.add(KanbanOrderEditMaster(int.parse(id), name));
    });
    return list;
  }

  static List<KanbanOrderEditTime> createAvailableTime(Map item) {
    final list = <KanbanOrderEditTime>[];
    item.forEach((id, value) {
      list.add(KanbanOrderEditTime(value));
    });
    return list;
  }
}

class KanbanOrderEditMaster {
  KanbanOrderEditMaster(this.id, this.name);
  int id;
  String name;
}

class KanbanOrderEditStatus {
  const KanbanOrderEditStatus._({
    required this.id,
    required this.value,
  });
  factory KanbanOrderEditStatus.fromJson(JsonReader item) =>
      KanbanOrderEditStatus._(
        id: item['id'].asInt(),
        value: item['value'].asString(),
      );
  final int id;
  final String value;
}

class KanbanOrderEditTime {
  const KanbanOrderEditTime(this.value);
  final String value;
}
