import 'package:audio_player/audio_player.dart';
import 'package:core/core.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'call_details.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.call);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.call);

  final AppPhoneCall call;

  @action
  void dispose() {}
}

class CallDetailsArgs {
  const CallDetailsArgs(this.call);

  final AppPhoneCall call;
}

class CallDetails extends StatelessWidget {
  const CallDetails(this.args, {super.key});

  static const String routeName = '/call_details';

  final CallDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(args.call),
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
      appBar: AppToolbar(
        title: Text('Вызов #${_State.of(context).call.id}'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, isPinned) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _Details(_State.of(context).call),
            ),
          )
        ],
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Обращения',
                  style: AppTextStyle.regularHeadline.style(
                    context,
                    AppColors.violetLight,
                  ),
                ),
              ),
            ),
            if (_State.of(context).call.orders.isNotEmpty)
              for (final order in _State.of(context).call.orders)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: AppMaterialBox(
                      key: ValueKey('call_order_${order.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.order_number != null) ...[
                              Text(
                                '#${order.order_number}',
                                style:
                                    AppTextStyle.regularHeadline.style(context),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (order.time?.isNotEmpty == true) ...[
                              IconWithTextRow(
                                text: order.time!,
                                textColor: AppColors.red,
                                leading: AppIcons.clock.iconColored(
                                  color: AppSplitColor.red(),
                                  iconSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (order.statusBadge != null) ...[
                              IconWithTextRow(
                                text: order.statusBadge!.text,
                                textColor: order.statusBadge!.color,
                                leading: AppIcons.status.iconColored(
                                  color: AppSplitColor.custom(
                                    primary: order.statusBadge!.color,
                                    secondary: order.statusBadge!.color
                                        .withOpacity(.2),
                                  ),
                                  iconSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (order.technique_name?.isNotEmpty == true) ...[
                              IconWithTextRow(
                                text: order.technique_name!,
                                leading: AppIcons.chip.iconColored(
                                  color: AppSplitColor.cyan(),
                                  iconSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (order.district?.isNotEmpty == true) ...[
                              IconWithTextRow(
                                text: order.district!,
                                leading: AppIcons.map.iconColored(
                                  color: AppSplitColor.violet(),
                                  iconSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (order.client_name?.isNotEmpty == true) ...[
                              IconWithTextRow(
                                text: order.client_name!,
                                leading: AppIcons.user.iconColored(
                                  color: AppSplitColor.violet(),
                                  iconSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (order.infoForMasterPrevent?.isNotEmpty ==
                                true) ...[
                              Text(
                                order.infoForMasterPrevent!,
                                style: AppTextStyle.regularSubHeadline
                                    .style(context),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (order.defect?.isNotEmpty == true) ...[
                              Text(
                                order.defect!,
                                style: AppTextStyle.regularSubHeadline.style(
                                  context,
                                  AppColors.violetLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Обращения отсутствуют',
                    style: AppTextStyle.regularCaption.style(
                      context,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _Details extends StatefulWidget {
  const _Details(this.call, {super.key});

  final AppPhoneCall call;

  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> with TickerProviderStateMixin {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('dd.MM.yyyy HH:mm:ss', 'ru')
              .format(call.createdAt.toLocal()),
          style: AppTextStyle.regularSubHeadline.style(context),
        ),
        const SizedBox(height: 16),
        IconWithTextRow(
          text: call.status.title,
          textColor: AppColors.green,
          leading: typeIcon,
        ),
        const SizedBox(height: 16),
        IconWithTextRow(
          text: call.name,
          leading: AppIcons.user.iconColored(
            color: AppSplitColor.violet(),
            iconSize: 12,
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 24),
        if (call.recordUrl != null &&
            call.recordUrl?.path.isNotEmpty == true) ...[
          _RecordToggle(
            show: showRecord,
            onChange: recordToggle,
          ),
          const SizedBox(width: 8),
        ],
        if (call.incomingPhone.isNotEmpty)
          ListenableBuilder(
            listenable: context.read<SipModel>(),
            builder: (context, child) {
              final sip = context.read<SipModel>();
              return CallButton(
                phone: call.incomingPhone,
                isSipActive: sip.isActive,
                onMakeCall: sip.makeCall,
                onTryCall: () {
                  showMessage(
                    context,
                    message: 'SIP клиент не доступен',
                    prefixIcon: AppIcons.callWait.widget(),
                    type: AppMessageType.error,
                  );
                },
              );
            },
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
      ],
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
