import 'package:core/core.dart';

/// Текущее окружение
class Environment<T> implements Listenable {
  Environment._([Flavor? flavor, T? config, bool isPlayMarket = false])
      : _currentBuildType = flavor ?? Flavor.dev,
        _isPlayMarket = isPlayMarket,
        _config = ValueNotifier(config!);

  factory Environment.instance() => _instance as Environment<T>;

  final Flavor _currentBuildType;
  ValueNotifier<T> _config;
  bool _isPlayMarket;
  bool get isPlayMarket => _isPlayMarket;

  T get config => _config.value;

  set config(T c) => _config.value = c;

  static Environment? _instance;

  static void init<T>({
    required Flavor flavor,
    required bool isPlayMarket,
    required T config,
  }) {
    _instance ??= Environment<T>._(flavor, config, isPlayMarket);
  }

  bool get isDebug => _currentBuildType != Flavor.prod;
  bool get isProd => _currentBuildType == Flavor.prod;

  Flavor get buildType => _currentBuildType;

  @override
  void addListener(VoidCallback listener) {
    _config.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _config.removeListener(listener);
  }
}
