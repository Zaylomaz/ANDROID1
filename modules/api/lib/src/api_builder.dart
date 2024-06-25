import 'dart:async';

import 'package:alice/alice.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:dio/io.dart';

final _defaultInterceptors = <Interceptor>[
  AuthInterceptor(refreshSession: () async {
    return true;
  }),
  LoggingInterceptor(),
];

class ApiBuilder {
  factory ApiBuilder() {
    return _singleton;
  }

  ApiBuilder._internal();

  static final ApiBuilder _singleton = ApiBuilder._internal();

  late Dio _dio;

  Dio get dio => _dio;

  late Alice _alice;

  late GlobalKey<NavigatorState> _navigatorState;

  void init({Uri? baseUrl}) {
    final options = BaseOptions(
      baseUrl:
          '${baseUrl ?? Environment<AppConfig>.instance().config.apiUrl}/api/',
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      headers: {
        'Accept': 'application/json',
      },
    );
    _dio = Dio(options);
    _dio.interceptors.addAll(_defaultInterceptors);
    (dio.httpClientAdapter as IOHttpClientAdapter).validateCertificate =
        (cert, host, port) => true;
  }

  void initAlice(GlobalKey<NavigatorState> key) {
    _navigatorState = key;
    _alice = Alice(navigatorKey: _navigatorState, darkTheme: true);
    _dio.interceptors.add(
      AliceDioInterceptor(_alice.core!),
    );
  }

  void showInspector() => _alice.showInspector();

  void addInterceptor(Interceptor interceptor) {
    if (_dio.interceptors.contains(interceptor)) {
      _dio.interceptors.remove(interceptor);
    }
    _dio.interceptors.add(interceptor);
  }

  void deleteInterceptor(Type interceptorType) {
    _dio.interceptors.removeWhere(
      (element) => element.runtimeType == interceptorType,
    );
  }

  SpeedTestResult speedTest() {
    final startStamp = DateTime.now();
    final subject =
        BehaviorSubject<_SpeedTestProgress>.seeded(_SpeedTestProgress(0));
    final result = SpeedTestResult(startStamp, subject);
    Dio().get(
      'http://speedtest.ftp.otenet.gr/files/test1Mb.db',
      onReceiveProgress: (count, total) {
        subject.add(_SpeedTestProgress(count / total));
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      ),
    );
    return result;
  }
}

class SpeedTestResult {
  const SpeedTestResult(this.startDate, this.progress);
  final DateTime startDate;
  final BehaviorSubject<_SpeedTestProgress> progress;

  void dispose() {
    progress.close();
  }

  Future<Duration> duration() async {
    final isComplete = await progress.stream.firstWhere((e) => e.progress == 1);
    dispose();
    return Duration(
      milliseconds: isComplete.timestamp.millisecondsSinceEpoch -
          startDate.millisecondsSinceEpoch,
    );
  }
}

class _SpeedTestProgress {
  _SpeedTestProgress(this.progress) : timestamp = DateTime.now();
  final double progress;
  late final DateTime timestamp;
}
