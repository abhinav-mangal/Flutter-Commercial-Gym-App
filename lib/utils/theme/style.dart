// ignore_for_file: deprecated_member_use

import 'package:energym/src/import.dart';

import 'package:flutter/services.dart';

enum AppTheme { light, dark }

ThemeData lightTheme = ThemeData(
  appBarTheme:
      const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
  primaryColor: Colors.white,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  brightness: Brightness.light,
  accentColor: AppColors.mainColor,
  dividerColor: AppColors.accentColor,
  focusColor: AppColors.accentColor,
  hintColor: AppColors.secondColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  textTheme: TextTheme(
    headline5: TextStyle(
      fontSize: 22.0,
      color: AppColors.secondColor,
      height: 1.3,
    ),
    headline4: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      color: AppColors.secondColor,
      height: 1.3,
    ),
    headline3: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      color: AppColors.secondColor,
      height: 1.3,
    ),
    headline2: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      color: AppColors.mainColor,
      height: 1.4,
    ),
    headline1: TextStyle(
      fontSize: 26.0,
      fontWeight: FontWeight.w300,
      color: AppColors.secondColor,
      height: 1.4,
    ),
    subtitle1: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
      color: AppColors.secondColor,
      height: 1.3,
    ),
    headline6: TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      color: AppColors.mainColor,
      height: 1.3,
    ),
    bodyText2: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: AppColors.secondColor,
      height: 1.2,
    ),
    bodyText1: TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      color: AppColors.secondColor,
      height: 1.3,
    ),
    caption: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
      color: AppColors.accentColor,
      height: 1.2,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  appBarTheme:
      const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
  primaryColor: Colors.white,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF000000),
  accentColor: AppColors.mainDarkColor,
  dividerColor: AppColors.accentColor,
  hintColor: AppColors.secondDarkColor,
  focusColor: AppColors.accentDarkColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  // cursorColor: Colors.green,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  textTheme: const TextTheme(
    headline5: TextStyle(fontSize: 22.0, color: Colors.white, height: 1.3),
    headline4: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.3,
    ),
    headline3: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.3,
    ),
    headline2: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.4,
    ),
    headline1: TextStyle(
      fontSize: 26.0,
      fontWeight: FontWeight.w300,
      color: Colors.white,
      height: 1.4,
    ),
    subtitle1: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      height: 1.3,
    ),
    headline6: TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.3,
    ),
    bodyText2: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      height: 1.2,
    ),
    bodyText1: TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      height: 1.3,
    ),
    caption: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
      color: Colors.white,
      height: 1.2,
    ),
  ),
);
