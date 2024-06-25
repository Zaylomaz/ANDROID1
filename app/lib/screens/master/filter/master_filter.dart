import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

part 'master_filter.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.args) {
    dict = args.dict;
    filter = args.initFilter;
    if (args.name?.isNotEmpty == true) {
      filterNameCtrl.text = args.name!;
    }
    masterNameCtrl.text = filter.masterName;
    masterNumberCtrl.text = filter.number.toString();
    phoneCtrl.text = filter.phone;
  }

  final MasterFilterScreenArgs args;
  late AppMasterUserDict dict;

  final filterNameCtrl = TextEditingController();
  final masterNumberCtrl = TextEditingController();
  final masterNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  List<TextEditingController> get _controllers => [
        filterNameCtrl,
        masterNumberCtrl,
        masterNameCtrl,
        phoneCtrl,
      ];

  @observable
  AppMasterUserFilter _filter = AppMasterUserFilter.empty;

  @computed
  AppMasterUserFilter get filter => _filter;

  @protected
  set filter(AppMasterUserFilter value) => _filter = value;

  @action
  Future<void> submit(BuildContext context) async {
    final data = filter.copyWith(
      name: filterNameCtrl.text.trim(),
      masterName: masterNameCtrl.text.trim(),
      number: masterNumberCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
    );
    Navigator.of(context).pop(data);
  }

  @action
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
  }
}

class MasterFilterScreenArgs {
  const MasterFilterScreenArgs({
    required this.dict,
    this.initFilter = AppMasterUserFilter.empty,
    this.name,
  });

  final AppMasterUserFilter initFilter;
  final AppMasterUserDict dict;
  final String? name;
}

class MasterFilterScreen extends StatelessWidget {
  const MasterFilterScreen({required this.args, super.key});

  final MasterFilterScreenArgs args;

  static const String routeName = '/master_filter';

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
        title: Text('Фильтр'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                if (_State.of(context).args.name?.isNotEmpty == true)
                  AppTextInputField(
                    controller: _State.of(context).filterNameCtrl,
                    keyboardType: TextInputType.text,
                    onEditingComplete: () =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration:
                        const InputDecoration(labelText: 'Название фильтра'),
                  ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).masterNumberCtrl,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(labelText: 'Номер мастера'),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).masterNameCtrl,
                  keyboardType: TextInputType.text,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(labelText: 'Имя мастера'),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).phoneCtrl,
                  keyboardType: TextInputType.phone,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(labelText: 'Телефон'),
                ),
                const SizedBox(height: 16),
                AppDropdownMultiSelectField<int>(
                  label: 'Роль',
                  selectedOptions: Map.fromEntries(_State.of(context)
                      .dict
                      .role
                      .entries
                      .where((e) =>
                          _State.of(context).filter.role.contains(e.key))),
                  options: _State.of(context).dict.role,
                  valueTransformer: (value) => int.parse(value!),
                  onSelected: (value) {
                    _State.of(context).filter =
                        _State.of(context).filter.copyWith(
                              role: value,
                            );
                  },
                ),
                const SizedBox(height: 16),
                AppDropdownMultiSelectField<int>(
                  label: 'Компания',
                  selectedOptions: Map.fromEntries(_State.of(context)
                      .dict
                      .companyId
                      .entries
                      .where((e) =>
                          _State.of(context).filter.companyId.contains(e.key))),
                  options: _State.of(context).dict.companyId,
                  valueTransformer: (value) => int.parse(value!),
                  onSelected: (value) {
                    _State.of(context).filter =
                        _State.of(context).filter.copyWith(
                              companyId: value,
                            );
                  },
                ),
                const SizedBox(height: 16),
                AppDropdownMultiSelectField<int>(
                  label: 'Город',
                  selectedOptions: Map.fromEntries(_State.of(context)
                      .dict
                      .cityId
                      .entries
                      .where((e) =>
                          _State.of(context).filter.cityId.contains(e.key))),
                  options: _State.of(context).dict.cityId,
                  valueTransformer: (value) => int.parse(value!),
                  onSelected: (value) {
                    _State.of(context).filter =
                        _State.of(context).filter.copyWith(
                              cityId: value,
                            );
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Состояние',
                      style: AppTextStyle.regularHeadline
                          .style(context, AppColors.violetLight),
                    ),
                    const SizedBox(height: 16),
                    Observer(builder: (context) {
                      final active = _State.of(context).filter.active;
                      return Row(
                        children: [
                          AppCheckBox(
                            value: active == true,
                            onChanged: (value) {
                              if (value == true) {
                                if (active != true) {
                                  _State.of(context).filter = _State.of(context)
                                      .filter
                                      .copyWith(active: true);
                                }
                              } else {
                                _State.of(context).filter =
                                    _State.of(context).filter.clearActive();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'On',
                            style: AppTextStyle.regularHeadline.style(context),
                          ),
                          const SizedBox(width: 32),
                          AppCheckBox(
                            value: active == false,
                            onChanged: (value) {
                              if (value == true) {
                                if (active != false) {
                                  _State.of(context).filter = _State.of(context)
                                      .filter
                                      .copyWith(active: false);
                                }
                              } else {
                                _State.of(context).filter =
                                    _State.of(context).filter.clearActive();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Off',
                            style: AppTextStyle.regularHeadline.style(context),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton.red(
                        onPressed: () => Navigator.of(context)
                            .pop(AppMasterUserFilter.empty),
                        text: 'Очистить',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton.green(
                        onPressed: () => _State.of(context).submit(context),
                        text: 'Применить',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
