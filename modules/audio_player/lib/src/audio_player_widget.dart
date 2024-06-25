import 'dart:async';
import 'dart:math' as math;

import 'package:audio_player/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uikit/uikit.dart';

/// внедерение функции воспроизведения аудиофайлов

class AppAudioPlayer extends StatefulWidget {
  /// аудиоплеер для воспроизведения записей звонков
  /// или любой аудиозаписи
  const AppAudioPlayer(this.media, {super.key, this.isActive = true});

  /// сслыка на аудиофайл
  final Uri media;

  /// активен ли плеер
  final bool isActive;

  @override
  State<AppAudioPlayer> createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  /// инстанс плеера
  Player? player;

  /// стрим возвращающий общую длину файла в секундах
  StreamSubscription<Duration>? durationListener;

  /// стрим возвращающий текущую секунду воспроизведения
  StreamSubscription<Duration>? positionListener;

  /// стрим возвращающий состояние воспроизведения
  StreamSubscription<bool>? stateListener;

  /// подписка для изменения состояния кнопки воспроизведения
  Subject<bool> isPlayingSub = BehaviorSubject<bool>.seeded(false);

  /// длина файла в секундах
  Duration duration = Duration.zero;

  /// текущая позиция
  Duration position = Duration.zero;

  @override
  void initState() {
    if (widget.isActive) {
      init();
    }
    super.initState();
  }

  /// запуск плеера и переопределение подписок
  void init() {
    player = Player();
    durationListener = player!.stream.duration.listen((event) {
      duration = event;
    });
    positionListener = player!.stream.position.listen((event) {
      position = event;
    });
    stateListener = player!.stream.playing.listen(isPlayingSub.add);
    player!.open(
      Media(
        widget.media.toString(),
      ),
      play: false,
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant AppAudioPlayer oldWidget) {
    if (oldWidget.isActive != widget.isActive) {
      if (!widget.isActive) {
        _dispose();
      } else {
        init();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void _dispose() {
    player?.dispose();
  }

  @override
  void dispose() {
    _dispose();
    positionListener?.cancel();
    stateListener?.cancel();
    durationListener?.cancel();
    isPlayingSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.violetDark,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  progressBar(),
                  progressSeconds(),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            playPauseButton(),
          ],
        ),
      ),
    );
  }

  /// билдер кнопки
  /// слушает стрим состояния плеера
  Widget playPauseButton() => StreamBuilder<bool>(
      stream: isPlayingSub.stream,
      initialData: false,
      builder: (context, snapshot) {
        void _action() {
          player?.playOrPause();
        }

        final icon =
            snapshot.data == true ? AppIcons.pause : AppIcons.chevronRight;
        return icon.iconButton(
          color: AppColors.violet,
          onPressed: _action.call,
          size: const Size.square(24),
        );
      });

  /// билдер прогрессбара
  Widget progressBar() => StreamBuilder<Duration>(
        stream: player?.stream.position,
        initialData: Duration.zero,
        builder: (context, snapshot) {
          return SizedBox(
            height: 8,
            child: SfSlider(
              min: 0,
              max: duration.inSeconds == 0 ? 1 : duration.inSeconds,
              stepSize: .1,
              value: snapshot.data!.inSeconds,
              activeColor: AppColors.violet,
              inactiveColor: AppColors.black,
              thumbShape: _ThumbShape(),
              trackShape: _TrackShape(),
              onChangeStart: (value) {
                player?.pause();
              },
              onChangeEnd: (value) {
                player?.seek(Duration(seconds: (value as double).toInt()));
                player?.play();
              },
              onChanged: (_) {},
            ),
          );
        },
      );

  /// билдер секундного указателя
  Widget progressSeconds() => StreamBuilder(
      stream: player?.stream.position,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position),
                style: AppTextStyle.regularCaption
                    .style(context, AppColors.violetLight)
                    .copyWith(fontSize: 10),
              ),
              Text(
                formatDuration(duration),
                style: AppTextStyle.regularCaption
                    .style(context)
                    .copyWith(fontSize: 10),
              ),
            ],
          ),
        );
      });
}

/// переопределение дизайна прогрессбара
class _ThumbShape extends SfThumbShape {
  @override
  Size getPreferredSize(_) => const Size.square(8);
}

/// переопределение дизайна прогрессбара
class _TrackShape extends SfTrackShape {
  @override
  Rect getPreferredRect(RenderBox parentBox, dynamic themeData, Offset offset,
      {bool? isActive}) {
    final overlayPreferredSize = Size(8, parentBox.size.width);
    const thumbPreferredSize = Size.square(8);
    const tickPreferredSize = Size.square(8);
    double maxRadius;
    maxRadius = math.max(overlayPreferredSize.width / 2,
        math.max(thumbPreferredSize.width / 2, tickPreferredSize.width / 2));
    final double maxTrackHeight = math.max(4, 4);
    final left = offset.dx + maxRadius;
    var top = offset.dy;
    if (isActive != null) {
      top += isActive ? (maxTrackHeight - 4) / 2 : (maxTrackHeight - 4) / 2;
    }
    final right = left + parentBox.size.width - (2 * maxRadius);
    final bottom =
        top + (isActive == null ? maxTrackHeight : (isActive ? 4 : 4));
    return Rect.fromLTRB(
        math.min(left, right), top, math.max(left, right), bottom);
  }
}
