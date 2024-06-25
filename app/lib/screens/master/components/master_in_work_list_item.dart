import 'package:core/core.dart';
import 'package:rempc/screens/master/components/master_in_work_status.dart';
import 'package:uikit/uikit.dart';

class MasterInWorkListItem extends StatelessWidget {
  const MasterInWorkListItem({
    required this.weekendDays,
    super.key,
    this.userNumber,
    this.userName,
    this.userStatus,
  });

  final int? userNumber;
  final dynamic userName;
  final List weekendDays;
  final int? userStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              '#$userNumber',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: AppColors.grayText,
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              top: 8,
            ),
            child: Text(
              userName,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              top: 8,
            ),
            child: Text(
              'Выходные: ${weekendDays.join(', ')}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        MasterInWorkStatus(userStatus: userStatus),
        Container(
          height: 1,
          margin: const EdgeInsets.only(
            left: 32,
            top: 10,
            right: 32,
            bottom: 10,
          ),
          decoration: const BoxDecoration(
            color: AppColors.violetLightDark,
          ),
        ),
      ],
    );
  }
}
