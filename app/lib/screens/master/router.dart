import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/master/masters_screen.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';

class MastersPageRouter extends OldPageRouterAbstract {
  const MastersPageRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => MasterScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.mastersNavigatorKey];
}
