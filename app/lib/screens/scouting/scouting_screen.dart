import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/screens/old_screen_abstract.dart';

/*
* Экран разведки с встроенным навигатором
* Вся документация по разведке в ./modules/app_camera
*/

class ScoutingScreen extends OldScreenAbstract {
  const ScoutingScreen({super.key});

  static const String routeName = '/scouting';

  @override
  final String title = 'Отчеты рекламы';

  @override
  Widget buildBody() => const ScoutingBody();
}

class ScoutingPageRouter extends OldPageRouterAbstract {
  const ScoutingPageRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => ScoutingScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.scoutingNavigatorKey];
}
