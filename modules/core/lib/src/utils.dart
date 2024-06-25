import 'dart:io';

import 'package:core/core.dart';

export 'utils/device_info.dart';
export 'utils/form_validator.dart';
export 'utils/launch_map.dart';
export 'utils/loader.dart';
export 'utils/location_loader.dart';
export 'utils/shake_detector.dart';

extension XFileExtension on XFile {
  File toFile() => File(path);
}

extension BoolExt on bool {
  int asInt() => this ? 1 : 0;
}

extension StringExt on String {
  String toCamelCase() {
    final splitted = split('_');
    return [
      splitted.first,
      if (splitted.length > 1)
        splitted
            .getRange(1, splitted.length)
            .map((e) => e.replaceRange(0, 1, e[0].toUpperCase()))
            .join()
    ].join();
  }
}
