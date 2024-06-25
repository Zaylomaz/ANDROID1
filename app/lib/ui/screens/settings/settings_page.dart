import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_reader/json_reader.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'settings_page.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.sip);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.sip) {
    micVolume = sip.micVolume;
    speakerVolume = sip.speakerVolume;
    sip.getSipRingtone().then((value) => currentRingtone = value);
    sip.getSounds().then((value) {
      final json = JsonReader(value);
      sounds = json.asList().map(SipRingtone.fromJson).toList();
    });
  }

  static const platform = MethodChannel('helperService');

  final SipModel sip;

  final selectedSoundStream = BehaviorSubject<String>();

  @observable
  List<SipRingtone> _sounds = [];

  @computed
  List<SipRingtone> get sounds => _sounds;

  @protected
  set sounds(List<SipRingtone> value) => _sounds = value;

  @observable
  String _currentRingtone = 'ringtone_default';

  @computed
  String get currentRingtone => _currentRingtone;

  @protected
  set currentRingtone(String value) => _currentRingtone = value;

  @observable
  List<Map> _channels = [];

  @computed
  List<Map> get channels => _channels;

  @protected
  set channels(List<Map> value) => _channels = value;

  @observable
  Map<String, String?> _selectedSound = {};

  @computed
  Map<String, String?> get selectedSound => _selectedSound;

  @protected
  set selectedSound(Map<String, String?> value) => _selectedSound = value;

  @observable
  double _micVolume = .3;

  @computed
  double get micVolume => _micVolume;

  @protected
  set micVolume(double value) => _micVolume = value;

  @observable
  double _speakerVolume = .3;

  @computed
  double get speakerVolume => _speakerVolume;

  @protected
  set speakerVolume(double value) => _speakerVolume = value;

  @action
  void setMic(double value) {
    micVolume = (value * 10).roundToDouble() / 10;
    sip.micVolume = micVolume;
  }

  @action
  void setVolume(double value) {
    speakerVolume = (value * 10).roundToDouble() / 10;
    sip.speakerVolume = speakerVolume;
  }

  @action
  void playSound(String sound) {
    sip.playSound(sound);
  }

  @action
  Future<void> sendLogs() async {
    await withLoadingIndicator(() async {
      await platform.invokeMethod('getWorkerInfo');
    });
  }

  @action
  void setupRingtone(String id) {
    currentRingtone = id;
    sip.setupSipRingtone(id);
  }

  @action
  void dispose() {
    DeprecatedRepository().updateSettings(
      sip.micVolume,
      sip.speakerVolume,
    );
    sip
      ..updateVolumeSettings()
      ..stopSound();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings_page';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(Provider.of<SipModel>(context)),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessObserverWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Настройки'),
      ),
      drawer: Navigator.of(context).canPop() ? null : const AppBarDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppMaterialBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Голосовые вызовы',
                        style: AppTextStyle.boldHeadLine.style(
                          context,
                          AppColors.violetLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Гормкость микрофона',
                            style: AppTextStyle.regularHeadline.style(context),
                          ),
                          Text('${_State.of(context).micVolume}',
                              style: AppTextStyle.regularHeadline.style(
                                context,
                                AppColors.green,
                              )),
                        ],
                      ),
                    ),
                    SfSlider(
                      min: .3,
                      max: 6.5,
                      interval: .1,
                      value: _State.of(context).micVolume,
                      onChanged: (value) => _State.of(context).setMic(value),
                      activeColor: AppColors.green,
                      inactiveColor: AppColors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Гормкость динамика',
                            style: AppTextStyle.regularHeadline.style(context),
                          ),
                          Text(
                            '${_State.of(context).speakerVolume}',
                            style: AppTextStyle.regularHeadline.style(
                              context,
                              AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SfSlider(
                      min: .3,
                      max: 6.5,
                      interval: .1,
                      value: _State.of(context).speakerVolume,
                      onChanged: (value) => _State.of(context).setVolume(value),
                      activeColor: AppColors.green,
                      inactiveColor: AppColors.black,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    width: 2,
                    color: AppColors.blackContainer,
                  ),
                ),
                color: AppColors.black,
                child: Column(
                  children: [
                    AppMaterialBox(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Звук уведомлений',
                              style: AppTextStyle.boldHeadLine.style(
                                context,
                                AppColors.violetLight,
                              ),
                            ),
                            const Sounds(),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Ringtones(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AppMaterialBox(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Отправить логи',
                        style: AppTextStyle.boldHeadLine.style(
                          context,
                          AppColors.violetLight,
                        ),
                      ),
                      const Logs(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPageRouter extends OldPageRouterAbstract {
  const SettingsPageRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => SettingsPage.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.settingsNavigationKey];
}

class Sounds extends StatelessObserverWidget {
  const Sounds({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton.violet(
            onPressed: () =>
                AppSettings.openAppSettings(type: AppSettingsType.notification),
            text: 'Натроить уведомления',
          ),
        ],
      ),
    );
  }
}

class Ringtones extends StatelessObserverWidget {
  const Ringtones({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: AppDropdownField<String>(
              label: 'Звук рингтона',
              items: _State.of(context).sounds.toMultiselect,
              value: _State.of(context).currentRingtone,
              onChange: (sound) {
                _State.of(context).sip.stopSound();
                if (sound != null) {
                  _State.of(context).setupRingtone(sound);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          AppIcons.chevronRight.iconButton(
            splitColor: AppSplitColor.violet(),
            onPressed: _State.of(context).sip.playRingtone,
          ),
        ],
      ),
    );
  }
}

class Logs extends StatelessObserverWidget {
  const Logs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton.cyan(
            onPressed: _State.of(context).sendLogs,
            text: 'Отправить данные',
          ),
          if (Environment<AppConfig>.instance().isDebug && kDebugMode) ...[
            const SizedBox(height: 16),
            PrimaryButton.greenInverse(
              text: 'Вызвать нативный тестовый екран',
              onPressed: () {
                _StateStore.platform.invokeMethod('showTestScreen');
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton.greenInverse(
              text: 'Проверить кеш словарей',
              onPressed: () async {
                // await AppDictionary().loadData();
                final testData =
                    AppDictionary().getByKey(AppDictionary().keys.first);
                debugPrint('TEST DATA => ${testData.cachedData}');
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton.greenInverse(
              text: 'Получить приложения',
              onPressed: () async {
                final apps =
                    await _StateStore.platform.invokeMethod('testAction');
                debugPrint('TEST DATA => $apps');
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton.greenInverse(
              text: 'Отправить контакты',
              onPressed: () async {
                await _StateStore.platform.invokeMethod('syncContacts');
              },
            ),
          ],
        ],
      ),
    );
  }
}

class SipRingtone {
  const SipRingtone._(this.title, this.file);

  factory SipRingtone.fromJson(JsonReader json) => SipRingtone._(
        json['title'].asString(),
        json['file'].asString(),
      );

  final String title;
  final String file;
}

extension SipRingtoneListExt on List<SipRingtone> {
  Iterable<MapEntry<String, String>> get toMultiselect =>
      map((e) => MapEntry(e.file, e.title));
}
