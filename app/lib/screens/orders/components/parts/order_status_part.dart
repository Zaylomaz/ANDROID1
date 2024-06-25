import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

class OrderStatusPart extends StatelessWidget {
  const OrderStatusPart({
    required this.onTap,
    required this.status,
    required this.isDone,
    required this.isAvailable,
    required this.isLoading,
    super.key,
    this.isRework = false,
  });

  final VoidCallback onTap;
  final String status;
  final bool isDone;
  final bool isAvailable;
  final bool isLoading;
  final bool isRework;

  @override
  Widget build(BuildContext context) {
    final widgetColor = isRework
        ? AppColors.yellow
        : isDone
            ? AppColors.green
            : isAvailable
                ? AppColors.white
                : AppColors.violetLightDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 2, color: widgetColor),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            buildIcon(widgetColor),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                status,
                style: TextStyle(
                  color: widgetColor,
                  fontSize: 12,
                  height: 16 / 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIcon(Color widgetColor) {
    return (isLoading && isAvailable)
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : Icon(
            Icons.check_circle,
            color: widgetColor,
          );
  }
}
