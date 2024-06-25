import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/faq/faq_list_screen.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';

class FAQListScreenRouter extends OldPageRouterAbstract {
  const FAQListScreenRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => FAQListScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.faqNavigatorKey];
}
