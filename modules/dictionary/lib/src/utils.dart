import 'package:dictionary/src/models.dart';
import 'package:json_reader/json_reader.dart';

mixin DictMapper {
  /// Маппер словарей
  /// Преобразует json объект в [DictChapter]
  /// При ошибке вернет пустой объект
  static DictChapter jsonMapMapper(JsonReader json) {
    try {
      return json
          .asMap<String>()
          .map((key, value) => MapEntry(int.parse(key), value));
    } catch (e) {
      return DictChapter.identity();
    }
  }

  static Map<String, dynamic> toJsonValue(DictChapter map) =>
      map.map((key, value) => MapEntry(key.toString(), value));
}
