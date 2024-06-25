import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:rempc/screens/access_deny/access_deny_screen.dart';
import 'package:rempc/screens/master/components/master_in_work_list_item.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:repository/repository.dart';

class MasterInWorkList extends StatefulWidget {
  const MasterInWorkList({super.key});

  @override
  State<MasterInWorkList> createState() => _MasterInWorkListState();
}

class _MasterInWorkListState extends State<MasterInWorkList> {
  List<AppMaster> _masters = [];
  bool _isFetch = false;

  Future<void> _fetchData() async {
    try {
      final response = await MasterRepository().getMasterInWork('');
      setState(() {
        _isFetch = true;
        _masters = response;
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
    return _masters.isEmpty
        ? const Center(child: Text('Нет мастеров'))
        : Expanded(
            child: ListView.builder(
              itemCount: _masters.length,
              itemBuilder: (ctx, index) {
                return MasterInWorkListItem(
                  userNumber: _masters[index].number,
                  userName: _masters[index].name,
                  weekendDays: _masters[index].weekendDaysByName,
                  userStatus: _masters[index].workStatus,
                );
              },
            ),
          );
  }
}
