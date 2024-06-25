import 'package:core/core.dart';
import 'package:rempc/main.dart';

/// Запускает приложение под PROD окружением
/// с использованием только допустимых значений
/// в Mainfest для PlayMarket
void main() => runMain(
      Flavor.prod,
      isPlayMarket: true,
    );
