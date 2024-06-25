import 'dart:ui';

import 'package:core/core.dart';

/// Принудительное обновление приложения
/// TODO проверить дизайн модалки

final ValueNotifier<bool> isUpdateAppDialogShowing = ValueNotifier<bool>(false);

Future<void> showUpdateAppDialog(BuildContext context) async {
  const androidUrl =
      '''https://play.google.com/store/apps/details?id=com.rempc.app''';
  isUpdateAppDialogShowing.value = true;
  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(.5),
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) {
      return MediaQuery.removePadding(
        context: context,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.06),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 32),
                          const Text(
                            'Необходимо обновление',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              height: 24 / 20,
                              letterSpacing: .38,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '''Версия устарела, необходимо обновить приложение в Play Market''',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              height: 20 / 15,
                              letterSpacing: .24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 42),
                          ElevatedButton(
                            onPressed: () {
                              launchUrlString(
                                androidUrl,
                                mode: LaunchMode.externalNonBrowserApplication,
                              );
                            },
                            child: const Text('Обновить'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  isUpdateAppDialogShowing.value = false;
}
