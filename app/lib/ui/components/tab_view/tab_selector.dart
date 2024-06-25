import 'dart:async';

import 'package:core/core.dart';
import 'package:preference/preference.dart';
import 'package:uikit/uikit.dart';

/// Контейнер с [TickerProvider] для создания и обновления [TabController]
class TabContainer extends StatefulWidget {
  const TabContainer({required this.child, required super.key});

  final Widget child;

  @override
  State<TabContainer> createState() => TabContainerState();
}

class TabContainerState extends State<TabContainer>
    with SingleTickerProviderStateMixin {
  TickerProvider get vsync => this;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Список вкладок на страницах
/// [ServiceOrderList]
/// [MasterScreen]
/// [ApplicantListScreen]
class TabSelector extends StatelessWidget {
  const TabSelector({
    required this.controller,
    required this.tabs,
    required this.tabsStream,
    this.fixedLength = false,
    super.key,
  });

  /// Список вкладок
  final List<AppTabView> tabs;

  /// Стрим кидает ивент если список вкладок изменился
  final Stream<List<AppTabView>> tabsStream;

  /// Контроллер
  final TabController? controller;

  /// Лейаут селектора
  /// устанавливает [isScrollable] и [TabAlignment]
  final bool fixedLength;

  @override
  Widget build(BuildContext context) {
    return tabs.isNotEmpty
        ? TabBar(
            controller: controller,
            isScrollable: !fixedLength,
            tabAlignment: fixedLength ? TabAlignment.fill : TabAlignment.start,
            splashFactory: Theme.of(context).tabBarTheme.splashFactory,
            dividerColor: Theme.of(context).tabBarTheme.dividerColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Theme.of(context).tabBarTheme.indicatorColor,
            labelStyle: AppTextStyle.regularSubHeadline.style(context),
            unselectedLabelStyle:
                AppTextStyle.regularSubHeadline.style(context),
            tabs: tabs
                .map((e) => Tab(
                      height: 24,
                      child: Text(e.name.value),
                    ))
                .toList(),
          )
        : const SizedBox.shrink();
  }
}

/// Разширение класса типичного [Store]
/// для экранов использующих лейаут [AppTabView]
mixin TabViewStateMixin<T> {
  late final TickerProvider vsync;

  /// Возвращает индекс текущей вкладки
  int stackIndex(BuildContext context) => tabController?.index ?? 0;

  /// Указание места сохренения табов
  JsonListPreference<T> get savedTabs;

  /// Табы
  List<T> get tabs;

  set tabs(List<T> tabs);

  /// Контроллер табов
  TabController? get tabController;

  set tabController(TabController? value);

  /// Инициализатор табов
  void initTabs(TickerProvider vsync) {
    this.vsync = vsync;
    tabs = savedTabs.value;
    tabController = TabController(length: tabs.length, vsync: vsync);
    tabs
        .where((e) => (e as AppTabView).initialized == false)
        .forEach((e) => (e as AppTabView).init());
    tabsSubscription = tabsSub.listen((value) {
      if (value.isNotEmpty) {
        savedTabs.value = value;
      }
    });
  }

  void onTabsChange(List<T> data) {
    tabs = data;
    tabsSub.add(data);
    tabs
        .where((e) => (e as AppTabView).initialized == false)
        .forEach((e) => (e as AppTabView).init());
    tabController = TabController(length: tabs.length, vsync: vsync)
      ..animateTo(tabs.length - 1);
  }

  /// Стрим изменений вносимых во вкладки
  final tabsSub = BehaviorSubject<List<T>>();

  /// Слушатель стрима
  late StreamSubscription<List<T>> tabsSubscription;

  /// Вызывается при смерти экрана [AppTabView]
  @mustCallSuper
  void dispose() {
    savedTabs.value = tabs;
    tabs
        .where((e) => (e as AppTabView).initialized)
        .forEach((e) => (e as AppTabView).dispose());
    tabsSub.close();
    tabsSubscription.cancel();
    tabController?.dispose();
  }
}
