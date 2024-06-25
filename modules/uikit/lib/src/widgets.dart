import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uikit/uikit.dart';

/*
* Виджеты из дизайна
* */

/// Стилизированный [AppBar]
/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=1749-1771&mode=dev
class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  const AppToolbar({
    this.leading,
    this.title,
    this.actions,
    this.bottom,
    super.key,
  });

  /// Левая иконка
  final Widget? leading;

  /// Текст по центру
  final Widget? title;

  /// Кнопки справа
  final List<Widget>? actions;

  /// Bottom widget
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static Widget? hamburger(BuildContext context) =>
      Scaffold.maybeOf(context)?.hasDrawer == true
          ? AppIcons.menuHamburger.iconButton(
              color: AppColors.white,
              onPressed: Scaffold.of(context).openDrawer,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            )
          : null;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.maybeOf(context)?.canPop() == true;
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: leading ??
          (canPop
              ? AppIcons.arrowPop.iconButton(
                  color: AppColors.white,
                  onPressed: Navigator.maybeOf(context)?.maybePop,
                )
              : hamburger(context) ?? leading),
      title: DefaultTextStyle.merge(
        style: AppTextStyle.boldHeadLine.style(context),
        child: title ?? const SizedBox.shrink(),
      ),
      actions: [
        ...?actions,
        const SizedBox(width: 16),
      ],
      bottom: bottom,
    );
  }
}

/// Контейнер для контента
class AppMaterialBox extends StatelessWidget {
  const AppMaterialBox({
    required this.child,
    this.borderSide = const BorderSide(color: Colors.transparent, width: 0),
    this.borderRadius,
    this.elevation = 0,
    super.key,
  });

  factory AppMaterialBox.withPadding({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? elevation,
    Key? key,
  }) =>
      AppMaterialBox(
        borderSide:
            borderSide ?? const BorderSide(color: Colors.transparent, width: 0),
        borderRadius: borderRadius,
        elevation: elevation ?? 0,
        key: key,
        child: Padding(
          padding: padding,
          child: child,
        ),
      );

  /// Контент
  final Widget child;

  /// Борт
  final BorderSide borderSide;

  /// Закругление углов
  final BorderRadius? borderRadius;

  /// Тень
  final double elevation;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        side: borderSide,
      ),
      clipBehavior: Clip.hardEdge,
      color: AppColors.blackContainer,
      surfaceTintColor: AppColors.blackContainer,
      child: child,
    );
  }
}

/// Крутилка прелоадер
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({super.key});

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircularProgressIndicator(
        valueColor: animationController.drive(
          ColorTween(
            begin: AppColors.violetLight,
            end: AppColors.green,
          ),
        ),
      ),
    );
  }
}

/// Группа пунктов меню в боковом меню
class AppDrawerGroup extends StatelessWidget {
  const AppDrawerGroup({required this.items, super.key});

  /// Пункты меню
  final List<AppDrawerMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: AppColors.black,
        surfaceTintColor: AppColors.black,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      ),
    );
  }
}

/// Пункт меню в боковом меню
class AppDrawerMenuItem extends StatelessWidget {
  const AppDrawerMenuItem({
    required this.text,
    required this.icon,
    required this.onTap,
    this.trailing,
    super.key,
  });

  /// Коллбек нажатия
  final VoidCallback onTap;

  /// Иконка
  final Widget icon;

  /// Название
  final String text;

  /// Виджет справа
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyle.regularHeadline.style(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Правая иконка для пункта меню в боковом меню
class AppDrawerCounter extends StatelessWidget {
  const AppDrawerCounter({required this.color, required this.count, super.key});

  /// Цвет
  final AppSplitColor color;

  /// Количество (например уведомлений)
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      constraints: const BoxConstraints(minWidth: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.secondary,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Text(
            count.toString(),
            style: AppTextStyle.regularCaption.style(
              context,
              color.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Пустой список
WidgetBuilder noItemsInListBuilder(BuildContext context) =>
    (context) => Builder(builder: (context) {
          return Center(
            child: Text(
              'Список пуст',
              style: AppTextStyle.regularHeadline.style(context),
            ),
          );
        });

/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=1696-1780&mode=dev
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.isSelected,
    this.onTap,
    super.key,
  });

  /// Название
  final String label;

  /// Коллбек нажатия
  final VoidCallback? onTap;

  /// Заливка цветом
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: AppColors.violetLight,
          ),
        ),
        color: isSelected ? AppColors.violetLight : AppColors.black,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SizedBox(
              height: 24,
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyle.regularHeadline.style(
                    context,
                    isSelected ? AppColors.black : AppColors.violetLight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Leading виджет для ListTile
/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-8594&mode=dev
class AppListTileLeading extends StatelessWidget {
  const AppListTileLeading({required this.child, super.key});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.black,
      ),
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: child,
      ),
    );
  }
}

/// Типы всплывающих уведомлений
enum AppMessageType {
  error(AppColors.redDark, AppColors.red, AppColors.white),
  info(AppColors.violetDark, AppColors.white, AppColors.violet),
  success(AppColors.greenDark, AppColors.white, AppColors.green);

  const AppMessageType(
    this.backgroundColor,
    this.textColor,
    this.actionColor,
  );
  final Color backgroundColor;
  final Color textColor;
  final Color actionColor;
}

/// Показать всплывающее уведомление
Future showMessage(
  BuildContext context, {
  /// Тест уведомления
  required String message,

  /// Тип уведомления
  AppMessageType type = AppMessageType.info,

  /// Опциональная кнопка
  VoidCallback? action,

  /// Название действия
  String? actionText,

  /// Период показа
  Duration duration = const Duration(seconds: 5),

  /// Иконка
  Widget? prefixIcon,
}) async {
  assert(action == null || actionText?.isNotEmpty == true);
  ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.regularHeadline.style(
                context,
                type.textColor,
              ),
            ),
          )
        ],
      ),
      backgroundColor: type.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      action: action != null
          ? SnackBarAction(
              textColor: type.actionColor,
              label: actionText!,
              onPressed: action,
            )
          : null,
    ),
  );
}

/// Тип выбора файла для фото
/// галлерея или камера
enum AppFileDestination {
  gallery(AppIcons.gallery, 'Галлерея'),
  camera(AppIcons.camera, 'Камера');

  const AppFileDestination(this.icon, this.title);

  final AppIcons icon;
  final String title;

  /// Виджет билдер для опции
  Widget widget({required VoidCallback onPressed}) => this == camera
      ? _FileDestinationChoiceElement.camera(onPressed: onPressed)
      : _FileDestinationChoiceElement.gallery(onPressed: onPressed);
}

/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2928-4451&mode=dev
class _FileDestinationChoiceElement extends StatelessWidget {
  const _FileDestinationChoiceElement._(this.type, this.onPressed);

  factory _FileDestinationChoiceElement.gallery(
          {required VoidCallback onPressed}) =>
      _FileDestinationChoiceElement._(AppFileDestination.gallery, onPressed);

  factory _FileDestinationChoiceElement.camera(
          {required VoidCallback onPressed}) =>
      _FileDestinationChoiceElement._(AppFileDestination.camera, onPressed);

  final AppFileDestination type;

  /// Коллбек нажатия
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 120,
      child: Material(
        color: AppColors.blackContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DottedBorder(
              color: AppColors.violetLight,
              radius: const Radius.circular(10),
              strokeCap: StrokeCap.round,
              borderType: BorderType.RRect,
              dashPattern: const [2, 2],
              padding: EdgeInsets.zero,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    type.icon.widget(
                      color: AppColors.violetLight,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.title,
                      style: AppTextStyle.regularCaption.style(
                        context,
                        AppColors.violetLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Кнопка звонка
/// С типами
typedef PhoneNumber = Map<String, String>;
typedef PhoneNumbers = List<PhoneNumber>;

class CallButton extends StatefulWidget {
  const CallButton({
    required this.isSipActive,
    required this.onMakeCall,
    required this.onTryCall,
    this.phone = '',
    this.additionalPhones = const [],
    this.binotel = '',
    this.asterisk = '',
    this.ringostat = '',
    super.key,
  });

  /// Основной телефон
  final String phone;

  /// Дополнительные телефоны
  final List<String> additionalPhones;

  /// Линия Бинотел
  final String binotel;

  /// Линия Asterisk
  final String asterisk;

  /// Линия Ringostat
  final String ringostat;

  /// Работает ли SIP служба
  final bool isSipActive;

  /// Коллбек звонка
  final Future Function(String) onMakeCall;

  /// Коллбек не удачного звонка
  final VoidCallback onTryCall;

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  final phones = PhoneNumbers.empty(growable: true);
  var _isActive = true;

  @override
  void initState() {
    var iteration = 0;
    if (widget.binotel.isNotEmpty) {
      phones.add({
        'name': 'Binotel',
        'phone': widget.binotel,
      });
    }
    if (widget.asterisk.isNotEmpty) {
      phones.add({
        'name': 'Asterisk',
        'phone': widget.asterisk,
      });
    }
    if (widget.ringostat.isNotEmpty) {
      phones.add({
        'name': 'Ringostat',
        'phone': widget.ringostat,
      });
    }
    if (widget.phone.isNotEmpty) {
      phones.add({
        'name': 'Основной',
        'phone': widget.phone,
      });
    }
    if (widget.additionalPhones.isNotEmpty) {
      for (final element in widget.additionalPhones) {
        iteration += 1;
        phones.add({
          'name': 'Дополнительный $iteration',
          'phone': element,
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuTheme(
      data: PopupMenuThemeData(
        color: AppColors.violetLightDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        enableFeedback: true,
        labelTextStyle: MaterialStateProperty.all(
          AppTextStyle.regularHeadline.style(
            context,
            AppColors.white,
          ),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: PopupMenuButton<String>(
          splashRadius: 0,
          surfaceTintColor: AppColors.greenDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          tooltip: 'Позвонить',
          itemBuilder: (context) {
            return phones
                .map((e) => PopupMenuItem(
                      value: e['phone'],
                      child: Text(e['name']!),
                    ))
                .toList();
          },
          onSelected: (phone) async {
            if (widget.isSipActive && _isActive) {
              setState(() {
                _isActive = false;
              });
              await widget.onMakeCall(phone);
              setState(() {
                _isActive = true;
              });
            } else {
              widget.onTryCall();
            }
          },
          child: (phones.length > 1 ? AppIcons.phoneSelect : AppIcons.phone)
              .iconColored(
            color: AppSplitColor.green(),
            size: 40,
            iconSize: 24,
          ),
        ),
      ),
    );
  }
}

/// Виджет показывающий ошибку загрузки изображения
ImageErrorWidgetBuilder imageErrorWidget = (context, e, __) => Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            AppIcons.gallery.widget(
              color: AppColors.red,
              width: 32,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error 404',
                style: AppTextStyle.regularCaption.style(
                  context,
                  AppColors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );

/// Виджет иконки с текстом
/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2896-3762&mode=dev
class IconWithTextRow extends StatelessWidget {
  const IconWithTextRow({
    required this.text,
    this.leading,
    this.textColor = AppColors.white,
    this.textStyle,
    this.maxLines = 2,
    Key? key,
  }) : super(key: key);

  /// Иконка
  final Widget? leading;

  /// Текст
  final String text;

  /// Цвет текста
  final Color textColor;

  /// Стиль текста
  final TextStyle? textStyle;

  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: textStyle ??
                AppTextStyle.regularHeadline.style(context, textColor),
          ),
        ),
      ],
    );
  }
}

/// Бейдж для элемента списка, например для уведомлений
class BadgeDrop extends StatelessWidget {
  const BadgeDrop({
    required this.color,
    this.size = const Size.square(32),
    this.icon,
    this.iconColor = AppColors.blackContainer,
    this.iconSize = const Size.square(16),
    super.key,
  });

  final Color color;
  final AppIcons? icon;
  final Color iconColor;
  final Size iconSize;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Material(
        color: color,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(size.height * .625),
          bottomLeft: Radius.circular(size.height * .625),
        ),
        child: Center(
          child: icon?.widget(
            color: iconColor,
            width: iconSize.width,
            height: iconSize.height,
          ),
        ),
      ),
    );
  }
}

class MaterialBottomSheetLayout extends StatelessWidget {
  const MaterialBottomSheetLayout({
    required this.child,
    this.title,
    super.key,
  });

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: AppColors.blackContainer,
          border: Border(
            top: BorderSide(
              color: Color(0xFF79747E),
            ),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF79747E).withOpacity(.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
            if (title?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  title.toString(),
                  style: AppTextStyle.regularSubHeadline.style(
                    context,
                    AppColors.violetLight,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
