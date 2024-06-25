import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'preference.dart';

typedef ValueMapper<T> = String Function(T value);

String _defaultMapper(dynamic value) {
  final str = value.toString();
  final dotIndex = str.indexOf('.');
  if (dotIndex > 0) {
    return str.substring(dotIndex);
  }
  throw ArgumentError.value(value, 'value', 'must be an enum');
}

class EnumPreference<T extends Object?> extends Preference<T> {
  EnumPreference({
    required PreferenceKey key,
    required T defaultValue,
    required List<T> values,
    this.mapper = _defaultMapper,
    PreferenceKey? oldKey,
  })  : _values = values,
        super(key, defaultValue, oldKey: oldKey);

  final List<T> _values;
  final ValueMapper<T> mapper;

  @override
  @protected
  T? convertFromString(String value) =>
      _values.firstWhereOrNull((enumValue) => mapper(enumValue) == value);

  @override
  @protected
  String? convertToString(T? value) {
    if (value == null) {
      return mapper(defaultValue);
    }

    return mapper(value);
  }
}
