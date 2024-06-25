library;

/// TODO написать новый провайдер для получения и слежки за разрешениями
// import 'dart:async';
//
// import 'package:core/core.dart';
// import 'package:flutter/services.dart';
// import 'package:rempc/config/router_manager.dart';
// import 'package:rempc/ui/screens/splash_page.dart';
// import 'package:uikit/uikit.dart';
//
// part 'permission_provider.g.dart';
//
// class AppPermissionManager extends AppPermissionManagerStore
//     with _$AppPermissionManager {
//   AppPermissionManager();
//
//   static AppPermissionManagerStore of(BuildContext context) =>
//       Provider.of<AppPermissionManager>(context, listen: false);
// }
//
// abstract class AppPermissionManagerStore with Store {
//   AppPermissionManagerStore() {
//     permissions = {
//       Permission.location: PermissionStatus.denied,
//       Permission.microphone: PermissionStatus.denied,
//       Permission.camera: PermissionStatus.denied,
//       Permission.phone: PermissionStatus.denied,
//       Permission.contacts: PermissionStatus.denied,
//       Permission.notification: PermissionStatus.denied,
//       Permission.mediaLibrary: PermissionStatus.denied,
//     };
//     permissionsSubject = BehaviorSubject<bool>.seeded(isGranted);
//     _setStatus().then((_) => requestAll());
//   }
//
//   final platform = const MethodChannel('helperService');
//
//   late Map<Permission, PermissionStatus> permissions;
//
//   late BehaviorSubject<bool> permissionsSubject;
//
//   ValueStream<bool> get permissionsStream => permissionsSubject.stream;
//
//   bool get isGranted =>
//       permissions.values.every((e) => e.isGranted) &&
//       isIgnoringBatteryOptimizations &&
//       isGeoEnabled;
//
//   Future<bool> awaitAccess() =>
//       permissionsStream.firstWhere((value) => value == true);
//
//   Future<void> requestAll() async {
//     sdk = await getAndroidSDK();
//     if (sdk <= 29) {
//       permissions[Permission.storage] = PermissionStatus.denied;
//     }
//     if (sdk >= 30) {
//       permissions[Permission.photos] = PermissionStatus.denied;
//       permissions[Permission.videos] = PermissionStatus.denied;
//     }
//     await _requestAndroidPermissions();
//     await _requestBattery();
//     await _requestAndroidPermissions();
//     if (!isPermissionDialogShown.value) {
//       await _PermissionDialog.show(
//           AppRouter.navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!);
//     }
//     await _requestFlutterPermissions();
//   }
//
//   Future<void> _setStatus() async {
//     for (final permission in permissions.entries) {
//       final status = await permission.key.status;
//       permissions[permission.key] = status;
//     }
//     permissionsSubject.add(isGranted);
//     debugPrint('isGranted => $isGranted'.toString());
//     if (!isGranted) {
//       debugPrint(sdk.toString());
//       debugPrint(permissions.entries
//           .where((e) => e.value != PermissionStatus.granted)
//           .toString());
//       debugPrint(
//           'isIgnoringBatteryOptimizations $isIgnoringBatteryOptimizations'
//               .toString());
//       debugPrint('isGeoEnabled $isGeoEnabled'.toString());
//     }
//   }
//
//   Future<void> _requestFlutterPermissions() async {
//     await permissions.keys.toList().request();
//     await _setStatus();
//   }
//
//   Future<void> _requestAndroidPermissions() async {
//     await platform.invokeMethod('requestNativePermissions');
//     await _setStatus();
//   }
//
//   Future<void> _requestBattery() async {
//     await platform.invokeMethod('requestAllowUseBattery');
//     await _checkAdditionalPermissions();
//     await _setStatus();
//   }
//
//   @observable
//   bool _isIgnoringBatteryOptimizations = false;
//   @computed
//   bool get isIgnoringBatteryOptimizations => _isIgnoringBatteryOptimizations;
//   @protected
//   set isIgnoringBatteryOptimizations(bool value) =>
//       _isIgnoringBatteryOptimizations = value;
//
//   @observable
//   bool _isGeoEnabled = false;
//   @computed
//   bool get isGeoEnabled => _isGeoEnabled;
//   @protected
//   set isGeoEnabled(bool value) => _isGeoEnabled = value;
//
//   @observable
//   int _sdk = 0;
//   @computed
//   int get sdk => _sdk;
//   @protected
//   set sdk(int value) => _sdk = value;
//
//   @action
//   Future _checkAdditionalPermissions() async {
//     final data = await platform.invokeMethod('checkAdditionalPermissions');
//     isIgnoringBatteryOptimizations = data['isIgnoringBatteryOptimizations'];
//     isGeoEnabled = data['isGeoEnabled'];
//   }
//
//   @action
//   void dispose() {
//     permissionsSubject.close();
//   }
// }
//
// class _PermissionDialog extends StatefulWidget {
//   const _PermissionDialog();
//
//   static Future<void> show(BuildContext context) => showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const _PermissionDialog(),
//       );
//
//   static Widget permission(
//     BuildContext context, {
//     required Widget icon,
//     required String title,
//     required String text,
//   }) =>
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               icon,
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: AppTextStyle.boldHeadLine.style(context),
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(height: 12),
//           RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: 'Приложение запрашивает разрешение:',
//                   style: AppTextStyle.boldSubHeadline.style(context),
//                 ),
//                 const TextSpan(text: '\n'),
//                 TextSpan(
//                   text: text,
//                   style: AppTextStyle.regularSubHeadline.style(context),
//                 ),
//               ],
//             ),
//           )
//         ],
//       );
//
//   @override
//   State<_PermissionDialog> createState() => _PermissionDialogState();
// }
//
// class _PermissionDialogState extends State<_PermissionDialog> {
//   final _pageController = PageController();
//   List<Widget> _permissions(BuildContext context) => [
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.location.widget(color: AppColors.green),
//           title: 'Геолокация',
//           text:
//               'Для корректного отображения заказов и последующей работы с ними',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.shareLocation.widget(color: AppColors.green),
//           title: 'Геолокация в фоновом режиме',
//           text:
//               '''Для оповещения клиента о том насколько быстро вы прибудете. Может быть использована когда приложение не активно или закрыто''',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.microphoneOn.widget(color: AppColors.green),
//           title: 'Микрофон',
//           text: 'Для записи звонков',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.phone.widget(color: AppColors.green),
//           title: 'Телефон',
//           text: 'Для работы встроенной телефонии',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.contacts.widget(color: AppColors.green),
//           title: 'Контакты',
//           text: 'Для работы встроенной телефонии',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.camera.widget(color: AppColors.green),
//           title: 'Камера',
//           text: 'Для создания отчетов',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.bellPush.widget(color: AppColors.green),
//           title: 'Push-уведомления',
//           text: '',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.storage.widget(color: AppColors.green),
//           title: 'Хранилище файлов',
//           text: 'Для хранения файлов используемых в приложении',
//         ),
//         _PermissionDialog.permission(
//           context,
//           icon: AppIcons.userSearch.widget(color: AppColors.green),
//           title: 'Ваш номер телефона',
//           text:
//               '''Для идентификации пользователя.\nМы не передаем собранные данные третьим лицам и используем их только сцелью улучшения сервиса нашей компании''',
//         ),
//       ];
//   int _currentPageIndex = 0;
//   bool isLastPage(BuildContext context) =>
//       _currentPageIndex == _permissions(context).length - 1;
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         side: const BorderSide(
//           color: AppColors.green,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             constraints: const BoxConstraints(
//               minHeight: 64,
//               maxHeight: 204,
//             ),
//             child: PageView(
//               controller: _pageController,
//               children: _permissions(context),
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentPageIndex = index;
//                 });
//               },
//             ),
//           ),
//           PrimaryButton.greenInverse(
//             onPressed: () {
//               if (isLastPage(context)) {
//                 isPermissionDialogShown.value = true;
//                 Navigator.of(context).pop();
//               } else {
//                 _pageController.jumpToPage(
//                   _currentPageIndex + 1,
//                 );
//               }
//             },
//             text: 'Разрешить',
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(12),
//               bottomRight: Radius.circular(12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
