// ignore_for_file: avoid_positional_boolean_parameters, comment_references

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:uikit/uikit.dart';

/*
* Виджеты для постройки форм
* */

/// Подогнанный к дизайну [TextFormField]
/// Реализация как в [TextFormField]
/// добавлено контекстное меню
/// изменен дизайн подписи поля
class AppTextInputField extends StatelessWidget {
  const AppTextInputField({
    this.restorationId,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
    this.cursorWidth = 1,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor = AppColors.white,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20),
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.enableIMEPersonalizedLearning = true,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.shakeKey,
    super.key,
  });

  final String? restorationId;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String?>? onSaved;
  final FormFieldValidator<String?>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final bool enableIMEPersonalizedLearning;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final GlobalKey<CustomShakeWidgetState>? shakeKey;

  static EditableTextContextMenuBuilder defaultContextMenuBuilder =
      (context, editableTextState) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: <ContextMenuButtonItem>[
        ContextMenuButtonItem(
          onPressed: () {
            editableTextState.copySelection(SelectionChangedCause.toolbar);
          },
          type: ContextMenuButtonType.copy,
          label: 'Копировать',
        ),
        ContextMenuButtonItem(
          onPressed: () {
            editableTextState.pasteText(SelectionChangedCause.toolbar);
          },
          type: ContextMenuButtonType.paste,
          label: 'Вставить',
        ),
        ContextMenuButtonItem(
          onPressed: () {
            editableTextState.cutSelection(SelectionChangedCause.toolbar);
          },
          type: ContextMenuButtonType.cut,
          label: 'Вырезать',
        ),
      ],
    );
  };

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      restorationId: restorationId,
      initialValue: initialValue,
      controller: controller,
      focusNode: focusNode,
      decoration: decoration?.copyWith(
        labelText: '',
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: style ?? AppTextStyle.regularHeadline.style(context),
      strutStyle: strutStyle,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      textDirection: textDirection,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      readOnly: readOnly,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onSaved: onSaved,
      onChanged: onChanged,
      onTap: onTap,
      onTapOutside: onTapOutside,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      scrollPadding: scrollPadding,
      scrollPhysics: scrollPhysics,
      keyboardAppearance: keyboardAppearance,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      buildCounter: buildCounter,
      autofillHints: autofillHints,
      scrollController: scrollController,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
      contextMenuBuilder: contextMenuBuilder ?? defaultContextMenuBuilder,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (decoration?.labelText?.isNotEmpty == true) ...[
          Text(
            decoration!.labelText!,
            style: AppTextStyle.regularCaption.style(context),
          ),
          const SizedBox(height: 8),
        ],
        if (shakeKey != null)
          CustomShakeWidget(
            key: shakeKey,
            child: textField,
          )
        else
          textField,
      ],
    );
  }
}

/// Меню выбора дропдаун
/// Выбирает одну опцию из списка
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.value,
    required this.onChange,
    this.dropdownColor = AppColors.blackContainer,
    Key? key,
  }) : super(key: key);

  /// Список опций
  final Iterable<MapEntry<T, String>> items;

  /// Текущее значение
  final T value;

  /// Коллбек выбора
  final Function(T?)? onChange;

  /// Название поля
  final String label;

  /// Фон поля
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FormField(
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: AppTextStyle.regularCaption.style(context),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<T>(
                          icon: const SizedBox.shrink(),
                          isExpanded: true,
                          enableFeedback: false,
                          dropdownColor: dropdownColor,
                          borderRadius: BorderRadius.circular(12),
                          value: value,
                          onChanged: onChange,
                          items: items
                              .map(
                                (e) => DropdownMenuItem<T>(
                                  value: e.key,
                                  child: Text(
                                    e.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.regularHeadline
                                        .style(context),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 16,
                      child: IgnorePointer(
                        child: AppIcons.chevron.widget(
                          color: AppColors.violet,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Меню выбора в виде облачка тегов
/// Выбирает несколько опций из списка
class AppMultiSelectField<T> extends StatelessWidget {
  const AppMultiSelectField({
    required this.label,
    required this.items,
    required this.value,
    required this.onChange,
    Key? key,
  }) : super(key: key);

  /// Список опций
  final Iterable<MapEntry<T, String>> items;

  /// Текущее значение
  final Iterable<T> value;

  /// Коллбек при выборе
  final Function(List<T>) onChange;

  /// Название
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyle.regularCaption.style(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 16,
          children: items
              .map((e) => _Chip<T>(
                    label: e.value,
                    isSelected: value.contains(e.key),
                    onTap: () {
                      final list = List<T>.from(value);
                      if (list.contains(e.key)) {
                        list.remove(e.key);
                      } else {
                        list.add(e.key);
                      }
                      onChange.call(list);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Меню выбора дропдаун
/// Выбирает несколько опций из списка
/// Использует библиотеку [multiselect_dropdown]
/// TODO форкнуть в проект и подправить дизайн дропдауна
class AppDropdownMultiSelectField<T> extends StatelessWidget {
  AppDropdownMultiSelectField({
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.onSelected,
    required this.valueTransformer,
    super.key,
  });

  /// Название
  final String label;

  /// Список опций
  final Map<T, dynamic> options;

  /// Выбранные опции
  final Map<T, dynamic> selectedOptions;

  /// Коллбек выбора
  final Function(List<T>) onSelected;

  /// Приводит тип опции к указанному
  final Function(String?) valueTransformer;

  /// Контроллер
  final controller = MultiSelectController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.regularCaption.style(context),
        ),
        const SizedBox(height: 8),
        MultiSelectDropDown(
          controller: controller,
          onOptionSelected: (options) {
            onSelected.call(
                options.map((e) => valueTransformer(e.value) as T).toList());
          },
          selectedOptions: selectedOptions.entries
              .map((e) => ValueItem(label: e.value, value: e.key.toString()))
              .toList(),
          options: options.entries
              .map((e) => ValueItem(label: e.value, value: e.key.toString()))
              .toList(),
          optionSeparator: const SizedBox(height: 4),
          chipConfig: const ChipConfig(
            wrapType: WrapType.wrap,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          dropdownHeight: 300,
          optionTextStyle: const TextStyle(fontSize: 16),
          selectedOptionIcon: const Icon(
            Icons.check_circle,
            color: AppColors.violet,
          ),
          selectedOptionBackgroundColor: AppColors.white,
          backgroundColor: AppColors.blackContainer,
          borderColor: AppColors.blackContainer,
          focusedBorderColor: AppColors.blackContainer,
          borderWidth: 0,
          focusedBorderWidth: 0,
          showClearIcon: false,
          hint: '',
          hintColor: AppColors.white,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.violet,
          ),
          selectedItemBuilder: (context, item) => _Chip(
            label: item.label,
            isSelected: true,
            onTap: () {
              controller.clearSelection(item);
            },
          ),
        ),
      ],
    );
  }
}

/// Виджет опции для [AppMultiSelectField]
class _Chip<V> extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    this.onTap,
    super.key,
  });

  /// Название опции
  final String label;

  /// Коллбек нажатия
  final VoidCallback? onTap;

  /// Выбран или нет
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.violetLight,
        ),
      ),
      color: isSelected ? AppColors.violetLight : AppColors.black,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 3, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24,
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyle.regularHeadline.style(
                      context,
                      isSelected ? AppColors.black : AppColors.violetLight,
                    ),
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                SizedBox.square(
                  dimension: 24,
                  child: AppIcons.close.widget(color: AppColors.black),
                ),
              ] else
                const SizedBox(
                  width: 13,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Checkbox
/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-7500&mode=dev
class AppCheckBox extends StatefulWidget {
  AppCheckBox({
    required this.value,
    required this.onChanged,
    this.hasError,
    this.focusNode,
    super.key,
  });

  factory AppCheckBox.withLabel({
    required Widget label,
    required bool value,
    required Function(bool?) onChanged,
    Stream<bool>? hasError,
    FocusNode? focusNode,
    Key? key,
  }) =>
      AppCheckBox(
        value: value,
        onChanged: onChanged,
        hasError: hasError,
        focusNode: focusNode,
        key: key,
      )..label = label;

  /// Выбран или нет
  final bool value;

  /// Коллбек нажатия
  final Function(bool?) onChanged;

  /// Красный бордер при ошибке
  final Stream<bool>? hasError;

  /// Фокус на поле
  final FocusNode? focusNode;

  /// Подпись (опционально)
  Widget? label;

  @override
  State<AppCheckBox> createState() => _AppCheckBoxState();
}

class _AppCheckBoxState extends State<AppCheckBox> {
  bool hasError = false;
  bool? _previousValue;
  @override
  void initState() {
    _previousValue = widget.value;
    widget.hasError?.listen((event) {
      if (event) {
        setState(() {
          hasError = true;
        });
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppCheckBox oldWidget) {
    setState(() {
      _previousValue = widget.value;
    });
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildCheckbox(BuildContext context) => SizedBox.square(
        dimension: 24,
        child: Material(
          clipBehavior: Clip.hardEdge,
          color: AppColors.blackContainer,
          surfaceTintColor: AppColors.blackContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: hasError ? AppColors.red : AppColors.violetLight,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                hasError = false;
                _previousValue = !_previousValue!;
                widget.onChanged.call(_previousValue);
              });
            },
            focusNode: widget.focusNode,
            focusColor: AppColors.red,
            child: AppIcons.checkbox.widget(
              color:
                  AppColors.green.withOpacity(_previousValue == true ? 1 : 0),
              width: 24,
              height: 24,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.label is Widget) {
      return Row(
        children: [
          _buildCheckbox(context),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: AppTextStyle.regularHeadline.style(context),
              child: widget.label!,
            ),
          ),
        ],
      );
    }
    return _buildCheckbox(context);
  }
}

/// Switch
/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=1818-2669&mode=dev
/// Простой переключатель
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.statusString,
    required this.isSwitched,
    required this.onChanged,
    this.leading,
    super.key,
  });

  /// Опциональное название
  final Widget? leading;

  /// Подпись возле переключателя
  final String statusString;

  /// Состояние переключателя
  final bool isSwitched;

  /// Коллбек переключения
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) Expanded(child: leading!),
        Text(
          statusString,
          style: AppTextStyle.regularCaption.style(
            context,
            isSwitched ? AppColors.green : AppColors.red,
          ),
        ),
        const SizedBox(width: 8),
        _AppSwitch(
          value: isSwitched,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Switch
/// Передизайненный [CupertinoSwitch]
class _AppSwitch extends StatelessWidget {
  const _AppSwitch({required this.value, required this.onChanged});

  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.green,
      trackColor: AppColors.red,
      thumbColor: AppColors.blackContainer,
    );
  }
}

/// Поле выбора фотографии
/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-8369&mode=dev
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    required this.onTap,
    this.onLongPress,
    this.file,
    this.fileUri,
    super.key,
  });

  /// Коллбек нажатия
  final VoidCallback? onTap;

  /// Коллбек длинного нажатия
  final VoidCallback? onLongPress;

  /// Текущий файл (выбран только что)
  final File? file;

  /// Текущий файл в интернете (когда-то выбран и загружен)
  final Uri? fileUri;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 120,
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.blackContainer,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              if (file?.path.isNotEmpty == true)
                Positioned.fill(
                  child: Image.file(
                    file!,
                    fit: BoxFit.cover,
                    errorBuilder: imageErrorWidget,
                  ),
                )
              else if (fileUri != null)
                Positioned.fill(
                  child: Image.network(
                    fileUri?.scheme.contains('http') == true
                        ? fileUri.toString()
                        : fileUri!.path,
                    fit: BoxFit.cover,
                    errorBuilder: imageErrorWidget,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: DottedBorder(
                  color: file?.path.isNotEmpty == true
                      ? AppColors.white
                      : AppColors.violetLight,
                  radius: const Radius.circular(10),
                  strokeCap: StrokeCap.round,
                  borderType: BorderType.RRect,
                  dashPattern: const [2, 2],
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: AppIcons.add1.widget(
                      width: 20,
                      height: 20,
                      color: file?.path.isNotEmpty == true
                          ? AppColors.white
                          : AppColors.grayText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
