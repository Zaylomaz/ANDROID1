import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';

part 'remote_config.g.dart';

/*
* Глобальный провайдер RemoteConfig от Firebase
* Переменные конфига хранятся тут
* https://console.firebase.google.com/u/0/project/rempc-crm/config
*/

StreamSubscription<RemoteConfigUpdate>? configListener;

class AppRemoteConfig extends AppRemoteConfigStore with _$AppRemoteConfig {
  AppRemoteConfig() : super();

  static AppRemoteConfigStore of(BuildContext context) =>
      Provider.of<AppRemoteConfig>(context, listen: false);
}

abstract class AppRemoteConfigStore with Store {
  AppRemoteConfigStore() {
    /// Инициализация конфига
    try {
      remoteConfig.ensureInitialized().then((value) => init());
    } catch (_) {}
  }

  final remoteConfig = FirebaseRemoteConfig.instance;
  final isInitializedSub = BehaviorSubject<bool>.seeded(false);
  final onChangeSub = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isInitialized => isInitializedSub.stream;
  Stream<bool> get onChange => onChangeSub.stream;

  Future<void> init() async {
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.setDefaults({
        'minimumVersion': '1.0.43',
        'buildUrl': '',
      });
      await remoteConfig.fetchAndActivate();
      runInAction(() {
        minimumVersion = remoteConfig.getString('minimumVersion');
        buildUrl = Uri.tryParse(remoteConfig.getString('buildUrl'));
      });
      if (configListener != null) {
        await configListener?.cancel();
        configListener = null;
      }
      configListener = remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();
        runInAction(() {
          minimumVersion = remoteConfig.getString('minimumVersion');
          buildUrl = Uri.tryParse(remoteConfig.getString('buildUrl'));
        });
        onChangeSub.add(true);
      });
      isInitializedSub.add(true);
    } catch (_) {}
  }

  @observable
  String _minimumVersion = '';
  @computed
  String get minimumVersion => _minimumVersion;
  @protected
  set minimumVersion(String value) => _minimumVersion = value;

  @observable
  Uri? _buildUrl;
  @computed
  Uri? get buildUrl => _buildUrl;
  @protected
  set buildUrl(Uri? value) => _buildUrl = value;

  @action
  void dispose() {
    configListener?.cancel();
  }
}

mixin AppConfigTools {
  static const _channel = MethodChannel('helperService');

  /// Получает текущую версию билда в виде Х.Х.Х
  static Future<String?> _getPackageInfo() async {
    try {
      return await _channel.invokeMethod('getPackageVersion');
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  /// Метод решает нужено ли обновить приложение
  /// на основе текущей и минимальной версией приложения
  static Future<bool> needUpdate({
    /// Получаем из RemoteConfig
    required String minimumVersion,
    String? currentPackageVersion,
  }) async {
    assert(minimumVersion.split('.').length == 3);
    final currentVersion =
        currentPackageVersion ?? await _getPackageInfo() ?? '';
    final versionRegExp = RegExp('[0-9.0-9.0-9]');
    if (currentVersion.isEmpty || minimumVersion.isEmpty) {
      unawaited(FirebaseCrashlytics.instance.recordError(
        'VERSION_IS_EMPTY => $currentVersion / $minimumVersion',
        null,
      ));
      return false;
    }
    if (!versionRegExp.hasMatch(minimumVersion)) {
      unawaited(FirebaseCrashlytics.instance.recordError(
        'WRONG_MINIMUM_VERSION => $minimumVersion',
        null,
      ));
      return false;
    }
    final packageVersion = currentVersion
        .replaceAll(RegExp('[a-zA-Z-]'), '')
        .split('.')
        .map(int.parse)
        .toList();
    final minimalVersion = minimumVersion.split('.').map(int.parse).toList();
    for (var i = 0; i < minimalVersion.length; i++) {
      if (packageVersion[i] < minimalVersion[i]) {
        return true;
      } else if (packageVersion[i] > minimalVersion[i]) {
        return false;
      }
    }
    return false;
  }
}
