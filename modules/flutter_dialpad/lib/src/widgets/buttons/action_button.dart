import 'package:flutter/material.dart';

import '../../mixins/scalable.dart';
import '../scalable/scalable.dart';

class ActionButton extends StatelessWidget with Scalable {
  ActionButton({
    super.key,
    this.title,
    this.subtitle,
    this.hideSubtitle = false,
    this.color = const Color(0xFF333333),
    this.textColor = Colors.white,
    this.icon,
    this.subtitleIcon,
    this.iconColor = Colors.white,
    this.subtitleIconColor,
    this.onTap,
    this.onLongPressed,
    this.buttonType = ButtonType.rectangle,
    this.padding = const EdgeInsets.all(0),
    this.disabled = false,
    this.scalingType = ScalingType.fixed,
    this.scalingSize = ScalingSize.small,
    this.minScalingSize,
    this.maxScalingSize,
    this.contentPadding,
    this.buttonSize = const Size.square(75),
  });

  /// Title to display on the button. If [icon] is provided, this
  /// will be ignored.
  final String? title;

  /// Subtitle (hint) to display below the title. If [subtitleIcon] is provided,
  /// this will be ignored. If neither are provided,
  /// subtitle (hint) will be hidden.
  final String? subtitle;

  /// Whether to hide the subtitle (hint). Defaults to false.
  final bool hideSubtitle;

  /// Background color of the button. Defaults to system/material color.
  final Color color;

  /// Text color of the button. Defaults to [Colors.black].
  final Color textColor;

  /// Icon to replace the title.
  final IconData? icon;

  /// Icon to replace the subtitle (hint). If not provided, subtitle (hint)
  /// will be used or hidden if not provided.
  final IconData? subtitleIcon;

  /// Color of the title icon. Defaults to [Colors.white].
  final Color iconColor;

  /// Color of the subtitle icon. Defaults to [iconColor].
  final Color? subtitleIconColor;

  /// Callback when the button is tapped.
  final VoidCallback? onTap;

  /// Callback when the button is held down for a longer period of time.
  final VoidCallback? onLongPressed;

  /// Button display style (clipping). Defaults to [ButtonType.rectangle].
  /// [ButtonType.circle] will clip the button to a circle e.g. an iPhone keypad
  /// [ButtonType.rectangle] will clip the button to
  /// a rectangle e.g. an Android keypad
  final ButtonType buttonType;

  /// Padding around the button. Defaults to [EdgeInsets.all(12)].
  final EdgeInsets padding;

  /// Whether to disable the button. Defaults to false.
  final bool disabled;

  /// [ScalingType] for the button. Defaults to [ScalingType.fixed].
  final ScalingType scalingType;

  /// [ScalingSize] for the button. Defaults to [ScalingSize.small].
  final ScalingSize scalingSize;

  /// Minimum scaling size for the button content. Defaults to null.
  final double? minScalingSize;

  /// Maximum scaling size for the button content. Defaults to null.
  final double? maxScalingSize;

  /// Padding around the button's content. Defaults to null.
  final EdgeInsets? contentPadding;

  final Size buttonSize;

  /// Get title widget, prefer icon over title
  Widget _buildTitleWidget(Size screenSize) {
    Widget widget = icon != null
        ? Icon(icon, size: buttonSize.width / 2, color: iconColor)
        : Text(
            title!,
            style: TextStyle(
              fontSize: buttonSize.width / 2,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 0,
            ),
          );

    // correction for asterisk being "higher" than other buttons
    // (only if we don't have subtitles to show)
    final hasSubtitle = subtitleIcon == null && subtitle == null;
    final showSubtitle = hasSubtitle && !hideSubtitle;
    if (title == '*' && !showSubtitle) {
      widget = Transform.translate(
        offset: const Offset(0, 10),
        child: widget,
      );
    }
    return widget;
  }

  /// Get subtitle widget, prefer subtitleIcon over subtitle
  Widget? _buildSubtitleWidget(Size screenSize) {
    return subtitleIcon != null
        ? Icon(subtitleIcon, color: subtitleIconColor ?? iconColor)
        : subtitle != null
            ? Text(
                subtitle ?? '',
                style: TextStyle(
                  color: textColor,
                  fontSize: buttonSize.width / 10,
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              )
            : null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;

      // Get title widget, prefer icon over title
      final titleWidget = _buildTitleWidget(size);

      // Get subtitle widget, prefer subtitleIcon over subtitle
      final subtitleWidget = _buildSubtitleWidget(size);

      // Create dial button text content
      final child = subtitleWidget == null || hideSubtitle == true
          ? titleWidget
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                subtitleWidget,
              ],
            );

      return Center(
        child: ElevatedButton(
          onPressed: onTap,
          onLongPress: onLongPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: buttonSize,
            maximumSize: buttonSize,
            fixedSize: buttonSize,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(buttonSize.width / 2),
              ),
            ),
            padding: EdgeInsets.zero,
            backgroundColor: color,
            surfaceTintColor: color,
          ),
          child: child,
        ),
      );

      // return Padding(
      //   padding: padding,
      //   child: ScalableButton(
      //     color: color,
      //     buttonType: buttonType,
      //     disabled: disabled,
      //     onPressed: onTap,
      //     padding: contentPadding ?? const EdgeInsets.all(0),
      //     onLongPressed: onLongPressed,
      //     child: child,
      //   ),
      // );
    });
  }
}
