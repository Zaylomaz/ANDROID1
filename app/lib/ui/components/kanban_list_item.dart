import 'package:core/core.dart';
import 'package:rempc/ui/screens/tab/kanban_masters_page.dart';
import 'package:rempc/ui/screens/tab/kanban_order_page.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

class KanbanListItem extends StatelessWidget {
  const KanbanListItem(
    this.order, {
    required this.isVisible,
    required this.attachMaster,
    required this.updateOrder,
    required this.detachMaster,
    required this.phoneCall,
    super.key,
  });

  final KanbanOrder order;
  final bool isVisible;
  final Function attachMaster;
  final Function updateOrder;
  final Function detachMaster;
  final Function phoneCall;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState:
          isVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
      firstChild: const SizedBox(
        height: 0,
        width: 0,
      ),
      secondChild: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: AppMaterialBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (order.company?.containsKey('name') == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        order.company!['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.boldSubHeadline.style(context),
                      ),
                    ),
                  const Spacer(),
                  if (order.distanceToOrder?.hasData == true)
                    _Distance(
                      order.distanceToOrder!,
                      withDateTime: false,
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: order.statusBadge?.color,
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(20),
                        bottomLeft: order.distanceToOrder?.hasData != true
                            ? const Radius.circular(20)
                            : Radius.zero,
                      ),
                    ),
                    child: Text(
                      order.statusBadge?.text ?? '-',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.boldSubHeadline.style(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (order.distance?.hasData == true)
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Distance(order.distance!),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.time?.isNotEmpty == true) ...[
                      IconWithTextRow(
                        leading: AppIcons.clock.iconColored(
                          color: AppSplitColor.green(),
                          iconSize: 16,
                        ),
                        text: order.time!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (order.client_name?.isNotEmpty == true) ...[
                      IconWithTextRow(
                        leading: AppIcons.user.iconColored(
                          color: AppSplitColor.violet(),
                          iconSize: 16,
                        ),
                        text: order.client_name!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if ((order.technique_name?.isNotEmpty ??
                            order.them_name?.isNotEmpty) ==
                        true) ...[
                      IconWithTextRow(
                        leading: AppIcons.tv.iconColored(
                          color: AppSplitColor.red(),
                          iconSize: 16,
                        ),
                        text: order.technique_name ?? order.them_name ?? '',
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (order.defect?.isNotEmpty == true) ...[
                      IconWithTextRow(
                        leading: AppIcons.repair.iconColored(
                          color: AppSplitColor.red(),
                          iconSize: 16,
                        ),
                        text: order.defect!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (order.infoForMasterPrevent?.isNotEmpty == true) ...[
                      IconWithTextRow(
                        leading: AppIcons.attention.iconColored(
                          color: AppSplitColor.violetLight(),
                          iconSize: 16,
                        ),
                        text: order.infoForMasterPrevent!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (order.district?.isNotEmpty == true) ...[
                      IconWithTextRow(
                        leading: AppIcons.map.iconColored(
                          color: AppSplitColor.violetLight(),
                          iconSize: 16,
                        ),
                        text: order.district!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (order.master.hasData) ..._withMaster(context, order),
                    if (!order.master.hasData)
                      ..._withoutMaster(context, order),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneCallButton(
      BuildContext context, KanbanOrder kanbanOrder, SipModel sipModel) {
    if (kanbanOrder.phone == null) {
      return Container();
    }

    var iteration = 0;
    final phones = [
      {'name': 'Основной', 'phone': kanbanOrder.phone}
    ];

    if (kanbanOrder.additionalPhones != null) {
      for (final element in kanbanOrder.additionalPhones!) {
        iteration += 1;
        phones.add({'name': 'Доп. $iteration', 'phone': element});
      }
    }

    if (kanbanOrder.phone?.isNotEmpty == true) {
      return CallButton(
        key: ValueKey('${order.id}_phones'),
        phone: kanbanOrder.phone!,
        additionalPhones: kanbanOrder.additionalPhones ?? [],
        isSipActive: sipModel.isActive,
        onMakeCall: (number) async {
          await sipModel.makeCall(number);
        },
        onTryCall: () {
          phoneCall(kanbanOrder.id);
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<Widget> _withMaster(BuildContext context, KanbanOrder order) {
    return [
      Text(
        order.master.name ?? 'Имя мастера не указано',
        style: AppTextStyle.regularHeadline.style(context),
      ),
      const SizedBox(height: 8),
      if (!order.isLoading)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (order.isCanCall) ...[
              _phoneCallButton(context, order, context.read<SipModel>()),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Opacity(
                opacity: order.isCanRemoveMaster ? 1 : .5,
                child: PrimaryButton.red(
                  text: 'Отвязать мастера',
                  onPressed: () async {
                    if (order.isCanRemoveMaster) {
                      detachMaster(order.id);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Opacity(
                opacity: order.isCanView ? 1 : .5,
                child: PrimaryButton.green(
                  text: 'Просмотр',
                  onPressed: () async {
                    if (order.isCanView) {
                      final result = await Navigator.of(context).pushNamed(
                          KanbanOrderPage.routeName,
                          arguments: {'orderId': order.id});
                      if (result != null) {
                        order.isLoading = true;
                        updateOrder(result);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        )
    ];
  }

  List<Widget> _withoutMaster(BuildContext context, KanbanOrder order) {
    return [
      if (!order.isLoading)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (order.isCanCall) ...[
            _phoneCallButton(context, order, context.read<SipModel>()),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: PrimaryButton.green(
              text: 'Выдать',
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                    KanbanMastersPage.routeName,
                    arguments: {'orderId': order.id});
                if (result != null) {
                  order.isLoading = true;
                  attachMaster(result);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryButton.cyan(
              text: 'Просмотр',
              onPressed: () async {
                if (order.isCanView) {
                  final result = await Navigator.of(context).pushNamed(
                      KanbanOrderPage.routeName,
                      arguments: {'orderId': order.id});
                  if (result != null) {
                    order.isLoading = true;
                    updateOrder(result);
                  }
                }
              },
            ),
          ),
        ])
    ];
  }
}

class _Distance extends StatelessWidget {
  const _Distance(this.data, {this.withDateTime = true});

  final KanbanOrderDistance data;
  final bool withDateTime;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: AppTextStyle.boldSubHeadline.style(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        decoration: const BoxDecoration(
          color: AppColors.blackLightContainer,
          borderRadius: BorderRadius.only(
            // topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: data.hasError
            ? Text('${data.error}')
            : Row(
                children: [
                  Text('${data.distance!} ${data.unitOfMeasurement!}'),
                  const SizedBox(width: 8),
                  if (withDateTime) Text(data.createdAt!),
                ],
              ),
      ),
    );
  }
}
