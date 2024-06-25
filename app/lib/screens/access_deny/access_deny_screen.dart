import 'package:core/core.dart';
import 'package:rempc/components/custom_title.dart';
import 'package:rempc/screens/sign_in/sign_in_screen.dart';
import 'package:uikit/uikit.dart';

/// Экран для отображения статуса "Доступ звпрещен"

class AccessDenyScreen extends StatelessWidget {
  const AccessDenyScreen({super.key});

  static String routeName = '/access-deny';

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushNamed(SignInScreen.routeName);
    });

    return Column(
      children: [
        const SizedBox(height: 50),
        const CustomTitle(text: 'Доступ запрещен'),
        Text(
          'Обратитесь к администратору',
          style: AppTextStyle.regularHeadline.style(context),
        ),
      ],
    );
  }
}
