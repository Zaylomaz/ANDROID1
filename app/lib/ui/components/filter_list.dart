import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

///TODO FINISH WIDGET
class FilterListDialog extends StatefulWidget {
  const FilterListDialog({
    required this.tabs,
    required this.onChange,
    required this.dictionary,
    super.key,
  });

  final List<AppTabView> tabs;
  final AppMasterUserDict dictionary;
  final Function(List<AppTabView>) onChange;

  @override
  State<FilterListDialog> createState() => _State();
}

class _State extends State<FilterListDialog> {
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
                      title: Observer(
                        builder: (context) => Text(
                          e.name.value,
                          style: const TextStyle(
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      leading: AppIcons.edit.iconButton(
                        splitColor: AppSplitColor.violet(),
                        onPressed: () async {
                          //TODO EDIT
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
                      //TODO CREATE NEW
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

class FilterDialogWrapper extends StatelessWidget {
  const FilterDialogWrapper({required this.child, super.key});

  final Widget child;

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
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * .7),
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
