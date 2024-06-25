// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/key_value.dart';

/// This widget is used to capture key events from the keyboard, and translate them into [DigitKey] or [ActionKey] events.
class KeypadFocusNode extends StatelessWidget {
  const KeypadFocusNode({
    required this.onKeypadPressed,
    required this.child,
    super.key,
  });

  /// This callback is called when a key is pressed on the keyboard.
  final ValueChanged<KeyValue> onKeypadPressed;

  /// The child widget that will be focused.
  final Widget child;

  /// Handles the key events from the keyboard, and translates them into [DigitKey] or [ActionKey] events that are passed to [onKeypadPressed].
  /// Returns [KeyEventResult.handled] if the event was handled, or [KeyEventResult.ignored] if the event was ignored.
  KeyEventResult _handleOnKeyEvent(FocusNode node, KeyEvent event) {
    if ((event is KeyRepeatEvent || event is KeyDownEvent) &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      onKeypadPressed(const ActionKey.backspace());
      return KeyEventResult.handled;
    } else if (event is KeyDownEvent) {
      // check if this is a key down event, otherwise we might get the same event multiple times
      final physicalKey = event.physicalKey;
      final logicalKey = event.logicalKey;
      if (physicalKey == PhysicalKeyboardKey.numpad0 ||
          physicalKey == PhysicalKeyboardKey.digit0) {
        onKeypadPressed(DigitKey(0));
      } else if (physicalKey == PhysicalKeyboardKey.numpad1 ||
          physicalKey == PhysicalKeyboardKey.digit1) {
        onKeypadPressed(DigitKey(1));
      } else if (physicalKey == PhysicalKeyboardKey.numpad2 ||
          physicalKey == PhysicalKeyboardKey.digit2) {
        onKeypadPressed(DigitKey(2));
      } else if (physicalKey == PhysicalKeyboardKey.numpad3 ||
          physicalKey == PhysicalKeyboardKey.digit3) {
        onKeypadPressed(DigitKey(3));
      } else if (physicalKey == PhysicalKeyboardKey.numpad4 ||
          physicalKey == PhysicalKeyboardKey.digit4) {
        onKeypadPressed(DigitKey(4));
      } else if (physicalKey == PhysicalKeyboardKey.numpad5 ||
          physicalKey == PhysicalKeyboardKey.digit5) {
        onKeypadPressed(DigitKey(5));
      } else if (physicalKey == PhysicalKeyboardKey.numpad6 ||
          physicalKey == PhysicalKeyboardKey.digit6) {
        onKeypadPressed(DigitKey(6));
      } else if (physicalKey == PhysicalKeyboardKey.numpad7 ||
          physicalKey == PhysicalKeyboardKey.digit7) {
        onKeypadPressed(DigitKey(7));
      } else if (physicalKey == PhysicalKeyboardKey.numpad8 ||
          physicalKey == PhysicalKeyboardKey.digit8) {
        onKeypadPressed(DigitKey(8));
      } else if (physicalKey == PhysicalKeyboardKey.numpad9 ||
          physicalKey == PhysicalKeyboardKey.digit9) {
        onKeypadPressed(DigitKey(9));
      } else if (physicalKey == PhysicalKeyboardKey.numpadMultiply ||
          logicalKey == LogicalKeyboardKey.asterisk) {
        onKeypadPressed(const ActionKey.asterisk());
      } else if (physicalKey == PhysicalKeyboardKey.numpadAdd ||
          logicalKey == LogicalKeyboardKey.add) {
        onKeypadPressed(const ActionKey.plus());
      } else if (physicalKey == PhysicalKeyboardKey.numpadEnter) {
        onKeypadPressed(const ActionKey.enter());
      } else if (logicalKey == LogicalKeyboardKey.numberSign) {
        onKeypadPressed(const ActionKey.hash());
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleOnKeyEvent,
      autofocus: true,
      child: child,
    );
  }
}
