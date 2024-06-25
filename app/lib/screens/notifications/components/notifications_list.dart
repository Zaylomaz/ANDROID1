import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/notifications/components/notifications_list_item.dart';
import 'package:rempc/screens/notifications/notifications_screen.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:rempc/ui/components/tab_view/tab_selector.dart';
import 'package:rempc/ui/components/tab_view/tab_view_model.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'notifications_list.g.dart';
part 'tabs.dart';

class _State extends _StateStore with _$_State {
  _State(super.homeData, super.vsync);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store, TabViewStateMixin<NotificationTab> {
  _StateStore(this.homeData, TickerProvider vsync) {
    initTabs(vsync);
    try {
      notificationsSub?.cancel();
      notificationsSub = null;
    } finally {
      notificationsSub = HomeDataStore.pushNotificationStream.listen((event) {
        if (event != null) {
          for (final tab in tabs) {
            tab.refresh();
          }
        }
      });
    }
  }

  final HomeDataStore homeData;

  StreamSubscription? notificationsSub;

  @observable
  TabController? _tabController;

  @override
  @computed
  TabController? get tabController => _tabController;

  @override
  @protected
  set tabController(TabController? value) => _tabController = value;

  @observable
  List<NotificationTab> _tabs = [];

  @override
  @computed
  List<NotificationTab> get tabs => _tabs;

  @override
  @protected
  set tabs(List<NotificationTab> value) => _tabs = value;

  @override
  JsonListPreference<NotificationTab> get savedTabs => notificationTabs;

  @action
  Future<void> reload(BuildContext context) async {
    try {
      tabs[stackIndex(context)].pageController.refresh();
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  @override
  void dispose() {
    homeData.updateUserInfo();
    notificationsSub?.cancel();
    super.dispose();
  }
}

class NotificationList extends StatelessWidget implements AppTabViewScreen {
  NotificationList({super.key});

  @override
  String get detailsRoute => throw UnimplementedError();

  @override
  String get filterRoute => throw UnimplementedError();

  @override
  String get route => NotificationsScreen.routeName;
  @override
  final tickerKey = GlobalKey<TabContainerState>();

  @override
  Widget build(BuildContext context) {
    return TabContainer(
      key: tickerKey,
      child: Provider<_State>(
        create: (ctx) => _State(
          HomeData.of(context),
          tickerKey.currentState!.vsync,
        ),
        builder: (ctx, child) => const _Content(),
        dispose: (ctx, state) {
          state.dispose();
        },
      ),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Уведомления'),
      ),
      drawer: const AppBarDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabSelector(
            controller: _State.of(context).tabController,
            tabs: _State.of(context).tabs,
            tabsStream: _State.of(context).tabsSub,
            fixedLength: true,
          ),
          Expanded(
            child: TabBarView(
              controller: _State.of(context).tabController,
              children: _State.of(context).tabs.map(_Tab.new).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.tab, {super.key});

  final NotificationTab tab;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      controller: tab.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Observer(builder: (context) {
                      return Text(
                        '${tab.name.value} (${tab.total.value})',
                        style: AppTextStyle.boldHeadLine.style(context),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () => _State.of(context).reload(context),
        child: PagedListView<int, NotificationBase>.separated(
          pagingController: tab.pageController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 8),
          builderDelegate: PagedChildBuilderDelegate<NotificationBase>(
            itemBuilder: (context, item, index) => NotificationsListItem(
              item,
              key: ValueKey<String>('${item.id}_$index'),
            ),
            noItemsFoundIndicatorBuilder: noItemsInListBuilder(context),
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ),
    );
  }
}
