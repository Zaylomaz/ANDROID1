// ignore_for_file: comment_references

import 'dart:math';

import 'package:flutter/material.dart';

/// Интерфейс для [StatefulWidget] с [TickerProvider] и контроллером анимации
abstract class AnimationControllerState<T extends StatefulWidget>
    extends State<T> with TickerProviderStateMixin {
  AnimationControllerState(this.animationDuration);

  final Duration animationDuration;
  late final animationController =
      AnimationController(vsync: this, duration: animationDuration);

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

/// Обертка для виджетов позволяющая их трусить
/// Хорошо подходит для привлечения внимания к визуальным елементам
/// Для реализации тряски нужно передать
/// [GlobalKey<CustomShakeWidgetState>] в параметр [Key]
/// Труситься виджет будет при вызове метода [shake]
/// через [currentState] ключа
class CustomShakeWidget extends StatefulWidget {
  const CustomShakeWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.shakeCount = 6,
    this.shakeOffset = 3,
    Key? key,
  }) : super(key: key);

  /// Виджет который будем трясти
  final Widget child;

  /// Диапазон тряски
  final double shakeOffset;

  /// Количество
  final int shakeCount;

  /// Период тряски
  final Duration duration;

  @override
  // ignore: no_logic_in_create_state
  CustomShakeWidgetState createState() => CustomShakeWidgetState(duration);
}

class CustomShakeWidgetState
    extends AnimationControllerState<CustomShakeWidget> {
  CustomShakeWidgetState(Duration duration) : super(duration);

  @override
  void initState() {
    super.initState();
    animationController.addStatusListener(_updateStatus);
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_updateStatus);
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
  }

  void shake() {
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: widget.child,
      builder: (context, child) {
        final sineValue =
            sin(widget.shakeCount * 2 * pi * animationController.value);
        return Transform.translate(
          offset: Offset(sineValue * widget.shakeOffset, 0),
          child: child,
        );
      },
    );
  }
}
