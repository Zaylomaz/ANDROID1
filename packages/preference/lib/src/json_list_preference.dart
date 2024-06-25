import 'json_preference.dart';
import 'preference.dart';

class JsonListPreference<T> extends JsonPreference<List<T>> {
  JsonListPreference({
    required PreferenceKey key,
    List<T> defaultValue = const [],
    required PreferenceJsonEncoder<T> itemEncoder,
    required PreferenceJsonDecoder<T> itemDecoder,
    PreferenceKey? oldKey,
  }) : super(
          key: key,
          defaultValue: defaultValue,
          encoder: (items) => items.map(itemEncoder).toList(),
          decoder: (items) => (items as List).map(itemDecoder).toList(),
          oldKey: oldKey,
        );
}
