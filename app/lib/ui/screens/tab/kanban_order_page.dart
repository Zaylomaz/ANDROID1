import 'dart:io';

import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/services.dart';
import 'package:rempc/model/kanban_order_page_model.dart';
import 'package:rempc/provider/view_state_widget.dart';
import 'package:uikit/uikit.dart';

class KanbanOrderPage extends StatefulWidget {
  const KanbanOrderPage(this.arguments, {super.key});

  static const String routeName = '/kanban_order';

  final Map<String, int> arguments;

  @override
  KanbanOrderPageState createState() => KanbanOrderPageState();
}

class KanbanOrderPageState extends State<KanbanOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(
        title: Text('Заказы'),
      ),
      body: _buildKanbanOrderPage(),
    );
  }

  Widget _buildKanbanOrderPage() {
    return ChangeNotifierProvider<KanbanOrderPageModel>(
        create: (_) => KanbanOrderPageModel(widget.arguments['orderId']!),
        child: _KanbanOrderPage(widget.arguments['orderId']!));
  }
}

class _KanbanOrderPage extends StatefulWidget {
  const _KanbanOrderPage(this.orderId);

  final int orderId;

  @override
  _KanbanOrderDataPageState createState() => _KanbanOrderDataPageState();
}

class _KanbanOrderDataPageState extends State<StatefulWidget> {
  KanbanOrderPageModel? _kanbanOrderPageModel;

  KanbanOrderPageModel? get kanbanOrderPageModel => _kanbanOrderPageModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshProvider();
    if (!(_kanbanOrderPageModel?.isInited ?? true)) {
      _kanbanOrderPageModel?.initData();
    }
  }

  void refreshProvider() {
    _kanbanOrderPageModel = Provider.of<KanbanOrderPageModel>(context);
  }

  TextEditingController orderSumController = TextEditingController();
  bool _firstInit = true;

  Future<XFile?> uploadFile(BuildContext context,
      {bool useInAppCamera = false}) async {
    final pickedFile = await AppImagePicker.showSelectDialog(
      context,
      Navigator.of(context),
    );
    return pickedFile;
  }

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'pt_BR';
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (kanbanOrderPageModel!.busy) {
      body = const Center(child: AppLoadingIndicator());
    } else if (kanbanOrderPageModel!.error &&
        kanbanOrderPageModel?.stateData == null) {
      body = ViewStateErrorWidget(
          error: kanbanOrderPageModel!.viewStateError!,
          onPressed: kanbanOrderPageModel!.initData);
    } else if (kanbanOrderPageModel!.empty) {
      body = ViewStateEmptyWidget(onPressed: kanbanOrderPageModel?.initData);
    } else if (kanbanOrderPageModel!.empty) {
      body = Container();
    } else {
      body = SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _getForm(),
        ),
      );
    }

    return Scaffold(
      body: body,
    );
  }

  Widget _getForm() {
    if (_firstInit) {
      orderSumController.text =
          kanbanOrderPageModel!.stateData!.orderSum == null
              ? '0'
              : kanbanOrderPageModel!.stateData!.orderSum.toString();
      _firstInit = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            kanbanOrderPageModel!.stateData!.orderNumber != null
                ? '#${kanbanOrderPageModel!.stateData!.orderNumber}'
                : '-',
            style: AppTextStyle.regularHeadline.style(context),
          ),
          const SizedBox(height: 8),
          IconWithTextRow(
            text: kanbanOrderPageModel!.stateData!.clientName,
            leading: AppIcons.user.iconColored(
              color: AppSplitColor.cyan(),
              iconSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          IconWithTextRow(
            text: kanbanOrderPageModel!.stateData!.city,
            leading: AppIcons.city.iconColored(
              color: AppSplitColor.violetLight(),
              iconSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          AppTextInputField(
            initialValue: kanbanOrderPageModel!.stateData!.defect,
            maxLines: 10,
            minLines: 1,
            decoration: const InputDecoration(
              labelText: 'Неисправность со слов клиента',
            ),
            onChanged: (newValue) {
              setState(() {
                kanbanOrderPageModel!.stateData =
                    kanbanOrderPageModel!.stateData!.copyWith(
                  defect: newValue,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          AppTextInputField(
            initialValue: kanbanOrderPageModel!.stateData!.infoForMasterPrevent,
            maxLines: 10,
            minLines: 1,
            decoration: const InputDecoration(
              labelText: 'Инфо мастеру',
            ),
            onChanged: (newValue) {
              setState(() {
                kanbanOrderPageModel!.stateData = kanbanOrderPageModel!
                    .stateData!
                    .copyWith(infoForMasterPrevent: newValue);
              });
            },
          ),
          const SizedBox(height: 16),
          infoBlock(
            'Коммент оператора',
            kanbanOrderPageModel!.stateData!.operatorComment,
          ),
          const SizedBox(height: 16),
          infoBlock(
            'Техника',
            kanbanOrderPageModel!.stateData!.technique,
          ),
          const SizedBox(height: 16),
          infoBlock(
            'Тематика',
            kanbanOrderPageModel!.stateData!.them,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Дата',
                style: AppTextStyle.regularCaption.style(context),
              ),
              const SizedBox(height: 8),
              DateTimePicker(
                style: AppTextStyle.regularHeadline.style(context),
                dateMask: 'dd.MM.yyyy',
                initialValue: DateFormat('yyyy-MM-dd')
                    .format(kanbanOrderPageModel!.stateData!.date),
                firstDate: DateTime.now().subtract(const Duration(days: 14)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onChanged: (value) {
                  kanbanOrderPageModel!.stateData = kanbanOrderPageModel!
                      .stateData!
                      .copyWith(date: DateTime.parse(value));
                },
                validator: (val) {
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdownField<String>(
            label: 'Время',
            value: kanbanOrderPageModel!.stateData!.time,
            items: kanbanOrderPageModel!.stateData!.availableTime
                .map((value) => MapEntry(value.value, value.value)),
            onChange: (newValue) {
              if (newValue != null) {
                setState(() {
                  kanbanOrderPageModel!.stateData =
                      kanbanOrderPageModel!.stateData!.copyWith(time: newValue);
                });
              }
            },
          ),
          if (kanbanOrderPageModel!.stateData!.masterId == null ||
              kanbanOrderPageModel!.stateData!.masters
                  .where(
                      (m) => m.id == kanbanOrderPageModel!.stateData!.masterId)
                  .isNotEmpty)
            AppDropdownField<int?>(
              label: 'Мастер',
              value: kanbanOrderPageModel!.stateData!.masterId,
              items: kanbanOrderPageModel!.stateData!.masters
                  .map((value) => MapEntry(value.id, value.name)),
              onChange: (newValue) {
                if (newValue != null) {
                  setState(() {
                    kanbanOrderPageModel!.stateData = kanbanOrderPageModel!
                        .stateData!
                        .copyWith(masterId: newValue);
                  });
                }
              },
            ),
          AppDropdownField<int>(
            label: 'Статус',
            value: kanbanOrderPageModel!.stateData!.status,
            items: kanbanOrderPageModel!.stateData!.availableStatuses
                .map((value) => MapEntry(value.id, value.value)),
            onChange: (newValue) {
              if (newValue != null) {
                setState(() {
                  kanbanOrderPageModel!.stateData = kanbanOrderPageModel!
                      .stateData!
                      .copyWith(status: newValue);
                });
              }
            },
          ),
          AppTextInputField(
            controller: orderSumController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(labelText: 'Сумма'),
            onChanged: (newValue) {
              kanbanOrderPageModel!.stateData = kanbanOrderPageModel!.stateData!
                  .copyWith(
                      orderSum: newValue.isNotEmpty ? int.parse(newValue) : 0);
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фото чека',
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PhotoPicker(
                    file: File(kanbanOrderPageModel!.stateData!.checkPhoto),
                    onTap: () async {
                      final file = await uploadFile(context);
                      kanbanOrderPageModel!.setCheckImage(file?.path);
                    },
                    onLongPress: () async {
                      final file = await uploadFile(
                        context,
                        useInAppCamera: true,
                      );
                      kanbanOrderPageModel!.setCheckImage(file?.path);
                    },
                  ),
                  const SizedBox(width: 16),
                  if (kanbanOrderPageModel!.stateData!.checkPhoto.isNotEmpty ==
                      true)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PrimaryButton.violet(
                            onPressed: () async {
                              final file = await uploadFile(context);
                              kanbanOrderPageModel!.setCheckImage(file?.path);
                            },
                            onLongPress: () async {
                              final file = await uploadFile(
                                context,
                                useInAppCamera: true,
                              );
                              kanbanOrderPageModel!.setCheckImage(file?.path);
                            },
                            text: 'Изменить фото чека',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton.red(
                            onPressed: kanbanOrderPageModel!.removeCheckImage,
                            text: 'Удалить фото чека',
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Фото акта забора',
                style: AppTextStyle.regularSubHeadline.style(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PhotoPicker(
                    file: File(kanbanOrderPageModel!
                        .stateData!.photoActOfTakeawayTechnique),
                    onTap: () async {
                      final file = await uploadFile(context);
                      kanbanOrderPageModel!.setActOfTakeawayImage(file?.path);
                    },
                    onLongPress: () async {
                      final file = await uploadFile(
                        context,
                        useInAppCamera: true,
                      );
                      kanbanOrderPageModel!.setActOfTakeawayImage(file?.path);
                    },
                  ),
                  const SizedBox(width: 16),
                  if (kanbanOrderPageModel!
                          .stateData!.photoActOfTakeawayTechnique.isNotEmpty ==
                      true)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PrimaryButton.violet(
                            onPressed: () async {
                              final file = await uploadFile(context);
                              kanbanOrderPageModel!
                                  .setActOfTakeawayImage(file?.path);
                            },
                            onLongPress: () async {
                              final file = await uploadFile(
                                context,
                                useInAppCamera: true,
                              );
                              kanbanOrderPageModel!
                                  .setActOfTakeawayImage(file?.path);
                            },
                            text: 'Изменить фото чека',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton.red(
                            onPressed:
                                kanbanOrderPageModel!.removeActOfTakeawayImage,
                            text: 'Удалить фото чека',
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
          if (kanbanOrderPageModel!.errorText != null &&
              kanbanOrderPageModel!.errorText!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              color: AppColors.red,
              alignment: Alignment.center,
              // height: 30,
              child: Text(
                kanbanOrderPageModel!.errorText ?? '-',
                style: AppTextStyle.regularHeadline.style(context),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              PrimaryButton.cyan(
                text: 'Отменить',
                onPressed: Navigator.of(context).pop,
              ),
              const SizedBox(width: 16),
              PrimaryButton.green(
                text: 'Сохранить',
                onPressed: () async {
                  final result = await kanbanOrderPageModel!.saveOrder();
                  if (result != null) {
                    Navigator.of(context).pop(result);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoBlock(String title, String text) => AppMaterialBox.withPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.regularHeadline.style(
                context,
                AppColors.violetLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: AppTextStyle.regularSubHeadline.style(context),
            ),
          ],
        ),
      );
}
