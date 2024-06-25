import 'dart:async';

import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';
import 'package:uikit/uikit.dart';

/// хранит файлы разведки не отправленные на сервер
/// работает с файлами [ScoutingStorage]
final _scoutingFiles = JsonListPreference<ScoutingFile>(
  key: const PreferenceKey(
    module: 'app_camera',
    component: 'files',
    name: 'scouting',
  ),
  defaultValue: [],
  itemDecoder: (value) => ScoutingFile.fromJson(JsonReader(value)),
  itemEncoder: (value) => value.toJson(),
);

class ScoutingStorage {
  factory ScoutingStorage() {
    return _singleton;
  }

  /// инициализация синглтона
  ScoutingStorage._internal() {
    if (_scoutingFiles.value.isNotEmpty) {
      for (final file in _scoutingFiles.value) {
        // проверяет физическое присутствие файла в памяти устройстве
        // если файл был удален мы его удалим из очереди загрузки
        if (!file.asFile.existsSync()) {
          removeFile(file);
        }
      }
    }
  }

  static final ScoutingStorage _singleton = ScoutingStorage._internal();

  /// отдает список файлов в очереди загрузки
  List<ScoutingFile> get getList =>
      _scoutingFiles.value.where((f) => f.asFile.existsSync()).toList();

  /// стрим для обновления списка файлов на UI
  Stream<List<ScoutingFile>> get files => _scoutingFiles.stream;

  /// добавит файл в очередь загрузки
  void addFile(ScoutingFile file) {
    final list = _scoutingFiles.value..add(file);
    _scoutingFiles.value = list;
  }

  /// удалит из очереди загрузки
  /// и если он присутствует на устройстве
  /// удалит его с устройства
  Future<void> removeFile(ScoutingFile file) async {
    try {
      final list = _scoutingFiles.value..remove(file);
      _scoutingFiles.value = list;
      if (file.asFile.existsSync()) {
        await file.asFile.delete();
      }
    } catch (_) {}
  }

  /// пробует загрузить на сервер все файлы разведки
  /// которые доступны на устройстве
  ///
  /// параметр [force] можно передать в метод
  /// с целью автоматической загрузки файлов, если такие есть
  /// в данном сценарии переменная [upload] будет назначена через показ
  /// модалки где пользователь может отложить загрузку
  /// TODO проверить дизайн модалки
  Future<void> uploadAll(BuildContext context, {bool force = false}) async {
    /// загружаем
    bool? upload = true;
    if (force == true) {
      /// можем отложить загрузку
      upload = await showDialog<bool>(
              context: context,
              builder: (context) {
                return Column(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: AppColors.blackContainer,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Загрузка файлов',
                                    style: TextStyle(
                                      color: AppColors.blackContainer,
                                      fontSize: 16,
                                      height: 21 / 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Найдены ранее не загруженные файлы разведки',
                                style: TextStyle(
                                  color: AppColors.blackContainer,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Загрузить'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Позже'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                );
              }) ??
          false;
    }

    /// если метод вызвали нарямую с экрана разведки
    /// или с использованием [force] и подтверждением в модалке
    if (upload == true || (force == true && upload == true)) {
      /// если нечего загружать на данный момент
      if (getList.isEmpty) return;
      for (final file in getList) {
        /// ещё раз проверим наличие на устройстве
        if (file.asFile.existsSync()) {
          try {
            /// загружаем файл
            await this.upload(context, file);
          } catch (e) {
            /// при ошибке загрузки спросим грузить ли остальные
            final isContinue = await showDialog<bool?>(
                context: context,
                builder: (context) {
                  return Column(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Material(
                          color: AppColors.blackContainer,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    AppIcons.attention.iconColored(
                                      color: AppSplitColor.red(),
                                      iconSize: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ошибка',
                                      style: AppTextStyle.regularSubHeadline
                                          .style(
                                              context, AppColors.violetLight),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '''Похоже что у Вас проблемы с интернет-соединением. Связь отсутствует или скорость передачи данных безбожно мала.''',
                                  style: AppTextStyle.regularCaption
                                      .style(context, AppColors.white),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: PrimaryButton.cyan(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        text: 'Повторить загрузку',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PrimaryButton.violet(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      text: 'Позже',
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  );
                });
            if (isContinue == true) {
              continue;
            } else {
              rethrow;
            }
          }
        } else {
          /// если файл пропал - удалим его из очереди
          await removeFile(file);
        }
      }
    }
  }

  /// пробует загрузить файл на сервер
  ///
  /// при успешной загрузке удалит файл из очереди
  ///
  /// при ошибке покажет ошибку на ui
  /// и прокинет её дальше
  Future<void> upload(BuildContext context, ScoutingFile file) async {
    try {
      /// грузим
      final response = await ScoutingRepository().reportsStore(file);

      /// загрузили
      if (response?.statusCode == 200 && getList.hasFile(file)) {
        /// удалили
        await removeFile(file);
      }
    } catch (e) {
      /// поругались на ошибку
      if (e is ApiException) {
        await showMessage(
          context,
          message: e.message,
          type: AppMessageType.error,
        );
      }

      /// отправили ошибку дальше в стек
      rethrow;
    }
  }
}

extension ContainsExt on List<ScoutingFile> {
  bool hasFile(ScoutingFile file) =>
      where((e) => e.path == file.path).isNotEmpty;
}

extension UploadingExt on List<ScoutingFile> {
  List<ScoutingFileUpload> get toUpload => map(
        (e) => ScoutingFileUpload(
          status: ScoutingFileUploadStatus.pending,
          fileName: e.name,
          sent: 0,
          total: 1,
        ),
      ).toList();
}
