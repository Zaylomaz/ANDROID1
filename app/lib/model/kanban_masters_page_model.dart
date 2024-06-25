import 'package:core/core.dart';
import 'package:rempc/provider/view_state_one_item_model.dart';
import 'package:repository/repository.dart';

/// TODO перестать использовать и удалить
class KanbanMastersPageModel extends ViewStateOneItemModel<KanbanMasterList> {
  KanbanMastersPageModel(this.orderId);
  final int orderId;

  @override
  Future<KanbanMasterList> loadData() async {
    final data = await KanbanRepository().kanbanMasterList(orderId);
    return data;
  }
}
