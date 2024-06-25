import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

class MasterOrderListItem extends StatelessWidget {
  const MasterOrderListItem({
    super.key,
    this.orderNumber,
    this.userName,
    this.date,
    this.time,
    this.textStatus,
  });

  final int? orderNumber;
  final String? userName;
  final String? date;
  final String? time;
  final String? textStatus;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: Container(
                height: 25,
                // width: 311,
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 32,
                ),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                          bottom: 3,
                        ),
                        child: Text(
                          '#$orderNumber',
                          // widget.textStatus.toString(),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 2,
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.green,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 2,
                                    left: 5,
                                  ),
                                  child: Text(
                                    textStatus ?? '',
                                    style: const TextStyle(
                                      color: AppColors.green,
                                      fontSize: 12,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 311,
                    margin: const EdgeInsets.only(
                      left: 15,
                      top: 24,
                      right: 32,
                    ),
                    child: Text(
                      userName ?? '',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    width: 311,
                    margin: const EdgeInsets.only(
                      left: 15,
                      top: 24,
                      right: 32,
                    ),
                    child: Text(
                      'Дата/Время: $date / $time',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(
                      left: 32,
                      top: 24,
                      right: 32,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              child: Container(
                height: 10,
                width: 311,
                margin: const EdgeInsets.only(
                  left: 32,
                  top: 10,
                  right: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
