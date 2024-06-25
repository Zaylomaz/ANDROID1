part of 'calls_screen.dart';

class CallsTab extends AppTabView<AppPhoneCall> {
  CallsTab({
    required super.filter,
    super.tabName,
  });

  factory CallsTab.fromMemory(JsonReader json) {
    final tab = CallsTab(
      filter: AppPhoneCallFilter.fromJson(json['filter']),
      tabName: json['name'].asString(),
    );
    tab.total.value = json['total'].asInt();
    return tab;
  }

  @override
  Future<void> getData(int page) async {
    final repo = PhoneCallsRepository();
    try {
      final response = await repo.getCallHistory(page, filter);
      if (response.data.length == 10) {
        pageController.appendPage(response.data, page + 1);
      } else {
        //TODO ТУТ ВЫБИТВАЕТ ОШИБКУ
        pageController.appendLastPage(response.data);
      }
      runInAction(() {
        total.value = response.total;
      });
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }
}

final callsTabs = JsonListPreference<CallsTab>(
  key: const PreferenceKey(
    module: 'calls',
    component: 'list',
    name: 'filters_multiple_1',
  ),
  defaultValue: [
    CallsTab(
      filter: AppPhoneCallFilter.empty,
      tabName: 'Все',
    )..total.value = 0,
    CallsTab(
      filter:
          AppPhoneCallFilter.empty.copyWith(type: AppPhoneCallType.incoming),
      tabName: 'Входящие',
    )..total.value = 0,
    CallsTab(
      filter:
          AppPhoneCallFilter.empty.copyWith(type: AppPhoneCallType.outgoing),
      tabName: 'Исходящие',
    )..total.value = 0,
    CallsTab(
      filter: AppPhoneCallFilter.empty.copyWith(type: AppPhoneCallType.lost),
      tabName: 'Пропущенные',
    )..total.value = 0,
    CallsTab(
      filter: AppPhoneCallFilter.empty.copyWith(type: AppPhoneCallType.waisted),
      tabName: 'Потерянные',
    )..total.value = 0,
  ],
  itemDecoder: (value) => CallsTab.fromMemory(
    JsonReader(value),
  ),
  itemEncoder: (tab) => tab.toJson(),
);

class _FilterList extends StatefulWidget {
  const _FilterList({
    required this.tabs,
    required this.onChange,
    required this.dictionary,
  });

  final List<CallsTab> tabs;
  final AppMasterUserDict dictionary;
  final Function(List<CallsTab>) onChange;

  @override
  State<_FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<_FilterList> {
  List<CallsTab> tabs = [];

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
                      CallFilterScreen.routeName,
                      arguments: CallFilterScreenArgs(
                        // dict: widget.dictionary,
                        filter: e.filter as AppPhoneCallFilter,
                        tabName: e.name.value,
                      ),
                    ) as AppPhoneCallFilter?;
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
                CallFilterScreen.routeName,
                arguments: const CallFilterScreenArgs(
                  filter: AppPhoneCallFilter.empty,
                  tabName: 'Новая вкладка',
                ),
              ) as AppPhoneCallFilter?;

              if (filter is AppPhoneCallFilter &&
                  !filter.isEmpty &&
                  filter.tabName?.isNotEmpty == true) {
                tabs.add(
                  CallsTab(
                    filter: filter,
                    tabName: filter.tabName,
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
