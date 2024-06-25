// ignore_for_file: lines_longer_than_80_chars

library flutter_dialpad;

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:uikit/uikit.dart';

// disabled temporarily
// import 'package:flutter_dtmf/dtmf.dart';

import 'src/flutter_dialpad.dart';

export 'src/flutter_dialpad.dart';

typedef DialPadButtonBuilder = Widget Function(BuildContext context, int index,
    KeyValue key, KeyValue? altKey, String? hint);

class DialPad extends StatefulWidget {
  const DialPad({
    super.key,
    this.makeCall,
    this.initialText,
    this.withNumber,
    this.keyPressed,
    this.onTextChanged,
    this.hideDialButton = false,
    this.hideBackspaceButton = false,
    this.hideSubtitle = false,
    this.outputMask = '(000) 000-0000',
    this.hint = '(000) 000-0000',
    this.buttonColor = const Color(0xff333333),
    this.buttonTextColor = Colors.white,
    this.dialButtonColor = Colors.green,
    this.dialButtonIconColor = Colors.white,
    this.dialButtonIcon = Icons.phone,
    this.dialOutputTextColor = Colors.black,
    this.dialOutputTextSize = 50,
    this.buttonTextSize = 75,
    this.subtitleTextSize = 25,
    this.backspaceButtonIconColor = Colors.grey,
    this.enableDtmf = false,
    @Deprecated(
        '''This has not yet been fully integrated for customer use and thus has no effect on the output - will be available in a future release.''')
    this.keypadButtonBuilder,
    this.buttonType = ButtonType.rectangle,
    this.buttonPadding = const EdgeInsets.all(0),
    this.backspaceButtonPadding = const EdgeInsets.all(0),
    this.dialButtonPadding = const EdgeInsets.all(0),
    this.callOnEnter = false,
    this.copyToClipboard = true,
    this.pasteFromClipboard = true,
    this.textFieldPadding =
        const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 16),
    this.scalingType = ScalingType.min,
    this.scalingSize = ScalingSize.medium,
    this.keyButtonContentPadding,
    this.hideBackspaceOnEmpty = true,
    this.dialAspectRatio = 9 / 16,
    this.additionalButton,
    this.buttonScale = 1,
  });

  /// Callback when the dial button is pressed.
  final ValueSetter<String>? makeCall;

  /// Initial unformatted text to display in the text field e.g. 15551234567
  final String? initialText;

  /// Updated number to display in the text field e.g. 15551234567
  final String? withNumber;

  /// Callback when a key is pressed.
  final ValueSetter<String>? keyPressed;

  /// Callback when text controller's content changed.
  final ValueChanged<String>? onTextChanged;

  /// Whether to hide the dial button. Defaults to false.
  final bool hideDialButton;

  /// Whether to hide the backspace button. Defaults to false.
  final bool hideBackspaceButton;

  /// Whether to hide the subtitle on the dial pad buttons. Defaults to [false].
  final bool hideSubtitle;

  /// buttonColor is the color of the button on the dial pad. defaults to [Colors.grey]
  final Color buttonColor;

  /// Color of the button text, defaults to [Colors.black]
  final Color buttonTextColor;

  /// Color of the dial button, defaults to [Colors.green]
  final Color dialButtonColor;

  /// Color of the dial button icon, defaults to [Colors.white]
  final Color dialButtonIconColor;

  /// Icon for the dial button, defaults to [Icons.phone]
  final IconData dialButtonIcon;

  /// Color of the backspace button icon, defaults to [Colors.grey]
  final Color backspaceButtonIconColor;

  /// Color of the output text, defaults to [Colors.black]
  final Color dialOutputTextColor;

  /// Font size for the output text, defaults to 50
  /// Text scales with the screen size using the shortest between (height & width) * 0.001 multiplied by the [dialOutputTextSize] value
  final double dialOutputTextSize;

  /// Font size for the output text, defaults to 75
  final double buttonTextSize;

  /// Font size for the output text, defaults to 25
  /// Text scales with the screen size using the shortest between (height & width) * 0.001 multiplied by the [subtitleTextSize] value
  final double subtitleTextSize;

  /// outputMask is the mask applied to the output text. Defaults to (000) 000-0000
  final String? outputMask;
  final String hint;

  /// Whether to enable DTMF tones. Defaults to [false].
  /// Disabled temporarily until [flutter_dtmf] has been updated.
  final bool enableDtmf;

  /// Builder for the keypad buttons. Defaults to [DialPadButtonBuilder].
  /// Note: this has not yet been fully integrated for customer use - this will be available in a future release.
  final DialPadButtonBuilder? keypadButtonBuilder;

  /// Button display style (clipping). Defaults to [ButtonType.rectangle].
  final ButtonType buttonType;

  /// Padding around the button. Defaults to [EdgeInsets.all(0)].
  final EdgeInsets buttonPadding;

  /// Padding around the button. Defaults to [buttonPadding].
  final EdgeInsets? backspaceButtonPadding;

  /// Padding around the button. Defaults to [buttonPadding].
  final EdgeInsets? dialButtonPadding;

  /// Whether to call [makeCall] when the enter key is pressed. Defaults to false.
  final bool callOnEnter;

  /// Whether to copy the text to the clipboard when the text field is tapped. Defaults to true.
  final bool copyToClipboard;

  /// Whether to paste the text from the clipboard when the text field is tapped. Defaults to true.
  final bool pasteFromClipboard;

  /// Padding around the text field. Defaults to [EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 16)].
  final EdgeInsets textFieldPadding;

  /// Scaling type for the dial pad. Defaults to [ScalingType.min].
  final ScalingType scalingType;

  /// Scaling size for the dial pad. Defaults to [ScalingSize.medium].
  final ScalingSize scalingSize;

  /// Add keypad button content padding used by [_defaultKeypadButtonBuilder]. Defaults to [EdgeInsets.zero].
  final EdgeInsets? keyButtonContentPadding;

  /// Hide backspace button when text field is empty. Defaults to [false].
  final bool hideBackspaceOnEmpty;

  final double dialAspectRatio;

  /// Место для кнопки вызова списка контактов
  final Widget? additionalButton;

  /// Размер кнопок
  final double buttonScale;

  @override
  State<DialPad> createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  late final MaskedTextController _controller;
  String _value = '';

  @override
  void initState() {
    super.initState();
    _controller = MaskedTextController(
      text: widget.initialText ?? widget.withNumber,
      mask: widget.outputMask,
    );
    _value = _controller.text;
    _controller.afterChange = (_, value) => _value = value;
  }

  /// Handles text field content change, notifies [onTextChanged] callback
  void _onTextChanged() {
    if (widget.onTextChanged != null) {
      widget.onTextChanged!(_controller.text);
    }
  }

  /// Handles keypad button press, this includes numbers and [DialActionKey] except [DialActionKey.backspace]
  void _onKeyPressed(String? value) {
    if (value != null) {
      setState(() {
        _value += value;
        _controller.updateText(_value);
      });
    }
  }

  /// Handles backspace button press
  void _onBackspacePressed() {
    if (_value.isEmpty) {
      return;
    }

    setState(() {
      _value = _value.substring(0, _value.length - 1);
      _controller.text = _value;
    });
  }

  /// Handles dial button press
  void _onDialPressed() {
    if (widget.makeCall != null && _value.isNotEmpty) {
      widget.makeCall!(_value);
    }
  }

  /// Handles all keyboard / UI keypad button presses
  void _onKeypadPressed(KeyValue key) {
    if (key is ActionKey && key.action == DialActionKey.backspace) {
      // handle backspace
      _onBackspacePressed();
    } else if (key is ActionKey && key.action == DialActionKey.enter) {
      if (widget.callOnEnter) {
        _onDialPressed();
      }
    } else {
      // For numbers, and all actions except backspace
      _onKeyPressed(key.value);
    }

    // notifies UI of input changed
    _onTextChanged();
  }

  Widget _defaultKeypadButtonBuilder(BuildContext context, int index,
      KeyValue key, KeyValue? altKey, String? hint) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ActionButton(
        title: key.value,
        subtitle: altKey?.value ?? hint,
        color: widget.buttonColor,
        hideSubtitle: widget.hideSubtitle,
        onTap: () => _onKeypadPressed(key),
        onLongPressed: () => _onKeypadPressed(altKey ?? key),
        buttonType: widget.buttonType,
        padding: widget.buttonPadding,
        contentPadding: widget.keyButtonContentPadding,
        textColor: widget.buttonTextColor,
        iconColor: widget.buttonTextColor,
        subtitleIconColor: widget.buttonTextColor,
        scalingType: widget.scalingType,
        scalingSize: widget.scalingSize,
        buttonSize: Size.square(75 * widget.buttonScale),
      ),
    );
  }

  @override
  void didUpdateWidget(DialPad oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if the withNumber property has changed, update the text field
    if (widget.withNumber != null &&
        widget.withNumber != oldWidget.withNumber) {
      // update text field
      _controller.updateText(widget.withNumber ?? '');
      // update value with masked number
      _value = _controller.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _keypadButtonBuilder = /*widget.keypadButtonBuilder ??  */
        _defaultKeypadButtonBuilder;
    const _generator = IosKeypadGenerator();

    /// Dial button
    final dialButton = widget.hideDialButton
        ? null
        : ActionButton(
            padding: widget.dialButtonPadding ?? widget.buttonPadding,
            buttonType: widget.buttonType,
            icon: widget.dialButtonIcon,
            iconColor: widget.dialButtonIconColor,
            color: widget.dialButtonColor,
            onTap: _onDialPressed,
            scalingType: widget.scalingType,
            buttonSize: Size.square(68 * widget.buttonScale),
          );

    /// Backspace button
    final backspaceButton = widget.hideBackspaceButton ||
            (_value.isEmpty && widget.hideBackspaceOnEmpty)
        ? null
        : ActionButton(
            onTap: () => _onKeypadPressed(const ActionKey.backspace()),
            buttonType: widget.buttonType,
            iconColor: const Color(0xFFA1A1A1),
            color: AppColors.black,
            padding: widget.backspaceButtonPadding ?? widget.buttonPadding,
            icon: Icons.backspace_sharp,
            buttonSize: Size.square(68 * widget.buttonScale),
          );

    /// Footer contains the dial and backspace buttons
    final footer = dialButton == null &&
            backspaceButton == null &&
            widget.additionalButton == null
        ? null
        : Row(
            children: [
              Expanded(child: widget.additionalButton ?? Container()),
              Expanded(child: dialButton ?? Container()),
              Expanded(child: backspaceButton ?? Container()),
            ],
          );

    final children = <Widget>[
      Padding(
        padding: widget.textFieldPadding,
        child: PhoneTextField(
          textColor: widget.dialOutputTextColor,
          textSize: widget.dialOutputTextSize,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hint,
            fillColor: AppColors.black,
          ),
          controller: _controller,
          copyToClipboard: widget.copyToClipboard,
          pasteFromClipboard: true,
          readOnly: true,
          scalingType: widget.scalingType,
          onPaste: (value) {
            setState(() {
              _value = value;
              _controller.updateText(_value);
            });
          },
        ),
      ),
      SizedBox.fromSize(
        size: Size(278 * widget.buttonScale, 474 * widget.buttonScale),
        child: KeypadGrid(
          itemCount: 12,
          itemBuilder: (context, index) {
            final key = _generator.get(index);
            final altKey = _generator.getAlt(index);
            final hint = _generator.hint(index);
            return _keypadButtonBuilder(
              context,
              index,
              key,
              altKey,
              hint,
            );
          },
          footer: footer,
        ),
      ),
    ];

    return KeypadFocusNode(
      onKeypadPressed: _onKeypadPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
