import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/orders/components/item/order_list_item_v2.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

class OrderList<T> extends StatefulWidget {
  const OrderList(this.updateDataSub, {super.key});

  final Subject<bool> updateDataSub;

  @override
  State<OrderList<T>> createState() => _OrderListState<T>();
}

class _OrderListState<T> extends State<OrderList<T>> {
  List<T> _orders = [];
  bool _isOrdersFetch = false;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<bool>? updateData;

  Future<void> _fetchData() async {
    try {
      final orders = T.runtimeType is AppOrder
          ? await OrdersRepository().getOrders()
          : await OrdersRepository().getOrdersV2();
      if (!mounted) return;
      setState(() => _isOrdersFetch = false);
      await Future.delayed(
        const Duration(milliseconds: 20),
      );
      _orders = orders as List<T>;
      _isOrdersFetch = true;
      setState(() {});
    } catch (e, s) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, s));
      if (e is TooManyRequestsException) {
        unawaited(Navigator.of(AppRouter
                .navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!)
            .pushReplacementNamed(ToManyRequestScreen.routeName));
      }
      if (e is TimeoutException) {
        await showMessage(
          context,
          message: 'Ошибка соединения',
          action: _fetchData,
          actionText: 'Повторить',
          type: AppMessageType.error,
        );
      }
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void updateDataListener(bool? value) {
    if (value == true) {
      setState(() {
        _orders = [];
      });
      _fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateData = widget.updateDataSub.listen(updateDataListener);
    });
  }

  @override
  void dispose() {
    super.dispose();
    updateData?.cancel();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOrdersFetch == false) {
      return const Center(child: AppLoadingIndicator());
    }
    if (_orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
            child: Text(
          'Нет заказов',
          style: AppTextStyle.boldHeadLine.style(
            context,
            AppColors.violetLight,
          ),
        )),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 12),
        itemCount: _orders.length,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemBuilder: (ctx, index) {
          return OrderListItemV2(
            key: ValueKey<String>(
              '${(_orders[index] as AppOrderV2).id}_$index',
            ),
            order: _orders[index] as AppOrderV2,
            updateOrderPage: _fetchData,
          );
          // if (T.runtimeType is AppOrder) {
          //   return OrderListItem(
          //     order: _orders[index] as AppOrder,
          //     updateOrderPage: _fetchData,
          //   );
          // } else if (T.runtimeType is AppOrderV2) {
          //   return OrderListItemV2(
          //     order: _orders[index] as AppOrderV2,
          //     updateOrderPage: _fetchData,
          //   );
          // }
          // return const SizedBox();
          // is_read
        },
        separatorBuilder: (context, i) => const SizedBox(height: 12),
      ),
    );
  }
}
