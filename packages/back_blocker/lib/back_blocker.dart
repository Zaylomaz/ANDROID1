import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class BackBlocker {
  factory BackBlocker() => _instance;
  const BackBlocker._();
  static const _instance = BackBlocker._();

  static const MethodChannel _channel = MethodChannel(_channelName);

  static const _channelName = 'back_blocker';

  static const _enableBackButtonMethodName = '$_channelName.enableBackButton';
  static const _disableBackButtonMethodName = '$_channelName.disableBackButton';

  Future<void> enableBackButton() async {
    if (!Platform.isAndroid) {
      return;
    }

    await BackBlocker._channel.invokeMethod(
      BackBlocker._enableBackButtonMethodName,
    );
  }

  Future<void> disableBackButton() async {
    if (!Platform.isAndroid) {
      return;
    }

    await BackBlocker._channel.invokeMethod(
      BackBlocker._disableBackButtonMethodName,
    );
  }
}
