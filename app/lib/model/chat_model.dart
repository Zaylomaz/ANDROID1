// ignore_for_file: constant_identifier_names

import 'package:core/core.dart';
import 'package:flutter/services.dart';

/// Провайдер чата построенный на взаиможействии с нативным кодом
/// Получает данные по каналу о новых сообщениях
///
class ChatModel extends ChangeNotifier {
  ChatModel() {
    ///Начинает слушать стрим ивентов
    onEvent.listen((event) async {
      switch (event!.name) {
        case ChatEvent.NEW_CHANNEL_MESSAGE:
          channelId = int.parse(event.body['channelId']);
          break;
        case ChatEvent.CHECK_NOTIFICATION:
          notifyListeners();
          break;
      }
    });
  }

  ///Нативный канал {app/android/app/src/main/kotlin/com/rempc/app/MainActivity.kt}
  static const EventChannel _eventChannel = EventChannel('rempc_chat_events');

  ///Стрим ивентов из канала
  static Stream<ChatEvent?> get onEvent =>
      _eventChannel.receiveBroadcastStream().map(_receiveEvent);

  ///Обработка ивента
  static ChatEvent _receiveEvent(dynamic data) {
    var event = '';
    dynamic body = {};
    if (data is Map) {
      event = data['event'];
      body = Map<String, dynamic>.from(data['body']);
    }
    return ChatEvent(event, body);
  }

  ///Текущий ID чата
  int _channelId = 0;

  int get channelId => _channelId;

  set channelId(int channelId) {
    _channelId = channelId;
    if (_channelId != 0) {
      notifyListeners();
    }
  }
}

///Ивент из стрима нативного канала
class ChatEvent {
  ChatEvent(this.name, this.body);

  static const String NEW_CHANNEL_MESSAGE = 'NEW_CHANNEL_MESSAGE';
  static const String CHECK_NOTIFICATION = 'CHECK_NOTIFICATION';

  String name;
  dynamic body;
}
