import 'dart:async';

import 'package:api/api.dart';
import 'package:back_blocker/back_blocker.dart';
import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/services.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/provider/view_state.dart';
import 'package:rempc/provider/view_state_widget.dart';
import 'package:rempc/screens/sign_in/sign_in_screen.dart';
import 'package:rempc/ui/components/error_view.dart';
import 'package:rempc/ui/screens/tab/main_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'splash_page.g.dart';

final isPermissionDialogShown = BoolPreference(
  key: const PreferenceKey(
      module: 'app', component: 'splash', name: 'permission_dialog'),
  defaultValue: false,
);

/// Объект записи в лог загрузки
class LoadingLog {
  const LoadingLog._(this.event, this.timestamp);
  factory LoadingLog.event(String event) => LoadingLog._(event, DateTime.now());
  factory LoadingLog.fromJson(dynamic data) {
    final json = JsonReader(data);
    return LoadingLog._(
      json['event'].asString(),
      json['timestamp'].asDateTime(),
    );
  }
  Map<String, dynamic> toJson() => {
        'event': event,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  final String event;
  final DateTime timestamp;
}

final splashLoadingLog = JsonListPreference<LoadingLog>(
  key: const PreferenceKey(
    module: 'app',
    component: 'splash',
    name: 'loading_log',
  ),
  defaultValue: <LoadingLog>[],
  itemEncoder: (log) => log.toJson(),
  itemDecoder: LoadingLog.fromJson,
);

class _State extends _StateStore with _$_State {
  _State(
    super.context,
    super.tickerProvider,
  );

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this._buildContext, this._vsync) {
    splashLoadingLog.clear();
    countdownController = AnimationController(
      vsync: _vsync,
      duration: animationDuration,
    );
    mainAnimation =
        countdownController.drive(CurveTween(curve: Curves.easeInOutQuad));
    loadingAnimation = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: _vsync,
    );
    backgroundAnimation =
        ColorTween(begin: AppColors.violet, end: AppColors.black)
            .animate(mainAnimation);
    iconAnimation = ColorTween(begin: AppColors.white, end: AppColors.violet)
        .animate(mainAnimation);
    countdownController.forward().then((value) => loadingAnimation.repeat());
    internetSub = AppConnectivityNotifier.maybeOf(_buildContext)
        ?.connectivityState
        .listen((event) {
      AppConnectivityNotifier.showSnackBar(_buildContext, event);
    });
    loadingProgressSub = loadingProgress.stream.listen((event) {
      loadingLog.add(event);
      splashLoadingLog.value = loadingLog;
    });
    Future.delayed(animationDuration, init);
  }

  final BuildContext _buildContext;
  final TickerProvider _vsync;
  static const animationDuration = Duration(milliseconds: 1500);
  late AnimationController countdownController;
  late Animation<double> mainAnimation;
  late AnimationController loadingAnimation;
  late Animation<Color?> backgroundAnimation;
  late Animation<Color?> iconAnimation;
  late StreamSubscription<ConnectivityResult>? internetSub;
  late StreamSubscription<LoadingLog>? loadingProgressSub;
  final loadingProgress =
      BehaviorSubject<LoadingLog>.seeded(LoadingLog.event('Запуск'));
  final platform = const MethodChannel('helperService');

  final loadingLog = <LoadingLog>[];

  @observable
  bool animationsIsInitialized = false;

  @observable
  String errorMessage = '';
  @observable
  bool firstLoad = true;
  @observable
  bool isLogged = false;

  bool get hasError => errorMessage.isNotEmpty;

  @observable
  bool unknownError = false;
  @observable
  bool isIgnoringBatteryOptimizations = false;
  @observable
  bool poorPermissions = false;

  @action
  Future<void> init() async {
    await BackBlocker().disableBackButton();
    try {
      await AppDictionary().updateRegistrationDictionary();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        Future.delayed(const Duration(seconds: 1), _zipInitialLoad);
        return;
      }
    }
    await _zipInitialLoad();
  }

  Future<void> remoteConfigInit() async {
    loadingProgress.add(LoadingLog.event('Получение конфигурации'));
    await AppRemoteConfig.of(_buildContext)
        .isInitialized
        .firstWhere((e) => e == true);
  }

  @action
  Future<void> _zipInitialLoad() async {
    loadingProgress.add(LoadingLog.event('Проверка соединения'));
    final hasInternet = await AppConnectivityNotifier.maybeOf(_buildContext)
        ?.isNetworkAvailable();
    await remoteConfigInit();
    if (hasInternet == true) {
      try {
        final test = SpeedTest().runTest();
        unawaited(
          test.duration().then(
            (duration) {
              if (duration.inSeconds > 5) {
                unawaited(
                  showMessage(
                    _buildContext,
                    message: 'Медленный интернет',
                    prefixIcon: AppIcons.alert.iconColored(
                      color: AppSplitColor.red(),
                    ),
                  ),
                );
              }
            },
          ),
        );
      } catch (e, s) {
        unawaited(FirebaseCrashlytics.instance.recordError(e, s));
      }
      loadingProgress.add(LoadingLog.event('Проверка обновлений'));
      final needUpdate = await AppConfigTools.needUpdate(
        minimumVersion: AppRemoteConfig.of(_buildContext).minimumVersion,
      );
      if (needUpdate) {
        await showUpdateAppDialog(_buildContext);
      }

      loadingProgress.add(LoadingLog.event('Проверка разрешений'));
      final permissions = await _requestPermissions();
      if (!permissions) {
        return;
      }

      if (isIgnoringBatteryOptimizations != true) {
        loadingProgress.add(LoadingLog.event('Запрос на оптимизацию'));
        await platform.invokeMethod('requestAllowUseBattery');
        return;
      }

      try {
        loadingProgress
            .add(LoadingLog.event('Получение информации о пользователе'));
        await _initHomeDataProvider();
        await _checkUserStatus();
      } finally {
        if (permissions && !hasError) {
          if (isLogged) {
            _goToHomePage(_buildContext);
          } else {
            _goToLoginPage(_buildContext);
          }
        } else {
          if (errorMessage.isEmpty) {
            errorMessage = 'Unknown exception';
          }
        }
      }
    } else {
      errorMessage = 'Нет соединения с интернет';
    }
  }

  @action
  Future<void> retry() async {
    if (poorPermissions) {
      await AppSettings.openAppSettings();
    }
    errorMessage = '';
    unknownError = false;
    isIgnoringBatteryOptimizations = false;
    countdownController.reset();
    await countdownController.forward();
    unawaited(_zipInitialLoad());
  }

  @action
  Future<bool> _requestPermissions() async {
    var status = true;
    if (!isPermissionDialogShown.value) {
      loadingProgress.add(LoadingLog.event('Запрос разрешений'));
      await _PermissionDialog.show(_buildContext);
    }
    loadingProgress.add(LoadingLog.event('Проверка разрешений'));
    final permissions = [
      Permission.location,
      Permission.microphone,
      Permission.camera,
      Permission.phone,
      Permission.contacts,
    ];
    final needRequest = <Permission>[];

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        needRequest.add(permission);
      }
    }

    if (needRequest.isNotEmpty) {
      final result = await needRequest.request();

      final statusResult = await Future.wait<PermissionStatus>([
        for (final key in result.keys) key.status,
      ]);

      for (final key in result.keys) {
        final index = result.keys.toList().indexOf(key);
        final permission = result[key] as PermissionStatus;
        final permissionStatus =
            statusResult[index] == PermissionStatus.granted;
        if (!permission.isGranted || permissionStatus == false) {
          final request = await key.request();
          final requestStatus = await key.status;
          if (!request.isGranted || requestStatus != PermissionStatus.granted) {
            poorPermissions = true;
            if (status == true) {
              status = false;
            }
            if (!errorMessage.contains(
                '''Для корректной работы приложения предоставьте все разрешения!''')) {
              errorMessage +=
                  '''Для корректной работы приложения предоставьте все разрешения!\n''';
            }
            switch (key.toString()) {
              case 'Permission.location':
                errorMessage += '\nГеопозиция';
                break;
              case 'Permission.microphone':
                errorMessage += '\nМикрофон';
                break;
              case 'Permission.camera':
                errorMessage += '\nКамера';
                break;
              case 'Permission.phone':
                errorMessage += '\nЗвонки';
                break;
              case 'Permission.contacts':
                errorMessage += '\nКонтакты';
                break;
              case 'Permission.notification':
                errorMessage += '\nПоказ уведомлений';
                break;
              case 'Permission.storage':
                errorMessage += '\nДоступ к памяти';
                break;
            }
          }
        }
      }
    }

    loadingProgress.add(LoadingLog.event('Проверка дополнителных разрешений'));
    await _requestNativePermissions();

    loadingProgress.add(LoadingLog.event('Проверка досупа оптимизации'));
    await _checkAdditionalPermissions();

    return status;
  }

  @action
  Future<void> _requestNativePermissions() async {
    loadingProgress.add(LoadingLog.event('Получение версии ПО'));
    final sdk = await getAndroidSDK();
    final permissions = [
      Permission.notification,
      Permission.mediaLibrary,
      if (sdk < 30) Permission.storage,
      if (sdk >= 30) Permission.photos,
      if (sdk >= 30) Permission.videos,
    ];
    final needRequest = <Permission>[];

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        needRequest.add(permission);
      }
    }

    if (needRequest.isNotEmpty) {
      loadingProgress.add(LoadingLog.event('Запрос разрешений android'));
      await platform.invokeMethod('requestNativePermissions');
    }
  }

  @action
  Future<bool> _checkAdditionalPermissions() async {
    try {
      loadingProgress.add(LoadingLog.event('Статус GPS...'));
      final isGPSEnabled = await platform.invokeMethod('isGPSEnabled');
      loadingProgress
        ..add(LoadingLog.event(
            'Статус GPS ${isGPSEnabled ? 'влючен' : 'выключен'}'))
        ..add(LoadingLog.event('Оптимизация батареи...'));
      isIgnoringBatteryOptimizations =
          await platform.invokeMethod('isIgnoringBatteryOptimizations');
      loadingProgress.add(LoadingLog.event(
          'Оптимизация батареи ${isIgnoringBatteryOptimizations ? 'выключена' : 'включена'}'));
      if (!isGPSEnabled) {
        unknownError = true;
        errorMessage = 'Включите GPS в верхней панели устройства';
        return false;
      }
      if (!isIgnoringBatteryOptimizations) {
        errorMessage =
            '''Фоновая активность приложения ограничена на этом устройстве. Пожалуйста, установите опцию "без ограничений" в настройках приложения.''';
        return false;
      }

      return true;
    } catch (e, stack) {
      if (Environment<AppConfig>.instance().isProd) {
        await FirebaseCrashlytics.instance.recordError(e, stack,
            reason: '_checkAdditionalPermissions() return error');
      }
      errorMessage = stack.toString();
    }
    return false;
  }

  @action
  Future<bool> _checkUserStatus() async {
    try {
      await _warmUpDeviceId();
      await _checkLogin();
      await _checkPermissions();
      return true;
    } catch (_) {
      return false;
    }
  }

  @action
  Future _warmUpDeviceId() => getDeviceId();

  @action
  Future _checkPermissions({bool withInfo = true}) async {
    try {
      _buildContext.read<HomeData>().permissions = await AuthRepository()
          .getUserPermissions(withInfo: withInfo, unauthorizedRedirect: false);
    } catch (_) {
      if (withInfo) {
        await _checkPermissions(withInfo: false);
      }
    }
  }

  @action
  Future _initHomeDataProvider() async {
    await HomeData.of(_buildContext).init();
  }

  @action
  Future _checkLogin() async {
    final isLoggedIn = await DeprecatedRepository().isLoggedIn();
    isLogged = isLoggedIn;
  }

  void _goToHomePage(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainScreen.routeName,
      (r) => false,
    );
  }

  void _goToLoginPage(BuildContext context) {
    final currentRouteName = ModalRoute.of(AppRouter
            .navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!)
        ?.settings
        .name;
    if (currentRouteName != SignInScreen.routeName) {
      Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
    }
  }

  @action
  void dispose() {
    splashLoadingLog.value = loadingLog;
    internetSub?.cancel();
    loadingProgressSub?.cancel();
    countdownController
      ..stop()
      ..dispose();
    loadingAnimation
      ..stop()
      ..dispose();
    loadingProgress.close();
    BackBlocker().enableBackButton();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  static List<LoadingLog> getLog() => splashLoadingLog.value;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(
        context,
        this,
      ),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  Widget _getErrorView(BuildContext context) {
    return Center(
      child: ErrorView(
        onPressedRetry: () async {
          if (!_State.of(context).isIgnoringBatteryOptimizations) {
            const platform = MethodChannel('helperService');
            await platform.invokeMethod('requestAllowUseBattery');
          }
          unawaited(_State.of(context).retry());
        },
        buttonText: 'Повторить',
        errorText: _State.of(context).errorMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).unknownError) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: ViewStateErrorWidget(
            error: ViewStateError(
              ErrorType.defaultError,
              errorMessage: _State.of(context).errorMessage,
            ),
            onPressed: _State.of(context).retry,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _State.of(context).hasError
            ? _getErrorView(context)
            : const AnimatedCountdown(),
      ),
    );
  }
}

class AnimatedCountdown extends StatelessWidget {
  const AnimatedCountdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _State.of(context).backgroundAnimation,
            builder: (context, child) {
              return Container(
                color: _State.of(context).backgroundAnimation.value,
                child: Center(
                  child: SizedBox(
                    height: 120,
                    width: 100,
                    child: child,
                  ),
                ),
              );
            },
            child: AnimatedBuilder(
              animation: _State.of(context).iconAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      color: _State.of(context).iconAnimation.value,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedBuilder(
                        animation: _State.of(context).loadingAnimation,
                        builder: (context, _) {
                          if (_State.of(context).loadingAnimation.isAnimating) {
                            return LinearProgressIndicator(
                              value: _State.of(context).loadingAnimation.value,
                              color: AppColors.violet,
                              backgroundColor: AppColors.green,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: SafeArea(
            child: StreamBuilder<LoadingLog>(
              stream: _State.of(context).loadingProgress.stream,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data?.event}...',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.regularCaption.style(context),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionDialog extends StatefulWidget {
  const _PermissionDialog();

  static Future<void> show(BuildContext context) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _PermissionDialog(),
      );

  static Widget permission(
    BuildContext context, {
    required Widget icon,
    required String title,
    required String text,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.boldHeadLine.style(context),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Приложение запрашивает разрешение:',
                  style: AppTextStyle.boldSubHeadline.style(context),
                ),
                const TextSpan(text: '\n'),
                TextSpan(
                  text: text,
                  style: AppTextStyle.regularSubHeadline.style(context),
                ),
              ],
            ),
          )
        ],
      );

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  final _pageController = PageController();
  List<Widget> _permissions(BuildContext context) => [
        _PermissionDialog.permission(
          context,
          icon: AppIcons.location.widget(color: AppColors.green),
          title: 'Геолокация',
          text:
              'Для корректного отображения заказов и последующей работы с ними',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.shareLocation.widget(color: AppColors.green),
          title: 'Геолокация в фоновом режиме',
          text:
              '''Для оповещения клиента о том насколько быстро вы прибудете. Может быть использована когда приложение не активно или закрыто''',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.microphoneOn.widget(color: AppColors.green),
          title: 'Микрофон',
          text: 'Для записи звонков',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.phone.widget(color: AppColors.green),
          title: 'Телефон',
          text: 'Для работы встроенной телефонии',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.contacts.widget(color: AppColors.green),
          title: 'Контакты',
          text: 'Для работы встроенной телефонии',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.camera.widget(color: AppColors.green),
          title: 'Камера',
          text: 'Для создания отчетов',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.bellPush.widget(color: AppColors.green),
          title: 'Push-уведомления',
          text: '',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.storage.widget(color: AppColors.green),
          title: 'Хранилище файлов',
          text: 'Для хранения файлов используемых в приложении',
        ),
        _PermissionDialog.permission(
          context,
          icon: AppIcons.userSearch.widget(color: AppColors.green),
          title: 'Ваш номер телефона',
          text:
              '''Для идентификации пользователя.\nМы не передаем собранные данные третьим лицам и используем их только сцелью улучшения сервиса нашей компании''',
        ),
      ];
  int _currentPageIndex = 0;
  bool isLastPage(BuildContext context) =>
      _currentPageIndex == _permissions(context).length - 1;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: AppColors.green,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(
              minHeight: 64,
              maxHeight: 204,
            ),
            child: PageView(
              controller: _pageController,
              children: _permissions(context),
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
            ),
          ),
          PrimaryButton.greenInverse(
            onPressed: () {
              if (isLastPage(context)) {
                isPermissionDialogShown.value = true;
                Navigator.of(context).pop();
              } else {
                _pageController.jumpToPage(
                  _currentPageIndex + 1,
                );
              }
            },
            text: 'Разрешить',
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
