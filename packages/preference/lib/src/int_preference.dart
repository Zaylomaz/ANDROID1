import 'package:meta/meta.dart';

import 'preference.dart';

class IntPreference extends Preference<int> {
  IntPreference({
    required PreferenceKey key,
    required int defaultValue,
    PreferenceKey? oldKey,
  }) : super(key, defaultValue, oldKey: oldKey);

  @override
  @protected
  int? convertFromString(String value) => int.tryParse(value);

  @override
  @protected
  String? convertToString(int? value) => value?.toString();
}
