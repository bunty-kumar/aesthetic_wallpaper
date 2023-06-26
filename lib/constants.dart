import 'package:flutter/material.dart';

const Color primaryColorDark = Color(0xff0754a8);
const Color primaryColorLight = Color(0xff0773d4);
const Color greyColor = Color(0xffa5a5a5);
const Color lightGreyColor = Color(0xffEDEDED);
const Color mediumGreyColor = Color(0x99c6c6c6);
const Color blackColor = Color(0xff000000);
const Color whiteColor = Color(0xffffffff);
const Color greenColor = Color(0xff008000);
const Color yellowColor = Color(0xffe2af08);
const Color disabledButtonColor = Color(0x990754a8);
const Color redColor = Color(0xfff63939);

const String appKey =
    "your_key_here";

class Themes {
  static ThemeData defaultTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: whiteColor,
      appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: primaryColorDark,
          iconTheme: IconThemeData(color: whiteColor),
          titleTextStyle: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: whiteColor)),
      colorScheme: const ColorScheme.light(
          primary: primaryColorLight, secondary: primaryColorDark));
}
