import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

/*
* Виджеты кнопок
* */

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        gradient: AppColors.blueGradient,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            fixedSize: const Size.fromHeight(48),
            minimumSize: const Size.fromHeight(48),
            maximumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            )),
        child: child,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton._(
    this._bgColor,
    this._textColor, {
    required this.text,
    this.onPressed,
    this.onLongPress,
    this.borderRadius,
  });

  /// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=1428-601&mode=dev
  /// Фиолетовая кнопка
  factory PrimaryButton.violet({
    required String text,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) =>
      PrimaryButton._(
        AppColors.violetDark,
        AppColors.violet,
        text: text,
        onPressed: onPressed,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
      );

  /// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-7460&mode=dev
  /// Красная кнопка
  factory PrimaryButton.red({
    required String text,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) =>
      PrimaryButton._(
        AppColors.redDark,
        AppColors.red,
        text: text,
        onPressed: onPressed,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
      );

  /// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-7476&mode=dev
  /// Зеленая кнопка
  factory PrimaryButton.green({
    required String text,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) =>
      PrimaryButton._(
        AppColors.greenDark,
        AppColors.green,
        text: text,
        onPressed: onPressed,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
      );

  /// Зеленая кнопка
  /// используется в заказе
  factory PrimaryButton.greenInverse({
    required String text,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) =>
      PrimaryButton._(
        AppColors.green,
        AppColors.blackContainer,
        text: text,
        onPressed: onPressed,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
      );

  /// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-7496&mode=dev
  /// Синяя кнопка
  factory PrimaryButton.cyan({
    required String text,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) =>
      PrimaryButton._(
        AppColors.cyanDark,
        AppColors.cyan,
        text: text,
        onPressed: onPressed,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
      );

  /// Цвет фона
  final Color _bgColor;

  /// Цвет текста
  final Color _textColor;

  /// Текст на кнопке
  final String text;

  /// Нажатие
  final VoidCallback? onPressed;

  /// Длинное нажатие
  final VoidCallback? onLongPress;

  /// Закругление углов
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: _bgColor,
        surfaceTintColor: _bgColor,
        fixedSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(14),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.boldSubHeadline.style(
          context,
          _textColor,
        ),
      ),
    );
  }
}
