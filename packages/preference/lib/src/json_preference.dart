import 'dart:convert';

import 'package:meta/meta.dart';

import 'preference.dart';

typedef PreferenceJsonEncoder<T> = dynamic Function(T value);
typedef PreferenceJsonDecoder<T> = T Function(dynamic json);

class JsonPreference<T> extends Preference<T> {
  JsonPreference({
    required PreferenceKey key,
    required T defaultValue,
    required PreferenceJsonEncoder<T> encoder,
    required PreferenceJsonDecoder<T> decoder,
    PreferenceKey? oldKey,
  })  : _encoder = encoder,
        _decoder = decoder,
        super(key, defaultValue, oldKey: oldKey);

  final PreferenceJsonEncoder<T> _encoder;
  final PreferenceJsonDecoder<T> _decoder;

  @override
  @protected
  T? convertFromString(String value) {
    if (value.isEmpty) {
      return defaultValue;
    }
    try {
      final jsonMap = jsonDecode(value);
      final result = _decoder(jsonMap);
      return result;
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  @protected
  String? convertToString(T? value) {
    if (value == null) {
      return null;
    }

    final jsonMap = _encoder(value);
    final jsonString = jsonEncode(jsonMap);
    return jsonString;
  }
}
