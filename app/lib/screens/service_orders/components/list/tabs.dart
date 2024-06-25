part of 'service_order_list.dart';

/// Переопределение [AppTabView] под заказы СЦ
class ServiceOrderTab extends AppTabView<ServiceOrderLite> {
  ServiceOrderTab({
    required super.filter,
    super.tabName,
  });

  factory ServiceOrderTab.fromMemory(JsonReader json) {
    final tab = ServiceOrderTab(
      filter: ServiceOrderFilter.fromJson(json['filter']),
      tabName: json['name'].asString(),
    );
    runInAction(() {
      tab.total.value = json['total'].asInt();
    });
    return tab;
  }

  @override
  Future<void> getData(int page) async {
    try {
      final response = await OrdersRepository().getServiceOrderMultiSelectList(
        page,
        filter,
      );
      if (response.data.length == 10) {
        pageController.appendPage(response.data, page + 1);
      } else {
        pageController.appendLastPage(response.data);
      }
      runInAction(() {
        total.value = response.total;
      });
    } catch (e, s) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, s));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'filter': filter.toJson(dateToMemory: true),
        ...super.toJson(),
      };
}

/// Сохраненные вкладуи в памяти
final serviceTabsMultiselect = JsonListPreference<ServiceOrderTab>(
  key: const PreferenceKey(
    module: 'service_order',
    component: 'list',
    name: 'filters_multiple',
  ),
  defaultValue: [
    ServiceOrderTab(
      filter: ServiceOrderFilter.empty,
      tabName: 'Главная',
    )..total.value = 0,
    ServiceOrderTab(
      filter: ServiceOrderFilter.empty.copyWith(status: [50]),
      tabName: 'Лид СЦ',
    )..total.value = 0,
  ],
  itemDecoder: (value) => ServiceOrderTab.fromMemory(
    JsonReader(value),
  ),
  itemEncoder: (tab) => tab.toJson(),
);

/// TODO сделать универсальный переиспользуемый виджет
class _FilterList extends StatefulWidget {
  const _FilterList({
    required this.tabs,
    required this.onChange,
    required this.dictionary,
  });

  final List<ServiceOrderTab> tabs;
  final ServiceOrderDict dictionary;
  final Function(List<ServiceOrderTab>) onChange;

  @override
  State<_FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<_FilterList> {
  List<ServiceOrderTab> tabs = [];

  @override
  void initState() {
    tabs = widget.tabs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FilterDialogWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...tabs.map(
            (e) => ListTile(
              title: Text(
                e.name.value,
                style: const TextStyle(
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leading: AppIcons.edit.iconButton(
                splitColor: AppSplitColor.violet(),
                onPressed: () async {
                  final newFilter = await Navigator.of(context).pushNamed(
                    ServiceOrderFilterScreen.routeName,
                    arguments: ServiceOrderFilterScreenArgs(
                      dictionary: widget.dictionary,
                      initFilters: e.filter as ServiceOrderFilter,
                      name: e.name.value,
                    ),
                  ) as ServiceOrderFilter?;
                  if (newFilter != null) {
                    tabs[tabs.indexOf(e)] = ServiceOrderTab(
                      filter: newFilter,
                      tabName: newFilter.name!,
                    );
                    widget.onChange(tabs);
                    setState(() {});
                  }
                },
              ),
              trailing: tabs.indexOf(e) > 0
                  ? AppIcons.trash.iconButton(
                      onPressed: () {
                        tabs.remove(e);
                        widget.onChange(tabs);
                        setState(() {});
                      },
                      splitColor: AppSplitColor.red(),
                    )
                  : null,
            ),
          ),
          PrimaryButton.violet(
            onPressed: () async {
              final filter = await Navigator.of(context).pushNamed(
                ServiceOrderFilterScreen.routeName,
                arguments: ServiceOrderFilterScreenArgs(
                  dictionary: widget.dictionary,
                  initFilters: ServiceOrderFilter.empty,
                  name: 'Новая вкладка',
                ),
              ) as ServiceOrderFilter?;

              if (filter is ServiceOrderFilter &&
                  !filter.isEmpty &&
                  filter.name?.isNotEmpty == true) {
                tabs.add(
                  ServiceOrderTab(
                    filter: filter,
                    tabName: filter.name!,
                  ),
                );
                widget.onChange(tabs);
                setState(() {});
              } else {
                debugPrint(filter.toString());
              }
            },
            text: 'Добавить вкладку',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
