import 'package:core/core.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/ai_chat/ai_chat_screen.dart';
import 'package:rempc/screens/applicant/applicant_screen.dart';
import 'package:rempc/screens/calls/calls_screen.dart';
import 'package:rempc/screens/cashbox/cashbox_screen.dart';
import 'package:rempc/screens/cashbox_admin/cashbox_admin_screen.dart';
import 'package:rempc/screens/channels/channels_screen.dart';
import 'package:rempc/screens/developer/developer_screen.dart';
import 'package:rempc/screens/faq/faq_list_screen.dart';
import 'package:rempc/screens/home/home_screen.dart';
import 'package:rempc/screens/master/details/master_screen.dart';
import 'package:rempc/screens/master/masters_screen.dart';
import 'package:rempc/screens/notifications/notifications_screen.dart';
import 'package:rempc/screens/orders/order_screen.dart';
import 'package:rempc/screens/scouting/scouting_screen.dart';
import 'package:rempc/screens/service_orders/service_orders_screen.dart';
import 'package:rempc/ui/components/dialpad_view.dart';
import 'package:rempc/ui/screens/settings/settings_page.dart';
import 'package:rempc/ui/screens/tab/kanban_page.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

extension AppBarDrawerUserScreenExt on UserScreen {
  String get routeName {
    switch (this) {
      case UserScreen.orderScreen:
        return OrderScreen.routeName;
      case UserScreen.serviceOrderScreen:
        return ServiceOrderScreen.routeName;
      case UserScreen.cashboxAdminScreen:
        return CashBoxAdminScreen.routeName;
      case UserScreen.cashboxScreen:
        return CashBoxScreen.routeName;
      case UserScreen.kanbanScreen:
        return KanbanPage.routeName;
      case UserScreen.chatScreen:
        return ChannelsScreen.routeName;
      case UserScreen.chatAiScreen:
        return AiChatScreen.routeName;
      case UserScreen.scoutingScreen:
        return ScoutingScreen.routeName;
      case UserScreen.settingsScreen:
        return SettingsPage.routeName;
      case UserScreen.dialPadScreen:
        return DialPadPage.routeName;
      case UserScreen.notificationsScreen:
        return NotificationsScreen.routeName;
      case UserScreen.mastersScreen:
        return MasterScreen.routeName;
      case UserScreen.missedCallsScreen:
        return AppCallsScreen.routeName;
      case UserScreen.faq:
        return FAQListScreen.routeName;
      case UserScreen.applicant:
        return ApplicantListScreen.routeName;
      case UserScreen.home:
        return HomeScreen.routeName;
      case UserScreen.undefined:
        return 'UserScreen.undefined';
    }
  }
}

class AppBarDrawer extends StatefulWidget {
  const AppBarDrawer({super.key});

  @override
  State<AppBarDrawer> createState() => _AppBarDrawerState();
}

class _AppBarDrawerState extends State<AppBarDrawer> {
  final _userRepo = UsersRepository();
  final pageController = PageController();
  int page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeData.of(context).refreshBalance();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
      surfaceTintColor: Theme.of(context).drawerTheme.surfaceTintColor,
      width: MediaQuery.of(context).size.width * .7,
      child: Observer(builder: (context) {
        return NestedScrollView(
          headerSliverBuilder: (context, pinned) => [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SafeArea(
                  child: GestureDetector(
                    onLongPress: () {
                      if (Environment<AppConfig>.instance().isDebug) {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(DeveloperScreen.routeName);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (HomeData.of(context).user?.fullName.isNotEmpty ==
                            true)
                          _User(
                            HomeData.of(context).user!,
                            roleName: _userRepo
                                .dict.role[HomeData.of(context).user?.role],
                          ),
                        const SizedBox(height: 8),
                        if (HomeData.of(context).balance.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 80,
                              child: PageView(
                                controller: pageController,
                                onPageChanged: (page) {
                                  setState(() {
                                    this.page = page;
                                  });
                                },
                                children: HomeData.of(context)
                                    .balance
                                    .map(
                                      (e) => Container(
                                        padding: const EdgeInsets.all(16),
                                        color: AppColors.black,
                                        child: RichText(
                                          maxLines: 3,
                                          text: TextSpan(
                                            style: AppTextStyle.regularHeadline
                                                .style(context),
                                            children: [
                                              TextSpan(text: e.city),
                                              const TextSpan(text: '\n'),
                                              TextSpan(
                                                text: e.submittedFormat,
                                                style: const TextStyle(
                                                  color: AppColors.green,
                                                ),
                                              ),
                                              const TextSpan(text: '/ '),
                                              TextSpan(
                                                text: e.totalFormat,
                                                style: const TextStyle(
                                                  color: AppColors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: HomeData.of(context)
                                    .balance
                                    .map((e) => Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          decoration: BoxDecoration(
                                            color: HomeData.of(context)
                                                        .balance
                                                        .indexOf(e) ==
                                                    page
                                                ? AppColors.violet
                                                : AppColors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.stretch,
                          //   children: balance
                          //       .map(
                          //         (e) => Container(
                          //           padding: const EdgeInsets.all(16),
                          //           margin: const EdgeInsets.only(bottom: 8),
                          //           decoration: BoxDecoration(
                          //             color: AppColors.black,
                          //             borderRadius: BorderRadius.circular(
                          //               20,
                          //             ),
                          //           ),
                          //           child: RichText(
                          //             maxLines: 3,
                          //             text: TextSpan(
                          //               style: AppTextStyle.regularHeadline
                          //                   .style(context),
                          //               children: [
                          //                 TextSpan(text: e.city),
                          //                 const TextSpan(text: '\n'),
                          //                 TextSpan(
                          //                   text: e.submittedFormat,
                          //                   style: const TextStyle(
                          //                     color: AppColors.green,
                          //                   ),
                          //                 ),
                          //                 const TextSpan(text: '/ '),
                          //                 TextSpan(
                          //                   text: e.totalFormat,
                          //                   style: const TextStyle(
                          //                     color: AppColors.red,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //       )
                          //       .toList(),
                          // )
                        ],
                        const SizedBox(height: 8),
                        if (HomeData.of(context).averageCheck.isNotEmpty) ...[
                          Text.rich(
                            TextSpan(
                                style:
                                    AppTextStyle.regularHeadline.style(context),
                                children: [
                                  const TextSpan(
                                    text: 'Средний чек: ',
                                    style: TextStyle(
                                      color: AppColors.violetLight,
                                    ),
                                  ),
                                  TextSpan(
                                      text: HomeData.of(context).averageCheck),
                                ]),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: Observer(builder: (context) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _buildMenu(context),
            );
          }),
        );
      }),
    );
  }

  List<Widget> _buildMenu(BuildContext context) {
    final homeProvider = context.read<HomeData>();
    final userInfo = homeProvider.userHeaderInfo;
    return UserScreenGroup.values.map((group) {
      if (group.screens.any((s) => homeProvider.leftItems.contains(s))) {
        return AppDrawerGroup(
          items: homeProvider.leftItems
              .where((element) => group.screens.contains(element))
              .map(
            (e) {
              Widget? trailing;
              if (e == UserScreen.missedCallsScreen &&
                  userInfo.lostCallsCount > 0) {
                trailing = Observer(
                  builder: (context) {
                    return AppDrawerCounter(
                      color: group.colors,
                      count: context
                          .read<HomeData>()
                          .userHeaderInfo
                          .lostCallsCount,
                    );
                  },
                );
              } else if (e == UserScreen.notificationsScreen &&
                  userInfo.notificationsCount > 0) {
                trailing = Observer(
                  builder: (context) {
                    return AppDrawerCounter(
                      color: AppSplitColor.custom(
                        primary: AppColors.white,
                        secondary: AppColors.red,
                      ),
                      count: context
                          .read<HomeData>()
                          .userHeaderInfo
                          .notificationsCount,
                    );
                  },
                );
              }
              return AppDrawerMenuItem(
                text: e.title,
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: group.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: e.icon(
                      color: group.colors.primary,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                onTap: () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(e.routeName),
                trailing: trailing,
              );
            },
          ).toList(),
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList();
  }
}

class _User extends StatelessWidget {
  const _User(this.user, {this.roleName});

  final AppMasterUser user;
  final String? roleName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        onTap: () => Navigator.of(context).pushNamed(
            MasterScreenDetails.routeName,
            arguments: MasterScreenDetailsArgs(master: user)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                user.avatar?.toString() ?? '',
                fit: BoxFit.cover,
                errorBuilder: imageErrorWidget,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: AppTextStyle.boldHeadLine.style(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcons.numberHash.iconColored(
                          color: AppSplitColor.violet(),
                          size: 16,
                          iconSize: 10),
                      const SizedBox(width: 4),
                      Text(
                        user.number.toString(),
                        style: AppTextStyle.regularSubHeadline.style(context),
                      ),
                      if (roleName?.isNotEmpty == true) ...[
                        const SizedBox(width: 16),
                        Text(
                          roleName!,
                          style: AppTextStyle.regularSubHeadline.style(
                            context,
                            AppColors.violetLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
