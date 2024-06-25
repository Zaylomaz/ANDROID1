import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

part 'ai_chat_screen.g.dart';

class _State extends _StateStore with _$_State {
  _State() : super();

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore();

  @action
  void dispose() {}
}

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  static const String routeName = '/ai_chat_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppToolbar(
        title: Text('RemPC AI'),
      ),
      body: _ChatView(),
      bottomNavigationBar: _InputView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _InputView extends StatelessWidget {
  const _InputView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppMaterialBox.withPadding(
      padding: EdgeInsets.all(8),
      child: const AppTextInputField(
        decoration: InputDecoration(labelText: 'Test'),
      ),
    );
  }
}
