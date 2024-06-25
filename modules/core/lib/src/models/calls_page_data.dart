import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';

/// Типы звонков
enum AppPhoneCallType {
  // входящий
  incoming,
  // исходящий
  outgoing,
  // не удачный
  lost,
  // Потерянные
  waisted,
  // заглушка для логики
  undefined;

  // маппер
  factory AppPhoneCallType.fromInt(int type) => type == 0 ? incoming : outgoing;

  String get title {
    switch (this) {
      case AppPhoneCallType.incoming:
        return 'Входящий';
      case AppPhoneCallType.outgoing:
        return 'Исходящий';
      case AppPhoneCallType.lost:
        return 'Не удачный';
      case AppPhoneCallType.waisted:
        return 'Потерянные';
      case AppPhoneCallType.undefined:
        return 'Не выбран';
    }
  }
}

extension AppPhoneCallTypeExt on List<AppPhoneCallType> {
  List<AppPhoneCallType> get forFilter =>
      where((e) => e != AppPhoneCallType.undefined).toList();
}

/// Статус звонка
enum AppPhoneCallStatus {
  answer('ANSWER', 'Успешный', 'успешный звонок'),
  transfer('TRANSFER', 'Переведен', 'успешный звонок который был переведен'),
  online('ONLINE', 'В онлайне', 'звонок в онлайне'),
  busy('BUSY', 'Занято', 'неуспешный звонок по причине занято'),
  noanswer('NOANSWER', 'Нет ответа', 'неуспешный звонок по причине нет ответа'),
  cancel('CANCEL', 'Отмена', 'неуспешный звонок по причине отмены звонка'),
  congestion('CONGESTION', 'Неуспешный', 'Канал перегружен'),
  chanunavail('CHANUNAVAIL', 'Неуспешный', 'Канал недоступен'),
  vm('VM', 'Голосовая почта без сообщения'),
  vmSuccess('VM-SUCCESS', 'Голосовая почта с сообщением'),
  smsSending('SMS-SENDING', 'Сообщение на отправке'),
  smsSuccess('SMS-SUCCESS', 'Сообщение успешно отправлено'),
  smsFailed('SMS-FAILED', 'Сообщение не отправлено'),
  success('SUCCESS', 'Успешно принятый факс'),
  failed('FAILED', 'Непринятый факс'),
  undefined('undefined', 'undefined');

  const AppPhoneCallStatus(this.backendName, this.title, [this.description]);

  /// маппер
  factory AppPhoneCallStatus.fromJson(JsonReader json) =>
      AppPhoneCallStatus.values.firstWhere(
        (e) => e.backendName == json.asString(),
        orElse: () => AppPhoneCallStatus.undefined,
      );

  bool get isSuccess => ![
        AppPhoneCallStatus.busy,
        AppPhoneCallStatus.noanswer,
        AppPhoneCallStatus.cancel,
        AppPhoneCallStatus.congestion,
        AppPhoneCallStatus.chanunavail,
      ].contains(this);

  /// Утгь ключ бекенда
  final String backendName;

  /// Название
  final String title;

  /// Описания
  final String? description;
}

/// Модель звонка
class AppPhoneCall {
  const AppPhoneCall({
    required this.id,
    required this.name,
    required this.incomingPhone,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.duration,
    required this.waitsec,
    this.orders = const <KanbanOrder>[],
    this.recordUrl,
  });

  factory AppPhoneCall.fromJson(JsonReader json) {
    var data = json;
    if (json.containsKey('call')) {
      data = json['call'];
    }
    return AppPhoneCall(
      id: data['id'].asInt(),
      name: data['name'].asString(defaultValue: '-'),
      incomingPhone: data['incoming_phone'].asString(),
      type: AppPhoneCallType.fromInt(data['type'].asInt()),
      status: AppPhoneCallStatus.fromJson(data['status']),
      recordUrl: Uri.tryParse(data['record_url'].asString()),
      createdAt: data['created_at'].asDateTime().toUtc(),
      duration: Duration(seconds: data['duration'].asInt(defaultValue: 0)),
      waitsec: Duration(seconds: data['waitsec'].asInt(defaultValue: 0)),
      orders: json['orders'].asList().map(KanbanOrder.fromJson).toList(),
    );
  }

  final int id;
  final String name;
  final String incomingPhone;
  final AppPhoneCallStatus status;
  final AppPhoneCallType type;
  final Uri? recordUrl;
  final DateTime createdAt;
  final Duration duration;
  final Duration waitsec;
  final List<KanbanOrder> orders;

  @override
  // ignore: leading_newlines_in_multiline_strings
  String toString() => '''AppPhoneCall(
    "id": $id,
    "name": $name,
    "incomingPhone": $incomingPhone,
    "status": $status (${status.backendName}),
    "type": $type,
    "recordUrl": $recordUrl,
    "createdAt": $createdAt,
    "duration": ${duration.inSeconds},
    "waitsec": ${waitsec.inSeconds},
    "orders": "orders count -> ${orders.length}",
  )''';
}

/// Документация в интерфейсе [AppFilter]
class AppPhoneCallFilter extends AppFilter {
  const AppPhoneCallFilter({
    this.type,
    this.name = '',
    this.orderNumber = '',
    this.tabName,
  });

  factory AppPhoneCallFilter.fromJson(JsonReader json) => AppPhoneCallFilter(
        type: AppPhoneCallType.values.firstWhere(
          (e) => e.name == json['type'].asString(),
          orElse: () => AppPhoneCallType.undefined,
        ),
        name: json['name'].asString(),
        orderNumber: json['orderNumber'].asString(),
      );

  static const empty = AppPhoneCallFilter();

  @override
  Map<String, dynamic> toJson({bool? dateToMemory}) => toQueryParams();

  @override
  Map<String, dynamic> toQueryParams() => {
        if (type != null && type != AppPhoneCallType.undefined)
          'type': type!.name,
        if (name.isNotEmpty == true) 'name': name,
        if (orderNumber.isNotEmpty == true) 'order_number': orderNumber,
      };

  final AppPhoneCallType? type;
  final String name;
  final String orderNumber;
  final String? tabName;

  @override
  AppPhoneCallFilter copyWith({
    AppPhoneCallType? type,
    String? name,
    String? tabName,
    String? orderNumber,
    int? cityId,
  }) =>
      AppPhoneCallFilter(
        type: type ?? this.type,
        name: name ?? this.name,
        tabName: tabName ?? this.tabName,
        orderNumber: orderNumber ?? this.orderNumber,
      );

  @override
  bool get isEmpty =>
      (type == null || type == AppPhoneCallType.undefined) &&
      name.isEmpty &&
      orderNumber.isEmpty;

  @override
  String get filterName => tabName ?? '';

  @override
  List<Object?> get props => [
        type,
        name,
        orderNumber,
        tabName,
      ];
}
