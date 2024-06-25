import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';
import 'package:rempc/screens/master/details/master_screen.dart';
import 'package:rempc/screens/master/filter/master_filter.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:rempc/ui/components/filter_list.dart';
import 'package:rempc/ui/components/tab_view/tab_selector.dart';
import 'package:rempc/ui/components/tab_view/tab_view_model.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'masters_screen.g.dart';
part 'tabs.dart';

class _State extends _StateStore with _$_State {
  _State(super.sipModel, super.vsync);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store, TabViewStateMixin<MastersTab> {
  _StateStore(this.sipModel, TickerProvider vsync) {
    init(vsync);
  }

  final SipModel sipModel;
  final _repo = UsersRepository();

  @observable
  TabController? _tabController;

  @override
  @computed
  TabController? get tabController => _tabController;

  @override
  @protected
  set tabController(TabController? value) => _tabController = value;

  @observable
  List<MastersTab> _tabs = [];

  @override
  @computed
  List<MastersTab> get tabs => _tabs;

  @override
  @protected
  set tabs(List<MastersTab> value) => _tabs = value;

  @computed
  IconData get filterIcon => filter.isEmpty ? Icons.search : Icons.saved_search;

  @computed
  Color get filterColor =>
      filter.isEmpty ? Colors.white : const Color(0xffFFAC18);

  @observable
  AppMasterUserFilter _filter = AppMasterUserFilter.empty;

  @computed
  AppMasterUserFilter get filter => _filter;

  @protected
  set filter(AppMasterUserFilter value) => _filter = value;

  @observable
  AppMasterUserDict? _dict;

  @computed
  AppMasterUserDict? get dict => _dict;

  @protected
  set dict(AppMasterUserDict? value) => _dict = value;

  @observable
  bool _isPhoneCalling = false;

  @computed
  bool get isPhoneCalling => _isPhoneCalling;

  @protected
  set isPhoneCalling(bool value) => _isPhoneCalling = value;

  @override
  JsonListPreference<MastersTab> get savedTabs => mastersTabs;

  @action
  Future<void> init(TickerProvider vsync) async {
    try {
      initTabs(vsync);
      dict = await _repo.getUsersListFilter();
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
    dict = await _repo.getUsersListFilter();
  }

  @action
  Future<AppMasterUserFilter> showFilter(BuildContext context) async {
    final update =
        await Navigator.of(context).pushNamed(MasterFilterScreen.routeName,
            arguments: MasterFilterScreenArgs(
              dict: dict!,
              initFilter:
                  tabs[stackIndex(context)].filter as AppMasterUserFilter,
            )) as AppMasterUserFilter?;
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
}

class MasterScreen extends StatelessWidget implements AppTabViewScreen {
  MasterScreen({super.key});

  static const String routeName = '/masters_screen';

  @override
  String get route => routeName;

  @override
  String get filterRoute => MasterFilterScreen.routeName;

  @override
  String get detailsRoute => MasterScreenDetails.routeName;
  @override
  final tickerKey = GlobalKey<TabContainerState>();

  @override
  Widget build(BuildContext context) {
    return TabContainer(
      key: tickerKey,
      child: Provider<_State>(
        create: (ctx) => _State(
          context.read<SipModel>(),
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
        title: const Text('Мастера'),
        actions: [
          AppIcons.edit.fabButton(
            onPressed: () => _State.of(context).editTabs(context),
          ),
          const SizedBox(width: 8),

          /// TODO создание мастера
          // AppIcons.add.fabButton(
          //   color: AppSplitColor.green(),
          //   onPressed: () => Navigator.of(context).pushNamed(
          //     MasterEdit.routeName,
          //     arguments: const MasterEditArgs(),
          //   ),
          // ),
        ],
      ),
      drawer: Navigator.of(context).canPop() ? null : const AppBarDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabSelector(
            controller: _State.of(context).tabController,
            tabs: _State.of(context).tabs,
            tabsStream: _State.of(context).tabsSub,
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

  final MastersTab tab;

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
        child: PagedListView<int, AppMasterUser>.separated(
          pagingController: tab.pageController,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          builderDelegate: PagedChildBuilderDelegate<AppMasterUser>(
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

class _Item extends StatelessObserverWidget {
  const _Item(this.data, {super.key});

  final AppMasterUser data;

  @override
  Widget build(BuildContext context) {
    return AppMaterialBox(
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          MasterScreenDetails.routeName,
          arguments: MasterScreenDetailsArgs(
            master: data,
            dict: _State.of(context).dict!,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    clipBehavior: Clip.hardEdge,
                    decoration: ShapeDecoration(
                      color: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Image.network(
                      data.avatar?.toString() ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: imageErrorWidget,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.boldHeadLine.style(context),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            AppIcons.numberHash.iconColored(
                              color: AppSplitColor.violet(),
                              size: 16,
                              iconSize: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data.number.toString(),
                              style: AppTextStyle.regularSubHeadline
                                  .style(context),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _State.of(context).dict?.role[data.role] ?? '',
                              style: AppTextStyle.regularSubHeadline.style(
                                context,
                                AppColors.violetLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              IconWithTextRow(
                leading: AppIcons.city.iconColored(
                  color: AppSplitColor.violet(),
                ),
                text: _State.of(context).dict?.cityId[data.cityId] ?? '',
              ),
              const SizedBox(height: 8),
              IconWithTextRow(
                leading: AppIcons.company.iconColored(
                  color: AppSplitColor.violet(),
                  iconSize: 16,
                ),
                text: _State.of(context).dict?.companyId[data.companyId] ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _CallButton(data),
                  const SizedBox(width: 8),
                  _StatusIndicator(isActive: data.active),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        color: isActive ? AppColors.greenDark : AppColors.redDark,
        shape: const OvalBorder(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          SizedBox(
            width: 22,
            height: 12,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 22,
                    height: 12,
                    decoration: ShapeDecoration(
                      color: AppColors.blackContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: isActive ? 12 : null,
                  right: !isActive ? 12 : null,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: ShapeDecoration(
                      color: isActive ? AppColors.green : AppColors.red,
                      shape: const OvalBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox.square(dimension: 1),
          Text(
            isActive ? 'On' : 'Off',
            style: AppTextStyle.regularCaption
                .style(
                  context,
                  isActive ? AppColors.green : AppColors.red,
                )
                .copyWith(fontSize: 9),
          )
        ],
      ),
    );
  }
}

class _CallButton extends StatelessObserverWidget {
  const _CallButton(this.data);

  final AppMasterUser data;

  @override
  Widget build(BuildContext context) {
    return CallButton(
      phone: data.contacts.primary,
      additionalPhones: data.contacts.additional,
      binotel: data.contacts.binotel,
      asterisk: data.contacts.asterisk,
      ringostat: data.contacts.ringostat,
      isSipActive: context.read<SipModel>().isActive,
      onMakeCall: _State.of(context).sipModel.makeCall,
      onTryCall: () async {
        unawaited(showMessage(context, message: 'Sip не активен'));
        if (_State.of(context).isPhoneCalling) return;
        _State.of(context).isPhoneCalling = true;
        await Future.delayed(const Duration(seconds: 15), () {
          _State.of(context).isPhoneCalling = false;
        });
      },
    );
  }
}
