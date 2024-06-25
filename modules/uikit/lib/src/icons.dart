import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uikit/uikit.dart';

/*
* Иконки в приложении
* https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-6764&mode=dev
* лежат в папке ./modules/uikit/assets/icons
* Имя иконки составлено из названия файла у которого убрали "_icon.svg"
*/
enum AppIcons {
  add(assetName: 'add_icon.svg'),
  add1(assetName: 'add_icon-1.svg'),
  aiBrain(assetName: 'ai_brain_icon.svg'),
  alert(assetName: 'alert_icon.svg'),
  angry(assetName: 'angry_icon.svg'),
  apple(assetName: 'apple_icon.svg'),
  arrowRedoDown(assetName: 'arrow-redo-down_icon.svg'),
  arrowRedoUp(assetName: 'arrow-redo-up_icon.svg'),
  arrowPop(assetName: 'arrow_pop_icon.svg'),
  attention(assetName: 'attention_icon.svg'),
  bell(assetName: 'bell_icon.svg'),
  bellPush(assetName: 'bell_push_icon.svg'),
  bookInfo(assetName: 'book_info_icon.svg'),
  calendar(assetName: 'calendar_icon.svg'),
  callArrow(assetName: 'call_arrow_icon.svg'),
  callCentre(assetName: 'call_centre_icon.svg'),
  call(assetName: 'call_icon.svg'),
  callLong(assetName: 'call_long_icon.svg'),
  callWait(assetName: 'call_wait_icon.svg'),
  camera(assetName: 'camera_icon.svg'),
  car(assetName: 'car_icon.svg'),
  chat(assetName: 'chat_icon.svg'),
  chatDef(assetName: 'chat_def_icon.svg'),
  check(assetName: 'check_icon.svg'),
  checked(assetName: 'checked_icon.svg'),
  checkbox(assetName: 'checkbox_icon.svg'),
  chevron(assetName: 'chevron_icon.svg'),
  chevronRight(assetName: 'chevron_right_icon.svg'),
  chip(assetName: 'chip_icon.svg'),
  city(assetName: 'city_icon.svg'),
  clock(assetName: 'clock_icon.svg'),
  close(assetName: 'close_icon.svg'),
  company(assetName: 'company_icon.svg'),
  contacts(assetName: 'contacts_icon.svg'),
  cross(assetName: 'cross_icon.svg'),
  dishwasher(assetName: 'dishwasher_icon.svg'),
  dry(assetName: 'dry_icon.svg'),
  edit(assetName: 'edit_icon.svg'),
  education(assetName: 'education_icon.svg'),
  email(assetName: 'email_icon.svg'),
  energy(assetName: 'energy_icon.svg'),
  event(assetName: 'event_icon.svg'),
  fail(assetName: 'fail_icon.svg'),
  faq(assetName: 'faq_icon.svg'),
  filter(assetName: 'filter_icon.svg'),
  flash(assetName: 'flash_icon.svg'),
  gallery(assetName: 'gallery_icon.svg'),
  guarantee(assetName: 'guarantee_icon.svg'),
  home(assetName: 'home_icon.svg'),
  linux(assetName: 'linux_icon.svg'),
  list(assetName: 'list_icon.svg'),
  location(assetName: 'location_icon.svg'),
  locationMan(assetName: 'location_man_icon.svg'),
  map(assetName: 'map_icon.svg'),
  menuCashbox(assetName: 'menu_cashbox_icon.svg'),
  menuChat(assetName: 'menu_chat_icon.svg'),
  menuHamburger(assetName: 'menu_hamburger_icon.svg'),
  menuManagement(assetName: 'menu_management_icon.svg'),
  menuNotifications(assetName: 'menu_notifications_icon.svg'),
  menuOrders(assetName: 'menu_orders_icon.svg'),
  menuScouting(assetName: 'menu_scouting_icon.svg'),
  menuSettings(assetName: 'menu_settings_icon.svg'),
  message(assetName: 'message_icon.svg'),
  microphoneOff(assetName: 'microphone_off_icon.svg'),
  microphoneOn(assetName: 'microphone_on_icon.svg'),
  microwave(assetName: 'microwave_icon.svg'),
  missedCall(assetName: 'missed_call_icon.svg'),
  more(assetName: 'more_icon.svg'),
  number(assetName: 'number_icon.svg'),
  numberHash(assetName: 'number_hash_icon.svg'),
  ordersSc(assetName: 'orders_sc_icon.svg'),
  oven(assetName: 'oven_icon.svg'),
  path(assetName: 'path_icon.svg'),
  pause(assetName: 'pause_icon.svg'),
  phone(assetName: 'phone_icon.svg'),
  phoneSelect(assetName: 'phone_select_icon.svg'),
  pin(assetName: 'pin_icon.svg'),
  printer(assetName: 'printer_icon.svg'),
  rate(assetName: 'rate_icon.svg'),
  repair(assetName: 'repair_icon.svg'),
  reverse(assetName: 'reverse_icon.svg'),
  ring(assetName: 'ring_icon.svg'),
  router(assetName: 'router_icon.svg'),
  save(assetName: 'save_icon.svg'),
  search(assetName: 'search_icon.svg'),
  service(assetName: 'service_icon.svg'),
  settings(assetName: 'settings_icon.svg'),
  shareLocation(assetName: 'share_location_icon.svg'),
  smart(assetName: 'smart_icon.svg'),
  sms(assetName: 'sms_icon.svg'),
  speakerOff(assetName: 'speaker_off_icon.svg'),
  speakerOn(assetName: 'speaker_on_icon.svg'),
  specialist(assetName: 'specialist_icon.svg'),
  specialist1(assetName: 'specialist_icon-1.svg'),
  status(assetName: 'status_icon.svg'),
  storage(assetName: 'storage_icon.svg'),
  support(assetName: 'support_icon.svg'),
  trash(assetName: 'trash_icon.svg'),
  tv(assetName: 'tv_icon.svg'),
  userAdd(assetName: 'user_add_icon.svg'),
  user(assetName: 'user_icon.svg'),
  userSearch(assetName: 'user_search_icon.svg'),
  users(assetName: 'users_icon.svg'),
  voiceRecord(assetName: 'voice_record_icon.svg'),
  wallet(assetName: 'wallet_icon.svg'),
  washingMachine(assetName: 'washing_machine_icon.svg'),
  washingMachine1(assetName: 'washing_machine_icon-1.svg'),
  wind(assetName: 'wind_icon.svg'),
  work(assetName: 'work_icon.svg');

  const AppIcons({
    required this.assetName,
  });

  /// Название файла
  final String assetName;

  /// Виджет для суффикса в поле ввода
  Widget inputSuffix({
    Color? color,
    double? width,
    double? height,
  }) =>
      SizedBox(
        width: 24,
        height: 24,
        child: Align(
          alignment: const Alignment(1, 0),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: widget(
              color: color,
              width: width,
              height: height,
            ),
          ),
        ),
      );

  /// Виджет иконки
  Widget widget({
    Color? color,
    double? width,
    double? height,
  }) =>
      SvgPicture.asset(
        'assets/icons/$assetName',
        package: 'uikit',
        colorFilter: color?.toColorFilter(),
        width: width,
        height: height,
      );

  /// Создание кнопки из иконки
  /// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-7481&mode=dev
  /// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-7487&mode=dev
  /// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-8808&mode=dev
  Widget iconButton({
    /// Цвет иконки
    Color? color,

    /// Цвет иконки + цвет фона кнопки
    AppSplitColor? splitColor,

    /// Шинира иконки
    double? width,

    /// Высота иконки
    double? height,

    /// Коллбек нажатия
    VoidCallback? onPressed,

    /// Всплывающая подсказка
    String? tooltip,

    /// Фиксированный размер кнопки
    Size? size = const Size.square(32),
  }) =>
      IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: splitColor?.secondary,
          surfaceTintColor: splitColor?.secondary,
          fixedSize: size,
        ),
        splashColor: splitColor?.primary,
        icon: widget(
          color: color ?? splitColor?.primary,
          width: width,
          height: height,
        ),
      );

  /// Кнопка из иконки на подобие [iconButton]
  /// Не имеет ограничений по размеру
  /// Анимация нажатия не выходит за пределы кнопки
  /// Размер иконки всегда в 2 раза меньше самой кнопки
  Widget fabButton({
    /// Цвет иконки + цвет фона кнопки
    AppSplitColor? color,

    /// Коллбек нажатия
    VoidCallback? onPressed,

    /// Всплывающая подсказка
    String? tooltip,

    /// Фиксированный размер кнопки
    Size size = const Size(32, 32),
  }) =>
      Material(
        color: color?.secondary ?? AppSplitColor.violet().secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width / 2),
        ),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: widget(
                color: color?.primary ?? AppSplitColor.violet().primary,
                width: size.width / 2,
                height: size.height / 2,
              ),
            ),
          ),
        ),
      );

  /// Иконка с круглым цветным фоном
  Widget iconColored({
    /// Цвет иконки + цвет фона
    required AppSplitColor color,

    /// Размер фона
    double size = 24,

    /// Размер иконки
    double? iconSize,
  }) =>
      Container(
        width: size,
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.secondary,
        ),
        child: Center(
          child: widget(
            color: color.primary,
            width: iconSize,
            height: iconSize,
          ),
        ),
      );

  /// Кнопка с анимацией
  /// При выполнении [Future] иконка будет вращаться
  Widget fabButtonAnimated<T>({
    /// Коллбек
    required Future<T> Function() onPressed,

    /// Цвет иконки + цвет фона
    AppSplitColor? color,

    /// Подсказка
    String? tooltip,

    /// Размер кнопки
    Size size = const Size(32, 32),
  }) =>
      _AnimatedWrapper<T>(
        color: color,
        onPressed: onPressed,
        tooltip: tooltip,
        size: size,
        assetName: assetName,
      );
}

class _AnimatedWrapper<T> extends StatefulWidget {
  const _AnimatedWrapper({
    required this.assetName,
    required this.onPressed,
    this.color,
    this.tooltip,
    this.size = const Size(32, 32),
  });

  final AppSplitColor? color;
  final Future<T> Function() onPressed;
  final String assetName;
  final String? tooltip;
  final Size size;

  @override
  State<_AnimatedWrapper> createState() => _AnimatedWrapperState();
}

class _AnimatedWrapperState extends State<_AnimatedWrapper>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Material(
            color: widget.color?.secondary ?? AppSplitColor.violet().secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.size.width / 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: widget.size.width,
              height: widget.size.height,
              child: InkWell(
                onTap: () async {
                  await _controller.forward();
                  await widget.onPressed.call();
                  _controller.reset();
                },
                child: Center(
                  child: Transform.rotate(
                    angle: _controller.value * 2.0 * math.pi,
                    child: SvgPicture.asset(
                      'assets/icons/${widget.assetName}',
                      package: 'uikit',
                      colorFilter: (widget.color?.primary ??
                              AppSplitColor.violet().primary)
                          .toColorFilter(),
                      width: widget.size.width / 2,
                      height: widget.size.height / 2,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
