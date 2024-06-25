import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:contacts/contacts.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:rempc/screens/ai_chat/ai_chat_screen.dart';
import 'package:rempc/screens/applicant/applicant_screen.dart';
import 'package:rempc/screens/applicant/details/applicant_details_screen.dart';
import 'package:rempc/screens/applicant/filter/applicant_filter.dart';
import 'package:rempc/screens/calls/calls_screen.dart';
import 'package:rempc/screens/calls/details/call_details.dart';
import 'package:rempc/screens/calls/filter/calls_filter.dart';
import 'package:rempc/screens/cashbox/cashbox_screen.dart';
import 'package:rempc/screens/cashbox_admin/cashbox_admin_edit/cashbox_admin_edit_screen.dart';
import 'package:rempc/screens/cashbox_admin/cashbox_admin_screen.dart';
import 'package:rempc/screens/channels/channels_screen.dart';
import 'package:rempc/screens/chat/chat_screen.dart';
import 'package:rempc/screens/close_order/close_order_screen.dart';
import 'package:rempc/screens/developer/developer_screen.dart';
import 'package:rempc/screens/faq/faq_details_screen.dart';
import 'package:rempc/screens/faq/faq_list_screen.dart';
import 'package:rempc/screens/home/home_screen.dart';
import 'package:rempc/screens/master/details/master_screen.dart';
import 'package:rempc/screens/master/edit/master_edit_screen.dart';
import 'package:rempc/screens/master/filter/master_filter.dart';
import 'package:rempc/screens/master/masters_screen.dart';
import 'package:rempc/screens/notifications/notifications_screen.dart';
import 'package:rempc/screens/order_additional/order_additional_screen.dart';
import 'package:rempc/screens/orders/available_orders/available_orders.dart';
import 'package:rempc/screens/orders/order_screen.dart';
import 'package:rempc/screens/scouting/scouting_screen.dart';
import 'package:rempc/screens/service_orders/components/edit/service_order_editor.dart';
import 'package:rempc/screens/service_orders/components/filter/service_order_filter.dart';
import 'package:rempc/screens/service_orders/service_orders_screen.dart';
import 'package:rempc/screens/sign_in/sign_in_screen.dart';
import 'package:rempc/screens/sign_up/sign_up_screen.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:rempc/screens/web_view/web_view_screen.dart';
import 'package:rempc/ui/components/dialpad_view.dart';
import 'package:rempc/ui/screens/debug_screen.dart';
import 'package:rempc/ui/screens/settings/settings_page.dart';
import 'package:rempc/ui/screens/splash_page.dart';
import 'package:rempc/ui/screens/tab/kanban_masters_page.dart';
import 'package:rempc/ui/screens/tab/kanban_order_page.dart';
import 'package:rempc/ui/screens/tab/kanban_page.dart';
import 'package:rempc/ui/screens/tab/main_screen.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

///
/// Роутер приложения
/// Их тут два.
/// Первый - глобальный
/// Второй - вложенный навигатор в екраны главного меню приложения
///
/// Одни и те-же экраны могут открываться в этих навигаторах, следовательно
/// их мы обозначаем в обоих функциях рендера экрана.
///
/// Так-же тут обозначены [GlobalKey] для всего приложения.
///
class AppRouter {
  factory AppRouter() => _singleton;

  AppRouter._internal();

  static final AppRouter _singleton = AppRouter._internal();

  ///Список имен [GlobalKey]
  ///Названия ключей с встроенной симантикой
  static const String mainNavigatorKey = 'root_navigator';
  static const String homeNavigatorKey = 'home_navigator';
  static const String ordersNavigatorKey = 'orders_navigator';
  static const String mastersNavigatorKey = 'masters_navigator';
  static const String kanbanNavigatorKey = 'kanban_navigator';
  static const String callsNavigatorKey = 'calls_navigator';
  static const String faqNavigatorKey = 'faq_navigator';
  static const String applicantNavigatorKey = 'applicant_navigator';
  static const String serviceNavigatorKey = 'serviceHome';
  static const String cashboxAdminNavigatorKey = 'cashbox_admin';
  static const String cashboxNavigatorKey = 'cashbox';
  static const String masterNavigatorKey = 'master';
  static const String chatNavigatorKey = 'chat';
  static const String scoutingNavigatorKey = 'scouting';
  static const String settingsNavigationKey = 'settings';
  static const String dialpadNavigationKey = 'dialpad';
  static const String missedCallsNavigationKey = 'missedCalls';
  static const String notificationsNavigationKey = 'notifications';

  ///[GlobalKey] навигаторов
  static final Map<String, GlobalKey<NavigatorState>> navigatorKeys = {
    mainNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'mainNavigatorKey',
    ),
    ordersNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'ordersNavigatorKey',
    ),
    kanbanNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'kanbanNavigatorKey',
    ),
    mastersNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'mastersNavigatorKey',
    ),
    homeNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'homeNavigatorKey',
    ),
    callsNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'callsNavigatorKey',
    ),
    faqNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'faqNavigatorKey',
    ),
    applicantNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'applicantNavigatorKey',
    ),
    cashboxNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'cashboxNavigatorKey',
    ),
    masterNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'masterNavigatorKey',
    ),
    chatNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'chatNavigatorKey',
    ),
    scoutingNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'scoutingNavigatorKey',
    ),
    settingsNavigationKey: GlobalKey<NavigatorState>(
      debugLabel: 'settingsNavigationKey',
    ),
    serviceNavigatorKey: GlobalKey<NavigatorState>(
      debugLabel: 'serviceNavigatorKey',
    ),
    dialpadNavigationKey: GlobalKey<NavigatorState>(
      debugLabel: 'dialpadNavigationKey',
    ),
    missedCallsNavigationKey: GlobalKey<NavigatorState>(
      debugLabel: 'missedCallsNavigationKey',
    ),
    notificationsNavigationKey: GlobalKey<NavigatorState>(
      debugLabel: 'notificationsNavigationKey',
    ),
  };

  /// История навигации
  List<RouteSettings> _history = [];

  /// Стрим истории
  final _historyStream = BehaviorSubject<List<RouteSettings>>.seeded(
      [const RouteSettings(name: 'SEED')]);

  /// Записать событие в историю (хранит 100 роутов)
  void _pushHistory(RouteSettings settings) {
    if (_history.length >= 100) {
      _history = _history
        ..sublist(1, 99)
        ..add(settings);
    } else {
      _history.add(settings);
    }
    _historyStream.add(_history);
  }

  /// Получить историю навигации
  List<RouteSettings> get history => _history;

  Stream<List<RouteSettings>> get historyStream => _historyStream.stream;

  /// Генератор страниц в навигаторе
  Route<dynamic> routeBuilder(RouteSettings settings) {
    if (kDebugMode) {
      _pushHistory(settings);
    }
    final arguments = settings.arguments;
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );
      case SignInScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const SignInScreen(),
          settings: settings,
        );
      case SignUpScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const SignUpScreen(),
          settings: settings,
        );
      case AwaitAuthScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => AwaitAuthScreen(
            arguments as DioException,
          ),
          settings: settings,
        );
      case CallScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const CallScreen(),
          settings: settings,
        );
      case MainScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const MainScreen(),
          settings: settings,
        );
      case NotificationsScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const NotificationsScreen(),
          settings: settings,
        );
      case DeveloperScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const DeveloperScreen(),
          settings: settings,
        );
      case ToManyRequestScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const ToManyRequestScreen(),
          settings: settings,
        );
      case ChatScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const ChatScreen(),
          settings: settings,
        );
      case DebugScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const DebugScreen(),
          settings: settings,
        );
      case FAQListScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const FAQListScreen(),
          settings: settings,
        );
      case FAQDetailsScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => FAQDetailsScreen(
            arguments as FAQDetails,
          ),
          settings: settings,
        );
      case MasterFilterScreen.routeName:
        return MaterialPageRoute<AppMasterUserFilter?>(
          builder: (context) => MasterFilterScreen(
            args: arguments as MasterFilterScreenArgs,
          ),
          settings: settings,
        );
      case MasterEdit.routeName:
        return MaterialPageRoute<bool?>(
          builder: (context) => MasterEdit(
            args: arguments as MasterEditArgs,
          ),
          settings: settings,
        );
      case ServiceOrderFilterScreen.routeName:
        return MaterialPageRoute<ServiceOrderFilter?>(
          builder: (context) => ServiceOrderFilterScreen(
            arguments as ServiceOrderFilterScreenArgs,
          ),
          settings: settings,
        );
      case ServiceOrderEditor.routeName:
        return MaterialPageRoute<ServiceOrder?>(
          builder: (context) => ServiceOrderEditor(
            arguments as ServiceOrderEditorArgs,
          ),
          settings: settings,
        );
      case WebViewScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => WebViewScreen(
            args: arguments as WebViewScreenArgs,
          ),
          settings: settings,
        );
      case AvailableOrdersScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const AvailableOrdersScreen(),
          settings: settings,
        );
      case ApplicantListScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => ApplicantListScreen(),
          settings: settings,
        );
      case ApplicantDetailsScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => ApplicantDetailsScreen(
            args: arguments as ApplicantDetailsScreenArgs,
          ),
          settings: settings,
        );
      case ApplicantFilterScreen.routeName:
        return MaterialPageRoute<ApplicantFilter?>(
          builder: (context) => ApplicantFilterScreen(
            args: arguments as ApplicantFilterScreenArgs,
          ),
          settings: settings,
        );
      case AppContacts.routeName:
        return MaterialPageRoute(
          builder: (context) => const AppContacts(),
          settings: settings,
        );
      case HomeScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
      case ServiceOrderScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => ServiceOrderScreen(),
          settings: settings,
        );
      case OrderScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const OrderScreen(),
          settings: settings,
        );
      case CloseOrderScreen.routeName:
        return MaterialPageRoute<bool?>(
          builder: (ctx) => CloseOrderScreen(
            args: arguments as CloseOrderScreenArgs,
          ),
          settings: settings,
        );
      case OrderAdditionalScreen.routeName:
        return MaterialPageRoute<bool?>(
          builder: (ctx) => OrderAdditionalScreen(
            args: arguments as OrderAdditionalScreenArgs,
          ),
          settings: settings,
        );
      case CashBoxScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const CashBoxScreen(),
          settings: settings,
        );
      case DialPadPage.routeName:
        return MaterialPageRoute(
          builder: (context) => const DialPadPage(
            isFullScreen: true,
          ),
          settings: settings,
        );
      case AppCallsScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => AppCallsScreen(),
          settings: settings,
        );
      case CallDetails.routeName:
        return MaterialPageRoute(
          builder: (context) => CallDetails(
            arguments as CallDetailsArgs,
          ),
          settings: settings,
        );
      case CallFilterScreen.routeName:
        return MaterialPageRoute<AppPhoneCallFilter?>(
          builder: (context) => CallFilterScreen(
            args: arguments as CallFilterScreenArgs,
          ),
          settings: settings,
        );
      case ChannelsScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const ChannelsScreen(),
          settings: settings,
        );
      case ScoutingScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const ScoutingScreen(),
          settings: settings,
        );
      case SettingsPage.routeName:
        return MaterialPageRoute(
          builder: (context) => const SettingsPage(),
          settings: settings,
        );
      case KanbanPage.routeName:
        return MaterialPageRoute(
          builder: (context) => const KanbanPage(),
          settings: settings,
        );
      case KanbanMastersPage.routeName:
        return MaterialPageRoute(
          builder: (context) => KanbanMastersPage(
            arguments as Map<String, int>,
          ),
          settings: settings,
        );
      case KanbanOrderPage.routeName:
        return MaterialPageRoute(
          builder: (context) => KanbanOrderPage(
            arguments as Map<String, int>,
          ),
          settings: settings,
        );
      case CashBoxAdminScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const CashBoxAdminScreen(),
          settings: settings,
        );
      case CashBoxAdminEditScreen.routeName:
        return MaterialPageRoute<CashBoxDetails?>(
          builder: (context) => CashBoxAdminEditScreen(
            args: arguments as CashBoxAdminEditScreenArgs,
          ),
          settings: settings,
        );
      case ScoutingResultScreen.routeName:
        return MaterialPageRoute<bool?>(
          builder: (context) => ScoutingResultScreen(
            args: arguments as ScoutingResultScreenArgs,
          ),
          settings: settings,
        );
      case MasterScreen.routeName:
        return MaterialPageRoute<bool?>(
          builder: (context) => MasterScreen(),
          settings: settings,
        );
      case MasterScreenDetails.routeName:
        return MaterialPageRoute(
          builder: (context) => MasterScreenDetails(
            args: arguments as MasterScreenDetailsArgs,
          ),
          settings: settings,
        );
      case AiChatScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const AiChatScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: AppTextStyle.regularHeadline.style(context),
              ),
            ),
          ),
          settings: settings,
        );
    }
  }
}
