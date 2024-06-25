import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'master_edit_screen.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.args);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.args) {
    if (args.user?.id != null) {
      master = args.user;
      try {
        _assignMastedFields();
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s);
      }
    } else {
      master = AppMasterUser.empty;
    }
    init();
  }
  final _repo = UsersRepository();
  final MasterEditArgs args;
  final formKey = GlobalKey<FormState>();

  final firstName = ShakerField.create();
  final lastName = ShakerField.create();
  final patronymic = ShakerField.create();
  final number = ShakerField.create();
  final email = ShakerField.create();
  final phone = ShakerField.create();
  final address = ShakerField.create();
  final comment = ShakerField.create();
  final pass = ShakerField.create();

  List<ShakerField> get fields => [
        lastName,
        firstName,
        patronymic,
        number,
        email,
        phone,
        address,
        comment,
        pass,
      ];

  @observable
  AppMasterUserDict? _dict;
  @computed
  AppMasterUserDict get dict => _dict ?? _repo.dict;
  @protected
  set dict(AppMasterUserDict value) => _dict = value;

  @observable
  AppMasterUser? _master;
  @computed
  AppMasterUser? get master => _master;
  @protected
  set master(AppMasterUser? value) => _master = value;

  @observable
  ObservableList<String> _additionalPhone = ObservableList();
  @computed
  ObservableList<String> get additionalPhone => _additionalPhone;
  @protected
  set additionalPhone(ObservableList<String> value) => _additionalPhone = value;

  @observable
  bool _active = false;
  @computed
  bool get active => _active;
  @protected
  set active(bool value) => _active = value;

  @observable
  int? _cityId;
  @computed
  int? get cityId => _cityId;
  @protected
  set cityId(int? value) => _cityId = value;

  @observable
  int? _companyId;
  @computed
  int? get companyId => _companyId;
  @protected
  set companyId(int? value) => _companyId = value;

  @observable
  int? _roleId;
  @computed
  int? get roleId => _roleId;
  @protected
  set roleId(int? value) => _roleId = value;

  @observable
  int? _them;
  @computed
  int? get them => _them;
  @protected
  set them(int? value) => _them = value;

  @observable
  List<String> _tags = [];
  @computed
  List<String> get tags => _tags;
  @protected
  set tags(List<String> value) => _tags = value;

  @observable
  bool _isCanCall = false;
  @computed
  bool get isCanCall => _isCanCall;
  @protected
  set isCanCall(bool value) => _isCanCall = value;

  @observable
  bool _isCanView = false;
  @computed
  bool get isCanView => _isCanView;
  @protected
  set isCanView(bool value) => _isCanView = value;

  @observable
  bool _isCanRemoveMaster = false;
  @computed
  bool get isCanRemoveMaster => _isCanRemoveMaster;
  @protected
  set isCanRemoveMaster(bool value) => _isCanRemoveMaster = value;

  @observable
  XFile? _avatar;
  @computed
  XFile? get avatar => _avatar;
  @protected
  set avatar(XFile? value) => _avatar = value;

  @observable
  ObservableList<XFile> _documents = ObservableList();
  @computed
  ObservableList<XFile> get documents => _documents;
  @protected
  set documents(ObservableList<XFile> value) => _documents = value;

  @action
  Future<void> init() async {
    dict = await _repo.getUsersListFilter();
  }

  @action
  Future<void> submit(BuildContext context) async {
    if (formKey.currentState?.validate() == true) {
      FocusManager.instance.primaryFocus?.unfocus();
      try {
        if (args.user != null) {
          await withLoadingIndicator(() async {
            await _repo.editUser(
              args.user!.id,
              body: getBody(),
              avatar: avatar,
              documents: documents,
            );
            Navigator.of(context).pop(true);
          });
        } else {
          await withLoadingIndicator(() async {
            await _repo.addNewUser(
              body: getBody(),
              avatar: avatar,
              documents: documents,
            );
            Navigator.of(context).pop(true);
          });
        }
      } catch (e) {
        if (e is DioException) {
          if (e is ApiException) {
            await showMessage(
              context,
              message: e.message,
              type: AppMessageType.error,
            );
          }
        }
      }
    } else {
      for (final shaker in fields) {
        if (shaker.hasError) {
          shaker
            ..requestFocus()
            ..shake();
          return;
        }
      }
    }
  }

  @action
  void _assignMastedFields() {
    assert(master != null);
    assert(master is AppMasterUser);
    firstName.textValue = master!.firstName;
    lastName.textValue = master!.lastName;
    patronymic.textValue = master!.patronymic;
    number.textValue = master!.number.toString();
    email.textValue = master!.email;
    phone.textValue = master!.contacts.primary;
    address.textValue = master!.homeAddress;
    comment.textValue = master!.comment;
    additionalPhone.addAll(master!.contacts.additional);
    cityId = master!.cityId;
    companyId = master!.companyId;
    roleId = master!.role;
    them = master!.them;
    tags = master!.tags.keys.toList();
    isCanView = master!.isCanView;
    isCanCall = master!.isCanCall;
    isCanRemoveMaster = master!.isCanRemoveMaster;
    active = master!.active;
  }

  @action
  Future<void> selectAvatar(BuildContext context) async {
    final file = await AppImagePicker.showSelectDialog(context);
    if (file != null) {
      avatar = file;
    }
  }

  @action
  Future<void> addDocument(BuildContext context) async {
    final file = await AppImagePicker.showSelectDialog(context);
    if (file != null) {
      documents.add(file);
    }
  }

  @action
  Future<void> deleteDocument(BuildContext context, XFile document) async {
    documents.remove(document);
  }

  Map<String, dynamic> getBody() => {
        'first_name': firstName.textValue,
        'last_name': lastName.textValue,
        'patronymic': patronymic.textValue,
        'email': email.textValue,
        'home_address': address.textValue,
        'phone': phone.textValue,
        'comment': comment.textValue,
        'password': pass.textValue,
        'additional_phone[]': additionalPhone.toList(),
        'city_id': cityId,
        'company_id': companyId,
        'role': roleId,
        'them': them,
        'tags[]': tags,
        'active': active.asInt(),
        'is_can_call': isCanCall.asInt(),
        'is_can_view': isCanView.asInt(),
        'is_can_remove_master': isCanRemoveMaster.asInt(),
      };

  @action
  void addPhone() => additionalPhone.add('');

  @action
  void removePhone(int index) => additionalPhone.removeAt(index);

  @action
  void dispose() {
    for (final f in fields) {
      f.dispose();
    }
  }
}

class MasterEditArgs {
  const MasterEditArgs({this.user});
  final AppMasterUser? user;
}

class MasterEdit extends StatelessWidget {
  const MasterEdit({required this.args, super.key});

  final MasterEditArgs args;

  static const String routeName = '/master_edit_screen';

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
      appBar: AppToolbar(
        title: Text(
            _State.of(context).master != null ? 'Редактирование' : 'Создание'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _State.of(context).formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_State.of(context).master?.canEditStatus == true) ...[
                        const _Status(),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Основная информация',
                        style: AppTextStyle.regularHeadline.style(
                          context,
                          AppColors.violetLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _UploadPhoto(),
                      if (_State.of(context).master?.canEditStatus == true) ...[
                        const SizedBox(height: 16),
                        const _MainInfoForm(),
                      ],
                      if (_State.of(context).master?.canEditDocuments ==
                          true) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Документы',
                          style: AppTextStyle.regularHeadline.style(
                            context,
                            AppColors.violetLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _Documents(),
                      ],
                      if (_State.of(context).master?.canEditContactInfo ==
                          true) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Контактная информация',
                          style: AppTextStyle.regularHeadline.style(
                            context,
                            AppColors.violetLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _ContactForm(),
                      ],
                      if (_State.of(context).master?.canEditSpec == true) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Специализация',
                          style: AppTextStyle.regularHeadline.style(
                            context,
                            AppColors.violetLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _SpecForm(),
                      ],
                      if (_State.of(context).master?.canEditAvailableButtons ==
                          true) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Возможности',
                          style: AppTextStyle.regularHeadline.style(
                            context,
                            AppColors.violetLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _AbilityList(),
                      ],
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppMaterialBox(
              elevation: 6,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton.red(
                            onPressed: () => Navigator.of(context).pop(),
                            text: 'Отмена',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton.green(
                            onPressed: () => _State.of(context).submit(context),
                            text: 'Сохранить',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessObserverWidget {
  const _Status();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Статус:',
            style: AppTextStyle.regularHeadline.style(context),
          ),
        ),
        AppSwitch(
          statusString: _State.of(context).active ? 'On' : 'Off',
          isSwitched: _State.of(context).active,
          onChanged: (state) {
            _State.of(context).active = state;
          },
        ),
      ],
    );
  }
}

class _UploadPhoto extends StatelessObserverWidget {
  const _UploadPhoto();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhotoPicker(
          onTap: () => _State.of(context).selectAvatar(context),
          file: _State.of(context).avatar?.toFile(),
          fileUri: _State.of(context).master?.avatar,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Загрузить фото',
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Нажмите “Плюс” и сделайте  фото или загрузите из готовых',
                style: AppTextStyle.regularCaption.style(
                  context,
                  AppColors.violetLight,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _Documents extends StatelessObserverWidget {
  const _Documents();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._State.of(context).documents.map((e) => PhotoPicker(
              onTap: () {
                _State.of(context).deleteDocument(context, e);
              },
              file: e.toFile(),
            )),
        PhotoPicker(onTap: () => _State.of(context).addDocument(context)),
      ],
    );
  }
}

class _AbilityList extends StatelessObserverWidget {
  const _AbilityList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Может звонить:',
                style: AppTextStyle.regularHeadline.style(context),
              ),
            ),
            AppSwitch(
              statusString: _State.of(context).isCanCall ? 'On' : 'Off',
              isSwitched: _State.of(context).isCanCall,
              onChanged: (state) {
                _State.of(context).isCanCall = state;
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Просмотр заказа:',
                style: AppTextStyle.regularHeadline.style(context),
              ),
            ),
            AppSwitch(
              statusString: _State.of(context).isCanView ? 'On' : 'Off',
              isSwitched: _State.of(context).isCanView,
              onChanged: (state) {
                _State.of(context).isCanView = state;
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Отвязать мастера:',
                style: AppTextStyle.regularHeadline.style(context),
              ),
            ),
            AppSwitch(
              statusString: _State.of(context).isCanRemoveMaster ? 'On' : 'Off',
              isSwitched: _State.of(context).isCanRemoveMaster,
              onChanged: (state) {
                _State.of(context).isCanRemoveMaster = state;
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _MainInfoForm extends StatelessObserverWidget {
  const _MainInfoForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextInputField(
          controller: _State.of(context).lastName.controller,
          focusNode: _State.of(context).lastName.focusNode,
          shakeKey: _State.of(context).lastName.shakeKey,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          validator: (value) => _State.of(context).lastName.inputFieldValidator(
            value,
            [
              NotEmptyValidator(),
              RangeLengthValidator(2, 30),
            ],
          ),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Фамилия',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).firstName.controller,
          focusNode: _State.of(context).firstName.focusNode,
          shakeKey: _State.of(context).firstName.shakeKey,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          validator: (value) =>
              _State.of(context).firstName.inputFieldValidator(
            value,
            [
              NotEmptyValidator(),
              RangeLengthValidator(2, 30),
            ],
          ),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Имя',
          ),
        ),
        const SizedBox(height: 16),
        AppTextInputField(
          controller: _State.of(context).patronymic.controller,
          focusNode: _State.of(context).patronymic.focusNode,
          shakeKey: _State.of(context).patronymic.shakeKey,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          validator: (value) =>
              _State.of(context).patronymic.inputFieldValidator(
            value,
            [
              NotEmptyValidator(),
              RangeLengthValidator(2, 30),
            ],
          ),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Отчество',
          ),
        ),
        if (_State.of(context).master != null) ...[
          const SizedBox(height: 16),
          AppTextInputField(
            enabled: false,
            controller: _State.of(context).number.controller,
            decoration: const InputDecoration(
              labelText: 'Номер мастера',
            ),
          ),
        ],
      ],
    );
  }
}

class _ContactForm extends StatelessObserverWidget {
  const _ContactForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextInputField(
          controller: _State.of(context).email.controller,
          focusNode: _State.of(context).email.focusNode,
          shakeKey: _State.of(context).email.shakeKey,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => _State.of(context).email.inputFieldValidator(
            value,
            [
              EmailValidator(),
            ],
          ),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 16),
        if (_State.of(context).args.user == null) ...[
          AppTextInputField(
            controller: _State.of(context).pass.controller,
            focusNode: _State.of(context).pass.focusNode,
            shakeKey: _State.of(context).pass.shakeKey,
            obscureText: true,
            keyboardType: TextInputType.text,
            validator: (value) => _State.of(context).pass.inputFieldValidator(
              value,
              [
                MinLengthValidator(8),
              ],
            ),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Пароль',
            ),
          ),
          const SizedBox(height: 16),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Контактный телефон',
              style: AppTextStyle.regularCaption.style(context),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextInputField(
                    controller: _State.of(context).phone.controller,
                    focusNode: _State.of(context).phone.focusNode,
                    shakeKey: _State.of(context).phone.shakeKey,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        _State.of(context).phone.inputFieldValidator(
                      value,
                      [
                        MinLengthValidator(10),
                      ],
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 8),
                AppIcons.add.iconButton(
                  splitColor: AppSplitColor.violet(),
                  size: const Size.square(48),
                  onPressed: () {
                    _State.of(context).additionalPhone.add('');
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _State.of(context).additionalPhone.length; i++) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Дополнительный телефон ${i + 1}',
                style: AppTextStyle.regularCaption.style(context),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextInputField(
                      initialValue: _State.of(context).additionalPhone[i],
                      onChanged: (value) {
                        _State.of(context).additionalPhone[i] = value;
                      },
                      keyboardType: TextInputType.phone,
                      validator: (value) => FormValidator.inputFieldValidator(
                        value,
                        [
                          MinLengthValidator(10),
                        ],
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppIcons.trash.iconButton(
                    splitColor: AppSplitColor.red(),
                    size: const Size.square(48),
                    onPressed: () {
                      _State.of(context).additionalPhone.removeAt(i);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        AppDropdownField<int?>(
          label: 'Город',
          items: _State.of(context).dict.cityId.entries,
          value: _State.of(context).cityId,
          onChange: (value) {
            if (value != null) {
              _State.of(context).cityId = value;
            }
          },
        ),
        AppTextInputField(
          controller: _State.of(context).address.controller,
          focusNode: _State.of(context).address.focusNode,
          shakeKey: _State.of(context).address.shakeKey,
          keyboardType: TextInputType.text,
          validator: (value) => _State.of(context).address.inputFieldValidator(
            value,
            [
              RangeLengthValidator(5, 500),
            ],
          ),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Домашний адрес',
          ),
        ),
      ],
    );
  }
}

class _SpecForm extends StatelessObserverWidget {
  const _SpecForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_State.of(context).master?.canEditCompany == true)
          AppDropdownField<int?>(
            label: 'Компания',
            items: _State.of(context).dict.companyId.entries,
            value: _State.of(context).companyId,
            onChange: (value) {
              if (value != null) {
                _State.of(context).companyId = value;
              }
            },
          ),
        if (_State.of(context).master?.canEditRole == true)
          AppDropdownField<int?>(
            label: 'Роль',
            items: _State.of(context).dict.role.entries,
            value: _State.of(context).roleId,
            onChange: (value) {
              if (value != null) {
                _State.of(context).roleId = value;
              }
            },
          ),
        if (_State.of(context).master?.canEditThem == true)
          AppDropdownField<int?>(
            label: 'Тематика',
            items: _State.of(context).dict.them.entries,
            value: _State.of(context).them,
            onChange: (value) {
              if (value != null) {
                _State.of(context).them = value;
              }
            },
          ),
        if (_State.of(context).master?.canEditTags == true)
          AppDropdownMultiSelectField<String>(
              label: 'Специализация',
              options: _State.of(context).dict.tags.map(
                    (key, value) => MapEntry(
                      key.toString(),
                      value,
                    ),
                  ),
              selectedOptions: Map.fromEntries(
                _State.of(context).tags.map(
                      (e) => MapEntry(
                        e,
                        _State.of(context).dict.tags[int.parse(e)],
                      ),
                    ),
              ),
              valueTransformer: (value) => value,
              onSelected: (data) {
                _State.of(context).tags = data;
              }),
        if (_State.of(context).master?.canEditComment == true) ...[
          const SizedBox(height: 16),
          AppTextInputField(
            controller: _State.of(context).comment.controller,
            focusNode: _State.of(context).comment.focusNode,
            shakeKey: _State.of(context).comment.shakeKey,
            keyboardType: TextInputType.text,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Комментарий',
            ),
          ),
        ],
      ],
    );
  }
}
