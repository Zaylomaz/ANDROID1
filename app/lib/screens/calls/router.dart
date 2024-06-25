import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/calls/calls_screen.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';

class CallsScreenRouter extends OldPageRouterAbstract {
  const CallsScreenRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => AppCallsScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.callsNavigatorKey];
}
