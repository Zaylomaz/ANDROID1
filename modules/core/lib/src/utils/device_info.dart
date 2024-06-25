import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

/// Модель информации о девайсе
/// Получает данные с нативной стороны
/// и плагина [DeviceInfoPlugin]
@immutable
class AppDeviceInfo {
  const AppDeviceInfo._({
    required this.deviceId,
    required this.phoneNumbers,
    required this.androidData,
  });

  final String deviceId;
  final List<String> phoneNumbers;
  final AndroidDeviceInfo androidData;

  static const MethodChannel platform = MethodChannel('helperService');

  /// По сути фабрика, но асинхронная
  static Future<AppDeviceInfo> get() async {
    final androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    final deviceId = androidDeviceInfo.id;
    final phoneNumbers =
        (await platform.invokeMethod('getCurrentPhoneNumber') as Iterable)
            .toList();
    return AppDeviceInfo._(
      deviceId: deviceId,
      androidData: androidDeviceInfo,
      phoneNumbers: phoneNumbers
          .whereType<String>()
          .where((p) => p.isNotEmpty == true)
          .toList(),
    );
  }

  /// Подготовка данных для отправки на сервер
  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'phoneNumbers[]': phoneNumbers,
        'model': androidData.model,
        'manufacturer': androidData.manufacturer,
        'display': androidData.display,
        'fingerprint': androidData.fingerprint,
        'androidVersion': androidData.version.release,
        'androidSDKVersion': androidData.version.sdkInt,
      };
}

/// Отдает [androidInfo.ID] по сути айди девайса
Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidDeviceInfo = await deviceInfo.androidInfo;

  final deviceId = androidDeviceInfo.id;

  return deviceId;
}

/// Отдает конкретную версию API Android
/// 33 == Android 13
/// 32 == Android 12
/// 31 == Android 11
/// More info at https://developer.android.com/tools/releases/platforms
Future<int> getAndroidSDK() async {
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  return deviceInfo.version.sdkInt;
}
