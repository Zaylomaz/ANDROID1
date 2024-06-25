import 'package:core/core.dart';
import 'package:rempc/model/kanban_page_model.dart';

mixin KanbanPagePresenter<T extends StatefulWidget> on State<StatefulWidget> {
  KanbanPageModel? _kanbanPageModel;

  KanbanPageModel? get kanbanPageModel => _kanbanPageModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshProvider();
    if (!(_kanbanPageModel?.isInited ?? true)) {
      _kanbanPageModel?.initData();
    }
  }

  void refreshProvider() {
    _kanbanPageModel = Provider.of<KanbanPageModel>(context);
  }
}
