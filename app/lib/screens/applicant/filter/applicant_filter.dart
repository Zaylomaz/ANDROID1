import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

part 'applicant_filter.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(
    this.args,
  ) {
    dict = args.dict;
    filter = args.initFilter;
    if (args.name?.isNotEmpty == true) {
      filterNameCtrl.text = args.name!;
    }
    clientNameCtrl.text = filter.clientName;
    emailCtrl.text = filter.email;
    phoneCtrl.text = filter.phone;
  }

  final ApplicantFilterScreenArgs args;
  late ApplicantFilterOptions dict;

  final filterNameCtrl = TextEditingController();
  final clientNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @observable
  ApplicantFilter _filter = ApplicantFilter.empty;
  @computed
  ApplicantFilter get filter => _filter;
  @protected
  set filter(ApplicantFilter value) => _filter = value;

  @action
  void submit(BuildContext context) {
    Navigator.of(context).pop(_State.of(context).filter.copyWith(
          clientName: clientNameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          name: filterNameCtrl.text.trim(),
        ));
  }

  @action
  void dispose() {
    clientNameCtrl.dispose();
    filterNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
  }
}

class ApplicantFilterScreenArgs {
  const ApplicantFilterScreenArgs({
    required this.dict,
    this.initFilter = ApplicantFilter.empty,
    this.name,
  });
  final ApplicantFilter initFilter;
  final ApplicantFilterOptions dict;
  final String? name;
}

class ApplicantFilterScreen extends StatelessWidget {
  const ApplicantFilterScreen({
    required this.args,
    super.key,
  });

  final ApplicantFilterScreenArgs args;

  static const String routeName = '/applicant_filter';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(args),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
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
                  controller: _State.of(context).clientNameCtrl,
                  keyboardType: TextInputType.text,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(labelText: 'ФИО'),
                ),
                const SizedBox(height: 16),
                AppTextInputField(
                  controller: _State.of(context).emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(labelText: 'Email'),
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
                AppDropdownField<int?>(
                  label: 'Вакансия',
                  value: _State.of(context).filter.jobVacancy,
                  items: _State.of(context).dict.jobVacancies.entries,
                  onChange: (value) {
                    _State.of(context).filter =
                        _State.of(context).filter.copyWith(
                              jobVacancy: value,
                            );
                  },
                ),
                AppDropdownField<int?>(
                  label: 'Статус',
                  value: _State.of(context).filter.status,
                  items: _State.of(context).dict.statuses.entries,
                  onChange: (value) {
                    _State.of(context).filter =
                        _State.of(context).filter.copyWith(
                              status: value,
                            );
                  },
                ),
                AppDropdownField<int?>(
                  label: 'Город',
                  value: _State.of(context).filter.cityId,
                  items: _State.of(context).dict.cities.entries,
                  onChange: (value) {
                    _State.of(context).filter =
                        _State.of(context).filter.copyWith(
                              cityId: value,
                            );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton.red(
                        onPressed: () =>
                            Navigator.of(context).pop(ApplicantFilter.empty),
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
