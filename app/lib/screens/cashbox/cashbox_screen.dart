import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/cashbox/components/cashbox_list.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/screens/old_screen_abstract.dart';

class CashBoxScreen extends OldScreenAbstract {
  const CashBoxScreen({super.key});

  static const String routeName = '/cashbox';

  @override
  final String title = 'Касса';

  @override
  StatefulWidget buildBody() => const CashBoxListWidget();
}

class CashBoxScreenRouter extends OldPageRouterAbstract {
  const CashBoxScreenRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => CashBoxScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.cashboxNavigatorKey];
}
