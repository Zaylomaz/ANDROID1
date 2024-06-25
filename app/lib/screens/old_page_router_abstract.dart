import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';

abstract class OldPageRouterAbstract extends StatelessWidget {
  const OldPageRouterAbstract(this.screen, {super.key});

  final UserScreen screen;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: getNavigatorKey(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  String getInitialRoute();

  GlobalKey<NavigatorState>? getNavigatorKey();

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    var settings0 = settings;
    if (settings0.name == '/' || settings0.name == '') {
      settings0 = RouteSettings(
        name: getInitialRoute(),
        arguments: settings.arguments,
      );
    }
    return AppRouter().routeBuilder(
      settings0,
    );
  }
}
