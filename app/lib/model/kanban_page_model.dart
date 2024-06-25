import 'dart:async';

import 'package:core/core.dart';
import 'package:rempc/provider/view_state.dart';
import 'package:rempc/provider/view_state_one_item_model.dart';
import 'package:repository/repository.dart';

/// TODO перестать использовать и удалить
class KanbanPageModel extends ViewStateOneItemModel<KanbanPageData> {
  KanbanPageModel();
  DateTime _dateFilter = DateTime.now();

  String? get dateFilterApi => DateFormat('yyyy-MM-dd').format(_dateFilter);

  String? get dateFilterFormatted =>
      DateFormat('dd.MM.yyyy').format(_dateFilter);

  DateTime get dateFilter => _dateFilter;

  set dateFilter(DateTime dateFilter) {
    if (viewState == ViewState.busy) {
      return;
    }
    _dateFilter = dateFilter;
    notifyListeners();
    debugPrint('date: $dateFilterFormatted');
    setBusy();
    refresh();
  }

  void addFilterDay() {
    dateFilter = _dateFilter.add(const Duration(days: 1));
  }

  void subFilterDay() {
    dateFilter = _dateFilter.subtract(const Duration(days: 1));
  }

  @override
  Future<KanbanPageData> loadData() async {
    final data = await KanbanRepository().kanbanList(date: dateFilterApi);
    return data;
  }

  void refreshOrder(KanbanOrderEdit orderEdit) {
    final order =
        stateData!.orders.where((element) => element.id == orderEdit.id).first;
    final index =
        stateData!.orders.indexWhere((element) => element.id == orderEdit.id);

    if (dateFilter != orderEdit.date) {
      stateData!.orders.removeAt(index);
      notifyListeners();
      return;
    }

    order
      ..defect = orderEdit.defect
      ..time = orderEdit.time;

    ///TODO use [StatusBadge]
    // order.statusBadge?.text = orderEdit.availableStatuses
    //     .where((it) => it.id == orderEdit.status)
    //     .first
    //     .value;
    if (orderEdit.masterId != null) {
      final name = orderEdit.masters
          .where((it) => it.id == orderEdit.masterId)
          .first
          .name;
      if (order.master.hasData) {
        order.master = KanbanMaster(
          id: orderEdit.masterId,
          name: name,
          number: 0,
        );
      } else {
        order.master = order.master.copyWith(
          id: orderEdit.masterId!,
          name: name,
        );
      }
    } else {
      order.master = KanbanMaster.empty;
    }

    order.isLoading = false;

    stateData?.orders.replaceRange(index, index + 1, [order]);
    notifyListeners();
  }

  Future<void> attachMaster(int orderId, int masterId) async {
    final order =
        stateData?.orders.where((element) => element.id == orderId).first;
    order?.isLoading = true;
    notifyListeners();

    final updatedOrder = await KanbanRepository().kanbanAttachMaster(
      orderId,
      masterId,
    );
    final index = stateData?.orders
        .indexWhere((element) => element.id == updatedOrder.id);
    if (index != null) {
      stateData?.orders.replaceRange(index, index + 1, [updatedOrder]);
      notifyListeners();
    } else {
      setBusy();
      unawaited(refresh());
    }
  }

  Future<void> detachMaster(int orderId) async {
    final order =
        stateData?.orders.where((element) => element.id == orderId).first;
    order?.isLoading = true;
    notifyListeners();

    final updatedOrder = await KanbanRepository().kanbanDetachMaster(orderId);
    final index = stateData?.orders
        .indexWhere((element) => element.id == updatedOrder.id);
    if (index != null) {
      stateData?.orders.replaceRange(index, index + 1, [updatedOrder]);
      notifyListeners();
    } else {
      setBusy();
      unawaited(refresh());
    }
  }

  Future<bool> callOrder(int orderId) async {
    final order =
        stateData?.orders.where((element) => element.id == orderId).first;
    order?.isPhoneCalling = true;
    notifyListeners();

    try {
      final data = await KanbanRepository().kanbanOrderCall(orderId);
      order?.isPhoneCalling = false;
      notifyListeners();
      return data['status'] ?? data['data']?['status'] ?? false;
    } catch (e) {
      order?.isPhoneCalling = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void onCompleted(KanbanPageData data) {
    notifyListeners();
    return super.onCompleted(data);
  }
}
