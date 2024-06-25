import 'dart:ui';

import 'package:json_reader/json_reader.dart';

/// Модель для включения SIP клиента на нативной стороне
class SipSettings {
  SipSettings(
    this.login,
    this.password,
    this.server, {
    this.microphoneVolume = 2.9,
    this.speakerVolume = 2.9,
    this.isSuspended = false,
  });

  String login;
  String password;
  String server;
  double microphoneVolume;
  double speakerVolume;

  // выкючает сип
  bool isSuspended;
}

/// Модель информации о том кому мы звоним по SIP
class PhoneInfo {
  const PhoneInfo._({
    required this.names,
    required this.cities,
    required this.addresses,
    required this.orders,
  });

  factory PhoneInfo.fromJson(JsonReader json) => PhoneInfo._(
        names: json['names'].asList().map((e) => e.asString()).toList(),
        cities: json['cities'].asList().map((e) => e.asString()).toList(),
        addresses: json['addresses'].asList().map((e) => e.asString()).toList(),
        orders: json['orders'].asList().map(PhoneInfoOrder.fromJson).toList(),
      );

  final List<String> names;
  final List<String> cities;
  final List<String> addresses;
  final List<PhoneInfoOrder> orders;
}

/// Упрощенная модель заказа для списка заказов [PhoneInfo]
class PhoneInfoOrder {
  const PhoneInfoOrder({
    required this.orderNumber,
    required this.orderSum,
    required this.statusBadge,
    required this.date,
    required this.address,
  });

  factory PhoneInfoOrder.fromJson(JsonReader json) => PhoneInfoOrder(
        orderNumber: json['order_number'].asIntOrNull(),
        orderSum: json['order_sum'].asInt(),
        statusBadge: PhoneInfoOrderBadge.fromJson(json['status_badge']),
        date: json['date'].asString(),
        address: json['address'].asString(),
      );

  final int? orderNumber;
  final int orderSum;
  final PhoneInfoOrderBadge statusBadge;
  final String date;
  final String address;
}

/// Статус заказа [PhoneInfoOrder]
class PhoneInfoOrderBadge {
  const PhoneInfoOrderBadge({
    required this.color,
    required this.status,
    required this.textStatus,
  });

  factory PhoneInfoOrderBadge.fromJson(JsonReader json) => PhoneInfoOrderBadge(
        color: json['color'].asColor(),
        status: json['status'].asInt(),
        textStatus: json['text_status'].asString(),
      );

  final Color color;
  final int status;
  final String textStatus;
}

/// Список телефонов у любой сущности
class PhoneList {
  const PhoneList._(
    this.primary,
    this.binotel,
    this.asterisk,
    this.ringostat,
    this.additional,
  );

  factory PhoneList.fromJson(JsonReader json) => PhoneList._(
        json['phone'].asString(),
        json['binotel_line'].asString(),
        json['asterisk_line'].asString(),
        json['ringostat_line'].asString(),
        json['additional_phone'].asListOf<String>(),
      );

  bool get isEmpty => primary.isEmpty && additional.isEmpty;

  final String primary;
  final String binotel;
  final String asterisk;
  final String ringostat;
  final List<String> additional;
}
