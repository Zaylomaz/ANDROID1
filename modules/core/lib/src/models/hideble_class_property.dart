/*
* Интерфейс поля класса которое можно скрыть для отображения
*/

/// Абстрактный интерфейс
abstract class ObjectProperty<T> {
  const ObjectProperty();

  /// Поле
  abstract final T value;

  /// Доступность для UI
  abstract final bool availability;
}

/// Имплементация абстракции
class Property<T> implements ObjectProperty<T> {
  const Property({
    required this.value,
    required this.availability,
  });

  /// Конструктор доступного поля
  factory Property.available(T value) => Property<T>(
        value: value,
        availability: true,
      );

  /// Конструктор скрытого поля
  factory Property.hidden(T value) => Property<T>(
        value: value,
        availability: false,
      );

  @override
  final bool availability;

  @override
  final T value;
}

extension ObjectPropertyListExt on List<ObjectProperty> {
  /// Доступные поля в списке полей
  List<dynamic> get availableValues =>
      where((e) => e.availability == true).toList();
}

extension ObjExt on Object {
  /// Конвертирует любой объект в [ObjectProperty]
  Property<T> toObjectProperty<T>({bool availability = true}) =>
      Property(value: this as T, availability: availability);
}
