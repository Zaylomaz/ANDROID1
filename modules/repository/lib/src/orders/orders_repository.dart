import 'package:api/api.dart';
import 'package:core/core.dart';

class OrdersRepository extends AppRepository {
  factory OrdersRepository() {
    return _singleton;
  }

  OrdersRepository._internal();

  static final OrdersRepository _singleton = OrdersRepository._internal();

  Future<List<AppOrder>> getOrders() async {
    final response = await const GetRequest(
      '/orders/get',
      secure: true,
    ).callRequest(dio);

    return response.asList().map(AppOrder.fromJson).toList();
  }

  Future<List<AppOrderV2>> getOrdersV2() async {
    final response = await const GetRequest(
      '/v2/orders',
      secure: true,
    ).callRequest(dio);

    return response['data'].asList().map(AppOrderV2.fromJson).toList();
  }

  Future<AppOrder> getOrderById(int id) async {
    final result = await GetRequest(
      '/orders/$id/show',
      secure: true,
    ).callRequest(dio);

    return AppOrder.fromJson(result['data']);
  }

  Future<AdditionalOrderInfo> getAdditionalOrderById(int id) async {
    final result = await GetRequest(
      '/additional-order/$id',
      secure: true,
    ).callRequest(dio);

    return AdditionalOrderInfo.fromJson(result['data']);
  }

  Future<bool> setOrderStatus(int orderId, int status) async {
    final data = await getAndroidPosition();

    final response = await GetRequest(
      '/orders/set-status',
      query: {
        'id': orderId.toString(),
        'status': status.toString(),
        ...data.toJson(),
      },
      secure: true,
    ).getResponse(dio);

    return response.statusCode == 200;
  }

  Future<AppOrderV2> setOrderStatusV2(int orderId, int status) async {
    final data = await getAndroidPosition();

    final response = await GetRequest(
      '/v2/orders/set-status',
      query: {
        'id': orderId.toString(),
        'status': status.toString(),
        ...data.toJson(),
      },
      secure: true,
    ).callRequest(dio);

    return AppOrderV2.fromJson(response['data']);
  }

  Future<bool> closeOrderRework({
    required int orderId,
    required int orderSum,
    required String date,
    required TimeSlot time,
    String comment = '',
    Coords? position,
  }) async {
    final response = await PostRequest(
      '/orders/close-order-rework',
      secure: true,
      body: {
        'id': orderId,
        'order_sum': orderSum,
        'date': date,
        'comment': comment,
        'time': time.slot,
        if (position != null) ...{
          'latitude': position.latitude,
          'longitude': position.longitude,
        }
      },
    ).getResponse(dio);
    return response.statusCode == 200;
  }

  Future<bool> closeOrderWarranty({
    required int orderId,
    required String comment,
    required String filePath,
    Coords? position,
  }) async {
    final formData = FormData.fromMap({
      'id': orderId,
      'comment': comment,
      if (position != null) ...{
        'latitude': position.latitude,
        'longitude': position.longitude,
      }
    });
    formData.files.add(
      MapEntry(
        'check_image',
        await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      ),
    );

    final response = await FileUploadRequest(
      '/orders/close-order-garanty',
      formData: formData,
      secure: true,
    ).upload(dio);

    return response.statusCode == 200;
  }

  Future<Response> setOrderCloseCheck({
    required int orderId,
    required int status,
    required String filePath,
    required String orderSum,
    String comment = '',
    Coords? position,
  }) async {
    final formData = FormData.fromMap({
      'id': orderId.toString(),
      'status': status.toString(),
      'order_sum': orderSum,
      'comment': comment,
      'token': ApiStorage().accessToken,
      if (position != null) ...{
        'latitude': position.latitude,
        'longitude': position.longitude,
      }
    });

    formData.files.add(
      MapEntry(
        'check_image',
        await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      ),
    );

    final request = FileUploadRequest(
      '/orders/close-order-check',
      formData: formData,
      secure: true,
    );
    return request.upload(dio);
  }

  Future<Response> setOrderClosePickup({
    required int orderId,
    required int status,
    required String filePath,
    required String orderSum,
    required String additionalPhone,
    required String customerName,
    required String customerStreet,
    required String customerBuilding,
    required String customerApartment,
    required String customerEntrance,
    required String customerFloor,
    required String techMark,
    required String techModel,
    required String techSerial,
    required String techBiosPassword,
    required String declaredDefect,
    required String masterComment,
    required bool isTechChargerChecked,
    required bool isTechVisualDefectsChecked,
    required bool isTechCracksChecked,
    required bool isTechIntegrityUsbChecked,
    required bool isTechAutopsyTracesChecked,
    required bool isTechFloodingMarksChecked,
    required bool isTechBatteryAvailabilityChecked,
    required bool isRushOrderChecked,
    Coords? position,
  }) async {
    final formData = FormData.fromMap({
      'token': ApiStorage().accessToken,
      'id': orderId.toString(),
      'status': status.toString(),
      'order_sum': orderSum.toString(),
      '_additionalPhone': additionalPhone,
      '_customerName': customerName,
      '_customerStreet': customerStreet,
      '_customerBuilding': customerBuilding,
      '_customerApartment': customerApartment,
      '_customerEntrance': customerEntrance,
      '_customerFloor': customerFloor,
      '_techMark': techMark,
      '_techModel': techModel,
      '_techSerial': techSerial,
      '_techBiosPassword': techBiosPassword,
      '_declaredDefect': declaredDefect,
      '_masterComment': masterComment,
      '_isTechChargerChecked': isTechChargerChecked.toString(),
      '_isTechVisualDefectsChecked': isTechVisualDefectsChecked.toString(),
      '_isTechCracksChecked': isTechCracksChecked.toString(),
      '_isTechIntegrityUsbChecked': isTechIntegrityUsbChecked.toString(),
      '_isTechAutopsyTracesChecked': isTechAutopsyTracesChecked.toString(),
      '_isTechFloodingMarksChecked': isTechFloodingMarksChecked.toString(),
      '_isTechBatteryAvailabilityChecked':
          isTechBatteryAvailabilityChecked.toString(),
      '_isRushOrderChecked': isRushOrderChecked.toString(),
      if (position != null) ...{
        'latitude': position.latitude,
        'longitude': position.longitude,
      }
    });

    if (filePath != 'null') {
      formData.files.add(
        MapEntry(
          'check_image',
          await MultipartFile.fromFile(
            filePath,
            filename: filePath.split('/').last,
          ),
        ),
      );
    }

    final request = FileUploadRequest(
      '/orders/close-order-pickup',
      formData: formData,
      secure: true,
    );
    return request.upload(dio);
  }

  Future updateOrderStatus(int orderId, int status) async {
    final data = await getAndroidPosition();

    final response = await GetRequest(
      '/orders/set-status',
      query: {
        'id': orderId.toString(),
        'status': status.toString(),
        'latitude': data.latitude.toString(),
        'longitude': data.longitude.toString(),
      },
      secure: true,
    ).getResponse(dio);

    return response;
  }

  Future setOrderEmail<T>(int orderId, String email) async {
    final request =
        await PostRequest('/order/set_order_email', secure: true, body: {
      'id': orderId,
      'email': email,
    }).callRequest(dio);
    if (T is AppOrder) {
      return AppOrder.fromJson(request);
    } else if (T is AppOrderV2) {
      return AppOrderV2.fromJson(request);
    }
  }

  Future<ServiceOrderDict> getServiceOrdersDictionary() async {
    final response = await const GetRequest(
      '/service-center-filter',
      secure: true,
    ).callRequest(dio);
    return ServiceOrderDict.fromJson(response);
  }

  Future<ServiceOrder> getServiceOrderById(int id) async {
    final result = await GetRequest('/service-center-orders/$id', secure: true)
        .callRequest(dio);
    return ServiceOrder.fromJson(result['data']);
  }

  Future<TabListResponse<ServiceOrderLite>> getServiceOrderMultiSelectList(
    int page,
    AppFilter filter,
  ) async {
    final query = filter.toQueryParams();
    final response = await GetRequest(
      '/service-center-orders',
      secure: true,
      query: {
        'page': page,
        'per_page': 10,
        ...query,
      },
    ).callRequest(dio);
    return TabListResponse(
      response['data'].asList().map(ServiceOrderLite.fromJson).toList(),
      response['meta']['total'].asInt(),
    );
  }

  Future<ServiceOrder> createServiceOrder(
    Map<String, dynamic> body,
  ) async {
    final response = await PostRequest(
      '/v2/service-center-orders',
      secure: true,
      body: body,
    ).callRequest(dio);
    return ServiceOrder.fromJson(response['data']);
  }

  Future<ServiceOrder> editServiceOrder(
    int id,
    Map<String, dynamic> body,
  ) async {
    final response = await PutRequest(
      '/v2/service-center-orders/$id',
      secure: true,
      body: body,
    ).callRequest(dio);
    return ServiceOrder.fromJson(response['data']);
  }

  Future<ServiceOrderDict> getServiceOrdersAvailableOptions(int? id) async {
    final response =
        await GetRequest('/service-center-options', secure: true, query: {
      if (id != null) 'id': id,
    }).callRequest(dio);
    return ServiceOrderDict.fromJson(response);
  }

  Future<bool> serviceOrderAddPhoto(
      {required int id,
      String? filePath,
      String? checkPath,
      List<String>? files}) async {
    final data = FormData();
    if (filePath?.isNotEmpty == true) {
      data.files.add(
        MapEntry(
          'photo_act_of_takeaway_technique',
          await MultipartFile.fromFile(
            filePath!,
            filename: filePath.split('/').last,
          ),
        ),
      );
    }
    if (checkPath?.isNotEmpty == true) {
      data.files.add(
        MapEntry(
          'check_photo',
          await MultipartFile.fromFile(
            checkPath!,
            filename: checkPath.split('/').last,
          ),
        ),
      );
    }
    if (files?.isNotEmpty == true) {
      final fileList = [
        for (final file in files!)
          MapEntry(
            'photos[]',
            await MultipartFile.fromFile(
              file,
              filename: file.split('/').last,
            ),
          ),
      ];
      data.files.addAll(fileList);
    }
    final request = FileUploadRequest(
      '/v2/service-center-photos/$id',
      formData: data,
      secure: true,
      sendTimeout: const Duration(seconds: 30),
    );
    final result = await request.upload(dio);
    return result.statusCode == 200;
  }

  Future<List<AppOrder>> getAvailableOrders(Coords position) async {
    final response =
        await GetRequest('/available-orders', secure: true, query: {
      'latitude': position.latitude,
      'longitude': position.longitude,
    }).callRequest(dio);

    return response['data'].asList().map(AppOrder.fromJson).toList();
  }

  Future<bool> additionalOrder({
    required AdditionalOrderData data,
  }) async {
    final response = await PostRequest(
      '/additional-order',
      secure: true,
      body: data.toJson(),
    ).getResponse(dio);

    return response.statusCode == 201;
  }
}
