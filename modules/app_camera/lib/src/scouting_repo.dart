import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';

class ScoutingRepository extends AppRepository {
  factory ScoutingRepository() {
    return _singleton;
  }

  ScoutingRepository._internal();

  static final ScoutingRepository _singleton = ScoutingRepository._internal();

  static void _updateUploadingProgress(ScoutingFileUpload file) {
    final list = _uploadingStream.value
      ..removeWhere((f) => f.fileName == file.fileName)
      ..add(file);
    _uploadingStream.add(list);
  }

  static final _uploadingStream =
      BehaviorSubject<List<ScoutingFileUpload>>.seeded([]);

  BehaviorSubject<List<ScoutingFileUpload>> get uploadingStream =>
      _uploadingStream;

  /// Отправка фото из разведки на сервер
  /// возвращает [Response]
  Future<Response?> reportsStore(
    ScoutingFile file,
  ) async {
    final formData = await file.toFormData();
    try {
      /// добавит или обновит файл
      /// с списке файлов загрузки
      /// устанавливая статус "в процессе звгрузки"
      _updateUploadingProgress(ScoutingFileUpload(
        fileName: file.name,
        total: 100,
        sent: 3,
        status: ScoutingFileUploadStatus.inProgress,
      ));

      /// отправляет на сервер
      final response = await FileUploadRequest(
        '/reports/store',
        formData: formData,
        secure: true,
        sentCallback: (sent, total) {
          /// обновляет объем данных отправленных на сервер
          _updateUploadingProgress(ScoutingFileUpload(
            fileName: file.name,
            total: total,
            sent: sent,
            status: ScoutingFileUploadStatus.inProgress,
          ));
        },
      ).upload(dio);

      /// при успешной отправке устанавливает статус "Готово"
      /// с процентом загрузки 100
      _updateUploadingProgress(ScoutingFileUpload(
        fileName: file.name,
        total: 1,
        sent: 1,
        status: ScoutingFileUploadStatus.done,
      ));

      return response;
    } catch (e) {
      /// обработка любой ошибки загрузки
      /// ставит статус загрузки в ошибку
      final list = _uploadingStream.value
        ..removeWhere((f) => f.fileName == file.name)
        ..add(ScoutingFileUpload(
          fileName: file.name,
          total: 1,
          sent: 1,
          status: ScoutingFileUploadStatus.error,
        ));
      _uploadingStream.add(list);

      /// дальнейшая обработка ошибки происходит на экране загрузки
      rethrow;
    }
  }
}
