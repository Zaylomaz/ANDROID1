import 'dart:io';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:uikit/uikit.dart';

/// Модель для файла фотоотчета
/// суть такого файла в том что при не удачной загрузке он сохраняется локально
/// с возможностью отправить позже
/// помогает при плохом интернете
class ScoutingFile {
  const ScoutingFile._({
    required this.apiTitle,
    required this.path,
    required this.createDate,
    this.latitude = 0,
    this.longitude = 0,
    this.isFake = false,
  });

  /// создание файла при новом отчете
  factory ScoutingFile.fromPath(
          String apiTitle, String path, String latitude, String longitude,
          {bool isFake = false}) =>
      ScoutingFile._(
        apiTitle: apiTitle,
        path: path,
        createDate: DateTime.now(),
        latitude: double.tryParse(latitude) ?? 0,
        longitude: double.tryParse(longitude) ?? 0,
        isFake: isFake,
      );

  /// Для парсинга из памяти
  factory ScoutingFile.fromJson(JsonReader json) => ScoutingFile._(
        apiTitle: json['apiTitle'].asString(),
        path: json['path'].asString(),
        createDate: json['createDate'].asDateTime(),
        latitude: json['latitude'].asDouble(),
        longitude: json['longitude'].asDouble(),
        isFake: json['isFake'].asBool(),
      );

  /// для записи в память
  Map<String, dynamic> toJson() => {
        'apiTitle': apiTitle,
        'path': path,
        'createDate': createDate.millisecondsSinceEpoch,
        'latitude': latitude,
        'longitude': longitude,
        'isFake': isFake,
      };

  /// преобразует в [MultipartFile] для [FormData]
  Future<MultipartFile> asApiFile() => MultipartFile.fromFile(
        path,
        filename: path.split('/').last,
      );

  /// возвращает как [File]
  File get asFile => File(path);

  /// имя файла
  String get name => path.split('/').last;

  /// формирует [FormData] объект для отправки на сервер
  /// добавляет файл в [FormData]
  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'button': apiTitle,
      'lat': latitude,
      'lng': longitude,
      'isFake': isFake ? 1 : 0,
      'createAt': createDate.millisecondsSinceEpoch,
      'token': ApiStorage().accessToken,
    });
    formData.files.add(
      MapEntry(
        'photo',
        await asApiFile(),
      ),
    );
    return formData;
  }

  // enum type для бекенда
  final String apiTitle;
  // путь к файлу
  final String path;
  // дата съемки
  final DateTime createDate;
  // геопозиция при съемке
  final double latitude;
  final double longitude;
  // геопозиция изменена программно
  final bool isFake;
}

enum ScoutingFileUploadStatus {
  pending,
  inProgress,
  error,
  done;

  Widget get icon {
    switch (this) {
      case ScoutingFileUploadStatus.pending:
        return AppIcons.clock.widget(color: color, width: 32);
      case ScoutingFileUploadStatus.inProgress:
        return const SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      case ScoutingFileUploadStatus.error:
        return AppIcons.angry.widget(color: color, width: 32);
      case ScoutingFileUploadStatus.done:
        return AppIcons.checked.widget(color: color, width: 32);
    }
  }

  Color get color {
    switch (this) {
      case ScoutingFileUploadStatus.pending:
        return AppColors.yellow;
      case ScoutingFileUploadStatus.inProgress:
        return AppColors.cyan;
      case ScoutingFileUploadStatus.error:
        return AppColors.red;
      case ScoutingFileUploadStatus.done:
        return AppColors.green;
    }
  }
}

class ScoutingFileUpload {
  const ScoutingFileUpload({
    required this.status,
    required this.fileName,
    required this.total,
    required this.sent,
  });

  bool get hasData => fileName.isNotEmpty;

  final ScoutingFileUploadStatus status;
  final String fileName;
  final int total;
  final int sent;
}
