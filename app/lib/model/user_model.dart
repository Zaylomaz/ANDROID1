import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:json_reader/json_reader.dart';
import 'package:repository/repository.dart';

part 'user_model.g.dart';

/// Глобальный провайдер для храрнения информации для отображения
/// главной страницы, содержит информацию о пользователе
class HomeData extends HomeDataStore with _$HomeData {
  HomeData() : super();

  static HomeDataStore of(BuildContext context) =>
      Provider.of<HomeData>(context, listen: false);
}

abstract class HomeDataStore with Store {
  HomeDataStore() {
    userInfo = _repo.userInfoStream.listen((event) {
      runInAction(() {
        userHeaderInfo = event;
      });
    });
    periodicTask();
    notificationsSub = notificationsStream.listen(channelListener);
  }

  /// Канал запросов на андроид натив код
  static const platform = MethodChannel('helperService');

  /// Канал получения Push сообщений в Raw формате
  static const notifications = EventChannel('notification_event_handler');

  /// Стрим Push сообщений в Raw формате
  static Stream get notificationsStream =>
      notifications.receiveBroadcastStream();

  int get userId => userHeaderInfo.userId;

  static final _repo = DeprecatedRepository();
  static final _userRepo = UsersRepository();

  /// Стрим [HomePageData] сообщений
  static final homeDataStream = BehaviorSubject<HomePageData?>.seeded(null);

  /// Стрим [PushNotification] сообщений
  static final pushNotificationStream =
      BehaviorSubject<PushNotification?>.seeded(null);
  late StreamSubscription<UserHeaderInfo> userInfo;
  late StreamSubscription notificationsSub;

  /// Стрим указывающий на то что нужно обновить данные
  /// [OrderList] дергает внутренний метод [_fetchData]
  Subject<bool> updateData = BehaviorSubject.seeded(false);

  /// Атрибуты текущего пользователя
  @observable
  UserHeaderInfo _userHeaderInfo = UserHeaderInfo.empty;
  @computed
  UserHeaderInfo get userHeaderInfo => _userHeaderInfo;
  @protected
  set userHeaderInfo(UserHeaderInfo value) => _userHeaderInfo = value;

  /// Информация отображаемая на главной странице
  @observable
  HomePageData? _homePageData;
  @computed
  HomePageData? get homePageData => _homePageData;
  @protected
  set homePageData(HomePageData? value) {
    _homePageData = value;
    homeDataStream.add(homePageData);
  }

  /// Средний чек
  @observable
  String _averageCheck = '';
  @computed
  String get averageCheck => _averageCheck;
  @protected
  set averageCheck(String value) => _averageCheck = value;

  /// Касса по городам
  @observable
  List<CashboxBalance> _balance = [];
  @computed
  List<CashboxBalance> get balance => _balance;
  @protected
  set balance(List<CashboxBalance> value) => _balance = value;

  /// Текущий пользователь
  @observable
  AppMasterUser? _user;
  @computed
  AppMasterUser? get user => _user;
  @protected
  set user(AppMasterUser? value) => _user = value;

  /// хранит информацию о составе меню и доступу к некоторым функциям
  @observable
  UserScreenPermissions _permissions = UserScreenPermissions.base;
  @computed
  UserScreenPermissions get permissions => _permissions;
  set permissions(UserScreenPermissions value) => _permissions = value;

  @observable
  String _userChannelId = '';
  @computed
  String get userChannelId => _userChannelId;
  set userChannelId(String value) => _userChannelId = value;

  /// Набор пунктов меню для [AppDrawer] (полное меню)
  List<UserScreen> get leftItems => permissions.leftItems;

  /// Набор пунктов меню в нижнем меню (главные страницы)
  List<UserScreen> get navigationItems => permissions.navigationItems;

  /// Первый пункт меню в нижнем меню
  UserScreen get baseItem => permissions.baseItem;

  /// Обновляет id канала для чата каждые 2 секунды
  /// TODO переписать
  Future<void> periodicTask() async {
    Future.delayed(const Duration(seconds: 2), () async {
      unawaited(periodicTask());
    });
    await updateChannelId();
  }

  /// Обновляет id канала для чата
  Future<void> updateChannelId() async {
    final channelId = await platform.invokeMethod('getChannelId');
    if (channelId != '') {
      permissions = permissions.copyWith(baseItem: UserScreen.chatScreen);
      if (userChannelId != channelId) {
        userChannelId = channelId;
      }
    }
  }

  /// Возвращает индекс первого пункта меню
  int get getInitialPage {
    var index = navigationItems.indexOf(baseItem);
    if (index == -1) {
      index = 0;
    }
    return index;
  }

  /// Запускает сервис
  @action
  Future<void> init() async {
    try {
      homePageData = await _repo.getHomePageData();
    } on UnauthorizedException {
      return;
    }
    try {
      await Future.wait([
        updateUserInfo(),
        _userRepo.getUsersListFilter(),
        refreshBalance(),
      ]);
    } finally {}
    if (userHeaderInfo.userId > -1) {
      await platform.invokeMethod('setReportUniqueId', {
        'uniqueId': userHeaderInfo.userId.toString(),
        'name': userHeaderInfo.userName,
      });
    }
  }

  /// Обновляем все данные
  @action
  Future<void> refresh() async {
    try {
      homePageData = await _repo.getHomePageData(unauthorizedRedirect: true);
    } finally {
      await Future.wait([
        refreshBalance(),
        updateUserInfo(),
        _userRepo.getUsersListFilter(),
      ]);
    }
  }

  /// Обновит средний чек и кассу по городам
  @action
  Future<void> refreshBalance() async {
    final balanceData = await CashBoxRepository().getBalance();
    averageCheck = balanceData.averageCheck;
    balance = balanceData.balance..sort((a, b) => b.total.compareTo(a.total));
  }

  /// Обновит атрибуты текущего пользователя
  /// затем обновит пользователя
  @action
  Future<void> updateUserInfo() =>
      _repo.getUserHeaderInfo().then((value) => getCurrentUser(value.userId));

  /// Обновляет пользователя
  @action
  Future<AppMasterUser> getCurrentUser(int id) async {
    return user = await _userRepo.getUserInfo(id);
  }

  void channelListener(dynamic event) {
    final json = JsonReader(event);
    final notification =
        PushNotification.fromRawString(json['body']['rawPayload'].asString());
    pushNotificationStream.add(notification);
    updateUserInfo();
  }

  @action
  void dispose() {
    /// убивает стрим
    userInfo.cancel();
    notificationsSub.cancel();
    homeDataStream.close();
    pushNotificationStream.close();
    updateData.close();
  }
}
