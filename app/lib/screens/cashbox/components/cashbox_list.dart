import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/screens/cashbox/components/cashbox_list_item.dart';
import 'package:rempc/screens/sign_in/sign_in_screen.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

class CashBoxListWidget extends StatefulWidget {
  const CashBoxListWidget({super.key});

  @override
  State<CashBoxListWidget> createState() => _CashBoxListWidgetState();
}

class _CashBoxListWidgetState extends State<CashBoxListWidget> {
  List<CashBox> _cashboxItems = [];
  bool _isNotificationsFetch = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _fetchData() async {
    try {
      final response = await CashBoxRepository().getCashBox();
      setState(() {
        _isNotificationsFetch = true;
        _cashboxItems = response;
      });
    } catch (e) {
      if (e is TooManyRequestsException) {
        unawaited(Navigator.of(context)
            .pushReplacementNamed(ToManyRequestScreen.routeName));
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(AppRouter
                .navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!)
            .pushReplacementNamed(SignInScreen.routeName));
      }
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNotificationsFetch == false) {
      return const Center(child: AppLoadingIndicator());
    }
    return _cashboxItems.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Отлично, касса сдана',
                    style: AppTextStyle.boldHeadLine
                        .style(context, AppColors.violetLight),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton.cyan(
                    text: 'Обновить',
                    onPressed: () => withLoadingIndicator(_fetchData),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: () => withLoadingIndicator(_fetchData),
            child: ListView.separated(
              itemCount: _cashboxItems.length,
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemBuilder: (ctx, index) {
                return CashBoxListItem(
                  key: ValueKey<String>(
                    '${_cashboxItems[index].order.id}_$index',
                  ),
                  orderNumber: _cashboxItems[index].order.orderNumber,
                  userName: _cashboxItems[index].user.name,
                  cashboxIn: _cashboxItems[index].amount,
                  isSubmitted: _cashboxItems[index].isSubmitted,
                );
                // is_read
              },
              separatorBuilder: (c, i) => const SizedBox(height: 8),
            ),
          );
  }
}
