import 'dart:async';

import 'package:audio_player/audio_player.dart';
import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:preference/preference.dart';
import 'package:rempc/screens/calls/details/call_details.dart';
import 'package:rempc/screens/calls/filter/calls_filter.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:rempc/ui/components/filter_list.dart';
import 'package:rempc/ui/components/tab_view/tab_selector.dart';
import 'package:rempc/ui/components/tab_view/tab_view_model.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'calls_screen.g.dart';
part 'tabs.dart';

class _State extends _StateStore with _$_State {
  _State(super.sipModel, super.vsync);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store, TabViewStateMixin<CallsTab> {
  _StateStore(this.sipModel, TickerProvider vsync) {
    initTabs(vsync);
    isSipActive = sipModel.isActive;
    sipModel.addListener(_sipListener);
  }

  final SipModel sipModel;

  @observable
  TabController? _tabController;

  @override
  @computed
  TabController? get tabController => _tabController;

  @override
  @protected
  set tabController(TabController? value) => _tabController = value;

  @observable
  List<CallsTab> _tabs = [];

  @override
  @computed
  List<CallsTab> get tabs => _tabs;

  @override
  @protected
  set tabs(List<CallsTab> value) => _tabs = value;

  @observable
  bool _isSipActive = false;

  @computed
  bool get isSipActive => _isSipActive;

  @protected
  set isSipActive(bool value) => _isSipActive = value;

  @observable
  AppMasterUserDict _dictionary = AppMasterUserDict.empty;

  @computed
  AppMasterUserDict get dictionary => _dictionary;

  @protected
  set dictionary(AppMasterUserDict value) => _dictionary = value;

  @observable
  AppPhoneCallFilter _filter = AppPhoneCallFilter.empty;

  @computed
  AppPhoneCallFilter get filter => _filter;

  @protected
  set filter(AppPhoneCallFilter value) => _filter = value;

  @observable
  bool _isPhoneCalling = false;

  @computed
  bool get isPhoneCalling => _isPhoneCalling;

  @protected
  set isPhoneCalling(bool value) => _isPhoneCalling = value;

  @override
  JsonListPreference<CallsTab> get savedTabs => callsTabs;

  @action
  Future<void> reload(BuildContext context) async {
    try {
      tabs[stackIndex(context)].refresh();
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  void showPhoneCallError(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ошибка звонка'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Не удалось совершить вызов'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ок'),
              onPressed: () async {
                Navigator.pop(context, 'Canceled');
              },
            ),
          ],
        );
      },
    );
  }

  @action
  Future<AppPhoneCallFilter> showFilter(BuildContext context) async {
    final filter = tabs[stackIndex(context)].filter as AppPhoneCallFilter;
    final update =
        await Navigator.of(context).pushNamed(CallFilterScreen.routeName,
            arguments: CallFilterScreenArgs(
              // dictionary: dictionary,
              filter: tabs[stackIndex(context)].filter as AppPhoneCallFilter,
              tabName: filter.name,
            )) as AppPhoneCallFilter?;
    if (update != null) {
      final hasUpdate = update != tabs[stackIndex(context)].filter;
      if (hasUpdate) {
        tabs[stackIndex(context)].filter = update;
        tabs[stackIndex(context)].pageController.refresh();
      }
    }
    return filter;
  }

  @action
  Future<void> editTabs(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => _FilterList(
        tabs: tabs,
        onChange: onTabsChange,
        dictionary: dictionary,
      ),
    );
  }

  @action
  void _sipListener() {
    isSipActive = sipModel.isActive;
  }

  @override
  void dispose() {
    sipModel.removeListener(_sipListener);
    super.dispose();
  }
}

class AppCallsScreen extends StatelessWidget implements AppTabViewScreen {
  AppCallsScreen({super.key});

  static const String routeName = '/calls_screen';

  @override
  String get route => routeName;

  @override
  String get filterRoute => CallFilterScreen.routeName;

  @override
  String get detailsRoute => CallDetails.routeName;
  @override
  final tickerKey = GlobalKey<TabContainerState>(
    debugLabel: 'tickerKey_AppCallsScreen',
  );

  @override
  Widget build(BuildContext context) {
    return TabContainer(
      key: tickerKey,
      child: Provider<_State>(
        create: (ctx) => _State(
          context.read<SipModel>(),
          tickerKey.currentState!.vsync,
        ),
        builder: (ctx, child) => const _Content(),
        dispose: (ctx, state) => state.dispose(),
      ),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: const Text('Звонки'),
        actions: [
          AppIcons.edit.fabButton(
            onPressed: () => _State.of(context).editTabs(context),
          )
        ],
      ),
      drawer: const AppBarDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabSelector(
            controller: _State.of(context).tabController,
            tabs: _State.of(context).tabs,
            tabsStream: _State.of(context).tabsSub,
          ),
          Expanded(
            child: TabBarView(
              controller: _State.of(context).tabController,
              children: [..._State.of(context).tabs.map(_Tab.new)],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.tab, {super.key});

  final CallsTab tab;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      controller: tab.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Observer(builder: (context) {
                      return Text(
                        '${tab.name.value} (${tab.total.value})',
                        style: AppTextStyle.boldHeadLine.style(context),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  AppIcons.filter.fabButton(
                    onPressed: () => _State.of(context).showFilter(context),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () => _State.of(context).reload(context),
        child: PagedListView<int, AppPhoneCall>.separated(
          pagingController: tab.pageController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 8),
          builderDelegate: PagedChildBuilderDelegate<AppPhoneCall>(
            itemBuilder: (context, item, index) => _CallItem(
              item,
              key: ValueKey<String>('${item.id}_$index'),
            ),
            noItemsFoundIndicatorBuilder: noItemsInListBuilder(context),
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ),
    );
  }
}

class _CallItem extends StatefulWidget {
  const _CallItem(this.call, {super.key});

  final AppPhoneCall call;

  @override
  State<_CallItem> createState() => _CallItemState();
}

class _CallItemState extends State<_CallItem> with TickerProviderStateMixin {
  late final AppPhoneCall call;
  late final AnimationController _controller;
  late final Animation<double> expandAnimation;
  bool showRecord = false;

  @override
  void initState() {
    call = widget.call;
    _controller = AnimationController(
      value: showRecord ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
    super.initState();
  }

  void recordToggle() {
    setState(() {
      showRecord = !showRecord;
    });
    if (showRecord) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget get typeIcon {
    final rotation = call.type == AppPhoneCallType.outgoing ? 2 : 0;
    final color = call.status.isSuccess ? AppColors.green : AppColors.red;
    return RotatedBox(
      quarterTurns: rotation,
      child: AppIcons.callArrow.iconColored(
        iconSize: 12,
        color: AppSplitColor.custom(
          primary: AppColors.black,
          secondary: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AppMaterialBox(
        borderSide: const BorderSide(
          color: AppColors.violetLightDark,
        ),
        child: InkWell(
          onTap: () {
            withLoadingIndicator(() async {
              final details =
                  await PhoneCallsRepository().getCallDetails(call.id);
              unawaited(
                Navigator.of(context).pushNamed(
                  CallDetails.routeName,
                  arguments: CallDetailsArgs(details),
                ),
              );
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    typeIcon,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm:ss', 'ru')
                                .format(call.createdAt.toLocal()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.regularSubHeadline.style(
                              context,
                              AppColors.violetLight,
                            ),
                          ),
                          Text(
                            call.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTextStyle.regularSubHeadline.style(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (call.recordUrl != null &&
                        call.recordUrl?.path.isNotEmpty == true) ...[
                      _RecordToggle(
                        show: showRecord,
                        onChange: recordToggle,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (call.incomingPhone.isNotEmpty)
                      CallButton(
                        phone: call.incomingPhone,
                        isSipActive: _State.of(context).isSipActive,
                        onMakeCall: _State.of(context).sipModel.makeCall,
                        onTryCall: () async {
                          if (_State.of(context).isPhoneCalling) return;
                          _State.of(context).isPhoneCalling = true;
                          await Future.delayed(const Duration(seconds: 15), () {
                            _State.of(context).isPhoneCalling = false;
                          });
                        },
                      )
                  ],
                ),
                if (call.recordUrl?.path.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  SizeTransition(
                    sizeFactor: expandAnimation,
                    child: AppAudioPlayer(
                      call.recordUrl!,
                      isActive: showRecord,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          AppIcons.callLong.iconColored(
                            color: AppSplitColor.green(),
                            iconSize: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDuration(call.duration),
                            style: AppTextStyle.regularHeadline.style(
                              context,
                              AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Flexible(
                      child: Row(
                        children: [
                          AppIcons.callWait.iconColored(
                            color: AppSplitColor.red(),
                            iconSize: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDuration(call.waitsec),
                            style: AppTextStyle.regularHeadline.style(
                              context,
                              AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordToggle extends StatelessWidget {
  const _RecordToggle({
    required this.onChange,
    required this.show,
  });

  final VoidCallback onChange;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildTapToCloseFab(context),
        _buildTapToOpenFab(context),
      ],
    );
  }

  Widget _buildTapToCloseFab(BuildContext context) {
    return AppIcons.voiceRecord.fabButton(
      color: AppSplitColor.custom(
        primary: AppColors.black,
        secondary: AppColors.violet,
      ),
      onPressed: onChange,
      size: const Size.square(40),
    );
  }

  Widget _buildTapToOpenFab(BuildContext context) {
    return IgnorePointer(
      ignoring: show,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          show ? 0.7 : 1.0,
          show ? 0.7 : 1.0,
          1,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: show ? 0.0 : 1.0,
          curve: const Interval(0.25, 1, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: AppIcons.voiceRecord.fabButton(
            color: AppSplitColor.violet(),
            onPressed: onChange,
            size: const Size.square(40),
          ),
        ),
      ),
    );
  }
}
