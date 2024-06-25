import 'package:json_reader/json_reader.dart';

/// Модель времени закрытия заказа
enum TimeSlot {
  s10('10:00-11:00'),
  s12('12:00-13:00'),
  s14('14:00-15:00'),
  s16('16:00-17:00'),
  s18('18:00-19:00'),
  s20('20:00-21:00'),
  undefined('');

  const TimeSlot(this.slot);

  /// Mapper
  factory TimeSlot.fromJson(JsonReader json) => TimeSlot.values.firstWhere(
        (e) => e.slot == json.asString(),
        orElse: () => TimeSlot.undefined,
      );

  final String slot;
}
