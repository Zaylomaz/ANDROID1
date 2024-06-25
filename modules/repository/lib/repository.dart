import 'package:api/api.dart';

export 'src/application_repo/application_repo.dart';
export 'src/auth_repo/auth_repository.dart';
export 'src/cashbox/cashbox_repository.dart';
export 'src/chat/chat_repository.dart';
export 'src/kanban/kanban_repository.dart';
export 'src/master/master_repository.dart';
export 'src/old_repo/deprecated_repository.dart';
export 'src/orders/orders_repository.dart';
export 'src/phone_calls/phone_calls.dart';
export 'src/users/users_repository.dart';

class SpeedTest extends AppRepository {
  factory SpeedTest() {
    return _singleton;
  }

  SpeedTest._internal();

  static final SpeedTest _singleton = SpeedTest._internal();

  SpeedTestResult runTest() {
    return apiBuilder.speedTest();
  }
}
