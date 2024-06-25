import 'dart:async';

import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:flutter/services.dart';
import 'package:json_reader/json_reader.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/ui/components/terms_and_conditions.dart';
import 'package:rempc/ui/screens/tab/main_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'sign_up_body.dart';
part 'sign_up_screen.g.dart';

/*
* Экран регистрации
* TODO сделать поля с вибрацией при ошибке
* */
class _State extends _StateStore with _$_State {
  _State() : super();

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore() {
    /// Ставит фокус в поле ввода
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusManager.instance.primaryFocus?.requestFocus(emailFocus);
    });
  }

  final _repo = AuthRepository();
  final platform = const MethodChannel('helperService');
  final formKey = GlobalKey<FormState>();
  final checkboxKey = GlobalKey<CustomShakeWidgetState>();
  final emailCtrl = TextEditingController();
  final emailFocus = FocusNode();
  final passCtrl = TextEditingController();
  final passFocus = FocusNode();
  final pass2Focus = FocusNode();
  final phoneCtrl = TextEditingController();
  final phoneFocus = FocusNode();
  final firstNameCtrl = TextEditingController();
  final firstNameFocus = FocusNode();
  final lastNameCtrl = TextEditingController();
  final lastNameFocus = FocusNode();
  final fatherNameCtrl = TextEditingController();
  final fatherNameFocus = FocusNode();
  final addressCtrl = TextEditingController();
  final addressFocus = FocusNode();
  final agreeTermsErrorStream = BehaviorSubject.seeded(false);
  final agreeTermsFocus = FocusNode();

  /// Текстовые контроллеры
  List<TextEditingController> get controllers => [
        emailCtrl,
        passCtrl,
        firstNameCtrl,
        lastNameCtrl,
        fatherNameCtrl,
        phoneCtrl,
        addressCtrl,
      ];

  /// Ноды фокусировки
  List<FocusNode> get focusNodes => [
        emailFocus,
        passFocus,
        pass2Focus,
        phoneFocus,
        firstNameFocus,
        lastNameFocus,
        fatherNameFocus,
        addressFocus,
        agreeTermsFocus,
      ];

  /// Скрытие пароля
  @observable
  bool _obscureText = true;
  @computed
  bool get obscureText => _obscureText;
  @protected
  set obscureText(bool value) => _obscureText = value;

  /// Выбранный город
  @observable
  int? _selectedCity;
  @computed
  int? get selectedCity => _selectedCity;
  @protected
  set selectedCity(int? value) => _selectedCity = value;

  /// Выбранная компания
  @observable
  int? _selectedCompany;
  @computed
  int? get selectedCompany => _selectedCompany;
  @protected
  set selectedCompany(int? value) => _selectedCompany = value;

  /// Аватар
  @observable
  XFile? _avatar;
  @computed
  XFile? get avatar => _avatar;
  @protected
  set avatar(XFile? value) => _avatar = value;

  /// Выбранные темы
  @observable
  List<int> _selectedThemas = [];
  @computed
  List<int> get selectedThemas => _selectedThemas;
  @protected
  set selectedThemas(List<int> value) => _selectedThemas = value;

  /// Согласие с правилами
  @observable
  bool _isAgree = false;
  @computed
  bool get isAgree => _isAgree;
  @protected
  set isAgree(bool value) => _isAgree = value;

  /// Отправка формы регистрации
  @action
  Future<void> submit(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (formKey.currentState?.validate() == true &&
        selectedCity != null &&
        selectedCompany != null &&
        isAgree) {
      final onesignalUserid = await platform.invokeMethod('getOneSignalUserId');
      try {
        final result = await _repo.register(
          await SingUpBody(
            name:
                '''${capitalizeFirstLetter(lastNameCtrl.text.trim())} ${capitalizeFirstLetter(firstNameCtrl.text.trim())} ${capitalizeFirstLetter(fatherNameCtrl.text.trim())}''',
            email: emailCtrl.text.trim(),
            cityId: selectedCity!,
            companyId: selectedCompany!,
            phone: phoneCtrl.text.replaceAll(' ', ''),
            password: passCtrl.text.trim(),
            homeAddress: addressCtrl.text.trim(),
            avatar: avatar,
            onesignalUserid: onesignalUserid,
            themas: selectedThemas,
          ).toFormData(),
        );

        /// Обработка удачной регистрации
        if (result == 200) {
          /// получение токена
          final accessToken = await AuthRepository().login(
            emailCtrl.text.trim(),
            passCtrl.text.trim(),
            onesignalUserid,
          );
          ApiStorage().accessToken = accessToken;
          await platform.invokeMethod(
            'setUserAuthToken',
            {
              'userAuthToken': accessToken,
            },
          );
          await platform.invokeMethod(
            'loginEvent',
            {
              'email': emailCtrl.text.trim(),
            },
          );
          await platform.invokeMethod(
            'startHelperService',
            {
              'userAuthToken': accessToken,
            },
          );
          try {
            /// Попытка пойти на главную
            final permissions = await AuthRepository().getUserPermissions();
            context.read<HomeData>().permissions = permissions;
            unawaited(Navigator.of(context).pushNamedAndRemoveUntil(
              MainScreen.routeName,
              (r) => false,
            ));
          } finally {
            await HomeData.of(context).init();
          }
        }
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.badResponse) {
          final errors = JsonReader(e.response!.data!)['data'].asMap();
          final message = StringBuffer();
          for (final error in errors.values) {
            message.writeln('$error\n');
          }
          unawaited(showMessage(
            context,
            message: '$message',
            type: AppMessageType.error,
          ));
        } else {
          unawaited(showMessage(
            context,
            message: 'Не известная ошибка',
            type: AppMessageType.error,
          ));
        }
      }
    } else {
      if (!isAgree) {
        /// Ошибка по чекбоксу
        checkboxKey.currentState?.shake();
        agreeTermsFocus.requestFocus();
        agreeTermsErrorStream.add(true);
      }
    }
  }

  /// Выбор аватара
  @action
  Future<void> addAvatar(BuildContext context) async {
    final file = await AppImagePicker.showSelectDialog(context);
    if (file != null) {
      avatar = file;
    }
  }

  /// Выключение экрана
  @action
  void dispose() {
    checkboxKey.currentState?.dispose();
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
  }

  /// Делает первую букву в строке большой
  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const String routeName = '/sign_up_screen';

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
    return const Scaffold(
      appBar: AppToolbar(
        leading: AppToolbar(),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SignUpForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Form(
          key: _State.of(context).formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Создать аккаунт',
                style: AppTextStyle.boldTitle2.style(context),
              ),
              const SizedBox(height: 8),
              Text(
                '''Для регистрации и получения доступа к приложения заполните свои данные''',
                style: AppTextStyle.regularHeadline.style(context),
              ),
              const SizedBox(height: 24),
              AppTextInputField(
                  controller: _State.of(context).emailCtrl,
                  focusNode: _State.of(context).emailFocus,
                  onEditingComplete: () => FocusScope.of(context)
                      .requestFocus(_State.of(context).passFocus),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value?.trim().isNotEmpty == true
                      ? null
                      : 'Обязательное поле',
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  )),
              const SizedBox(height: 16),
              AppTextInputField(
                controller: _State.of(context).passCtrl,
                focusNode: _State.of(context).passFocus,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_State.of(context).pass2Focus),
                keyboardType: TextInputType.visiblePassword,
                obscureText: _State.of(context).obscureText,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty == true &&
                      value.trim().length >= 8) {
                    return null;
                  } else {
                    return value?.trim().isNotEmpty == true
                        ? 'Пароль должен иметь минимум 8 символов'
                        : 'Обязательное поле';
                  }
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _State.of(context).obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () => _State.of(context).obscureText =
                        !_State.of(context).obscureText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextInputField(
                focusNode: _State.of(context).pass2Focus,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_State.of(context).phoneFocus),
                keyboardType: TextInputType.visiblePassword,
                obscureText: _State.of(context).obscureText,
                validator: (value) {
                  if (value == _State.of(context).passCtrl.text) {
                    return null;
                  } else {
                    return 'Пароли не совпадают';
                  }
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Подтвердите пароль',
                ),
              ),
              const SizedBox(height: 16),
              AppTextInputField(
                controller: _State.of(context).phoneCtrl,
                focusNode: _State.of(context).phoneFocus,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_State.of(context).firstNameFocus),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.replaceAll(' ', '').length == 10) {
                    return null;
                  } else {
                    return 'Введите номер в формате 099 999 99 99';
                  }
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Номер телефона',
                ),
              ),
              const SizedBox(height: 16),
              AppTextInputField(
                controller: _State.of(context).lastNameCtrl,
                focusNode: _State.of(context).lastNameFocus,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_State.of(context).fatherNameFocus),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return null;
                  } else {
                    return 'Поле не может быть пустым';
                  }
                },
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Фамилия',
                ),
              ),
              const SizedBox(height: 16),
              AppTextInputField(
                controller: _State.of(context).firstNameCtrl,
                focusNode: _State.of(context).firstNameFocus,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_State.of(context).lastNameFocus),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return null;
                  } else {
                    return 'Поле не может быть пустым';
                  }
                },
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                ),
              ),
              const SizedBox(height: 16),
              AppTextInputField(
                controller: _State.of(context).fatherNameCtrl,
                focusNode: _State.of(context).fatherNameFocus,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_State.of(context).addressFocus),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return null;
                  } else {
                    return 'Поле не может быть пустым';
                  }
                },
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Отчество',
                ),
              ),
              const SizedBox(height: 16),
              AppDropdownField<int?>(
                label: 'Город',
                items: GetDict.publicCities.entries,
                value: _State.of(context).selectedCity,
                onChange: (value) => _State.of(context).selectedCity = value,
              ),
              AppDropdownField<int?>(
                label: 'Компания',
                items: GetDict.publicCompanies.entries,
                value: _State.of(context).selectedCompany,
                onChange: (value) => _State.of(context).selectedCompany = value,
              ),
              AppTextInputField(
                controller: _State.of(context).addressCtrl,
                focusNode: _State.of(context).addressFocus,
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 6,
                validator: (value) {
                  if (value?.isNotEmpty == true) {
                    return null;
                  } else {
                    return 'Поле не может быть пустым';
                  }
                },
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Полный адрес',
                ),
              ),
              const SizedBox(height: 24),
              AppMultiSelectField<int>(
                label: 'Сфера деятельности',
                value: _State.of(context).selectedThemas,
                items: GetDict.publicThemes.entries,
                onChange: (value) {
                  _State.of(context).selectedThemas = value;
                },
              ),
              const SizedBox(height: 24),
              const _Photo(),
              const SizedBox(height: 24),
              TermsAndConditions(
                isAgree: _State.of(context).isAgree,
                onChanged: (isAgree) =>
                    _State.of(context).isAgree = isAgree ?? false,
                checkboxKey: _State.of(context).checkboxKey,
                hasError: _State.of(context).agreeTermsErrorStream,
                focusNode: _State.of(context).agreeTermsFocus,
              ),
              const SizedBox(height: 24),
              PrimaryButton.violet(
                onPressed: () async {
                  if (_State.of(context).formKey.currentState?.validate() ==
                      true) {
                    _State.of(context).formKey.currentState!.save();
                    FocusManager.instance.primaryFocus?.unfocus();
                    await _State.of(context).submit(context);
                  }
                },
                text: 'Зарегистрироваться',
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _Photo extends StatelessObserverWidget {
  const _Photo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhotoPicker(
          file: _State.of(context).avatar?.toFile(),
          onTap: () => _State.of(context).addAvatar(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Загрузить фото',
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Нажмите “Плюс” и сделайте  фото или загрузите из готовых',
                style: AppTextStyle.regularCaption.style(
                  context,
                  AppColors.violetLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
