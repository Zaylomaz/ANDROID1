import 'package:meta/meta.dart';

import 'preference.dart';

class DoublePreference extends Preference<double> {
  DoublePreference({
    required PreferenceKey key,
    required double defaultValue,
    PreferenceKey? oldKey,
  }) : super(key, defaultValue, oldKey: oldKey);

  @override
  @protected
  double? convertFromString(String value) => double.tryParse(value);

  @override
  @protected
  String? convertToString(double? value) => value?.toString();
}
