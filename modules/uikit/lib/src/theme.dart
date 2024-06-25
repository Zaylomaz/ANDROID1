import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/*
* Создание темы приложения
* */

/// Палитра цветов
/// https://www.figma.com/file/36YshEgTaYdl2KupJleNeR/Koff-Project?type=design&node-id=2852-6764&mode=dev
mixin AppColors {
  ///#0b0b0b
  static const black = Color(0xff0b0b0b);

  ///#1d1d1d
  static const blackContainer = Color(0xff1d1d1d);

  ///#3b3b51
  static const blackLightContainer = Color(0xff3b3b51);

  ///#303959
  static const blackBorder = Color(0xff303959);

  ///#acacac
  static const grayText = Color(0xffacacac);

  ///#9285ee
  static const violet = Color(0xff9285ee);

  ///#B7B6E0
  static const violetLight = Color(0xffB7B6E0);

  ///#2F2D3D
  static const violetDark = Color(0xff2F2D3D);

  ///#34343B
  static const violetLightDark = Color(0xff34343B);

  ///#ffffff
  static const white = Color(0xffffffff);

  ///#9fe89c
  static const green = Color(0xff9fe89c);

  ///#313C30
  static const greenDark = Color(0xff313C30);

  ///#d46e6a
  static const red = Color(0xffd46e6a);

  ///#392929
  static const redDark = Color(0xff392929);

  ///#F09E23
  static const yellow = Color(0xffF09E23);

  ///#372810
  static const yellowDark = Color(0xff372810);

  ///#202D3A
  static const cyan = Color(0xff71AFE8);

  ///#202D3A
  static const cyanDark = Color(0xff202D3A);

  static const blueGradient = LinearGradient(
    colors: [
      Color(0xff5aa7ee),
      Color(0xff584fdc),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Цветовые пары часто встречающиеся в дизайне
/// Имеет определенные в дизайне конструкторы [AppSplitColor.green] и подобные
/// Конструктор [AppSplitColor.custom] аозволяет задать любую цветовую пару
class AppSplitColor {
  const AppSplitColor._(this.primary, this.secondary);

  factory AppSplitColor.green() => const AppSplitColor._(
        AppColors.green,
        AppColors.greenDark,
      );

  factory AppSplitColor.red() => const AppSplitColor._(
        AppColors.red,
        AppColors.redDark,
      );

  factory AppSplitColor.cyan() => const AppSplitColor._(
        AppColors.cyan,
        AppColors.cyanDark,
      );

  factory AppSplitColor.violet() => const AppSplitColor._(
        AppColors.violet,
        AppColors.violetDark,
      );

  factory AppSplitColor.violetLight() => const AppSplitColor._(
        AppColors.violetLight,
        AppColors.violetLightDark,
      );

  factory AppSplitColor.yellow() => const AppSplitColor._(
        AppColors.yellow,
        AppColors.yellowDark,
      );

  factory AppSplitColor.custom({
    required Color primary,
    required Color secondary,
  }) =>
      AppSplitColor._(
        primary,
        secondary,
      );

  final Color primary;
  final Color secondary;
}

/// Стили текста
/// Название стилей соответствует дизайну
enum AppTextStyle {
  ///fontSize: 32, fontWeight: FontWeight.w700
  boldLargeTitle(
    fontSize: 32,
    letterSpacing: -.3,
    fontWeight: FontWeight.w700,
  ),

  ///fontSize: 22, fontWeight: FontWeight.w500
  boldTitle2(
    fontSize: 22,
    letterSpacing: -.3,
    fontWeight: FontWeight.w500,
  ),

  ///fontSize: 17, fontWeight: FontWeight.w600
  boldHeadLine(
    fontSize: 17,
    letterSpacing: -.3,
    fontWeight: FontWeight.w600,
  ),

  ///fontSize: 15, fontWeight: FontWeight.w600
  boldSubHeadline(
    fontSize: 15,
    height: 24 / 20,
    letterSpacing: -.3,
    fontWeight: FontWeight.w600,
  ),

  ///fontSize: 17, fontWeight: FontWeight.w400
  regularHeadline(
    fontSize: 17,
    letterSpacing: -.3,
  ),

  ///fontSize: 15, fontWeight: FontWeight.w400
  regularSubHeadline(
    fontSize: 15,
    letterSpacing: -.3,
  ),

  ///fontSize: 12, fontWeight: FontWeight.w400
  regularCaption(
    fontSize: 12,
    letterSpacing: -.3,
  );

  const AppTextStyle({
    required this.fontSize,
    required this.letterSpacing,
    this.height = 1.3,
    this.fontWeight = FontWeight.w400,
  });

  /// Размер шрифта
  final int fontSize;

  /// Высота строки
  final double height;

  /// Межбуквенное растояние
  final double letterSpacing;

  /// Толщина шрифта
  final FontWeight fontWeight;

  /// Простой конструктор [TextStyle] исходя из стиля
  TextStyle get textStyle => TextStyle(
        fontFamily: 'SFProText',
        fontSize: fontSize.toDouble(),
        height: height,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        color: AppColors.white,
      );

  /// Простой конструктор [TextStyle] исходя из стиля с указанием цвета
  TextStyle textStyleWithColor(Color color) => textStyle.copyWith(color: color);

  /// Конструктор [TextStyle] исходя из темы с возможностью
  /// переопределить цвет
  TextStyle style(BuildContext context, [Color? color]) {
    switch (this) {
      case AppTextStyle.boldLargeTitle:
        return Theme.of(context)
            .primaryTextTheme
            .titleLarge!
            .copyWith(color: color);
      case AppTextStyle.boldTitle2:
        return Theme.of(context)
            .primaryTextTheme
            .titleMedium!
            .copyWith(color: color);
      case AppTextStyle.boldHeadLine:
        return Theme.of(context)
            .primaryTextTheme
            .headlineLarge!
            .copyWith(color: color);
      case AppTextStyle.boldSubHeadline:
        return Theme.of(context)
            .primaryTextTheme
            .titleSmall!
            .copyWith(color: color);
      case AppTextStyle.regularHeadline:
        return Theme.of(context)
            .primaryTextTheme
            .headlineMedium!
            .copyWith(color: color);
      case AppTextStyle.regularSubHeadline:
        return Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: color);
      case AppTextStyle.regularCaption:
        return Theme.of(context)
            .primaryTextTheme
            .bodyMedium!
            .copyWith(color: color);
    }
  }
}

/// Основная тема
mixin AppTheme {
  /// Окантовка поля ввода
  static final _inputBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Colors.transparent,
    ),
    borderRadius: BorderRadius.circular(12),
  );

  /// Окантовка поля ввода в фокусе
  static final _inputFocusBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: AppColors.violetLight,
    ),
    borderRadius: BorderRadius.circular(12),
  );

  /// Окантовка поля ввода с ошибкой
  static final _inputErrorBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: AppColors.red,
    ),
    borderRadius: BorderRadius.circular(12),
  );

  /// Тема
  static final data = ThemeData(
    fontFamily: 'SFProText',
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    platform: TargetPlatform.android,
    splashColor: AppColors.violet,
    primaryColor: AppColors.violet,
    primaryColorDark: AppColors.black,
    primaryColorLight: AppColors.white,
    primaryTextTheme: TextTheme(
      bodySmall: AppTextStyle.regularCaption.textStyle,
      bodyMedium: AppTextStyle.regularCaption.textStyle,
      bodyLarge: AppTextStyle.regularCaption.textStyle,
      headlineLarge: AppTextStyle.boldHeadLine.textStyle,
      headlineMedium: AppTextStyle.regularHeadline.textStyle,
      headlineSmall: AppTextStyle.regularSubHeadline.textStyle,
      titleLarge: AppTextStyle.boldLargeTitle.textStyle,
      titleMedium: AppTextStyle.boldTitle2.textStyle,
      titleSmall: AppTextStyle.boldSubHeadline.textStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: AppTextStyle.regularCaption.textStyle,
      floatingLabelStyle: AppTextStyle.regularCaption.textStyle,
      alignLabelWithHint: true,
      outlineBorder: const BorderSide(
        color: Colors.transparent,
      ),
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputFocusBorder,
      disabledBorder: _inputBorder,
      errorBorder: _inputErrorBorder,
      filled: true,
      fillColor: AppColors.blackContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      constraints: const BoxConstraints(minHeight: 48),
      isCollapsed: true,
      suffixIconColor: Colors.white,
      prefixIconColor: Colors.white,
      errorStyle: AppTextStyle.regularCaption.textStyle.copyWith(
        color: AppColors.red,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.black,
      surfaceTintColor: AppColors.black,
      iconTheme: const IconThemeData(
        color: AppColors.white,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.violet,
        size: 32,
      ),
      centerTitle: true,
      titleTextStyle: AppTextStyle.boldHeadLine.textStyle,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.violetLightDark,
      thickness: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.black,
      selectedItemColor: AppColors.violet,
      unselectedItemColor: AppColors.grayText,
      selectedLabelStyle: AppTextStyle.regularCaption.textStyle.copyWith(
        color: AppColors.violet,
      ),
      unselectedLabelStyle: AppTextStyle.regularCaption.textStyle.copyWith(
        color: AppColors.grayText,
      ),
      enableFeedback: true,
      type: BottomNavigationBarType.fixed,
    ),
    drawerTheme: DrawerThemeData(
      surfaceTintColor: AppColors.blackContainer,
      backgroundColor: AppColors.blackContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    ),
    splashFactory: const InkResponse(
      splashColor: AppColors.violetLight,
      overlayColor: MaterialStatePropertyAll<Color>(AppColors.violetLightDark),
    ).splashFactory,
    tabBarTheme: TabBarTheme(
      labelStyle: AppTextStyle.regularHeadline.textStyle.copyWith(
        color: AppColors.black,
      ),
      unselectedLabelStyle: AppTextStyle.regularHeadline.textStyle.copyWith(
        color: AppColors.violetLight,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: AppColors.violet,
      dividerColor: AppColors.violetLightDark,
      splashFactory: NoSplash.splashFactory,
      labelPadding: const EdgeInsets.all(8),
      labelColor: AppColors.violet,
      unselectedLabelColor: AppColors.violetLight,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.blackContainer,
      surfaceTintColor: AppColors.blackContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      titleTextStyle: AppTextStyle.boldSubHeadline.textStyle,
      contentTextStyle: AppTextStyle.regularSubHeadline.textStyle,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: AppColors.blackContainer,
      contentPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      horizontalTitleGap: 12,
      enableFeedback: true,
    ),
  );
}
