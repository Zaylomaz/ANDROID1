// ignore_for_file: comment_references

import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:uikit/uikit.dart';

// Результат снимка камеры
typedef OnCameraResult = Function(XFile?);

/// Забирает изображение
/// с файловой системы
/// с камеры устройства
/// с камеры [CameraAwesome] плагина
mixin AppImagePicker {
  /// Предоставляет выбор источника для изображения
  /// возвращает [XFile] или Null если диалог был закрыт или файл не выбран
  static Future<XFile?> showSelectDialog(BuildContext context,
          [NavigatorState? navigator]) =>
      showDialog(
          context: context,
          useRootNavigator: true,
          builder: (context) {
            final _navigator =
                navigator ?? Navigator.of(context, rootNavigator: true);
            final sources = AppFileDestination.values.map((e) =>
                e.widget(onPressed: () async {
                  switch (e) {
                    case AppFileDestination.gallery:
                      final file =
                          await AppImagePicker.pickImage(ImageSource.gallery);
                      return _navigator.pop(file);
                    case AppFileDestination.camera:
                      final file = await AppImagePicker.getCameraImage(context);
                      return _navigator.pop(file);
                  }
                }));
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Выбор файла',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.boldHeadLine.style(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '''Выберите фото из вашей галереи или воспользуйтесь камерой''',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.regularSubHeadline.style(context),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        sources.first,
                        const SizedBox(width: 16),
                        sources.last,
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton.red(
                        text: 'Отмена',
                        onPressed: Navigator.maybeOf(context)?.maybePop,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });

  /// Забирает изображение исключительно используя камеру
  /// возвращает [XFile] или Null если диалог был закрыт или файл не выбран
  static Future<XFile?> getCameraImage(BuildContext context) async {
    try {
      if (ImagePicker().supportsImageSource(ImageSource.camera)) {
        return pickImage(ImageSource.camera);
      } else {
        return getImage(context);
      }
    } catch (e, s) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, s));
      return getImage(context);
    }
  }

  /// Забирает изображение исключительно используя [CameraAwesome] плагин
  /// возвращает [XFile] или Null если диалог был закрыт или файл не выбран
  static Future<XFile?> getImage(BuildContext context) async {
    return showDialog<XFile?>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: _CameraView((file) {
              Navigator.of(context).pop(file);
            }),
          );
        });
  }

  /// Забирает файл исключительно плагином [ImagePicker]
  /// Забирает из галлереи или делает новый снимок
  static Future<XFile?> pickImage(ImageSource source) async {
    XFile? file;
    final pickedFile = await ImagePicker().pickImage(
      source: source,
    );
    if (pickedFile != null) {
      file = pickedFile;
    }
    return file;
  }
}

/// Виджет визуального представления для [AppImagePicker.getCameraImage]
/// Реализован согласно документации к [CameraAwesome]
class _CameraView extends StatefulWidget {
  const _CameraView(this.onResult);

  final OnCameraResult onResult;

  @override
  State<_CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<_CameraView> {
  FlashMode? _flashMode;
  late PhotoCameraState _state;

  void setAutoFlashMode(CameraState state) {
    if (_flashMode != null) return;
    if (state.sensorConfig.flashMode != FlashMode.auto) {
      state.sensorConfig.switchCameraFlash();
      Future.delayed(
        const Duration(milliseconds: 300),
        () => setAutoFlashMode(state),
      );
    } else {
      _flashMode = state.sensorConfig.flashMode;
    }
  }

  Future<void> onPhoto(BuildContext context) async {
    await _state.takePhoto().then((path) {
      widget.onResult(XFile(
        path,
        name: 'rempc_camera_photo_${DateTime.now().toIso8601String()}',
      ));
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: [
          Positioned.fill(
            child: CameraAwesomeBuilder.custom(
              builder: (cameraState, _, __) {
                return cameraState.when(
                  onPreparingCamera: (state) =>
                      const Center(child: AppLoadingIndicator()),
                  onPhotoMode: (state) {
                    _state = state;
                    setAutoFlashMode(state);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            right: 0,
                            child: Material(
                              color: AppColors.blackContainer,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(23),
                              ),
                              elevation: 6,
                              child: AwesomeFlashButton(
                                state: state,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              saveConfig: SaveConfig.photoAndVideo(
                photoPathBuilder: () async {
                  final dir = await getApplicationDocumentsDirectory();
                  return '${dir.path}/photo/${DateTime.now().millisecondsSinceEpoch}.jpg';
                },
                videoPathBuilder: () async {
                  final dir = await getApplicationDocumentsDirectory();
                  return '${dir.path}/photo/${DateTime.now().millisecondsSinceEpoch}.mp4';
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AppIcons.camera.iconButton(
              splitColor: AppSplitColor.red(),
              onPressed: () => onPhoto(context),
              size: const Size.square(40),
            ),
          ),
        ],
      ),
    );
  }
}
