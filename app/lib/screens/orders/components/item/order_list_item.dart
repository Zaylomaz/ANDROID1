import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:rempc/screens/close_order/close_order_screen.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'order_list_item.g.dart';

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
    AppOrder order,
    this.updateOrderPage,
    this.sipModel,
    this._vsync,
  ) {
    this.order = order;
    status = order.status;
    isSipActive = sipModel.isActive;
    sipModel.addListener(_sipListener);
    _emailCtrl.text = order.email;
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
  AppOrder _order = AppOrder.empty;
  @computed
  AppOrder get order => _order;
  @protected
  set order(AppOrder value) => _order = value;

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
      (order.apartment.isNotEmpty ||
          order.entrance.isNotEmpty ||
          order.floor.isNotEmpty);

  bool get canSeeMap =>
      order.lat is double && order.lng is double && status.canSeeMap;

  Future openMap(BuildContext context) async {
    final isLaunched = await Coords(order.lat!, order.lng!).tryLaunch(context);
    if (!isLaunched) {
      final googleUrl =
          '''https://www.google.com/maps/search/?api=1&query=${order.lat},${order.lng}''';
      if (await canLaunchUrlString(googleUrl)) {
        await launchUrlString(googleUrl);
      } else {
        throw Exception('Could not open the map.');
      }
    }
  }

  @action
  Future<void> changeEmail(BuildContext context) async {
    final email = await showDialog<String?>(
      context: context,
      builder: (context) {
        const inputBorder = OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xffa7a7a7),
          ),
        );

        const decoration = InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(
            color: Color(0xffFAFBFF),
          ),
          alignLabelWithHint: true,
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder,
          disabledBorder: inputBorder,
          suffixIcon: Icon(
            Icons.email,
            color: Colors.white,
            size: 12,
          ),
          contentPadding: EdgeInsets.all(12),
        );

        const inputTextStyle = TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 19 / 16,
          color: Colors.white,
        );

        /// TODO check design
        return SimpleDialog(
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          backgroundColor: AppColors.blackContainer,
          children: [
            TextFormField(
              controller: _emailCtrl,
              autofocus: true,
              style: inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: decoration,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                const pattern =
                    r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                    r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                    r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                    r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                    r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                    r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                    r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
                final regex = RegExp(pattern);

                return value!.isNotEmpty && !regex.hasMatch(value)
                    ? 'Ошибка валидации'
                    : null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_emailCtrl.text);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
    if (email?.isNotEmpty == true) {
      await withLoadingIndicator(() async {
        order = await _repo.setOrderEmail(order.id, email!);
      });
    }
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
        final success = await _repo.setOrderStatus(order.id, status.asInt);
        if (success) {
          this.status = status;
        } else {
          updateOrderPage();
        }
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
      arguments: CloseOrderScreenArgs(order.id, order.orderNumber),
    );

    if (isClosed == true) {
      updateOrderPage();
    }
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

class OrderListItem extends StatefulWidget {
  const OrderListItem({
    required this.order,
    required this.updateOrderPage,
    super.key,
  });

  final AppOrder order;
  final VoidCallback updateOrderPage;

  @override
  State<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem>
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

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        '#${_State.of(context).order.orderNumber}',
                        style: AppTextStyle.regularSubHeadline.style(context),
                      ),
                      const SizedBox(height: 8),
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
          if (_State.of(context).status.actionStatus !=
              AppOrderStatus.undefined) {
            _State.of(context).setStatus(
              context,
              _State.of(context).status.actionStatus,
            );
          } else if (_State.of(context).status == AppOrderStatus.s11) {
            _State.of(context).closeOrder(context);
          }
        },
      ),
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime();

  @override
  Widget build(BuildContext context) {
    final dateString =
        DateFormat('dd MMMM yyyy', 'ru').format(_State.of(context).order.date);
    final time = _State.of(context).order.time;
    return IconWithTextRow(
      leading: AppIcons.clock.iconColored(
        color: AppSplitColor.red(),
        iconSize: 16,
      ),
      textColor: AppColors.red,
      text:
          '''$dateString${time?.isNotEmpty == true ? ' / ${_State.of(context).order.time}' : ''}''',
    );
  }
}

class _Info extends StatelessObserverWidget {
  const _Info();

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).order.infoForMasterPrevent.isNotEmpty &&
        _State.of(context).status.canSeeInfoForMasterPrevent) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconWithTextRow(
          text:
              '''Инфо (предв.): ${_State.of(context).order.infoForMasterPrevent}''',
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
    if (_State.of(context).order.infoForMasterFact.isNotEmpty &&
        _State.of(context).status.canSeeInfoForMasterFact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconWithTextRow(
          text:
              '''Инфо (факт.): ${_State.of(context).order.infoForMasterFact}''',
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
    if (_State.of(context).status.canSeeAddress) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_State.of(context).order.district.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IconWithTextRow(
                text: 'Район: ${_State.of(context).order.district.trim()}',
                leading: AppIcons.map
                    .iconColored(color: AppSplitColor.violet(), iconSize: 16),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IconWithTextRow(
              text:
                  '''Адрес: ${_State.of(context).order.street}, ${_State.of(context).order.building}''',
              leading: AppIcons.location.iconColored(
                color: AppSplitColor.violet(),
                iconSize: 16,
              ),
            ),
          ),
          if (_State.of(context).canSeeFullAddress) ...[
            const _FullAddress(),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _FullAddress extends StatelessWidget {
  const _FullAddress();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Flexible(
            child: IconWithTextRow(
              text: 'кв. ${_State.of(context).order.apartment}',
              leading: AppIcons.number.iconColored(
                color: AppSplitColor.violet(),
                iconSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: IconWithTextRow(
              text: 'пд. ${_State.of(context).order.entrance}',
              leading: AppIcons.number.iconColored(
                color: AppSplitColor.violet(),
                iconSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: IconWithTextRow(
              text: 'эт. ${_State.of(context).order.floor}',
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
    if (_State.of(context).order.infoForMasterFact.isNotEmpty &&
        _State.of(context).status.canSeeInfoForMasterFact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconWithTextRow(
          text: 'Имя: ${_State.of(context).order.clientName}',
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
        phone: _State.of(context).order.phone,
        additionalPhones: _State.of(context).order.additionalPhones,
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
    return Stack(
      children: [
        _buildTapToCloseFab(context),
        _buildTapToOpenFab(context),
      ],
    );
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
            if (_State.of(context).status.canSetEmail) ...[
              const SizedBox(width: 4),
              AppIcons.email.fabButton(
                color: _State.of(context).order.email.isEmpty
                    ? AppSplitColor.yellow()
                    : AppSplitColor.green(),
                onPressed: () => _State.of(context).changeEmail(context),
                size: const Size.square(40),
              ),
            ],
            if (_State.of(context).canSeeMap) ...[
              const SizedBox(width: 4),
              AppIcons.map.fabButton(
                color: AppSplitColor.violet(),
                onPressed: () => _State.of(context).openMap(context),
                size: const Size.square(40),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
