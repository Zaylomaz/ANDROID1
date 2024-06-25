import 'dart:async';

import 'package:api/api.dart';
import 'package:audio_player/audio_player.dart';
import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:preference/preference.dart';
import 'package:rempc/config/provider_manager.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/firebase_options.dart';
import 'package:rempc/screens/developer/developer_screen.dart';
import 'package:rempc/ui/screens/splash_page.dart';
import 'package:rempc/utils/app_session.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uikit/uikit.dart';

final _errorStreamCtrl = StreamController<UncaughtErrorDetails>();

//Main entry point of app
void runMain(Flavor flavor, {bool isPlayMarket = false}) {
  runZonedGuarded(
    () => _runApp(flavor, isPlayMarket: isPlayMarket),
    _handleZoneError,
  );
}

Future<void> _runApp(Flavor flavor, {required bool isPlayMarket}) async {
  /// Запуск необходимых служб
  await prepareMainApp(
    flavor,
    isPlayMarket: isPlayMarket,
  );

  /// Запуск приложения
  runApp(
    const App(),
  );
}

Future<void> prepareMainApp(Flavor flavor, {required bool isPlayMarket}) async {
  Provider.debugCheckInvalidValueType = null;
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  timeago.setLocaleMessages('ru_short', timeago.RuShortMessages());

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await AppDictionary.ensureInitialized();
  await Preference.init();
  Environment.init(
    flavor: flavor,
    isPlayMarket: isPlayMarket,
    config: AppConfig.fromFlavor(flavor),
  );
  ApiBuilder().init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = flavor == Flavor.prod
      ? FirebaseCrashlytics.instance.recordFlutterError
      : (error) {
          debugPrint(error.toString());
        };
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

/// Покажет ошибку при запуске
void _handleZoneError(Object error, StackTrace trace) {
  _errorStreamCtrl.add(UncaughtErrorDetails(error, trace));
}

@immutable
class UncaughtErrorDetails {
  const UncaughtErrorDetails(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    ApiBuilder()
        .initAlice(AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!);
    ApiBuilder().addInterceptor(
        ErrorInterceptor(AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      builder: (context, child) => Loader(
        navigatorKey: AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!,
        child: AppSession(
          navigatorKey: AppRouter.navigatorKeys[AppRouter.mainNavigatorKey],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.data,
            onGenerateRoute: AppRouter().routeBuilder,
            navigatorKey: AppRouter.navigatorKeys[AppRouter.mainNavigatorKey],
            initialRoute: SplashScreen.routeName,
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: ShakeQaScreenOpener(
                navigatorKey:
                    AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!,
                screenPath: DeveloperScreen.routeName,
                child: AppConnectivity(child: child!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
