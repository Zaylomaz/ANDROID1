import 'dart:async';
import 'dart:io';

import 'package:api/api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:uikit/uikit.dart';

/// Проверит наличие интернета по пингу [google.com]
/// Если интернета нет - вернет [NoInternetException]
Future<void> checkInternet() async {
  try {
    final url = Uri.parse(ApiBuilder().dio.options.baseUrl);
    final result = await InternetAddress.lookup(url.host);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      debugPrint('connected');
    }
  } on SocketException catch (e) {
    if (e.osError?.errorCode == 7) {
      throw BadHostException(e.osError!.message);
    }
    throw NoInternetException();
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionError) {
      throw BadHostException((e.error as SocketException).message);
    }
  }
}

/// Обертка для [AppConnectivityNotifier]
class AppConnectivity extends StatefulWidget {
  const AppConnectivity({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  State<AppConnectivity> createState() => _AppConnectivityState();
}

class _AppConnectivityState extends State<AppConnectivity> {
  final _instance = Connectivity();

  /// Надстройка над [Connectivity.onConnectivityChanged]
  /// для того чтоб провибрировать телефон при изменении сети
  final _onConnectivityChangeCtrl = BehaviorSubject<ConnectivityResult>();

  /// Стрим подключения
  /// При изменении типа подключения будет вызван event
  late StreamSubscription<ConnectivityResult> _stream;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    // получаем состоянии сети
    final connectivityResult = await _instance.checkConnectivity();
    // отправляем слушателю
    _onConnectivityChangeCtrl.add(connectivityResult);
    // подписываемся на стрим из [Connectivity]
    _stream = _instance.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        HapticFeedback.mediumImpact();
      }
      // отправляем слушателю
      _onConnectivityChangeCtrl.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppConnectivityNotifier._(
      connectivityState: _onConnectivityChangeCtrl.stream,
      instance: _instance,
      child: widget.child,
    );
  }
}

class AppConnectivityNotifier extends InheritedWidget {
  const AppConnectivityNotifier._({
    required this.connectivityState,
    required this.instance,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  final Stream<ConnectivityResult> connectivityState;
  final Connectivity instance;

  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await instance.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> checkInternet() async {
    if (!(await isNetworkAvailable())) {
      throw NoInternetException();
    }
  }

  /// показывает [SnackBar] при изменеии подключения
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      showSnackBar(
    BuildContext context,
    ConnectivityResult result,
  ) {
    if (result == ConnectivityResult.none) {
      showMessage(
        context,
        message: result.title,
        type: result.type,
        prefixIcon: Icon(
          result.icon,
          color: AppColors.white,
        ),
      );
    }
    return null;
  }

  @override
  bool updateShouldNotify(covariant AppConnectivityNotifier oldWidget) => true;

  static AppConnectivityNotifier? maybeOf(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<AppConnectivityNotifier>()
        ?.widget as AppConnectivityNotifier?;
  }
}

/// Расширение для enum [ConnectivityResult]
extension ConnectivityResultExt on ConnectivityResult {
  /// Название подключения
  String get title {
    switch (this) {
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.wifi:
        return 'Wifi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.mobile:
        return '2G/3G/LTE';
      case ConnectivityResult.none:
        return 'No Internet';
      case ConnectivityResult.vpn:
        return 'VPN';
      default:
        throw ArgumentError('ConnectivityResult type unsupported');
    }
  }

  /// Иконка
  IconData get icon {
    switch (this) {
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.ethernet:
        return Icons.settings_ethernet;
      case ConnectivityResult.mobile:
        return Icons.four_g_mobiledata;
      case ConnectivityResult.none:
        return Icons.signal_cellular_connected_no_internet_0_bar;
      case ConnectivityResult.vpn:
        return Icons.vpn_lock;
      default:
        throw ArgumentError('ConnectivityResult type unsupported');
    }
  }

  /// Декорация для [SnackBar]
  AppMessageType get type {
    switch (this) {
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
        return AppMessageType.success;
      case ConnectivityResult.none:
        return AppMessageType.error;
      case ConnectivityResult.vpn:
        return AppMessageType.info;
      default:
        throw ArgumentError('ConnectivityResult type unsupported');
    }
  }
}
