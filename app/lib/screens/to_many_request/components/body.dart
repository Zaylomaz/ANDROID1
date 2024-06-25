import 'package:core/core.dart';
import 'package:rempc/components/custom_title.dart';
import 'package:uikit/uikit.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CustomTitle(text: 'Слишком много запросов'),
        Text(
          'Попробуйте повторить позже',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}
