import 'package:meta/meta.dart';

import 'preference.dart';

class StringPreference extends Preference<String> {
  StringPreference({
    required PreferenceKey key,
    required String defaultValue,
    PreferenceKey? oldKey,
  }) : super(key, defaultValue, oldKey: oldKey);

  @override
  @protected
  String? convertFromString(String value) => value;

  @override
  @protected
  String? convertToString(String? value) => value;
}
