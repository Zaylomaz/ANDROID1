import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.onPressedRetry,
    required this.errorText,
    this.buttonText = 'Retry',
    this.additional,
    super.key,
  });

  final VoidCallback onPressedRetry;
  final String errorText;
  final String buttonText;
  final Widget? additional;

  static final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xffFFAC18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    fixedSize: const Size.fromHeight(44),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );

  static const buttonTextStyle = TextStyle(
    color: Color(0xff263238),
    fontSize: 16,
    height: 19 / 16,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(),
            Text(
              errorText,
              style: AppTextStyle.regularHeadline.style(context),
            ),
            const Spacer(),
            PrimaryButton.violet(
              onPressed: onPressedRetry,
              text: buttonText.toUpperCase(),
            ),
            if (additional != null) ...[
              const SizedBox(height: 12),
              additional!,
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  EdgeInsetsGeometry getErrorIconPadding() => const EdgeInsets.only(bottom: 16);
}
