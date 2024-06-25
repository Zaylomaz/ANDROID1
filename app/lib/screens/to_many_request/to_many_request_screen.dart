import 'package:core/core.dart';
import 'package:rempc/components/coustom_bottom_nav_bar.dart';
import 'package:rempc/enums.dart';
import 'package:uikit/uikit.dart';

import 'components/body.dart';

class ToManyRequestScreen extends StatelessWidget {
  const ToManyRequestScreen({super.key});

  static const String routeName = '/to-many-request';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppToolbar(
        title: Text('Ошибка сервера'),
      ),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedMenu: MenuState.home,
        currentRoute: routeName,
      ),
    );
  }
}
