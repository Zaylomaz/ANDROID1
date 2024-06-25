import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

part 'calls_filter.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.args) {
    filters = args.filter;
    tabNameCtrl.text = args.tabName ?? '';
    contactNameCtrl.text = args.filter.name;
    orderNumberCtrl.text = args.filter.orderNumber;
  }

  final formKey = GlobalKey<FormState>();
  final CallFilterScreenArgs args;
  final contactNameCtrl = TextEditingController();
  final tabNameCtrl = TextEditingController();
  final orderNumberCtrl = TextEditingController();

  @observable
  AppPhoneCallFilter _filters = AppPhoneCallFilter.empty;

  @computed
  AppPhoneCallFilter get filters => _filters;

  @protected
  set filters(AppPhoneCallFilter value) => _filters = value;

  @action
  void dispose() {
    contactNameCtrl.dispose();
    tabNameCtrl.dispose();
    orderNumberCtrl.dispose();
  }
}

class CallFilterScreenArgs {
  const CallFilterScreenArgs({
    required this.filter,
    this.tabName,
  });

  final String? tabName;
  final AppPhoneCallFilter filter;
}

class CallFilterScreen extends StatelessWidget {
  const CallFilterScreen({required this.args, super.key});

  final CallFilterScreenArgs args;

  static const String routeName = '/calls_filter';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(args),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Фильтр звонков'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Observer(
            builder: (context) {
              return Form(
                key: _State.of(context).formKey,
                child: Column(
                  children: [
                    if (_State.of(context).args.tabName?.isNotEmpty ==
                        true) ...[
                      AppTextInputField(
                        controller: _State.of(context).tabNameCtrl,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        onEditingComplete: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: const InputDecoration(
                          labelText: 'Название вкладки',
                        ),
                        onChanged: (value) {
                          _State.of(context).filters =
                              _State.of(context).filters.copyWith(name: value);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    AppTextInputField(
                      controller: _State.of(context).contactNameCtrl,
                      keyboardType: TextInputType.text,
                      onEditingComplete: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration:
                          const InputDecoration(labelText: 'Имя контакта'),
                    ),
                    const SizedBox(height: 16),
                    AppTextInputField(
                      controller: _State.of(context).orderNumberCtrl,
                      keyboardType: TextInputType.number,
                      onEditingComplete: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration:
                          const InputDecoration(labelText: 'Номер заказа'),
                    ),
                    const SizedBox(height: 16),
                    AppDropdownField<AppPhoneCallType?>(
                      label: 'Статус',
                      value: _State.of(context).filters.type,
                      items: AppPhoneCallType.values.map(
                        (e) => MapEntry(
                          e,
                          e.title,
                        ),
                      ),
                      onChange: (value) {
                        _State.of(context).filters =
                            _State.of(context).filters.copyWith(type: value);
                      },
                    ),
                    const Row(
                      children: [
                        Expanded(child: _Refresh()),
                        SizedBox(width: 16),
                        Expanded(child: _Submit()),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Refresh extends StatelessWidget {
  const _Refresh();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
      child: PrimaryButton.red(
        onPressed: () => Navigator.of(context).maybePop(
          AppPhoneCallFilter.empty.copyWith(
            name: _State.of(context).filters.tabName,
          ),
        ),
        text: 'Сбросить',
      ),
    );
  }
}

class _Submit extends StatelessWidget {
  const _Submit();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
      child: PrimaryButton.green(
        onPressed: () => Navigator.of(context).maybePop(
          _State.of(context).filters.copyWith(
                tabName: _State.of(context).tabNameCtrl.text,
              ),
        ),
        text: 'Применить',
      ),
    );
  }
}
