import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';

/*
*  Абстрактные интерфейсы для постройки списков типа
*  соискателей, заказов сервисного центра и т.п.
*  Особенность реализации:
*  - фильтрация
*  - наличие вкладок с разными фильтрами
*  - каждая вкладка имеет пагинацию
*/

/// Объект фильтра для списков данных
/// Может преобразовываться в объект для бекенда
/// Может преобразовываться в объект для сохранения в память
abstract class AppFilter extends Equatable {
  const AppFilter();

  external const factory AppFilter.fromJson(JsonReader json);

  /// Возвращает состояние фильтра
  /// если [isEmpty] == false то считаем что фильтр не используется
  bool get isEmpty;

  String get filterName;

  /// Метод обновления параметров фильтра
  AppFilter copyWith();

  /// Конвертация в объект для сохранения в память
  Map<String, dynamic> toJson({bool dateToMemory});

  /// Конвертация в объект [QueryParameters] для запроса на бекенд
  Map<String, dynamic> toQueryParams();
}

/// Интерфейс отдельно взятой вкладки списка данных
abstract class AppTabView<T> {
  AppTabView({
    required this.filter,
    this.tabName,
  }) {
    name = Observable<String>('');
    total = Observable<int>(0);
    if (tabName?.isNotEmpty == true) {
      name.value = tabName!;
    }
    pageController = PagingController<int, T>(firstPageKey: 1);
    scrollController = ScrollController();
  }

  /// Фильтр для вкладки
  AppFilter filter;
  String? tabName;

  /// Название вкладки
  late Observable<String> name;

  /// Контроллер пагинации
  late final PagingController<int, T> pageController;
  late final ScrollController scrollController;

  /// Количество элементов в списке по данному фильтру
  late Observable<int> total;

  /// Готова ли вкладка с фильтром к работе
  bool initialized = false;

  /// Метод получения данных с сервера
  Future<void> getData(int page);

  /// Запуск в работу
  @mustCallSuper
  void init() {
    if (initialized) return;
    pageController.addPageRequestListener(getData);
    initialized = true;
  }

  /// Обновление данных
  @mustCallSuper
  void refresh() {
    if (!initialized) return;
    pageController.refresh();
  }

  /// Деинициализация
  @mustCallSuper
  void dispose() {
    if (!initialized) return;
    pageController
      ..removePageRequestListener(getData)
      ..dispose();
    scrollController.dispose();
    initialized = false;
  }

  /// Подготовка объекта для записи в память
  Map<String, dynamic> toJson() => {
        'filter': filter.toJson(dateToMemory: true),
        'name': name.value,
        'total': total.value,
      };
}

/// Объект ответа сервера для списков с фильтрацией
class TabListResponse<T> {
  const TabListResponse(
    this.data,
    this.total,
  );

  final List<T> data;
  final int total;
}
