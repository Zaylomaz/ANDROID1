import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';

import 'utils.dart';

typedef ListItemMapper<T, R> = R Function(T item);

class InvalidJsonValueException implements Exception {
  InvalidJsonValueException(this.value);

  final dynamic value;

  @override
  String toString() {
    return 'InvalidJsonValueException{value: $value}';
  }
}

/// Provides safe access to JSON values.
/// Any null field values are automatically replaced with default ones.
///
/// Examples:
/// Get top field value:
/// ```
/// final json = '''
/// {
///   "topField": "Hello",
///   "object1": {
///      "object2": {
///         "int": 0
///      }
///   }
/// }
/// ''';
/// final value = JsonReader(json)['topField'].asString();
/// ```
///
/// Get nested field value:
/// ```
/// final json = '''
/// {
///   "object1": {
///      "object2": {
///         "int": 0
///      }
///   }
/// }
/// ''';
/// final value = JsonReader(json)['object1']['object2']['int'].asInt()
/// ```
///
/// Get nested list of ints:
/// ```
/// final json = '''
/// {
///   "object1": {
///      "object2": {
///         "int": 0,
///         "list": [0, 1, 2, 3]
///      }
///   }
/// }
/// ''';
/// final value = JsonReader(json)['object1']['object2']['list']
///   .asListOf<int>();
/// ```
class JsonReader {
  factory JsonReader(
    dynamic json, {
    bool permissive = true,
  }) =>
      JsonReader._(json, permissive: permissive);

  factory JsonReader.decode(
    String jsonString, {
    bool permissive = true,
  }) {
    dynamic decodedJson;
    try {
      decodedJson = jsonDecode(jsonString);
    } catch (_) {}
    return JsonReader._(decodedJson, permissive: permissive);
  }

  JsonReader._(
    this.json, {
    bool permissive = true,
    int defaultInt = 0,
    double defaultDouble = 0,
    bool defaultBool = false,
    String defaultString = '',
    Color defaultColor = const Color(0xFF000000),
    bool trimStrings = true,
    DateTime? defaultDateTime,
  })  : _permissive = permissive,
        _defaultInt = defaultInt,
        _defaultDouble = defaultDouble,
        _defaultBool = defaultBool,
        _defaultString = defaultString,
        _defaultColor = defaultColor,
        _trimStrings = trimStrings {
    _defaultDateTime = defaultDateTime ?? DateTime.utc(0);

    final isValidJson = json == null ||
        json is Map ||
        json is List ||
        json is String ||
        json is bool ||
        json is num;

    if (!isValidJson) {
      throw InvalidJsonValueException(json);
    }
  }

  final dynamic json;

  final bool _permissive;
  final int _defaultInt;
  final double _defaultDouble;
  final bool _defaultBool;
  final String _defaultString;
  final Color _defaultColor;
  final bool _trimStrings;
  DateTime? _defaultDateTime;

  int asInt({
    bool? permissive,
    int? defaultValue,
  }) =>
      _getInt(
        json,
        permissive: permissive ?? _permissive,
        defaultValue: defaultValue ?? _defaultInt,
      )!;

  int? asIntOrNull({bool? permissive}) => _getInt(
        json,
        permissive: permissive ?? _permissive,
        defaultValue: null,
      );

  double asDouble({
    bool? permissive,
    double? defaultValue,
  }) =>
      _getDouble(
        json,
        permissive: permissive ?? _permissive,
        defaultValue: defaultValue ?? _defaultDouble,
      );

  String asString({
    bool? permissive,
    bool? trim,
    String? defaultValue,
  }) =>
      _getStr(
        json,
        permissive: permissive ?? _permissive,
        trim: trim ?? _trimStrings,
        defaultValue: defaultValue ?? _defaultString,
      )!;

  String? asStringOrNull({
    bool? permissive,
    bool? trim,
  }) =>
      _getStr(
        json,
        permissive: permissive ?? _permissive,
        trim: trim ?? _trimStrings,
        defaultValue: null,
      );

  bool asBool({
    bool? permissive,
    bool? defaultValue,
  }) =>
      _getBool(
        json,
        permissive: permissive ?? _permissive,
        defaultValue: defaultValue ?? _defaultBool,
      );

  DateTime asDateTime({
    bool? permissive,
    DateTime? defaultValue,
  }) =>
      _getDateTime(
        json,
        permissive: permissive ?? _permissive,
        defaultValue: defaultValue ?? _defaultDateTime,
      );

  Color asColor({
    bool? permissive,
    Color? defaultValue,
  }) =>
      _getColor(
        json,
        permissive: permissive ?? _permissive,
        defaultValue: defaultValue ?? _defaultColor,
      );

  Map<String, dynamic> asObject() => asMap();

  Map<String, V> asMap<V>() {
    final v = json;
    if (v == null && _permissive) {
      return const {};
    }
    if (v is! Map<String, dynamic>) {
      throw ArgumentError.value(json, 'json', 'must be a map');
    }
    final map = v;
    if (map.values.every((v) => v is V)) {
      return map.cast<String, V>();
    }

    throw ArgumentError.value(json, 'json', 'must be a Map<String, $V>');
  }

  List<JsonReader> asList() {
    final v = json;
    if (v == null && _permissive) {
      return const [];
    }
    return _getList(json);
  }

  List<T> asListOf<T>() {
    final v = json;
    if (v == null && _permissive) {
      return const [];
    }
    if (v is List && v.every((item) => item is T)) {
      return v.cast<T>();
    }
    throw ArgumentError.value(json, 'json', 'must be a list of $T');
  }

  List<Map<String, dynamic>> asListOfObjects() =>
      asListOf<Map<String, dynamic>>();

  bool containsKey(Object key) {
    final v = json;
    if (v == null) {
      return false;
    }
    if (v is Map) {
      return v.containsKey(key);
    }
    return false;
  }

  JsonReader operator [](Object key) {
    assert(key is int || key is String);

    if (key is int && json is List) {
      final list = _getList(json);
      JsonReader? listItemReader;
      try {
        listItemReader = list[key];
      } catch (_) {}
      return listItemReader ?? JsonReader(null);
    } else if (key is String && json is Map) {
      final map = _getMap(json);
      final mapItemReader = map[key];
      return mapItemReader ?? JsonReader(null);
    }
    return JsonReader(null);
  }

  @override
  String toString() {
    try {
      return jsonEncode(json);
    } catch (_) {
      return '';
    }
  }
}

int? _getInt(
  dynamic value, {
  bool permissive = true,
  int? defaultValue = 0,
}) {
  final v = value;
  if (v is int) {
    return v;
  } else if (permissive && v is num) {
    return v.toInt();
  } else if (permissive && v is String) {
    return int.tryParse(v) ?? defaultValue;
  } else if (permissive && v == null) {
    return defaultValue;
  } else {
    throw ArgumentError('Illegal type: ${v.runtimeType}');
  }
}

double _getDouble(
  dynamic value, {
  bool permissive = true,
  double defaultValue = 0,
}) {
  final v = value;
  if (v is double) {
    return v;
  } else if (permissive && v is num) {
    return v.toDouble();
  } else if (permissive && v is String) {
    return num.tryParse(v)?.toDouble() ?? defaultValue;
  } else if (permissive && v == null) {
    return defaultValue;
  } else {
    throw ArgumentError('Illegal type: ${v.runtimeType}');
  }
}

String? _getStr(
  dynamic value, {
  bool permissive = true,
  bool trim = true,
  String? defaultValue = '',
}) {
  final v = value ?? defaultValue;
  if (v is String) {
    if (trim) {
      return v.trim();
    } else {
      return v;
    }
  } else if (permissive) {
    return v?.toString();
  } else {
    throw ArgumentError('Illegal type: ${v.runtimeType}');
  }
}

bool _getBool(
  dynamic value, {
  bool permissive = true,
  bool defaultValue = false,
}) {
  final v = value ?? defaultValue;
  if (v is bool) {
    return v;
  } else if (permissive && v is int) {
    return v > 0;
  } else if (permissive && v is String && (v == '0' || v == '1')) {
    return v == '1';
  } else {
    throw ArgumentError('Illegal type: ${v.runtimeType}');
  }
}

Map<String, JsonReader> _getMap(
  dynamic value, {
  Map<String, dynamic> defaultValue = const {},
}) {
  final v = value ?? defaultValue;
  if (v is Map && v.keys.every((k) => k is String?)) {
    return v.map((k, v) => MapEntry(k, JsonReader._(v)));
  } else {
    throw ArgumentError('Illegal type: ${v.runtimeType}');
  }
}

List<JsonReader> _getList(
  dynamic value, {
  List defaultValue = const [],
}) {
  final v = value ?? defaultValue;
  if (v is Iterable) {
    return v.map(JsonReader._).toList();
  } else {
    throw ArgumentError('Illegal type: ${v.runtimeType}');
  }
}

DateTime _getDateTime(
  dynamic value, {
  bool permissive = true,
  bool throwable = false,
  DateTime? defaultValue,
}) {
  defaultValue ??= DateTime.utc(0);

  final v = value ?? defaultValue;
  if (v is DateTime) {
    return v;
  } else if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM').parse(v, true);
      } catch (e) {
        return DateFormat('yyyy-MM-dd').parse(v, true);
      }
    }
  } else if (permissive && v is int) {
    if (v >= 0) {
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
    } else if (!throwable) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    } else {
      throw ArgumentError('Illegal timestamp: $v');
    }
  } else {
    throw ArgumentError('Illegal type: ${v.runtimeType}');
  }
}

Color _getColor(
  dynamic value, {
  bool permissive = true,
  Color defaultValue = const Color(0xFF000000),
}) {
  final v = value;
  if (permissive && v == null) {
    return defaultValue;
  }
  if (v is int) {
    return Color(v);
  } else if (v is String) {
    try {
      return getColorFromHex(v);
    } catch (_) {
      if (permissive) {
        return defaultValue;
      }
    }
  }
  throw ArgumentError('Illegal value: $v');
}
