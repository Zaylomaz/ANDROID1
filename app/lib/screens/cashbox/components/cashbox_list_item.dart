import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

class CashBoxListItem extends StatelessWidget {
  const CashBoxListItem({
    required this.cashboxIn,
    required this.isSubmitted,
    super.key,
    this.orderNumber,
    this.userName,
  });

  final int? orderNumber;
  final String? userName;
  final int cashboxIn;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppMaterialBox(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#$orderNumber',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppTextStyle.regularCaption.style(context),
            ),
            const SizedBox(height: 8),
            if (userName?.isNotEmpty == true)
              Row(
                children: [
                  AppIcons.service.iconColored(
                    color: AppSplitColor.cyan(),
                    iconSize: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userName!,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppTextStyle.regularHeadline.style(context),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcons.arrowRedoDown.iconColored(
                  color: AppSplitColor.green(),
                  iconSize: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$cashboxIn грн.',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppTextStyle.regularHeadline.style(
                      context,
                      AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
