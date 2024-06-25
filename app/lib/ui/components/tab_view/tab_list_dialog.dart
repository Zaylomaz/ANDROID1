import 'package:core/core.dart';
import 'package:rempc/ui/components/tab_view/tab_view_model.dart';
import 'package:uikit/uikit.dart';

class TabListDialog extends StatefulWidget {
  const TabListDialog({
    required this.parent,
    required this.tabs,
    required this.onChange,
    super.key,
  });

  final List<AppTabView> tabs;
  final Function(List<AppTabView>) onChange;
  final AppTabViewScreen parent;

  @override
  State createState() => TabListDialogState();
}

class TabListDialogState<AppTabViewScreen> extends State<TabListDialog> {
  List<AppTabView> tabs = [];
  @override
  void initState() {
    tabs = widget.tabs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Dialog(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Быстрые фильтры',
                textAlign: TextAlign.center,
                style: AppTextStyle.boldHeadLine.style(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...tabs.map(
                    (e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Observer(builder: (context) {
                        return Text(
                          e.name.value,
                          style: const TextStyle(
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                      leading: AppIcons.edit.iconButton(
                        splitColor: AppSplitColor.violet(),
                        onPressed: () async {
                          /// TODO
                          // try {
                          //   final newFilter =
                          //       await Navigator.of(context).pushNamed(
                          //     widget.parent.filterRoute,
                          //     arguments: MasterFilterScreenArgs(
                          //       dict: widget.dictionary,
                          //       initFilter: e.filter as AppMasterUserFilter,
                          //       name: e.name.value,
                          //     ),
                          //   ) as AppFilter?;
                          //   if (newFilter != null) {
                          //     tabs[tabs.indexOf(e)].filter = newFilter;
                          //     if (newFilter.filterName.isNotEmpty == true) {
                          //       runInAction(() {
                          //         tabs[tabs.indexOf(e)].name.value =
                          //             newFilter.filterName;
                          //       });
                          //     }
                          //     widget.onChange(tabs);
                          //     setState(() {});
                          //   }
                          // } catch (e, s) {
                          //   unawaited(
                          //       FirebaseCrashlytics.instance.recordError(e, s));
                          // }
                        },
                      ),
                      trailing: tabs.indexOf(e) > 0
                          ? AppIcons.trash.iconButton(
                              onPressed: () {
                                tabs.remove(e);
                                widget.onChange(tabs);
                                setState(() {});
                              },
                              splitColor: AppSplitColor.red(),
                              width: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton.violet(
                    onPressed: () async {
                      /// TODO
                      // final filter = await Navigator.of(context).pushNamed(
                      //   widget.parent.filterRoute,
                      //   arguments: MasterFilterScreenArgs(
                      //     name: 'Новая вкладка',
                      //   ),
                      // ) as AppFilter?;
                      //
                      // if (filter is AppFilter &&
                      //     !filter.isEmpty &&
                      //     filter.filterName.isNotEmpty == true) {
                      //   tabs.add(
                      //     MastersTab(
                      //       filter: filter,
                      //       tabName: filter.filterName,
                      //     ),
                      //   );
                      //   widget.onChange(tabs);
                      //   setState(() {});
                      // } else {
                      //   debugPrint(filter.toString());
                      // }
                    },
                    text: 'Добавить вкладку',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
