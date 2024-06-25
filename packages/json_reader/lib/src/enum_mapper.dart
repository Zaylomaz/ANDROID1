import 'package:quiver/collection.dart';

typedef EnumMapperCallback<T, E> = T Function(E value);

class EnumMapper<E, T> {
  EnumMapper(List<E> values, EnumMapperCallback<T, E> mapper) {
    _map = BiMap()
      ..addEntries(
        values.map(
          (v) => MapEntry(v, mapper(v)),
        ),
      );
  }

  late BiMap<E, T> _map;

  T fromEnum(E value) => _map[value]!;
  E? toEnum(T value) => _map.inverse[value];
}
