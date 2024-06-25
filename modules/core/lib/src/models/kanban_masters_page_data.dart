import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';

/// TODO нужен рефакторинг
/// НЕ КОМЕНТИРУЮ

class KanbanMasterList {
  const KanbanMasterList._(this.masters);

  factory KanbanMasterList.fromJson(JsonReader json) => KanbanMasterList._(
      json['data'].asList().map(KanbanMasterItem.fromJson).toList());

  final List<KanbanMasterItem> masters;
}

enum MasterColor { red, grey, green }

extension MasterColorExt on MasterColor {
  Color get color {
    switch (this) {
      case MasterColor.red:
        return Colors.red;
      case MasterColor.grey:
        return Colors.grey;
      case MasterColor.green:
        return Colors.green;
    }
  }
}

final masterColorMapper =
    EnumMapper<MasterColor, String>(MasterColor.values, (value) {
  switch (value) {
    case MasterColor.red:
      return 'red';
    case MasterColor.grey:
      return 'grey';
    case MasterColor.green:
      return 'green';
  }
});

class KanbanMasterItem {
  KanbanMasterItem.fromJson(JsonReader json)
      : id = json['id'].asInt(),
        name = json['name'].asString(),
        distance = json['distance'].asString(),
        color =
            masterColorMapper.toEnum(json['color'].asString().toLowerCase())!,
        isAvailable = json['is_available'].asBool(),
        specializations = json['specializations']
            .asList()
            .map(KanbanMasterSpecializations.fromJson)
            .toList();

  int id;
  String name;
  String distance;
  MasterColor color;
  bool isAvailable;
  List<KanbanMasterSpecializations> specializations;
}

class KanbanMasterSpecializations {
  KanbanMasterSpecializations.fromJson(JsonReader json)
      : id = json['id'].asInt(),
        title = json['title'].asString(),
        icon = json['icon'].asString(),
        color = json['color'].asColor(),
        pivot = KanbanMasterSpecializationsPivot.fromJson(json['pivot']);

  int id;
  String title;
  String icon;
  Color color;
  KanbanMasterSpecializationsPivot pivot;
}

class KanbanMasterSpecializationsPivot {
  KanbanMasterSpecializationsPivot.fromJson(JsonReader json)
      : userId = json['user_id'].asInt(),
        masterTagId = json['master_tag_id'].asInt();

  int userId;
  int masterTagId;
}
