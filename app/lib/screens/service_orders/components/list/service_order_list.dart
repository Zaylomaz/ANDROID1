import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';
import 'package:rempc/screens/service_orders/components/edit/service_order_editor.dart';
import 'package:rempc/screens/service_orders/components/filter/service_order_filter.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:rempc/ui/components/filter_list.dart';
import 'package:rempc/ui/components/tab_view/tab_selector.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'service_order_list.g.dart';
part 'tabs.dart';

class _State extends _StateStore with _$_State {
  _State(super.sipModel, super.vsync);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store, TabViewStateMixin<ServiceOrderTab> {
  _StateStore(this.sipModel, TickerProvider vsync) {
    init(vsync);
    isSipActive = sipModel.isActive;
    sipModel.addListener(_sipListener);
  }

  final queryCtrl = TextEditingController();
  final _repo = OrdersRepository();
  final SipModel sipModel;

  @observable
  TabController? _tabController;

  @override
  @computed
  TabController? get tabController => _tabController;

  @override
  @protected
  set tabController(TabController? value) => _tabController = value;

  @observable
  List<ServiceOrderTab> _tabs = [];

  @override
  @computed
  List<ServiceOrderTab> get tabs => _tabs;

  @override
  @protected
  set tabs(List<ServiceOrderTab> value) => _tabs = value;

  @observable
  bool _isSipActive = false;

  @computed
  bool get isSipActive => _isSipActive;

  @protected
  set isSipActive(bool value) => _isSipActive = value;

  @observable
  ServiceOrderDict _dictionary = ServiceOrderDict.empty;

  @computed
  ServiceOrderDict get dictionary => _dictionary;

  @protected
  set dictionary(ServiceOrderDict value) => _dictionary = value;

  @observable
  ServiceOrderFilter _filter = ServiceOrderFilter.empty;

  @computed
  ServiceOrderFilter get filter => _filter;

  @protected
  set filter(ServiceOrderFilter value) => _filter = value;

  @observable
  bool _isPhoneCalling = false;

  @computed
  bool get isPhoneCalling => _isPhoneCalling;

  @protected
  set isPhoneCalling(bool value) => _isPhoneCalling = value;

  @override
  JsonListPreference<ServiceOrderTab> get savedTabs => serviceTabsMultiselect;

  @action
  Future<void> init(TickerProvider vsync) async {
    initTabs(vsync);
    queryCtrl.text = (tabs.first.filter as ServiceOrderFilter).queryText;
    dictionary = await _repo.getServiceOrdersDictionary();
  }

  @action
  Future<void> reload(BuildContext context) async {
    try {
      tabs[stackIndex(context)].refresh();
      dictionary = await _repo.getServiceOrdersDictionary();
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
  void search(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    final filter = (tabs[stackIndex(context)].filter as ServiceOrderFilter)
        .copyWith(queryText: queryCtrl.text.trim());
    tabs[stackIndex(context)].filter = filter;
    tabs[stackIndex(context)].pageController.refresh();
  }

  @action
  Future<ServiceOrderFilter> showFilter(BuildContext context) async {
    final filter = tabs[stackIndex(context)].filter as ServiceOrderFilter;
    final update = await Navigator.of(context).pushNamed(
        ServiceOrderFilterScreen.routeName,
        arguments: ServiceOrderFilterScreenArgs(
          dictionary: dictionary,
          initFilters: tabs[stackIndex(context)].filter as ServiceOrderFilter,
          name: filter.name,
        )) as ServiceOrderFilter?;
    if (update != null) {
      final hasUpdate = update != tabs[stackIndex(context)].filter;
      if (hasUpdate) {
        tabs[stackIndex(context)].filter = update;
        if (stackIndex(context) == 0) {
          if (filter.orderNumber.trim().isEmpty) {
            queryCtrl.clear();
          } else {
            queryCtrl.text = filter.orderNumber;
          }
        }
        tabs[stackIndex(context)].pageController.refresh();
      }
    }
    return filter;
  }

  @action
  Future<ServiceOrder?> editOrder(
    BuildContext context,
    ServiceOrderLite order,
  ) async {
    late ServiceOrder details;
    late ServiceOrderDict dict;
    await withLoadingIndicator(() async {
      details =
          await withLoadingIndicator(() => _repo.getServiceOrderById(order.id));
      dict =
          await OrdersRepository().getServiceOrdersAvailableOptions(details.id);
    });
    final result = await Navigator.of(context).pushNamed(
      ServiceOrderEditor.routeName,
      arguments: ServiceOrderEditorArgs(dict: dict, order: details),
    ) as ServiceOrder?;
    if (result != null) {
      tabs[stackIndex(context)].refresh();
    }
    return result;
  }

  @action
  Future<void> editTabs(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => _FilterList(
        tabs: tabs,
        onChange: onTabsChange,
        dictionary: dictionary,
      ),
    );
  }

  @action
  void _sipListener() {
    isSipActive = sipModel.isActive;
  }

  @override
  void dispose() {
    sipModel.removeListener(_sipListener);
    queryCtrl.dispose();
    super.dispose();
  }
}

class ServiceOrderList extends StatelessWidget {
  const ServiceOrderList(this.vsync, {super.key});

  final TickerProvider vsync;

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(
        Provider.of<SipModel>(context, listen: false),
        vsync,
      ),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: const Text('Заказы СЦ'),
        actions: [
          AppIcons.edit.fabButton(
            onPressed: () => _State.of(context).editTabs(context),
          ),
        ],
      ),
      drawer: Navigator.maybeOf(context)?.canPop() == true
          ? null
          : const AppBarDrawer(),
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

  final ServiceOrderTab tab;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      controller: tab.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          if (_State.of(context).stackIndex(context) == 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: innerBoxIsScrolled ? 0 : 52,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 300),
                  heightFactor: innerBoxIsScrolled ? 0 : 1,
                  widthFactor: 1,
                  curve: Curves.easeInOut,
                  child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: CupertinoSearchTextField(
                        controller: _State.of(context).queryCtrl,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 19 / 16,
                          color: Colors.white,
                        ),
                        onSubmitted: (value) =>
                            _State.of(context).search(context),
                        placeholder: 'Номер телефона/Номер заказа',
                        placeholderStyle: AppTextStyle.regularHeadline
                            .style(context, AppColors.violetLight),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        prefixIcon: AppIcons.search.widget(
                          color: AppColors.violetLight,
                          width: 16,
                          height: 16,
                        ),
                        suffixIcon: const Icon(
                          Icons.clear,
                          size: 16,
                          color: AppColors.violetLight,
                        ),
                        onSuffixTap: () {
                          _State.of(context).queryCtrl.clear();
                          _State.of(context).search(context);
                        },
                        suffixInsets: const EdgeInsets.fromLTRB(0, 7, 8, 7),
                        prefixInsets: const EdgeInsets.fromLTRB(8, 7, 0, 7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Observer(builder: (context) {
                      return Text(
                        '${tab.name.value} (${tab.total.value})',
                        style: AppTextStyle.boldHeadLine.style(context),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  AppIcons.filter.fabButton(
                    onPressed: () => _State.of(context).showFilter(context),
                  ),
                  const SizedBox(width: 12),
                  AppIcons.add.fabButton(
                    onPressed: () async {
                      late ServiceOrderDict dict;
                      await withLoadingIndicator(() async {
                        dict = await OrdersRepository()
                            .getServiceOrdersAvailableOptions(null);
                      });
                      await Navigator.of(context).pushNamed(
                        ServiceOrderEditor.routeName,
                        arguments: ServiceOrderEditorArgs(
                          dict: dict,
                        ),
                      );
                      tab.refresh();
                    },
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () => _State.of(context).reload(context),
        child: PagedListView<int, ServiceOrderLite>.separated(
          pagingController: tab.pageController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 8),
          builderDelegate: PagedChildBuilderDelegate<ServiceOrderLite>(
            itemBuilder: (context, item, index) => _OrderItem(
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
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem(this.order, {super.key});

  final ServiceOrderLite order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppMaterialBox(
        borderSide: BorderSide(
          color: order.status.secondaryColor,
          width: 2,
        ),
        child: InkWell(
          onTap: () => _State.of(context).editOrder(context, order),
          splashColor: order.status.color,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DefaultTextStyle.merge(
                  style: AppTextStyle.regularSubHeadline.style(context),
                  child: Row(
                    children: [
                      Text('# ${order.orderNumber}'),
                      if (order.date.isAfter(
                        DateTime.utc(0),
                      )) ...[
                        const SizedBox(width: 16),
                        Text(
                          DateFormat(
                            'dd.MM.yyyy',
                            'ru',
                          ).format(order.date),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${order.amount} грн',
                        style: AppTextStyle.boldSubHeadline.style(context),
                      ),
                    ],
                  ),
                ),
                DefaultTextStyle.merge(
                  style: AppTextStyle.regularHeadline.style(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppIcons.energy.iconColored(
                            color: AppSplitColor.custom(
                              primary: order.status.color,
                              secondary: order.status.color.withOpacity(.2),
                            ),
                            iconSize: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.status.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: order.status.color,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (order.callDate.isAfter(DateTime(1971))) ...[
                        Row(
                          children: [
                            AppIcons.call.iconColored(
                              color: order.callDateFail
                                  ? AppSplitColor.red()
                                  : AppSplitColor.green(),
                              iconSize: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                  'ru',
                                ).format(order.callDate),
                                style: TextStyle(
                                  color: order.callDateFail
                                      ? AppColors.red
                                      : AppColors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (order.serviceMaster.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcons.users.iconColored(
                              color: AppSplitColor.cyan(),
                              iconSize: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.serviceMaster,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (order.clientCity.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcons.city.iconColored(
                              color: AppSplitColor.violet(),
                              iconSize: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.clientCity,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (order.company.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcons.company.iconColored(
                              color: AppSplitColor.violet(),
                              iconSize: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.company,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (order.commentFromOperator.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcons.callCentre.iconColored(
                              color: AppSplitColor.cyan(),
                              iconSize: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.commentFromOperator,
                                maxLines: 6,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (order.orderComment.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcons.sms.iconColored(
                              color: AppSplitColor.cyan(),
                              iconSize: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.orderComment,
                                maxLines: 6,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (order.clientFullAddress.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcons.location.iconColored(
                                color: AppSplitColor.violetLight(),
                                iconSize: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.clientFullAddress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      DefaultTextStyle.merge(
                        style: AppTextStyle.regularCaption.style(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (order.technique.isNotEmpty) ...[
                              Text(
                                order.technique,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                            if (order.brand.isNotEmpty) ...[
                              Text(
                                order.brand,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (order.model.isNotEmpty) ...[
                              Text(
                                order.model,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (order.defect.isNotEmpty) ...[
                              Text(
                                order.defect,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if ((order.defect +
                                    order.model +
                                    order.brand +
                                    order.technique)
                                .isNotEmpty)
                              const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      _CallButton(order),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessObserverWidget {
  const _CallButton(this.order);

  final ServiceOrderLite order;

  @override
  Widget build(BuildContext context) {
    final isSipActive = _State.of(context).isSipActive;
    return CallButton(
      phone: order.clientPhone,
      additionalPhones: order.clientAdditionalPhone,
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
