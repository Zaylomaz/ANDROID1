import 'dart:async';

import 'package:core/core.dart';
import 'package:rempc/screens/faq/faq_details_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

part 'faq_list_screen.g.dart';

/*
* Екран списка часто задаваемых вопросов
*/

class _State extends _StateStore with _$_State {
  _State() : super();

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore() {
    pageController.addPageRequestListener(_pageRequestListener);
  }

  /// Контроллер пагинации списка вопросов [FAQModel]
  final pageController = PagingController<int, FAQModel>(firstPageKey: 1);

  /// Инициатор запросов
  @action
  Future<void> _pageRequestListener(int page) async {
    final result = await DeprecatedRepository().getFAQList(page);
    result.data.length == FAQList.perPage
        ? pageController.appendPage(result.data, page + 1)
        : pageController.appendLastPage(result.data);
  }

  /// Перезагрузить данные
  @action
  Future<void> reload() async {
    pageController.refresh();
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Открыть вопрос
  @action
  Future<void> openDetails(
    BuildContext context,
    int id,
  ) async {
    final result = await DeprecatedRepository().getFAQDetails(id);
    unawaited(Navigator.of(context).pushNamed(
      FAQDetailsScreen.routeName,
      arguments: result,
    ));
  }

  @action
  void dispose() {
    pageController
      ..removePageRequestListener(_pageRequestListener)
      ..dispose();
  }
}

class FAQListScreen extends StatelessWidget {
  const FAQListScreen({super.key});

  static const String routeName = '/faq_list_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('База знаний'),
      ),
      body: RefreshIndicator(
        onRefresh: _State.of(context).reload,
        child: PagedListView<int, FAQModel>(
          padding: const EdgeInsets.all(16),
          pagingController: _State.of(context).pageController,
          builderDelegate: PagedChildBuilderDelegate<FAQModel>(
            itemBuilder: (context, item, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  key: ValueKey<String>('${item.id}_$index'),
                  leading: AppListTileLeading(
                    child: AppIcons.bookInfo.widget(
                      color: AppColors.violet,
                    ),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.regularHeadline.style(context),
                  ),
                  onTap: () => _State.of(context).openDetails(context, item.id),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: AppIcons.chevron.widget(),
                    ),
                  ),
                  tileColor: AppColors.blackContainer,
                ),
              );
            },
            firstPageErrorIndicatorBuilder: (context) {
              return const Center(
                child: Text(
                  'First page error',
                ),
              );
            },
            noItemsFoundIndicatorBuilder: noItemsInListBuilder(context),
            newPageErrorIndicatorBuilder: (context) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Loading error',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
