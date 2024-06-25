import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'cashbox_admin_edit_screen.g.dart';

enum _ScreenMode { edit, create }

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.args) {
    mode = args.data != null ? _ScreenMode.edit : _ScreenMode.create;
    init();
  }

  late _ScreenMode mode;
  final CashBoxAdminEditScreenArgs args;
  final _repo = CashBoxRepository();
  final formKey = GlobalKey<FormState>();
  final incomeAmountCtrl = TextEditingController();
  final outcomeAmountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final cityStream = BehaviorSubject<int?>();
  final userStream = BehaviorSubject<int?>();
  final appointmentStream = BehaviorSubject<int?>();

  bool get hasChanges {
    switch (mode) {
      case _ScreenMode.edit:
        return int.tryParse(incomeAmountCtrl.text.trim()) !=
                args.data!.inputAmount &&
            int.tryParse(outcomeAmountCtrl.text.trim()) !=
                args.data!.outputAmount &&
            descriptionCtrl.text.trim() != args.data!.description &&
            submitted != args.data!.submitted;
      case _ScreenMode.create:
        return incomeAmountCtrl.text.trim().isNotEmpty &&
            outcomeAmountCtrl.text.trim().isNotEmpty &&
            descriptionCtrl.text.trim().isNotEmpty &&
            submitted == false;
    }
  }

  @observable
  bool _submitted = false;
  @computed
  bool get submitted => _submitted;
  @protected
  set submitted(bool value) => _submitted = value;

  @observable
  CashBoxOptions _options = CashBoxOptions.empty;
  @computed
  CashBoxOptions get options => _options;
  @protected
  set options(CashBoxOptions value) => _options = value;

  @observable
  int? _city;
  @computed
  int? get city => _city;
  @protected
  set city(int? value) => _city = value;

  @observable
  int? _user;
  @computed
  int? get user => _user;
  @protected
  set user(int? value) => _user = value;

  @observable
  int? _appointment;
  @computed
  int? get appointment => _appointment;
  @protected
  set appointment(int? value) => _appointment = value;

  @action
  Future<void> init() async {
    await withLoadingIndicator(() async {
      options = await _repo.getOptions();
    });
    if (mode == _ScreenMode.edit) {
      incomeAmountCtrl.text = args.data!.inputAmount.toString();
      outcomeAmountCtrl.text = args.data!.outputAmount.toString();
      descriptionCtrl.text = args.data!.description;
      submitted = args.data!.submitted;
      city = args.data!.cityId;
      if (options.cities.entries.isNotEmpty &&
          options.cities.entries.where((e) => e.key == city).isNotEmpty) {
        cityStream.add(city);
      } else {
        cityStream.add(null);
      }
      user = args.data!.userId;
      if (options.users.isNotEmpty &&
          options.users.entries.where((e) => e.key == user).isNotEmpty) {
        userStream.add(user);
      } else {
        userStream.add(null);
      }
    } else {
      if (options.cities.entries.isNotEmpty) {
        city = options.cities.entries.first.key;
        cityStream.add(city);
      }
      if (options.users.isNotEmpty) {
        user = options.users.keys.first;
        userStream.add(user);
      }
      if (options.appointments.isNotEmpty) {
        appointment = options.appointments.keys.first;
        appointmentStream.add(appointment);
      }
    }
  }

  @action
  void cityChange(int? city) {
    if (city == null) return;
    this.city = city;
    cityStream.add(city);
  }

  @action
  void userChange(int? user) {
    if (user == null) return;
    this.user = user;
    userStream.add(user);
  }

  @action
  void appointmentChange(int? appointment) {
    if (appointment == null) return;
    this.appointment = appointment;
    appointmentStream.add(appointment);
  }

  @action
  Future<void> onSubmit(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    var result = false;
    late CashBoxDetails body;
    if (formKey.currentState?.validate() == true) {
      try {
        await withLoadingIndicator(() async {
          if (mode == _ScreenMode.create) {
            body = CashBoxDetails.create(
              userId: user!,
              cityId: city!,
              inputAmount: int.parse(incomeAmountCtrl.text.trim()),
              outputAmount: int.parse(outcomeAmountCtrl.text.trim()),
              submitted: submitted,
              description: descriptionCtrl.text.trim(),
            );
            result = await _repo.addCashboxItem(body);
          }
          if (mode == _ScreenMode.edit) {
            body = CashBoxDetails.edit(
              id: args.data!.id!,
              orderId: args.data!.orderId,
              userId: user!,
              cityId: city!,
              inputAmount: int.parse(incomeAmountCtrl.text.trim()),
              outputAmount: int.parse(outcomeAmountCtrl.text.trim()),
              submitted: submitted,
              description: descriptionCtrl.text.trim(),
            );
            result = await _repo.patchCashboxItem(body);
          }
        });
        Navigator.of(context).pop(result ? body : null);
      } on DioException catch (e) {
        await showMessage(
          context,
          message: e is ApiException ? e.message : 'Неизвестная ошибка',
          type: AppMessageType.error,
        );
      }
    }
  }

  @action
  Future<bool> onWillPop() async {
    debugPrint(hasChanges.toString());
    return Future.value(true);
  }

  @action
  void dispose() {
    incomeAmountCtrl.dispose();
    outcomeAmountCtrl.dispose();
    descriptionCtrl.dispose();

    cityStream.close();
    userStream.close();
    appointmentStream.close();
  }
}

class CashBoxAdminEditScreenArgs {
  const CashBoxAdminEditScreenArgs({this.data});
  final CashBoxDetails? data;
}

class CashBoxAdminEditScreen extends StatelessWidget {
  const CashBoxAdminEditScreen({required this.args, super.key});

  final CashBoxAdminEditScreenArgs args;

  static const String routeName = '/cashbox_admin_edit_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(args),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  static const bigTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 19 / 16,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _State.of(context).onWillPop,
      child: Scaffold(
        appBar: AppToolbar(
          title: Text(
            _State.of(context).mode == _ScreenMode.create
                ? 'Новая касса'
                : '''Редактирование ${_State.of(context).args.data!.orderNumber != null ? '# ${_State.of(context).args.data!.orderNumber}' : ''}''',
            style: bigTextStyle,
          ),
        ),
        body: const SafeArea(
          top: false,
          child: _Form(),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Form(
                key: _State.of(context).formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextInputField(
                            controller: _State.of(context).incomeAmountCtrl,
                            validator: (value) => value?.isNotEmpty == true
                                ? null
                                : 'Обязательное поле',
                            keyboardType: TextInputType.number,
                            inputFormatters: numberFormatters,
                            onEditingComplete: () =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration:
                                const InputDecoration(labelText: 'Приход'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextInputField(
                            controller: _State.of(context).outcomeAmountCtrl,
                            validator: (value) => value?.isNotEmpty == true
                                ? null
                                : 'Обязательное поле',
                            keyboardType: TextInputType.number,
                            inputFormatters: numberFormatters,
                            onEditingComplete: () =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration:
                                const InputDecoration(labelText: 'Расход'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<int?>(
                      stream: _State.of(context).cityStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AppDropdownField<int>(
                            label: 'Город',
                            value: _State.of(context).city!,
                            items: _State.of(context).options.cities.entries,
                            onChange: _State.of(context).cityChange,
                          );
                        } else if (_State.of(context)
                                .args
                                .data
                                ?.cityName
                                .isNotEmpty ==
                            true) {
                          return AppTextInputField(
                            enabled: false,
                            decoration:
                                const InputDecoration(labelText: 'Город'),
                            initialValue:
                                _State.of(context).args.data?.cityName ?? '',
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    StreamBuilder<int?>(
                      stream: _State.of(context).userStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AppDropdownField<int>(
                            label: 'Сотрудник',
                            value: _State.of(context).user!,
                            items: _State.of(context).options.users.entries,
                            onChange: _State.of(context).userChange,
                          );
                        } else if (_State.of(context)
                                .args
                                .data
                                ?.userName
                                .isNotEmpty ==
                            true) {
                          return AppTextInputField(
                            enabled: false,
                            decoration:
                                const InputDecoration(labelText: 'Сотрудник'),
                            initialValue:
                                _State.of(context).args.data?.userName ?? '',
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    StreamBuilder<int?>(
                      stream: _State.of(context).appointmentStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return AppDropdownField<int>(
                            label: 'Назначение',
                            value: _State.of(context).appointment!,
                            items:
                                _State.of(context).options.appointments.entries,
                            onChange: _State.of(context).appointmentChange,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    Observer(
                      builder: (context) => AppSwitch(
                        leading: Text(
                          'Статус задачи:',
                          style: AppTextStyle.regularHeadline.style(context),
                        ),
                        statusString:
                            _State.of(context).submitted ? 'Сдал' : 'Не сдал',
                        isSwitched: _State.of(context).submitted,
                        onChanged: (value) {
                          _State.of(context).submitted = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextInputField(
                      controller: _State.of(context).descriptionCtrl,
                      maxLines: 10,
                      keyboardType: TextInputType.text,
                      onEditingComplete: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            color: AppColors.blackContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton.green(
                text: 'Сохранить',
                onPressed: () => _State.of(context).onSubmit(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
