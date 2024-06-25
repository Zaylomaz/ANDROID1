import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

import 'components/body.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  static const String routeName = '/developer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Developer'),
      ),
      body: Body(AppConnectivityNotifier.maybeOf(context)),
    );
  }
}
