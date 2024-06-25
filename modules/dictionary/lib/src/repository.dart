import 'dart:async';

import 'package:api/api.dart';
import 'package:dictionary/dictionary.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';

final _appDictionaryKeys = JsonPreference<Set<String>>(
  key: const PreferenceKey(
    module: 'repository',
    component: 'dictionary',
    name: 'keys',
  ),
  defaultValue: AppDictionary.defaultKeys,
  encoder: (data) => data.toList(),
  decoder: (json) => (json as List<String>).toSet(),
);

class AppDictionary extends AppRepository with DictMapper {
  factory AppDictionary() => _singleton;

  AppDictionary._internal();

  static final AppDictionary _singleton = AppDictionary._internal();

  static const defaultKeys = {
    'cities',
    'companies',
    'themes',
    'role',
    'master_tag',
    'statuses',
    'applicant_statuses',
    'master',
    'sc_master',
    'technique',
    'call_statuses',
    'job_vacancies',
    'users',
    'appointments',
  };

  static const registrationKeys = {
    'public_cities',
    'public_companies',
    'public_themes',
  };

  Set<String> get keys =>
      _appDictionaryKeys.value.isEmpty ? defaultKeys : _appDictionaryKeys.value;

  static const _hiveBoxId = 'appDictionaryBox';
  static bool _initialized = false;

  static late Box<DictChapter> box;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      box = await Hive.openBox(_hiveBoxId);
      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Получит актуальные ключи
  Future<void> updateKeys() =>
      _apiGetKeys().then((value) => _appDictionaryKeys.value = value.toSet());

  CachedDataLazy<DictChapter> getByKey(String key) {
    assert(
      keys.contains(key) || registrationKeys.contains(key),
      'Key is not found',
    );
    return CachedDataLazy(
      cachedData: _getFromCache(key),
      freshDataLazy: () => _loadKey(key),
    );
  }

  /// Получит все значения
  /// передает все [keys]
  /// сохраняет в базу
  Future<void> loadData() async {
    assert(_initialized);
    unawaited(updateKeys());
    final data = await _apiGetAll();
    await _updateCache(data);
  }

  /// Получит словарь по ключу
  Future<DictChapter> _loadKey(String key) async {
    assert(_initialized);
    assert(keys.contains(key));
    try {
      /// попробует спросить по ключу
      /// и отдать результат
      return await _apiGetKey(key);
    } catch (_) {
      /// отдаст пустоту
      return {};
    }
  }

  /// сохранит в базу
  Future<void> _updateCache(Map<String, Map<int, String>> data) async {
    assert(_initialized);
    for (final dict in data.entries) {
      await box.put(dict.key, dict.value);
    }

    /// пропустит пустые объекты и сохранит только то где есть данные
  }

  /// отдаст кеш по ключу
  DictChapter _getFromCache(String key) {
    try {
      return box.get(key) ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Запрос на все доступные словари
  Future<Dictionary> _apiGetAll() async {
    final request = await const GetRequest(
      '/v2/app-dictionary',
      secure: true,
    ).callRequest(dio);
    return request.asMap().map(
          (key, value) => MapEntry(
            key,
            DictMapper.jsonMapMapper(
              JsonReader(value),
            ),
          ),
        );
  }

  /// Запрос словаря по ключу
  Future<DictChapter> _apiGetKey(String key) async {
    final request = await GetRequest(
      '/v2/app-dictionary/$key',
      secure: true,
    ).callRequest(dio);
    return DictMapper.jsonMapMapper(request);
  }

  /// Запрос на ключи
  Future<List<String>> _apiGetKeys() async {
    final request = await const GetRequest(
      '/v2/app-dictionary/keys',
      secure: true,
    ).callRequest(dio);
    return request.asListOf<String>();
  }

  /// Получает словарь для регистрации
  /// и сохраняет его в базу
  Future<void> updateRegistrationDictionary() async {
    final publicDict = await _getRegistrationDictionary();
    await _updateCache(publicDict);
  }

  /// Получает словарь для регистрации с сервера
  Future<Dictionary> _getRegistrationDictionary() async {
    final request =
        await const GetRequest('/v2/register/options').callRequest(dio);
    return request.asMap().map(
          (key, value) => MapEntry(
            'public_$key',
            DictMapper.jsonMapMapper(
              JsonReader(value),
            ),
          ),
        );
  }
}

mixin GetDict {
  static AppDictionary get _repo => AppDictionary();
  static DictChapter get publicCities => _repo._getFromCache('public_cities');
  static DictChapter get publicCompanies =>
      _repo._getFromCache('public_companies');
  static DictChapter get publicThemes => _repo._getFromCache('public_themes');
  static DictChapter get cities => _repo._getFromCache('cities');
  static DictChapter get companies => _repo._getFromCache('companies');
  static DictChapter get themes => _repo._getFromCache('themes');
  static DictChapter get role => _repo._getFromCache('role');
  static DictChapter get masterTag => _repo._getFromCache('master_tag');
  static DictChapter get statuses => _repo._getFromCache('statuses');
  static DictChapter get applicantStatuses =>
      _repo._getFromCache('applicant_statuses');
  static DictChapter get master => _repo._getFromCache('master');
  static DictChapter get scMaster => _repo._getFromCache('sc_master');
  static DictChapter get technique => _repo._getFromCache('technique');
  static DictChapter get callStatuses => _repo._getFromCache('call_statuses');
  static DictChapter get jobVacancies => _repo._getFromCache('job_vacancies');
  static DictChapter get users => _repo._getFromCache('users');
  static DictChapter get appointments => _repo._getFromCache('appointments');
}
