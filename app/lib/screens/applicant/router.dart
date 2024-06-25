import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/applicant/applicant_screen.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';

class ApplicantListRouter extends OldPageRouterAbstract {
  const ApplicantListRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => ApplicantListScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.applicantNavigatorKey];
}
