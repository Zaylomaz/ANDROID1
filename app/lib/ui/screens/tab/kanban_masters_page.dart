import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/model/kanban_masters_page_model.dart';
import 'package:rempc/provider/view_state_widget.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/ui/screens/tab/kanban_page.dart';
import 'package:uikit/uikit.dart';

class KanbanPageRouter extends OldPageRouterAbstract {
  const KanbanPageRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => KanbanPage.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.kanbanNavigatorKey];
}

class KanbanMastersPage extends StatefulWidget {
  const KanbanMastersPage(this.arguments, {super.key});

  static const String routeName = '/kanban_masters';

  final Map<String, int> arguments;

  @override
  KanbanMastersPageState createState() => KanbanMastersPageState();
}

class KanbanMastersPageState extends State<KanbanMastersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Мастера'),
      ),
      body: _buildKanbanPage(),
    );
  }

  Widget _buildKanbanPage() {
    return ChangeNotifierProvider<KanbanMastersPageModel>(
        create: (_) => KanbanMastersPageModel(widget.arguments['orderId']!),
        child: _KanbanMastersPage(widget.arguments['orderId']));
  }
}

enum _KanbanMastersPageTableColumns {
  name,
  distance,
  specs,
}

extension _KanbanMastersPageTableColumnsExt on _KanbanMastersPageTableColumns {
  String get title {
    switch (this) {
      case _KanbanMastersPageTableColumns.name:
        return 'Имя';
      case _KanbanMastersPageTableColumns.distance:
        return 'Расстояние';
      case _KanbanMastersPageTableColumns.specs:
        return 'Специализация';
    }
  }
}

class _KanbanMastersPage extends StatefulWidget {
  const _KanbanMastersPage(this.orderId);

  final int? orderId;

  @override
  _KanbanMasterPageState createState() => _KanbanMasterPageState();
}

class _KanbanMasterPageState extends State<_KanbanMastersPage> {
  KanbanMastersPageModel? _kanbanMastersPageModel;

  KanbanMastersPageModel? get kanbanMastersPageModel => _kanbanMastersPageModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshProvider();
    if (!(_kanbanMastersPageModel?.isInited ?? true)) {
      _kanbanMastersPageModel?.initData();
    }
  }

  void refreshProvider() {
    _kanbanMastersPageModel = Provider.of<KanbanMastersPageModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (kanbanMastersPageModel!.busy) {
      body = const Center(child: AppLoadingIndicator());
    } else if (kanbanMastersPageModel!.error &&
        kanbanMastersPageModel?.stateData == null) {
      body = ViewStateErrorWidget(
          error: kanbanMastersPageModel!.viewStateError!,
          onPressed: kanbanMastersPageModel!.initData);
    } else if (kanbanMastersPageModel!.empty) {
      body = ViewStateEmptyWidget(onPressed: kanbanMastersPageModel?.initData);
    } else if (kanbanMastersPageModel!.empty) {
      body = Container();
    } else {
      body = SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _getTable(),
        ),
      );
    }

    return Scaffold(
      body: body,
    );
  }

  Widget _getTable() {
    return Table(
      defaultColumnWidth: const FractionColumnWidth(1 / 3),
      border: TableBorder.all(
        color: AppColors.grayText,
      ),
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: AppColors.blackContainer,
          ),
          children: _KanbanMastersPageTableColumns.values
              .map((e) => TableCell(
                    child: Container(
                      padding: const EdgeInsets.only(left: 6),
                      alignment: Alignment.centerLeft,
                      height: 30,
                      child: Text(
                        e.title,
                        style: AppTextStyle.regularSubHeadline.style(context),
                      ),
                    ),
                  ))
              .toList(),
        ),
        ...kanbanMastersPageModel?.stateData?.masters
                .where((it) => it.isAvailable)
                .map(_getTableRows)
                .toList() ??
            []
      ],
    );
  }

  TableRow _getTableRows(KanbanMasterItem master) {
    return TableRow(children: [
      TableCell(
        child: _getMasterRow(
          Text(
            master.name,
            style: AppTextStyle.regularSubHeadline.style(context),
          ),
          master,
        ),
      ),
      TableCell(
        child: _getMasterRow(
          Text(
            master.distance,
            style: AppTextStyle.regularSubHeadline.style(context),
          ),
          master,
        ),
      ),
      TableCell(
        child: _getMasterRow(
            Column(
              children: [
                ...master.specializations.map<Widget>(
                  (it) => Container(
                    alignment: Alignment.center,
                    color: it.color,
                    child: Text(
                      it.title,
                      style: AppTextStyle.regularSubHeadline.style(
                        context,
                        AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            master),
      ),
    ]);
  }

  Widget _getMasterRow(Widget child, KanbanMasterItem master) {
    return GestureDetector(
      onTap: () async {
        final result = await _showSelectMasterDialog(master);
        if (result != null) {
          Navigator.of(context).pop(result);
        }
      },
      child: Container(
        color: master.color.color,
        padding: const EdgeInsets.all(4),
        child: child,
      ),
    );
  }

  Future<Map<String, dynamic>?> _showSelectMasterDialog(
      KanbanMasterItem master) async {
    return showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Подтверждение'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Назначить ${master.name} на заказ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Назначить'),
              onPressed: () async {
                Navigator.of(context).pop({
                  'masterId': master.id,
                  'orderId': widget.orderId,
                });
              },
            ),
            TextButton(
              child: const Text('Отмена'),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
