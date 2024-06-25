import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/screens/old_screen_abstract.dart';
import 'package:rempc/screens/orders/available_orders/available_orders.dart';
import 'package:rempc/screens/orders/components/order_list.dart';
import 'package:uikit/uikit.dart';

class OrderScreen extends OldScreenAbstract {
  const OrderScreen({super.key});

  static const String routeName = '/orders';

  @override
  final String title = 'Заказы';

  @override
  Widget buildBody() => Builder(
        builder: (context) {
          return OrderList<AppOrderV2>(context.read<HomeData>().updateData);
        },
      );

  @override
  FloatingActionButton? floatingActionButton(BuildContext context) =>
      HomeData.of(context).permissions.hasOrderButton
          ? FloatingActionButton(
              elevation: 4,
              highlightElevation: 8,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppColors.greenDark,
              onPressed: () async {
                unawaited(HapticFeedback.mediumImpact());
                await Navigator.maybeOf(context, rootNavigator: true)
                    ?.pushNamed(AvailableOrdersScreen.routeName);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              enableFeedback: true,
              child: AppIcons.work.widget(color: AppColors.green),
            )
          : null;
}

class OrderPageRouter extends OldPageRouterAbstract {
  const OrderPageRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => OrderScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.ordersNavigatorKey];
}
