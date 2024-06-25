// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';
import 'package:uikit/uikit.dart';

import '../mixins/scalable.dart';

typedef ClipboardWidgetBuilder = Widget Function(
    BuildContext context, VoidCallback onCopyPressed);

class PhoneTextField extends StatelessWidget with Scalable {
  const PhoneTextField({
    required this.controller,
    required this.onPaste,
    super.key,
    this.textStyle,
    this.color = Colors.white,
    this.textColor = Colors.grey,
    this.textSize = 15,
    this.decoration = const InputDecoration(border: InputBorder.none),
    this.readOnly = false,
    this.textAlign = TextAlign.center,
    this.copyToClipboard = false,
    this.pasteFromClipboard = false,
    this.copyToClipboardBuilder,
    this.pasteFromClipboardBuilder,
    this.scalingType = ScalingType.fixed,
    this.scalingSize = ScalingSize.small,
    this.minScalingSize,
    this.maxScalingSize,
  });

  /// TextStyle for the text field.
  final TextStyle? textStyle;

  /// The background color of the text field. Defaults to [Colors.white].
  final Color color;

  /// The text color of the text field. Defaults to [Colors.grey].
  final Color textColor;

  /// Font size for the text field, as a percentage of the screen height.
  /// Defaults to 25.
  final double textSize;

  /// The decoration to show around the text field. Defaults to
  /// [InputDecoration(border: InputBorder.none)].
  final InputDecoration decoration;

  /// Add copyToClipboard widget to the text field. Defaults to false.
  final bool copyToClipboard;
  final bool pasteFromClipboard;

  /// The controller for the text field.
  final TextEditingController controller;

  /// Whether the text field is read only. Defaults to false.
  final bool readOnly;

  /// The alignment of the text field. Defaults to [TextAlign.center].
  final TextAlign textAlign;

  /// Builder for the copyToClipboard widget. Defaults to [_defaultCopyToClipboardBuilder].
  final ClipboardWidgetBuilder? copyToClipboardBuilder;

  /// Builder for the copyToClipboard widget. Defaults to [_defaultPasteFromClipboardBuilder].
  final ClipboardWidgetBuilder? pasteFromClipboardBuilder;

  /// [ScalingType] for the button. Defaults to [ScalingType.fixed].
  final ScalingType scalingType;

  /// [ScalingSize] for the button. Defaults to [ScalingSize.small].
  final ScalingSize scalingSize;

  /// Minimum scaling size for the button content. Defaults to null.
  final double? minScalingSize;

  /// Maximum scaling size for the button content. Defaults to null.
  final double? maxScalingSize;

  final Function(String) onPaste;

  void _onCopyPressed() {
    Clipboard.setData(ClipboardData(text: controller.text));
  }

  Future<void> _onPastePressed() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text?.isNotEmpty == true) {
      controller
        ..text = data!.text!
        ..value = TextEditingValue(
          text: data.text!,
          selection: TextSelection.fromPosition(
            TextPosition(offset: data.text!.length),
          ),
        );
      onPaste.call(controller.text);
    }
  }

  Widget _defaultCopyToClipboardBuilder() {
    return IconButton(
      icon: const Icon(
        Icons.copy,
        color: AppColors.violet,
      ),
      onPressed: _onCopyPressed,
    );
  }

  Widget _defaultPasteFromClipboardBuilder() {
    return IconButton(
      icon: const Icon(
        Icons.paste,
        color: AppColors.violet,
      ),
      onPressed: _onPastePressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textInput = ContextMenuRegion(
      contextMenuBuilder: (context, offset) {
        // The custom context menu will look like the default context menu
        // on the current platform with a single 'Print' button.
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: offset,
          ),
          buttonItems: <ContextMenuButtonItem>[
            ContextMenuButtonItem(
              onPressed: () {
                ContextMenuController.removeAny();
                _onPastePressed();
              },
              label: 'Вставить',
            ),
          ],
        );
      },
      child: IgnorePointer(
        ignoring: readOnly,
        child: AppTextInputField(
          keyboardType: TextInputType.phone,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          decoration: decoration,
          readOnly: readOnly,
          textAlign: textAlign,
          controller: controller,
        ),
      ),
    );
    return textInput;
    // if (copyToClipboard || pasteFromClipboard) {
    //   return Row(
    //     children: [
    //       Expanded(child: textInput),
    //       const SizedBox(width: 16),
    //       if (copyToClipboard)
    //         copyToClipboardBuilder?.call(context, _onCopyPressed) ??
    //             _defaultCopyToClipboardBuilder(),
    //       if (pasteFromClipboard)
    //         pasteFromClipboardBuilder?.call(context, _onPastePressed) ??
    //             _defaultPasteFromClipboardBuilder()
    //     ],
    //   );
    // } else {
    //   return textInput;
    // }
  }
}
