part of 'applicant_screen.dart';

/// Переопределение [AppTabView] под соискателей
class ApplicantTab extends AppTabView<ApplicantData> {
  ApplicantTab({
    required super.filter,
    super.tabName,
  });

  factory ApplicantTab.fromMemory(JsonReader json) {
    final tab = ApplicantTab(
      filter: ApplicantFilter.fromJson(json['filter']),
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
      final response = await ApplicationRepository().getApplicantList(
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
}

/// Сохраненные вкладуи в памяти
final applicantTabs = JsonListPreference<ApplicantTab>(
  key: const PreferenceKey(
    module: 'applicant',
    component: 'list',
    name: 'filters_2',
  ),
  oldKey: const PreferenceKey(
    module: 'applicant',
    component: 'list',
    name: 'filters_1',
  ),
  defaultValue: [
    ApplicantTab(
      filter: ApplicantFilter.empty,
      tabName: 'Все',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 1),
      tabName: 'Не обработан',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 2),
      tabName: 'Отказ',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 3),
      tabName: 'Думает',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 4),
      tabName: 'Собеседование',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 5),
      tabName: 'Готов к стажировке',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 6),
      tabName: 'Стажировка',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 7),
      tabName: 'Готов к оформлению',
    )..total.value = 0,
    ApplicantTab(
      filter: ApplicantFilter.empty.copyWith(status: 8),
      tabName: 'Оформлен',
    )..total.value = 0,
  ],
  itemDecoder: (value) => ApplicantTab.fromMemory(
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

  final List<ApplicantTab> tabs;
  final ApplicantFilterOptions dictionary;
  final Function(List<ApplicantTab>) onChange;

  @override
  State<_FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<_FilterList> {
  List<ApplicantTab> tabs = [];

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
              title: Observer(
                builder: (context) => Text(
                  e.name.value,
                  style: const TextStyle(
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              leading: AppIcons.edit.iconButton(
                splitColor: AppSplitColor.violet(),
                onPressed: () async {
                  try {
                    final newFilter = await Navigator.of(context).pushNamed(
                      ApplicantFilterScreen.routeName,
                      arguments: ApplicantFilterScreenArgs(
                        dict: widget.dictionary,
                        initFilter: e.filter as ApplicantFilter,
                        name: e.name.value,
                      ),
                    ) as ApplicantFilter?;
                    if (newFilter != null) {
                      tabs[tabs.indexOf(e)].filter = newFilter;
                      if (newFilter.name?.isNotEmpty == true) {
                        runInAction(() {
                          tabs[tabs.indexOf(e)].name.value = newFilter.name!;
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
                ApplicantFilterScreen.routeName,
                arguments: ApplicantFilterScreenArgs(
                  dict: widget.dictionary,
                  name: 'Новая вкладка',
                ),
              ) as ApplicantFilter?;

              if (filter is ApplicantFilter &&
                  !filter.isEmpty &&
                  filter.name?.isNotEmpty == true) {
                tabs.add(
                  ApplicantTab(
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
