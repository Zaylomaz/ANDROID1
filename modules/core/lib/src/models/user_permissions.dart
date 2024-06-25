import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:uikit/uikit.dart';

/// Модель для понимания того что пользователь может видеть в меню
enum UserScreen {
  orderScreen('OrdersScreen'),
  serviceOrderScreen('OrderScScreen'),
  cashboxScreen('CashboxScreen'),
  cashboxAdminScreen('CashboxAdminScreen'),
  kanbanScreen('KanbanScreen'),
  chatScreen('ChatScreen'),
  chatAiScreen('ChatAiScreen'),
  scoutingScreen('ScoutingScreen'),
  settingsScreen('SettingsScreen'),
  dialPadScreen('DialPadScreen'),
  notificationsScreen('NotificationsScreen'),
  mastersScreen('MastersScreen'),
  missedCallsScreen('MissedCallsScreen'),
  faq('Faq'),
  applicant('Applicant'),
  home('Home'),
  undefined('');

  const UserScreen(this.backendValue);

  /// Mapper
  factory UserScreen.fromJson(JsonReader json) =>
      UserScreen.values.firstWhere((e) => e.backendValue == json.asString(),
          orElse: () => UserScreen.undefined);

  /// Значение получаемое с сервера
  final String backendValue;

  /// параметр для сортировки чтоб ставить главную страницу на первое место
  int get weight => this == UserScreen.home ? 0 : 1;

  String get semanticTitle {
    switch (this) {
      case UserScreen.orderScreen:
        return 'Orders';
      case UserScreen.serviceOrderScreen:
        return 'Service Orders';
      case UserScreen.cashboxScreen:
        return 'CashBox';
      case UserScreen.cashboxAdminScreen:
        return 'CashBoxAdmin';
      case UserScreen.kanbanScreen:
        return 'Master';
      case UserScreen.chatScreen:
        return 'Chat';
      case UserScreen.chatAiScreen:
        return 'ChatAI';
      case UserScreen.scoutingScreen:
        return 'Scouting';
      case UserScreen.settingsScreen:
        return 'Settings';
      case UserScreen.dialPadScreen:
        return 'Call';
      case UserScreen.notificationsScreen:
        return 'Notifications';
      case UserScreen.mastersScreen:
        return 'Masters';
      case UserScreen.missedCallsScreen:
        return 'MissedCall';
      case UserScreen.faq:
        return 'FAQ';
      case UserScreen.applicant:
        return 'Applicant';
      case UserScreen.home:
        return 'Home';
      case UserScreen.undefined:
        return 'undefined';
    }
  }

  String get title {
    switch (this) {
      case UserScreen.orderScreen:
        return 'Заказы';
      case UserScreen.serviceOrderScreen:
        return 'Заказы СЦ';
      case UserScreen.cashboxAdminScreen:
        return 'Управление Кассой';
      case UserScreen.cashboxScreen:
        return 'Касса';
      case UserScreen.kanbanScreen:
        return 'Координирование';
      case UserScreen.chatScreen:
        return 'Чат';
      case UserScreen.chatAiScreen:
        return 'Чат AI';
      case UserScreen.scoutingScreen:
        return 'Отчеты рекламы';
      case UserScreen.settingsScreen:
        return 'Настройки';
      case UserScreen.dialPadScreen:
        return 'Телефон';
      case UserScreen.notificationsScreen:
        return 'Уведомления';
      case UserScreen.mastersScreen:
        return 'Мастера';
      case UserScreen.missedCallsScreen:
        return 'Звонки';
      case UserScreen.faq:
        return 'База знаний';
      case UserScreen.applicant:
        return 'Соискатели';
      case UserScreen.home:
        return 'Главная';
      case UserScreen.undefined:
        return 'undefined';
    }
  }

  Widget icon({
    Color? color = AppColors.grayText,
    double? width = 24,
    double? height = 24,
  }) {
    switch (this) {
      case UserScreen.orderScreen:
        return AppIcons.menuOrders.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.serviceOrderScreen:
        return AppIcons.service.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.cashboxAdminScreen:
      case UserScreen.cashboxScreen:
        return AppIcons.menuCashbox.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.kanbanScreen:
        return AppIcons.menuManagement.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.chatScreen:
        return AppIcons.menuChat.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.chatAiScreen:
        return AppIcons.aiBrain.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.scoutingScreen:
        return AppIcons.menuScouting.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.settingsScreen:
        return AppIcons.menuSettings.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.dialPadScreen:
        return AppIcons.phone.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.notificationsScreen:
        return AppIcons.menuNotifications.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.mastersScreen:
        return AppIcons.userSearch.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.missedCallsScreen:
        return AppIcons.call.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.faq:
        return AppIcons.faq.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.applicant:
        return AppIcons.user.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.home:
        return AppIcons.home.widget(
          color: color,
          width: width,
          height: height,
        );
      case UserScreen.undefined:
        return const SizedBox.shrink();
    }
  }
}

/// Группы пунктов меню для бокового меню
enum UserScreenGroup {
  violet,
  cyan,
  green,
  red,
  grey;

  AppSplitColor get colors {
    switch (this) {
      case UserScreenGroup.violet:
        return AppSplitColor.violet();
      case UserScreenGroup.cyan:
        return AppSplitColor.cyan();
      case UserScreenGroup.green:
        return AppSplitColor.green();
      case UserScreenGroup.red:
        return AppSplitColor.red();
      case UserScreenGroup.grey:
        return AppSplitColor.violetLight();
    }
  }

  List<UserScreen> get screens {
    switch (this) {
      case UserScreenGroup.violet:
        return [
          UserScreen.orderScreen,
          UserScreen.cashboxScreen,
          UserScreen.kanbanScreen,
          UserScreen.chatScreen,
          UserScreen.scoutingScreen,
        ];
      case UserScreenGroup.cyan:
        return [
          UserScreen.notificationsScreen,
          UserScreen.mastersScreen,
          UserScreen.cashboxAdminScreen,
          UserScreen.serviceOrderScreen,
          UserScreen.applicant,
        ];
      case UserScreenGroup.grey:
        return [
          UserScreen.settingsScreen,
          UserScreen.faq,
        ];
      case UserScreenGroup.green:
        return [UserScreen.dialPadScreen];
      case UserScreenGroup.red:
        return [UserScreen.missedCallsScreen];
    }
  }
}

/// Модель состава меню и некоторых разрешений для конкретного юзера
@immutable
class UserScreenPermissions {
  const UserScreenPermissions({
    required this.canSeeManagerMenu,
    required this.leftItems,
    required this.navigationItems,
    required this.baseItem,
    this.userId,
    this.canSeeMasterButton = false,
    this.hasOrderButton = false,
  });

  factory UserScreenPermissions.fromJson(JsonReader json) {
    var permissions = base.copyWith(
      canSeeManagerMenu: json['can_see_manager_menu'].asBool(),
      canSeeMasterButton: json['can_see_master_button'].asBool(),
      hasOrderButton: json['has_order_button'].asBool(),
      userId: json['user_id'].asIntOrNull(),
    );
    if (!json.containsKey('menu')) {
      return permissions;
    }
    if (json['menu'].containsKey('left_items')) {
      final left =
          json['menu']['left_items'].asList().map(UserScreen.fromJson).toList();
      permissions = permissions.copyWith(
        leftItems: left.whereType<UserScreen>().toList(),
      );
    }
    if (json['menu'].containsKey('navigation_items')) {
      final navigation = json['menu']['navigation_items']
          .asList()
          .map(UserScreen.fromJson)
          .toList();
      permissions = permissions.copyWith(
        navigationItems: navigation.whereType<UserScreen>().toList(),
      );
    }
    if (json['menu'].containsKey('base_item')) {
      permissions = permissions.copyWith(
        baseItem: UserScreen.fromJson(json['menu']['base_item']),
      );
    }

    return permissions;
  }

  static const UserScreenPermissions base = UserScreenPermissions(
    canSeeManagerMenu: false,
    baseItem: UserScreen.settingsScreen,
    leftItems: [
      UserScreen.settingsScreen,
    ],
    navigationItems: [
      UserScreen.settingsScreen,
      UserScreen.chatScreen,
    ],
  );

  UserScreenPermissions copyWith({
    bool? canSeeManagerMenu,
    bool? canSeeMasterButton,
    bool? hasOrderButton,
    List<UserScreen>? leftItems,
    List<UserScreen>? navigationItems,
    UserScreen? baseItem,
    int? userId,
  }) =>
      UserScreenPermissions(
        canSeeManagerMenu: canSeeManagerMenu ?? this.canSeeManagerMenu,
        canSeeMasterButton: canSeeMasterButton ?? this.canSeeMasterButton,
        hasOrderButton: hasOrderButton ?? this.hasOrderButton,
        leftItems: leftItems ?? this.leftItems,
        navigationItems: navigationItems ?? this.navigationItems,
        baseItem: baseItem ?? this.baseItem,
        userId: userId ?? this.userId,
      );

  final bool canSeeManagerMenu;
  final bool canSeeMasterButton;
  final bool hasOrderButton;
  final List<UserScreen> leftItems;
  final List<UserScreen> navigationItems;
  final UserScreen baseItem;
  final int? userId;
}
