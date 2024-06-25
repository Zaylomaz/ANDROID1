import 'package:core/core.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/cashbox/cashbox_screen.dart';
import 'package:rempc/screens/channels/channels_screen.dart';
import 'package:rempc/screens/master/masters_screen.dart';
import 'package:rempc/screens/orders/order_screen.dart';
import 'package:rempc/screens/scouting/scouting_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

import '../enums.dart';

/// Судя по названию класса - это кастомный нижний бар навигации для двух
/// экранов. Для екрана заказа на карте и екрана который говорит о том что мы
/// отправили слишком много запросов на бекенд.
///

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({
    required this.selectedMenu,
    required this.currentRoute,
    super.key,
  });

  final MenuState selectedMenu;
  final String currentRoute;

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  ///Метод получения пунктом меню в данном навбаре
  Future<void> _fetchData() async {
    context.read<HomeData>().permissions =
        await AuthRepository().getUserPermissions();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<HomeData>().permissions.canSeeManagerMenu == true) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.violetLightDark,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    iconSize: 20,
                    color: Colors.white,
                    icon: const Icon(Icons.handshake),
                    onPressed: () {
                      if (widget.currentRoute != OrderScreen.routeName) {
                        Navigator.of(context).pushNamed(OrderScreen.routeName);
                      }
                    }),
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.monetization_on),
                  onPressed: () {
                    if (widget.currentRoute != CashBoxScreen.routeName) {
                      Navigator.of(context).pushNamed(CashBoxScreen.routeName);
                    }
                  },
                ),
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.people),
                  onPressed: () {
                    if (widget.currentRoute != MasterScreen.routeName) {
                      Navigator.of(context).pushNamed(MasterScreen.routeName);
                    }
                  },
                ),
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    if (widget.currentRoute != ChannelsScreen.routeName) {
                      Navigator.of(context).pushNamed(ChannelsScreen.routeName);
                    }
                  },
                ),
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    if (widget.currentRoute != ScoutingScreen.routeName) {
                      Navigator.of(context).pushNamed(ScoutingScreen.routeName);
                    }
                  },
                ),
              ],
            )),
      );
    } else {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.violetLightDark,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.handshake),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(OrderScreen.routeName),
                ),
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.monetization_on),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CashBoxScreen.routeName);
                  },
                ),
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    Navigator.of(context).pushNamed(ChannelsScreen.routeName);
                  },
                ),
                IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.of(context).pushNamed(ScoutingScreen.routeName);
                  },
                ),
              ],
            )),
      );
    }
  }
}
