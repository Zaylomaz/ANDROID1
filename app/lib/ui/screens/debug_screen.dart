import 'package:api/api.dart';
import 'package:core/core.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  static const String routeName = '/debug_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text('Debug screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => ApiBuilder().showInspector(),
          child: const Text('Show http data'),
        ),
      ),
    );
  }
}
