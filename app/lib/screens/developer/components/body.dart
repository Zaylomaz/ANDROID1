import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/ui/screens/splash_page.dart';
import 'package:uikit/uikit.dart';

class Body extends StatefulWidget {
  const Body(this.connectivity, {super.key});

  final AppConnectivityNotifier? connectivity;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String _cameraPermission = 'Unknown';
  String _geoPermission = 'Unknown';
  String _storagePermission = 'Unknown';
  String _microphonePermission = 'Unknown';
  String _notificationPermission = 'Unknown';
  String _internetAccess = 'Unknown';
  String location = '';
  List<RouteSettings> navigatorHistory = [];

  @override
  void initState() {
    super.initState();
    Future.wait([
      checkCameraPermission(),
      checkGeoPermission(),
      checkStoragePermission(),
      checkMicrophonePermission(),
      checkInternetConnection(),
      checkNotificationPermission(),
      getNavigatorHistory(),
    ]).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: AppTextStyle.regularHeadline.style(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Разрешения',
              style: AppTextStyle.boldHeadLine.style(
                context,
                AppColors.violet,
              ),
            ),
            Text('Camera access: $_cameraPermission'),
            Text('Geo access: $_geoPermission'),
            Text('File access: $_storagePermission'),
            Text('Microphone access: $_microphonePermission'),
            Text('Notification access: $_notificationPermission'),
            Text('Internet access: $_internetAccess'),
            const SizedBox(height: 15),
            Text(
              'Геолокация',
              style: AppTextStyle.boldHeadLine.style(
                context,
                AppColors.violet,
              ),
            ),
            Text('Lat,Lng: $location'),
            const SizedBox(height: 10),
            PrimaryButton.green(
                text: 'Получить локациию',
                onPressed: () async {
                  final data = await getAndroidPosition();
                  setState(() {
                    location = '${data.latitude}, ${data.longitude}';
                  });
                }),
            const SizedBox(height: 10),
            PrimaryButton.cyan(
              onPressed: () => ApiBuilder().showInspector(),
              text: 'История HTTP запросов',
            ),
            const SizedBox(height: 10),
            PrimaryButton.cyan(
              onPressed: () async {
                final log = SplashScreen.getLog();
                await showDialog(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: AppColors.black,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (var i = 0; i < log.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  log[i].event,
                                  style: AppTextStyle.regularHeadline
                                      .style(context),
                                ),
                                subtitle: Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                      text: DateFormat(
                                              'dd MMM yyyy - HH:mm:ss:ms', 'ru')
                                          .format(log[i].timestamp),
                                    ),
                                    if (i + 1 < log.length) ...[
                                      const TextSpan(text: '\n'),
                                      TextSpan(
                                          text:
                                              '''${log[i + 1].timestamp.difference(log[i].timestamp).inMilliseconds} ms'''),
                                    ],
                                  ]),
                                  style: AppTextStyle.regularCaption
                                      .style(context),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              text: 'Показать лог сплеш экрана',
            ),
            const SizedBox(height: 10),
            PrimaryButton.red(
              onPressed: () async {
                ApiStorage().accessToken = '';
                unawaited(Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                  SplashScreen.routeName,
                  (route) => false,
                ));
              },
              text: 'Логаут',
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: navigatorHistory.length,
                itemBuilder: (context, index) => ListTile(
                  onTap: () => Navigator.of(context).pushNamed(
                      navigatorHistory[index].name!,
                      arguments: navigatorHistory[index].arguments),
                  leading: CircleAvatar(
                    child: Text((index + 1).toString()),
                  ),
                  title: Text(
                    navigatorHistory[index].name ?? '-',
                    style: AppTextStyle.regularSubHeadline.style(context),
                  ),
                ),
                separatorBuilder: (context, index) => const Divider(
                  height: 8,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkInternetConnection() async {
    final connection = await widget.connectivity?.instance.checkConnectivity();
    _internetAccess = connection?.title ?? 'Unknown';
  }

  Future<void> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _cameraPermission = 'Granted';
    } else {
      _cameraPermission = 'Denied';
    }
  }

  Future<void> checkGeoPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      _geoPermission = 'Granted';
    } else {
      _geoPermission = 'Denied';
    }
  }

  Future<void> checkStoragePermission() async {
    var isGranted = false;
    final sdk = await getAndroidSDK();
    if (sdk < 30) {
      isGranted = await Permission.storage.status.isGranted;
    } else {
      isGranted = await Permission.photos.status.isGranted &&
          await Permission.videos.status.isGranted;
    }
    if (isGranted) {
      _storagePermission = 'Granted';
    } else {
      _storagePermission = 'Denied';
    }
  }

  Future<void> checkMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      _microphonePermission = 'Granted';
    } else {
      _microphonePermission = 'Denied';
    }
  }

  Future<void> checkNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      _notificationPermission = 'Granted';
    } else {
      _notificationPermission = 'Denied';
    }
  }

  Future<void> getNavigatorHistory() async {
    try {
      final history = AppRouter().history;
      navigatorHistory = history;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }
}
