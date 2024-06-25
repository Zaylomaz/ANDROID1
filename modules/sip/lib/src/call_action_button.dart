import 'package:core/core.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    this.title,
    this.subTitle = '',
    this.icon,
    this.onPressed,
    this.onLongPress,
    this.checked = false,
    this.number = false,
    this.fillColor,
  });

  final String? title;
  final String subTitle;
  final IconData? icon;
  final bool checked;
  final bool number;
  final Color? fillColor;
  final Function()? onPressed;
  final Function()? onLongPress;

  @override
  ActionButtonState createState() => ActionButtonState();
}

class ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
            onLongPress: widget.onLongPress,
            onTap: widget.onPressed,
            child: RawMaterialButton(
              onPressed: widget.onPressed,
              splashColor: widget.fillColor ??
                  (widget.checked ? Colors.white : Colors.blue),
              fillColor: widget.fillColor ??
                  (widget.checked ? Colors.blue : Colors.white),
              elevation: 10,
              shape: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: widget.number
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text('${widget.title}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: widget.fillColor ?? Colors.grey[500],
                                )),
                            Text(widget.subTitle.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: widget.fillColor ?? Colors.grey[500],
                                ))
                          ])
                    : Icon(
                        widget.icon,
                        size: 30,
                        color: widget.fillColor != null
                            ? Colors.white
                            : (widget.checked ? Colors.white : Colors.blue),
                      ),
              ),
            )),
        if (widget.number)
          Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2))
        else
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: (widget.number || widget.title == null)
                ? null
                : Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.fillColor ?? Colors.grey[500],
                    ),
                  ),
          )
      ],
    );
  }
}
