import 'package:meta/meta.dart';

import 'preference.dart';

class BoolPreference extends Preference<bool> {
  BoolPreference({
    required PreferenceKey key,
    required bool defaultValue,
    PreferenceKey? oldKey,
  }) : super(key, defaultValue, oldKey: oldKey);

  @override
  @protected
  bool? convertFromString(String value) {
    if (value == '1') {
      return true;
    } else if (value == '0') {
      return false;
    } else {
      return null;
    }
  }

  @override
  @protected
  String? convertToString(bool? value) {
    if (value == true) {
      return '1';
    } else if (value == false) {
      return '0';
    } else {
      return null;
    }
  }
}
