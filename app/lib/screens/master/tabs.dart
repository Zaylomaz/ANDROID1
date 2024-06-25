part of 'masters_screen.dart';

/// Переопределение [AppTabView] под мастеров
class MastersTab extends AppTabView<AppMasterUser> {
  MastersTab({
    required super.filter,
    super.tabName,
  });

  factory MastersTab.fromMemory(JsonReader json) {
    final tab = MastersTab(
      filter: AppMasterUserFilter.fromJson(json['filter']),
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
      final response = await UsersRepository().getUsersList(page, filter);
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
}

/// Сохраненные вкладуи в памяти
final mastersTabs = JsonListPreference<MastersTab>(
  key: const PreferenceKey(
    module: 'master',
    component: 'list',
    name: 'filters_multiple',
  ),
  defaultValue: [
    MastersTab(
      filter: AppMasterUserFilter.empty,
      tabName: 'Все',
    )..total.value = 0,
    MastersTab(
      filter: AppMasterUserFilter.empty.copyWith(active: false),
      tabName: 'Не активные',
    )..total.value = 0,
  ],
  itemDecoder: (value) => MastersTab.fromMemory(
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

  final List<MastersTab> tabs;
  final AppMasterUserDict dictionary;
  final Function(List<MastersTab>) onChange;

  @override
  State<_FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<_FilterList> {
  List<MastersTab> tabs = [];

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
              contentPadding: EdgeInsets.zero,
              title: Observer(builder: (context) {
                return Text(
                  e.name.value,
                  style: const TextStyle(
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
              leading: AppIcons.edit.iconButton(
                splitColor: AppSplitColor.violet(),
                onPressed: () async {
                  try {
                    final newFilter = await Navigator.of(context).pushNamed(
                      MasterFilterScreen.routeName,
                      arguments: MasterFilterScreenArgs(
                        dict: widget.dictionary,
                        initFilter: e.filter as AppMasterUserFilter,
                        name: e.name.value,
                      ),
                    ) as AppMasterUserFilter?;
                    if (newFilter != null) {
                      tabs[tabs.indexOf(e)].filter = newFilter;
                      if (newFilter.name.isNotEmpty == true) {
                        runInAction(() {
                          tabs[tabs.indexOf(e)].name.value = newFilter.name;
                        });
                      }
                      widget.onChange(tabs);
                      setState(() {});
                    }
                  } catch (e, s) {
                    debugPrint(e.toString());
                    debugPrint(s.toString());
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
                      width: 16,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton.violet(
            onPressed: () async {
              final filter = await Navigator.of(context).pushNamed(
                MasterFilterScreen.routeName,
                arguments: MasterFilterScreenArgs(
                  dict: widget.dictionary,
                  name: 'Новая вкладка',
                ),
              ) as AppMasterUserFilter?;

              if (filter is AppMasterUserFilter &&
                  !filter.isEmpty &&
                  filter.name.isNotEmpty == true) {
                tabs.add(
                  MastersTab(
                    filter: filter,
                    tabName: filter.name,
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
