export 'package:media_kit/media_kit.dart';

export 'src/audio_player_widget.dart';

/// переводит [Duration] в вид [00:00:00] час:минута:секунда
String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours.remainder(24));
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  if (duration.inHours > 0) {
    return '$hours:$minutes:$seconds:';
  } else if (duration.inMinutes > 0) {
    return '$minutes:$seconds';
  } else {
    return '00:$seconds';
  }
}
