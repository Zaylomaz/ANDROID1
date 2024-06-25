import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:rempc/provider/view_state_one_item_model.dart';
import 'package:repository/repository.dart';

/// TODO перестать использовать и удалить
class KanbanOrderPageModel extends ViewStateOneItemModel<KanbanOrderEdit> {
  KanbanOrderPageModel(this.orderId);

  int orderId;
  String? errorText;

  String? get selectedMaster => stateData?.masterId != null
      ? stateData!.masters
          .where((it) => it.id == stateData?.masterId)
          .first
          .name
      : null;

  @override
  Future<KanbanOrderEdit> loadData() async {
    final data = await KanbanRepository().kanbanOrder(orderId);
    return data;
  }

  void setCheckImage(String? path) {
    if (path == null) {
      return;
    }

    stateData = stateData!.copyWith(checkPhoto: path);
    notifyListeners();
  }

  void removeCheckImage() {
    stateData = stateData!.copyWith(checkPhoto: '');
    notifyListeners();
  }

  void setActOfTakeawayImage(String? path) {
    if (path == null) {
      return;
    }

    stateData = stateData!.copyWith(photoActOfTakeawayTechnique: path);
    notifyListeners();
  }

  void removeActOfTakeawayImage() {
    stateData = stateData!.copyWith(photoActOfTakeawayTechnique: '');
    notifyListeners();
  }

  Future<KanbanOrderEdit?> saveOrder() async {
    errorText = null;
    stateData = stateData!.copyWith(isLoading: true);
    notifyListeners();
    try {
      final result = await KanbanRepository().kanbanUpdateOrder(stateData!);
      if (result.containsKey('success') &&
          result['success'] == false &&
          result.containsKey('data')) {
        final errors =
            Map.castFrom<dynamic, dynamic, String, dynamic>(result['data']);
        errorText = '';
        errors.forEach((key, value) {
          value.forEach((error) {
            if (null != error && error is String) {
              errorText = '${errorText!}$error\n';
            }
          });
        });
        errorText = errorText!.trim();
        stateData = stateData!.copyWith(isLoading: false);
        notifyListeners();

        return null;
      }
      return KanbanOrderEdit.fromJson(JsonReader(result['data']));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        errorText = 'Повторите попытку позже';
        stateData = stateData!.copyWith(isLoading: false);
        notifyListeners();
      } else {
        errorText = 'Ошибка';
        stateData = stateData!.copyWith(isLoading: false);
        notifyListeners();
      }
    }

    return null;
  }
}
