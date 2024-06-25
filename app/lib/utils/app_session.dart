import 'dart:async';

import 'package:core/core.dart';
import 'package:rempc/model/user_model.dart';
import 'package:repository/repository.dart';

/// Наследуемый виджет
/// Передает в [BuildContext] состояние сессии и доп параметры
abstract class AppSessionController {
  /// СТРИМ -> Приложение активно или нет
  ValueStream<bool> get isActive;

  /// СТРИМ -> Юзер залогинился или нет
  ValueStream<bool> get isLoggedIn;

  /// СТРИМ -> Ативна ли служба GPS
  ValueStream<bool> get isGeoEnabled;

  /// Ожидает момента когда приложение активно
  Future<void> awaitActive();

  /// Ожидает момента когда юзер авторизировался
  Future<void> awaitAuthorized();

  /// Обновляет геопозицию пользователя
  Future<void> checkGPSService();
}

class AppSession extends StatefulWidget {
  const AppSession({
    required this.child,
    required this.navigatorKey,
    super.key,
  });

  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  AppSessionState createState() => AppSessionState();

  static AppSessionController of(BuildContext context) =>
      context.findAncestorStateOfType<AppSessionState>()!;
}

class AppSessionState extends State<AppSession>
    with WidgetsBindingObserver
    implements AppSessionController {
  final _isActive = BehaviorSubject<bool>.seeded(false);
  final _isLoggedIn = BehaviorSubject<bool>.seeded(false);
  final _isGeoEnabled = BehaviorSubject<bool>.seeded(true);

  @override
  ValueStream<bool> get isActive => _isActive.stream;

  @override
  Future<bool> awaitActive() => isActive.firstWhere((value) => value == true);

  @override
  ValueStream<bool> get isLoggedIn => _isLoggedIn.stream;

  @override
  ValueStream<bool> get isGeoEnabled => _isGeoEnabled.stream;

  @override
  Future<bool> awaitAuthorized() =>
      isLoggedIn.firstWhere((value) => value == true);

  @override
  Future<void> checkGPSService() async {
    _isGeoEnabled.value = await isGPSEnabled();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _isActive.close();
    _isLoggedIn.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _isActive.value = true;
      if (_isLoggedIn.value == true) {
        context.read<HomeData>().permissions =
            await AuthRepository().getUserPermissions();
      }
      await checkGPSService();
    } else if (state == AppLifecycleState.paused) {
      _isActive.value = false;
    }
  }
}
