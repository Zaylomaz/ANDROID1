import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';

/// Модель контакта из CRM
class AppContact extends Equatable {
  const AppContact({
    required this.id,
    required this.name,
    required this.role,
    required this.binotel,
    required this.asterisk,
    required this.phone,
    this.avatar,
    this.additionalPhone = const [],
  });

  /// Mapper
  factory AppContact.fromJson(JsonReader json) => AppContact(
        id: json['id'].asInt(),
        name: json['name'].asString(),
        role: json['role_text'].asString(),
        binotel: json['binotel_inner_phone'].asString(),
        asterisk: json['asterisk_inner_phone'].asString(),
        phone: json['phone'].asString(),
        additionalPhone: json['additionalPhone'].asListOf<String>(),
      );

  /// Количество контактов получаемых за один запрос
  static const perPage = 25;

  final int id;
  final String name;
  final Uri? avatar;
  final String role;
  final String binotel;
  final String asterisk;
  final String phone;
  final List<String> additionalPhone;

  @override
  List get props => [id, name, role, binotel, asterisk, phone, additionalPhone];

  @override
  String toString() => '''$name => $id''';
}
