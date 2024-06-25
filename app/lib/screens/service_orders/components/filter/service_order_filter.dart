import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

part 'service_order_filter.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.args) {
    if (args.name?.isNotEmpty == true) {
      nameCtrl.text = args.name!;
    }
    dictionary = args.dictionary;
    filters = args.initFilters;
    queryCtrl
      ..addListener(queryListener)
      ..text = filters.queryText;
    if (filters.dateFrom.millisecondsSinceEpoch > 0) {
      dateCtrl.text =
          '''${DateFormat('dd MMM yyyy', 'ru').format(filters.dateFrom)} - ${DateFormat('dd MMM yyyy', 'ru').format(filters.dateTo)}''';
    }
  }

  final ServiceOrderFilterScreenArgs args;
  final formKey = GlobalKey<FormState>();
  late ServiceOrderDict dictionary;
  final queryCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  @observable
  ServiceOrderFilter _filters = ServiceOrderFilter.empty;
  @computed
  ServiceOrderFilter get filters => _filters;
  @protected
  set filters(ServiceOrderFilter value) => _filters = value;

  @action
  void queryListener() {
    filters = filters.copyWith(queryText: queryCtrl.text.trim());
  }

  void submit(BuildContext context) {
    assert(
      (args.name != null && nameCtrl.text.trim().isNotEmpty == true) ||
          args.name == null,
      'Имя фильра не может быть пустым',
    );
    Navigator.of(context).maybePop(
      _State.of(context).filters.copyWith(
            name: _State.of(context).nameCtrl.text,
          ),
    );
  }

  void reset(BuildContext context) {
    assert(
      (args.name != null && nameCtrl.text.trim().isNotEmpty == true) ||
          args.name == null,
      'Имя фильра не может быть пустым',
    );
    Navigator.of(context).maybePop(
      ServiceOrderFilter.empty.copyWith(
        name: _State.of(context).filters.name,
      ),
    );
  }

  @action
  void dispose() {
    queryCtrl
      ..removeListener(queryListener)
      ..dispose();
    dateCtrl.dispose();
    try {
      nameCtrl.dispose();
    } catch (_) {}
  }
}

class ServiceOrderFilterScreenArgs {
  const ServiceOrderFilterScreenArgs({
    required this.dictionary,
    required this.initFilters,
    this.name,
  });
  final ServiceOrderDict dictionary;
  final ServiceOrderFilter initFilters;
  final String? name;
}

class ServiceOrderFilterScreen extends StatelessWidget {
  const ServiceOrderFilterScreen(this.args, {super.key});

  final ServiceOrderFilterScreenArgs args;

  static const String routeName = '/service_order_filter';

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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _State.of(context).formKey,
            child: Column(
              children: [
                if (_State.of(context).args.name != null) ...[
                  AppTextInputField(
                    controller: _State.of(context).nameCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    onEditingComplete: () =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration:
                        const InputDecoration(labelText: 'Название вкладки'),
                    onChanged: (value) {
                      _State.of(context).filters =
                          _State.of(context).filters.copyWith(name: value);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                AppTextInputField(
                  controller: _State.of(context).queryCtrl,
                  keyboardType: TextInputType.text,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(
                      labelText: 'Номер телефона/Номер заказа'),
                ),
                const SizedBox(height: 16),
                AppMultiSelectField<int>(
                  label: 'Статус',
                  value: _State.of(context).filters.status,
                  items: _State.of(context).dictionary.statuses.entries,
                  onChange: (value) {
                    _State.of(context).filters =
                        _State.of(context).filters.copyWith(status: value);
                  },
                ),
                const SizedBox(height: 16),
                AppMultiSelectField<int>(
                  label: 'Мастер',
                  value:
                      _State.of(context).filters.master.map(int.parse).toList(),
                  items: _State.of(context).dictionary.masters.entries,
                  onChange: (value) {
                    _State.of(context).filters = _State.of(context)
                        .filters
                        .copyWith(
                            master: value.map((e) => e.toString()).toList());
                  },
                ),
                const SizedBox(height: 16),
                AppMultiSelectField<int>(
                  label: 'Мастер СЦ',
                  value: _State.of(context)
                      .filters
                      .serviceMaster
                      .map(int.parse)
                      .toList(),
                  items: _State.of(context).dictionary.serviceMasters.entries,
                  onChange: (value) {
                    _State.of(context).filters = _State.of(context)
                        .filters
                        .copyWith(
                            serviceMaster:
                                value.map((e) => e.toString()).toList());
                  },
                ),
                const SizedBox(height: 16),
                AppMultiSelectField<int>(
                  label: 'Компания',
                  value: _State.of(context)
                      .filters
                      .company
                      .map(int.parse)
                      .toList(),
                  items: _State.of(context).dictionary.companies.entries,
                  onChange: (value) {
                    _State.of(context).filters = _State.of(context)
                        .filters
                        .copyWith(
                            company: value.map((e) => e.toString()).toList());
                  },
                ),
                const SizedBox(height: 16),
                AppMultiSelectField<int>(
                  label: 'Город',
                  value:
                      _State.of(context).filters.city.map(int.parse).toList(),
                  items: _State.of(context).dictionary.cities.entries,
                  onChange: (value) {
                    _State.of(context).filters = _State.of(context)
                        .filters
                        .copyWith(
                            city: value.map((e) => e.toString()).toList());
                  },
                ),
                const SizedBox(height: 16),
                AppMultiSelectField<int>(
                  label: 'Техника',
                  value: _State.of(context)
                      .filters
                      .technicType
                      .map(int.parse)
                      .toList(),
                  items: _State.of(context).dictionary.technique.entries,
                  onChange: (value) {
                    _State.of(context).filters = _State.of(context)
                        .filters
                        .copyWith(
                            technicType:
                                value.map((e) => e.toString()).toList());
                  },
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        onPressed: () {
                          _State.of(context).filters = _State.of(context)
                              .filters
                              .copyWith(
                                dateFrom:
                                    DateTime.fromMillisecondsSinceEpoch(0),
                                dateTo: DateTime.fromMillisecondsSinceEpoch(0),
                              );
                          _State.of(context).dateCtrl.text = '';
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 46,
                      top: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.utc(2022),
                              lastDate: DateTime.now(),
                              locale:
                                  const Locale.fromSubtags(languageCode: 'ru'),
                              initialDateRange: _State.of(context)
                                          .filters
                                          .dateFrom
                                          .millisecondsSinceEpoch >
                                      0
                                  ? DateTimeRange(
                                      start:
                                          _State.of(context).filters.dateFrom,
                                      end: _State.of(context).filters.dateTo,
                                    )
                                  : null,
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark(useMaterial3: true),
                                  child: child!,
                                );
                              });
                          if (range != null) {
                            _State.of(context).dateCtrl.text =
                                '''${DateFormat('dd MMM yyyy', 'ru').format(range.start)} - ${DateFormat('dd MMM yyyy', 'ru').format(range.end)}''';
                            _State.of(context).filters =
                                _State.of(context).filters.copyWith(
                                      dateFrom: range.start,
                                      dateTo: range.end,
                                    );
                          }
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                    IgnorePointer(
                      child: AppTextInputField(
                        controller: _State.of(context).dateCtrl,
                        keyboardType: TextInputType.text,
                        onEditingComplete: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration:
                            const InputDecoration(labelText: 'Диапазон дат'),
                      ),
                    ),
                  ],
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
          ),
        ),
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
        onPressed: () {
          try {
            _State.of(context).submit(context);
          } catch (e) {
            if (e is AssertionError) {
              showMessage(
                context,
                message: e.message.toString(),
                type: AppMessageType.error,
              );
            }
          }
        },
        text: 'Применить',
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
        onPressed: () {
          try {
            _State.of(context).reset(context);
          } catch (e) {
            if (e is AssertionError) {
              showMessage(
                context,
                message: e.message.toString(),
                type: AppMessageType.error,
              );
            }
          }
        },
        text: 'Сбросить',
      ),
    );
  }
}
