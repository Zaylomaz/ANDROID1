import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:uikit/uikit.dart';

import 'form_validators/email_validator_lib.dart' as ev;

mixin FormValidator {
  static String? inputFieldValidator(
    String? value,
    List<TextInputValidator> validators,
  ) {
    for (final validator in validators) {
      return validator.check(value);
    }
    return null;
  }
}

/// Интерфейс валидатора для текстового поля
abstract class TextInputValidator<T> {
  /// Ругательство
  String get errorMessage;

  /// Метод проверки на валидность
  String? check(T? value);
}

/// Валидатор по сути отвечает за required поля
class NotEmptyValidator extends TextInputValidator<String> {
  @override
  String? check(String? value) {
    if (value == null || value.trim().isEmpty == true) {
      return errorMessage;
    }
    return null;
  }

  @override
  String get errorMessage => 'Поле не может быть пустым';
}

/// Валидатор минимальной длинны текста
class MinLengthValidator extends TextInputValidator<String> {
  MinLengthValidator(this.minLength);
  final int minLength;
  @override
  String? check(String? value) {
    if (value == null || value.trim().length < minLength) {
      return errorMessage;
    }
    return null;
  }

  @override
  String get errorMessage => 'Минимальная длина $minLength симовлов';
}

/// Валидатор максимально длинны текста
class MaxLengthValidator extends TextInputValidator<String> {
  MaxLengthValidator(this.maxLength);
  final int maxLength;
  @override
  String? check(String? value) {
    if (value != null && value.trim().length > maxLength) {
      return errorMessage;
    }
    return null;
  }

  @override
  String get errorMessage => 'Максимальная длина $maxLength симовлов';
}

/// Валидатор длинны текста в диапазоне
class RangeLengthValidator extends TextInputValidator<String> {
  RangeLengthValidator(this.minLength, this.maxLength);
  final int minLength;
  final int maxLength;
  @override
  String? check(String? value) {
    if (value == null ||
        value.trim().length > maxLength ||
        value.trim().length < minLength) {
      return errorMessage;
    }
    return null;
  }

  @override
  String get errorMessage =>
      'Поле вмещает от $minLength до $maxLength симовлов';
}

/// Валидатор Email
class EmailValidator extends TextInputValidator<String> {
  @override
  String? check(String? value) {
    if (!ev.EmailValidator.validate(value ?? '')) {
      return errorMessage;
    }
    return null;
  }

  @override
  String get errorMessage => 'Не верный email адрес';
}

/// Класс для работы с [AppTextInputField] который при валидации
/// подсвечивается красным
/// опционально может дрыгаться
/// опционально может запрашивать фокус
/// может иметь свой порядок в массиве применяя метод [Iterable.sort]
/// для корректной работы в [AppTextInputField] в качестве валидатора
/// нужно использовать метод [inputFieldValidator]
class ShakerField implements Comparable<int> {
  ShakerField._({
    required this.controller,
    required this.focusNode,
    required this.shakeKey,
    this.order = 0,
  });

  /// Стандартный конструктор класса [ShakerField]
  /// создает набор необходимых классов для работы с инпутом
  /// который реагирует на ошибку вибрацией
  factory ShakerField.create({String? text, int? order}) => ShakerField._(
        controller: TextEditingController(text: text),
        focusNode: FocusNode(),
        shakeKey: GlobalKey<CustomShakeWidgetState>(),
        order: order ?? 0,
      );

  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey<CustomShakeWidgetState> shakeKey;

  /// для использования [sort]
  final int order;
  bool hasError = false;

  String? inputFieldValidator(
    String? value,
    List<TextInputValidator> validators,
  ) {
    for (final validator in validators) {
      final message = validator.check(value);
      if (message?.isNotEmpty == true) {
        hasError = true;
        return message;
      }
    }
    hasError = false;
    return null;
  }

  /// получает значение поля
  String get textValue => controller.text.trim();

  /// назначает в поле текст
  set textValue(String? text) => controller.text = text ?? '';

  /// запрашивает фокус
  void requestFocus() => focusNode.requestFocus();

  /// анимация вибрации
  void shake() => shakeKey.currentState?.shake();

  /// обязательный метод при окончании работы с классом
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    shakeKey.currentState?.dispose();
  }

  @override
  int compareTo(int other) => order.compareTo(other);
}

/// Форматтер не даст ввести ничего кроме цифр
final numberFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  FilteringTextInputFormatter.digitsOnly
];

/// Форматтер не даст ввести ничего длиннее чем указано в [maxLength]
List<TextInputFormatter> maxLengthFormatter(int maxLength) =>
    <TextInputFormatter>[
      LengthLimitingTextInputFormatter(maxLength),
    ];
