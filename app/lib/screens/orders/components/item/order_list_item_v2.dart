import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:rempc/screens/close_order/close_order_screen.dart';
import 'package:rempc/screens/order_additional/order_additional_screen.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'order_list_item_v2.g.dart';

class _State extends _StateStore with _$_State {
  _State(
    super.order,
    super.updateOrderPage,
    super.sipModel,
    super._vsync,
  );

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(
    AppOrderV2 order,
    this.updateOrderPage,
    this.sipModel,
    this._vsync,
  ) {
    this.order = order;
    status = order.status.value;
    isSipActive = sipModel.isActive;
    sipModel.addListener(_sipListener);
    _emailCtrl.text = order.email.value;
    _controller = AnimationController(
      value: _showOptions ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: _vsync,
    );
    expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  final _repo = OrdersRepository();
  final _emailCtrl = TextEditingController();
  final TickerProvider _vsync;
  final VoidCallback updateOrderPage;
  final SipModel sipModel;

  late final AnimationController _controller;
  late final Animation<double> expandAnimation;

  @observable
  bool _showOptions = false;
  @computed
  bool get showOptions => _showOptions;
  @protected
  set showOptions(bool value) => _showOptions = value;

  @action
  void optionsToggle() {
    _showOptions = !_showOptions;
    if (_showOptions) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @observable
  AppOrderV2 _order = AppOrderV2.empty;
  @computed
  AppOrderV2 get order => _order;
  @protected
  set order(AppOrderV2 value) => _order = value;

  @observable
  bool _isPhoneCalling = false;
  @computed
  bool get isPhoneCalling => _isPhoneCalling;
  @protected
  set isPhoneCalling(bool value) => _isPhoneCalling = value;

  @observable
  AppOrderStatus _status = AppOrderStatus.undefined;
  @computed
  AppOrderStatus get status => _status;
  @protected
  set status(AppOrderStatus value) => _status = value;

  @observable
  bool _isSipActive = false;
  @computed
  bool get isSipActive => _isSipActive;
  @protected
  set isSipActive(bool value) => _isSipActive = value;

  bool isDoneCheck(List<AppOrderStatus> expectStatus) =>
      expectStatus.contains(status);

  bool isAvailableCheck(AppOrderStatus expectStatus) => expectStatus == status;

  bool get canSeeFullAddress =>
      status.canSeeFullAddress &&
      (order.apartment.value.isNotEmpty ||
          order.entrance.value.isNotEmpty ||
          order.floor.value.isNotEmpty);

  bool get canSeeMap =>
      order.lat is double && order.lng is double && status.canSeeMap;

  Future openMap(BuildContext context) =>
      order.location.value!.tryLaunch(context);

  @action
  Future<void> changeEmail(BuildContext ctx) async {
    final email = await showDialog<String?>(
      context: ctx,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextInputField(
                  controller: _emailCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => EmailValidator().check(value),
                ),
                const SizedBox(height: 16),
                PrimaryButton.violet(
                  onPressed: () {
                    if (EmailValidator().check(_emailCtrl.text) == null) {
                      Navigator.of(context).pop(_emailCtrl.text);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.of(context).pop();
                        showMessage(
                          ctx,
                          prefixIcon: AppIcons.email.widget(
                            color: AppColors.red,
                          ),
                          message: 'Не верный адрес електронной почты',
                          type: AppMessageType.error,
                          actionText: 'Повторить',
                          action: () => changeEmail(ctx),
                        );
                      });
                    }
                  },
                  text: 'Сохранить',
                ),
              ],
            ),
          ),
        );
      },
    );
    if (email?.isNotEmpty == true) {
      await withLoadingIndicator(() async {
        try {
          await OrdersRepository()
              .setOrderEmail<AppOrderV2>(order.id.value, email!);
          order = order.setEmail(email);
        } catch (e, s) {
          if (e is DioException && e.error is ApiException) {
            await showMessage(
              ctx,
              prefixIcon: AppIcons.email.widget(
                color: AppColors.red,
              ),
              message: (e.error as ApiException).message,
              type: AppMessageType.error,
              actionText: 'Повторить',
              action: () => changeEmail(ctx),
            );
          } else {
            unawaited(FirebaseCrashlytics.instance.recordError(e, s));
          }
        }
      });
    }
    _emailCtrl.text = order.email.value;
  }

  void showError(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
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
  Future<void> setStatus(BuildContext context, AppOrderStatus status) async {
    try {
      await withLoadingIndicator(() async {
        order = await _repo.setOrderStatusV2(order.id.value, status.asInt);
        this.status = order.status.value;
      });
    } catch (e) {
      if (e is ApiException) {
        await showMessage(
          context,
          type: AppMessageType.error,
          message: e.message,
        );
      } else {
        updateOrderPage();
      }
    }
  }

  Future closeOrder(BuildContext context) async {
    final isClosed = await Navigator.of(context).pushNamed(
      CloseOrderScreen.routeName,
      arguments: CloseOrderScreenArgs(order.id.value, order.orderNumber.value),
    );

    if (isClosed == true) {
      updateOrderPage();
    }
  }

  Future<void> pickAdditional(BuildContext context) async {
    await Navigator.of(context).pushNamed(
      OrderAdditionalScreen.routeName,
      arguments: OrderAdditionalScreenArgs(
        order.id.value,
        order.orderNumber.value,
      ),
    );
    updateOrderPage.call();
  }

  @action
  void _sipListener() {
    isSipActive = sipModel.isActive;
  }

  @action
  void dispose() {
    _controller.dispose();
    _emailCtrl.dispose();
    sipModel.removeListener(_sipListener);
  }
}

class OrderListItemV2 extends StatefulWidget {
  const OrderListItemV2({
    required this.order,
    required this.updateOrderPage,
    super.key,
  });

  final AppOrderV2 order;
  final VoidCallback updateOrderPage;

  @override
  State<OrderListItemV2> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItemV2>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(
        widget.order,
        widget.updateOrderPage,
        Provider.of<SipModel>(context, listen: false),
        this,
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
    // return SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppMaterialBox(
        borderSide: const BorderSide(
          width: 2,
          color: AppColors.violetLightDark,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 56),
                        child: _Options(),
                      ),
                      if (_State.of(context)
                          .order
                          .orderNumber
                          .availability) ...[
                        Text(
                          '#${_State.of(context).order.orderNumber.value}',
                          style: AppTextStyle.regularSubHeadline.style(context),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_State.of(context).order.status.availability)
                        IconWithTextRow(
                          text: _State.of(context).status.title,
                          textColor: AppColors.green,
                          leading: AppIcons.status.iconColored(
                            color: AppSplitColor.green(),
                            iconSize: 16,
                          ),
                        ),
                      const SizedBox(height: 8),
                      const _DateTime(),
                      const SizedBox(height: 8),
                      const _Info(),
                      const _Address(),
                      const _InfoFact(),
                      const _Client(),
                    ],
                  ),
                ),
                const _Action(),
              ],
            ),
            const Positioned(
              top: 16,
              right: 16,
              child: _OptionsToggle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessObserverWidget {
  const _Action();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
      child: PrimaryButton.greenInverse(
        text: _State.of(context).status.actionText,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        onPressed: () {
          if (_State.of(context).status.canCloseOrder) {
            _State.of(context).closeOrder(context);
          } else if (_State.of(context).status.actionStatus !=
              AppOrderStatus.undefined) {
            _State.of(context).setStatus(
              context,
              _State.of(context).status.actionStatus,
            );
          }
        },
      ),
    );
  }
}

class _DateTime extends StatelessObserverWidget {
  const _DateTime();

  @override
  Widget build(BuildContext context) {
    if (!_State.of(context).order.date.availability) return const SizedBox();
    final dateString = DateFormat('dd MMMM yyyy', 'ru')
        .format(_State.of(context).order.date.value);
    final time = _State.of(context).order.time.availability &&
            _State.of(context).order.time.value.isNotEmpty
        ? _State.of(context).order.time.value
        : '';
    return IconWithTextRow(
      leading: AppIcons.clock.iconColored(
        color: AppSplitColor.red(),
        iconSize: 16,
      ),
      textColor: AppColors.red,
      text: '''$dateString${time.isNotEmpty == true ? ' / $time' : ''}''',
    );
  }
}

class _Info extends StatelessObserverWidget {
  const _Info();

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).order.infoForMasterPrevent.value.isNotEmpty &&
        _State.of(context).order.infoForMasterPrevent.availability) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconWithTextRow(
          text:
              '''Инфо (предв.): ${_State.of(context).order.infoForMasterPrevent.value}''',
          maxLines: 6,
          leading: AppIcons.attention.iconColored(
            color: AppSplitColor.cyan(),
            iconSize: 16,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _InfoFact extends StatelessObserverWidget {
  const _InfoFact();

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).order.infoForMasterFact.value.isNotEmpty &&
        _State.of(context).order.infoForMasterFact.availability) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconWithTextRow(
          text:
              '''Инфо (факт.): ${_State.of(context).order.infoForMasterFact.value}''',
          maxLines: 6,
          leading: AppIcons.attention.iconColored(
            color: AppSplitColor.cyan(),
            iconSize: 16,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Address extends StatelessObserverWidget {
  const _Address();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_State.of(context).order.district.availability &&
            _State.of(context).order.district.value.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IconWithTextRow(
              text: 'Район: ${_State.of(context).order.district.value.trim()}',
              leading: AppIcons.map
                  .iconColored(color: AppSplitColor.violet(), iconSize: 16),
            ),
          ),
        ],
        if (_State.of(context).order.showAddress) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IconWithTextRow(
              text: _State.of(context).order.address,
              leading: AppIcons.location.iconColored(
                color: AppSplitColor.violet(),
                iconSize: 16,
              ),
            ),
          ),
        ],
        if (_State.of(context).order.showFullAddress) ...[
          const _FullAddress(),
        ],
      ],
    );
  }
}

class _FullAddress extends StatelessObserverWidget {
  const _FullAddress();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (_State.of(context).order.apartment.availability &&
              _State.of(context).order.apartment.value.isNotEmpty) ...[
            Flexible(
              child: IconWithTextRow(
                text: 'кв. ${_State.of(context).order.apartment.value}',
                leading: AppIcons.number.iconColored(
                  color: AppSplitColor.violet(),
                  iconSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (_State.of(context).order.entrance.availability &&
              _State.of(context).order.entrance.value.isNotEmpty) ...[
            Flexible(
              child: IconWithTextRow(
                text: 'пд. ${_State.of(context).order.entrance.value}',
                leading: AppIcons.number.iconColored(
                  color: AppSplitColor.violet(),
                  iconSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (_State.of(context).order.floor.availability &&
              _State.of(context).order.floor.value.isNotEmpty)
            Flexible(
              child: IconWithTextRow(
                text: 'эт. ${_State.of(context).order.floor.value}',
                leading: AppIcons.number.iconColored(
                  color: AppSplitColor.violet(),
                  iconSize: 16,
                ),
              ),
            )
        ],
      ),
    );
  }
}

class _Client extends StatelessObserverWidget {
  const _Client();

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).order.clientName.value.isNotEmpty &&
        _State.of(context).order.clientName.availability) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconWithTextRow(
          text: 'Имя: ${_State.of(context).order.clientName.value}',
          leading: AppIcons.user.iconColored(
            color: AppSplitColor.cyan(),
            iconSize: 16,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _CallButton extends StatelessObserverWidget {
  const _CallButton();

  @override
  Widget build(BuildContext context) {
    if (!_State.of(context).status.canSeeCallButton) {
      return const SizedBox.shrink();
    } else {
      return CallButton(
        isSipActive: _State.of(context).isSipActive,
        phone: _State.of(context).order.phone.value,
        additionalPhones: _State.of(context).order.additionalPhones.value,
        onMakeCall: (phone) async {
          await _State.of(context).sipModel.makeCall(phone);
        },
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
}

class _OptionsToggle extends StatelessObserverWidget {
  const _OptionsToggle();

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).order.hasOptions) {
      return Stack(
        children: [
          _buildTapToCloseFab(context),
          _buildTapToOpenFab(context),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTapToCloseFab(BuildContext context) {
    return AppIcons.cross.fabButton(
      color: AppSplitColor.violetLight(),
      onPressed: _State.of(context).optionsToggle,
      size: const Size.square(40),
    );
  }

  Widget _buildTapToOpenFab(BuildContext context) {
    return IgnorePointer(
      ignoring: _State.of(context).showOptions,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _State.of(context).showOptions ? 0.7 : 1.0,
          _State.of(context).showOptions ? 0.7 : 1.0,
          1,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _State.of(context).showOptions ? 0.0 : 1.0,
          curve: const Interval(0.25, 1, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: AppIcons.more.fabButton(
            color: AppSplitColor.violetLight(),
            onPressed: _State.of(context).optionsToggle,
            size: const Size.square(40),
          ),
        ),
      ),
    );
  }
}

class _Options extends StatelessObserverWidget {
  const _Options();

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _State.of(context).expandAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const _CallButton(),
            if (_State.of(context).order.email.availability) ...[
              const SizedBox(width: 4),
              AppIcons.email.fabButton(
                color: _State.of(context).order.email.value.isEmpty
                    ? AppSplitColor.yellow()
                    : AppSplitColor.green(),
                onPressed: () => _State.of(context).changeEmail(context),
                size: const Size.square(40),
              ),
            ],
            if (_State.of(context).order.location.availability) ...[
              const SizedBox(width: 4),
              AppIcons.map.fabButton(
                color: AppSplitColor.violet(),
                onPressed: () => _State.of(context).openMap(context),
                size: const Size.square(40),
              ),
            ],
            if (_State.of(context)
                .order
                .canPickAdditionalOrder
                .availability) ...[
              const SizedBox(width: 4),
              AppIcons.add.fabButton(
                color: AppSplitColor.green(),
                onPressed: () => _State.of(context).pickAdditional(context),
                size: const Size.square(40),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
