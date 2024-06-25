import 'dart:async';

import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:rempc/components/form_error.dart';
import 'package:rempc/screens/access_deny/access_deny_screen.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'close_order_screen.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.args);

  final CloseOrderScreenArgs args;

  final _repo = OrdersRepository();
  final dropdownStatusStream = BehaviorSubject<int?>();
  final timeslotStream = BehaviorSubject<TimeSlot?>();
  final dateCtrl = TextEditingController();

  @observable
  AppOrder _order = AppOrder.empty;
  @computed
  AppOrder get order => _order;
  @protected
  set order(AppOrder value) => _order = value;

  @observable
  int? _dropdownOrderStatus;
  @computed
  int? get dropdownOrderStatus => _dropdownOrderStatus;
  @protected
  set dropdownOrderStatus(int? value) => _dropdownOrderStatus = value;

  @observable
  List<String?> _errors = [];
  @computed
  List<String?> get errors => _errors;
  @protected
  set errors(List<String?> value) => _errors = value;

  @observable
  String orderSum = '';
  @observable
  String phone = '';
  @observable
  String additionalPhone = '';
  @observable
  String customerName = '';
  @observable
  String customerStreet = '';
  @observable
  String customerBuilding = '';
  @observable
  String customerApartment = '';
  @observable
  String customerEntrance = '';
  @observable
  String customerFloor = '';
  @observable
  String techMark = '';
  @observable
  String techModel = '';
  @observable
  String techSerial = '';
  @observable
  String techBiosPassword = '';
  @observable
  String declaredDefect = '';
  @observable
  String masterComment = '';
  @observable
  String date = '';
  @observable
  TimeSlot time = TimeSlot.s10;
  @observable
  bool isTechChargerChecked = false;
  @observable
  bool isTechVisualDefectsChecked = false;
  @observable
  bool isTechCracksChecked = false;
  @observable
  bool isTechIntegrityUsbChecked = false;
  @observable
  bool isTechAutopsyTracesChecked = false;
  @observable
  bool isTechFloodingMarksChecked = false;
  @observable
  bool isTechBatteryAvailabilityChecked = false;
  @observable
  bool isRushOrderChecked = false;
  @observable
  XFile? orderCheckFile;

  @action
  Future<void> getOrderDetails(BuildContext context) async {
    try {
      order = await _repo.getOrderById(args.orderId);
      dropdownOrderStatus = order.availableCloseStatus.entries.first.value;
      dropdownStatusStream.add(dropdownOrderStatus);
      timeslotStream.add(TimeSlot.s10);
      if (order.additionalPhones.isNotEmpty) {
        additionalPhone = order.additionalPhones.first;
      }
      if (order.clientName.isNotEmpty) {
        customerName = order.clientName;
      }
      if (order.street.isNotEmpty) {
        customerStreet = order.street;
      }
      if (order.building.isNotEmpty) {
        customerBuilding = order.building;
      }
      if (order.apartment.isNotEmpty) {
        customerApartment = order.apartment;
      }
      if (order.entrance.isNotEmpty) {
        customerEntrance = order.entrance;
      }
      if (order.floor.isNotEmpty) {
        customerFloor = order.floor;
      }
    } catch (e) {
      if (e is DioException &&
          e.error is ApiException &&
          e.message?.isNotEmpty == true) {
        await showMessage(
          context,
          message: e.message!,
          type: AppMessageType.error,
          prefixIcon: AppIcons.alert.widget(
            color: AppColors.white,
          ),
        );
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
      if (e is TooManyRequestsException) {
        unawaited(
            Navigator.of(context).pushNamed(ToManyRequestScreen.routeName));
      }
      if (e is DioException && e.response?.statusCode == 404) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
    }
  }

  @action
  Future<void> storeCheckOrder(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (orderCheckFile == null || orderSum.isEmpty) {
      await showMessage(
        context,
        message:
            orderCheckFile == null ? 'Добавьте фото чека' : 'Введите сумму',
        prefixIcon:
            (orderCheckFile == null ? AppIcons.camera : AppIcons.check).widget(
          color: AppColors.white,
        ),
      );
      return;
    }
    try {
      await withLoadingIndicator(() async {
        final position = await getAndroidPosition();
        await _repo.setOrderCloseCheck(
          orderId: order.id,
          status: 35,
          filePath: orderCheckFile!.path,
          orderSum: orderSum,
          position: position,
          comment: masterComment,
        );
        Navigator.of(context).pop(true);
      });
    } catch (e) {
      if (e is ApiException) {
        await showMessage(
          context,
          message: e.message,
          type: AppMessageType.error,
          prefixIcon: AppIcons.alert.widget(
            color: AppColors.white,
          ),
        );
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
      if (e is TooManyRequestsException) {
        unawaited(
            Navigator.of(context).pushNamed(ToManyRequestScreen.routeName));
      }
    }
  }

  @action
  Future<void> closeOrderRework(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (date.isEmpty || orderSum.isEmpty) {
      await showMessage(
        context,
        message: date.isEmpty ? 'Добавьте дату' : 'Введите сумму',
        type: AppMessageType.error,
        prefixIcon: (date.isEmpty ? AppIcons.calendar : AppIcons.check).widget(
          color: AppColors.white,
        ),
      );
      return;
    }
    try {
      await withLoadingIndicator(() async {
        final position = await getAndroidPosition();
        await _repo.closeOrderRework(
          orderId: order.id,
          orderSum: int.parse(orderSum),
          date: date,
          time: time,
          position: position,
          comment: masterComment,
        );
        Navigator.of(context).pop(true);
      });
    } catch (e) {
      if (e is ApiException) {
        await showMessage(
          context,
          message: e.message,
          type: AppMessageType.error,
          prefixIcon: AppIcons.alert.widget(
            color: AppColors.white,
          ),
        );
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
      if (e is TooManyRequestsException) {
        unawaited(
            Navigator.of(context).pushNamed(ToManyRequestScreen.routeName));
      }
    }
  }

  @action
  Future<void> closeOrderWarranty(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (orderCheckFile == null || masterComment.isEmpty) {
      await showMessage(
        context,
        message: orderCheckFile == null
            ? 'Добавьте фото чека'
            : 'Добавьте комментарий',
        type: AppMessageType.error,
        prefixIcon:
            (orderCheckFile == null ? AppIcons.camera : AppIcons.message)
                .widget(
          color: AppColors.white,
        ),
      );
      return;
    }
    try {
      await withLoadingIndicator(() async {
        final position = await getAndroidPosition();
        await _repo.closeOrderWarranty(
          orderId: order.id,
          comment: masterComment,
          filePath: orderCheckFile!.path,
          position: position,
        );
        Navigator.of(context).pop(true);
      });
    } catch (e) {
      if (e is ApiException) {
        await showMessage(
          context,
          message: e.message,
          type: AppMessageType.error,
          prefixIcon: AppIcons.alert.widget(
            color: AppColors.white,
          ),
        );
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
      if (e is TooManyRequestsException) {
        unawaited(
            Navigator.of(context).pushNamed(ToManyRequestScreen.routeName));
      }
    }
  }

  @action
  Future<void> storePickupOrder(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (orderCheckFile == null) {
      await showMessage(
        context,
        message: 'Добавте фото',
        type: AppMessageType.error,
        prefixIcon: AppIcons.camera.widget(
          color: AppColors.white,
        ),
      );
      return;
    }
    try {
      await withLoadingIndicator(() async {
        final position = await getAndroidPosition();
        await OrdersRepository().setOrderClosePickup(
          orderId: order.id,
          status: 35,
          filePath: orderCheckFile!.path,
          orderSum: orderSum,
          additionalPhone: additionalPhone,
          customerName: customerName,
          customerStreet: customerStreet,
          customerBuilding: customerBuilding,
          customerApartment: customerApartment,
          customerEntrance: customerEntrance,
          customerFloor: customerFloor,
          techMark: techMark,
          techModel: techModel,
          techSerial: techSerial,
          techBiosPassword: techBiosPassword,
          declaredDefect: declaredDefect,
          masterComment: masterComment,
          isTechChargerChecked: isTechChargerChecked,
          isTechVisualDefectsChecked: isTechVisualDefectsChecked,
          isTechCracksChecked: isTechCracksChecked,
          isTechIntegrityUsbChecked: isTechIntegrityUsbChecked,
          isTechAutopsyTracesChecked: isTechAutopsyTracesChecked,
          isTechFloodingMarksChecked: isTechFloodingMarksChecked,
          isTechBatteryAvailabilityChecked: isTechBatteryAvailabilityChecked,
          isRushOrderChecked: isRushOrderChecked,
          position: position,
        );

        Navigator.of(context).pop(true);
      });
    } catch (e) {
      if (e is ApiException) {
        errors = [e.message];
        await showMessage(
          context,
          message: e.message,
          type: AppMessageType.error,
          prefixIcon: AppIcons.alert.widget(
            color: AppColors.white,
          ),
        );
      }
      if (e is DioException && e.response?.statusCode == 404) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
      }
      if (e is TooManyRequestsException) {
        unawaited(
            Navigator.of(context).pushNamed(ToManyRequestScreen.routeName));
      }
      if (e is ApiException) {
        errors = [e.message];
      }
    }
  }

  @action
  void changeDropdownValue(int? status) {
    if (status is int) {
      dropdownOrderStatus = status;
      dropdownStatusStream.add(dropdownOrderStatus);
    }
  }

  @action
  void changeTimeSlot(TimeSlot? slot) {
    if (slot is TimeSlot) {
      time = slot;
      timeslotStream.add(time);
    }
  }

  @action
  Future<void> uploadFile(BuildContext context,
      {bool useInAppCamera = false}) async {
    final pickedFile = useInAppCamera
        ? await AppImagePicker.getImage(context)
        : await AppImagePicker.getCameraImage(context);
    if (pickedFile != null) {
      orderCheckFile = pickedFile;
    }
    return;
  }

  @action
  void dispose() {
    dateCtrl.dispose();
  }
}

class CloseOrderScreenArgs {
  const CloseOrderScreenArgs(this.orderId, this.orderNumber);
  final int orderId;
  final int orderNumber;
}

class CloseOrderScreen extends StatelessWidget {
  const CloseOrderScreen({required this.args, super.key});

  final CloseOrderScreenArgs args;

  static const String routeName = '/close_order_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(args)..getOrderDetails(context),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  static final numberFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
    FilteringTextInputFormatter.digitsOnly
  ];

  static final lengthFormatters = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(500)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: Text('Заказ #${_State.of(context).args.orderNumber}'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _DropDownField(),
            ),
            Expanded(
              child: Observer(
                builder: (context) {
                  switch (_State.of(context).dropdownOrderStatus) {
                    case 35:
                      return const _CheckForm();
                    case 6:
                      return const _PickUpForm();
                    case 7:
                      return const _ReworkForm();
                    case 5:
                      return const _WarrantyForm();
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropDownField extends StatelessObserverWidget {
  const _DropDownField();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: _State.of(context).dropdownStatusStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDropdownField<int?>(
                label: 'Тип закрытия',
                items: _State.of(context)
                    .order
                    .availableCloseStatus
                    .entries
                    .map((e) => MapEntry(e.value, e.key)),
                value: _State.of(context).dropdownOrderStatus,
                onChange: _State.of(context).changeDropdownValue,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FormLayout extends StatelessWidget {
  const _FormLayout({
    required this.children,
    required this.button,
  });

  final List<Widget> children;
  final _BottomButtonContainer button;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 64,
          child: ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            children: children,
          ),
        ),
        button,
      ],
    );
  }
}

class _BottomButtonContainer extends StatelessWidget {
  const _BottomButtonContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AppMaterialBox(
        elevation: 6,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              child,
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckForm extends StatelessObserverWidget {
  const _CheckForm();

  @override
  Widget build(BuildContext context) {
    return _FormLayout(
      button: _BottomButtonContainer(
        child: PrimaryButton.green(
          onPressed: () => _State.of(context).storeCheckOrder(context),
          text: 'Сохранить',
        ),
      ),
      children: [
        AppTextInputField(
          keyboardType: TextInputType.number,
          onSaved: (newValue) => _State.of(context).orderSum = newValue ?? '',
          onChanged: (value) {
            _State.of(context).orderSum = value;
          },
          inputFormatters: _Content.numberFormatters,
          decoration: const InputDecoration(
            labelText: 'Сумма',
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фото чека',
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PhotoPicker(
                    file: _State.of(context).orderCheckFile?.toFile(),
                    onTap: () => _State.of(context).uploadFile(context),
                    onLongPress: () => _State.of(context).uploadFile(
                      context,
                      useInAppCamera: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_State.of(context).orderCheckFile != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PrimaryButton.violet(
                            onPressed: () =>
                                _State.of(context).uploadFile(context),
                            onLongPress: () => _State.of(context).uploadFile(
                              context,
                              useInAppCamera: true,
                            ),
                            text: 'Изменить фото чека',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton.red(
                            onPressed: () =>
                                _State.of(context).orderCheckFile = null,
                            text: 'Удалить фото чека',
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          inputFormatters: _Content.lengthFormatters,
          minLines: 3,
          maxLines: 10,
          onSaved: (newValue) =>
              _State.of(context).masterComment = newValue ?? '',
          onChanged: (value) {
            _State.of(context).masterComment = value;
          },
          initialValue: _State.of(context).masterComment,
          decoration: const InputDecoration(
            labelText: 'Комментарий мастера *',
          ),
        ),
        const SizedBox(height: 16),
        FormError(errors: _State.of(context).errors),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _PickUpForm extends StatelessObserverWidget {
  const _PickUpForm();

  @override
  Widget build(BuildContext context) {
    return _FormLayout(
      button: _BottomButtonContainer(
        child: PrimaryButton.green(
          text: 'Сохранить',
          onPressed: () => _State.of(context).storePickupOrder(context),
        ),
      ),
      children: [
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) {
            _State.of(context).customerName = newValue ?? '';
          },
          onChanged: (value) {
            _State.of(context).customerName = value;
          },
          initialValue: _State.of(context).customerName,
          decoration: const InputDecoration(
            labelText: 'ФИО *',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) =>
              _State.of(context).customerStreet = newValue ?? '',
          onChanged: (value) {
            _State.of(context).customerStreet = value;
          },
          initialValue: _State.of(context).customerStreet,
          decoration: const InputDecoration(
            labelText: 'Улица',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) =>
              _State.of(context).customerBuilding = newValue ?? '',
          onChanged: (value) {
            _State.of(context).customerBuilding = value;
          },
          initialValue: _State.of(context).customerBuilding,
          decoration: const InputDecoration(
            labelText: 'Дом',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) =>
              _State.of(context).customerApartment = newValue ?? '',
          onChanged: (value) {
            _State.of(context).customerApartment = value;
          },
          initialValue: _State.of(context).customerApartment,
          decoration: const InputDecoration(
            labelText: 'Квартира',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) =>
              _State.of(context).customerEntrance = newValue ?? '',
          onChanged: (value) {
            _State.of(context).customerEntrance = value;
          },
          initialValue: _State.of(context).customerEntrance,
          decoration: const InputDecoration(
            labelText: 'Подъезд',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) =>
              _State.of(context).customerFloor = newValue ?? '',
          onChanged: (value) {
            _State.of(context).customerFloor = value;
          },
          initialValue: _State.of(context).customerFloor,
          decoration: const InputDecoration(
            labelText: 'Этаж',
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Тип техники',
          style: AppTextStyle.regularHeadline
              .style(context, AppColors.violetLight),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) => _State.of(context).techMark = newValue ?? '',
          onChanged: (value) {
            _State.of(context).techMark = value;
          },
          initialValue: _State.of(context).techMark,
          decoration: const InputDecoration(
            labelText: 'Марка *',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) => _State.of(context).techModel = newValue ?? '',
          onChanged: (value) {
            _State.of(context).techModel = value;
          },
          initialValue: _State.of(context).techModel,
          decoration: const InputDecoration(
            labelText: 'Модель *',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) => _State.of(context).techSerial = newValue ?? '',
          onChanged: (value) {
            _State.of(context).techSerial = value;
          },
          initialValue: _State.of(context).techSerial,
          decoration: const InputDecoration(
            labelText: 'Серийный номер *',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) =>
              _State.of(context).techBiosPassword = newValue ?? '',
          onChanged: (value) {
            _State.of(context).techBiosPassword = value;
          },
          initialValue: _State.of(context).techBiosPassword,
          decoration: const InputDecoration(
            labelText: 'Пароль биоса',
          ),
        ),
        const SizedBox(height: 16),
        AppSwitch(
          leading: const Text(
            'Зарядное',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          statusString:
              _State.of(context).isTechChargerChecked ? 'Есть' : 'Нет',
          isSwitched: _State.of(context).isTechChargerChecked,
          onChanged: (value) {
            _State.of(context).isTechChargerChecked = value;
          },
        ),
        const SizedBox(height: 8),
        AppSwitch(
          leading: const Text('Визуальные дефекты',
              style: TextStyle(color: Colors.white)),
          isSwitched: _State.of(context).isTechVisualDefectsChecked,
          statusString:
              _State.of(context).isTechVisualDefectsChecked ? 'Есть' : 'Нет',
          onChanged: (value) {
            _State.of(context).isTechVisualDefectsChecked = value;
          },
        ),
        const SizedBox(height: 8),
        AppSwitch(
          leading: const Text(
            'Трещины разломы',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          isSwitched: _State.of(context).isTechCracksChecked,
          statusString: _State.of(context).isTechCracksChecked ? 'Есть' : 'Нет',
          onChanged: (value) {
            _State.of(context).isTechCracksChecked = value;
          },
        ),
        const SizedBox(height: 8),
        AppSwitch(
          leading: const Text(
            'Целостность портов usb',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          isSwitched: _State.of(context).isTechIntegrityUsbChecked,
          statusString:
              _State.of(context).isTechIntegrityUsbChecked ? 'Есть' : 'Нет',
          onChanged: (value) {
            _State.of(context).isTechIntegrityUsbChecked = value;
          },
        ),
        const SizedBox(height: 8),
        AppSwitch(
          leading: const Text(
            'Следы вскрытия',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          isSwitched: _State.of(context).isTechAutopsyTracesChecked,
          statusString:
              _State.of(context).isTechAutopsyTracesChecked ? 'Есть' : 'Нет',
          onChanged: (value) {
            _State.of(context).isTechAutopsyTracesChecked = value;
          },
        ),
        const SizedBox(height: 8),
        AppSwitch(
          leading: const Text(
            'Следы залития',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          isSwitched: _State.of(context).isTechFloodingMarksChecked,
          statusString:
              _State.of(context).isTechFloodingMarksChecked ? 'Есть' : 'Нет',
          onChanged: (value) {
            _State.of(context).isTechFloodingMarksChecked = value;
          },
        ),
        const SizedBox(height: 8),
        AppSwitch(
          leading: const Text(
            'Наличие акб',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          statusString: _State.of(context).isTechBatteryAvailabilityChecked
              ? 'Есть'
              : 'Нет',
          isSwitched: _State.of(context).isTechBatteryAvailabilityChecked,
          onChanged: (value) {
            _State.of(context).isTechBatteryAvailabilityChecked = value;
          },
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.text,
          onSaved: (newValue) =>
              _State.of(context).declaredDefect = newValue ?? '',
          onChanged: (value) {
            _State.of(context).declaredDefect = value;
          },
          initialValue: _State.of(context).declaredDefect,
          decoration: const InputDecoration(
            labelText: 'Заявленная неисправность *',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          inputFormatters: _Content.lengthFormatters,
          minLines: 3,
          maxLines: 10,
          onSaved: (newValue) =>
              _State.of(context).masterComment = newValue ?? '',
          onChanged: (value) {
            _State.of(context).masterComment = value;
          },
          initialValue: _State.of(context).masterComment,
          decoration: const InputDecoration(
            labelText: 'Комментарий мастера *',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.number,
          onSaved: (newValue) => _State.of(context).orderSum = newValue ?? '',
          onChanged: (value) {
            _State.of(context).orderSum = value;
          },
          decoration: const InputDecoration(
            labelText: 'Сумма',
          ),
        ),
        const SizedBox(height: 16),
        AppSwitch(
          leading: const Text(
            'Срочный заказ',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          isSwitched: _State.of(context).isRushOrderChecked,
          statusString: _State.of(context).isRushOrderChecked ? 'Да' : 'Нет',
          onChanged: (value) {
            _State.of(context).isRushOrderChecked = value;
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фото чека',
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PhotoPicker(
                    file: _State.of(context).orderCheckFile?.toFile(),
                    onTap: () => _State.of(context).uploadFile(context),
                    onLongPress: () => _State.of(context).uploadFile(
                      context,
                      useInAppCamera: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_State.of(context).orderCheckFile != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PrimaryButton.violet(
                            onPressed: () =>
                                _State.of(context).uploadFile(context),
                            onLongPress: () => _State.of(context).uploadFile(
                              context,
                              useInAppCamera: true,
                            ),
                            text: 'Изменить фото чека',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton.red(
                            onPressed: () =>
                                _State.of(context).orderCheckFile = null,
                            text: 'Удалить фото чека',
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FormError(errors: _State.of(context).errors),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ReworkForm extends StatelessObserverWidget {
  const _ReworkForm();

  @override
  Widget build(BuildContext context) {
    return _FormLayout(
      button: _BottomButtonContainer(
        child: PrimaryButton.green(
          onPressed: () => _State.of(context).closeOrderRework(context),
          text: 'Сохранить',
        ),
      ),
      children: [
        AppTextInputField(
          keyboardType: TextInputType.number,
          onSaved: (newValue) => _State.of(context).orderSum = newValue ?? '',
          onChanged: (value) {
            _State.of(context).orderSum = value;
          },
          inputFormatters: _Content.numberFormatters,
          decoration: const InputDecoration(
            labelText: 'Сумма',
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Positioned(
              left: 0,
              right: 46,
              top: 0,
              bottom: 0,
              child: InkWell(
                onTap: () async {
                  try {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                        locale: const Locale.fromSubtags(languageCode: 'ru'),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark(useMaterial3: true),
                            child: child!,
                          );
                        });
                    if (date != null) {
                      _State.of(context).dateCtrl.text =
                          DateFormat('dd MMM yyyy', 'ru').format(date);
                      _State.of(context).date =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                child: const SizedBox.expand(),
              ),
            ),
            IgnorePointer(
              child: AppTextInputField(
                controller: _State.of(context).dateCtrl,
                keyboardType: TextInputType.text,
                onEditingComplete: () =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(labelText: 'Дата'),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: AppIcons.close.fabButton(
                color: AppSplitColor.violet(),
                onPressed: () {
                  _State.of(context).dateCtrl.text = '';
                  _State.of(context).date = '';
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<TimeSlot?>(
          stream: _State.of(context).timeslotStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppDropdownField<TimeSlot>(
                    label: 'Время',
                    items: TimeSlot.values.map((e) => MapEntry(e, e.slot)),
                    value: _State.of(context).time,
                    onChange: _State.of(context).changeTimeSlot,
                  ),
                  const SizedBox(height: 32),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          inputFormatters: _Content.lengthFormatters,
          minLines: 3,
          maxLines: 10,
          onSaved: (newValue) =>
              _State.of(context).masterComment = newValue ?? '',
          onChanged: (value) {
            _State.of(context).masterComment = value;
          },
          initialValue: _State.of(context).masterComment,
          decoration: const InputDecoration(
            labelText: 'Комментарий мастера *',
          ),
        ),
        const SizedBox(height: 16),
        FormError(errors: _State.of(context).errors),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _WarrantyForm extends StatelessObserverWidget {
  const _WarrantyForm();

  @override
  Widget build(BuildContext context) {
    return _FormLayout(
      button: _BottomButtonContainer(
        child: PrimaryButton.green(
          onPressed: () => _State.of(context).closeOrderWarranty(context),
          text: 'Сохранить',
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фото чека',
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PhotoPicker(
                    file: _State.of(context).orderCheckFile?.toFile(),
                    onTap: () => _State.of(context).uploadFile(context),
                    onLongPress: () => _State.of(context).uploadFile(
                      context,
                      useInAppCamera: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_State.of(context).orderCheckFile != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PrimaryButton.violet(
                            onPressed: () =>
                                _State.of(context).uploadFile(context),
                            onLongPress: () => _State.of(context).uploadFile(
                              context,
                              useInAppCamera: true,
                            ),
                            text: 'Изменить фото чека',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton.red(
                            onPressed: () =>
                                _State.of(context).orderCheckFile = null,
                            text: 'Удалить фото чека',
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          inputFormatters: _Content.lengthFormatters,
          minLines: 3,
          maxLines: 10,
          onSaved: (newValue) =>
              _State.of(context).masterComment = newValue ?? '',
          onChanged: (value) {
            _State.of(context).masterComment = value;
          },
          decoration: const InputDecoration(
            labelText: 'Комментарий мастера *',
          ),
        ),
        const SizedBox(height: 16),
        FormError(errors: _State.of(context).errors),
        const SizedBox(height: 32),
      ],
    );
  }
}
