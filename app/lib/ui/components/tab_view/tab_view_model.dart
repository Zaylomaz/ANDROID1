import 'package:core/core.dart';
import 'package:rempc/ui/components/tab_view/tab_selector.dart';

abstract class AppTabViewScreen {
  String get route;
  String get filterRoute;
  String get detailsRoute;
  abstract final GlobalKey<TabContainerState> tickerKey;
}

// const List<AppTabViewScreen> appTabViewUsers = [
//   ApplicantListScreen,
//   AppCallsScreen,
//   MasterScreen,
//   ServiceOrderScreen,
// ];

// extension TabListDialogUsersExt on AppTabViewScreen {
//   String get routeName {
//     switch (this) {
//       case ApplicantListScreen _:
//         return ApplicantListScreen.routeName;
//       case AppCallsScreen _:
//         return AppCallsScreen.routeName;
//       case MasterScreen _:
//         return MasterScreen.routeName;
//       case ServiceOrderScreen _:
//         return ServiceOrderScreen.routeName;
//     }
//     throw ArgumentError(
//         'TabListDialogUsersExt.routeName => AppTabViewScreen is undefined');
//   }
//
//   String get filterRouteName {
//     switch (this) {
//       case ApplicantListScreen _:
//         return ApplicantFilterScreen.routeName;
//       case AppCallsScreen _:
//         return CallFilterScreen.routeName;
//       case MasterScreen _:
//         return MasterFilterScreen.routeName;
//       case ServiceOrderScreen _:
//         return ServiceOrderFilterScreen.routeName;
//     }
//     throw ArgumentError(
//         'TabListDialogUsersExt.editRouteName => AppTabViewScreen is undefined');
//   }
// }
