import 'package:contacts/contacts.dart';
import 'package:core/core.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';
import 'package:preference/preference.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart'; // import 'package:sip/sip.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

final _dialScale = DoublePreference(
  key: const PreferenceKey(module: 'app', component: 'dial', name: 'scale'),
  defaultValue: 1,
);

class DialPadPageRouter extends OldPageRouterAbstract {
  const DialPadPageRouter(
    super.screen, {
    super.key,
    this.isFullScreen = false,
  });

  final bool isFullScreen;

  @override
  String getInitialRoute() => DialPadPage.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.dialpadNavigationKey];
}

class DialPadPage extends StatefulWidget {
  const DialPadPage({
    this.topPageController,
    this.isFullScreen = false,
    super.key,
  });

  static const String routeName = '/dial_pad';

  final PageController? topPageController;
  final bool isFullScreen;

  @override
  State<DialPadPage> createState() => _DialPadPageState();
}

class _DialPadPageState extends State<DialPadPage> {
  static const _minScale = .7;
  static const _maxScale = 1.3;
  double scale = _dialScale.value;

  bool _isCalling = false;

  void upScale() {
    if ((scale + .1) <= _maxScale) {
      setState(() {
        _dialScale.value = scale = scale += .1;
      });
    }
  }

  void downScale() {
    if ((scale - .1) >= _minScale) {
      setState(() {
        _dialScale.value = scale = scale -= .1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFullScreen
          ? AppToolbar(
              title: const Text('Телефон'),
              actions: [
                IconButton(
                  onPressed: downScale,
                  icon: const Icon(
                    Icons.text_decrease,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: upScale,
                  icon: const Icon(
                    Icons.text_increase,
                    size: 24,
                  ),
                ),
              ],
            )
          : null,
      drawer: widget.isFullScreen && !Navigator.of(context).canPop()
          ? const AppBarDrawer()
          : null,
      body: SafeArea(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListenableBuilder(
        listenable: context.read<SipModel>(),
        builder: (context, _) {
          final sipModel = context.read<SipModel>();
          return DefaultTextStyle.merge(
            style: AppTextStyle.regularCaption.style(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DialPad(
                enableDtmf: true,
                outputMask: '************',
                hint: '',
                copyToClipboard: false,
                buttonType: ButtonType.circle,
                dialOutputTextColor: AppColors.white,
                hideDialButton: sipModel.callState !=
                        SipModel.PJSIP_INV_STATE_NULL &&
                    sipModel.callState != SipModel.PJSIP_INV_STATE_DISCONNECTED,
                makeCall: (number) async {
                  if (_isCalling || number.length < 3) {
                    return;
                  }
                  setState(() {
                    _isCalling = true;
                  });
                  await sipModel.makeCall(
                    number.replaceAll('+', ''),
                    isManualCalling: true,
                  );
                  Future.delayed(const Duration(seconds: 5), () {
                    setState(() {
                      _isCalling = false;
                    });
                  });
                },
                additionalButton: Center(
                  child: AppIcons.contacts.fabButton(
                    color: AppSplitColor.custom(
                      primary: AppColors.white,
                      secondary: Colors.transparent,
                    ),
                    size: Size.square(68 * scale),
                    onPressed: () => Navigator.maybeOf(context)
                        ?.pushNamed(AppContacts.routeName),
                  ),
                ),
                buttonScale: scale,
              ),
            ),
          );
        });
  }
}
