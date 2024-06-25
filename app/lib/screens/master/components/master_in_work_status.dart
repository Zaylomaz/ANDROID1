import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

class MasterInWorkStatus extends StatefulWidget {
  const MasterInWorkStatus({super.key, this.userStatus});

  final int? userStatus;

  @override
  State<MasterInWorkStatus> createState() => _MasterInWorkStatusState();
}

class _MasterInWorkStatusState extends State<MasterInWorkStatus> {
  String _textStatus = '';
  Color _colorStatus = AppColors.green;

  @override
  Widget build(BuildContext context) {
    if (widget.userStatus == 1) {
      _textStatus = 'Подтвержден';
      _colorStatus = AppColors.green;
    }
    if (widget.userStatus == 2) {
      _textStatus = 'Выходной';
      _colorStatus = AppColors.violetLight;
    }
    if (widget.userStatus == 3) {
      _textStatus = 'Не поджвержден';
      _colorStatus = AppColors.red;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          top: 8,
        ),
        child: Text(
          _textStatus,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: _colorStatus,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
