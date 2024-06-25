import 'package:dictionary/dictionary.dart';
import 'package:json_reader/json_reader.dart';

abstract class AdditionalOrder {
  const AdditionalOrder({
    required this.id,
    required this.clientName,
    required this.themId,
    required this.defect,
  });

  final int id;
  final String clientName;
  final int? themId;
  final String defect;

  Map<String, dynamic> toJson();
}

class AdditionalOrderInfo extends AdditionalOrder {
  const AdditionalOrderInfo._({
    required super.id,
    required super.clientName,
    required super.themId,
    required super.defect,
    required this.phone,
    required this.additionalPhones,
    required this.cityId,
    required this.cityName,
    required this.district,
    required this.street,
    required this.building,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.techniqueId,
    required this.techniqueName,
    required this.themName,
    required this.options,
  });

  factory AdditionalOrderInfo.fromJson(JsonReader json) {
    final _options = json.containsKey('options')
        ? AdditionalOrderOptions.fromJson(json['options'])
        : AdditionalOrderOptions.empty;

    return AdditionalOrderInfo._(
      id: json['original_order_id'].asInt(),
      clientName: json['client_name'].asString(defaultValue: '-'),
      phone: json['phone'].asString(),
      additionalPhones: json['additional_phone'].asListOf<String>(),
      cityId: json['city'].asInt(),
      cityName: json['city_name'].asString(),
      district: json['district'].asString(),
      street: json['street'].asString(),
      building: json['building'].asString(),
      apartment: json['apartment'].asString(),
      entrance: json['entrance'].asString(),
      floor: json['floor'].asString(),
      techniqueId: json['technique'].asInt(),
      techniqueName: json['technique_name'].asString(),
      themId: json['them'].asInt(),
      themName: json['them_name'].asString(),
      defect: json['defect'].asString(defaultValue: '-'),
      options: _options,
    );
  }

  AdditionalOrderInfo copyWith({
    String? defect,
  }) =>
      AdditionalOrderInfo._(
        id: id,
        clientName: clientName,
        phone: phone,
        additionalPhones: additionalPhones,
        cityId: cityId,
        cityName: cityName,
        district: district,
        street: street,
        building: building,
        apartment: apartment,
        entrance: entrance,
        floor: floor,
        techniqueId: techniqueId,
        techniqueName: techniqueName,
        themId: themId,
        themName: themName,
        defect: defect ?? this.defect,
        options: options,
      );

  static const empty = AdditionalOrderInfo._(
    id: -1,
    clientName: '',
    phone: '',
    additionalPhones: [],
    cityId: -1,
    cityName: '',
    district: '',
    street: '',
    building: '',
    apartment: '',
    entrance: '',
    floor: '',
    techniqueId: -1,
    techniqueName: '',
    themId: -1,
    themName: '',
    defect: '',
    options: AdditionalOrderOptions.empty,
  );

  @override
  Map<String, dynamic> toJson() => {
        'original_order_id': id,
        if (clientName.isNotEmpty) 'client_name': clientName,
        if (phone.isNotEmpty) 'phone': phone,
        'additional_phone': additionalPhones.isNotEmpty
            ? additionalPhones.map((e) => e.toString()).toList()
            : [],
        'city': cityId,
        if (cityName.isNotEmpty) 'city_name': cityName,
        if (district.isNotEmpty) 'district': district,
        if (street.isNotEmpty) 'street': street,
        if (building.isNotEmpty) 'building': building,
        if (apartment.isNotEmpty) 'apartment': apartment,
        if (entrance.isNotEmpty) 'entrance': entrance,
        if (floor.isNotEmpty) 'floor': floor,
        'technique': techniqueId,
        if (techniqueName.isNotEmpty) 'technique_name': techniqueName,
        'them': themId,
        if (themName.isNotEmpty) 'them_name': themName,
        if (defect.isNotEmpty) 'defect': defect,
      };

  final String phone;
  final List<String> additionalPhones;
  final int cityId;
  final String cityName;
  final String district;
  final String street;
  final String building;
  final String apartment;
  final String entrance;
  final String floor;
  final int techniqueId;
  final String techniqueName;
  final String themName;
  final AdditionalOrderOptions options;
}

class AdditionalOrderData extends AdditionalOrder {
  const AdditionalOrderData({
    required super.id,
    required super.clientName,
    required super.themId,
    required super.defect,
    required this.additionalPhone,
    required this.cityId,
    required this.district,
    required this.street,
    required this.building,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.techniqueId,
    required this.latitude,
    required this.longitude,
  });

  factory AdditionalOrderData.fromJson(JsonReader json) => AdditionalOrderData(
        id: json['original_order_id'].asInt(),
        clientName: json['customer_name'].asString(defaultValue: '-'),
        themId: json['them'].asInt(),
        defect: json['defect'].asString(defaultValue: '-'),
        additionalPhone: json['additional_phone'].asString(),
        cityId: json['city_id'].asInt(),
        district: json['district'].asString(),
        street: json['street'].asString(),
        building: json['building'].asString(),
        apartment: json['apartment'].asString(),
        entrance: json['entrance'].asString(),
        floor: json['floor'].asString(),
        techniqueId: json['technique'].asInt(),
        latitude: json['latitude'].asDouble(),
        longitude: json['longitude'].asDouble(),
      );

  AdditionalOrderData copyWith({
    String? defect,
    String? additionalPhone,
    double? latitude,
    double? longitude,
  }) =>
      AdditionalOrderData(
        id: id,
        clientName: clientName,
        themId: themId,
        defect: defect ?? this.defect,
        additionalPhone: additionalPhone ?? this.additionalPhone,
        cityId: cityId,
        district: district,
        street: street,
        building: building,
        apartment: apartment,
        entrance: entrance,
        floor: floor,
        techniqueId: techniqueId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  @override
  Map<String, dynamic> toJson() => {
        'original_order_id': id,
        'customer_name': clientName,
        'additional_phone': additionalPhone.isNotEmpty ? additionalPhone : null,
        'city_id': cityId,
        'district': district.isNotEmpty ? district : null,
        'street': street,
        'building': building,
        'apartment': apartment.isNotEmpty ? apartment : null,
        'entrance': entrance.isNotEmpty ? entrance : null,
        'floor': floor.isNotEmpty ? floor : null,
        'them': themId,
        'technique': techniqueId,
        'defect': defect,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

  final String additionalPhone;
  final int? cityId;
  final String district;
  final String street;
  final String building;
  final String apartment;
  final String entrance;
  final String floor;
  final int? techniqueId;
  final double latitude;
  final double longitude;
}

/// Словарь по доп заказу
/// TODO заменить на глобальный словарь
class AdditionalOrderOptions {
  const AdditionalOrderOptions({
    this.cities = const {},
    this.techniques = const {},
    this.themes = const {},
  });

  factory AdditionalOrderOptions.fromJson(JsonReader json) =>
      AdditionalOrderOptions(
        cities: DictMapper.jsonMapMapper(json['cities']),
        techniques: DictMapper.jsonMapMapper(json['techniques']),
        themes: DictMapper.jsonMapMapper(json['themes']),
      );

  final DictChapter cities;
  final DictChapter techniques;
  final DictChapter themes;

  static const empty = AdditionalOrderOptions();
}
