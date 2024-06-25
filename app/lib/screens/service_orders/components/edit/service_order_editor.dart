import 'dart:async';
import 'dart:io';

import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'service_order_editor.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args, super.sipModel);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(
    ServiceOrderEditorArgs args,
    this.sipModel,
  ) {
    dict = args.dict;
    order = args.order;
    mode = args.mode;

    cityId = int.tryParse(order?.clientCity ?? '');
    technique = int.tryParse(order?.technicType ?? '');
    companyId = order?.company == null
        ? -1000
        : int.tryParse(order?.company ?? '') ?? -1000;
    date = order?.date;
    dateToDone = order?.callDate;
    serviceMaster = int.tryParse(order?.serviceMaster ?? '');
    if (order?.clientAdditionalPhone.isNotEmpty == true) {
      additionalPhone.addAll(order!.clientAdditionalPhone);
    }

    try {
      if (order != null) {
        if (dict.statuses.containsKey(order!.status)) {
          status = order?.status;
        } else {
          status = -1000;
        }
        if (dict.serviceMasters.containsKey(int.parse(order!.serviceMaster))) {
          serviceMaster = int.parse(order!.serviceMaster);
        } else {
          serviceMaster = -1000;
        }
        if (dict.companies.containsKey(int.parse(order!.company))) {
          companyId = int.parse(order!.company);
        } else {
          companyId = -1000;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    clientNameCtrl.text = order?.clientName ?? '';
    phoneCtrl.text = order?.clientPhone ?? '';
    districtCtrl.text = order?.clientDistrict ?? '';
    streetCtrl.text = order?.clientStreet ?? '';
    buildingCtrl.text = order?.clientHouse ?? '';
    apartmentCtrl.text = order?.clientApartment ?? '';
    entranceCtrl.text = order?.clientEntrance ?? '';
    floorCtrl.text = order?.clientFloor ?? '';
    brandCtrl.text = order?.technicBrand ?? '';
    modelCtrl.text = order?.technicModel ?? '';
    serialCtrl.text = order?.technicSerial ?? '';
    biosCtrl.text = order?.technicBiosPass ?? '';
    chargerValue = order?.technicPowerSupply ?? false;
    visualDefectsCtrl.text = order?.technicVisualDefects ?? '';
    cracksValue = order?.technicIsUncovered ?? false;
    usbValue = order?.technicUsbCondition ?? false;
    autopsyCtrl.text = order?.technicVisualDefects ?? '';
    floodingValue = order?.technicHasWaterDamage ?? false;
    batteryValue = order?.technicHasBattery ?? false;
    equipmentCtrl.text = order?.technicComplectation ?? '';
    declaredDefectCtrl.text = order?.damageFromClient ?? '';
    defectCtrl.text = order?.damageFromOperator ?? '';
    masterCommentCtrl.text = order?.commentFromMaster ?? '';
    operatorCommentCtrl.text = order?.commentFromOperator ?? '';
    orderCommentCtrl.text = order?.orderComment ?? '';
    amountCtrl.text = order?.amount.toString() ?? '';
    if (order?.date != null) {
      dateCtrl.text = DateFormat('dd MMM yyyy', 'ru').format(order!.date!);
    }
    if (order?.callDate != null &&
        order?.callDate?.isAfter(DateTime(1971)) == true) {
      dateToDoneCtrl.text =
          DateFormat('dd MMM yyyy', 'ru').format(order!.callDate!);
    }
    isActiveCall = sipModel.isActiveCall;
    sipModel.addListener(callListener);
  }

  late ServiceOrderDict dict;
  late ServiceOrder? order;
  late ServiceOrderEditorMode mode;

  final SipModel sipModel;

  final formKey = GlobalKey<FormState>();
  final clientNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final buildingCtrl = TextEditingController();
  final apartmentCtrl = TextEditingController();
  final entranceCtrl = TextEditingController();
  final floorCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final serialCtrl = TextEditingController();
  final biosCtrl = TextEditingController();
  final visualDefectsCtrl = TextEditingController();
  final autopsyCtrl = TextEditingController();
  final equipmentCtrl = TextEditingController();
  final declaredDefectCtrl = TextEditingController();
  final defectCtrl = TextEditingController();
  final masterCommentCtrl = TextEditingController();
  final operatorCommentCtrl = TextEditingController();
  final orderCommentCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final dateToDoneCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  List<TextEditingController> get controllers => [
        clientNameCtrl,
        phoneCtrl,
        districtCtrl,
        streetCtrl,
        buildingCtrl,
        apartmentCtrl,
        entranceCtrl,
        floorCtrl,
        brandCtrl,
        modelCtrl,
        serialCtrl,
        biosCtrl,
        visualDefectsCtrl,
        autopsyCtrl,
        equipmentCtrl,
        declaredDefectCtrl,
        defectCtrl,
        masterCommentCtrl,
        operatorCommentCtrl,
        orderCommentCtrl,
        dateCtrl,
        dateToDoneCtrl,
        amountCtrl,
      ];

  @observable
  bool _chargerValue = false;
  @computed
  bool get chargerValue => _chargerValue;
  @protected
  set chargerValue(bool value) => _chargerValue = value;

  @observable
  bool _cracksValue = false;
  @computed
  bool get cracksValue => _cracksValue;
  @protected
  set cracksValue(bool value) => _cracksValue = value;

  @observable
  bool _usbValue = false;
  @computed
  bool get usbValue => _usbValue;
  @protected
  set usbValue(bool value) => _usbValue = value;

  @observable
  bool _floodingValue = false;
  @computed
  bool get floodingValue => _floodingValue;
  @protected
  set floodingValue(bool value) => _floodingValue = value;

  @observable
  bool _batteryValue = false;
  @computed
  bool get batteryValue => _batteryValue;
  @protected
  set batteryValue(bool value) => _batteryValue = value;

  @observable
  int? _cityId;
  @computed
  int? get cityId => _cityId;
  @protected
  set cityId(int? value) => _cityId = value;

  @observable
  int? _technique;
  @computed
  int? get technique => _technique;
  @protected
  set technique(int? value) => _technique = value;

  @observable
  ObservableList<String> _additionalPhone = ObservableList();
  @computed
  ObservableList<String> get additionalPhone => _additionalPhone;
  @protected
  set additionalPhone(ObservableList<String> value) => _additionalPhone = value;

  @observable
  int? _companyId;
  @computed
  int? get companyId => _companyId;
  @protected
  set companyId(int? value) => _companyId = value;

  @observable
  int? _status;
  @computed
  int? get status => _status;
  @protected
  set status(int? value) => _status = value;

  @observable
  int? _serviceMaster;
  @computed
  int? get serviceMaster => _serviceMaster;
  @protected
  set serviceMaster(int? value) => _serviceMaster = value;

  @observable
  DateTime? _date;
  @computed
  DateTime? get date => _date;
  @protected
  set date(DateTime? value) => _date = value;

  @observable
  DateTime? _dateToDone;
  @computed
  DateTime? get dateToDone => _dateToDone;
  @protected
  set dateToDone(DateTime? value) => _dateToDone = value;

  @observable
  XFile? file;

  @observable
  XFile? check;

  @observable
  ObservableList<XFile?> files = ObservableList();

  @observable
  bool _isActiveCall = false;
  @computed
  bool get isActiveCall => _isActiveCall;
  @protected
  set isActiveCall(bool value) => _isActiveCall = value;

  @action
  void addPhone() => additionalPhone.add('');

  @action
  void removePhone(int index) => additionalPhone.removeAt(index);

  @action
  Future<void> submit(BuildContext context) async {
    if (formKey.currentState?.validate() == true && isFieldsValid) {
      final location = await getAndroidPosition();
      final sendOrder = {
        'status': status,
        'company_id': companyId,
        'client_name': clientNameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'additional_phone': additionalPhone.toList(),
        'date': DateFormat('yyyy-MM-dd').format(date!),
        'city_id': cityId,
        'district': districtCtrl.text.trim(),
        'street': streetCtrl.text.trim(),
        'building': buildingCtrl.text.trim(),
        'apartment': apartmentCtrl.text.trim(),
        'entrance': entranceCtrl.text.trim(),
        'floor': floorCtrl.text.trim(),
        'sc_master_id': serviceMaster,
        'technique': technique,
        'brand': brandCtrl.text.trim(),
        'model': modelCtrl.text.trim(),
        'serial_number': serialCtrl.text.trim(),
        'bios_password': biosCtrl.text.trim(),
        'charger': chargerValue.asInt(),
        'visual_defects': visualDefectsCtrl.text.trim(),
        'cracks_faults': cracksValue.asInt(),
        'integrity_usb_ports': usbValue.asInt(),
        'autopsy_traces': autopsyCtrl.text.trim(),
        'flooding_marks': floodingValue.asInt(),
        'battery_availability': batteryValue.asInt(),
        'equipment': equipmentCtrl.text.trim(),
        'declared_defect': declaredDefectCtrl.text.trim(),
        'defect': defectCtrl.text.trim(),
        'master_comment': masterCommentCtrl.text.trim(),
        'operator_comment': operatorCommentCtrl.text.trim(),
        'order_comment': orderCommentCtrl.text.trim(),
        if (dateToDone?.isAfter(DateTime(2000)) == true)
          'date_to_done': DateFormat('yyyy-MM-dd HH:mm:ss').format(dateToDone!),
        'order_sum': amountCtrl.text.trim(),
        'longitude': location.longitude,
        'latitude': location.latitude,
      };
      if (mode == ServiceOrderEditorMode.create) {
        try {
          await withLoadingIndicator(() async {
            final result =
                await OrdersRepository().createServiceOrder(sendOrder);
            if (file != null || check != null || files.isNotEmpty) {
              await OrdersRepository().serviceOrderAddPhoto(
                id: result.id,
                filePath: file?.path,
                checkPath: check?.path,
                files: files
                    .toList()
                    .map((e) => e?.path ?? '')
                    .where((e) => e.isNotEmpty)
                    .toList(),
              );
            }
            Navigator.of(context).pop(result);
          });
        } on DioException catch (e) {
          unawaited(showMessage(
            context,
            message: e is ApiException ? e.message : 'Неизвестная ошибка',
            type: AppMessageType.error,
          ));
        }
      } else {
        try {
          await withLoadingIndicator(() async {
            final result =
                await OrdersRepository().editServiceOrder(order!.id, sendOrder);
            if (file != null || check != null || files.isNotEmpty) {
              await OrdersRepository().serviceOrderAddPhoto(
                id: order!.id,
                filePath: file?.path,
                checkPath: check?.path,
                files: files
                    .toList()
                    .map((e) => e?.path ?? '')
                    .where((e) => e.isNotEmpty)
                    .toList(),
              );
            }
            Navigator.of(context).pop(result);
          });
        } on DioException catch (e) {
          unawaited(showMessage(
            context,
            message: e is ApiException ? e.message : 'Неизвестная ошибка',
            type: AppMessageType.error,
          ));
        }
      }
    } else {
      var errorMessage = '';
      if (companyId == null || companyId == -1000) {
        errorMessage += 'Компания не выбрана.\n';
      }
      if (status == null || status == -1000) {
        errorMessage += 'Статус не выбран.\n';
      }
      if (date == null) {
        errorMessage += 'Дата не выбрана.\n';
      }
      if (technique == null || technique == -1000) {
        errorMessage += 'Укажите тип техники.\n';
      }
      if (cityId == null || cityId == -1000) {
        errorMessage += 'Укажите город.\n';
      }
      if (errorMessage.isNotEmpty) {
        unawaited(showMessage(
          context,
          message: errorMessage,
          type: AppMessageType.error,
        ));
      }
    }
  }

  @action
  Future<void> addPhoto(BuildContext context) async {
    final pickedFile = await AppImagePicker.showSelectDialog(
      context,
      Navigator.of(context, rootNavigator: true),
    );
    if (pickedFile != null) {
      file = pickedFile;
    }
  }

  Future<void> addCheck(BuildContext context) async {
    final pickedFile = await AppImagePicker.showSelectDialog(
      context,
      Navigator.of(context, rootNavigator: true),
    );
    if (pickedFile != null) {
      check = pickedFile;
    }
  }

  Future<void> addTakeAwayPhoto(BuildContext context) async {
    final pickedFile = await AppImagePicker.showSelectDialog(
      context,
      Navigator.of(context, rootNavigator: true),
    );
    if (pickedFile != null) {
      files.add(pickedFile);
    }
  }

  Future<void> openPhoto(BuildContext context, String url) async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        insetPadding: const EdgeInsets.all(8),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.network(
              url,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  @computed
  bool get isFieldsValid =>
      (companyId != null &&
          status != null &&
          date != null &&
          technique != null &&
          cityId != null) &&
      (companyId != -1000 &&
          status != -1000 &&
          technique != -1000 &&
          cityId != -1000);

  @action
  void callListener() {
    isActiveCall = sipModel.isActiveCall;
  }

  @action
  void dispose() {
    sipModel.removeListener(callListener);
    for (final c in controllers) {
      c.dispose();
    }
  }
}

enum ServiceOrderEditorMode { edit, create }

class ServiceOrderEditorArgs {
  ServiceOrderEditorArgs({
    required this.dict,
    this.order,
  }) {
    if (order != null) {
      mode = ServiceOrderEditorMode.edit;
    } else {
      mode = ServiceOrderEditorMode.create;
    }
  }
  final ServiceOrder? order;
  final ServiceOrderDict dict;
  late ServiceOrderEditorMode mode;
}

class ServiceOrderEditor extends StatelessWidget {
  const ServiceOrderEditor(this.args, {super.key});

  final ServiceOrderEditorArgs args;

  static const String routeName = '/service_order_editor';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(
        args,
        Provider.of<SipModel>(context, listen: false),
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
    return Scaffold(
      appBar: AppToolbar(
        title: Text(
          _State.of(context).mode == ServiceOrderEditorMode.edit
              ? 'Заказ #${_State.of(context).order?.orderNumber}'
              : 'Новый заказ',
        ),
        actions: const [
          _CallIndicator(),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _State.of(context).formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Observer(
                    builder: (context) {
                      return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //CLIENT DATA
                          _ClientSection(),
                          SizedBox(height: 16),
                          //TECHNIQUE DATA
                          _TechSection(),
                          SizedBox(height: 16),
                          //OTHER DATA
                          _AdditionalSection(),
                          SizedBox(height: 64),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
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
                    PrimaryButton.violet(
                      onPressed: () => _State.of(context).submit(context),
                      text: 'Сохранить',
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientSection extends StatelessObserverWidget {
  const _ClientSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Клиент',
            style: AppTextStyle.regularHeadline.style(
              context,
              AppColors.violetLight,
            ),
          ),
        ),
        AppTextInputField(
          controller: _State.of(context).clientNameCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          validator: (value) => NotEmptyValidator().check(value),
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Имя'),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Телефон',
              style: AppTextStyle.regularCaption.style(context),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextInputField(
                    controller: _State.of(context).phoneCtrl,
                    obscureText:
                        _State.of(context).mode == ServiceOrderEditorMode.edit,
                    enabled: _State.of(context).mode ==
                        ServiceOrderEditorMode.create,
                    inputFormatters: maxLengthFormatter(10),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        MinLengthValidator(10).check(value) ??
                        MaxLengthValidator(10).check(value),
                    onEditingComplete: () =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      // labelText: 'Телефон',
                      enabled: _State.of(context).mode ==
                          ServiceOrderEditorMode.create,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppIcons.phone.iconButton(
                  splitColor: AppSplitColor.violet(),
                  size: const Size.square(48),
                  onPressed: () {
                    _State.of(context)
                        .sipModel
                        .makeCall(_State.of(context).phoneCtrl.text);
                  },
                ),
                const SizedBox(width: 8),
                AppIcons.add.iconButton(
                  splitColor: AppSplitColor.violet(),
                  size: const Size.square(48),
                  onPressed: () {
                    _State.of(context).additionalPhone.add('');
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...[
          for (var i = 0;
              i < _State.of(context).additionalPhone.length;
              i++) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Телефон ${i + 1}',
                  style: AppTextStyle.regularCaption.style(context),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextInputField(
                        inputFormatters: maxLengthFormatter(10),
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            MinLengthValidator(10).check(value) ??
                            MaxLengthValidator(10).check(value),
                        obscureText: _State.of(context).mode ==
                                ServiceOrderEditorMode.edit &&
                            _State.of(context).additionalPhone[i].isNotEmpty,
                        enabled: _State.of(context).mode ==
                                ServiceOrderEditorMode.create ||
                            (_State.of(context).mode ==
                                    ServiceOrderEditorMode.edit &&
                                _State.of(context)
                                        .order
                                        ?.clientAdditionalPhone
                                        .contains(_State.of(context)
                                            .additionalPhone[i]) ==
                                    false),
                        initialValue: _State.of(context).additionalPhone[i],
                        onChanged: (value) {
                          _State.of(context).additionalPhone[i] = value;
                        },
                        onEditingComplete: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_State.of(context).mode != ServiceOrderEditorMode.edit)
                      AppIcons.trash.iconButton(
                        splitColor: AppSplitColor.red(),
                        size: const Size.square(48),
                        onPressed: () {
                          _State.of(context).additionalPhone.removeAt(i);
                        },
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ]
        ],
        if (_State.of(context)
                .dict
                .statusesToShowAddress
                .contains(_State.of(context).order?.status) ||
            _State.of(context).mode == ServiceOrderEditorMode.create) ...[
          AppDropdownField<int?>(
            label: 'Город',
            value: _State.of(context).cityId,
            items: [
              const MapEntry(-1000, 'Не выбрано'),
              ..._State.of(context).dict.cities.entries
            ],
            onChange: (value) {
              if (value == -1000) {
                _State.of(context).cityId = null;
              } else {
                _State.of(context).cityId = value;
              }
            },
          ),
          AppTextInputField(
            controller: _State.of(context).districtCtrl,
            inputFormatters: maxLengthFormatter(255),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            onEditingComplete: () =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(labelText: 'Район'),
          ),
          const SizedBox(height: 16),
          AppTextInputField(
            controller: _State.of(context).streetCtrl,
            inputFormatters: maxLengthFormatter(255),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            onEditingComplete: () =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(labelText: 'Улица'),
          ),
          const SizedBox(height: 16),
          AppTextInputField(
            controller: _State.of(context).buildingCtrl,
            inputFormatters: maxLengthFormatter(255),
            keyboardType: TextInputType.text,
            onEditingComplete: () =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(labelText: 'Дом'),
          ),
          const SizedBox(height: 16),
          AppTextInputField(
            controller: _State.of(context).apartmentCtrl,
            inputFormatters: maxLengthFormatter(255),
            keyboardType: TextInputType.text,
            onEditingComplete: () =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(labelText: 'Квартира'),
          ),
          const SizedBox(height: 16),
          AppTextInputField(
            controller: _State.of(context).entranceCtrl,
            inputFormatters: maxLengthFormatter(255),
            keyboardType: TextInputType.text,
            onEditingComplete: () =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(labelText: 'Подъезд'),
          ),
          const SizedBox(height: 16),
          AppTextInputField(
            controller: _State.of(context).floorCtrl,
            inputFormatters: maxLengthFormatter(255),
            keyboardType: TextInputType.text,
            onEditingComplete: () =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(labelText: 'Этаж'),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _TechSection extends StatelessObserverWidget {
  const _TechSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Техника',
          style: AppTextStyle.regularHeadline.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 16),
        AppDropdownField<int?>(
          label: 'Тип техники',
          value: _State.of(context).technique,
          items: _State.of(context).dict.technique.entries,
          onChange: (value) {
            _State.of(context).technique = value;
          },
        ),
        AppTextInputField(
          controller: _State.of(context).brandCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Бренд'),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).modelCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Модель'),
        ),
        const SizedBox(height: 16),
        const _PhotoSection(),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).declaredDefectCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration:
              const InputDecoration(labelText: 'Неисправность со слов клиента'),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).defectCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(
              labelText: 'Неисправность со слов клиента (оператор)'),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).masterCommentCtrl,
          minLines: 2,
          maxLines: 6,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Комментарий мастера'),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).operatorCommentCtrl,
          minLines: 2,
          maxLines: 6,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Комментарий оператора'),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).serialCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Серийный номер'),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).biosCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Пароль на BIOS'),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 8),
        Text(
          'Комплект и состояние',
          style: AppTextStyle.regularHeadline.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).visualDefectsCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Визуальные дефекты'),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).equipmentCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Комплектация'),
        ),
        const SizedBox(height: 16),
        AppCheckBox.withLabel(
          label: const Text('Зарядное устройство'),
          value: _State.of(context).chargerValue,
          onChanged: (value) =>
              _State.of(context).chargerValue = value ?? false,
        ),
        const SizedBox(height: 16),
        AppCheckBox.withLabel(
          label: const Text('Следы вскрытия'),
          value: _State.of(context).cracksValue,
          onChanged: (value) => _State.of(context).cracksValue = value ?? false,
        ),
        const SizedBox(height: 16),
        AppCheckBox.withLabel(
          label: const Text('Целостность USB'),
          value: _State.of(context).usbValue,
          onChanged: (value) => _State.of(context).usbValue = value ?? false,
        ),
        const SizedBox(height: 16),
        AppCheckBox.withLabel(
          label: const Text('Попадание влаги'),
          value: _State.of(context).floodingValue,
          onChanged: (value) =>
              _State.of(context).floodingValue = value ?? false,
        ),
        const SizedBox(height: 16),
        AppCheckBox.withLabel(
          label: const Text('Наличие батареи'),
          value: _State.of(context).batteryValue,
          onChanged: (value) =>
              _State.of(context).batteryValue = value ?? false,
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).autopsyCtrl,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Внешняя оценка'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          children: const [
            _Photo(),
            _PhotoCheck(),
          ],
        ),
        const _TakeAwayPhoto(),
      ],
    );
  }
}

class _AdditionalSection extends StatelessObserverWidget {
  const _AdditionalSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Дополнительно',
          style: AppTextStyle.regularHeadline.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).amountCtrl,
          inputFormatters: numberFormatters,
          validator: (value) {
            if (value == null || value.isEmpty == true) {
              return 'Поле не может быть пустым';
            }
            if (int.tryParse(value) == null || int.parse(value) < 0) {
              return 'Значение должно быть 0 или более';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Сумма (без копеек)'),
        ),
        const SizedBox(height: 16),
        AppDropdownField<int?>(
          label: 'Статус',
          items: [
            const MapEntry(-1000, 'Не выбрано'),
            ..._State.of(context).dict.statuses.entries,
          ],
          value: _State.of(context).status,
          onChange: (value) {
            if (value == -1000) {
              _State.of(context).status = null;
            } else {
              _State.of(context).status = value;
            }
          },
        ),
        AppDropdownField<int?>(
          label: 'Компания',
          items: [
            const MapEntry(-1000, 'Не выбрано'),
            ..._State.of(context).dict.companies.entries,
          ],
          value: _State.of(context).companyId,
          onChange: (value) {
            if (value == -1000) {
              _State.of(context).companyId = null;
            } else {
              _State.of(context).companyId = value;
            }
          },
        ),
        AppDropdownField<int?>(
          label: 'Мастер СЦ',
          items: [
            const MapEntry(-1000, 'Не выбрано'),
            ..._State.of(context).dict.serviceMasters.entries,
          ],
          value: _State.of(context).serviceMaster,
          onChange: (value) {
            if (value == -1000) {
              _State.of(context).serviceMaster = null;
            } else {
              _State.of(context).serviceMaster = value;
            }
          },
        ),
        Stack(
          children: [
            if (_State.of(context).mode == ServiceOrderEditorMode.create) ...[
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
                          firstDate:
                              (_State.of(context).order?.date ?? DateTime.now())
                                  .subtract(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          locale: const Locale.fromSubtags(languageCode: 'ru'),
                          initialDate: _State.of(context).order?.date ??
                              DateTime.now().subtract(const Duration(days: 1)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark(useMaterial3: true),
                              child: child!,
                            );
                          });
                      if (date != null) {
                        _State.of(context).dateCtrl.text =
                            DateFormat('dd MMM yyyy', 'ru').format(date);
                        _State.of(context).date = date;
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ],
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
                  _State.of(context).date = null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IconButton(
                onPressed: () {
                  _State.of(context).dateToDoneCtrl.text = '';
                  _State.of(context).dateToDone = null;
                },
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 46,
              top: 0,
              bottom: 0,
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate:
                        (_State.of(context).order?.callDate ?? DateTime.now())
                            .subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale.fromSubtags(languageCode: 'ru'),
                    initialDate: _State.of(context).order?.callDate ??
                        DateTime.now().subtract(const Duration(days: 1)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark(useMaterial3: true),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: _State.of(context).order?.callDate?.hour ?? 12,
                          minute:
                              _State.of(context).order?.callDate?.minute ?? 0),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: Theme(
                            data: ThemeData.dark(useMaterial3: true),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (time != null) {
                      final fullDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      _State.of(context).dateToDoneCtrl.text =
                          DateFormat('dd MMM yyyy HH:mm', 'ru')
                              .format(fullDate);
                      _State.of(context).dateToDone = fullDate;
                    }
                  }
                },
                child: const SizedBox.expand(),
              ),
            ),
            IgnorePointer(
              child: AppTextInputField(
                controller: _State.of(context).dateToDoneCtrl,
                keyboardType: TextInputType.text,
                onEditingComplete: () =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(labelText: 'Дата созвона'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).orderCommentCtrl,
          minLines: 2,
          maxLines: 6,
          inputFormatters: maxLengthFormatter(255),
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(labelText: 'Комментарий'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Photo extends StatelessObserverWidget {
  const _Photo();

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _State.of(context).order?.actPhoto.isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Акт забора',
          style: AppTextStyle.regularCaption.style(context),
        ),
        const SizedBox(height: 8),
        PhotoPicker(
          onTap: hasPhoto
              ? () => _State.of(context).openPhoto(
                    context,
                    _State.of(context).order!.actPhoto,
                  )
              : () => _State.of(context).addPhoto(context),
          fileUri:
              hasPhoto ? Uri.parse(_State.of(context).order!.actPhoto) : null,
          file: _State.of(context).file?.path.isNotEmpty == true
              ? File(_State.of(context).file!.path)
              : null,
        ),
      ],
    );
  }
}

class _PhotoCheck extends StatelessObserverWidget {
  const _PhotoCheck();

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _State.of(context).order?.checkPhoto.isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Фото чека',
          style: AppTextStyle.regularCaption.style(context),
        ),
        const SizedBox(height: 8),
        PhotoPicker(
          onTap: hasPhoto
              ? () => _State.of(context).openPhoto(
                    context,
                    _State.of(context).order!.checkPhoto,
                  )
              : () => _State.of(context).addCheck(context),
          fileUri:
              hasPhoto ? Uri.parse(_State.of(context).order!.checkPhoto) : null,
          file: _State.of(context).check?.path.isNotEmpty == true
              ? File(_State.of(context).check!.path)
              : null,
        ),
      ],
    );
  }
}

class _TakeAwayPhoto extends StatelessObserverWidget {
  const _TakeAwayPhoto();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Фото техники',
          style: AppTextStyle.regularCaption.style(context),
        ),
        const SizedBox(height: 8),
        GridView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          children: [
            ..._State.of(context)
                    .order
                    ?.photos
                    .map(
                      (e) => PhotoPicker(
                        onTap: () => _State.of(context).openPhoto(
                          context,
                          e,
                        ),
                        fileUri: Uri.parse(e),
                      ),
                    )
                    .toList() ??
                [],
            ..._State.of(context).files.map(
                  (file) => PhotoPicker(
                    onTap: () => _State.of(context)
                        .files
                        .removeAt(_State.of(context).files.indexOf(file)),
                    file: File(file!.path),
                  ),
                ),
            PhotoPicker(
              onTap: () => _State.of(context).addTakeAwayPhoto(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _CallIndicator extends StatelessWidget {
  const _CallIndicator();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (_State.of(context).isActiveCall) {
        return GestureDetector(
          onTap: () {
            _State.of(context).sipModel.isActiveCallScreen = true;
            Navigator.of(AppRouter
                    .navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!)
                .pushNamed(CallScreen.routeName);
          },
          child: AppIcons.phone.iconColored(
            color: AppSplitColor.green(),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
