import 'package:core/core.dart';
import 'package:flutter/services.dart';

/// Возвращает последнюю известную геопозицию юзера
/// с указанием подленности данных
Future<AppCoords> getAndroidPosition() async {
  try {
    const platform = MethodChannel('helperService');
    final result = await platform.invokeMethod('getCurrentGPSLocation');
    if (result != null) {
      return AppCoords(
        result['latitude'],
        result['longitude'],
        isFake: result['isFake'] as bool,
      );
    } else {
      return const AppCoords(0, 0);
    }
  } catch (e) {
    return const AppCoords(0, 0);
  }
}

Future<bool> isGPSEnabled() async {
  const platform = MethodChannel('helperService');
  final data = await platform.invokeMethod('isGPSEnabled');
  return data;
}

/// Добавление полезных свойств в класс
extension CoordsExt on Coords {
  bool get isEmpty => latitude == 0 && longitude == 0;

  String get googleMapsUrlString =>
      '''https://www.google.com/maps/search/?api=1&query=$latitude,$longitude''';

  Uri get googleMapsUri => Uri.parse(googleMapsUrlString);

  Future<bool> tryLaunch(BuildContext context) =>
      launchMap(context, location: this);
}

@immutable
class AppCoords implements Coords {
  const AppCoords(this.latitude, this.longitude, {this.isFake = false});

  @override
  final double latitude;
  @override
  final double longitude;
  final bool isFake;

  Map<String, dynamic> toJson() => {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'isFake': isFake ? 1 : 0,
      };
}
