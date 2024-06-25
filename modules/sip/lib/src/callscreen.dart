import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:sip/sip.dart';
import 'package:sip/src/call_action_button.dart';
import 'package:uikit/uikit.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  static const String routeName = '/call_screen';

  @override
  CallScreenState createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  bool _showNumPad = false;
  String _timeLabel = '00:00';
  Timer? _timer;
  bool _audioMuted = false;
  bool _speakerOn = false;
  SipModel? _sipModel;
  bool _toggleSpeakerBusy = false;

  String get direction => 'OUTGOING';
  int _appendSeconds = 0;

  @override
  void initState() {
    super.initState();
    _sipModel?.isActiveCallScreen = true;
    _updateCallState();
  }

  Future<void> _updateCallState() async {
    const platform = MethodChannel('helperService');
    final result = await platform.invokeMethod('getCallScreenInfo');
    if (_timer == null && _sipModel != null && _sipModel!.callState == 5) {
      _startTimer();
    }
    if (result['callTimeSeconds'] != null) {
      _appendSeconds = result['callTimeSeconds'];
    }
    _speakerOn = result['isSpeaker'] ?? false;
    _audioMuted = result['isMuted'] ?? false;
    final duration = Duration(seconds: _appendSeconds);
    setState(() {
      _timeLabel = [duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshProvider();
  }

  void refreshProvider() {
    _sipModel = Provider.of<SipModel>(context);
    if (mounted) {
      _sipModel?.isActiveCallScreen = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _sipModel?.isActiveCallScreen = false;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final duration = Duration(seconds: timer.tick + _appendSeconds);
      if (mounted) {
        setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _backToDialPad() {
    _timer?.cancel();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  void _handleHangup() {
    const MethodChannel('helperService').invokeMethod('hangupCall');
    if (_timer?.isActive == true) {
      _timer?.cancel();
    }
    close();
  }

  Future<void> _handleAccept() async {
    const platform = MethodChannel('helperService');
    await platform.invokeMethod('acceptCall');
  }

  Future<void> _muteAudio() async {
    const platform = MethodChannel('helperService');
    if (_audioMuted) {
      setState(() {
        _audioMuted = false;
      });
      await platform.invokeMethod('unMuteCall');
    } else {
      setState(() {
        _audioMuted = true;
      });
      await platform.invokeMethod('muteCall');
    }
  }

  void _handleHold() {
    // if (_hold) {
    //   call!.unhold();
    // } else {
    //   call!.hold();
    // }
  }

  void _handleTransfer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter target to transfer.'),
          content: TextField(
            onChanged: (text) {
              setState(() {});
            },
            decoration: const InputDecoration(
              hintText: 'URI or Username',
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleDtmf(String tone) {
    debugPrint('Dtmf tone => $tone');
    // call!.sendDTMF(tone);
  }

  void _handleKeyPad() {
    setState(() {
      _showNumPad = !_showNumPad;
    });
  }

  Future<void> _toggleSpeaker() async {
    if (_toggleSpeakerBusy) return;
    _toggleSpeakerBusy = true;
    setState(() {
      _speakerOn = !_speakerOn;
    });
    const platform = MethodChannel('helperService');

    if (_speakerOn) {
      await platform.invokeMethod('speakerCallOn');
    } else {
      await platform.invokeMethod('speakerCallOff');
    }
    _toggleSpeakerBusy = false;
  }

  List<Widget> _buildNumPad() {
    final labels = [
      [
        {'1': ''},
        {'2': 'abc'},
        {'3': 'def'}
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'}
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'}
      ],
      [
        {'*': ''},
        {'0': '+'},
        {'#': ''}
      ],
    ];

    return labels
        .map((row) => Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: label.keys.first,
                          subTitle: label.values.first,
                          onPressed: () => _handleDtmf(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  Widget _buildActionButtons() {
    final hangupBtn = ActionButton(
      title: 'Завершить',
      onPressed: _handleHangup,
      icon: Icons.call_end,
      fillColor: Colors.red,
    );

    final hangupBtnInactive = ActionButton(
      title: 'hangup',
      onPressed: () {},
      icon: Icons.call_end,
      fillColor: Colors.grey,
    );

    final basicActions = <Widget>[];
    final advanceActions = <Widget>[];

    ///
    if (_sipModel?.callState == SipModel.PJSIP_INV_STATE_EARLY &&
        _sipModel?.isOutgoing == false) {
      basicActions
        ..add(ActionButton(
          title: 'Принять',
          fillColor: Colors.green,
          icon: Icons.phone,
          onPressed: _handleAccept,
        ))
        ..add(hangupBtn);
    } else {
      basicActions.add(hangupBtn);
    }

    advanceActions
      ..add(ActionButton(
        title: _audioMuted ? 'Микро. вкл.' : 'Микро. выкл.',
        icon: _audioMuted ? Icons.mic_off : Icons.mic,
        checked: _audioMuted,
        onPressed: _muteAudio,
      ))
      ..add(ActionButton(
        title: _speakerOn ? 'Динамик выкл.' : 'Динамик вкл.',
        icon: _speakerOn ? Icons.volume_off : Icons.volume_up,
        checked: _speakerOn,
        onPressed: _toggleSpeaker,
      ));

    final actionWidgets = <Widget>[];

    if (_showNumPad) {
      actionWidgets.addAll(_buildNumPad());
    } else {
      if (advanceActions.isNotEmpty) {
        actionWidgets.add(
          Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: advanceActions,
            ),
          ),
        );
      }
    }

    actionWidgets.add(
      Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: basicActions,
        ),
      ),
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: actionWidgets);
  }

  Widget _buildContent() {
    final sipModel = Provider.of<SipModel>(context);
    final statuses = {
      0: 'Статус неизвестен',
      1: 'Набор...',
      2: 'Входящий вызов',
      3: 'Вызов',
      4: 'Соединение...',
      5: 'Голосовой вызов',
      6: 'Завершен',
    };
    final currentStatus = statuses[sipModel.callState] ?? 'Голосовой вызов';
    if (_timer == null && sipModel.callState == 5) {
      _startTimer();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              currentStatus,
              style: AppTextStyle.boldLargeTitle.style(context),
            ),
          ),
        ),
        if (sipModel.getNames.isNotEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sipModel.getNames.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle.regularHeadline.style(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _timeLabel,
              style: AppTextStyle.boldTitle2.style(context),
            ),
          ),
        ),
        if (sipModel.getCities.isNotEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sipModel.getCities.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (sipModel.getAddresses.isNotEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sipModel.getAddresses.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (sipModel.getOrders.isNotEmpty) ...[
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                height: constraints.maxHeight,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: sipModel.getOrders.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (c, i) {
                    final it = sipModel.getOrders[i];
                    return AppMaterialBox(
                      borderSide: BorderSide(
                        color: it.statusBadge.color,
                        width: 2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconWithTextRow(
                              text: it.statusBadge.textStatus,
                              leading: AppIcons.status.iconColored(
                                color: AppSplitColor.custom(
                                  primary: it.statusBadge.color,
                                  secondary: AppColors.violetLightDark,
                                ),
                                iconSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconWithTextRow(
                              text: it.orderNumber.toString(),
                              leading: AppIcons.numberHash.iconColored(
                                iconSize: 16,
                                color: AppSplitColor.cyan(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconWithTextRow(
                              text: it.date.isNotEmpty ? it.date : '-',
                              leading: AppIcons.calendar.iconColored(
                                iconSize: 16,
                                color: AppSplitColor.yellow(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconWithTextRow(
                              text: it.address.isNotEmpty ? it.address : '-',
                              leading: AppIcons.location.iconColored(
                                iconSize: 16,
                                color: AppSplitColor.green(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconWithTextRow(
                              text: it.orderSum.toString().isNotEmpty
                                  ? it.orderSum.toString()
                                  : '-',
                              leading: AppIcons.check.iconColored(
                                iconSize: 16,
                                color: AppSplitColor.green(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: 320,
          child: _buildActionButtons(),
        ),
      ],
    );
  }

  void close() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((_sipModel?.isActiveCall ?? true) == false) {
      Future.delayed(const Duration(seconds: 3), close);
      if (_timer?.isActive == true) {
        _timer?.cancel();
      }
    }
    return Scaffold(
      appBar: const AppToolbar(
        leading: SizedBox.shrink(),
        title: Text('Вызов'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
      backgroundColor: AppColors.violetLightDark,
    );
  }
}
