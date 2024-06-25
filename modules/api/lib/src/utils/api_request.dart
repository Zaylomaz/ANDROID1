/// Описание стандартных [HTTP] запросов
/// для использования с [Dio] клиентом

import 'dart:typed_data';

import 'package:api/src/interceptors.dart';
import 'package:dio/dio.dart';
import 'package:json_reader/json_reader.dart';

const multipartFormData = 'multipart/form-data';
const applicationJsonHeader = 'application/json';

/// Константы HTTP методов
mixin HttpMethod {
  static const get = 'GET';
  static const post = 'POST';
  static const put = 'PUT';
  static const patch = 'PATCH';
  static const delete = 'DELETE';
}

/// абстрактный запрос
abstract class AppRequest {
  const AppRequest(
    this.path, {
    this.secure = false,
    this.unauthorizedRedirect = true,
    this.headers,
  });

  /// Путь в АПИ
  final String path;

  /// Использовать авторизацию?
  final bool secure;

  /// Редирект на логин при ошибке [UnauthorizedException]
  final bool unauthorizedRedirect;

  /// HttpHeaders запроса
  final Map<String, dynamic>? headers;

  /// Отдаст объект типа [JsonReader] из data ответа
  Future<JsonReader> callRequest(Dio dio) async {
    final result = await getResponse(dio);
    return JsonReader(result.data);
  }

  /// Получит ответ от сервера
  Future<Response> getResponse(Dio dio);
}

/// GET запрос
class GetRequest extends AppRequest {
  const GetRequest(
    super.path, {
    super.secure,
    super.unauthorizedRedirect,
    super.headers,
    this.query,
  });

  final Map<String, dynamic>? query;

  @override
  Future<Response> getResponse(Dio dio) => dio.get(
        path,
        queryParameters: query,
        options: Options(
          headers: headers,
          method: HttpMethod.get,
          contentType: applicationJsonHeader,
          extra: {
            AuthInterceptor.flag: secure,
            AuthInterceptor.unauthorizedRedirect: unauthorizedRedirect,
          },
        ),
      );

  Future<Uint8List> getRawBody(Dio dio) async {
    final responseData = await dio.get(
      path,
      queryParameters: query,
      options: Options(
        headers: headers,
        method: HttpMethod.post,
        contentType: applicationJsonHeader,
        responseType: ResponseType.bytes,
        extra: {
          AuthInterceptor.flag: secure,
        },
      ),
    );
    final bytes = responseData.data;
    return bytes;
  }
}

/// POST запрос
class PostRequest extends AppRequest {
  const PostRequest(
    super.path, {
    super.secure,
    super.unauthorizedRedirect,
    super.headers,
    this.query,
    this.body,
  });

  final Map<String, dynamic>? query;
  final Map<String, dynamic>? body;

  @override
  Future<Response> getResponse(Dio dio) => dio.post(
        path,
        queryParameters: query,
        data: body,
        options: Options(
          headers: headers,
          method: HttpMethod.post,
          contentType: applicationJsonHeader,
          extra: {
            AuthInterceptor.flag: secure,
            AuthInterceptor.unauthorizedRedirect: unauthorizedRedirect,
          },
        ),
      );

  Future<Uint8List> getRawBody(Dio dio) async {
    final responseData = await dio.post(
      path,
      queryParameters: query,
      data: body,
      options: Options(
        headers: headers,
        method: HttpMethod.post,
        contentType: applicationJsonHeader,
        responseType: ResponseType.bytes,
        extra: {
          AuthInterceptor.flag: secure,
        },
      ),
    );
    final bytes = responseData.data;
    return bytes;
  }
}

/// PUT запрос
class PutRequest extends AppRequest {
  const PutRequest(
    super.path, {
    super.secure,
    super.unauthorizedRedirect,
    super.headers,
    this.query,
    this.body,
  });

  final Map<String, dynamic>? query;
  final Map<String, dynamic>? body;

  @override
  Future<Response> getResponse(Dio dio) => dio.put(
        path,
        queryParameters: query,
        data: body,
        options: Options(
          headers: headers,
          method: HttpMethod.put,
          contentType: applicationJsonHeader,
          extra: {
            AuthInterceptor.flag: secure,
            AuthInterceptor.unauthorizedRedirect: unauthorizedRedirect,
          },
        ),
      );
}

/// DELETE запрос
class DeleteRequest extends AppRequest {
  const DeleteRequest(
    super.path, {
    super.secure,
    super.unauthorizedRedirect,
    super.headers,
    this.query,
    this.body,
  });

  final Map<String, dynamic>? query;
  final Map<String, dynamic>? body;

  @override
  Future<Response> getResponse(Dio dio) => dio.delete(
        path,
        queryParameters: query,
        data: body,
        options: Options(
          headers: headers,
          method: HttpMethod.delete,
          contentType: applicationJsonHeader,
          extra: {
            AuthInterceptor.flag: secure,
            AuthInterceptor.unauthorizedRedirect: unauthorizedRedirect,
          },
        ),
      );
}

/// PATCH запрос
class PatchRequest extends AppRequest {
  const PatchRequest(
    super.path, {
    super.secure,
    super.unauthorizedRedirect,
    super.headers,
    this.query,
    this.body,
  });

  final Map<String, dynamic>? query;
  final Map<String, dynamic>? body;

  @override
  Future<Response> getResponse(Dio dio) => dio.patch(
        path,
        queryParameters: query,
        data: body,
        options: Options(
          headers: headers,
          method: HttpMethod.patch,
          contentType: applicationJsonHeader,
          extra: {
            AuthInterceptor.flag: secure,
            AuthInterceptor.unauthorizedRedirect: unauthorizedRedirect,
          },
        ),
      );
}

/// Загрузка файла через [FormData]
class FileUploadRequest {
  const FileUploadRequest(
    this.path, {
    required this.formData,
    this.secure = false,
    this.sentCallback,
    this.sendTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  final String path;
  final FormData formData;
  final bool secure;
  final ProgressCallback? sentCallback;
  final Duration sendTimeout;
  final Duration receiveTimeout;

  Future<Response> upload(Dio dio) => dio.post(
        path,
        data: formData,
        options: Options(
          method: HttpMethod.post,
          contentType: applicationJsonHeader,
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
          extra: {
            AuthInterceptor.flag: secure,
          },
        ),
        onSendProgress: sentCallback,
      );
}
