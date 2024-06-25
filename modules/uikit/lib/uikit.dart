// ignore_for_file: comment_references

library uikit;

import 'dart:ui';

export 'package:syncfusion_flutter_sliders/sliders.dart';

export 'src/buttons.dart';
export 'src/form_elements.dart';
export 'src/icons.dart';
export 'src/shaker.dart';
export 'src/theme.dart';
export 'src/widgets.dart';

/// Создание [ColorFilter] из [Color]
/// Необходимо для указания цвета [SvgPicture]
extension ColorExt on Color {
  ColorFilter toColorFilter({BlendMode blendMode = BlendMode.srcIn}) =>
      ColorFilter.mode(this, blendMode);
}
