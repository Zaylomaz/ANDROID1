import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

///
/// Виджет заголовка
///

@Deprecated('Удалить в перспективе')
class CustomTitle extends StatelessWidget {
  const CustomTitle({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 32,
          top: 20,
          right: 32,
          bottom: 20,
        ),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyle.regularHeadline.style(context, AppColors.violet),
        ),
      ),
    );
  }
}
