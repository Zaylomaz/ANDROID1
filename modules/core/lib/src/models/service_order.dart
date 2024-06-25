// ignore_for_file: lines_longer_than_80_chars

import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:json_reader/json_reader.dart';

/// Модель статуса заказа СЦ
@immutable
class StatusBadge {
  const StatusBadge({
    required this.color,
    required this.secondaryColor,
    required this.status,
    required this.text,
  });

  factory StatusBadge.fromJson(JsonReader json) => StatusBadge(
        color: json['color'].asColor(),
        secondaryColor: json['secondary_color'].asColor(),
        status: json['status'].asInt(),
        text: json['text_status'].asString(),
      );
  final Color color;
  final Color secondaryColor;
  final int status;
  final String text;
}

/// Заказ СЦ
@immutable
class ServiceOrder {
  const ServiceOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.company,
    required this.master,
    required this.serviceMaster,
    required this.technicType,
    required this.technicBrand,
    required this.technicModel,
    required this.technicSerial,
    required this.technicBiosPass,
    required this.technicPowerSupply,
    required this.technicVisualDefects,
    required this.technicBodyDefects,
    required this.technicUsbCondition,
    required this.technicIsUncovered,
    required this.technicHasWaterDamage,
    required this.technicHasBattery,
    required this.technicComplectation,
    required this.date,
    required this.clientName,
    required this.clientPhone,
    required this.clientAdditionalPhone,
    required this.clientCity,
    required this.clientDistrict,
    required this.clientStreet,
    required this.clientHouse,
    required this.clientApartment,
    required this.clientEntrance,
    required this.clientFloor,
    required this.damageFromClient,
    required this.damageFromOperator,
    required this.commentFromMaster,
    required this.commentFromOperator,
    required this.orderComment,
    required this.callDate,
    required this.amount,
    required this.photos,
    required this.actPhoto,
    required this.checkPhoto,
  });

  factory ServiceOrder.fromJson(JsonReader json) {
    DateTime? _dateMapper(JsonReader date) {
      try {
        return json.asDateTime();
      } catch (e) {
        try {
          return DateFormat('yyyy-MM-dd').parse(date.asString(), true);
        } catch (e) {
          return null;
        }
      }
    }

    bool getBoolFromString(String value) {
      if (value == 'true') return true;
      if (value == 'false') return false;
      return false;
    }

    return ServiceOrder(
      id: json['id'].asInt(),
      orderNumber: json['order_number'].asString(),
      status: json['status'].asInt(),
      company: json['company_id'].asString(),
      master: json['master_id'].asString(),
      serviceMaster: json['sc_master_id'].asString(),
      technicType: json['technique'].asString(),
      technicBrand: json['brand'].asString(),
      technicModel: json['model'].asString(),
      technicSerial: json['serial_number'].asString(),
      technicBiosPass: json['bios_password'].asString(),
      technicPowerSupply: getBoolFromString(json['charger'].asString()),
      technicVisualDefects: json['visual_defects'].asString(),
      technicBodyDefects: getBoolFromString(json['cracks_faults'].asString()),
      technicUsbCondition:
          getBoolFromString(json['integrity_usb_ports'].asString()),
      technicIsUncovered: getBoolFromString(json['autopsy_traces'].asString()),
      technicHasWaterDamage:
          getBoolFromString(json['flooding_marks'].asString()),
      technicHasBattery:
          getBoolFromString(json['battery_availability'].asString()),
      technicComplectation: json['equipment'].asString(),
      date: _dateMapper(json['date']),
      clientName: json['client_name'].asString(),
      clientPhone: json['phone'].asString(),
      clientAdditionalPhone: json['additional_phone']
          .asList()
          .map((e) => e.asString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      clientCity: json['city_id'].asString(),
      clientDistrict: json['district'].asString(),
      clientStreet: json['street'].asString(),
      clientHouse: json['building'].asString(),
      clientApartment: json['apartment'].asString(),
      clientEntrance: json['entrance'].asString(),
      clientFloor: json['floor'].asString(),
      damageFromClient: json['declared_defect'].asString(),
      damageFromOperator: json['defect'].asString(),
      commentFromMaster: json['master_comment'].asString(),
      commentFromOperator: json['operator_comment'].asString(),
      orderComment: json['order_comment'].asString(),
      callDate: _dateMapper(json['date_to_done']),
      amount: json['order_sum'].asInt(),
      photos: json['photos'].asListOf<String>(),
      actPhoto: json['photo_act_of_takeaway_technique'].asString(),
      checkPhoto: json['check_photo'].asString(),
    );
  }

  final int id;
  final String orderNumber;
  final int status;
  final String company;
  final String master;
  final String serviceMaster;

  final String technicType;
  final String technicBrand;
  final String technicModel;
  final String technicSerial;
  final String technicBiosPass;
  final String technicVisualDefects;
  final String technicComplectation;
  final bool technicPowerSupply;
  final bool technicBodyDefects;
  final bool technicUsbCondition;
  final bool technicIsUncovered;
  final bool technicHasWaterDamage;
  final bool technicHasBattery;

  final DateTime? date;

  final String clientName;
  final String clientPhone;
  final List<String> clientAdditionalPhone;
  final String clientCity;
  final String clientDistrict;
  final String clientStreet;
  final String clientHouse;
  final String clientApartment;
  final String clientEntrance;
  final String clientFloor;

  final String damageFromClient;
  final String damageFromOperator;
  final String commentFromMaster;
  final String commentFromOperator;
  final String orderComment;
  final DateTime? callDate;
  final int amount;
  final List<String> photos;
  final String actPhoto;
  final String checkPhoto;
}

/// Заказ СЦ упрощенная модель для списка
@immutable
class ServiceOrderLite {
  const ServiceOrderLite({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.date,
    required this.callDate,
    required this.clientCity,
    required this.serviceMaster,
    required this.amount,
    required this.createDate,
    required this.assignDate,
    required this.company,
    required this.orderComment,
    required this.clientName,
    required this.clientPhone,
    required this.clientAdditionalPhone,
    required this.commentFromOperator,
    required this.clientFullAddress,
    required this.defect,
    required this.technique,
    required this.brand,
    required this.model,
  });

  factory ServiceOrderLite.fromJson(JsonReader json) {
    DateTime _dateMapper(JsonReader date) {
      try {
        return json.asDateTime();
      } catch (e) {
        try {
          return DateFormat('yyyy-MM-dd').parse(date.asString(), true);
        } catch (e) {
          return DateTime.utc(0);
        }
      }
    }

    return ServiceOrderLite(
      id: json['id'].asInt(),
      orderNumber: json['order_number'].asInt(),
      status: StatusBadge.fromJson(json['status_badge']),
      date: _dateMapper(json['date']),
      callDate: _dateMapper(json['date_to_done']),
      createDate: _dateMapper(json['created_at']),
      assignDate: _dateMapper(json['client_at']),
      company: json['company_name'].asString(),
      serviceMaster: json['sc_master_name'].asString(),
      clientName: json['client_name'].asString(),
      clientPhone: json['phone'].asString(),
      clientAdditionalPhone:
          json['additional_phones'].asList().map((e) => e.asString()).toList(),
      clientCity: json['city_name'].asString(),
      clientFullAddress: json['full_address'].asString(),
      commentFromOperator: json['operator_comment'].asString(),
      orderComment: json['order_comment'].asString(),
      amount: json['order_sum'].asInt(),
      defect: json['defect'].asString(),
      technique: json['technique'].asString(),
      brand: json['brand'].asString(),
      model: json['model'].asString(),
    );
  }

  bool get callDateFail => DateTime.now().difference(callDate).inMinutes > 0;

  final int id;
  final int orderNumber;
  final StatusBadge status;
  final DateTime date;
  final DateTime createDate;
  final DateTime assignDate;
  final DateTime callDate;
  final String clientCity;
  final String serviceMaster;
  final int amount;
  final String company;
  final String brand;
  final String model;
  final String orderComment;
  final String clientName;
  final String clientPhone;
  final List<String> clientAdditionalPhone;
  final String commentFromOperator;
  final String clientFullAddress;
  final String defect;
  final String technique;
}

/// Фильтр заказов СЦ детальная документация в [AppFilter]
@immutable
class ServiceOrderFilter extends AppFilter {
  const ServiceOrderFilter({
    required this.queryText,
    required this.orderNumber,
    required this.phone,
    required this.master,
    required this.serviceMaster,
    required this.company,
    required this.city,
    required this.technicType,
    required this.dateFrom,
    required this.dateTo,
    this.status = const [],
    this.name,
  });

  factory ServiceOrderFilter.fromJson(JsonReader json) => ServiceOrderFilter(
        queryText: json['query_text'].asString(),
        orderNumber: json['order_number'].asString(),
        phone: json['phone'].asString(),
        master: json['master_id'].asListOf<String>(),
        serviceMaster: json['sc_master_id'].asListOf<String>(),
        company: json['company_id'].asListOf<String>(),
        city: json['city_id'].asListOf<String>(),
        technicType: json['technique'].asListOf<String>(),
        status: json['status'].asListOf<int>(),
        dateFrom: json['date_start'].asDateTime(),
        dateTo: json['date_end'].asDateTime(),
        name: json['name'].asString(),
      );

  @override
  List<Object?> get props => [
        queryText,
        orderNumber,
        phone,
        status,
        master,
        serviceMaster,
        company,
        city,
        technicType,
        dateFrom,
        dateTo,
        name,
      ];

  static final empty = ServiceOrderFilter(
    queryText: '',
    orderNumber: '',
    phone: '',
    master: const [],
    serviceMaster: const [],
    company: const [],
    city: const [],
    technicType: const [],
    dateFrom: DateTime.fromMillisecondsSinceEpoch(0),
    dateTo: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  bool get isEmpty =>
      queryText.isEmpty &&
      orderNumber.isEmpty &&
      phone.isEmpty &&
      master.isEmpty &&
      serviceMaster.isEmpty &&
      company.isEmpty &&
      city.isEmpty &&
      status.isEmpty &&
      technicType.isEmpty &&
      dateFrom == DateTime.fromMillisecondsSinceEpoch(0) &&
      dateTo == DateTime.fromMillisecondsSinceEpoch(0);

  ServiceOrderFilter clearStatus() => ServiceOrderFilter(
        queryText: queryText,
        orderNumber: orderNumber,
        phone: phone,
        master: master,
        serviceMaster: serviceMaster,
        company: company,
        city: city,
        technicType: technicType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  @override
  ServiceOrderFilter copyWith({
    String? queryText,
    String? orderNumber,
    String? phone,
    List<int>? status,
    List<String>? master,
    List<String>? serviceMaster,
    List<String>? company,
    List<String>? city,
    List<String>? technicType,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? name,
  }) =>
      ServiceOrderFilter(
        queryText: queryText ?? this.queryText,
        orderNumber: orderNumber ?? this.orderNumber,
        phone: phone ?? this.phone,
        status: (status ?? this.status).toSet().toList(),
        master: (master ?? this.master).toSet().toList(),
        serviceMaster: (serviceMaster ?? this.serviceMaster).toSet().toList(),
        company: (company ?? this.company).toSet().toList(),
        city: (city ?? this.city).toSet().toList(),
        technicType: (technicType ?? this.technicType).toSet().toList(),
        dateFrom: dateFrom ?? this.dateFrom,
        dateTo: dateTo ?? this.dateTo,
        name: name ?? this.name,
      );

  @override
  Map<String, dynamic> toJson({bool dateToMemory = false}) => {
        if (queryText.isNotEmpty) 'query_text': queryText,
        if (orderNumber.isNotEmpty) 'order_number': orderNumber,
        if (phone.isNotEmpty) 'phone': phone,
        if (status.isNotEmpty) 'status': status,
        if (master.isNotEmpty) 'master_id': master,
        if (serviceMaster.isNotEmpty) 'sc_master_id': serviceMaster,
        if (company.isNotEmpty) 'company_id': company,
        if (city.isNotEmpty) 'city_id': city,
        if (technicType.isNotEmpty) 'technique': technicType,
        if (dateFrom.millisecondsSinceEpoch > 0)
          'date_start': dateToMemory
              ? dateFrom.millisecondsSinceEpoch
              : DateFormat('yyyy-MM-dd').format(dateFrom),
        if (dateTo.millisecondsSinceEpoch > 0)
          'date_end': dateToMemory
              ? dateTo.millisecondsSinceEpoch
              : DateFormat('yyyy-MM-dd').format(dateTo),
        if (name?.isNotEmpty == true) 'name': name,
      };

  @override
  Map<String, dynamic> toQueryParams() => {
        if (queryText.isNotEmpty) 'query_text': queryText,
        if (orderNumber.isNotEmpty) 'order_number': orderNumber,
        if (phone.isNotEmpty) 'phone': phone,
        if (dateFrom.isAfter(DateTime(2000))) 'date_start': dateFrom,
        if (dateTo.isAfter(DateTime(2000))) 'date_end': dateTo,
        if (status.isNotEmpty) 'status[]': status,
        if (master.isNotEmpty) 'master_id[]': master,
        if (serviceMaster.isNotEmpty) 'sc_master_id[]': serviceMaster,
        if (company.isNotEmpty) 'company_id[]': company,
        if (city.isNotEmpty) 'city_id[]': city,
        if (technicType.isNotEmpty) 'technique[]': technicType,
      };

  @override
  String get filterName => name ?? '';

  final String queryText;
  final String orderNumber;
  final String phone;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? name;
  final List<int> status;
  final List<String> master;
  final List<String> serviceMaster;
  final List<String> company;
  final List<String> city;
  final List<String> technicType;
}

/// Словарь по СЦ
/// TODO заменить на глобальный словарь
class ServiceOrderDict extends AbstractDictionary {
  const ServiceOrderDict({
    required this.statuses,
    required this.masters,
    required this.serviceMasters,
    required this.cities,
    required this.technique,
    required this.companies,
    required this.statusesToShowAddress,
  });

  factory ServiceOrderDict.fromJson(JsonReader json) => ServiceOrderDict(
        statuses: DictMapper.jsonMapMapper(json['statuses']),
        masters: DictMapper.jsonMapMapper(json['master_id']),
        serviceMasters: DictMapper.jsonMapMapper(json['sc_master_id']),
        cities: DictMapper.jsonMapMapper(json['city_id']),
        technique: DictMapper.jsonMapMapper(json['technique']),
        companies: DictMapper.jsonMapMapper(json['company_id']),
        statusesToShowAddress: json['statuses_to_show_address'].asListOf<int>(),
      );

  static const empty = ServiceOrderDict(
    statuses: {},
    masters: {},
    serviceMasters: {},
    cities: {},
    technique: {},
    companies: {},
    statusesToShowAddress: [],
  );

  String getStatusName(int id) => statuses[id] ?? '';

  String getMasterName(int id) => masters[id] ?? '';

  String getServiceMasterName(int id) => serviceMasters[id] ?? '';

  String getCityName(int id) => cities[id] ?? '';

  String getTechniqueName(int id) => technique[id] ?? '';

  String getCompanyName(int id) => companies[id] ?? '';

  final DictChapter statuses;
  final DictChapter masters;
  final DictChapter serviceMasters;
  final DictChapter cities;
  final DictChapter technique;
  final DictChapter companies;
  final List<int> statusesToShowAddress;

  @override
  List<Object?> get props => [
        statuses,
        masters,
        serviceMasters,
        cities,
        technique,
        companies,
        statusesToShowAddress,
      ];
}
