part of 'notifications_list.dart';

/// Переопределение [AppTabView] под соискателей
class NotificationTab extends AppTabView<NotificationBase> {
  NotificationTab({
    required super.filter,
    super.tabName,
  });

  factory NotificationTab.fromMemory(JsonReader json) {
    final tab = NotificationTab(
      filter: NotificationsFilter.fromJson(json['filter']),
      tabName: json['name'].asString(),
    );
    runInAction(() {
      tab.total.value = json['total'].asInt();
    });
    return tab;
  }

  @override
  Future<void> getData(int page) async {
    try {
      final response = await DeprecatedRepository().getNotifications(
        page,
        filter,
      );
      if (response.data.length == 10) {
        pageController.appendPage(response.data, page + 1);
      } else {
        pageController.appendLastPage(response.data);
      }
      runInAction(() {
        total.value = response.total;
      });
    } catch (e, s) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, s));
    }
  }
}

/// Сохраненные вкладуи в памяти
final notificationTabs = JsonListPreference<NotificationTab>(
  key: const PreferenceKey(
    module: 'notifications',
    component: 'list',
    name: 'filters',
  ),
  defaultValue: [
    NotificationTab(
      filter: NotificationsFilter.empty.copyWith(isRead: false),
      tabName: 'Не прочитанные',
    )..total.value = 0,
    NotificationTab(
      filter: NotificationsFilter.empty.copyWith(
        isRead: true,
      ),
      tabName: 'Прочитанные',
    )..total.value = 0,
  ],
  itemDecoder: (value) => NotificationTab.fromMemory(
    JsonReader(value),
  ),
  itemEncoder: (tab) => tab.toJson(),
);
