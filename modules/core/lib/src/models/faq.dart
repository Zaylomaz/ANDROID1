import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
/*
* Модель часто задаваемых вопросов
*/

/// Интерфейс часто задаваемого вопроса
abstract class FAQModel {
  const FAQModel({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;
}

/// Часто задаваемый вопрос в списке
@immutable
class FAQSimple implements FAQModel {
  const FAQSimple({required this.id, required this.title});

  factory FAQSimple.fromJson(JsonReader json) => FAQSimple(
        title: json['title'].asString(),
        id: json['id'].asInt(),
      );

  @override
  final int id;
  @override
  final String title;
}

/// Список часто задаваемых вопросов
@immutable
class FAQList {
  const FAQList({
    required this.total,
    required this.data,
  });

  factory FAQList.fromJson(JsonReader json) => FAQList(
        total: json['total'].asInt(),
        data: json['data'].asList().map(FAQSimple.fromJson).toList(),
      );

  static const int perPage = 10;

  final List<FAQModel> data;
  final int total;
}

/// Детальная информация по вопросу
@immutable
class FAQDetails extends FAQModel {
  const FAQDetails({
    required super.id,
    required super.title,
    required this.text,
  });

  factory FAQDetails.fromJson(JsonReader json) => FAQDetails(
        id: json['id'].asInt(),
        title: json['title'].asString(),
        text: json['text'].asString(),
      );

  /// HTML контент
  final String text;
}
