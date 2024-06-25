import 'package:core/core.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/master/edit/master_edit_screen.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'master_screen.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.master, super.dict, {super.currentUserProfile});

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(
    this.init,
    AppMasterUserDict? dict, {
    this.currentUserProfile = false,
  }) {
    master = init;
    this.dict = dict ?? _repo.dict;
    getData();
  }

  final _repo = UsersRepository();
  final bool currentUserProfile;
  final AppMasterUser init;
  late AppMasterUserDict dict;

  @observable
  AppMasterUser? _master;
  @computed
  AppMasterUser get master => _master ?? init;
  @protected
  set master(AppMasterUser? value) => _master = value;

  @action
  Future<void> getData() async {
    master = await withLoadingIndicator(() => _repo.getUserInfo(master.id));
  }

  @action
  void dispose() {}
}

class MasterScreenDetailsArgs {
  const MasterScreenDetailsArgs({
    required this.master,
    this.dict,
  });
  final AppMasterUser master;
  final AppMasterUserDict? dict;
}

class MasterScreenDetails extends StatelessWidget {
  const MasterScreenDetails({required this.args, super.key});

  final MasterScreenDetailsArgs args;

  static const String routeName = '/master_details_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(
        args.master,
        args.dict,
        currentUserProfile: context.read<HomeData>().userId == args.master.id,
      ),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final master = _State.of(context).master;
    return Scaffold(
      appBar: AppToolbar(
        title: Text('# ${_State.of(context).master.number}'),
        actions: [
          if (master.isCanEdit)
            AppIcons.edit.fabButton(
              color: AppSplitColor.violet(),
              onPressed: () async {
                final update = await Navigator.of(context).pushNamed(
                        MasterEdit.routeName,
                        arguments:
                            MasterEditArgs(user: _State.of(context).master))
                    as bool?;
                if (update == true) {
                  if (_State.of(context).master.id ==
                      HomeData.of(context).user?.id) {
                    await HomeData.of(context).updateUserInfo();
                  }
                  await _State.of(context).getData();
                }
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _State.of(context).getData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppMaterialBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          clipBehavior: Clip.hardEdge,
                          decoration: ShapeDecoration(
                            color: AppColors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Image.network(
                            master.avatar?.toString() ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: imageErrorWidget,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              master.fullName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.boldHeadLine.style(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _State.of(context).dict.role[master.role] ?? '',
                              style: AppTextStyle.regularSubHeadline.style(
                                context,
                                AppColors.violetLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                AppIcons.numberHash.iconColored(
                                  color: AppSplitColor.violet(),
                                  iconSize: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  master.number.toString(),
                                  style: AppTextStyle.regularSubHeadline
                                      .style(context),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: ShapeDecoration(
                                    color: master.active
                                        ? AppColors.greenDark
                                        : AppColors.redDark,
                                    shape: const OvalBorder(),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: ShapeDecoration(
                                        color: master.active
                                            ? AppColors.green
                                            : AppColors.red,
                                        shape: const OvalBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  master.active ? 'On' : 'Off',
                                  style: AppTextStyle.regularSubHeadline.style(
                                    context,
                                    master.active
                                        ? AppColors.green
                                        : AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppMaterialBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Фото паспорта',
                          style: AppTextStyle.regularCaption.style(context),
                        ),
                        const SizedBox(height: 8),
                        if (master.documentPhotos.isNotEmpty)
                          Wrap(
                            runSpacing: 8,
                            spacing: 8,
                            children: master.documentPhotos
                                .map((e) => Container(
                                      width: 120,
                                      height: 120,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: ShapeDecoration(
                                        color: AppColors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Image.network(
                                        e.toString(),
                                        fit: BoxFit.cover,
                                        errorBuilder: imageErrorWidget,
                                      ),
                                    ))
                                .toList(),
                          )
                        else
                          IconWithTextRow(
                            text: 'Фото не загружено',
                            leading: AppIcons.attention.iconColored(
                              color: AppSplitColor.red(),
                              iconSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppMaterialBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconWithTextRow(
                          text: _State.of(context).dict.cityId[master.cityId] ??
                              '',
                          leading: AppIcons.location.iconColored(
                            color: AppSplitColor.violet(),
                            iconSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconWithTextRow(
                          text: master.homeAddress,
                          leading: AppIcons.map.iconColored(
                            color: AppSplitColor.violet(),
                            iconSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconWithTextRow(
                          text: master.email,
                          leading: AppIcons.email.iconColored(
                            color: AppSplitColor.violet(),
                            iconSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconWithTextRow(
                                    text: master.contacts.primary,
                                    leading: AppIcons.phone.iconColored(
                                      color: AppSplitColor.green(),
                                      iconSize: 16,
                                    ),
                                  ),
                                  if (master
                                      .contacts.additional.isNotEmpty) ...[
                                    for (final phone
                                        in master.contacts.additional) ...[
                                      const SizedBox(height: 8),
                                      IconWithTextRow(
                                        text: phone,
                                        leading: AppIcons.phone.iconColored(
                                          color: AppSplitColor.violetLight(),
                                          iconSize: 16,
                                        ),
                                      ),
                                    ]
                                  ],
                                ],
                              ),
                            ),
                            if (!_State.of(context).currentUserProfile) ...[
                              const SizedBox(width: 8),
                              CallButton(
                                phone: master.contacts.primary,
                                additionalPhones: master.contacts.additional,
                                binotel: master.contacts.binotel,
                                asterisk: master.contacts.asterisk,
                                ringostat: master.contacts.ringostat,
                                isSipActive: context.read<SipModel>().isActive,
                                onMakeCall: (phone) =>
                                    context.read<SipModel>().makeCall(phone),
                                onTryCall: () {
                                  showMessage(context,
                                      message: 'Sip не активен');
                                },
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppMaterialBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconWithTextRow(
                          text: _State.of(context)
                                  .dict
                                  .companyId[master.companyId] ??
                              '',
                          leading: AppIcons.company.iconColored(
                            color: AppSplitColor.violet(),
                            iconSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconWithTextRow(
                          text: _State.of(context).dict.them[master.them] ?? '',
                          leading: AppIcons.education.iconColored(
                            color: AppSplitColor.violet(),
                            iconSize: 16,
                          ),
                        ),
                        if (master.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: master.tags
                                .map(
                                  (key, value) => MapEntry(
                                    key,
                                    AppChip(
                                      label: value,
                                      isSelected: true,
                                    ),
                                  ),
                                )
                                .values
                                .toList(),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppMaterialBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconWithTextRow(
                          text: 'Возможность звонка',
                          leading: master.isCanCall
                              ? AppIcons.checked.widget(color: AppColors.green)
                              : AppIcons.cross.widget(color: AppColors.red),
                        ),
                        const SizedBox(height: 8),
                        IconWithTextRow(
                          text: 'Возможность просмотра заказа',
                          leading: master.isCanView
                              ? AppIcons.checked.widget(color: AppColors.green)
                              : AppIcons.cross.widget(color: AppColors.red),
                        ),
                        const SizedBox(height: 8),
                        IconWithTextRow(
                          text: 'Возможность отвязать мастера',
                          leading: master.isCanRemoveMaster
                              ? AppIcons.checked.widget(color: AppColors.green)
                              : AppIcons.cross.widget(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
