import 'package:api/api.dart';
import 'package:core/core.dart';

class KanbanRepository extends AppRepository {
  factory KanbanRepository() {
    return _singleton;
  }

  KanbanRepository._internal();

  static final KanbanRepository _singleton = KanbanRepository._internal();

  Future<KanbanPageData> kanbanList({String? date}) async {
    final response = await GetRequest(
      '/kanban',
      query: {
        if (date?.isNotEmpty == true) 'date': date,
      },
      secure: true,
    ).callRequest(dio);

    return KanbanPageData.fromJson(response);
  }

  Future<KanbanMasterList> kanbanMasterList(int orderId) async {
    final response = await GetRequest(
      '/kanban/available-masters',
      query: {
        'order_id': orderId,
      },
      secure: true,
    ).callRequest(dio);

    return KanbanMasterList.fromJson(response);
  }

  Future<KanbanOrder> kanbanAttachMaster(int orderId, int masterId) async {
    final response = await GetRequest(
      '/kanban/make-out',
      query: {
        'order_id': orderId,
        'user_id': masterId,
      },
      secure: true,
    ).callRequest(dio);

    return KanbanOrder.fromJson(response);
  }

  Future<KanbanOrder> kanbanDetachMaster(int orderId) async {
    final response = await GetRequest(
      '/kanban/remove_master',
      query: {
        'order_id': orderId,
      },
      secure: true,
    ).callRequest(dio);

    return KanbanOrder.fromJson(response);
  }

  Future<KanbanOrderEdit> kanbanOrder(int orderId) async {
    final response = await GetRequest(
      '/orders/$orderId/edit',
      secure: true,
    ).callRequest(dio);

    return KanbanOrderEdit.fromJson(response['data']);
  }

  Future kanbanOrderCall(int orderId) async {
    final response = await GetRequest(
      '/order/call',
      query: {
        'order_id': orderId,
      },
      secure: true,
    ).getResponse(dio);

    return response.data;
  }

  Future kanbanUpdateOrder(KanbanOrderEdit order) async {
    final formData = FormData.fromMap({
      'defect': order.defect,
      'info_for_master_prevent': order.infoForMasterPrevent,
      'date': DateFormat('yyyy-MM-dd').format(order.date),
      'time': order.time,
      'master_id': order.masterId,
      'status': order.status,
      'order_sum': order.orderSum,
    });

    if (order.checkPhoto.startsWith('/')) {
      formData.files.add(MapEntry(
          'check_photo',
          await MultipartFile.fromFile(order.checkPhoto,
              filename: order.checkPhoto.split('/').last)));
    }

    if (order.photoActOfTakeawayTechnique.startsWith('/')) {
      formData.files.add(
        MapEntry(
          'photo_act_of_takeaway_technique',
          await MultipartFile.fromFile(
            order.photoActOfTakeawayTechnique,
            filename: order.photoActOfTakeawayTechnique.split('/').last,
          ),
        ),
      );
    }

    final response = await FileUploadRequest(
      'orders/${order.id}/update',
      formData: formData,
      secure: true,
    ).upload(dio);

    return response.data;
  }

  Future<bool> canCall(int orderId) async {
    final canCall = await GetRequest('call/can_call', secure: true, query: {
      'page': 'kanban',
      'order_id': orderId,
    }).callRequest(dio);
    return canCall['status'].asBool();
  }
}
