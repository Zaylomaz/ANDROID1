part of 'app_config.dart';

/// Текущая конфигурация приложения Прод или Дев
enum Flavor {
  dev,
  prod;

  Uri get apiUrl {
    switch (this) {
      case Flavor.prod:
        return Uri(
          host: 'rempc-crm.com',
          scheme: 'https',
        );
      case Flavor.dev:
        return Uri(
          host: 'dev.rempc-crm.com',
          scheme: 'https',
        );
    }
  }

  Uri get proxyUrl {
    switch (this) {
      case Flavor.prod:
        return Uri(
          host: 'rempc-crm.org.ua',
          scheme: 'https',
        );
      case Flavor.dev:
        return Uri(
          host: 'dev.rempc-crm.org.ua',
          scheme: 'https',
        );
    }
  }
}
