import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';
import 'package:rempc/screens/applicant/details/applicant_details_screen.dart';
import 'package:rempc/screens/applicant/filter/applicant_filter.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:rempc/ui/components/filter_list.dart';
import 'package:rempc/ui/components/tab_view/tab_selector.dart';
import 'package:rempc/ui/components/tab_view/tab_view_model.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'applicant_screen.g.dart';
part 'tabs.dart';

class _State extends _StateStore with _$_State {
  _State(super.sipModel, super.vsync);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store, TabViewStateMixin<ApplicantTab> {
  _StateStore(this.sipModel, TickerProvider vsync) {
    init(vsync);
    isSipActive = sipModel.isActive;
    sipModel.addListener(_sipListener);
  }

  final SipModel sipModel;
  final repo = ApplicationRepository();

  @observable
  TabController? _tabController;

  @override
  @computed
  TabController? get tabController => _tabController;

  @override
  @protected
  set tabController(TabController? value) => _tabController = value;

  @observable
  List<ApplicantTab> _tabs = [];

  @override
  @computed
  List<ApplicantTab> get tabs => _tabs;

  @override
  @protected
  set tabs(List<ApplicantTab> value) => _tabs = value;

  @computed
  IconData get filterIcon => filter.isEmpty ? Icons.search : Icons.saved_search;

  @computed
  Color get filterColor =>
      filter.isEmpty ? Colors.white : const Color(0xffFFAC18);

  @observable
  ApplicantFilter _filter = ApplicantFilter.empty;

  @computed
  ApplicantFilter get filter => _filter;

  @protected
  set filter(ApplicantFilter value) => _filter = value;

  @observable
  ApplicantFilterOptions? _dict;

  @computed
  ApplicantFilterOptions? get dict => _dict;

  @protected
  set dict(ApplicantFilterOptions? value) => _dict = value;

  @observable
  bool _isSipActive = false;

  @computed
  bool get isSipActive => _isSipActive;

  @protected
  set isSipActive(bool value) => _isSipActive = value;

  @observable
  bool _isPhoneCalling = false;

  @computed
  bool get isPhoneCalling => _isPhoneCalling;

  @protected
  set isPhoneCalling(bool value) => _isPhoneCalling = value;

  @override
  JsonListPreference<ApplicantTab> get savedTabs => applicantTabs;

  @action
  Future<void> init(TickerProvider vsync) async {
    try {
      initTabs(vsync);
      dict = await repo.getDict();
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  void showPhoneCallError(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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

  @action
  Future<void> refresh(BuildContext context) async {
    tabs[stackIndex(context)].refresh();
    dict = await repo.getDict();
  }

  @action
  Future<ApplicantFilter> showFilter(BuildContext context) async {
    final update =
        await Navigator.of(context).pushNamed(ApplicantFilterScreen.routeName,
            arguments: ApplicantFilterScreenArgs(
              dict: dict!,
              initFilter: tabs[stackIndex(context)].filter as ApplicantFilter,
            )) as ApplicantFilter?;
    if (update != null) {
      final hasUpdate = update != tabs[stackIndex(context)].filter;
      if (hasUpdate) {
        tabs[stackIndex(context)].filter = update;
        tabs[stackIndex(context)].refresh();
      }
    }
    return filter;
  }

  @action
  Future<void> getToWork(BuildContext context, ApplicantData data) async {
    final data0 = await repo.getToWork(data.id);
    tabs[stackIndex(context)].pageController.itemList =
        tabs[stackIndex(context)]
            .pageController
            .itemList
            ?.map((e) => e.id == data.id ? data0 : e)
            .toList();
  }

  @action
  void _sipListener() {
    isSipActive = sipModel.isActive;
  }

  @action
  Future<void> editTabs(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => _FilterList(
        tabs: tabs,
        onChange: onTabsChange,
        dictionary: dict!,
      ),
    );
  }

  @override
  void dispose() {
    sipModel.removeListener(_sipListener);
    super.dispose();
  }
}

class ApplicantListScreen extends StatelessWidget implements AppTabViewScreen {
  ApplicantListScreen({super.key});

  static const String routeName = '/applicant_screen';

  @override
  String get route => routeName;

  @override
  String get filterRoute => ApplicantFilterScreen.routeName;

  @override
  String get detailsRoute => ApplicantDetailsScreen.routeName;
  @override
  final tickerKey = GlobalKey<TabContainerState>();

  @override
  Widget build(BuildContext context) {
    return TabContainer(
      key: tickerKey,
      child: Provider<_State>(
        create: (ctx) => _State(
          Provider.of<SipModel>(context, listen: false),
          tickerKey.currentState!.vsync,
        ),
        builder: (ctx, child) => const _Content(),
        dispose: (ctx, state) => state.dispose(),
      ),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: const Text('Соискатели'),
        actions: [
          AppIcons.edit.fabButton(
            onPressed: () => _State.of(context).editTabs(context),
          )
        ],
      ),
      drawer: Navigator.maybeOf(context)?.canPop() == true
          ? null
          : const AppBarDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabSelector(
            tabs: _State.of(context).tabs,
            tabsStream: _State.of(context).tabsSub,
            controller: _State.of(context).tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: _State.of(context).tabController,
              children: [..._State.of(context).tabs.map(_Tab.new)],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.tab, {super.key});

  final ApplicantTab tab;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      controller: tab.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Observer(builder: (context) {
                    return Text(
                      '${tab.name.value} (${tab.total.value})',
                      style: AppTextStyle.boldHeadLine.style(context),
                    );
                  })),
                  AppIcons.filter.fabButton(
                    onPressed: () => _State.of(context).showFilter(context),
                  ),
                ],
              ),
            ),
          )
        ];
      },
      body: RefreshIndicator(
        onRefresh: () => _State.of(context).refresh(context),
        child: PagedListView<int, ApplicantData>.separated(
          pagingController: tab.pageController,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          builderDelegate: PagedChildBuilderDelegate<ApplicantData>(
            itemBuilder: (context, item, index) => _Item(
              item,
              key: ValueKey<String>('${item.id}_$index'),
            ),
            firstPageErrorIndicatorBuilder: (context) {
              return const Center(
                child: Text(
                  'First page error',
                ),
              );
            },
            noItemsFoundIndicatorBuilder: noItemsInListBuilder(context),
            newPageErrorIndicatorBuilder: (context) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Loading error',
                  ),
                ),
              );
            },
            firstPageProgressIndicatorBuilder: (context) {
              return const Center(
                child: AppLoadingIndicator(),
              );
            },
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.data, {super.key});

  final ApplicantData data;

  @override
  Widget build(BuildContext context) {
    return AppMaterialBox(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd.MM.yyyy HH:mm', 'ru').format(data.createdAt),
              style: AppTextStyle.regularSubHeadline.style(context),
            ),
            const SizedBox(height: 16),
            IconWithTextRow(
              leading: AppIcons.energy.iconColored(
                color: AppSplitColor.custom(
                  primary: data.statusBadge.color,
                  secondary: data.statusBadge.color.withOpacity(.2),
                ),
                iconSize: 16,
              ),
              text: data.statusBadge.text,
              textColor: data.statusBadge.color,
            ),
            const SizedBox(height: 8),
            if (data.clientName.isNotEmpty && data.status != -1) ...[
              IconWithTextRow(
                leading: AppIcons.users.iconColored(
                  color: AppSplitColor.cyan(),
                  iconSize: 12,
                ),
                text:
                    '''${data.clientName} ${data.age.isNotEmpty ? '(${data.age})' : ''}''',
              ),
              const SizedBox(height: 8),
            ],
            IconWithTextRow(
              leading: AppIcons.city.iconColored(
                color: AppSplitColor.violet(),
                iconSize: 12,
              ),
              text: _State.of(context).dict?.cities[data.cityId] ??
                  data.cityId.toString(),
            ),
            const SizedBox(height: 8),
            if (data.status != -1) ...[
              IconWithTextRow(
                leading: AppIcons.smart.iconColored(
                  color: AppSplitColor.violet(),
                  iconSize: 16,
                ),
                text: data.smartphone ? 'В наличии' : 'Нет в наличии',
              ),
              const SizedBox(height: 8),
            ],
            IconWithTextRow(
              leading: AppIcons.work.iconColored(
                color: AppSplitColor.violet(),
                iconSize: 12,
              ),
              text: data.jobVacancyText,
            ),
            const SizedBox(height: 8),
            IconWithTextRow(
              leading: AppIcons.pin.iconColored(
                color: AppSplitColor.violet(),
                iconSize: 16,
              ),
              text: data.specificationText,
            ),
            const SizedBox(height: 8),
            if ((data.interviewDateIsEmpty == false ||
                    data.interviewDate != null) &&
                data.status != -1) ...[
              IconWithTextRow(
                leading: AppIcons.calendar.iconColored(
                  color: AppSplitColor.red(),
                  iconSize: 12,
                ),
                text: data.interviewDate != null
                    ? DateFormat('dd.MM.yyyy HH:mm', 'ru')
                        .format(data.interviewDate!)
                    : '${data.date} / ${data.time}',
                textColor: AppColors.red,
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            if (data.status != -1) ...[
              IconWithTextRow(
                text: data.experience ? 'С опытом' : 'Без опыта',
                textStyle: AppTextStyle.regularCaption.style(context),
              ),
              const SizedBox(height: 16),
            ],
            if (data.canTakeToWork)
              SizedBox(
                width: double.infinity,
                child: PrimaryButton.green(
                  onPressed: () => _State.of(context).getToWork(context, data),
                  text: 'Взять в работу',
                ),
              )
            else
              Row(
                children: [
                  AppIcons.edit.fabButton(
                    size: const Size.square(40),
                    onPressed: () async {
                      if (data.canTakeToWork == false) {
                        await Navigator.of(context).pushNamed(
                          ApplicantDetailsScreen.routeName,
                          arguments: ApplicantDetailsScreenArgs(
                            data,
                            _State.of(context).dict!,
                          ),
                        );
                        await withLoadingIndicator(() async {
                          await _State.of(context).refresh(context);
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _CallButton(data),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessObserverWidget {
  const _CallButton(this.data);

  final ApplicantData data;

  @override
  Widget build(BuildContext context) {
    final isSipActive = _State.of(context).isSipActive;
    return CallButton(
      phone: data.phone,
      additionalPhones: data.additionalPhone,
      isSipActive: isSipActive,
      onMakeCall: _State.of(context).sipModel.makeCall,
      onTryCall: () async {
        if (_State.of(context).isPhoneCalling) return;
        _State.of(context).isPhoneCalling = true;
        await Future.delayed(const Duration(seconds: 15), () {
          _State.of(context).isPhoneCalling = false;
        });
      },
    );
  }
}
