import 'package:preference/preference.dart';

const _isLoggedInKey = 'IS_LOGGED_IN';
final _isLoggedInPref = BoolPreference(
  key: const PreferenceKey(
    module: 'api',
    component: 'storage',
    name: _isLoggedInKey,
  ),
  defaultValue: false,
  oldKey: const PreferenceKey(
    module: '',
    component: '',
    name: 'IS_LOGGED_IN',
  ),
);

const _accessTokenKey = 'ACCESS_TOKEN';
final _accessTokenPref = StringPreference(
  key: const PreferenceKey(
    module: 'api',
    component: 'storage',
    name: _accessTokenKey,
  ),
  defaultValue: '',
  oldKey: const PreferenceKey(
    module: '',
    component: '',
    name: 'access_token',
  ),
);

const _lastContactsDateKey = 'LAST_CONTACTS_DATE';
final _lastContactsDatePref = StringPreference(
  key: const PreferenceKey(
    module: 'api',
    component: 'storage',
    name: _lastContactsDateKey,
  ),
  defaultValue: '',
  oldKey: const PreferenceKey(
    module: '',
    component: '',
    name: 'last_contacts_date',
  ),
);

const _deviceIdKey = 'DEVICE_ID';
final _deviceIdPref = StringPreference(
  key: const PreferenceKey(
    module: 'api',
    component: 'storage',
    name: _deviceIdKey,
  ),
  defaultValue: '',
  oldKey: const PreferenceKey(
    module: '',
    component: '',
    name: 'device_id',
  ),
);

class ApiStorage {
  factory ApiStorage() {
    return _singleton;
  }

  ApiStorage._internal();

  static final ApiStorage _singleton = ApiStorage._internal();

  bool get isLoggedIn => _isLoggedInPref.value;
  set isLoggedIn(bool value) => _isLoggedInPref.value = value;

  Stream<String?> get accessTokenStream => _accessTokenPref.stream;
  String get accessToken => _accessTokenPref.value;
  set accessToken(String value) => _accessTokenPref.value = value;

  DateTime? get lastContactsDate {
    final date = _lastContactsDatePref.value;
    if (date.isEmpty) {
      lastContactsDate = DateTime.now().subtract(const Duration(days: 2));
    }
    return DateTime.tryParse(_lastContactsDatePref.value);
  }

  set lastContactsDate(DateTime? value) {
    if (value != null) {
      _lastContactsDatePref.value = value.toIso8601String();
    }
  }

  void lastContactsDateClear() => _lastContactsDatePref.clear();

  String get deviceId => _deviceIdPref.value;
  set deviceId(String value) => _deviceIdPref.value = value;

  void clear() {
    _isLoggedInPref.clear();
    _accessTokenPref.clear();
    _lastContactsDatePref.clear();
    _deviceIdPref.clear();
  }
}
