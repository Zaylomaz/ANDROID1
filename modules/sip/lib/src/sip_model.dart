// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';

/// Провайдер отвечающий за прием и осуществление звонков
/// TODO переписать на MobX
class SipModel extends ChangeNotifier {
  SipModel(this.navigator) {
    /// Подписка на ивенты по звонкам SIP клиента
    callSub = onEvent.listen((event) async {
      switch (event!.name) {
        /// Нам звонят
        case 'INCOMING_CALL':
          _isManualCalling = false;
          _lastRemoteUrl = event.body['remoteUrl'];
          final phoneInfoRequest = await DeprecatedRepository().phoneInfo(
            getPhoneNumber,
            _lastRemoteUrl,
            event.body['callId'] ?? '',
          );
          phoneInfo = phoneInfoRequest;
          isOutgoing = false;
          notifyListeners();
          break;

        /// мы звоним
        case 'OUTGOING_CALL':
          _lastRemoteUrl = event.body['remoteUrl'];
          final phoneInfoRequest = await DeprecatedRepository().phoneInfo(
            getPhoneNumber,
            _lastRemoteUrl,
            event.body['callId'] ?? '',
          );
          phoneInfo = phoneInfoRequest;
          if (!isActiveCallScreen) {
            isActiveCallScreen = true;
            unawaited(navigator.pushNamed(CallScreen.routeName));
          }
          isOutgoing = true;
          notifyListeners();
          break;

        /// изменилось состояние звонка
        case 'CALL_STATE':
          await updateState(event.body);
          break;
      }
    });

    _fetchCallStatus();
  }

  final NavigatorState navigator;

  @override
  void dispose() {
    callSub.cancel();
    super.dispose();
  }

  final platform = const MethodChannel('helperService');

  late StreamSubscription callSub;

  static const int PJSIP_INV_STATE_NULL = 0;
  static const int PJSIP_INV_STATE_CALLING = 1;
  static const int PJSIP_INV_STATE_INCOMING = 2;
  static const int PJSIP_INV_STATE_EARLY = 3;
  static const int PJSIP_INV_STATE_CONNECTING = 4;
  static const int PJSIP_INV_STATE_CONFIRMED = 5;
  static const int PJSIP_INV_STATE_DISCONNECTED = 6;

  /// звонит ли пользователь сейчас
  bool isOutgoing = false;

  /// показываем ли мы экран текущего звонка
  bool isActiveCallScreen = false;

  /// говорит ли кто-то по телифионии
  bool _isActiveCall = false;

  bool get isActiveCall => _isActiveCall;

  /// Настройки SIP клиента
  SipSettings? _settings;

  /// Настройка микрофона
  double get micVolume => _settings?.microphoneVolume ?? 2.9;

  set micVolume(double newVolume) => _settings?.microphoneVolume = newVolume;

  /// Громкость динамиков
  double get speakerVolume => _settings?.speakerVolume ?? 2.9;

  set speakerVolume(double newVolume) => _settings?.speakerVolume = newVolume;

  /// Доступен ли SIP клиент для работы с ним
  bool get isActive => _settings != null && _settings!.isSuspended == false;

  /// Состояние текущего звонка если 0 => звонка просто нет
  int callState = 0;

  /// Пользователь сам позвонил
  bool _isManualCalling = false;

  String _lastRemoteUrl = '';

  String get lastRemoteUrl => _lastRemoteUrl;

  String _lastPhoneNumber = '';

  String get getPhoneNumber {
    var phone = _lastRemoteUrl;
    if (phone.contains('<')) {
      phone = phone.substring(phone.indexOf('<') + 1);
      phone = phone.substring(0, phone.indexOf('>'));
    }
    phone = phone.replaceAll('sip:38', '');
    phone = phone.replaceAll('sip:', '');
    phone = phone.substring(0, phone.indexOf('@'));
    return phone;
  }

  String _lastCallId = '';

  String get lastCallId => _lastCallId;

  PhoneInfo? phoneInfo;

  String get getName {
    if (_isManualCalling) {
      return _lastPhoneNumber;
    }
    if (phoneInfo?.names.isNotEmpty == true) {
      return phoneInfo!.names.first;
    }
    return 'Неопределен';
  }

  List<String> get getNames {
    if (_isManualCalling) {
      return [_lastPhoneNumber];
    }
    return phoneInfo?.names ?? [];
  }

  String get getCity {
    if (_isManualCalling) {
      return '-';
    }

    if (phoneInfo?.cities.isNotEmpty == true) {
      return phoneInfo!.cities.first;
    }

    return '-';
  }

  List<String> get getCities => phoneInfo?.cities ?? [];

  String get getAddress {
    if (_isManualCalling) {
      return '-';
    }

    if (phoneInfo?.addresses.isNotEmpty == true) {
      return phoneInfo!.addresses.first;
    }

    return '-';
  }

  List<String> get getAddresses {
    if (_isManualCalling) {
      return [];
    }

    return phoneInfo?.addresses ?? [];
  }

  List<PhoneInfoOrder> get getOrders {
    if (_isManualCalling) {
      return [];
    }

    return phoneInfo?.orders ?? [];
  }

  /// Нативный канал
  static const EventChannel _eventChannel =
      EventChannel('rempc_incoming_events');

  /// Стрим данных нативного канала
  static Stream<CallEvent?> get onEvent =>
      _eventChannel.receiveBroadcastStream().map(_receiveEvent);

  /// Преобразует стрим [dynamic] в стрим данных [CallEvent]
  static CallEvent _receiveEvent(dynamic data) {
    if (data is Map) {
      return CallEvent(data['event'], Map<String, dynamic>.from(data['body']));
    }
    return CallEvent.empty;
  }

  Future<void> _fetchCallStatus() async {
    final result = await platform.invokeMethod('getSipCallData');
    await updateState(result, navigate: false);
  }

  Future<void> updateState(Map<String, dynamic> body,
      {bool navigate = true}) async {
    callState = body['state'] ?? 0;
    if (_lastRemoteUrl != body['remoteUrl'] && body['remoteUrl'] != null) {
      _lastRemoteUrl = body['remoteUrl'];
      final phoneInfoRequest = await DeprecatedRepository()
          .phoneInfo(getPhoneNumber, _lastRemoteUrl, body['callId'] ?? '');
      phoneInfo = phoneInfoRequest;
    }
    _lastCallId = body['callId'] ?? '';
    if (callState <= PJSIP_INV_STATE_CONFIRMED &&
        callState >= PJSIP_INV_STATE_CALLING &&
        callState != PJSIP_INV_STATE_INCOMING) {
      _isActiveCall = true;
      if (!isActiveCallScreen && navigate) {
        isActiveCallScreen = true;
        unawaited(navigator.pushNamed(CallScreen.routeName));
      }
    }
    if (PJSIP_INV_STATE_DISCONNECTED == callState) {
      _isActiveCall = false;
      isActiveCallScreen = false;
      isOutgoing = false;
    }
    notifyListeners();
  }

  /// Позвонить по SIP телефонии
  Future<void> makeCall(String phone, {bool isManualCalling = false}) async {
    if (isActiveCall) {
      return;
    }
    if (phone == '') {
      return;
    }
    if (callState != PJSIP_INV_STATE_DISCONNECTED &&
        callState != 0 &&
        _lastPhoneNumber == phone) {
      return;
    }

    _lastPhoneNumber = phone;
    _isManualCalling = isManualCalling;
    const platform = MethodChannel('helperService');
    await platform
        .invokeMethod('makeCall', {'url': 'sip:$phone@${_settings!.server}'});
    await Future.delayed(const Duration(seconds: 5));
    isOutgoing = true;
  }

  /// Получает SIP данные авторизации для пользователя
  /// и сохраняет их локально
  Future<void> setSettings() async {
    final json = await DeprecatedRepository().getSipCredential();
    if (json['success'].asBool() != true) {
      return;
    }

    final microphoneVolume =
        json['microphone_volume'].asDouble(defaultValue: 4.5);

    final speakerVolume = json['speaker_volume'].asDouble(defaultValue: 4.5);

    _settings = SipSettings(json['login'].asString(),
        json['password'].asString(), json['server'].asString(),
        microphoneVolume: microphoneVolume,
        speakerVolume: speakerVolume,
        isSuspended: json['is_suspended'].asBool());

    if (isActive && _settings!.isSuspended) {
      await _stopSipClient();
    }
    Future.delayed(const Duration(seconds: 3), _registerSipClient);
  }

  /// Останавливает SIP клиент
  Future<void> _stopSipClient() async {
    await platform.invokeMethod('stopSipClient');
  }

  /// Запускает SIP клиент
  Future<void> _registerSipClient() async {
    if (_settings!.isSuspended) {
      return;
    }
    await platform.invokeMethod('runSipClient', {
      'login': _settings!.login,
      'password': _settings!.password,
      'host': _settings!.server,
      'microphone_volume': _settings!.microphoneVolume,
      'speaker_volume': _settings!.speakerVolume,
    });
    notifyListeners();
  }

  /// Задает параметры громкости и чувствительности
  /// для SIP клиента
  Future<void> updateVolumeSettings() async {
    await platform.invokeMethod('updateSipVolume', {
      'microphone_volume': _settings!.microphoneVolume,
      'speaker_volume': _settings!.speakerVolume,
    });
  }

  /// Забирает текущий рингтон
  Future<String> getSipRingtone() async {
    try {
      final result = await platform.invokeMethod('getCurrentSipRingtone');
      return result;
    } catch (e) {
      return '';
    }
  }

  /// Устанавливает текущий рингтон
  Future<void> setupSipRingtone(String id) async {
    await platform.invokeMethod('setupSipRingtone', id);
  }

  /// Dоспроизведение рингтона
  void playRingtone() {
    platform.invokeMethod('playSipSound');
  }

  /// Останавливает воспроизведение рингтона
  Future<void> stopSound() async {
    try {
      await platform.invokeMethod('stopSipSound');
    } catch (_) {}
  }

  /// Забирает рингтоны CallKit на страницу настроек
  Future<List> getSounds() async {
    try {
      final result = await platform.invokeMethod('getSipRingtones');
      return result as List;
    } catch (e) {
      return [];
    }
  }

  /// Воспроизводит аудио файл
  Future<void> playSound(String sound) async {
    try {
      await platform.invokeMethod('playNotificationSound', {'sound': sound});
    } catch (_) {}
  }

  /// Старый метод присвоения мелодии к уведомлению
  /// не используется
  Future<void> setNotificationSound(Map<String, String?> sounds) async {
    try {
      await platform.invokeMethod('setNotificationSound', {'sounds': sounds});
    } catch (_) {}
  }
}
