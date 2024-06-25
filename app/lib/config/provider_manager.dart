import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/model/chat_model.dart';
import 'package:rempc/model/user_model.dart';
import 'package:sip/sip.dart';

///
/// [MultiProvider] в корне приложения требует список провайдеров
/// собственно это и есть их список
///

List<SingleChildWidget> providers = [
  ///Провайдер Sip телефонии
  ChangeNotifierProvider<SipModel>(
    create: (context) => SipModel(Navigator.of(
        AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!)),
  ),

  ///Провайдер чата
  ChangeNotifierProvider<ChatModel>(
    create: (context) => ChatModel(),
  ),

  ///Провайдер удаленного Firebase конфига
  Provider<AppRemoteConfig>(
    create: (context) => AppRemoteConfig(),
  ),

  /// Провайдер "швейцарский нож" для приложения.
  /// Всё что глобально и важно
  /// Всё о чём должны знать и слушать все - пишем тут
  Provider<HomeData>(
    create: (context) => HomeData(),
  ),

  ///TODO может когда-то сделаю нормальный провайдер.
  // Provider<AppPermissionManager>(
  //   create: (context) => AppPermissionManager(),
  // ),
];
