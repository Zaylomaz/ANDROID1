import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:shake/shake.dart';

/// Детектор тряски
/// открывает DEBUG меню в DEV билде
class ShakeQaScreenOpener extends StatefulWidget {
  const ShakeQaScreenOpener({
    required this.navigatorKey,
    required this.screenPath,
    required this.child,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;
  final String screenPath;

  @override
  _ShakeQaScreenOpenerState createState() => _ShakeQaScreenOpenerState();
}

class _ShakeQaScreenOpenerState extends State<ShakeQaScreenOpener> {
  ShakeDetector? _detector;
  bool _qaScreenShown = false;

  @override
  void initState() {
    super.initState();
    if (Environment<AppConfig>.instance().isDebug) {
      _detector = ShakeDetector.autoStart(
        shakeSlopTimeMS: 2000,
        onPhoneShake: _onShake,
      );
    }
  }

  // ignore: prefer_void_to_null
  Null _onShake() {
    if (Environment<AppConfig>.instance().isProd) return;
    HapticFeedback.heavyImpact();
    if (!_qaScreenShown) {
      _qaScreenShown = true;
      widget.navigatorKey.currentState
          ?.pushNamed(
        widget.screenPath,
      )
          .then((value) {
        _qaScreenShown = false;
      }, onError: (_) {
        _qaScreenShown = false;
      });
    }
  }

  @override
  void dispose() {
    _detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
