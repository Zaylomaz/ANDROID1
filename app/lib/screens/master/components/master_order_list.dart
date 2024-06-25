import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:rempc/screens/access_deny/access_deny_screen.dart';
import 'package:rempc/screens/master/components/master_order_list_item.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:repository/repository.dart';

class MasterOrderList extends StatefulWidget {
  const MasterOrderList({super.key});

  @override
  State<MasterOrderList> createState() => _MasterOrderListState();
}

class _MasterOrderListState extends State<MasterOrderList> {
  List<AppOrder> _orders = [];
  bool _isFetch = false;

  Future<void> _fetchData() async {
    try {
      final response = await MasterRepository().getMasterOrders();
      setState(() {
        _isFetch = true;
        _orders = response;
      });
    } catch (e) {
      if (e is TooManyRequestsException) {
        unawaited(Navigator.of(context)
            .pushReplacementNamed(ToManyRequestScreen.routeName));
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetch == false) {
      return const Center(child: CircularProgressIndicator());
    }
    return _orders.isEmpty
        ? const Center(child: Text('Нет заказов'))
        : Expanded(
            child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (ctx, index) {
                return MasterOrderListItem(
                  orderNumber: _orders[index].orderNumber,
                  userName: _orders[index].master.name,
                  date: _orders[index].date.toIso8601String(),
                  time: _orders[index].time,
                  textStatus: _orders[index].textStatus,
                );
              },
            ),
          );
  }
}
