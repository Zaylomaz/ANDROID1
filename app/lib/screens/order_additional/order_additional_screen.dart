import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:rempc/components/form_error.dart';
import 'package:rempc/screens/access_deny/access_deny_screen.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'order_additional_screen.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.args);

  final OrderAdditionalScreenArgs args;

  final _repo = OrdersRepository();

  final formKey = GlobalKey<FormState>();

  final clientNameCtrl = TextEditingController();
  final mainPhoneCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final buildingCtrl = TextEditingController();
  final apartmentCtrl = TextEditingController();
  final entranceCtrl = TextEditingController();
  final floorCtrl = TextEditingController();
  final defectCtrl = TextEditingController();

  @observable
  AdditionalOrderInfo _order = AdditionalOrderInfo.empty;
  @computed
  AdditionalOrderInfo get order => _order;
  @protected
  set order(AdditionalOrderInfo value) => _order = value;

  @observable
  List<String?> _errors = [];
  @computed
  List<String?> get errors => _errors;
  @protected
  set errors(List<String?> value) => _errors = value;

  @observable
  int? _selectedCityId;
  @computed
  int? get selectedCityId => _selectedCityId;
  @protected
  set selectedCityId(int? value) => _selectedCityId = value;

  @observable
  int? _selectedThemeId;
  @computed
  int? get selectedThemeId => _selectedThemeId;
  @protected
  set selectedThemeId(int? value) => _selectedThemeId = value;

  @observable
  int? _selectedTechniqueId;
  @computed
  int? get selectedTechniqueId => _selectedTechniqueId;
  @protected
  set selectedTechniqueId(int? value) => _selectedTechniqueId = value;

  @observable
  bool _isValid = false;
  @computed
  bool get isValid => _isValid;
  @protected
  set isValid(bool value) => _isValid = value;

  @action
  Future<void> init(BuildContext context) async {
    try {
      order = await _repo.getAdditionalOrderById(args.orderId);
      clientNameCtrl
        ..addListener(_formValidation)
        ..text = order.clientName;
      mainPhoneCtrl.text = order.phone;
      phoneCtrl.addListener(_formValidation);
      districtCtrl
        ..addListener(_formValidation)
        ..text = order.district;
      streetCtrl
        ..addListener(_formValidation)
        ..text = order.street;
      buildingCtrl
        ..addListener(_formValidation)
        ..text = order.building;
      entranceCtrl
        ..addListener(_formValidation)
        ..text = order.entrance;
      floorCtrl
        ..addListener(_formValidation)
        ..text = order.floor;
      apartmentCtrl
        ..addListener(_formValidation)
        ..text = order.apartment;
      defectCtrl
        ..addListener(_formValidation)
        ..text = order.defect;
      selectedCityId = order.cityId != -1
          ? order.cityId
          : order.options.cities.entries.first.key;
      selectedThemeId = order.themId != -1
          ? order.themId
          : order.options.themes.entries.first.key;
      selectedTechniqueId = order.techniqueId != -1
          ? order.techniqueId
          : order.options.techniques.entries.first.key;
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

  void _formValidation() {
    isValid = clientNameCtrl.text.trim().isNotEmpty &&
        streetCtrl.text.trim().isNotEmpty &&
        buildingCtrl.text.trim().isNotEmpty &&
        defectCtrl.text.trim().isNotEmpty &&
        selectedCityId != null &&
        selectedThemeId != null &&
        selectedTechniqueId != null;
  }

  void _validatePickers() {
    errors = [];
    if (selectedCityId == null) {
      errors.add('Выберите город');
    }
    if (selectedThemeId == null) {
      errors.add('Выберите тематику');
    }
    if (selectedTechniqueId == null) {
      errors.add('Выберите технику');
    }
    formKey.currentState!.validate();
  }

  @action
  Future<void> save(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _validatePickers();
    _formValidation();
    if (formKey.currentState!.validate() && isValid == true) {
      try {
        await withLoadingIndicator(() async {
          final position = await getAndroidPosition();
          final result = await OrdersRepository().additionalOrder(
            data: AdditionalOrderData(
              id: order.id,
              clientName: clientNameCtrl.text.trim(),
              themId: selectedThemeId,
              defect: defectCtrl.text.trim(),
              additionalPhone: phoneCtrl.text.trim(),
              cityId: selectedCityId,
              district: districtCtrl.text.trim(),
              street: streetCtrl.text.trim(),
              building: buildingCtrl.text.trim(),
              apartment: apartmentCtrl.text.trim(),
              entrance: entranceCtrl.text.trim(),
              floor: floorCtrl.text.trim(),
              techniqueId: selectedTechniqueId,
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
          Navigator.of(context).pop(result);
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
        if (e is DioException && e.response?.statusCode == 404) {
          unawaited(
              Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
        }
        if (e is UnauthorizedException) {
          unawaited(
              Navigator.of(context).pushNamed(AccessDenyScreen.routeName));
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
  }

  @action
  void dispose() {
    clientNameCtrl
      ..removeListener(_formValidation)
      ..dispose();
    phoneCtrl
      ..removeListener(_formValidation)
      ..dispose();
    districtCtrl
      ..removeListener(_formValidation)
      ..dispose();
    streetCtrl
      ..removeListener(_formValidation)
      ..dispose();
    buildingCtrl
      ..removeListener(_formValidation)
      ..dispose();
    entranceCtrl
      ..removeListener(_formValidation)
      ..dispose();
    floorCtrl
      ..removeListener(_formValidation)
      ..dispose();
    apartmentCtrl
      ..removeListener(_formValidation)
      ..dispose();
    defectCtrl
      ..removeListener(_formValidation)
      ..dispose();
    mainPhoneCtrl.dispose();
  }
}

class OrderAdditionalScreenArgs {
  const OrderAdditionalScreenArgs(this.orderId, this.orderNumber);
  final int orderId;
  final int orderNumber;
}

class OrderAdditionalScreen extends StatelessWidget {
  const OrderAdditionalScreen({required this.args, super.key});

  final OrderAdditionalScreenArgs args;

  static const String routeName = '/order_additional_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(args)..init(context),
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
        title: Text(
          'Доп для заказа #${_State.of(context).args.orderNumber}',
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Expanded(
              child: Observer(
                builder: (context) {
                  return const _Form();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Form extends StatelessObserverWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 60,
          child: Form(
            key: _State.of(context).formKey,
            child: ListView(
              padding: const EdgeInsets.only(
                top: 8,
                left: 16,
                right: 16,
              ),
              children: [
                ///name
                AppTextInputField(
                  controller: _State.of(context).clientNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Имя клиента *',
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) => NotEmptyValidator().check(value),
                ),
                const SizedBox(height: 16),

                ///phone
                AppTextInputField(
                  controller: _State.of(context).mainPhoneCtrl,
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                ),

                const SizedBox(height: 20),
                ...[
                  for (var i = 0;
                      i < _State.of(context).order.additionalPhones.length;
                      i++) ...[
                    Observer(
                      builder: (context) {
                        return AppTextInputField(
                          enabled: false,
                          initialValue:
                              _State.of(context).order.additionalPhones[i],
                          decoration:
                              InputDecoration(labelText: 'Телефон ${i + 1}'),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ]
                ],
                AppTextInputField(
                  controller: _State.of(context).phoneCtrl,
                  inputFormatters: maxLengthFormatter(10),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      MinLengthValidator(10).check(value) ??
                      MaxLengthValidator(10).check(value),
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Доп номер телефона',
                  ),
                ),
                const SizedBox(height: 16),
                AppDropdownField<int?>(
                  label: 'Город',
                  value: _State.of(context).selectedCityId,
                  items: [
                    const MapEntry(-1000, 'Не выбрано'),
                    ..._State.of(context).order.options.cities.entries
                  ],
                  onChange: (value) {
                    if (value == -1000) {
                      _State.of(context).selectedCityId = null;
                    } else {
                      _State.of(context).selectedCityId = value;
                    }
                  },
                ),
                AppTextInputField(
                  controller: _State.of(context).districtCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Район',
                  ),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).streetCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Улица *',
                  ),
                  validator: (value) => NotEmptyValidator().check(value),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).buildingCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Дом *',
                  ),
                  validator: (value) => NotEmptyValidator().check(value),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).apartmentCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Квартира',
                  ),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).entranceCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Подъезд',
                  ),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).floorCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Этаж',
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                AppDropdownField<int?>(
                  label: 'Тематика',
                  value: _State.of(context).selectedThemeId,
                  items: [
                    const MapEntry(-1000, 'Не выбрано'),
                    ..._State.of(context).order.options.themes.entries,
                  ],
                  onChange: (value) {
                    if (value == -1000) {
                      _State.of(context).selectedThemeId = null;
                    } else {
                      _State.of(context).selectedThemeId = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppDropdownField<int?>(
                  label: 'Техника',
                  value: _State.of(context).selectedTechniqueId,
                  items: [
                    const MapEntry(-1000, 'Не выбрано'),
                    ..._State.of(context).order.options.techniques.entries,
                  ],
                  onChange: (value) {
                    if (value == -1000) {
                      _State.of(context).selectedTechniqueId = null;
                    } else {
                      _State.of(context).selectedTechniqueId = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                AppTextInputField(
                  controller: _State.of(context).defectCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Заявленная неисправность *',
                  ),
                  validator: (value) => NotEmptyValidator().check(value),
                ),
                const SizedBox(height: 16),
                FormError(errors: _State.of(context).errors),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 12,
          child: PrimaryButton.green(
            onPressed: () => _State.of(context).save(context),
            text: 'Сохранить',
          ),
        ),
      ],
    );
  }
}
