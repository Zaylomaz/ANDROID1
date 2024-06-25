part 'flavor.dart';

/// Конфиг приложения
/// Принимает текущий [Flavor] билда
/// устанавливает [apiUrl] для [ApiBuilder]
class AppConfig {
  const AppConfig._({
    required this.apiUrl,
    required this.proxyUrl,
    required this.flavor,
  });

  factory AppConfig.fromFlavor(Flavor flavor) => AppConfig._(
        flavor: flavor,
        apiUrl: flavor.apiUrl,
        proxyUrl: flavor.proxyUrl,
      );

  AppConfig copyWith({
    Uri? apiUrl,
    Uri? proxyUrl,
  }) =>
      AppConfig._(
        apiUrl: apiUrl ?? this.apiUrl,
        proxyUrl: proxyUrl ?? this.proxyUrl,
        flavor: flavor,
      );

  /// дает доступ к просмотру HTTP логов
  bool get showApiRequestsInConsole => flavor == Flavor.dev;

  final Flavor flavor;
  final Uri apiUrl;
  final Uri proxyUrl;
}
