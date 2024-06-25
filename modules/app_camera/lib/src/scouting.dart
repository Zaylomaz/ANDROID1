import 'package:api/api.dart';
import 'package:app_camera/app_camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

part 'scouting.g.dart';

class _State extends _StateStore with _$_State {
  _State() : super();

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore() {
    /// проверит наличие не загруженных файлов
    notUploadedFiles = ScoutingStorage().getList;
    ScoutingRepository().uploadingStream.add(notUploadedFiles.toUpload);
    if (notUploadedFiles.isNotEmpty) {
      /// покажет не загруженные файлы
      Future.delayed(const Duration(seconds: 1), panelController.open);
    }
  }

  final panelController = PanelController();

  /// режим вспышки камеры
  @observable
  FlashMode? _flashMode;
  @computed
  FlashMode? get flashMode => _flashMode;
  @protected
  set flashMode(FlashMode? value) => _flashMode = value;

  /// камера согласно документации к [CameraAwesome]
  @observable
  PhotoCameraState? _state;
  @computed
  PhotoCameraState? get state => _state;
  @protected
  set state(PhotoCameraState? value) => _state = value;

  /// файлы которые не загрузились по какой-то причине
  @observable
  List<ScoutingFile> _notUploadedFiles = [];
  @computed
  List<ScoutingFile> get notUploadedFiles => _notUploadedFiles;
  @protected
  set notUploadedFiles(List<ScoutingFile> value) => _notUploadedFiles = value;

  /// установка режима вспышки на [FlashMode.auto]
  /// проверит текущий режим и если он не [FlashMode.auto]
  /// уйдет в рекурсию
  @action
  void setAutoFlashMode(CameraState state) {
    /// подразумевает что [FlashMode.auto] уже включен
    if (flashMode != null) return;

    /// проверяет текущее состояние режима вспышки
    if (state.sensorConfig.flashMode != FlashMode.auto) {
      /// меняет режим работы вспышки
      state.sensorConfig.switchCameraFlash();

      /// рекурсивно себя проверит
      Future.delayed(
        const Duration(milliseconds: 300),
        () => setAutoFlashMode(state),
      );
    } else {
      /// установит режим [FlashMode.auto]
      flashMode = state.sensorConfig.flashMode;
    }
  }

  /// Делает фото
  /// Показывает превью
  /// Отправляет на сервер
  @action
  Future<void> onPhotoButtonPressed(
    BuildContext context,
    _PhotoButtonType type,
  ) async {
    /// делает фото
    final path = await _State.of(context).state!.takePhoto();

    /// забирает геопозицию
    final location = await getAndroidPosition();

    /// формирует файл для бека
    final file = ScoutingFile.fromPath(
      type.name,
      path,
      location.latitude.toString(),
      location.longitude.toString(),
      isFake: location.isFake,
    );

    /// показывает превью и в результате назначит переменную [upload]
    final upload = await Navigator.of(context).pushNamed(
      ScoutingResultScreen.routeName,
      arguments: ScoutingResultScreenArgs(file),
    ) as bool?;

    /// загружаем при [upload == true]
    if (upload == true) {
      try {
        /// добавляем в очередь
        ScoutingStorage().addFile(file);

        /// загружаем файл
        await ScoutingStorage().upload(context, file);
        if (panelController.isPanelOpen == false) {
          await panelController.open();
        }

        /// радуемся
        await showMessage(context,
            message: 'Успешно загружено',
            type: AppMessageType.success,
            prefixIcon: AppIcons.checked.widget(color: AppColors.white));
      } on TimeoutException catch (_) {
        /// обработка ошибки [TimeoutException]
        await showMessage(
          context,
          message: 'Превышено время выполнения запроса',
          type: AppMessageType.error,
          prefixIcon: AppIcons.fail.widget(color: AppColors.white),
        );
      }
    } else {
      /// удаляем при [upload != true]
      await file.asFile.delete();
    }
  }

  @action
  void dispose() {
    state?.dispose();
  }
}

/// Экран фотоочетов
/// Делает фото
/// Отправляет фото на сервер
/// Может повторно выгружать фото, если они по какой-то
/// причине не были загружены
class ScoutingBody extends StatelessWidget {
  const ScoutingBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(),
      builder: (ctx, _) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlidingUpPanel(
        minHeight: 160,
        maxHeight: 450,
        controller: _State.of(context).panelController,
        backdropEnabled: true,
        body: Stack(
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: CameraAwesomeBuilder.custom(
                builder: (cameraState, _, __) {
                  return cameraState.when(
                    onPreparingCamera: (state) =>
                        const Center(child: CircularProgressIndicator()),
                    onPhotoMode: (state) {
                      _State.of(context).setAutoFlashMode(state);
                      _State.of(context).state = state;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              right: 0,
                              child: Material(
                                color: AppColors.blackContainer,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                )),
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
                    return '${dir.path}/scouting/${DateTime.now().millisecondsSinceEpoch}.jpg';
                  },
                  videoPathBuilder: () async {
                    final dir = await getApplicationDocumentsDirectory();
                    return '${dir.path}/scouting/${DateTime.now().millisecondsSinceEpoch}.mp4';
                  },
                ),
              ),
            ),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        panelBuilder: (controller) => Material(
          color: AppColors.blackContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 64,
                decoration: const BoxDecoration(
                  color: AppColors.violetLight,
                  borderRadius: BorderRadius.all(
                    Radius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 1,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  children:
                      _PhotoButtonType.values.map(_PhotoButton.new).toList(),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<ScoutingFileUpload>>(
                initialData: ScoutingRepository().uploadingStream.value,
                stream: ScoutingRepository().uploadingStream,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data?.isNotEmpty == true &&
                      _State.of(context).panelController.isPanelOpen == false) {
                    _State.of(context).panelController.open();
                  }
                  if (data?.isNotEmpty == true) {
                    data?.sort((a, b) => b.sent.compareTo(a.sent));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Очередь загрузки',
                            style: AppTextStyle.regularCaption.style(
                              context,
                              AppColors.violetLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            controller: controller,
                            itemCount: data?.length ?? 0,
                            itemBuilder: (context, i) => ListTile(
                              leading: AppListTileLeading(
                                child: data![i].status.icon,
                              ),
                              title: Text(
                                data[i].fileName,
                                style: const TextStyle(
                                  color: AppColors.white,
                                ),
                              ),
                              subtitle: SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  minHeight: 4,
                                  value: data[i].sent / data[i].total,
                                  color: AppColors.green,
                                  backgroundColor: data[i].sent > 0
                                      ? AppColors.white
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            separatorBuilder: (context, i) =>
                                const SizedBox(height: 8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: PrimaryButton.violet(
                            onPressed: () =>
                                ScoutingStorage().uploadAll(context),
                            text: 'Повторить загрузку',
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PhotoButtonType {
  glue,
  enemy,
  clear,
  friendly;

  String get title {
    switch (this) {
      case _PhotoButtonType.enemy:
        return 'Конкурент';
      case _PhotoButtonType.clear:
        return 'Чисто';
      case _PhotoButtonType.friendly:
        return 'Дружеский';
      case _PhotoButtonType.glue:
        return 'Самоклейка';
    }
  }
}

class _PhotoButton extends StatelessObserverWidget {
  const _PhotoButton(
    this.type, {
    super.key,
  });

  final _PhotoButtonType type;

  @override
  Widget build(BuildContext context) {
    if (_State.of(context).state == null) return const SizedBox.shrink();
    switch (type) {
      case _PhotoButtonType.enemy:
        return PrimaryButton.red(
          onPressed: () =>
              _State.of(context).onPhotoButtonPressed(context, type),
          text: type.title,
        );
      case _PhotoButtonType.clear:
        return PrimaryButton.cyan(
          onPressed: () =>
              _State.of(context).onPhotoButtonPressed(context, type),
          text: type.title,
        );
      case _PhotoButtonType.friendly:
        return PrimaryButton.green(
          onPressed: () =>
              _State.of(context).onPhotoButtonPressed(context, type),
          text: type.title,
        );
      case _PhotoButtonType.glue:
        return PrimaryButton.violet(
          onPressed: () =>
              _State.of(context).onPhotoButtonPressed(context, type),
          text: type.title,
        );
    }
  }
}
