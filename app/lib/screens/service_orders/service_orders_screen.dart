import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/screens/service_orders/components/filter/service_order_filter.dart';
import 'package:rempc/screens/service_orders/components/list/service_order_list.dart';
import 'package:rempc/ui/components/tab_view/tab_selector.dart';
import 'package:rempc/ui/components/tab_view/tab_view_model.dart';

class ServiceOrderScreen extends StatelessWidget implements AppTabViewScreen {
  ServiceOrderScreen({super.key});

  static const String routeName = '/service_orders';

  @override
  String get route => routeName;
  @override
  String get filterRoute => ServiceOrderFilterScreen.routeName;
  @override
  String get detailsRoute =>
      throw UnimplementedError('ServiceOrderScreen has no details');
  @override
  final tickerKey = GlobalKey<TabContainerState>();

  @override
  Widget build(BuildContext context) => TabContainer(
        key: tickerKey,
        child: Builder(builder: (context) {
          return ServiceOrderList(tickerKey.currentState!.vsync);
        }),
      );
}

class ServiceOrderRouter extends OldPageRouterAbstract {
  const ServiceOrderRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => ServiceOrderScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.serviceNavigatorKey];
}
