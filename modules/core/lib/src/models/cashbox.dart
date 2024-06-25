import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:json_reader/json_reader.dart';

/*
* Модель кассы и сопутствующих данных
* */

/// Объект кассы для простого мастера
class CashBox {
  const CashBox({
    required this.order,
    required this.user,
    required this.amount,
    required this.isSubmitted,
  });

  factory CashBox.fromJson(JsonReader json) => CashBox(
        order: AppOrder.fromJson(json['order']),
        user: AppUser.fromJson(json['user']),
        amount: json['in'].asInt(),
        isSubmitted: json['submitted'].asBool(),
      );

  final AppOrder order;
  final AppUser user;
  final int amount;
  final bool isSubmitted;
}

/// Объект кассы для админа кассы
class CashBoxList {
  const CashBoxList({
    required this.id,
    required this.description,
    required this.city,
    required this.inputAmount,
    required this.outputAmount,
    required this.orderNumber,
    required this.technique,
    required this.user,
    required this.status,
    required this.submitted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashBoxList.fromJson(JsonReader json) => CashBoxList(
        id: json['id'].asInt(),
        description: json['description'].asString(),
        city: json['city'].asString(),
        inputAmount: json['in'].asInt(),
        outputAmount: json['out'].asInt(),
        orderNumber: json['order_number'].asIntOrNull(),
        technique: json['technique'].asString(),
        user: json['user'].asString(),
        status: json['status'].asString(),
        submitted: json['submitted'].asBool(),
        createdAt: json['created_at'].asDateTime(),
        updatedAt: json['updated_at'].asDateTime(),
      );

  CashBoxList copyWith({
    bool? submitted,
    String? description,
    String? city,
    int? inputAmount,
    int? outputAmount,
    String? user,
  }) =>
      CashBoxList(
        id: id,
        description: description ?? this.description,
        city: city ?? this.city,
        inputAmount: inputAmount ?? this.inputAmount,
        outputAmount: outputAmount ?? this.outputAmount,
        orderNumber: orderNumber,
        technique: technique,
        user: user ?? this.user,
        status: status,
        submitted: submitted ?? this.submitted,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  final int id;
  final String description;
  final String city;
  final int inputAmount;
  final int outputAmount;
  final int? orderNumber;
  final String technique;
  final String user;
  final String status;
  final bool submitted;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Детальный объект кассы для админа кассы
class CashBoxDetails extends Equatable {
  const CashBoxDetails._({
    required this.userId,
    required this.cityId,
    required this.inputAmount,
    required this.outputAmount,
    required this.submitted,
    required this.description,
    required this.orderStatusName,
    required this.userName,
    required this.cityName,
    this.orderId,
    this.orderNumber,
    this.itemId,
    this.orderStatus,
    this.id,
    this.appointment,
  });

  factory CashBoxDetails.create({
    required int userId,
    required int cityId,
    required int inputAmount,
    required int outputAmount,
    required bool submitted,
    required String description,
    int? appointment,
  }) =>
      CashBoxDetails._(
        userId: userId,
        cityId: cityId,
        inputAmount: inputAmount,
        outputAmount: outputAmount,
        submitted: submitted,
        description: description,
        appointment: appointment,
        cityName: '',
        userName: '',
        orderStatusName: '',
      );

  factory CashBoxDetails.edit({
    required int id,
    required int userId,
    required int cityId,
    required int inputAmount,
    required int outputAmount,
    required bool submitted,
    required String description,
    int? orderId,
    int? orderNumber,
    int? appointment,
  }) =>
      CashBoxDetails._(
        orderId: orderId,
        orderNumber: orderNumber,
        userId: userId,
        cityId: cityId,
        inputAmount: inputAmount,
        outputAmount: outputAmount,
        submitted: submitted,
        description: description,
        id: id,
        appointment: appointment,
        cityName: '',
        userName: '',
        orderStatusName: '',
      );

  factory CashBoxDetails.fromJson(JsonReader json) => CashBoxDetails._(
        orderId: json['order_id'].asIntOrNull(),
        orderNumber: json['order_number'].asIntOrNull(),
        itemId: json['item_id'].asIntOrNull(),
        orderStatus: json['order_status'].asIntOrNull(),
        orderStatusName: json['order_status_name'].asString(),
        userId: json['user_id'].asInt(),
        userName: json['user_name'].asString(),
        cityId: json['city_id'].asInt(),
        cityName: json['city_name'].asString(),
        inputAmount: json['in'].asInt(),
        outputAmount: json['out'].asInt(),
        submitted: json['submitted'].asBool(),
        description: json['description'].asString(),
        id: json['id'].asIntOrNull(),
        appointment: json['appointment'].asInt(),
      );

  final int? orderId;
  final int? orderNumber;
  final int? itemId;
  final int? orderStatus;
  final int userId;
  final int cityId;
  final int inputAmount;
  final int outputAmount;
  final bool submitted;
  final String description;
  final int? id;
  final int? appointment;
  final String orderStatusName;
  final String userName;
  final String cityName;

  /// Подготовка данных для отправки на сервер
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'city_id': cityId,
        'in': inputAmount,
        'out': outputAmount,
        'submitted': submitted,
        'description': description.isNotEmpty ? description : null,
        if (orderId is int) 'order_id': orderId,
        if (orderNumber is int) 'order_number': orderNumber,
        if (itemId is int) 'item_id': itemId,
        if (orderStatus is int) 'order_status': orderStatus,
        if (id is int) 'id': id,
        if (appointment is int) 'appointment': appointment,
      };

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        itemId,
        orderStatus,
        userId,
        cityId,
        inputAmount,
        outputAmount,
        submitted,
        description,
        id,
        appointment,
      ];
}

/// Словарь данных
/// TODO заменить на лобальный словарь
class CashBoxOptions {
  const CashBoxOptions({
    required this.cities,
    required this.users,
    required this.appointments,
  });

  factory CashBoxOptions.fromJson(JsonReader json) => CashBoxOptions(
        cities: DictMapper.jsonMapMapper(json['cities']),
        users: DictMapper.jsonMapMapper(json['users']),
        appointments: DictMapper.jsonMapMapper(json['appointments']),
      );

  static const CashBoxOptions empty = CashBoxOptions(
    cities: {},
    users: {},
    appointments: {},
  );

  final DictChapter cities;
  final DictChapter users;
  final DictChapter appointments;
}

/// Модель баланса по городу
class CashboxBalance {
  const CashboxBalance({
    required this.city,
    required this.submitted,
    required this.total,
  });

  factory CashboxBalance.fromJson(JsonReader json) => CashboxBalance(
        city: json['city_name'].asString(),
        submitted: json['submitted'].asInt(),
        total: json['total'].asInt(),
      );

  bool get isNotEmpty => submitted > 0 || total > 0;

  String get submittedFormat => NumberFormat.currency(
        locale: 'ru',
        symbol: '',
        decimalDigits: 0,
      ).format(submitted);
  String get totalFormat => NumberFormat.currency(
        locale: 'ru',
        symbol: '',
        decimalDigits: 0,
      ).format(total);

  final String city;
  final int submitted;
  final int total;
}

/// Касса + средний чек
class CashboxData {
  const CashboxData({
    required this.balance,
    required this.averageCheck,
  });
  final List<CashboxBalance> balance;
  final String averageCheck;
  // average_check
}
