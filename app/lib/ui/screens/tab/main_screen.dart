import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/services.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/ai_chat/ai_chat_screen.dart';
import 'package:rempc/screens/applicant/router.dart';
import 'package:rempc/screens/calls/router.dart';
import 'package:rempc/screens/cashbox/cashbox_screen.dart';
import 'package:rempc/screens/cashbox_admin/cashbox_admin_screen.dart';
import 'package:rempc/screens/channels/channels_screen.dart';
import 'package:rempc/screens/faq/router.dart';
import 'package:rempc/screens/home/home_screen.dart';
import 'package:rempc/screens/master/router.dart';
import 'package:rempc/screens/notifications/notifications_screen.dart';
import 'package:rempc/screens/orders/order_screen.dart';
import 'package:rempc/screens/scouting/scouting_screen.dart';
import 'package:rempc/screens/service_orders/service_orders_screen.dart';
import 'package:rempc/ui/components/dialpad_view.dart';
import 'package:rempc/ui/screens/settings/settings_page.dart';
import 'package:rempc/ui/screens/tab/kanban_masters_page.dart';
import 'package:rempc/utils/app_session.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'main_screen.g.dart';

extension PageFromUserScreen on UserScreen {
  Widget page() {
    switch (this) {
      case UserScreen.notificationsScreen:
        return NotificationsScreenRouter(this);
      case UserScreen.orderScreen:
        return OrderPageRouter(this);
      case UserScreen.serviceOrderScreen:
        return ServiceOrderRouter(this);
      case UserScreen.cashboxAdminScreen:
        return CashBoxAdminScreenRouter(this);
      case UserScreen.cashboxScreen:
        return CashBoxScreenRouter(this);
      case UserScreen.kanbanScreen:
        return KanbanPageRouter(this);
      case UserScreen.chatScreen:
        return ChannelsPageRouter(this);
      case UserScreen.chatAiScreen:
        return const AiChatScreen();
      case UserScreen.scoutingScreen:
        return ScoutingPageRouter(this);
      case UserScreen.settingsScreen:
        return SettingsPageRouter(this);
      case UserScreen.dialPadScreen:
        return DialPadPageRouter(
          this,
          isFullScreen: true,
        );
      case UserScreen.mastersScreen:
        return MastersPageRouter(this);
      case UserScreen.missedCallsScreen:
        return CallsScreenRouter(this);
      case UserScreen.faq:
        return FAQListScreenRouter(this);
      case UserScreen.applicant:
        return ApplicantListRouter(this);
      case UserScreen.home:
        return HomeScreenRouter(this);
      case UserScreen.undefined:
        return const SizedBox.shrink();
    }
  }
}

class _State extends _StateStore with _$_State {
  _State(
    super.homeDataStore,
    super.sipModel,
    super.sessionController,
    super.connectivityNotifier,
    super.remoteConfigStore,
  );

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(
    this.homeDataStore,
    this.sipModel,
    this.sessionController,
    this.connectivityNotifier,
    this.remoteConfigStore,
  ) {
    try {
      withLoadingIndicator(() async {
        await AppDictionary().loadData();
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
    _gpsListener = sessionController.isGeoEnabled.listen((isEnabled) {
      runInAction(() {
        isGeoEnabled = isEnabled;
      });
    });
    sessionController.checkGPSService();
    _internetSub = connectivityNotifier?.connectivityState.listen((event) {
      AppConnectivityNotifier.showSnackBar(
        AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!,
        event,
      );
    });
    _configListener = remoteConfigStore.onChangeSub.listen((value) async {
      if (value &&
          await AppConfigTools.needUpdate(
            minimumVersion: remoteConfigStore.minimumVersion,
          )) {
        if (!isUpdateAppDialogShowing.value) {
          await showUpdateAppDialog(
            AppRouter
                .navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!,
          );
        }
      }
    });
    sipModel.addListener(_sipListener);
    _initHelperService();
  }

  final HomeDataStore homeDataStore;
  final SipModel sipModel;
  final AppSessionController sessionController;
  final AppConnectivityNotifier? connectivityNotifier;
  final AppRemoteConfigStore remoteConfigStore;
  final bottomNavigatorKey = GlobalKey(debugLabel: 'bottomNavigatorKey');
  late final PageController pageController =
      PageController(initialPage: homeDataStore.getInitialPage);
  late StreamSubscription<ConnectivityResult>? _internetSub;
  late StreamSubscription<bool> _configListener;
  late StreamSubscription<bool> _gpsListener;

  @observable
  bool _firstLaunch = true;

  @computed
  bool get firstLaunch => _firstLaunch;

  @protected
  set firstLaunch(bool value) => _firstLaunch = value;

  @observable
  bool _isGeoEnabled = true;

  @computed
  bool get isGeoEnabled => _isGeoEnabled;

  @protected
  set isGeoEnabled(bool value) => _isGeoEnabled = value;

  List<UserScreen> get pages {
    final pages = List<UserScreen>.from(homeDataStore.navigationItems)
      ..sort((a, b) => a.weight.compareTo(b.weight));
    return pages;
  }

  int? get getOrdersIndex {
    final pages = List<UserScreen>.from(homeDataStore.navigationItems)
      ..sort((a, b) => a.weight.compareTo(b.weight));
    return pages.indexOf(UserScreen.orderScreen);
  }

  int? get callsIndex {
    final pages = List<UserScreen>.from(homeDataStore.navigationItems)
      ..sort((a, b) => a.weight.compareTo(b.weight));
    return pages.indexOf(UserScreen.missedCallsScreen);
  }

  Future<void> _initHelperService() async {
    final token = ApiStorage().accessToken;
    const platform = MethodChannel('helperService');
    await platform.invokeMethod('startHelperService', {'userAuthToken': token});
    await sipModel.setSettings();
    await platform.invokeMethod('initWorkers');
  }

  void _sipListener() {
    if (sipModel.isActiveCall && !sipModel.isActiveCallScreen) {
      sipModel.isActiveCallScreen = true;
      Navigator.of(
        AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!,
        rootNavigator: true,
      ).pushNamed(CallScreen.routeName);
    }
  }

  Future<bool?> showExitPopup(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Закрыть приложение',
          style: AppTextStyle.boldHeadLine.style(context),
        ),
        content: Text(
          'Вы уверены, что хотите закрыть приложение?',
          style: AppTextStyle.regularCaption.style(context),
        ),
        actions: [
          PrimaryButton.cyan(
            onPressed: () => Navigator.of(context).pop(false),
            text: 'Отмена',
          ),
          PrimaryButton.red(
            onPressed: () => Navigator.of(context).pop(true),
            text: 'Закрыть',
          ),
        ],
      ),
    );
  }

  Future onWillPop(BuildContext context, {required bool didPop}) async {
    if (didPop) return;
    try {
      if (pageController.page! >= 0 &&
          pageController.page! < homeDataStore.navigationItems.length) {
        final maybePopList = <bool>[];
        for (final key in AppRouter.navigatorKeys.entries) {
          if (key.value.currentState?.canPop() == true) {
            maybePopList.add(true);
            await key.value.currentState?.maybePop();
          }
        }
        if (maybePopList.every((e) => e == false)) {
          if (await showExitPopup(context) == true) {
            await SystemNavigator.pop(animated: true);
          }
          return;
        }
      }
      if (await showExitPopup(context) == true) {
        await SystemNavigator.pop(animated: true);
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  @action
  void dispose() {
    sipModel.removeListener(_sipListener);
    _internetSub?.cancel();
    _configListener.cancel();
    _gpsListener.cancel();
    pageController.dispose();
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const String routeName = '/main_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(
        context.read<HomeData>(),
        context.read<SipModel>(),
        AppSession.of(context),
        AppConnectivityNotifier.maybeOf(context),
        AppRemoteConfig.of(context),
      ),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            body: PopScope(
              canPop: false,
              onPopInvoked: (didPop) => _State.of(context).onWillPop(
                context,
                didPop: didPop,
              ),
              child: const _Pages(),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: const _CallState(),
            bottomNavigationBar: const _BottomNavigation(),
          ),
        ),
        if (!_State.of(context).isGeoEnabled)
          Positioned.fill(
            child: Material(
              color: AppColors.blackContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    '''ГЕОПОЗИЦИЯ НЕ АКТИВНА\nВключите GPS и перезапустите приложение''',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regularSubHeadline.style(context),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Pages extends StatelessWidget {
  const _Pages();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemBuilder: (ctx, index) => _State.of(context).pages[index].page(),
      itemCount: _State.of(context).pages.length,
      controller: _State.of(context).pageController,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}

class _CallState extends StatelessWidget {
  const _CallState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.read<SipModel>(),
      builder: (context, child) {
        final active = context.read<SipModel>().isActiveCall;
        if (active) {
          return PrimaryButton.green(
            text: 'Активный вызов',
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(CallScreen.routeName);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _BottomNavigation extends StatelessObserverWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _State.of(context).pageController,
      builder: (ctx, child) {
        return BottomNavigationBar(
          key: _State.of(context).bottomNavigatorKey,
          currentIndex: _State.of(context).pageController.page?.toInt() ??
              _State.of(context).pageController.initialPage,
          backgroundColor: Colors.black38,
          onTap: _State.of(context).pageController.jumpToPage,
          unselectedLabelStyle:
              Theme.of(context).bottomNavigationBarTheme.unselectedLabelStyle,
          selectedLabelStyle:
              Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
          unselectedItemColor:
              Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          selectedItemColor:
              Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          items: _State.of(context)
              .pages
              .map(AppBottomNavigationItem.new)
              .toList(),
        );
      },
    );
  }
}

class AppBottomNavigationItem extends BottomNavigationBarItem {
  AppBottomNavigationItem(this.screen)
      : super(
          icon: Observer(
            builder: (context) {
              if (screen == UserScreen.missedCallsScreen) {
                final count =
                    HomeData.of(context).userHeaderInfo.lostCallsCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    screen.icon(),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Center(
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              } else if (screen == UserScreen.notificationsScreen) {
                final count =
                    HomeData.of(context).userHeaderInfo.notificationsCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    screen.icon(color: count > 0 ? AppColors.red : null),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Center(
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                return screen.icon();
              }
            },
          ),
          activeIcon: Observer(builder: (context) {
            if (screen == UserScreen.missedCallsScreen) {
              final count = HomeData.of(context).userHeaderInfo.lostCallsCount;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  screen.icon(color: count > 0 ? AppColors.red : null),
                  if (count > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Center(
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            } else if (screen == UserScreen.notificationsScreen) {
              final count =
                  HomeData.of(context).userHeaderInfo.notificationsCount;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  screen.icon(
                    color: count > 0 ? AppColors.red : AppColors.violet,
                  ),
                  if (count > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Center(
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            } else {
              return screen.icon(
                color: AppColors.violet,
              );
            }
          }),
          label: screen.title,
        );

  final UserScreen screen;
}
