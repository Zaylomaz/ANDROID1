import 'package:core/core.dart';
import 'package:dictionary/dictionary.dart';
import 'package:json_reader/json_reader.dart';

/// Соискатели
/// Модели для работы с соискателями

/// Поля в форме создания, редактирования и поиска
enum ApplicantFilterInputs {
  clientName('client_name'),
  phone('phone'),
  jobVacancy('job_vacancy'),
  age('age'),
  experience('experience'),
  specification('specification'),
  smartphone('smartphone'),
  email('email'),
  orderComment('order_comment'),
  status('status'),
  date('date'),
  time('time'),
  cityId('city_id'),
  district('district'),
  masterId('master_id'),
  undefined('');

  const ApplicantFilterInputs(this.backendName);

  factory ApplicantFilterInputs.fromJson(JsonReader json) =>
      ApplicantFilterInputs.values.firstWhere(
          (e) => e.backendName == json.asString(),
          orElse: () => ApplicantFilterInputs.undefined);

  final String backendName;

  /// Обязательные поля в форме
  bool get isRequired =>
      this == ApplicantFilterInputs.clientName ||
      this == ApplicantFilterInputs.phone;
}

extension ApplicantFilterInputsListExt on Iterable<ApplicantFilterInputs> {
  /// Поля о которых знает бекенд
  List<ApplicantFilterInputs> get backendValues =>
      where((e) => e != ApplicantFilterInputs.undefined).toList();

  /// Поля с значением "Строка"
  List<ApplicantFilterInputs> get stringValues => [
        ApplicantFilterInputs.clientName,
        ApplicantFilterInputs.phone,
        ApplicantFilterInputs.age,
        ApplicantFilterInputs.email,
        ApplicantFilterInputs.orderComment,
        ApplicantFilterInputs.district,
      ];

  /// Поля с числовым значением
  List<ApplicantFilterInputs> get intValues => [
        ApplicantFilterInputs.status,
        ApplicantFilterInputs.jobVacancy,
        ApplicantFilterInputs.cityId,
        ApplicantFilterInputs.specification,
        ApplicantFilterInputs.masterId,
      ];

  /// Поля логического смысла
  List<ApplicantFilterInputs> get boolValues => [
        ApplicantFilterInputs.smartphone,
        ApplicantFilterInputs.experience,
      ];

  /// Поля указания даты и времени
  List<ApplicantFilterInputs> get dateTimeValues => [
        ApplicantFilterInputs.date,
        ApplicantFilterInputs.time,
      ];
}

/// Модель для отправки формы на сервер
class EditApplicantBody {
  /// поля формы
  static final List<ApplicantFilterInputs> inputs =
      ApplicantFilterInputs.values.backendValues;

  static final stringValues = inputs.stringValues;
  static final intValues = inputs.intValues;
  static final boolValues = inputs.boolValues;

  /// валидатор полей возвращает [true]
  /// если поля соответствуют правилам валидации
  bool get isValid {
    /// проверка всех обязательных полей на присутствие в принципе
    for (final value in inputs) {
      if (!data.keys.contains(value) && value.isRequired) {
        return false;
      }
    }

    /// проверка всех обязательных полей с привидением к типу
    ///
    /// Тип [String] проверяется на то чтоб строка была не пуста
    ///
    /// Тип [int] и тип [bool] проверяется на наличие значения
    ///
    /// Тип [int] дополнительно проверяется на значение -1000
    /// Если -1000 то значение в селекторе не выбрано
    ///
    /// Тип дата и время не проверяется
    for (final key in stringValues) {
      if ((data[key] as String).trim().isEmpty && key.isRequired) {
        return false;
      }
    }

    for (final key in [...intValues, ...boolValues]) {
      if (data[key] == null && key.isRequired) {
        return false;
      }
    }
    for (final key in intValues) {
      if (data[key] == -1000 && key.isRequired) {
        return false;
      }
    }
    return true;
  }

  /// инициализация пустых данных
  Map<ApplicantFilterInputs, dynamic> data = {
    for (final key in inputs) key: null,
  };

  /// преобразует данные в формат читаемый бекендом
  Map<String, dynamic> toJson(BuildContext context) {
    final stringValues = data.keys.stringValues;
    final intValues = data.keys.intValues;
    final boolValues = data.keys.boolValues;
    return {
      for (final key in stringValues)
        if ((data[key] as String).isNotEmpty)
          key.backendName: data[key] as String,
      for (final key in intValues) key.backendName: data[key] as int?,
      for (final key in boolValues) key.backendName: data[key] as bool,
      if (data[ApplicantFilterInputs.date] != null)
        ApplicantFilterInputs.date.backendName:
            DateFormat('yyyy-MM-dd').format(data[ApplicantFilterInputs.date]),
      if (data[ApplicantFilterInputs.time] != null)
        ApplicantFilterInputs.time.backendName:
            (data[ApplicantFilterInputs.time] as TimeOfDay).format(context),
    };
  }
}

/// словарь достурных опций для фильтра Соискателей
/// TODO заменить на глобальный словарь
/// оставить только список [inputs]
class ApplicantFilterOptions extends AbstractDictionary {
  const ApplicantFilterOptions({
    this.companies = const {},
    this.jobVacancies = const {},
    this.statuses = const {},
    this.cities = const {},
    this.inputs = const [],
  });

  factory ApplicantFilterOptions.fromJson(JsonReader json) {
    return ApplicantFilterOptions(
      companies: DictMapper.jsonMapMapper(json['companies']),
      jobVacancies: DictMapper.jsonMapMapper(json['job_vacancies']),
      statuses: DictMapper.jsonMapMapper(json['statuses']),
      cities: DictMapper.jsonMapMapper(json['cities']),
      inputs: json['filter_inputs']
          .asList()
          .map(ApplicantFilterInputs.fromJson)
          .toList(),
    );
  }

  final DictChapter companies;
  final DictChapter jobVacancies;
  final DictChapter statuses;
  final DictChapter cities;
  final List<ApplicantFilterInputs?> inputs;

  @override
  List<Object?> get props => [
        companies,
        jobVacancies,
        statuses,
        cities,
        inputs,
      ];
}

/// Соискатель
class ApplicantData {
  /// Модель соискателя
  const ApplicantData({
    required this.id,
    required this.status,
    required this.statusBadge,
    required this.receive,
    required this.makeOut,
    required this.clientName,
    required this.phone,
    required this.additionalPhone,
    required this.jobVacancy,
    required this.jobVacancyText,
    required this.age,
    required this.experience,
    required this.specification,
    required this.specificationText,
    required this.smartphone,
    required this.email,
    required this.orderComment,
    required this.date,
    required this.time,
    required this.cityId,
    required this.cityName,
    required this.district,
    required this.createdAt,
    required this.masterId,
    this.canTakeToWork = false,
  });

  /// Стандартный парсер
  factory ApplicantData.fromJson(JsonReader json) {
    return ApplicantData(
      id: json['id'].asInt(),
      status: json['status'].asInt(),
      statusBadge: StatusBadge.fromJson(json['status_badge']),
      receive: json['receive'].asIntOrNull(),
      makeOut: json['make_out'].asIntOrNull(),
      clientName: json['client_name'].asString(),
      phone: json['phone'].asString(),
      additionalPhone: json['additional_phone'].asListOf<String>(),
      jobVacancy: json['job_vacancy'].asIntOrNull(),
      jobVacancyText: json['job_vacancy_text'].asString(),
      age: json['age'].asString(),
      experience: json['experience'].asBool(),
      specification: json['specification'].asInt(),
      specificationText: json['specification_text'].asString(),
      smartphone: json['smartphone'].asBool(),
      email: json['email'].asString(),
      date: json['date'].asString(),
      time: json['time'].asString(),
      orderComment: json['order_comment'].asString(),
      cityId: json['city_id'].asInt(),
      cityName: json['city_name'].asString(),
      district: json['district'].asString(),
      canTakeToWork: json['can_take_to_work'].asBool(),
      createdAt: json['created_at'].asDateTime().toLocal(),
      masterId: json['master_id'].asIntOrNull(),
    );
  }

  /// Есть ли дата созвона
  bool get interviewDateIsEmpty => date.isEmpty && time.isEmpty;

  /// Дата созвона
  DateTime? get interviewDate {
    try {
      final _date = date.split('-').map(int.parse).toList();
      final _time = time.split(':').map(int.parse).toList();
      return DateTime(
          _date[0], _date[1], _date[2], _time[0], _time[1], _time[2]);
    } catch (e) {
      return null;
    }
  }

  final int id;
  final int status;
  final StatusBadge statusBadge;
  final int? receive;
  final int? makeOut;
  final String clientName;
  final String phone;
  final List<String> additionalPhone;
  final int? jobVacancy;
  final String jobVacancyText;
  final String age;
  final bool experience;
  final int specification;
  final String specificationText;
  final bool smartphone;
  final String email;
  final String date;
  final String time;
  final String orderComment;
  final int cityId;
  final String cityName;
  final String district;
  final bool canTakeToWork;
  final DateTime createdAt;
  final int? masterId;
}

/// Фильтр соискателей детальная документация в [AppFilter]
class ApplicantFilter extends AppFilter {
  const ApplicantFilter({
    required this.clientName,
    required this.email,
    required this.phone,
    this.jobVacancy,
    this.status,
    this.cityId,
    this.dateStart,
    this.dateEnd,
    this.createAtStart,
    this.createAtEnd,
    this.name,
  });

  factory ApplicantFilter.fromJson(JsonReader json) => ApplicantFilter(
        clientName: json['client_name'].asString(),
        email: json['email'].asString(),
        phone: json['phone'].asString(),
        jobVacancy: json['job_vacancy'].asIntOrNull(),
        status: json['status'].asIntOrNull(),
        cityId: json['city_id'].asIntOrNull(),
        name: json['name'].asString(),
      );

  static const empty = ApplicantFilter(
    clientName: '',
    email: '',
    phone: '',
  );

  @override
  bool get isEmpty =>
      clientName.isEmpty &&
      email.isEmpty &&
      phone.isEmpty &&
      jobVacancy == null &&
      status == null &&
      cityId == null &&
      dateStart == null &&
      dateEnd == null &&
      createAtStart == null &&
      createAtEnd == null;

  @override
  ApplicantFilter copyWith({
    String? name,
    String? clientName,
    String? email,
    String? phone,
    int? jobVacancy,
    int? status,
    int? cityId,
    DateTime? dateStart,
    DateTime? dateEnd,
    DateTime? createAtStart,
    DateTime? createAtEnd,
  }) =>
      ApplicantFilter(
        name: name ?? this.name,
        clientName: clientName ?? this.clientName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        jobVacancy: jobVacancy ?? this.jobVacancy,
        status: status ?? this.status,
        cityId: cityId ?? this.cityId,
        dateStart: dateStart ?? this.dateStart,
        dateEnd: dateEnd ?? this.dateEnd,
        createAtStart: createAtStart ?? this.createAtStart,
        createAtEnd: createAtEnd ?? this.createAtEnd,
      );

  @override
  Map<String, dynamic> toQueryParams() => {
        if (clientName.isNotEmpty) 'client_name': clientName,
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone': phone,
        if (jobVacancy != null) 'job_vacancy': jobVacancy,
        if (status != null) 'status': status,
        if (cityId != null) 'city_id': cityId,
      };

  @override
  Map<String, dynamic> toJson({bool dateToMemory = false}) => toQueryParams();

  @override
  List<Object?> get props => [
        clientName,
        email,
        phone,
        jobVacancy,
        status,
        cityId,
        dateStart,
        dateEnd,
        createAtStart,
        createAtEnd,
        name,
      ];

  final String clientName;
  final String email;
  final String phone;
  final int? jobVacancy;
  final int? status;
  final int? cityId;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final DateTime? createAtStart;
  final DateTime? createAtEnd;
  final String? name;

  @override
  String get filterName => name ?? '';
}
