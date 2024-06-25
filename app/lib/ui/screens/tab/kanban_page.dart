import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:rempc/model/kanban_page_model.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/provider/view_state_widget.dart';
import 'package:rempc/screens/master/masters_screen.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:rempc/ui/components/kanban_list_item.dart';
import 'package:rempc/ui/presenter/kanban_page_presenter.dart';
import 'package:uikit/uikit.dart';

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key});

  static const String routeName = '/kanban';

  @override
  KanbanPageState createState() => KanbanPageState();
}

class KanbanPageState extends State<KanbanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        actions: context.read<HomeData>().permissions.canSeeMasterButton
            ? [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(MasterScreen.routeName);
                  },
                  child: Container(
                    color: Colors.black26,
                    padding: const EdgeInsets.only(
                      left: 13,
                      right: 13,
                      top: 6,
                      bottom: 6,
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.people_outline_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Мастера',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]
            : null,
        title: const Text('Координирование'),
      ),
      body: _buildKanbanPage(),
      drawer: const AppBarDrawer(),
    );
  }

  Widget _buildKanbanPage() {
    return ChangeNotifierProvider<KanbanPageModel>(
        create: (_) => KanbanPageModel(), child: _KanbanDataPage());
  }
}

class _KanbanDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _KanbanDataPageState();
}

class _KanbanDataPageState extends State<StatefulWidget>
    with KanbanPagePresenter {
  TextEditingController dateTimeFilterController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'ru_RU';
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    dateTimeFilterController.text = kanbanPageModel!.dateFilterApi!;

    if (kanbanPageModel!.busy) {
      body = Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 32),
            alignment: Alignment.center,
            child: const AppLoadingIndicator(),
          )
        ],
      );
    } else if (kanbanPageModel!.error && kanbanPageModel?.stateData == null) {
      body = ViewStateErrorWidget(
          error: kanbanPageModel!.viewStateError!,
          onPressed: kanbanPageModel!.initData);
    } else if (kanbanPageModel!.empty) {
      body = ViewStateEmptyWidget(onPressed: kanbanPageModel?.initData);
    } else if (kanbanPageModel!.empty) {
      body = Container();
    } else {
      body = _getCustomScrollView();
    }

    return Scaffold(
      body: body,
    );
  }

  Widget _getCustomScrollView() {
    return RefreshIndicator(
      onRefresh: () async {
        await kanbanPageModel!.refresh();
      },
      child: CustomScrollView(
        slivers: <Widget>[
          if (kanbanPageModel?.stateData?.isDisplayDateFilter == true) ...[
            SliverToBoxAdapter(child: _dateFilter()),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 16,
              ),
            ),
          ],
          ..._getAllSubLists(),
        ],
      ),
    );
  }

  Iterable<Widget> _getAllSubLists() {
    if (kanbanPageModel?.stateData?.cities.isNotEmpty == true) {
      return kanbanPageModel!.stateData!.data
          .map((key, value) => MapEntry(key, _getSublistSliver(key, value)))
          .values
          .expand((e) => e);
    }
    return [
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Text(
            'Пусто',
            style: AppTextStyle.regularHeadline.style(context),
          ),
        ),
      ),
    ];
  }

  Widget _dateFilter() {
    return Container(
      color: AppColors.blackContainer,
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RotatedBox(
            quarterTurns: 1,
            child: AppIcons.chevron.iconButton(
              color: AppColors.violet,
              onPressed: () => kanbanPageModel?.subFilterDay(),
            ),
          ),
          Expanded(
            child: Theme(
              data: ThemeData.dark(
                useMaterial3: true,
              ),
              child: DateTimePicker(
                controller: dateTimeFilterController,
                style: AppTextStyle.boldHeadLine.style(context),
                textAlign: TextAlign.center,
                dateMask: 'dd.MM.yyyy',
                locale: const Locale.fromSubtags(languageCode: 'ru'),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                validator: (val) {
                  return null;
                },
                onChanged: (value) {
                  kanbanPageModel?.dateFilter = DateTime.parse(value);
                },
                onSaved: (value) {
                  setState(() {
                    kanbanPageModel?.dateFilter =
                        value == null ? DateTime.now() : DateTime.parse(value);
                  });
                },
              ),
            ),
          ),
          RotatedBox(
            quarterTurns: 3,
            child: AppIcons.chevron.iconButton(
              color: AppColors.violet,
              onPressed: () => kanbanPageModel?.addFilterDay(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getSublistSliver(KanbanCity city, List<KanbanOrder> orders) {
    return [
      SliverToBoxAdapter(
        child: _getSublistTitle(city, orders.length),
      ),
      if (orders.isNotEmpty == true)
        for (final order in orders)
          SliverToBoxAdapter(
            child: KanbanListItem(
              order,
              key: ValueKey('${city.id}_${order.id}'),
              isVisible: city.isOpened,
              attachMaster: (value) => _attachMaster(context, value),
              updateOrder: updateOrder,
              detachMaster: (value) => _detachMaster(context, value),
              phoneCall: _phoneCall,
            ),
          ),
    ];
  }

  Widget _getSublistTitle(KanbanCity item, int count) {
    if (item.name?.isEmpty != false) {
      return const SizedBox(
        height: 16,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            item.isOpened = !item.isOpened;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Text(
                '${item.name} ($count)',
                style: AppTextStyle.boldHeadLine.style(context),
              ),
              const Spacer(),
              RotatedBox(
                quarterTurns: item.isOpened ? 0 : 2,
                child: AppIcons.chevron.widget(
                  color: AppColors.violet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateOrder(KanbanOrderEdit? orderEdit) async {
    if (orderEdit == null) {
      await kanbanPageModel!.refresh();
      return;
    }

    kanbanPageModel!.refreshOrder(orderEdit);
  }

  Future<void> _attachMaster(
    BuildContext context,
    Map<String, dynamic> result,
  ) async {
    try {
      await kanbanPageModel!
          .attachMaster(result['orderId'], result['masterId']);
      await withLoadingIndicator(() async {
        await kanbanPageModel?.refresh();
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Заказ не найден',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _detachMaster(BuildContext context, int orderId) async {
    try {
      await kanbanPageModel!.detachMaster(orderId);
      await withLoadingIndicator(() async {
        await kanbanPageModel?.refresh();
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Заказ не найден',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _phoneCall(int orderId) async {
    final status = await kanbanPageModel!.callOrder(orderId);
    if (!status) {
      unawaited(_showPhoneCallError());
    }
  }

  Future<void> _showPhoneCallError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Ошибка звонка'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Не удалось совершить вызов'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ок'),
              onPressed: () async {
                Navigator.pop(context, 'Canceled');
              },
            ),
          ],
        );
      },
    );
  }
}
