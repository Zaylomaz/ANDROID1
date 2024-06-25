import 'package:core/core.dart';
import 'package:repository/repository.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

part 'contacts_screen.g.dart';

class _State extends _StateStore with _$_State {
  _State(super.sip);

  static _StateStore of(BuildContext context) =>
      Provider.of<_State>(context, listen: false);
}

abstract class _StateStore with Store {
  _StateStore(this.sip) {
    pageController.addPageRequestListener(_getContacts);
  }

  final SipModel sip;
  final pageController = PagingController<int, AppContact>(firstPageKey: 0);

  @observable
  bool _isPhoneCalling = false;
  @computed
  bool get isPhoneCalling => _isPhoneCalling;
  @protected
  set isPhoneCalling(bool value) => _isPhoneCalling = value;

  @action
  Future<void> _getContacts(int page) async {
    final result = await UsersRepository().getContacts(page);
    if (result.data.length < AppContact.perPage) {
      pageController.appendLastPage(result.data);
    } else {
      pageController.appendPage(result.data, page + 1);
    }
  }

  @action
  void refresh() => pageController.refresh();

  @action
  void dispose() {
    pageController
      ..removePageRequestListener(_getContacts)
      ..dispose();
  }
}

class AppContacts extends StatelessWidget {
  const AppContacts({super.key});

  static const String routeName = '/contacts_screen';

  @override
  Widget build(BuildContext context) {
    return Provider<_State>(
      create: (ctx) => _State(Provider.of<SipModel>(context)),
      builder: (ctx, child) => const _Content(),
      dispose: (ctx, state) => state.dispose(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Контакты'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.microtask(_State.of(context).refresh),
        child: PagedListView<int, AppContact>(
          pagingController: _State.of(context).pageController,
          builderDelegate: PagedChildBuilderDelegate<AppContact>(
            itemBuilder: (context, item, index) => ContactListItem(
              item,
              even: index % 2 == 0,
            ),
            noItemsFoundIndicatorBuilder: noItemsInListBuilder(context),
          ),
        ),
      ),
    );
  }
}

class ContactListItem extends StatelessWidget {
  const ContactListItem(
    this.data, {
    required this.even,
    super.key,
  });

  final AppContact data;
  final bool even;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: even ? AppColors.black : AppColors.blackContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AppIcons.users.iconColored(
              color: AppSplitColor.cyan(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.regularHeadline.style(context),
              ),
            ),
            const SizedBox(width: 8),
            CallButton(
              phone: data.phone,
              additionalPhones: data.additionalPhone,
              binotel: data.binotel,
              asterisk: data.asterisk,
              isSipActive: _State.of(context).sip.isActive,
              onMakeCall: _State.of(context).sip.makeCall,
              onTryCall: () async {
                if (_State.of(context).isPhoneCalling) return;
                _State.of(context).isPhoneCalling = true;
                await Future.delayed(const Duration(seconds: 15), () {
                  _State.of(context).isPhoneCalling = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
