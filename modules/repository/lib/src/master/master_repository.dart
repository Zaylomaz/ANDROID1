import 'package:api/api.dart';
import 'package:core/core.dart';

class MasterRepository extends AppRepository {
  factory MasterRepository() {
    return _singleton;
  }

  MasterRepository._internal();

  static final MasterRepository _singleton = MasterRepository._internal();

  Future<List<AppMaster>> getMasterInWork(String date) async {
    final response = await GetRequest(
      '/master-statistic/in-work',
      query: {
        'date': date,
      },
      secure: true,
    ).callRequest(dio);
    return response.asList().map(AppMaster.fromJson).toList();
  }

  Future<List<AppOrder>> getMasterOrders() async {
    final response = await const GetRequest(
      '/master-statistic/get-orders',
      secure: true,
    ).callRequest(dio);
    return response.asList().map(AppOrder.fromJson).toList();
  }
}
