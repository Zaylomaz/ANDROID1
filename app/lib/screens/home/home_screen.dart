import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/developer/developer_screen.dart';
import 'package:rempc/screens/old_page_router_abstract.dart';
import 'package:rempc/ui/components/app_bar_drawer.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

/*
* Главная страница
*/

class HomeScreenRouter extends OldPageRouterAbstract {
  const HomeScreenRouter(super.screen, {super.key});

  @override
  String getInitialRoute() => HomeScreen.routeName;

  @override
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      AppRouter.navigatorKeys[AppRouter.homeNavigatorKey];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> setInWork(BuildContext context) async {
    await withLoadingIndicator(() async {
      await DeprecatedRepository().setInWork();
      await HomeData.of(context).updateUserInfo();
    });
  }

  Widget info(BuildContext context) => AppMaterialBox(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Observer(
            builder: (context) {
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 160 / 102,
                ),
                children: HomeData.of(context)
                        .homePageData
                        ?.data
                        .map((e) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      e.icon,
                                      const SizedBox(width: 8),
                                      Text(
                                        e.title,
                                        style: AppTextStyle.regularSubHeadline
                                            .style(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        e.count.toString(),
                                        style:
                                            AppTextStyle.boldLargeTitle.style(
                                          context,
                                          e.countColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 5,
                                        ),
                                        child: e.countSuffix,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ))
                        .toList() ??
                    const [],
              );
            },
          ),
        ),
      );

  Widget inWorkButton(BuildContext context) => Observer(builder: (context) {
        if (HomeData.of(context).homePageData?.isInWorkButtonAvailable ==
            true) {
          if (HomeData.of(context).userHeaderInfo.isInWork) {
            return PrimaryButton.cyan(
              text: 'В работе',
            );
          } else {
            return PrimaryButton.green(
              text: 'Начать работать',
              onPressed: () => setInWork(context),
            );
          }
        }
        return const SizedBox.shrink();
      });

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: GestureDetector(
          onTap: () {
            if (kDebugMode) {
              Navigator.of(context).pushNamed(DeveloperScreen.routeName);
            }
          },
          child: const Text('Главная'),
        ),
        actions: [
          AppIcons.reverse.fabButtonAnimated<void>(
            onPressed: HomeData.of(context).refresh,
          ),
        ],
      ),
      drawer: const AppBarDrawer(),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              info(context),
              const SizedBox(height: 16),
              inWorkButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
