import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'applicant_details_screen.g.dart';

class _State extends _StateStore with _$_State {
  _State(SipModel sipModel, ApplicantData data, ApplicantFilterOptions dict)
      : super(sipModel, dict, data);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.sipModel, this.dict, this.data) {
    isSipActive = sipModel.isActive;
    sipModel.addListener(_sipListener);
    clientNameCtrl.text = data.clientName;
    phoneCtrl.text = data.phone;
    ageCtrl.text = data.age;
    emailCtrl.text = data.email;
    orderCommentCtrl.text = data.orderComment;
    dateCtrl.text = data.date;
    timeCtrl.text = data.time;
    districtCtrl.text = data.district;
    jobVacancy = data.jobVacancy;
    specification = data.specification;
    smartphone = data.smartphone ? 1 : 0;
    status = data.status;
    cityId = data.cityId;
    masterId = data.masterId;
    experience = data.experience ? 1 : 0;
    date = DateTime.tryParse(data.date);
    if (data.time.isNotEmpty) {
      try {
        time = TimeOfDay(
          hour: int.parse(data.time.split(':')[0]),
          minute: int.parse(
            data.time.split(':')[1],
          ),
        );
      } catch (e) {
        time = TimeOfDay.now();
      }
    } else {
      time = TimeOfDay.now();
    }
    init();
  }

  final ApplicantData data;
  final ApplicantFilterOptions dict;
  final SipModel sipModel;

  final repo = ApplicationRepository();
  final formKey = GlobalKey<FormState>();

  final clientNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final orderCommentCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final districtCtrl = TextEditingController();

  List<TextEditingController> get controllers => [
        clientNameCtrl,
        phoneCtrl,
        ageCtrl,
        emailCtrl,
        orderCommentCtrl,
        dateCtrl,
        timeCtrl,
        districtCtrl,
      ];

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
  Map<ApplicantFilterInputs, Map<int?, String>> _options = {};
  @computed
  Map<ApplicantFilterInputs, Map<int?, String>> get options => _options;
  @protected
  set options(Map<ApplicantFilterInputs, Map<int?, String>> value) =>
      _options = value;

  @observable
  int? innerPhone;
  @observable
  int? source;
  @observable
  int? companyId;
  @observable
  int? jobVacancy;
  @observable
  int? specification;
  @observable
  int? smartphone;
  @observable
  int? status;
  @observable
  int? cityId;
  @observable
  int? masterId;
  @observable
  int? experience;

  @observable
  DateTime? date;
  @observable
  TimeOfDay? time;

  @action
  Future<void> init() async {
    try {
      options = await repo.getUpdateOptions();
      debugPrint(options.toString());
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  @action
  Future<void> submit(BuildContext context) async {
    try {
      final body = EditApplicantBody();
      body.data[ApplicantFilterInputs.clientName] = clientNameCtrl.text;
      body.data[ApplicantFilterInputs.phone] = phoneCtrl.text;
      body.data[ApplicantFilterInputs.age] = ageCtrl.text;
      body.data[ApplicantFilterInputs.experience] = experience == 1;
      body.data[ApplicantFilterInputs.email] = emailCtrl.text;
      body.data[ApplicantFilterInputs.district] = districtCtrl.text;
      body.data[ApplicantFilterInputs.date] = date;
      body.data[ApplicantFilterInputs.time] = time;
      body.data[ApplicantFilterInputs.orderComment] = orderCommentCtrl.text;
      body.data[ApplicantFilterInputs.jobVacancy] = jobVacancy;
      body.data[ApplicantFilterInputs.specification] = specification;
      body.data[ApplicantFilterInputs.status] = status;
      body.data[ApplicantFilterInputs.cityId] = cityId;
      body.data[ApplicantFilterInputs.masterId] = masterId;
      body.data[ApplicantFilterInputs.smartphone] = smartphone == 1;

      if (formKey.currentState?.validate() == true && body.isValid) {
        try {
          await repo.editApplicant(data.id, body.toJson(context));
          Navigator.of(context).pop();
        } catch (e, s) {
          debugPrint(e.toString());
          unawaited(FirebaseCrashlytics.instance.recordError(e, s));
          if (e is ApiException) {
            await showMessage(
              context,
              prefixIcon: const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              message: e.message,
              type: AppMessageType.error,
            );
          }
        }
      } else {
        await showMessage(
          context,
          message: 'Форма заполнена не корректно',
          type: AppMessageType.error,
          prefixIcon: AppIcons.alert.widget(
            color: AppColors.white,
          ),
        );
      }
    } catch (e, s) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, s));
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
  void _sipListener() {
    isSipActive = sipModel.isActive;
  }

  @action
  void dispose() {
    sipModel.removeListener(_sipListener);
    for (final c in controllers) {
      c.dispose();
    }
  }
}

class ApplicantDetailsScreenArgs {
  const ApplicantDetailsScreenArgs(
    this.data,
    this.dict,
  );
  final ApplicantData data;
  final ApplicantFilterOptions dict;
}

class ApplicantDetailsScreen extends StatelessWidget {
  const ApplicantDetailsScreen({required this.args, super.key});

  final ApplicantDetailsScreenArgs args;

  static const String routeName = '/applicant_details_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(
        Provider.of<SipModel>(
          context,
          listen: false,
        ),
        args.data,
        args.dict,
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
      appBar: const AppToolbar(
        title: Text('Соискатель'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _State.of(context).formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  if (_State.of(context).options.isNotEmpty)
                    ...ApplicantFilterInputs.values.backendValues.map((e) {
                      switch (e) {
                        case ApplicantFilterInputs.clientName:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AppTextInputField(
                              controller: _State.of(context).clientNameCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Имя клиента'),
                              validator: NotEmptyValidator().check,
                            ),
                          );
                        case ApplicantFilterInputs.phone:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AppTextInputField(
                              controller: _State.of(context).phoneCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Телефон'),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                ...numberFormatters,
                                ...maxLengthFormatter(10),
                              ],
                              validator: (value) {
                                final minLength =
                                    MinLengthValidator(10).check(value);
                                final maxLength =
                                    MaxLengthValidator(10).check(value);
                                final notEmpty =
                                    NotEmptyValidator().check(value);
                                return minLength ?? maxLength ?? notEmpty;
                              },
                            ),
                          );
                        case ApplicantFilterInputs.jobVacancy:
                          return AppDropdownField<int?>(
                            label: 'Вакансия',
                            value: _State.of(context).jobVacancy,
                            items: [
                              const MapEntry(-1000, 'Не выбрано'),
                              ..._State.of(context).options[e]?.entries ?? [],
                            ],
                            onChange: (value) {
                              if (value == -1000) {
                                _State.of(context).jobVacancy = null;
                              } else {
                                _State.of(context).jobVacancy = value;
                              }
                            },
                          );
                        case ApplicantFilterInputs.age:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: AppTextInputField(
                              controller: _State.of(context).ageCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Возраст'),
                              keyboardType: TextInputType.number,
                            ),
                          );
                        case ApplicantFilterInputs.experience:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: AppSwitch(
                              leading: Text(
                                'Опыт',
                                style:
                                    AppTextStyle.regularHeadline.style(context),
                              ),
                              statusString: _State.of(context).experience == 1
                                  ? 'Да'
                                  : 'Нет',
                              isSwitched: _State.of(context).experience == 1,
                              onChanged: (value) {
                                _State.of(context).experience = value ? 1 : 0;
                              },
                            ),
                          );
                        case ApplicantFilterInputs.specification:
                          return AppDropdownField<int?>(
                            label: 'Спецификация',
                            value: _State.of(context).specification,
                            items: [
                              const MapEntry(-1000, 'Не выбрано'),
                              ..._State.of(context).options[e]?.entries ?? [],
                            ],
                            onChange: (value) {
                              if (value == -1000) {
                                _State.of(context).specification = null;
                              } else {
                                _State.of(context).specification = value;
                              }
                            },
                          );
                        case ApplicantFilterInputs.masterId:
                          return AppDropdownField<int?>(
                            label: 'Мастер стажировки',
                            value: _State.of(context).masterId,
                            items: [
                              const MapEntry(-1000, 'Не выбрано'),
                              ..._State.of(context).options[e]?.entries ?? [],
                            ],
                            onChange: (value) {
                              if (value == -1000) {
                                _State.of(context).masterId = null;
                              } else {
                                _State.of(context).masterId = value;
                              }
                            },
                          );
                        case ApplicantFilterInputs.smartphone:
                          return AppDropdownField<int?>(
                            label: 'Наличие телефона',
                            value: _State.of(context).smartphone,
                            items: [
                              const MapEntry(-1000, 'Не выбрано'),
                              ..._State.of(context).options[e]?.entries ?? [],
                            ],
                            onChange: (value) {
                              if (value == -1000) {
                                _State.of(context).smartphone = null;
                              } else {
                                _State.of(context).smartphone = value;
                              }
                            },
                          );
                        case ApplicantFilterInputs.email:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: AppTextInputField(
                              controller: _State.of(context).emailCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          );
                        case ApplicantFilterInputs.orderComment:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: AppTextInputField(
                              controller: _State.of(context).orderCommentCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Комментарий'),
                              minLines: 2,
                              maxLines: 6,
                            ),
                          );
                        case ApplicantFilterInputs.status:
                          return AppDropdownField<int?>(
                            label: 'Статус',
                            value: _State.of(context).status,
                            items: [
                              const MapEntry(-1000, 'Не выбрано'),
                              ..._State.of(context).options[e]?.entries ?? [],
                            ],
                            onChange: (value) {
                              if (value == -1000) {
                                _State.of(context).status = null;
                              } else {
                                _State.of(context).status = value;
                              }
                            },
                          );
                        case ApplicantFilterInputs.date:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 46,
                                  top: 24,
                                  bottom: 0,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    overlayColor:
                                        const MaterialStatePropertyAll<Color>(
                                            Colors.transparent),
                                    onTap: () async {
                                      final date = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime.utc(2022),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 90)),
                                          locale: const Locale.fromSubtags(
                                              languageCode: 'ru'),
                                          initialDate:
                                              _State.of(context).date ??
                                                  DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.dark(
                                                  useMaterial3: true),
                                              child: child!,
                                            );
                                          });
                                      if (date != null) {
                                        _State.of(context).dateCtrl.text =
                                            DateFormat('yyyy-MM-dd')
                                                .format(date);
                                        _State.of(context).date = date;
                                      }
                                    },
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                                IgnorePointer(
                                  child: AppTextInputField(
                                    controller: _State.of(context).dateCtrl,
                                    keyboardType: TextInputType.text,
                                    onEditingComplete: () => FocusManager
                                        .instance.primaryFocus
                                        ?.unfocus(),
                                    decoration: const InputDecoration(
                                        labelText: 'Дата созвона'),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 24,
                                  bottom: 0,
                                  child: AppIcons.cross.iconButton(
                                    color: AppColors.violet,
                                    onPressed: () {
                                      _State.of(context).date = null;
                                      _State.of(context).dateCtrl.text = '';
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        case ApplicantFilterInputs.time:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 46,
                                  top: 24,
                                  bottom: 0,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    overlayColor:
                                        const MaterialStatePropertyAll<Color>(
                                            Colors.transparent),
                                    onTap: () async {
                                      final time = await showTimePicker(
                                          context: context,
                                          initialTime: _State.of(context).time!,
                                          builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.dark(
                                                  useMaterial3: true),
                                              child: child!,
                                            );
                                          });
                                      if (time != null) {
                                        _State.of(context).timeCtrl.text =
                                            time.format(context);
                                        _State.of(context).time = time;
                                      }
                                    },
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                                IgnorePointer(
                                  child: AppTextInputField(
                                    controller: _State.of(context).timeCtrl,
                                    keyboardType: TextInputType.text,
                                    onEditingComplete: () => FocusManager
                                        .instance.primaryFocus
                                        ?.unfocus(),
                                    decoration: const InputDecoration(
                                        labelText: 'Время созвона'),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 24,
                                  child: AppIcons.cross.iconButton(
                                    color: AppColors.violet,
                                    onPressed: () {
                                      _State.of(context).time = null;
                                      _State.of(context).timeCtrl.text = '';
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        case ApplicantFilterInputs.cityId:
                          return AppDropdownField<int?>(
                            label: 'Город',
                            value: _State.of(context).cityId,
                            items: [
                              const MapEntry(-1000, 'Не выбрано'),
                              ..._State.of(context).options[e]?.entries ?? [],
                            ],
                            onChange: (value) {
                              if (value == -1000) {
                                _State.of(context).cityId = null;
                              } else {
                                _State.of(context).cityId = value;
                              }
                            },
                          );
                        case ApplicantFilterInputs.district:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AppTextInputField(
                              controller: _State.of(context).districtCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Район'),
                            ),
                          );
                        default:
                          return const SizedBox();
                      }
                    }),
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
      ),
    );
  }
}
