import 'package:rempc/provider/view_state_model.dart';

/// TODO перестать использовать и удалить
@Deprecated('Перестать использовать и удалить')
abstract class ViewStateOneItemModel<T> extends ViewStateModel {
  bool _isInited = false;
  bool get isInited => _isInited;

  T? stateData;

  Future<void> initData() async {
    _isInited = true;
    setBusy();
    await refresh(init: true);
  }

  Future<void> refresh({bool init = false}) async {
    try {
      final data = await loadData();
      if (data == null) {
        stateData = null;
        setEmpty();
      } else {
        onCompleted(data);
        stateData = data;
        setIdle();
      }
    } catch (e, s) {
      if (init) stateData = null;
      setError(e, s);
    }
  }

  Future<T> loadData();

  void onCompleted(T data) {}
}
