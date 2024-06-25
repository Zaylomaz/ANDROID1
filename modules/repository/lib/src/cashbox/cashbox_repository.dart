import 'package:api/api.dart';
import 'package:core/core.dart';

class CashBoxRepository extends AppRepository {
  factory CashBoxRepository() {
    return _singleton;
  }

  CashBoxRepository._internal();

  static final CashBoxRepository _singleton = CashBoxRepository._internal();

  Future<List<CashBox>> getCashBox() async {
    final response = await const GetRequest('/v2/cashbox/get', secure: true)
        .callRequest(dio);

    return response.asList().map(CashBox.fromJson).toList();
  }

  Future<List<CashBoxList>> getCashBoxList({
    required int page,
    int pageSize = 10,
    int? orderNumber,
  }) async {
    final response = await GetRequest('/v2/cashbox', secure: true, query: {
      'per_page': pageSize,
      'page': page,
      if (orderNumber is int) 'order_number': orderNumber,
    }).callRequest(dio);

    return response['data'].asList().map(CashBoxList.fromJson).toList();
  }

  Future<CashBoxDetails> getCashBoxById(int id) async {
    final response = await GetRequest(
      '/v2/cashbox/$id',
      secure: true,
    ).callRequest(dio);

    return CashBoxDetails.fromJson(response);
  }

  Future<bool> switchCashBoxStatus({
    required int id,
    required bool submitted,
  }) async {
    final response = await PostRequest(
      '/v2/cashbox/switch-status',
      body: {
        'id': id,
        'submitted': submitted,
      },
      secure: true,
    ).getResponse(dio);

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> patchCashboxItem(CashBoxDetails body) async {
    final response = await PostRequest(
      '/v2/cashbox',
      body: body.toJson(),
      secure: true,
    ).getResponse(dio);

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> addCashboxItem(CashBoxDetails body) async {
    final response = await PostRequest(
      '/v2/cashbox/store',
      body: body.toJson(),
      secure: true,
    ).getResponse(dio);

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<CashBoxOptions> getOptions() async {
    final response = await const GetRequest(
      '/v2/cashbox/options',
      secure: true,
    ).callRequest(dio);

    return CashBoxOptions.fromJson(response);
  }

  Future<CashboxData> getBalance() async {
    final response = await const GetRequest(
      '/v2/cashbox/balance',
      secure: true,
    ).callRequest(dio);

    return CashboxData(
      balance:
          response['cashbox'].asList().map(CashboxBalance.fromJson).toList(),
      averageCheck: response['average_check'].asString(),
    );
  }
}
