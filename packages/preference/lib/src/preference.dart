import 'dart:async';

import 'package:flutter/foundation.dart' hide Key;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef LogErrorCallback = void Function(String className, String message);

SharedPreferences? _prefs;

class PreferenceKey {
  const PreferenceKey({
    required this.module,
    required this.component,
    required this.name,
  });

  final String module;
  final String component;
  final String name;

  @override
  String toString() => '$module.$component.$name';
}

abstract class Preference<T> with ChangeNotifier implements ValueListenable<T> {
  Preference(
    this.key,
    this.defaultValue, {
    PreferenceKey? oldKey,
  }) : _valueSubject = BehaviorSubject<T>() {
    if (oldKey != null) {
      final oldKeyString = oldKey.toString();
      final value = prefs.getString(oldKeyString);
      if (value != null) {
        prefs.setString(key.toString(), value);
        prefs.remove(oldKeyString);
      }
    }

    if (_initialized) {
      _valueSubject.add(_getValue() ?? defaultValue);
    }
  }

  @visibleForTesting
  static void setMockInitialValues(Map<String, Object> values) =>
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues(values);

  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();

    _initialized = true;
  }

  // static const _passphraseKey = 'bank2keyToEverything';
  // static final _iv = IV.fromLength(16);
  // static late LogErrorCallback _logError;

  // static late Encrypter _encrypter;
  static bool _initialized = false;

  final BehaviorSubject<T> _valueSubject;

  @protected
  SharedPreferences get prefs {
    assert(
      _prefs != null,
      'Preference.init() must be called beforce accessing any preference.',
    );
    return _prefs!;
  }

  @protected
  final PreferenceKey key;
  @protected
  final T defaultValue;

  ValueStream<T> get stream => _valueSubject;

  /// Get value from `shared_preferences`.
  ///
  /// This getter is the most **inefficient**, use [cachedValue] instead.
  @override
  T get value => _getValue();
  set value(T value) => _setValue(value);

  /// Get value from [stream].
  ///
  /// This getter is the most **efficient**.
  T get cachedValue => stream.value;

  @protected
  T? convertFromString(String value);

  @protected
  String? convertToString(T? value);

  Future<bool> clear() async {
    final result = await prefs.remove(key.toString());
    if (result == true) {
      _valueSubject.value = defaultValue;
      notifyListeners();
    }
    return result;
  }

  T _getValue() {
    assert(_initialized, 'Preferences are not initialized');

    final encValue = prefs.getString(key.toString());
    if (encValue?.isNotEmpty != true) {
      return defaultValue;
    }
    final decValue = encValue!;
    // ignore: unnecessary_null_comparison
    if (decValue == null) {
      return defaultValue;
    }
    return convertFromString(decValue) ?? defaultValue;
  }

  Future<bool> _setValue(T value) async {
    assert(_initialized, 'Preferences are not initialized');

    var stringValue = convertToString(value);
    if (stringValue?.isNotEmpty != true) {
      stringValue = convertToString(defaultValue);
    }
    String encValue;
    if (stringValue?.isNotEmpty == true) {
      encValue = stringValue!;
    } else {
      encValue = '';
    }
    final result = await prefs.setString(key.toString(), encValue);
    if (result == true) {
      _valueSubject.value = value;
      notifyListeners();
    }
    return result;
  }

  // String _encrypt(String value) => _encrypter.encrypt(value, iv: _iv).base64;
  //
  // String? _decrypt(String encValue) {
  //   final paddedDataLeft = encValue.length % 4;
  //   final paddedData = StringBuffer();
  //   for (var i = 0; paddedDataLeft > 0 && i < 4 - paddedDataLeft; i++) {
  //     paddedData.write('=');
  //   }
  //
  //   final value = encValue + paddedData.toString();
  //
  //   try {
  //     return _encrypter.decrypt64(
  //       value,
  //       iv: _iv,
  //     );
  //   } catch (e, trace) {
  //     _logError(
  //       'preference.dart',
  //       '$e\n$trace',
  //     );
  //
  //     return null;
  //   }
  // }
}
