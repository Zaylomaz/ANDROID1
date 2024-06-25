import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

///
/// Виждет отображения списка ошибок
///

class FormError extends StatelessWidget {
  const FormError({
    required this.errors,
    super.key,
  });

  final List<String?> errors;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: AppTextStyle.regularCaption.style(context, AppColors.red),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(
              errors.length, (index) => formErrorText(error: errors[index]!)),
        ),
      ),
    );
  }

  Widget formErrorText({required String error}) => Text(error);
}
