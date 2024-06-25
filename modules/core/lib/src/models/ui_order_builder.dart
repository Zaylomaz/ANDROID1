import 'package:core/core.dart';
import 'package:json_reader/json_reader.dart';
import 'package:uikit/uikit.dart';

/*
* UI билдер для заказа
* на данный момент не используется
* можно использовать для динамических виджетов
*
* НЕ ОПИСЫВАЮ ДОКУМЕНТАЦИЮ ИЗ-ЗА НЕНАДОБНОСТИ В ИСПОЛЬЗОВАНИИ
* */

enum AppOrderOptions { email, map }

abstract class AppOrderOption {
  abstract final String title;
  abstract final Color iconColor;
  abstract final Color iconBackgroundColor;
  abstract final AppOrderOptions type;
  abstract Function action;

  static AppOrderOption? jsonParser(JsonReader json) {
    final type = AppOrderOptions.values
        .where((e) => e.name == json['type'].asString())
        .firstOrNull;
    switch (type) {
      case AppOrderOptions.email:
        return AppOrderOptionEmail.fromJson(json);
      case AppOrderOptions.map:
        return AppOrderOptionMap.fromJson(json);
      default:
        return null;
    }
  }
}

class AppOrderOptionEmail implements AppOrderOption {
  AppOrderOptionEmail({
    required this.title,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.email,
  });

  factory AppOrderOptionEmail.fromJson(JsonReader json) => AppOrderOptionEmail(
        title: json['title'].asString(),
        iconColor: json['iconColor'].asColor(),
        iconBackgroundColor: json['iconBackgroundColor'].asColor(),
        email: json['email'].asString(),
      );

  @override
  AppOrderOptions get type => AppOrderOptions.email;
  @override
  final String title;
  @override
  final Color iconColor;
  @override
  final Color iconBackgroundColor;

  final String email;

  @override
  Function action = () {};
}

class AppOrderOptionMap implements AppOrderOption {
  AppOrderOptionMap({
    required this.title,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.location,
  });

  factory AppOrderOptionMap.fromJson(JsonReader json) => AppOrderOptionMap(
        title: json['title'].asString(),
        iconColor: json['iconColor'].asColor(),
        iconBackgroundColor: json['iconBackgroundColor'].asColor(),
        location: Coords(
          json['latitude'].asDouble(),
          json['longitude'].asDouble(),
        ),
      );

  @override
  AppOrderOptions get type => AppOrderOptions.map;
  @override
  final String title;
  @override
  final Color iconColor;
  @override
  final Color iconBackgroundColor;

  final Coords location;

  @override
  Function action = () {};
}

enum AppOrderUIElements {
  sizedBox,
  row,
  iconWithTextRow,
  column,
  flexible,
  text,
  icon,
}

abstract class AppOrderUIElement {
  abstract final AppOrderUIElements type;
  abstract final Widget widget;

  static AppOrderUIElement jsonParser(JsonReader json) {
    final type = AppOrderUIElements.values
        .where((e) => e.name == json['type'].asString())
        .firstOrNull;
    switch (type) {
      case AppOrderUIElements.sizedBox:
        return AppOrderUISizedBox.fromJson(json);
      case AppOrderUIElements.row:
        return AppOrderUIRow.fromJson(json);
      case AppOrderUIElements.iconWithTextRow:
        return AppOrderUIIconTextRow.fromJson(json);
      case AppOrderUIElements.column:
        return AppOrderUIColumn.fromJson(json);
      case AppOrderUIElements.flexible:
        return AppOrderUIFlexible.fromJson(json);
      case AppOrderUIElements.text:
        return AppOrderUIText.fromJson(json);
      default:
        return const AppOrderUISizedBox(width: 0, height: 0);
    }
  }
}

class AppOrderUISizedBox implements AppOrderUIElement {
  const AppOrderUISizedBox({
    this.width,
    this.height,
  });

  factory AppOrderUISizedBox.fromJson(JsonReader json) => AppOrderUISizedBox(
        width: json['width'].asIntOrNull()?.toDouble(),
        height: json['height'].asIntOrNull()?.toDouble(),
      );

  @override
  AppOrderUIElements get type => AppOrderUIElements.sizedBox;

  final double? width;
  final double? height;

  @override
  Widget get widget => SizedBox(
        width: width,
        height: height,
      );
}

class AppOrderUIRow implements AppOrderUIElement {
  const AppOrderUIRow({
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });

  factory AppOrderUIRow.fromJson(JsonReader json) => AppOrderUIRow(
        mainAxisAlignment: json['mainAxisAlignment'].asStringOrNull(),
        crossAxisAlignment: json['crossAxisAlignment'].asStringOrNull(),
        children: json['children']
            .asList()
            .map(AppOrderUIElement.jsonParser)
            .toList(),
      );

  final String? mainAxisAlignment;
  final String? crossAxisAlignment;
  final List<AppOrderUIElement> children;

  @override
  AppOrderUIElements get type => AppOrderUIElements.row;

  @override
  Widget get widget => Row(
        mainAxisAlignment: MainAxisAlignment.values
                .where((e) => e.name == mainAxisAlignment)
                .firstOrNull ??
            MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.values
                .where((e) => e.name == crossAxisAlignment)
                .firstOrNull ??
            CrossAxisAlignment.center,
        children: children.map((e) => e.widget).toList(),
      );
}

class AppOrderUIIconTextRow implements AppOrderUIElement {
  const AppOrderUIIconTextRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.text,
    this.textColor = AppColors.white,
    this.textStyle = AppTextStyle.regularHeadline,
    this.iconSize = 16,
  });

  factory AppOrderUIIconTextRow.fromJson(JsonReader json) =>
      AppOrderUIIconTextRow(
        icon: AppIcons.values.firstWhere(
            (e) => e.name == json['icon'].asString(),
            orElse: () => AppIcons.fail),
        iconColor: json['iconColor'].asColor(),
        iconBackgroundColor: json['iconBackgroundColor'].asColor(),
        textColor: json['textColor'].asColor(),
        textStyle: AppTextStyle.values
            .firstWhere((e) => e.name == json['textStyle'].asString()),
        text: json['text'].asString(),
        iconSize: json['iconSize'].asIntOrNull()?.toDouble() ?? 16,
      );

  final AppIcons icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final double iconSize;
  final String text;
  final AppTextStyle textStyle;

  @override
  AppOrderUIElements get type => AppOrderUIElements.row;

  @override
  Widget get widget => Builder(
        builder: (context) {
          return IconWithTextRow(
            text: text,
            textColor: textColor,
            textStyle: textStyle.style(context),
            leading: icon.iconColored(
              color: AppSplitColor.custom(
                primary: iconColor,
                secondary: iconBackgroundColor,
              ),
            ),
          );
        },
      );
}

class AppOrderUIColumn implements AppOrderUIElement {
  const AppOrderUIColumn({
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });

  factory AppOrderUIColumn.fromJson(JsonReader json) => AppOrderUIColumn(
        mainAxisAlignment: json['mainAxisAlignment'].asStringOrNull(),
        crossAxisAlignment: json['crossAxisAlignment'].asStringOrNull(),
        children: json['children']
            .asList()
            .map(AppOrderUIElement.jsonParser)
            .toList(),
      );

  final String? mainAxisAlignment;
  final String? crossAxisAlignment;
  final List<AppOrderUIElement> children;

  @override
  AppOrderUIElements get type => AppOrderUIElements.row;

  @override
  Widget get widget => Column(
        mainAxisAlignment: MainAxisAlignment.values
                .where((e) => e.name == mainAxisAlignment)
                .firstOrNull ??
            MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.values
                .where((e) => e.name == crossAxisAlignment)
                .firstOrNull ??
            CrossAxisAlignment.center,
        children: children.map((e) => e.widget).toList(),
      );
}

class AppOrderUIFlexible implements AppOrderUIElement {
  const AppOrderUIFlexible({
    required this.child,
    this.flex,
  });

  factory AppOrderUIFlexible.fromJson(JsonReader json) => AppOrderUIFlexible(
        flex: json['flex'].asIntOrNull(),
        child: AppOrderUIElement.jsonParser(json),
      );

  final int? flex;
  final AppOrderUIElement child;

  @override
  AppOrderUIElements get type => AppOrderUIElements.row;

  @override
  Widget get widget => Flexible(
        flex: flex ?? 1,
        child: child.widget,
      );
}

class AppOrderUIText implements AppOrderUIElement {
  const AppOrderUIText({
    required this.text,
    this.textStyle = AppTextStyle.regularCaption,
    this.textColor,
    this.maxLines,
    this.textOverflow,
    this.textAlign,
  });

  factory AppOrderUIText.fromJson(JsonReader json) => AppOrderUIText(
        text: json['text'].asString(),
        textStyle: AppTextStyle.values
            .firstWhere((e) => e.name == json['textStyle'].asString()),
        textColor: json['textColor'].asColor(),
        maxLines: json['maxLines'].asIntOrNull(),
        textOverflow: TextOverflow.values
            .firstWhere((e) => e.name == json['textOverflow'].asString()),
        textAlign: TextAlign.values
            .firstWhere((e) => e.name == json['textAlign'].asString()),
      );

  final String text;
  final AppTextStyle textStyle;
  final Color? textColor;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;

  @override
  AppOrderUIElements get type => AppOrderUIElements.row;

  @override
  Widget get widget => Builder(builder: (context) {
        return Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: textOverflow,
          style: textStyle.style(context, textColor),
        );
      });
}

class AppOrderLayout {
  const AppOrderLayout({
    required this.options,
    required this.children,
    required this.actions,
  });

  factory AppOrderLayout.fromJson(JsonReader json) => AppOrderLayout(
        options: json['options']
            .asList()
            .map(AppOrderOption.jsonParser)
            .whereType<AppOrderOption>()
            .toList(),
        children: json['children']
            .asList()
            .map(AppOrderUIElement.jsonParser)
            .toList(),
        actions:
            json['actions'].asList().map(AppOrderUIElement.jsonParser).toList(),
      );

  final List<AppOrderOption> options;
  final List<AppOrderUIElement> children;
  final List<AppOrderUIElement> actions;
}

final exampleJson = {
  'options': [
    {
      'type': 'email',
      'title': 'Email',
      'iconColor': '#fff000',
      'iconBackgroundColor': '#000fff',
      'email': 'wdfwefwe@dewdwe.de',
    },
    {
      'type': 'map',
      'title': 'На карте',
      'iconColor': '#fff000',
      'iconBackgroundColor': '#000fff',
      'location': {
        'latitude': 123123,
        'longitude': 142323,
      }
    }
  ],
  'widgets': [
    {
      'type': 'row',
      'mainAxisAlignment': 'start',
      'crossAxisAlignment': 'stretch',
      'children': [
        {
          'type': 'sizedBox',
          'width': 8,
        },
      ],
    },
    {
      'type': 'sizedBox',
      'height': 8,
    },
    {
      'type': 'column',
      'mainAxisAlignment': 'start',
      'crossAxisAlignment': 'stretch',
      'children': [
        {
          'type': 'iconWithTextRow',
          'icon': 'chevron',
          'iconColor': '#fff000',
          'iconBackgroundColor': '#000fff',
          'textColor': '#f0f0f0',
          'iconSize': 12,
          'text': 'Text in row',
          'textStyle': 'boldHeadLine'
        },
        {
          'type': 'sizedBox',
          'height': 8,
        },
        {
          'type': 'iconWithTextRow',
          'icon': 'map',
          'iconColor': '#fff000',
          'iconBackgroundColor': '#000fff',
          'textColor': '#f0f0f0',
          'iconSize': 16,
          'text': 'Text in 2row',
        },
      ],
    },
    {
      'type': 'sizedBox',
      'height': 8,
    },
    {
      'type': 'text',
      'text': 'Some text',
      'textColor': '#000fff',
      'textStyle': 'boldTitle2',
      'maxLines': 1,
      'textOverflow': 'ellipsis',
      'textAlign': 'center',
    }
  ],
  'action': []
};
