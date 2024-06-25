import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:rempc/model/kanban_page_model.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/ui/screens/tab/kanban_order_page.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'available_orders.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.kanbanModel, super.sipModel);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(
    this.kanbanModel,
    this.sipModel,
  ) {
    init();
    isSipActive = sipModel.isActive;
    sipModel.addListener(_sipListener);
  }

  final KanbanPageModel kanbanModel;
  final SipModel sipModel;

  @action
  void _sipListener() {
    isSipActive = sipModel.isActive;
  }

  @observable
  KanbanPageData _data = KanbanPageData.fromJson(JsonReader(
      '{"cities": [], "orders": [], "is_display_date_filter": false}'));
  @computed
  KanbanPageData get data => _data;
  @protected
  set data(KanbanPageData value) => _data = value;

  @observable
  List<KanbanOrder> _orders = [];
  @computed
  List<KanbanOrder> get orders => _orders;
  @protected
  set orders(List<KanbanOrder> value) => _orders = value;

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

  @observable
  bool _isLoading = true;
  @computed
  bool get isLoading => _isLoading;
  @protected
  set isLoading(bool value) => _isLoading = value;

  @action
  Future<void> init() async {
    data = await KanbanRepository().kanbanList();
    orders = data.orders;
    isLoading = false;
  }

  @action
  void dispose() {
    sipModel.removeListener(_sipListener);
  }
}

class AvailableOrdersScreen extends StatelessWidget {
  const AvailableOrdersScreen({super.key});

  static const String routeName = '/available_orders';

  @override
  Widget build(BuildContext context) {
    return Provider<KanbanPageModel>(
      create: (context) => KanbanPageModel(),
      builder: (ctx, child) => Provider<_State>(
        create: (c) =>
            _State(ctx.read<KanbanPageModel>(), Provider.of<SipModel>(context)),
        builder: (c, child) => const _Content(),
        dispose: (c, state) => state.dispose(),
      ),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Доступные заказы'),
      ),
      body: RefreshIndicator(
        onRefresh: _State.of(context).init,
        child: _State.of(context).isLoading
            ? const Center(
                child: AppLoadingIndicator(),
              )
            : _State.of(context).orders.isNotEmpty
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      final item = _State.of(context).orders[index];
                      return _Order(
                        item,
                        key: ValueKey<String>('${item.id}_$index'),
                      );
                    },
                    itemCount: _State.of(context).orders.length,
                  )
                : const _EmptyList(),
      ),
    );
  }
}

class _Order extends StatelessWidget {
  const _Order(this.order, {super.key});

  final KanbanOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppMaterialBox(
        child: InkWell(
          onTap: () async {
            if (order.isCanView) {
              await Navigator.of(context).pushNamed(
                KanbanOrderPage.routeName,
                arguments: {
                  'orderId': order.id,
                },
              );
              order.isLoading = true;
              await withLoadingIndicator(() async {
                await _State.of(context).init();
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.time?.isNotEmpty == true) ...[
                  IconWithTextRow(
                    leading: AppIcons.clock.iconColored(
                      color: AppSplitColor.red(),
                      iconSize: 16,
                    ),
                    text: order.time!,
                    textColor: AppColors.red,
                  ),
                  const SizedBox(height: 8),
                ],
                if (order.statusBadge != null) ...[
                  IconWithTextRow(
                    leading: AppIcons.energy.iconColored(
                      color: AppSplitColor.custom(
                        primary: order.statusBadge!.color,
                        secondary: order.statusBadge!.color.withOpacity(.2),
                      ),
                      iconSize: 12,
                    ),
                    text: order.statusBadge!.text,
                    textColor: order.statusBadge!.color,
                  ),
                  const SizedBox(height: 8),
                ],
                IconWithTextRow(
                  leading: AppIcons.chip.iconColored(
                    color: AppSplitColor.cyan(),
                    iconSize: 16,
                  ),
                  text: order.technique_name ?? order.them_name ?? '-',
                ),
                const SizedBox(height: 8),
                if (order.defect?.isNotEmpty == true) ...[
                  IconWithTextRow(
                    leading: AppIcons.attention.iconColored(
                      color: AppSplitColor.cyan(),
                      iconSize: 12,
                    ),
                    text: order.defect!,
                  ),
                  const SizedBox(height: 8),
                ],
                if (order.district?.isNotEmpty == true) ...[
                  IconWithTextRow(
                    leading: AppIcons.map.iconColored(
                      color: AppSplitColor.violet(),
                      iconSize: 12,
                    ),
                    text: order.district!,
                  ),
                  const SizedBox(height: 8),
                ],
                if (order.distanceToOrder?.distance?.isNotEmpty == true) ...[
                  IconWithTextRow(
                    leading: AppIcons.locationMan.iconColored(
                      color: AppSplitColor.violet(),
                      iconSize: 16,
                    ),
                    text:
                        '''${order.distanceToOrder!.distance!} ${order.distanceToOrder!.unitOfMeasurement!}''',
                  ),
                  const SizedBox(height: 8),
                ],
                if (order.client_name?.isNotEmpty == true) ...[
                  IconWithTextRow(
                    leading: AppIcons.user.iconColored(
                      color: AppSplitColor.violet(),
                      iconSize: 12,
                    ),
                    text: order.client_name!,
                  ),
                  const SizedBox(height: 8),
                ],
                if (order.infoForMasterPrevent?.isNotEmpty == true) ...[
                  Text(
                    order.infoForMasterPrevent!,
                    style: AppTextStyle.regularSubHeadline.style(context),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (order.master.hasData) {
                            return PrimaryButton.red(
                              onPressed: () async {
                                if (context.read<HomeData>().permissions.userId
                                    is int) {
                                  await withLoadingIndicator(() async {
                                    await KanbanRepository().kanbanDetachMaster(
                                      order.id,
                                    );
                                    context
                                        .read<HomeData>()
                                        .updateData
                                        .add(true);
                                    Navigator.of(context).pop();
                                  });
                                }
                              },
                              text: 'Отказаться',
                            );
                          } else {
                            return PrimaryButton.cyan(
                              onPressed: () async {
                                if (context.read<HomeData>().permissions.userId
                                    is int) {
                                  await withLoadingIndicator(() async {
                                    try {
                                      await KanbanRepository()
                                          .kanbanAttachMaster(
                                        order.id,
                                        context
                                            .read<HomeData>()
                                            .permissions
                                            .userId!,
                                      );
                                      context
                                          .read<HomeData>()
                                          .updateData
                                          .add(true);
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      if (e is DioException &&
                                          e is ApiException) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.message),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  });
                                }
                              },
                              text: 'Взять заказ',
                            );
                          }
                        },
                      ),
                    ),
                    if (order.isCanCall && order.phone?.isNotEmpty == true) ...[
                      const SizedBox(width: 8),
                      _CallButton(order),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessObserverWidget {
  const _CallButton(this.data);

  final KanbanOrder data;

  @override
  Widget build(BuildContext context) {
    final isSipActive = _State.of(context).isSipActive;
    return CallButton(
      phone: data.phone!,
      additionalPhones: data.additionalPhones ?? [],
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

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Spacer(),
          AppIcons.flash.iconColored(
              color: AppSplitColor.violet(), size: 96, iconSize: 72),
          const SizedBox(height: 24),
          Text(
            '''На данный момент заказов нет\n\nОжидайте уведомления о поступлении новых!''',
            textAlign: TextAlign.center,
            style: AppTextStyle.boldTitle2.style(
              context,
              AppColors.violet,
            ),
          ),
          const Spacer(),
          PrimaryButton.cyan(
            text: 'Обновить',
            onPressed: () => withLoadingIndicator(_State.of(context).init),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
