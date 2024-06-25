import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:rempc/screens/web_view/web_view_screen.dart';
import 'package:uikit/uikit.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({
    required this.isAgree,
    required this.onChanged,
    this.hasError,
    this.checkboxKey,
    this.focusNode,
    super.key,
  });

  /// Текущий выбранный параметр чекбокса
  final bool isAgree;

  /// Коллбек нажатия на чекбокс
  final Function(bool?) onChanged;

  /// Красный бордер при ошибке
  final Stream<bool>? hasError;

  /// Ключ для [CustomShakeWidget]
  final GlobalKey<CustomShakeWidgetState>? checkboxKey;

  /// Нода фокусировки
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomShakeWidget(
          key: checkboxKey,
          child: AppCheckBox(
            value: isAgree,
            onChanged: onChanged,
            focusNode: focusNode,
            hasError: hasError,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyle.regularSubHeadline.style(context),
              children: [
                const TextSpan(text: 'Я соглашаюсь с '),
                TextSpan(
                  text: 'условиями использования',
                  style: const TextStyle(
                    color: AppColors.violet,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.of(context).pushNamed(
                          WebViewScreen.routeName,
                          arguments: WebViewScreenArgs.fromUri(
                            title: 'Условия использования',
                            initialUri: Uri.parse(
                              '${ApiBuilder().dio.options.baseUrl}text/terms',
                            ),
                          ),
                        ),
                ),
                const TextSpan(text: ' и '),
                TextSpan(
                  text: 'политикой конфиденциальности',
                  style: const TextStyle(
                    color: AppColors.violet,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.of(context).pushNamed(
                          WebViewScreen.routeName,
                          arguments: WebViewScreenArgs.fromUri(
                            title: 'Политика конфиденциальности',
                            initialUri: Uri.parse(
                              '${ApiBuilder().dio.options.baseUrl}text/conditions',
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
