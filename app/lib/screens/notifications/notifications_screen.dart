import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/notifications/components/notifications_list.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return NotificationList();
  }
}

class NotificationsScreenRouter extends OldPageRouterAbstract {
  const NotificationsScreenRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => NotificationsScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.notificationsNavigationKey];
}
