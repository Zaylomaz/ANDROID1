import 'dart:async';

import 'package:back_blocker/back_blocker.dart';
import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

/*
* Прелоадер для всего приложения
* вызов метода лоадера закрывает весь экран перекрытием с крутилкой
* использовать только метод [withLoadingIndicator]
* всё остальное произойдет автоматом
* */

class _LoaderScaffold extends StatelessWidget {
  const _LoaderScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black.withOpacity(.5),
        body: Center(
          child: Container(
            height: 54,
            width: 54,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(27)),
              color: AppColors.blackContainer,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  blurRadius: 10,
                  offset: Offset(0, 1),
                )
              ],
            ),
            child: const AppLoadingIndicator(),
          ),
        ),
      ),
    );
  }
}

@Deprecated('Use `withLoadingIndicator` instead')
void showLoadingDialog() {
  _loaderController.showLoader();
  BackBlocker().disableBackButton();
}

void hideLoadingDialog() {
  _loaderController.closeLoader();
  BackBlocker().enableBackButton();
}

int _loadingCount = 0;

/// Враппер для [Future]
/// до конца выполнения асинхронного метода будет показан прелоадер
///
/// вызывать именно так
/// await withLoadingIndicator(() async { });
Future<T> withLoadingIndicator<T>(FutureOr<T> Function() fn) async {
  void stopLoadingDialog() {
    if (--_loadingCount == 0) {
      hideLoadingDialog();
    }
  }

  if (_loadingCount == 0) {
    // ignore: deprecated_member_use_from_same_package
    showLoadingDialog();
  }
  ++_loadingCount;
  try {
    final result = await fn();
    stopLoadingDialog();
    return result;
  } catch (_) {
    stopLoadingDialog();
    rethrow;
  }
}

late _LoaderOverlayController _loaderController;

/// Виджет глобального лоадера
class Loader extends StatelessWidget {
  const Loader({
    required this.navigatorKey,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return _LoaderOverlay(
      navigatorKey: navigatorKey,
      onLoaderInitialized: (controller) {
        _loaderController = controller;
      },
      child: child,
    );
  }
}

abstract class _LoaderOverlayController {
  void showLoader();

  void closeLoader();
}

class _LoaderOverlay extends StatefulWidget {
  const _LoaderOverlay({
    required this.navigatorKey,
    required this.child,
    required this.onLoaderInitialized,
    Key? key,
  }) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;
  final ValueChanged<_LoaderOverlayController> onLoaderInitialized;

  @override
  _LoaderOverlayState createState() => _LoaderOverlayState();
}

class _LoaderOverlayState extends State<_LoaderOverlay>
    implements _LoaderOverlayController {
  late OverlayEntry? _overlayEntry;

  @override
  void closeLoader() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void showLoader() {
    _overlayEntry = _overlayEntryBuilder();
    try {
      widget.navigatorKey.currentState?.overlay!.insert(_overlayEntry!);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      maintainState: true,
      builder: (context) {
        return const _LoaderScaffold();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget.onLoaderInitialized(this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    closeLoader();
    super.dispose();
  }
}
