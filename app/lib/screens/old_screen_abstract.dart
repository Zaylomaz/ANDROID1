import 'package:core/core.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:uikit/uikit.dart';

abstract class OldScreenAbstract extends StatelessWidget {
  const OldScreenAbstract({super.key});

  abstract final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(),
      drawer: const AppBarDrawer(),
      floatingActionButton: floatingActionButton(context),
    );
  }

  AppToolbar buildAppBar(BuildContext context) => AppToolbar(
        title: Text(title),
      );

  Widget buildBody();
  FloatingActionButton? floatingActionButton(BuildContext context) => null;
}
