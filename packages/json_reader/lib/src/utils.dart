import 'dart:ui';

Color getColorFromHex(String hexColor) {
  var color = hexColor.toUpperCase().replaceAll('#', '').replaceAll('0X', '');
  if (color.length == 6) {
    color = 'FF$color';
  }
  return Color(int.parse(color, radix: 16));
}
