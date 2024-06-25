import 'dart:async';

import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/cashbox_admin/cashbox_admin_edit/cashbox_admin_edit_screen.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'cashbox_admin_screen.g.dart';

const _kDefaultChunkSize = 20;

class _State extends _StateStore with _$_State {
  _State();

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore() {
    pagingController.addPageRequestListener(load);
    getBalance();
  }
  final _repo = CashBoxRepository();

  final pagingController = PagingController<int, CashBoxList>(firstPageKey: 1);

  @observable
  List<CashboxBalance> _balance = [];
  @computed
  List<CashboxBalance> get balance => _balance;
  @protected
  set balance(List<CashboxBalance> value) => _balance = value;

  @observable
  String _averageCheck = '';
  @computed
  String get averageCheck => _averageCheck;
  @protected
  set averageCheck(String value) => _averageCheck = value;

  @action
  Future<void> reload() async {
    pagingController.refresh();
    unawaited(getBalance());
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> load(int page) async {
    final result = await _repo.getCashBoxList(
      page: page,
      pageSize: _kDefaultChunkSize,
    );
    result.length == _kDefaultChunkSize
        ? pagingController.appendPage(result, page + 1)
        : pagingController.appendLastPage(result);
  }

  @action
  Future<void> switchStatus({required int id, required bool submitted}) async {
    await withLoadingIndicator(() async {
      final success =
          await _repo.switchCashBoxStatus(id: id, submitted: submitted);
      if (success) {
        final list = pagingController.itemList;
        final index = list!.indexWhere((e) => e.id == id);
        final item = list[index].copyWith(submitted: submitted);
        list[index] = item;
        pagingController
          ..itemList = list
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          ..notifyListeners();
      }
    });
  }

  @action
  Future<CashBoxDetails?> editBox(BuildContext context, int id) async {
    await withLoadingIndicator<CashBoxDetails>(() async {
      final data = await _repo.getCashBoxById(id);
      return data;
    }).then((data) async {
      final result = await Navigator.of(context).pushNamed(
        CashBoxAdminEditScreen.routeName,
        arguments: CashBoxAdminEditScreenArgs(data: data),
      ) as CashBoxDetails?;
      if (result != null) {
        final list = pagingController.itemList;
        final index = list!.indexWhere((e) => e.id == id);
        final item = list[index].copyWith(
          submitted: result.submitted,
        );
        list[index] = item;
        pagingController
          ..itemList = list
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          ..notifyListeners();
        return result;
      }
    });
    return null;
  }

  @action
  Future<void> getBalance() async {
    final data = await _repo.getBalance();
    averageCheck = data.averageCheck;
    balance = data.balance..sort((a, b) => b.total.compareTo(a.total));
  }

  @action
  void dispose() {
    pagingController.dispose();
  }
}

class CashBoxAdminScreen extends StatelessWidget {
  const CashBoxAdminScreen({super.key});

  static const String routeName = '/cashbox_admin_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: const Text('Управление кассой'),
        actions: [
          AppIcons.add.fabButton(
            onPressed: () => Navigator.of(context).pushNamed(
              CashBoxAdminEditScreen.routeName,
              arguments: const CashBoxAdminEditScreenArgs(),
            ),
          )
        ],
      ),
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, pinned) => [
            const SliverToBoxAdapter(
              child: _Balance(),
            )
          ],
          body: RefreshIndicator(
            onRefresh: _State.of(context).reload,
            child: PagedListView<int, CashBoxList>(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              pagingController: _State.of(context).pagingController,
              builderDelegate: PagedChildBuilderDelegate<CashBoxList>(
                itemBuilder: (context, item, index) {
                  return _CashBoxItem(
                    item,
                    key: ValueKey<String>('${item.id}_$index'),
                  );
                },
                noItemsFoundIndicatorBuilder: noItemsInListBuilder(context),
                firstPageErrorIndicatorBuilder: (context) {
                  return const Center(
                    child: Text(
                      'First page error',
                    ),
                  );
                },
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
            ),
          ),
        ),
      ),
    );
  }
}

class _CashBoxItem extends StatelessWidget {
  const _CashBoxItem(this.item, {super.key});

  final CashBoxList item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppMaterialBox(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ItemTop(item),
                  const SizedBox(height: 8),
                  //Check status
                  Row(
                    children: [
                      AppIcons.energy.iconColored(
                        color: AppSplitColor.cyan(),
                        iconSize: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.status.isNotEmpty ? item.status : 'Не указан',
                        style: AppTextStyle.regularHeadline.style(
                          context,
                          AppColors.cyan,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  //Employee
                  Row(
                    children: [
                      AppIcons.users.iconColored(
                        color: AppSplitColor.cyan(),
                        iconSize: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.user,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.regularHeadline.style(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  //City
                  Row(
                    children: [
                      AppIcons.city.iconColored(
                        color: AppSplitColor.violet(),
                        iconSize: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.city.isNotEmpty ? item.city : 'Не указан',
                        style: AppTextStyle.regularHeadline.style(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  //Technic
                  Row(
                    children: [
                      AppIcons.service.iconColored(
                        color: AppSplitColor.violetLight(),
                        iconSize: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.technique,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.regularHeadline.style(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _InOutData(item)),
                      const SizedBox(width: 8),
                      _Status(item),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: AppIcons.edit.fabButton(
                  color: AppSplitColor.violet(),
                  onPressed: () => _State.of(context).editBox(context, item.id),
                  size: const Size.square(40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTop extends StatelessWidget {
  const _ItemTop(this.item);

  final CashBoxList item;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: AppTextStyle.regularSubHeadline.style(context),
      child: Row(
        children: [
          if (item.orderNumber is int) ...[
            Flexible(
              flex: 2,
              child: AutoSizeText(
                '#${item.orderNumber}',
                maxLines: 1,
                maxFontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            flex: 2,
            child: AutoSizeText(
              DateFormat('dd.MM.yy', 'ru').format(item.createdAt),
              maxLines: 1,
              maxFontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AutoSizeText(
              DateFormat('HH:mm', 'ru').format(item.createdAt),
              maxLines: 1,
              maxFontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InOutData extends StatelessWidget {
  const _InOutData(this.item);

  final CashBoxList item;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: AppTextStyle.regularHeadline.style(context),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                AppIcons.arrowRedoDown.iconColored(
                  color: AppSplitColor.green(),
                  iconSize: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  item.inputAmount.toString(),
                  style: const TextStyle(
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                AppIcons.arrowRedoUp.iconColored(
                  color: AppSplitColor.red(),
                  iconSize: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  item.outputAmount.toString(),
                  style: const TextStyle(
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status(this.item);

  final CashBoxList item;

  @override
  Widget build(BuildContext context) {
    return AppSwitch(
      statusString: item.submitted ? 'Сдал' : 'Не сдал',
      isSwitched: item.submitted,
      onChanged: (value) => _State.of(context).switchStatus(
        id: item.id,
        submitted: value,
      ),
    );
  }
}

class _Balance extends StatelessObserverWidget {
  const _Balance();

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).balance.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppMaterialBox(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                      style: AppTextStyle.regularHeadline.style(context),
                      children: [
                        const TextSpan(
                          text: 'Средний чек: ',
                          style: TextStyle(
                            color: AppColors.violetLight,
                          ),
                        ),
                        TextSpan(text: _State.of(context).averageCheck),
                      ]),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    minHeight: 46,
                  ),
                  padding: EdgeInsets.zero,
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: _State.of(context).balance.length,
                    itemBuilder: (context, i) =>
                        _BalanceItem(_State.of(context).balance[i]),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4 / 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem(this.item);

  final CashboxBalance item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth / 2,
        padding: const EdgeInsets.only(right: 8),
        child: RichText(
          maxLines: 3,
          text: TextSpan(
            style: AppTextStyle.regularHeadline.style(context),
            children: [
              TextSpan(text: item.city),
              const TextSpan(text: '\n'),
              TextSpan(
                text: item.submittedFormat,
                style: const TextStyle(
                  color: AppColors.green,
                ),
              ),
              const TextSpan(text: '/ '),
              TextSpan(
                text: item.totalFormat,
                style: const TextStyle(
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class CashBoxAdminScreenRouter extends OldPageRouterAbstract {
  const CashBoxAdminScreenRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => CashBoxAdminScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.cashboxAdminNavigatorKey];
}
