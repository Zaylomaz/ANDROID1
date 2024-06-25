import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:uikit/uikit.dart';

/// Модель пользователя приложением
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.contacts,
  });

  factory AppUser.fromJson(JsonReader json) => AppUser(
        id: json['id'].asInt(),
        name: json['name'].asString(),
        email: json['email'].asString(),
        contacts: PhoneList.fromJson(json['contacts']),
      );

  final int id;
  final String name;
  final String email;
  final PhoneList contacts;
}

/// Данные главной страницы
class HomePageData {
  const HomePageData._(
    this.rating,
    this.penalty,
    this.salary,
    this.averageCheck,
    this.isInWorkButtonAvailable,
  );

  factory HomePageData.fromJson(JsonReader json) => HomePageData._(
        HomePageRating.fromJson(json['rating']),
        HomePagePenalty.fromJson(json['penalty']),
        HomePageSalary.fromJson(json['salary']),
        HomePageAverageCheck.fromJson(json['averageCheck']),
        json['isInWorkButtonAvailable'].asBool(),
      );

  final HomePageRating rating;
  final HomePagePenalty penalty;
  final HomePageSalary salary;
  final HomePageAverageCheck averageCheck;
  final bool isInWorkButtonAvailable;

  List<HomePageInfo> get data => [rating, penalty, salary, averageCheck];
}

/// Интерфейс данных на главной странице
abstract class HomePageInfo {
  const HomePageInfo();

  String get title;

  int get count;

  Color get countColor;

  AppSplitColor get iconColor;

  Widget get countSuffix => const SizedBox.shrink();

  Widget get icon;
}

/// Рейтинг
class HomePageRating extends HomePageInfo {
  const HomePageRating._(this.position, this.isArrowUp);

  factory HomePageRating.fromJson(JsonReader json) => HomePageRating._(
        json['position'].asInt(),
        json['isArrowUp'].asBool(),
      );
  final int position;
  final bool isArrowUp;

  @override
  int get count => position;

  @override
  Color get countColor => AppColors.white;

  @override
  Widget get countSuffix => RotatedBox(
        quarterTurns: isArrowUp ? 1 : 3,
        child: AppIcons.arrowPop.widget(
          color: isArrowUp ? AppColors.green : AppColors.red,
        ),
      );

  @override
  AppSplitColor get iconColor => AppSplitColor.yellow();

  @override
  String get title => 'Рейтинг';

  @override
  Widget get icon => AppIcons.rate.iconColored(
        color: iconColor,
        iconSize: 16,
      );
}

/// Штрафы
class HomePagePenalty extends HomePageInfo {
  const HomePagePenalty._(this._count);

  factory HomePagePenalty.fromJson(JsonReader json) => HomePagePenalty._(
        json['count'].asInt(),
      );
  final int _count;

  @override
  int get count => _count;

  @override
  Color get countColor => AppColors.red;

  @override
  AppSplitColor get iconColor => AppSplitColor.red();

  @override
  String get title => 'Нарушения';

  @override
  Widget get icon => AppIcons.fail.iconColored(
        color: iconColor,
        iconSize: 16,
      );
}

/// Зарплата
class HomePageSalary extends HomePageInfo {
  const HomePageSalary._(this.sum);

  factory HomePageSalary.fromJson(JsonReader json) => HomePageSalary._(
        json['sum'].asInt(),
      );
  final int sum;

  @override
  int get count => sum;

  @override
  Color get countColor => AppColors.white;

  @override
  AppSplitColor get iconColor => AppSplitColor.green();

  @override
  String get title => 'Зарплата';

  @override
  Widget get icon => AppIcons.wallet.iconColored(
        color: iconColor,
        iconSize: 16,
      );

  @override
  Widget get countSuffix => Text(
        ' грн',
        style: AppTextStyle.regularCaption.textStyle,
      );
}

/// Средний чек
class HomePageAverageCheck extends HomePageInfo {
  const HomePageAverageCheck._(this.sum);

  factory HomePageAverageCheck.fromJson(JsonReader json) =>
      HomePageAverageCheck._(
        json['sum'].asInt(),
      );
  final int sum;

  @override
  int get count => sum;

  @override
  Color get countColor => AppColors.yellow;

  @override
  AppSplitColor get iconColor => AppSplitColor.green();

  @override
  String get title => 'Средний чек';

  @override
  Widget get icon => AppIcons.check.iconColored(
        color: iconColor,
        iconSize: 16,
      );

  @override
  Widget get countSuffix => Text(
        ' грн',
        style: AppTextStyle.regularCaption.textStyle,
      );
}

/// Атрибуты пользователя
class UserHeaderInfo {
  const UserHeaderInfo({
    required this.notificationsCount,
    required this.isInWork,
    required this.userId,
    required this.userName,
    required this.lostCallsCount,
  });

  factory UserHeaderInfo.fromJson(JsonReader json) => UserHeaderInfo(
        notificationsCount: json['count_new_notifications'].asInt(),
        isInWork: json['is_in_work'].asBool(),
        userId: json['user_id'].asInt(defaultValue: -1),
        userName: json['user_name'].asString(),
        lostCallsCount: json['lost_calls'].asInt(),
      );

  static const empty = UserHeaderInfo(
    notificationsCount: 0,
    isInWork: false,
    userId: -1,
    userName: '',
    lostCallsCount: 0,
  );

  Map<String, dynamic> toJson() => {
        'count_new_notifications': notificationsCount,
        'is_in_work': isInWork,
        'user_id': userId,
        'user_name': userName,
        'lost_calls': lostCallsCount,
      };

  final int notificationsCount;
  final bool isInWork;
  final int userId;
  final String userName;
  final int lostCallsCount;
}
