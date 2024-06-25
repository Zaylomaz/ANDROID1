import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/channels/components/channels_list.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/screens/old_screen_abstract.dart';

class ChannelsScreen extends OldScreenAbstract {
  const ChannelsScreen({super.key});

  static const String routeName = '/channels';

  @override
  final String title = 'Каналы';

  @override
  Widget buildBody() => const ChannelsList();
}

class ChannelsPageRouter extends OldPageRouterAbstract {
  const ChannelsPageRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => ChannelsScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.chatNavigatorKey];
}
