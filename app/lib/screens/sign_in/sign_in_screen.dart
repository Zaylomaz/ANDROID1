import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/sign_up/sign_up_screen.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:rempc/ui/components/terms_and_conditions.dart';
import 'package:rempc/ui/screens/tab/main_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

/*
* Экран логина
*/

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const String routeName = '/sign_in';

  Future<bool> _onWillPop() async {
    unawaited(SystemNavigator.pop());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SignForm(),
        ),
        bottomNavigationBar: Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'У меня ещё нет аккаунта.'),
            const TextSpan(text: '\n'),
            TextSpan(
              text: 'Зарегистрироваться',
              style: const TextStyle(
                color: AppColors.violet,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushNamed(SignUpScreen.routeName);
                },
            ),
          ]),
          textAlign: TextAlign.center,
          style: AppTextStyle.regularHeadline.style(context),
        ),
      ),
    );
  }
}

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  SignFormState createState() => SignFormState();
}

class SignFormState extends State<SignForm> {
  static const platform = MethodChannel('helperService');

  /// Поле Email
  final email = ShakerField.create();

  /// Поле пароля
  final pass = ShakerField.create();

  /// Ключ чекбокса
  final GlobalKey<CustomShakeWidgetState> _checkboxKey =
      GlobalKey<CustomShakeWidgetState>();

  /// Ключ валидации формы
  final _formKey = GlobalKey<FormState>();
  final agreeTermsErrorStream = BehaviorSubject.seeded(false);
  bool isAgree = false;
  final termsFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    /// Фокус на поле логина
    Future.delayed(const Duration(milliseconds: 300), email.requestFocus);
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    termsFocus.dispose();
    _formKey.currentState?.dispose();
    _checkboxKey.currentState?.dispose();
    super.dispose();
  }

  /// Метод логина
  Future<void> submit() async {
    final onesignalUserid = await platform.invokeMethod('getOneSignalUserId');
    try {
      /// Попытка логина
      final accessToken = await AuthRepository().login(
        email.textValue,
        pass.textValue,
        onesignalUserid,
      );

      /// Сохранение токена
      ApiStorage().accessToken = accessToken;
      await platform.invokeMethod(
        'setUserAuthToken',
        {'userAuthToken': accessToken},
      );
      await platform.invokeMethod(
        'loginEvent',
        {'email': email.textValue},
      );

      try {
        final permissions = await AuthRepository().getUserPermissions();
        context.read<HomeData>().permissions = permissions;
      } finally {
        /// Переход на главную
        unawaited(Navigator.of(context).pushNamedAndRemoveUntil(
          MainScreen.routeName,
          (r) => false,
        ));
        await HomeData.of(context).init();
      }
    } catch (e) {
      if (e is ApiException) {
        await showMessage(
          context,
          type: AppMessageType.error,
          message: e.messages.entries.first.value.first,
        );
      }
      if (e is TooManyRequestsException) {
        unawaited(
            Navigator.of(context).pushNamed(ToManyRequestScreen.routeName));
      }
      if (e is UnknownApiException) {
        await showMessage(
          context,
          type: AppMessageType.error,
          message: '500 ServerError',
        );
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              'Добро пожаловать',
              style: AppTextStyle.boldLargeTitle.style(context),
            ),
            const SizedBox(height: 16),
            Text(
              '''Войдите в свой аккаунт для дальнейшего использования приложения''',
              style: AppTextStyle.regularHeadline.style(context),
            ),
            const SizedBox(height: 24),
            AppTextInputField(
              controller: email.controller,
              focusNode: email.focusNode,
              shakeKey: email.shakeKey,
              onEditingComplete: pass.requestFocus,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => email.inputFieldValidator(
                value,
                [NotEmptyValidator()],
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Электронная почта'),
            ),
            const SizedBox(height: 15),
            AppTextInputField(
              controller: pass.controller,
              focusNode: pass.focusNode,
              shakeKey: pass.shakeKey,
              obscureText: true,
              validator: (value) => pass.inputFieldValidator(
                value,
                [
                  NotEmptyValidator(),
                ],
              ),
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            const SizedBox(height: 24),
            TermsAndConditions(
              isAgree: isAgree,
              onChanged: (isAgree) {
                setState(() {
                  this.isAgree = isAgree ?? false;
                });
              },
              hasError: agreeTermsErrorStream,
              checkboxKey: _checkboxKey,
              focusNode: termsFocus,
            ),
            const SizedBox(height: 24),
            PrimaryButton.violet(
              onPressed: () async {
                _formKey.currentState!.save();
                try {
                  if (_formKey.currentState?.validate() == true && isAgree) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    await withLoadingIndicator(() async {
                      await submit();
                    });
                  } else {
                    if (email.hasError) {
                      email
                        ..requestFocus()
                        ..shake();
                    } else if (pass.hasError) {
                      pass
                        ..requestFocus()
                        ..shake();
                    } else if (!isAgree) {
                      agreeTermsErrorStream.add(true);
                      _checkboxKey.currentState?.shake();
                      termsFocus.requestFocus();
                    }
                  }
                } catch (e, s) {
                  debugPrint(e.toString());
                  debugPrint(s.toString());
                }
              },
              text: 'Войти',
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// GET '/user/login'
/// Error: response.error = Object
// {
//   'type': 'FORM_VALIDATION_ERROR',
//   'fields': {
//     'login': [
//       'Email должен быть уникальным',
//       'Любая другая ошибка',
//     ],
//     'password': [
//       'Пароль слишком простой',
//       'Любая другая ошибка',
//     ]
//   }
// }
