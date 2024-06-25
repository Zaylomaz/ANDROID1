import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:uikit/uikit.dart';

enum NotificationType {
  finishedOrder('FINISHED_ORDER'),
  managerLostCall('LOST_CALL_FOR_MANAGER'),
  lostCall('LOST_CALL'),
  orderChange('NOTIFICATION_ABOUT_ORDER'),
  newChatMessage('NEW_CHAT_MESSAGE'),
  newOrderMakeOut('NEW_ORDER_TO_MAKE_OUT'),
  newOrder('NEW_ORDER'),
  penalty('DANGER'),
  undefined('');

  const NotificationType(this.backendValue);
  factory NotificationType.fromString(String value) =>
      NotificationType.values.firstWhere((n) => n.backendValue == value,
          orElse: () => NotificationType.undefined);
  final String backendValue;

  Color get color {
    switch (this) {
      case NotificationType.undefined:
        return AppColors.violetLight;
      case NotificationType.orderChange:
      case NotificationType.finishedOrder:
      case NotificationType.newOrder:
      case NotificationType.newOrderMakeOut:
        return AppColors.green;
      case NotificationType.newChatMessage:
        return AppColors.violet;
      case NotificationType.penalty:
      case NotificationType.managerLostCall:
      case NotificationType.lostCall:
        return AppColors.red;
    }
  }
}

typedef NotificationData = Map<String, dynamic>;

/// Модель уведомления общая
class NotificationBase {
  const NotificationBase({
    required this.id,
    required this.type,
    required this.data,
    required this.createAt,
    required this.readAt,
  });

  factory NotificationBase.fromJson(JsonReader json) {
    return NotificationBase(
      type: NotificationType.fromString(json['data']['type'].asString()),
      data: json['data'].asMap(),
      createAt: json['created_at'].asDateTime().toUtc(),
      readAt: json['read_at'].asDateTime().toUtc(),
      id: json['id'].asString(),
    );
  }

  Color get decorationColor => type.color;

  final String id;
  final NotificationType type;
  final NotificationData data;
  final DateTime createAt;
  final DateTime readAt;
}

/// Данные уведомления
abstract class NotificationDataClass {
  const NotificationDataClass(this._data);
  external factory NotificationDataClass.fromJson(NotificationData map);
  final JsonReader _data;
}

/// Данные уведомления о заказе
/// [String] get title
/// [int] get orderNumber
/// [String] get orderDate
/// [String] get clientName
/// [String] get status
/// [String] get message
/// [PhoneList] get contacts
class NotificationAboutOrder extends NotificationDataClass {
  const NotificationAboutOrder(super.data);

  factory NotificationAboutOrder.fromJson(NotificationData map) =>
      NotificationAboutOrder(JsonReader(map));

  String get title => _data['title'].asString();
  int get orderNumber => _data['order_number'].asInt();
  String get orderDate => _data['order_date'].asString();
  String get clientName => _data['client_name'].asString();
  String get status => _data['status'].asString();
  String get message => _data['message'].asString();
  PhoneList get contacts => PhoneList.fromJson(_data['contacts']);
}

/// Данные уведомления о закрытии заказа
/// [String] get title
/// [String] get user
/// [String] get status
/// [String] get orderSum
/// [PhoneList] get userContacts
class NotificationFinishedOrder extends NotificationDataClass {
  const NotificationFinishedOrder(super.data);

  factory NotificationFinishedOrder.fromJson(NotificationData map) =>
      NotificationFinishedOrder(JsonReader(map));

  String get title => _data['title'].asString();
  String get user => _data['user'].asString();
  String get status => _data['status'].asString();
  String get orderSum => _data['order_sum'].asString();
  PhoneList get userContacts => PhoneList.fromJson(_data['user_contacts']);
}

/// Данные уведомления о штрафе
/// [String] get title
/// [String] get message
class NotificationDanger extends NotificationDataClass {
  const NotificationDanger(super.data);

  factory NotificationDanger.fromJson(NotificationData map) =>
      NotificationDanger(JsonReader(map));

  String get title => _data['title'].asString();
  String get message => _data['message'].asString();
}

/// Данные уведомления о новом заказе
/// [String] get title
/// [String] get message
class NotificationNewOrder extends NotificationDataClass {
  const NotificationNewOrder(super.data);

  factory NotificationNewOrder.fromJson(NotificationData map) =>
      NotificationNewOrder(JsonReader(map));

  String get title => _data['title'].asString();
  String get message => _data['message'].asString();
}

/// Данные уведомления о заборе
/// [String] get title
/// [String] get message
/// [String] get clientName
/// [String] get technique
/// [String] get city
/// [String] get date
/// [String] get time
/// [bool] get isUrgently
class NotificationNewOrderMakeOut extends NotificationDataClass {
  const NotificationNewOrderMakeOut(super.data);

  factory NotificationNewOrderMakeOut.fromJson(NotificationData map) =>
      NotificationNewOrderMakeOut(JsonReader(map));

  String get title => _data['title'].asString();
  String get message => _data['message'].asString();
  String get clientName => _data['client_name'].asString();
  String get technique => _data['technique'].asString();
  String get defect => _data['defect'].asString();
  String get city => _data['city'].asString();
  String get date => _data['date'].asString();
  String get time => _data['time'].asString();
  bool get isUrgently => _data['is_urgently'].asBool();
}

/// Данные уведомления о пропущенном звонке
/// [String] get title
/// [String] get message
class NotificationLostCall extends NotificationDataClass {
  const NotificationLostCall(super.data);

  factory NotificationLostCall.fromJson(NotificationData map) =>
      NotificationLostCall(JsonReader(map));

  String get title => _data['title'].asString();
  String get message => _data['message'].asString();
}

/// Данные уведомления о пропущеном звонке от менеджера
/// [String] get title
/// [String] get message
/// [int] get userId
class NotificationManagerLostCall extends NotificationDataClass {
  const NotificationManagerLostCall(super.data);

  factory NotificationManagerLostCall.fromJson(NotificationData map) =>
      NotificationManagerLostCall(JsonReader(map));

  String get title => _data['title'].asString();
  String get message => _data['message'].asString();
  int get userId => _data['user_id'].asInt();
}

/// Модель пуша OneSignal
class PushNotification {
  const PushNotification._(
    this.sentTime,
    this.ttl,
    this.title,
    this.body,
    this.channel,
  );

  factory PushNotification.fromRawString(String data) {
    final json = JsonReader.decode(data);
    final channel = JsonReader.decode(json['chnl'].asString());

    return PushNotification._(
      json['google.sent_time'].asDateTime(),
      json['google.ttl'].asInt(),
      json['title'].asString(),
      json['alert'].asString(),
      PushNotificationChannel.fromId(channel['id'].asString()),
    );
  }

  final DateTime sentTime;
  final int ttl;
  final PushNotificationChannel channel;
  final String body;
  final String title;
}

/// Каналы в OneSignal
enum PushNotificationChannel {
  mainForeground(
    'OS_93fb1eec-863b-4234-a470-83c877043255',
    'Foreground',
  ),
  sip(
    'SipChannel',
    'Sip Channel',
  ),
  noSound(
    'OS_4f52d74b-67bc-4c44-ad58-1017a5d011ad',
    'No sound',
  ),
  orderChange(
    'OS_fb2442d7-fab3-449a-acc7-ffdaae7bfb47',
    'Notification about order',
  ),
  penalty(
    'OS_8be82044-147c-4b58-ade6-eb643219c2ad',
    'Penalty',
  ),
  newOrder(
    'OS_06191f65-6218-4b59-8f75-3534432fea94',
    'New order',
  ),
  newChatMessage(
    'OS_a99ed4d9-ddd1-4f7e-8db3-a207b8fa65e3',
    'New chat message',
  ),
  finishedOrder(
    'OS_088410fe-405a-456b-bac2-d2e01baec499',
    'Finished order',
  ),
  managerLostCall(
    'OS_10b02c38-b5ee-46aa-a9d0-44f2de81afe9',
    'Lost call for manager',
  ),
  lostCall(
    'OS_65c89091-5593-4863-86d4-8a3b864246c2',
    'Lost call',
  );

  const PushNotificationChannel(this.id, this.title);
  factory PushNotificationChannel.fromId(String id) =>
      PushNotificationChannel.values.firstWhere((channel) => channel.id == id,
          orElse: () => PushNotificationChannel.noSound);

  final String id;
  final String title;
}

/// Фильтр уведомлений. детальная документация в [AppFilter]
class NotificationsFilter extends AppFilter {
  const NotificationsFilter({
    required this.name,
    this.isRead,
  });

  factory NotificationsFilter.fromJson(JsonReader json) => NotificationsFilter(
        name: json['name'].asString(),
        isRead: json.containsKey('is_read') ? json['is_read'].asBool() : null,
      );

  static const empty = NotificationsFilter(name: '');

  final String name;
  final bool? isRead;

  NotificationsFilter clearRead() => NotificationsFilter(
        name: name,
      );

  @override
  NotificationsFilter copyWith({
    String? name,
    bool? isRead,
    int? cityId,
  }) =>
      NotificationsFilter(
        name: name ?? this.name,
        isRead: isRead ?? this.isRead,
      );

  @override
  String get filterName => name;

  @override
  bool get isEmpty => false;

  @override
  List get props => [name, isRead];

  @override
  Map<String, dynamic> toJson({bool dateToMemory = true}) => {
        'name': name,
        if (isRead != null) 'is_read': isRead,
      };

  @override
  Map<String, dynamic> toQueryParams() => {
        if (isRead != null) 'is_read': isRead!.asInt(),
      };
}
